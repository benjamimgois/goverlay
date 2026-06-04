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
unit PasVulkan.Compression;
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

{$scopedenums on}
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
     PasMP,
     PasVulkan.Types,
     PasVulkan.Math,
     PasVulkan.Compression.Deflate,
     PasVulkan.Compression.LZBRS,
     PasVulkan.Compression.LZBRSF,
     PasVulkan.Compression.LZBRSX,
     PasVulkan.Compression.LZBRRC,
     PasVulkan.Compression.LZMA;

type TpvCompressionMethod=
      (
       None=0,
       Deflate=1,
       LZBRSF=2,
       LZBRRC=3,
       LZMA=4,
       LZBRS=5,
       LZBRSX=6
      );

var pvCompressionPasMPInstance:TPasMP=nil;

// Convert a 32-bit float to a uint32, preserving order.
function MapFloatToUInt32WithOrderPreservation(const aValue:TpvFloat):TpvUInt32; inline;

// Convert a 32-bit uint32 to a float, preserving order.
function UnmapFloatFromUInt32WithOrderPreservation(const aValue:TpvUInt32):TpvFloat; inline;

// This function transforms 32-bit float data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransform32BitFloatData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure ForwardTransform32BitFloatData(const aStream:TStream); overload;

// This function transforms 32-bit float data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransform32BitFloatData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure BackwardTransform32BitFloatData(const aStream:TStream); overload;

// This function transforms RGBA8 data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransformRGBA8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure ForwardTransformRGBA8Data(const aStream:TStream); overload;

// This function transforms RGBA8 data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransformRGBA8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure BackwardTransformRGBA8Data(const aStream:TStream); overload;

// This function transforms R8 data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransformR8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure ForwardTransformR8Data(const aStream:TStream); overload;

// This function transforms R8 data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransformR8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure BackwardTransformR8Data(const aStream:TStream); overload;

// This function transforms RGBA32 data to the reordered order (RGBARGBARGBARGBA => RRRRGGGGBBBBAAAA )
procedure ForwardTransformRGBA32OrderData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure ForwardTransformRGBA32OrderData(const aStream:TStream); overload;

// This function transforms RGBA32 data back from the reordered order (RRRRGGGGBBBBAAAA => RGBARGBARGBARGBA)
procedure BackwardTransformRGBA32OrderData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); overload;
procedure BackwardTransformRGBA32OrderData(const aStream:TStream); overload;

function CompressStream(const aInStream:TStream;const aOutStream:TStream;const aCompressionMethod:TpvCompressionMethod=TpvCompressionMethod.LZBRRC;const aCompressionLevel:TpvUInt32=5;const aParts:TpvUInt32=0):boolean;

function DecompressStream(const aInStream:TStream;const aOutStream:TStream):boolean;

implementation

//uses PasVulkan.Application;

////////////////////////////////////////////////////////////////////////////////////////

// Convert a 32-bit float to a uint32, preserving order.
function MapFloatToUInt32WithOrderPreservation(const aValue:TpvFloat):TpvUInt32; inline;
var Temporary:TpvUInt32;
begin
 Temporary:=TpvUInt32(Pointer(@aValue)^);
 result:=Temporary xor (TpvUInt32(TpvUInt32(-TpvInt32(TpvUInt32(Temporary shr 31)))) or TpvUInt32($80000000));
end;

// Convert a 32-bit uint32 to a float, preserving order.
function UnmapFloatFromUInt32WithOrderPreservation(const aValue:TpvUInt32):TpvFloat; inline;
var Temporary:TpvUInt32;
begin
 Temporary:=aValue xor TpvUInt32(TpvUInt32(TpvUInt32(aValue shr 31)-1) or TpvUInt32($80000000));
 result:=TpvFloat(Pointer(@Temporary)^);
end;

////////////////////////////////////////////////////////////////////////////////////////

{$ifdef cpuamd64}
procedure ForwardTransform32BitFloatDataAMD64(aInData,aOutData:pointer;aDataSize:TpvSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const Data0:array[0..3] of TpvUInt32=($80000000,$80000000,$80000000,$80000000);
      Data5:array[0..15] of TpvUInt8=(3,7,11,15,0,0,0,0,0,0,0,0,0,0,0,0);
      Data6:array[0..15] of TpvUInt8=(2,6,10,14,0,0,0,0,0,0,0,0,0,0,0,0);
      Data7:array[0..15] of TpvUInt8=(1,5,9,13,0,0,0,0,0,0,0,0,0,0,0,0);
      Data8:array[0..15] of TpvUInt8=(0,4,8,12,0,0,0,0,0,0,0,0,0,0,0,0);
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Entry & quick-exit for too-small data
 cmp r8,4
 jb @EarlyExit // if <4 bytes, nothing to do

 // Prologue: save callee-saved regs & stack space for xmm6/7
 push r15
 push r14
 push r13
 push r12
 push rsi
 push rdi
 push rbp
 push rbx
 sub rsp,40
 movdqa oword ptr [rsp+16],xmm7
 movdqa oword ptr [rsp],xmm6

 // Compute element counts & offsets
 mov rax,r8
 shr rax,2 // number of 32-bit floats
 lea rsi,[rax+rax] // rsi = 2*count
 lea r9,[rax+rax*2] // r9  = 3*count

 // Choose scalar fallback for small blocks (<48 bytes)
 cmp r8,48
 jae @SIMDSetup // if >=48 bytes, go SIMD

 // else prepare for small-loop
 xor r8d,r8d

@ScalarLoopInit:
 xor r10d,r10d // inner byte-index = 0

@ScalarElementLoop: // small-block loop: process each float
 lea r11,[rdx+r8] // outBase = outPtr + byteOffset
 add r9,r11 // update write pointers
 add rsi,r11
 lea rdi,[r8+rax] // outPtr+count
 sub rax,r8
 add rdi,rdx
 lea rcx,[rcx+r8*4] // inPtr+byteOffset
 xor edx,edx

@ScalarProcess: // per-float transform (scalar)
 mov r8d,dword ptr [rcx+rdx*4]
 mov ebp,r8d
 sar ebp,31 // sign bit to all bits
 or ebp,$80000000 // make positive magnitude
 xor ebp,r8d // xor to apply sign‐flip
 mov ebx,ebp
 sub ebx,r10d // delta = curr – prev
 mov r8d,ebx
 shr r8d,24 // extract highest byte
 mov byte ptr [r11+rdx],r8b
 mov r8d,ebx
 shr r8d,16
 mov byte ptr [rdi+rdx],r8b
 mov byte ptr [rsi+rdx],bh
 mov byte ptr [r9+rdx],bl
 inc rdx
 mov r10d,ebp // prev = curr
 cmp rax,rdx
 jne @ScalarProcess // loop floats

@ScalarEpilogue: // restore & exit
 movaps xmm6,oword ptr [rsp]
 movaps xmm7,oword ptr [rsp+16]
 add rsp,40
 pop rbx
 pop rbp
 pop rdi
 pop rsi
 pop r12
 pop r13
 pop r14
 pop r15

@EarlyExit:
 jmp @Exit

 // SIMD path for larger blocks
@SIMDSetup:
 // prepare pointers & alignment for SIMD path
 lea r11,[rdx+r9]  // out3_base = outPtr + 3*count
 and r8,-4         // align count down to multiple of 4 floats
 lea r10,[rdx+r8]  // out0_end   = outPtr + aligned_count
 add r8,rcx        // in_end     = inPtr  + aligned_count*4
 lea rbx,[rdx+rsi] // out2_base = outPtr + 2*count
 lea r15,[rdx+rax] // out1_base = outPtr + 1*count

 // Check if we should fall back to scalar (unaligned) loop
 cmp r11,r8
 setb r12b
 cmp rcx,r10
 setb r13b
 cmp rbx,r8
 setb r10b
 cmp rcx,r11
 setb bpl
 cmp r15,r8
 setb dil
 cmp rcx,rbx
 setb r14b
 cmp rdx,r8
 setb r11b
 cmp rcx,r15
 setb bl

 xor r8d,r8d // clear flags
 test r12b,r13b
 jne @ScalarLoopInit // if any overlap, scalar fallback
 and r10b,bpl
 jne @ScalarLoopInit
 and dil,r14b
 jne @ScalarLoopInit
 mov r10d,0
 and r11b,bl
 jne @ScalarElementLoop // scalar fallback if still unaligned

 // Set up for SIMD: load constants & zero xmm0
 mov r8,rax // total floats
 and r8,-4 // multiple of 4
 pxor xmm0,xmm0 // zero vector
 movdqa xmm1,oword ptr [rip+Data0] // mask to flip sign bit
 movd xmm2,dword ptr [rip+Data5] // shuffle control for byte 3
 movd xmm3,dword ptr [rip+Data6] // byte 2
 movd xmm4,dword ptr [rip+Data7] // byte 1
 movd xmm5,dword ptr [rip+Data8] // byte 0

 mov r10,r8 // element count
 mov r11,rdx // dst_ptr
 mov rdi,rcx // src_ptr

@SIMDMainLoop:
 // Load 4 floats, compute signed-magnitude, and delta pack
 movdqa xmm6,xmm0 // save prev vector
 movdqu xmm7,oword ptr [rdi] // load 4 raw floats
 movdqa xmm0,xmm7
 psrad xmm0,31 // sign mask (-1 or 0 per lane)
 por xmm0,xmm1 // set MSB for magnitude
 pxor xmm0,xmm7 // signed-magnitude: value xor sign-mask

 // compute vector of differences between this and previous
 movdqa xmm7,xmm0
 palignr xmm7,xmm6,12 // shift-in previous high dword
 movdqa xmm6,xmm0
 psubd xmm6,xmm7 // deltas in xmm6

 // scatter each delta byte-plane via pshufb + movd
 movdqa xmm7,xmm6
 pshufb xmm7,xmm2 // extract byte 3 of each delta
 movd dword ptr [r11],xmm7

 movdqa xmm7,xmm6
 pshufb xmm7,xmm3 // byte 2
 movd dword ptr [r11+rax],xmm7

 movdqa xmm7,xmm6
 pshufb xmm7,xmm4 // byte 1
 movd dword ptr [r11+rax*2],xmm7

 pshufb xmm6,xmm5 // byte 0 in xmm6
 movd dword ptr [r11+r9],xmm6

 // advance pointers and counters
 add rdi,16 // next 4 floats
 add r11,4 // next 4 output bytes per plane
 add r10,-4 // subtract 4 elements
 jne @SIMDMainLoop // loop until all aligned floats done

 cmp rax,r8
 je @ScalarEpilogue// if exactly aligned, skip scalar tail

 // extract remaining count (1–3 floats) into r10d and fall into scalar
 pextrd r10d,xmm0,3
 jmp @ScalarElementLoop // scalar tail for 1–3 floats

@Exit:
end;

(*
procedure ForwardTransform32BitFloatDataAMD64(aInData,aOutData:pointer;aDataSize:TpvSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 shr r8,2
 je @Exit
 push rdi
 mov r11,rcx
 mov r10,rdx
 xor r9d,r9d
 push rsi
 xor eax,eax
 lea rsi,[rdx+r8]
 push rbx
 lea rbx,[rdx+r8*2]
 lea rdi,[rbx+r8]
 jmp @LoopEntry
@Loop:
 mov r9d,edx
@LoopEntry:
 mov ecx,dword ptr [r11+rax*4]
 mov edx,ecx
 sar edx,31
 or edx,$80000000
 xor edx,ecx
 mov ecx,edx
 sub ecx,r9d
 mov r9d,ecx
 shr r9d,24
 mov byte ptr [r10+rax],r9b
 mov r9d,ecx
 shr r9d,16
 mov byte ptr [rsi+rax],r9b
 mov byte ptr [rbx+rax],ch
 mov byte ptr [rdi+rax],cl
 add rax,1
 cmp r8,rax
 jne @Loop
 pop rbx
 pop rsi
 pop rdi
@Exit:
end;*)
{$endif}

// This function transforms 32-bit float data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransform32BitFloatData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
{$ifdef cpuamd64}
begin
 ForwardTransform32BitFloatDataAMD64(aInData,aOutData,aDataSize);
end;
{$else}
var Index,Count:TpvSizeInt;
    Previous,Value,Delta:TpvUInt32;
begin
 Count:=aDataSize shr 2;
 Previous:=0;
 for Index:=0 to Count-1 do begin
  Value:=PpvUInt32Array(aInData)^[Index];
  Value:=Value xor (TpvUInt32(TpvUInt32(-TpvInt32(TpvUInt32(Value shr 31)))) or TpvUInt32($80000000));
  Delta:=Value-Previous;
  Previous:=Value;
  PpvUInt8Array(aOutData)^[Index]:=(Delta shr 24) and $ff;
  PpvUInt8Array(aOutData)^[Index+Count]:=(Delta shr 16) and $ff;
  PpvUInt8Array(aOutData)^[Index+(Count*2)]:=(Delta shr 8) and $ff;
  PpvUInt8Array(aOutData)^[Index+(Count*3)]:=(Delta shr 0) and $ff;
 end;
end;
{$endif}

procedure ForwardTransform32BitFloatData(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     ForwardTransform32BitFloatData(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      ForwardTransform32BitFloatData(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

{$ifdef cpuamd64}
procedure BackwardTransform32BitFloatDataAMD64(aInData,aOutData:pointer;aDataSize:TpvSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Entry & quick-exit for too-small data (<4 bytes)
 cmp r8,4
 jb @Exit

 // Prologue: save callee‑saved registers
 push rsi
 push rdi
 push rbx

 // Compute element count and split input planes
 // r8d := byte‑count; shr r8,2 => float‑count
 shr r8,2 // r8 = Count
 lea rax,[r8+r8*2] // rax = 3*Count
 mov r9,r8 // r9 =  Count
 neg r9    // r9 = -Count

 // Build pointers to each of the 4 byte‑planes in aInData:
 //   rcx = base+0*Count,        [rcx + index]   plane 0 (MSB)
 //   r8  = base+1*Count,        [r8  + index]   plane 1
 //   r10 = base+2*Count,        [r10 + index]   plane 2
 //   rax = base+3*Count,        [rax + index]   plane 3 (LSB)
 add rax,rcx         // rax = aInData + 3*Count
 lea r10,[rcx+r8*2]  // r10 = aInData + 2*Count
 add r8,rcx          // r8  = aInData + 1*Count

 // Initialize loop index and accumulator
 xor r11d,r11d // index = 0
 xor esi,esi // accumulator (previous sum) = 0

@Loop:
 // Load and shift each byte-plane into its position
 movzx edi,byte ptr [rcx+r11] // load MSB byte
 shl edi,24                   // shift to bits 24–31

 movzx ebx,byte ptr [r8+r11]  // load next byte
 shl ebx,16                   // shift to bits 16–23
 or ebx,edi                   // combine MSB and next byte

 movzx edi,byte ptr [r10+r11] // third byte
 shl edi,8                    // shift to bits 8–15
 or edi,ebx                   // combine top three bytes

 movzx ebx,byte ptr [rax+r11] // LSB byte
 or ebx,edi                   // full 32‑bit delta

 // Accumulate delta to reconstruct original value
 add esi,ebx                  // running sum = prev + delta

 // Restore IEEE‑754 float bits from signed‑magnitude
 mov edi,esi
 shr edi,31                   // sign bit → all bits (-1 if negative)
 dec edi                      // edi = (sign_mask - 1)
 or edi,$80000000             // set MSB for magnitude
 xor edi,esi                  // xor with sum to reapply sign

 // Store the 32‑bit float result
 mov dword ptr [rdx+r11*4],edi

 // Increment index and loop
 inc r11
 mov rdi,r9
 add rdi,r11
 jne @Loop

 // Epilogue: restore registers & exit
 pop rbx
 pop rdi
 pop rsi

@Exit:
end;
{$endif}

// This function transforms 32-bit float data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransform32BitFloatData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
{$ifdef cpuamd64}
begin
 BackwardTransform32BitFloatDataAMD64(aInData,aOutData,aDataSize);
end;
{$else}
var Index,Count:TpvSizeInt;
    Value:TpvUInt32;
begin
 Count:=aDataSize shr 2;
 Value:=0;
 for Index:=0 to Count-1 do begin
  inc(Value,(TpvUInt32(PpvUInt8Array(aInData)^[Index]) shl 24) or
            (TpvUInt32(PpvUInt8Array(aInData)^[Index+Count]) shl 16) or
            (TpvUInt32(PpvUInt8Array(aInData)^[Index+(Count*2)]) shl 8) or
            (TpvUInt32(PpvUInt8Array(aInData)^[Index+(Count*3)]) shl 0));
  PpvUInt32Array(aOutData)^[Index]:=Value xor TpvUInt32(TpvUInt32(TpvUInt32(Value shr 31)-1) or TpvUInt32($80000000));
 end;
end;
{$endif}

procedure BackwardTransform32BitFloatData(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     BackwardTransform32BitFloatData(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      BackwardTransform32BitFloatData(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////

{$ifdef cpuamd64}
procedure ForwardTransformRGBA8DataAMD64(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
const Data:array[0..15] of TpvUInt8=(0,4,8,12,0,0,0,0,0,0,0,0,0,0,0,0);
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Entry & quick-exit for too-small data (<4 bytes)
 cmp r8,4
 jb @EarlyExit

 // Prologue: save callee‑saved registers & reserve stack for xmm registers
 push r15
 push r14
 push r13
 push r12
 push rsi
 push rdi
 push rbp
 push rbx
 sub rsp,88
 movdqa oword ptr [rsp+64],xmm9
 movdqa oword ptr [rsp+48],xmm8
 movdqa oword ptr [rsp+32],xmm7
 movdqa oword ptr [rsp+16],xmm6

 // Compute element count & plane offsets
 mov rax,r8
 shr rax,2            // rax = Count (number of pixels)
 lea r13,[rax+rax]    // r13 = 2*Count
 lea r10,[rax+rax*2]  // r10 = 3*Count

 // Choose scalar fallback for small blocks (<48 bytes)
 cmp r8,48
 jae @SIMDSetup

 // Scalar fallback initialization
 xor r8d,r8d  // byte-index = 0

@ScalarInit:
 xor r9d,r9d        // deltaR_prev = 0
 xor edi,edi        // deltaG_prev = 0
 xor ebx,ebx        // deltaB_prev = 0
 xor r11d,r11d      // deltaA_prev = 0

 // Scalar element loop: process each pixel
@ScalarLoop:
 lea rsi,[rdx+r11]           // out_base = outPtr + index
 add r10,rsi                 // update plane3 pointer
 mov qword ptr [rsp+8],rsi   // save plane0 pointer
 add r13,rsi                 // update plane2 pointer
 lea r15,[r11+rax]           // temp = index + Count
 sub rax,r11                 // remaining = Count - index
 add r15,rdx                 // out_plane1 = outPtr + temp
 lea rcx,[rcx+r11*4]         // inPtr + index*4
 xor edx,edx                 // channel-loop idx = 0

 // Scalar channel processing: R, G, B, A deltas
@ScalarProcessChannels:
 mov r11d,dword ptr [rcx+rdx*4]   // load pixel value
 mov ebp,r11d                     // ebp = raw RGBA

 // extract channels
 mov r12d,r11d                    // r12d = raw pixel (for B)
 mov r14,rax                      // save remaining count
 mov rax,r10                      // swap registers for plane pointers
 mov r10,r13
 mov r13d,r11d                    // r13d = raw pixel (for R)
 mov esi,r11d                     // esi = raw pixel (for G)

 shr esi,8                        // R = raw shr 0
 shr ebp,16                       // G = raw shr 8
 shr r12d,24                      // B = raw shr 16

 sub r13d,r8d                     // deltaR = R - prevR
 mov r8d,esi
 sub r8d,r9d

 mov r9d,ebp                      // deltaG = G - prevG
 sub r9d,edi

 mov edi,r12d                     // deltaB = B - prevB
 sub edi,ebx

 mov rbx,qword ptr [rsp+8]        // write plane0 (R)
 mov byte ptr [rbx+rdx],r13b

 mov r13,r10                      // write plane1 (G)
 mov r10,rax
 mov rax,r14
 mov byte ptr [r15+rdx],r8b

 mov byte ptr [r13+rdx],r9b      // write plane2 (B)

 mov byte ptr [r10+rdx],dil      // write plane3 (A)

 // update prev channels
 mov r8d,r11d
 inc rdx
 mov r9d,esi
 mov edi,ebp
 mov ebx,r12d
 cmp r14,rdx
 jne @ScalarProcessChannels

  // Scalar epilogue: restore xmm & regs
@ScalarEpilogue:
 movaps xmm6,oword ptr [rsp+16]
 movaps xmm7,oword ptr [rsp+32]
 movaps xmm8,oword ptr [rsp+48]
 movaps xmm9,oword ptr [rsp+64]
 add rsp,88
 pop rbx
 pop rbp
 pop rdi
 pop rsi
 pop r12
 pop r13
 pop r14
 pop r15

@EarlyExit:
 jmp @Exit

 // SIMD path for larger blocks
@SIMDSetup:
 // Compute pointers & align count to multiple of 4 pixels
 lea rsi,[rdx+r10]  // simd_plane3 = outPtr + 3*Count
 and r8,-4          // round Count down to multiple of 4
 lea r11,[rdx+r8]   // simd_plane0_end
 add r8,rcx         // simd_in_end = inPtr + aligned*4
 lea rdi,[rdx+r13]  // simd_plane2 = outPtr + 2*Count
 lea r14,[rdx+rax]  // simd_plane1 = outPtr + Count

 // Overlap test: if any output region overlaps input, fallback
 cmp rsi,r8   // plane3_base < in_end?
 setb r15b
 cmp rcx,r11  // plane0_start < plane0_end?
 setb r12b
 cmp rdi,r8   // plane2_base < in_end?
 setb r11b
 cmp rcx,rsi  // in_start < plane3_base?
 setb sil
 cmp r14,r8   // plane1_base < in_end
 setb bl
 cmp rcx,rdi  // in_start < plane2_base?
 setb dil
 cmp rdx,r8   // index < in_end?
 setb bpl
 cmp rcx,r14  // in_start < plane1_base?
 setb r14b
 xor r8d,r8d  // clear flags for next test

 test r15b,r12b  // if plane3_base < in_end && in_start < plane0_end then
 jne @ScalarInit // => scalar

 and r11b,sil    // if (in_start < plane2_base)
 jne @ScalarInit // then => scalar

 and bl,dil      // if in_start < plane2_base
 jne @ScalarInit // then => scalar

 mov r9d,0     // prevR = prevG = prevB = prevA = 0
 mov edi,0
 mov ebx,0
 mov r11d,0

 and bpl,r14b        // if index < in_end && in_start < plane1_base
 jne @ScalarLoop     // then => scalar

 // SIMD setup: load shuffle mask & zero acc registers
 mov r11,rax                    // loop count (pixels)
 and r11,-4                     // ensure multiple of 4
 pxor xmm0,xmm0                 // prev vector = 0
 movd xmm1,dword ptr [rip+Data] // shuffle mask [0,4,8,12]
 mov r8,rcx                     // src_ptr = inPtr
 mov rsi,rdx                    // dst_plane0 = outPtr
 mov rdi,r11                    // simd loop counter

 pxor xmm2,xmm2                 // tmp0 = zero
 pxor xmm3,xmm3                 // tmp1 = zero
 pxor xmm4,xmm4                 // tmp2 = zero

 // SIMD main loop
@SIMDMainLoop:

 // Rotate pipeline of previous vectors
 movdqa xmm5,xmm4               // prev_plane0 <= prev_plane1
 movdqa xmm4,xmm3               // prev_plane1 <= prev_plane2
 movdqa xmm3,xmm2               // prev_plane2 <= prev_plane3
 movdqa xmm2,xmm0               // prev_plane3 <= prev_vec

 movdqu xmm0,oword ptr [r8]     // load 4 RGBA pixels into xmm0

 movdqa xmm6,xmm0               // curr_vec = raw pixels
 palignr xmm6,xmm2,12           // prevA = align(prev_plane3_vec, curr_vec), xmm6 = { prevA3, currA0, currA1, currA2 }

 movdqa xmm2,xmm0               // tmp = raw pixels
 psrld xmm2,8                   // shift bytes >>8 for B
 movdqa xmm7,xmm2
 palignr xmm7,xmm3,12           // prevB, xmm7 = { prevB3, currB0, currB1, currB2 }

 movdqa xmm3,xmm0               // tmp = raw pixels
 psrld xmm3,16                  // shift bytes >>16 for G
 movdqa xmm8,xmm3
 palignr xmm8,xmm4,12           // prevG, xmm8 = { prevG3, currG0, currG1, currG2 }

 movdqa xmm4,xmm0               // tmp = raw pixels
 psrld xmm4,24                  // shift bytes >>24 for R
 movdqa xmm9,xmm4
 palignr xmm9,xmm5,12           // prevR, xmm9 = { prevR3, currR0, currR1, currR2 }

 // delta = curr - prev for each channel
 movdqa xmm5,xmm0                // reload raw into pipeline for packing for A
 psubd xmm5,xmm6                 // deltaA = currA - prevA
 pshufb xmm5,xmm1                // pack bytes for A

 movdqa xmm6,xmm2                // reload byte2 into pipeline for packing for B
 psubd xmm6,xmm7                 // deltaB = currB - prevB
 pshufb xmm6,xmm1                // pack bytes for B

 movdqa xmm7,xmm3                // reload byte3 into pipeline for packing for G
 psubd xmm7,xmm8                 // deltaG = currG - prevG
 pshufb xmm7,xmm1                // pack bytes for G

 movdqa xmm8,xmm4                // reload byte4 into pipeline for packing for R
 psubd xmm8,xmm9                 // deltaR = currR - prevR
 pshufb xmm8,xmm1                // pack bytes for A

 // store results per plane
 movd dword ptr [rsi],xmm5       // plane3 (A)
 movd dword ptr [rsi+rax],xmm6   // plane2 (G)
 movd dword ptr [rsi+rax*2],xmm7 // plane1 (B)
 movd dword ptr [rsi+r10],xmm8   // plane0 (R)

 // advance pointers & loop
 add rsi,4                       // advance plane3 ptr by 4 bytes
 add r8,16                       // advance src_ptr by 4 pixels
 add rdi,-4                      // decrement simd_loop counter
 jne @SIMDMainLoop               // loop

 // handle tail <4 pixels via scalar
 cmp rax,r11                     // processed all aligned pixels?
 je @ScalarEpilogue              // if yes, jump to SIMD epilogue

 // handle tail (<4 pixels) by extracting last bytes
 pextrd r8d,xmm0,3               // last raw pixel byte3
 pextrd r9d,xmm2,3               // last raw byte2
 pextrd edi,xmm3,3               // last raw byte1
 pextrd ebx,xmm4,3               // last raw byte0
 jmp @ScalarLoop                 // fall back to scalar for tail

@Exit:
end;
{$endif}

// This function transforms RGBA8 data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransformRGBA8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
{$ifdef cpuamd64}
begin
 ForwardTransformRGBA8DataAMD64(aInData,aOutData,aDataSize);
end;
{$else}
var Index,Count:TpvSizeInt;
    Value:TpvUInt32;
    PreviousR,ValueR,DeltaR,
    PreviousG,ValueG,DeltaG,
    PreviousB,ValueB,DeltaB,
    PreviousA,ValueA,DeltaA:TpvUInt8;
begin
 Count:=aDataSize shr 2;
 PreviousR:=0;
 PreviousG:=0;
 PreviousB:=0;
 PreviousA:=0;
 for Index:=0 to Count-1 do begin
  Value:=PpvUInt32Array(aInData)^[Index];
  ValueR:=(Value shr 0) and $ff;
  ValueG:=(Value shr 8) and $ff;
  ValueB:=(Value shr 16) and $ff;
  ValueA:=(Value shr 24) and $ff;
  DeltaR:=ValueR-PreviousR;
  DeltaG:=ValueG-PreviousG;
  DeltaB:=ValueB-PreviousB;
  DeltaA:=ValueA-PreviousA;
  PreviousR:=ValueR;
  PreviousG:=ValueG;
  PreviousB:=ValueB;
  PreviousA:=ValueA;
  PpvUInt8Array(aOutData)^[Index]:=DeltaR;
  PpvUInt8Array(aOutData)^[Index+Count]:=DeltaG;
  PpvUInt8Array(aOutData)^[Index+(Count*2)]:=DeltaB;
  PpvUInt8Array(aOutData)^[Index+(Count*3)]:=DeltaA;
 end;
end;
{$endif}

procedure ForwardTransformRGBA8Data(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     ForwardTransformRGBA8Data(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      ForwardTransformRGBA8Data(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

{$ifdef cpuamd64}
procedure BackwardTransformRGBA8DataAMD64(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt); assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}

 // Entry & quick‑exit for too‑small data (<4 bytes)
 cmp r8,4
 jb @Exit

 // Prologue: save callee‑saved registers
 push r15
 push r14
 push rsi
 push rdi
 push rbp
 push rbx

 // Compute element count & plane bases
 shr r8,2             // r8 = Count (pixels)
 lea rax,[r8+r8*2]    // rax = 3*Count
 mov r9,r8            // r9 =  Count
 neg r9               // r9 = -Count (for indexing)
 add rax,rcx          // plane3 = aInData + 3*Count
 lea r10,[rcx+r8*2]   // plane2 = aInData + 2*Count
 add r8,rcx           // plane1 = aInData + 1*Count
                      // plane0 = rcx

 // Initialize loop index & accumulators for each channel
 xor r11d,r11d        // idx = 0
 xor esi,esi          // sumR = 0
 xor edi,edi          // sumG = 0
 xor ebx,ebx          // sumB = 0
 xor ebp,ebp          // sumA = 0

@Loop:

 // Load & accumulate delta for R channel
 movzx r14d,byte ptr [rcx+r11]   // deltaR
 add ebp,r14d                    // sumR += deltaR

 // Load & accumulate delta for G channel
 movzx r14d,byte ptr [r8+r11]    // deltaG
 movzx ebx,bl                    // ebx := previous sumG & 0xFF
 add ebx,r14d                    // sumG = (sumG + deltaG) & 0xFF

 // Load & accumulate delta for B channel
 movzx r14d,byte ptr [r10+r11]  // deltaB
 movzx edi,dil                  // edi := previous sumB & 0xFF
 add edi,r14d                   // sumB = (sumB + deltaB) & 0xFF

 // Load & accumulate delta for A channel
 movzx r14d,byte ptr [rax+r11]  // deltaA
 add esi,r14d                   // sumA += deltaA

 // Pack RGBA into a 32‑bit value:
 //   low 8 bits = sumR & 0xFF
 //   next byte  = sumG & 0xFF
 //   next byte  = sumB & 0xFF
 //   top byte   = sumA & 0xFF
 movzx r14d,bpl                 // r14 = sumR & 0xFF
 mov r15d,ebx                   // r15 = sumG
 shl r15d,8
 movzx r15d,r15w                // combine G<<8 | R
 or r15d,r14d
 movzx r14d,dil                 // r14 = sumB & 0xFF
 shl r14d,16
 or r14d,r15d                   // combine B<<(16) | previous
 mov r15d,esi                   // r15 = sumA
 shl r15d,24
 or r15d,r14d                   // final = A<<24 | B<<16 | G<<8 | R

 mov dword ptr [rdx+r11*4],r15d // Store reconstructed pixel

 // Next index & loop
 inc r11
 mov r14,r9
 add r14,r11 // check r11 != Count
 jne @Loop

 // Epilogue: restore registers & exit
 pop rbx
 pop rbp
 pop rdi
 pop rsi
 pop r14
 pop r15

@Exit:
end;
{$endif}

// This function transforms RGBA8 data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransformRGBA8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
{$ifdef cpuamd64}
begin
 BackwardTransformRGBA8DataAMD64(aInData,aOutData,aDataSize);
end;
{$else}
var Index,Count:TpvSizeInt;
    ValueR,ValueG,ValueB,ValueA:TpvUInt8;
begin
 Count:=aDataSize shr 2;
 ValueR:=0;
 ValueG:=0;
 ValueB:=0;
 ValueA:=0;
 for Index:=0 to Count-1 do begin
  inc(ValueR,TpvUInt8(PpvUInt8Array(aInData)^[Index]));
  inc(ValueG,TpvUInt8(PpvUInt8Array(aInData)^[Index+Count]));
  inc(ValueB,TpvUInt8(PpvUInt8Array(aInData)^[Index+(Count*2)]));
  inc(ValueA,TpvUInt8(PpvUInt8Array(aInData)^[Index+(Count*3)]));
  PpvUInt32Array(aOutData)^[Index]:=((TpvUInt32(ValueR) and $ff) shl 0) or
                                    ((TpvUInt32(ValueG) and $ff) shl 8) or
                                    ((TpvUInt32(ValueB) and $ff) shl 16) or
                                    ((TpvUInt32(ValueA) and $ff) shl 24);
 end;
end;
{$endif}

procedure BackwardTransformRGBA8Data(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     BackwardTransformRGBA8Data(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      BackwardTransformRGBA8Data(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////

// This function transforms R8 data to a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure ForwardTransformR8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
var Index,Count:TpvSizeInt;
    Previous,Value:TpvUInt8;
begin
 Count:=aDataSize;
 Previous:=0;
 for Index:=0 to Count-1 do begin
  Value:=PpvUInt8Array(aInData)^[Index];
  PpvUInt8Array(aOutData)^[Index]:=Value-Previous;
  Previous:=Value;
 end;
end;

procedure ForwardTransformR8Data(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     ForwardTransformR8Data(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      ForwardTransformR8Data(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

// This function transforms R8 data back from a better compressible format, together with preserving the order
// before and after the transformation for better delta compression
procedure BackwardTransformR8Data(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
var Index,Count:TpvSizeInt;
    Value:TpvUInt8;
begin
 Count:=aDataSize;
 Value:=0;
 for Index:=0 to Count-1 do begin
  inc(Value,TpvUInt8(PpvUInt8Array(aInData)^[Index]));
  PpvUInt8Array(aOutData)^[Index]:=Value;
 end;
end;

procedure BackwardTransformR8Data(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     BackwardTransformR8Data(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      BackwardTransformR8Data(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;
  end;
 end;
end;

// This function transforms RGBA32 data to the reordered order (RGBARGBARGBARGBA => RRRRGGGGBBBBAAAA )
procedure ForwardTransformRGBA32OrderData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
var Index,Count:TpvSizeInt;
begin
 Count:=aDataSize shr 4; // 4 bytes per pixel, 4 channels so 4*4 = 2+2 shift
 for Index:=0 to Count-1 do begin
  PpvUInt32Array(aOutData)^[Index+(Count*0)]:=PpvUInt32Array(aInData)^[(Index shl 2) or 0];
  PpvUInt32Array(aOutData)^[Index+(Count*1)]:=PpvUInt32Array(aInData)^[(Index shl 2) or 1];
  PpvUInt32Array(aOutData)^[Index+(Count*2)]:=PpvUInt32Array(aInData)^[(Index shl 2) or 2];
  PpvUInt32Array(aOutData)^[Index+(Count*3)]:=PpvUInt32Array(aInData)^[(Index shl 2) or 3];
 end;
end;

procedure ForwardTransformRGBA32OrderData(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     ForwardTransformRGBA32OrderData(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      ForwardTransformRGBA32OrderData(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;  
   end;
  end;
 end;
end;

// This function transforms RGBA32 data back from the reordered order (RRRRGGGGBBBBAAAA => RGBARGBARGBARGBA)
procedure BackwardTransformRGBA32OrderData(const aInData,aOutData:pointer;const aDataSize:TpvSizeInt);
var Index,Count:TpvSizeInt;
begin
 Count:=aDataSize shr 4; // 4 bytes per pixel, 4 channels so 4*4 = 2+2 shift
 for Index:=0 to Count-1 do begin
  PpvUInt32Array(aOutData)^[(Index shl 2) or 0]:=PpvUInt32Array(aInData)^[Index+(Count*0)];
  PpvUInt32Array(aOutData)^[(Index shl 2) or 1]:=PpvUInt32Array(aInData)^[Index+(Count*1)];
  PpvUInt32Array(aOutData)^[(Index shl 2) or 2]:=PpvUInt32Array(aInData)^[Index+(Count*2)];
  PpvUInt32Array(aOutData)^[(Index shl 2) or 3]:=PpvUInt32Array(aInData)^[Index+(Count*3)];
 end;
end;

procedure BackwardTransformRGBA32OrderData(const aStream:TStream);
var InData,OutData:Pointer;
    Size:TpvSizeInt;
begin
 if assigned(aStream) then begin
  Size:=aStream.Size;
  if Size>0 then begin
   if aStream is TMemoryStream then begin
    GetMem(OutData,Size);
    try
     BackwardTransformRGBA32OrderData(TMemoryStream(aStream).Memory,OutData,Size);
     Move(OutData^,TMemoryStream(aStream).Memory^,Size);  
    finally
     try
      FreeMem(OutData);
     finally
      OutData:=nil;
     end;
    end;
   end else begin
    GetMem(InData,Size);
    try
     aStream.Seek(0,soBeginning);   
     aStream.ReadBuffer(InData^,Size);
     GetMem(OutData,Size);
     try
      BackwardTransformRGBA32OrderData(InData,OutData,Size);
      aStream.Seek(0,soBeginning);
      aStream.WriteBuffer(OutData^,Size);
     finally
      try
       FreeMem(OutData);
      finally
       OutData:=nil;   
      end;
     end;
    finally
     try
      FreeMem(InData);
     finally
      InData:=nil;
     end;
    end;
   end;  
  end;
 end;
end;

////////////////////////////////////////////////////////////////////////////////////////

type TCompressedFileSignature=array[0..3] of AnsiChar;

     TCompressedFileHeader=packed record
      Signature:TCompressedFileSignature;
      Version:TpvUInt32;
      Flags:TpvUInt8; // Yet unused, but reserved for future use, better to have it now than to break the file format later 
      Parts:TpvUInt8; // max 255 parts, should be enough
      CompressionMethod:TpvUInt8;
      CompressionLevel:TpvUInt8;
      UncompressedSize:TpvUInt64;
      CompressedSize:TpvUInt64;
     end;
     PCompressedFileHeader=^TCompressedFileHeader;

     TCompressionPartHeader=packed record
      CompressedOffset:TpvUInt64;
      CompressedSize:TpvUInt64;
      UncompressedOffset:TpvUInt64;
      UncompressedSize:TpvUInt64;
     end;
     PCompressionPartHeader=^TCompressionPartHeader;

     TCompressionPartHeaders=array of TCompressionPartHeader;

const CompressedFileSignature:TCompressedFileSignature=('C','O','F','I');

      CompressedFileVersion=2;

type TCompressionPartJob=record
      FileHeader:PCompressedFileHeader;
      CompressionPartHeader:PCompressionPartHeader;
      InData:Pointer;
      InSize:TpvUInt64;
      OutData:Pointer;
      OutSize:TpvUInt64;
      Success:boolean;
     end;
     PCompressionPartJob=^TCompressionPartJob;

     TCompressionPartJobs=array of TCompressionPartJob;

     TDecompressionPartJob=record
      FileHeader:PCompressedFileHeader;
      CompressionPartHeader:PCompressionPartHeader;
      InData:Pointer;
      InSize:TpvUInt64;
      OutData:Pointer;
      OutSize:TpvUInt64;
      Success:boolean;
     end;
     PDecompressionPartJob=^TDecompressionPartJob;

     TDecompressionPartJobs=array of TDecompressionPartJob;

procedure CompressPart(const aJob:PCompressionPartJob);
{var Stream:TFileStream;
    FileName:TpvUTF8String;
    TemporaryOutData:Pointer;
    TemporaryOutDataSize:TpvUInt64;//}
var OutSize:TpvSizeUInt;
begin

 aJob^.OutData:=nil;
 aJob^.OutSize:=0;

 case aJob.FileHeader^.CompressionMethod of
  TpvUInt8(TpvCompressionMethod.None):begin
   if aJob.InSize>0 then begin
    GetMem(aJob.OutData,aJob.InSize);
    aJob.OutSize:=aJob.InSize;
    Move(aJob.InData^,aJob.OutData^,aJob.InSize);
    aJob.Success:=true;
   end else begin
    aJob.Success:=false;
   end;
  end;
  TpvUInt8(TpvCompressionMethod.Deflate):begin
   OutSize:=aJob.OutSize;
   aJob.Success:=DoDeflate(aJob.InData,aJob.InSize,aJob.OutData,OutSize,TpvDeflateMode(aJob.FileHeader^.CompressionLevel),false);
   aJob.OutSize:=OutSize;
  end;
  TpvUInt8(TpvCompressionMethod.LZBRSF):begin
   aJob.Success:=LZBRSFCompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,TpvLZBRSFLevel(aJob.FileHeader^.CompressionLevel),false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRRC):begin
   aJob.Success:=LZBRRCCompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,TpvLZBRRCLevel(aJob.FileHeader^.CompressionLevel),false);
{  // Safe check by decompressing the compressed data again and compare it with the original data
   if aJob.Success then begin
    GetMem(TemporaryOutData,aJob.CompressionPartHeader^.UncompressedSize);
    try
     TemporaryOutDataSize:=0;
     aJob.Success:=LZBRRCDecompress(aJob.OutData,aJob.OutSize,TemporaryOutData,TemporaryOutDataSize,aJob.CompressionPartHeader^.UncompressedSize,false);
     if aJob.Success then begin
      aJob.Success:=CompareMem(TemporaryOutData,aJob.InData,Min(TemporaryOutDataSize,aJob.CompressionPartHeader^.UncompressedSize));
     end;
     if not aJob.Success then begin
      FileName:='broken_'+IntToHex(TpvPtrUInt(aJob),16)+'_'+IntToHex(random($ffffffff),8);
      Stream:=TFileStream.Create(FileName+'_input.bin',fmCreate);
      try
       Stream.WriteBuffer(aJob.InData^,aJob.InSize);
      finally
       FreeAndNil(Stream);
      end;
      Stream:=TFileStream.Create(FileName+'_output.bin',fmCreate);
      try
       Stream.WriteBuffer(aJob.OutData^,aJob.OutSize);
      finally
       FreeAndNil(Stream);
      end;
      Stream:=TFileStream.Create(FileName+'_decompressed.bin',fmCreate);
      try
       Stream.WriteBuffer(TemporaryOutData^,TemporaryOutDataSize);
      finally
       FreeAndNil(Stream);
      end;
     end;
    finally
     FreeMem(TemporaryOutData);
     TemporaryOutData:=nil;
    end;
   end;//}
  end;
  TpvUInt8(TpvCompressionMethod.LZMA):begin
   aJob.Success:=LZMACompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,TpvLZMALevel(aJob.FileHeader^.CompressionLevel),false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRS):begin
   aJob.Success:=LZBRSCompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,TpvLZBRSLevel(aJob.FileHeader^.CompressionLevel),false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRSX):begin
   aJob.Success:=LZBRSXCompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,TpvLZBRSXLevel(aJob.FileHeader^.CompressionLevel),false);
  end;
  else begin
   aJob.Success:=false;
  end;
 end;

 aJob^.CompressionPartHeader^.CompressedSize:=aJob^.OutSize;

end;     

procedure CompressPartJob(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Index:TpvSizeInt;
    JobData:PCompressionPartJob;
begin
 for Index:=FromIndex to ToIndex do begin
  JobData:=Data;
  inc(JobData,Index);
  CompressPart(JobData);
 end;
end;

function CompressStream(const aInStream:TStream;const aOutStream:TStream;const aCompressionMethod:TpvCompressionMethod;const aCompressionLevel:TpvUInt32;const aParts:TpvUInt32):boolean;
var InData:Pointer;
    InSize,Offset,Size,RemainSize,PartSize:TpvUInt64;
    FileHeader:TCompressedFileHeader;
    CompressionPartHeaders:TCompressionPartHeaders;
    CompressionPartHeader:PCompressionPartHeader;
    CompressionPartJobs:TCompressionPartJobs;
    CompressionPartJob:PCompressionPartJob;
    PartIndex:TpvSizeInt;    
begin

 if assigned(aInStream) and (aInStream.Size>0) and assigned(aOutStream) then begin

  GetMem(InData,aInStream.Size);
  try

   aInStream.Seek(0,soBeginning);
   aInStream.ReadBuffer(InData^,aInStream.Size);

   InSize:=aInStream.Size;

   FileHeader.Signature:=CompressedFileSignature;
   FileHeader.Version:=CompressedFileVersion;
   FileHeader.Flags:=0; // Zero for now, because it is reserved for future use
   if (InSize<65536) or (aCompressionMethod=TpvCompressionMethod.None) then begin
    FileHeader.Parts:=1;
   end else begin
    if aParts=0 then begin
     FileHeader.Parts:=Min(Max(IntLog264(InSize)-21,1),255); // minimum 1, maximum 255 parts
    end else begin
     FileHeader.Parts:=Min(Max(aParts,1),255); // minimum 1, maximum 255 parts
    end;
   end;
   FileHeader.CompressionMethod:=TpvUInt8(aCompressionMethod);
   FileHeader.CompressionLevel:=aCompressionLevel;
   FileHeader.UncompressedSize:=InSize;

   CompressionPartHeaders:=nil;
   try

    SetLength(CompressionPartHeaders,FileHeader.Parts);

    Offset:=0;
    RemainSize:=InSize;
    PartSize:=TpvUInt64(Max(TpvUInt64(1),TpvUInt64((InSize+(FileHeader.Parts-1)) div FileHeader.Parts)));
    for PartIndex:=0 to FileHeader.Parts-1 do begin
     if (PartIndex=(FileHeader.Parts-1)) or (RemainSize<PartSize) then begin
      Size:=RemainSize;
     end else begin
      Size:=PartSize;
     end;
     CompressionPartHeader:=@CompressionPartHeaders[PartIndex];
     CompressionPartHeader^.CompressedOffset:=0;
     CompressionPartHeader^.CompressedSize:=0;
     CompressionPartHeader^.UncompressedOffset:=Offset;
     CompressionPartHeader^.UncompressedSize:=Size;
     inc(Offset,Size);
     dec(RemainSize,Size);
    end;

    CompressionPartJobs:=nil;
    try
     
     SetLength(CompressionPartJobs,FileHeader.Parts);
     for PartIndex:=0 to FileHeader.Parts-1 do begin
      CompressionPartJob:=@CompressionPartJobs[PartIndex];
      CompressionPartJob^.FileHeader:=@FileHeader;
      CompressionPartJob^.CompressionPartHeader:=@CompressionPartHeaders[PartIndex];
      CompressionPartJob^.InData:=Pointer(TpvPtrUInt(TpvPtrUInt(InData)+TpvPtrUInt(CompressionPartHeaders[PartIndex].UncompressedOffset)));
      CompressionPartJob^.InSize:=CompressionPartHeaders[PartIndex].UncompressedSize;
      CompressionPartJob^.OutData:=nil;
      CompressionPartJob^.OutSize:=0;
      CompressionPartJob^.Success:=false;
     end;

     if FileHeader.Parts>1 then begin
      if assigned(pvCompressionPasMPInstance) then begin
       // Use multiple threads for multiple parts
       pvCompressionPasMPInstance.Invoke(pvCompressionPasMPInstance.ParallelFor(@CompressionPartJobs[0],0,length(CompressionPartJobs)-1,CompressPartJob,1,PasMPDefaultDepth,nil,0,0));
      end else begin
       for PartIndex:=0 to FileHeader.Parts-1 do begin
        CompressPart(@CompressionPartJobs[PartIndex]);
       end;
      end;
     end else begin
      // No need to use multiple threads for only one part
      CompressPart(@CompressionPartJobs[0]);
     end;

     result:=true;
     Offset:=SizeOf(TCompressedFileHeader)+(FileHeader.Parts*SizeOf(TCompressionPartHeader));
     Size:=0;
     for PartIndex:=0 to FileHeader.Parts-1 do begin
      CompressionPartJob:=@CompressionPartJobs[PartIndex];
      if CompressionPartJob^.Success and assigned(CompressionPartJob^.OutData) and (CompressionPartJob^.OutSize>0) then begin
       CompressionPartHeader:=@CompressionPartHeaders[PartIndex];
       CompressionPartHeader^.CompressedOffset:=Offset;
       CompressionPartHeader^.CompressedSize:=CompressionPartJob^.OutSize;
       inc(Offset,CompressionPartHeader^.CompressedSize);
       inc(Size,CompressionPartHeader^.CompressedSize);
      end else begin
       result:=false;
       break;
      end;
     end;

     FileHeader.CompressedSize:=Size;

     if result then begin
      
      aOutStream.WriteBuffer(FileHeader,SizeOf(TCompressedFileHeader));

      for PartIndex:=0 to FileHeader.Parts-1 do begin
       CompressionPartHeader:=@CompressionPartHeaders[PartIndex];
       aOutStream.WriteBuffer(CompressionPartHeader^,SizeOf(TCompressionPartHeader));
      end;

      for PartIndex:=0 to FileHeader.Parts-1 do begin
       CompressionPartJob:=@CompressionPartJobs[PartIndex];
       if assigned(CompressionPartJob^.OutData) and (CompressionPartJob^.OutSize>0) then begin
        aOutStream.WriteBuffer(CompressionPartJob^.OutData^,CompressionPartJob^.OutSize);
       end;
      end;
      
     end;

     for PartIndex:=0 to FileHeader.Parts-1 do begin
      CompressionPartJob:=@CompressionPartJobs[PartIndex];
      if assigned(CompressionPartJob^.OutData) then begin
       FreeMem(CompressionPartJob^.OutData);
       CompressionPartJob^.OutData:=nil;
      end;
     end;

    finally
     CompressionPartJobs:=nil;
    end;

   finally
    CompressionPartHeaders:=nil;
   end; 

  finally
   FreeMem(InData);
   InData:=nil;
  end;

 end else begin

  result:=false;

 end;

end;

procedure DecompressPart(const aJob:PDecompressionPartJob);
var TemporaryDeflateOutData:Pointer; // Deflate isn't in-place, so we need a temporary buffer
    TemporaryDeflateOutSize:TpvSizeUInt;
begin 

 case aJob.FileHeader^.CompressionMethod of
  TpvUInt8(TpvCompressionMethod.None):begin
   // No compression, just copy the data
   if aJob.InSize>0 then begin
    GetMem(aJob.OutData,aJob.InSize);
    aJob.OutSize:=aJob.InSize;
    Move(aJob.InData^,aJob.OutData^,aJob.InSize);
    aJob.Success:=true;
   end else begin
    aJob.Success:=false;
   end;
  end;
  TpvUInt8(TpvCompressionMethod.Deflate):begin
   // The old good Deflate, it is slow and it doesn't compress very well in addition to that, in comparison to LZBRRC and LZMA
   TemporaryDeflateOutData:=nil;
   TemporaryDeflateOutSize:=0;
   try
    aJob.Success:=DoInflate(aJob.InData,aJob.InSize,TemporaryDeflateOutData,TemporaryDeflateOutSize,false);
    if aJob.Success then begin
     if TemporaryDeflateOutSize=aJob.CompressionPartHeader^.UncompressedSize then begin
      GetMem(aJob.OutData,TemporaryDeflateOutSize);
      aJob.OutSize:=TemporaryDeflateOutSize;
      Move(TemporaryDeflateOutData^,aJob.OutData^,TemporaryDeflateOutSize);
     end else begin
      aJob.Success:=false;
     end;
    end;
   finally
    if assigned(TemporaryDeflateOutData) then begin
     FreeMem(TemporaryDeflateOutData);
     TemporaryDeflateOutData:=nil;
    end;
   end;
  end;
  TpvUInt8(TpvCompressionMethod.LZBRSF):begin
   // LZBRSF is a pure byte-wise compression algorithm, so it is pretty fast, but it doesn't compress very well, but it is still better than 
   // nothing, and it is also very fast at decompression, so it is a pretty good choice for games, where the compression ratio isn't that important, 
   // only the decompression speed.
   aJob.Success:=LZBRSFDecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRRC):begin
   // LZBRRC is a LZ77-based compression algorithm but with range coding for the entropy coding, so it is pretty fast and it does also 
   // compress very well, but LZMA is still better at the compression ratio. LZBRRC is also very fast at decompression, so it is a good
   // choice for games, because it is fast at both compression and decompression, and it compresses very well, so it saves a lot of space.
{$if declared(LZBRRCFastDecompress)}
   // Assembler version is faster, but not yet available for all targets, and it has fewer to no sanity checks
   aJob.Success:=LZBRRCFastDecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
{$else}
   // The pure pas version is slower, but available for all targets, and it has full sanity checks
   aJob.Success:=LZBRRCDecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
{$ifend}
  end;
  TpvUInt8(TpvCompressionMethod.LZMA):begin
   // The old good LZMA, but it is slow, but it compresses very well. It should be used for data, where the compression ratio is more important 
   // than the decompression speed.  
   aJob.Success:=LZMADecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRS):begin
   // LZBRS is a simple LZ77/LZSS-style algorithm like BriefLZ, but with 32-bit tags instead 16-bit tags,
   // and with end tag (match with offset 0)
   // Not to be confused with the old equal-named LRBRS from BeRoEXEPacker, which was 8-bit byte-wise tag-based.
   aJob.Success:=LZBRSDecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
  end;
  TpvUInt8(TpvCompressionMethod.LZBRSX):begin
   // LZBRSX is a simple LZ77/LZSS-style algorithm like apLib, but with 32-bit tags instead 8-bit tags
   aJob.Success:=LZBRSXDecompress(aJob.InData,aJob.InSize,aJob.OutData,aJob.OutSize,aJob.CompressionPartHeader^.UncompressedSize,false);
  end;
  else begin
   aJob.Success:=false;
  end;
 end;

end; 

procedure DecompressPartJob(const Job:PPasMPJob;const ThreadIndex:TPasMPInt32;const Data:pointer;const FromIndex,ToIndex:TPasMPNativeInt);
var Index:TpvSizeInt;
    JobData:PDecompressionPartJob;
begin
 for Index:=FromIndex to ToIndex do begin
  JobData:=Data;
  inc(JobData,Index);
  DecompressPart(JobData);
 end;
end;

function DecompressStream(const aInStream:TStream;const aOutStream:TStream):boolean;
var InData,OutData:Pointer;
    InSize,OutSize,Offset,Size,RemainSize,PartSize:TpvUInt64;
    PartIndex:TpvSizeInt;
    FileHeader:TCompressedFileHeader;
    CompressionPartHeaders:TCompressionPartHeaders;
    CompressionPartHeader:PCompressionPartHeader;
    DecompressionPartJobs:TDecompressionPartJobs;
    DecompressionPartJob:PDecompressionPartJob;
begin

 if assigned(aInStream) and (aInStream.Size>=SizeOf(TCompressedFileHeader)) and assigned(aOutStream) then begin

  InData:=nil;
  OutData:=nil;

  aInStream.ReadBuffer(FileHeader,SizeOf(TCompressedFileHeader));

  Size:=aInStream.Size-(SizeOf(TCompressedFileHeader)+(FileHeader.Parts*SizeOf(TCompressionPartHeader)));

  if (FileHeader.Signature=CompressedFileSignature) and
     (FileHeader.Version=CompressedFileVersion) and
     (FileHeader.CompressedSize=Size) and
     ((FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.None)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.Deflate)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.LZBRS)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.LZBRSX)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.LZBRSF)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.LZBRRC)) or
      (FileHeader.CompressionMethod=TpvUInt8(TpvCompressionMethod.LZMA))) then begin

   InSize:=FileHeader.CompressedSize;
   OutSize:=FileHeader.UncompressedSize;

   CompressionPartHeaders:=nil;
   try

    SetLength(CompressionPartHeaders,FileHeader.Parts);
    aInStream.ReadBuffer(CompressionPartHeaders[0],FileHeader.Parts*SizeOf(TCompressionPartHeader));

    if InSize>0 then begin

     GetMem(InData,InSize);
     try

      aInStream.ReadBuffer(InData^,InSize);
      
      if OutSize>0 then begin

       GetMem(OutData,OutSize);
       try

        DecompressionPartJobs:=nil;
        try

         SetLength(DecompressionPartJobs,FileHeader.Parts);

         Offset:=SizeOf(TCompressedFileHeader)+(FileHeader.Parts*SizeOf(TCompressionPartHeader));
         for PartIndex:=0 to FileHeader.Parts-1 do begin
          DecompressionPartJob:=@DecompressionPartJobs[PartIndex];
          DecompressionPartJob^.FileHeader:=@FileHeader;
          DecompressionPartJob^.CompressionPartHeader:=@CompressionPartHeaders[PartIndex];
          DecompressionPartJob^.InData:=Pointer(TpvPtrUInt(TpvPtrUInt(InData)+TpvPtrUInt(DecompressionPartJob^.CompressionPartHeader^.CompressedOffset-Offset)));
          DecompressionPartJob^.InSize:=DecompressionPartJob^.CompressionPartHeader^.CompressedSize;
          DecompressionPartJob^.OutData:=Pointer(TpvPtrUInt(TpvPtrUInt(OutData)+TpvPtrUInt(DecompressionPartJob^.CompressionPartHeader^.UncompressedOffset)));
          DecompressionPartJob^.OutSize:=DecompressionPartJob^.CompressionPartHeader^.UncompressedSize;
          DecompressionPartJob^.Success:=false;
         end;

         if FileHeader.Parts>1 then begin
          if assigned(pvCompressionPasMPInstance) then begin
           // Use multiple threads for multiple parts
           pvCompressionPasMPInstance.Invoke(pvCompressionPasMPInstance.ParallelFor(@DecompressionPartJobs[0],0,length(DecompressionPartJobs)-1,DecompressPartJob,1,PasMPDefaultDepth,nil,0,0));
          end else begin
           for PartIndex:=0 to FileHeader.Parts-1 do begin
            DecompressPart(@DecompressionPartJobs[PartIndex]);
           end;
          end;
         end else begin
          // No need to use multiple threads for only one part
          DecompressPart(@DecompressionPartJobs[0]);
         end;

         result:=true;
         for PartIndex:=0 to FileHeader.Parts-1 do begin
          DecompressionPartJob:=@DecompressionPartJobs[PartIndex];
          if DecompressionPartJob^.Success and assigned(DecompressionPartJob^.OutData) and (DecompressionPartJob^.OutSize>0) then begin
           aOutStream.WriteBuffer(DecompressionPartJob^.OutData^,DecompressionPartJob^.OutSize);
          end else begin
           result:=false;
           break;
          end;
         end;

        finally
         DecompressionPartJobs:=nil;
        end;

       finally
        FreeMem(OutData);
        OutData:=nil;
       end; 

      end;

     finally
      FreeMem(InData);
      InData:=nil;
     end; 

    end; 

   finally
    CompressionPartHeaders:=nil;
   end;   

  end else begin

   result:=false;

  end;

 end else begin

  result:=false;

 end;

end;

end.
