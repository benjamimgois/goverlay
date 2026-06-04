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
unit PasVulkan.Hash.RapidHash;
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
     PasVulkan.Types;

// This RapidHash implementation is endian-dependent, so the results are not interchangeable between
// different endian architectures. So be careful when using this hash function in a cross-platform / 
// cross-endian-architecture context. The hash function is designed to be fast and efficient on little-endian
// architectures, such as ARM, AArch64, RISC-V, x86 and x86-64. It is not optimized for older big-endian 
// architectures, such as PowerPC or SPARC. These big-endian architectures are almost dead in the modern world
// anyway, so this is not a big problem. Indeed ARM and AArch64 can be either little-endian or big-endian, but
// the vast majority of modern newer ARM and AArch64 implementations and operating systems are little-endian. 
// And RISC-V is also practically always little-endian. So this implementation is optimized for little-endian 
// architectures.

// Equivalent to the C implementation of RapidHash with the following defines:
// #define RAPIDHASH_LITTLE_ENDIAN
// #define RAPIDHASH_UNROLLED
// #define RAPIDHASH_FAST
// and the secrets here are fixed to the following values:
// #define RAPID_SECRET0 0x2d358dccaa6c78a5ULL
// #define RAPID_SECRET1 0x8bb84b93962eacc9ULL
// #define RAPID_SECRET2 0x4b33a62ed433d4a3ULL 

type TpvHashRapidHash=class
      public
       const RapidSeed=TpvUInt64($bdd89aa982704029);
             Secret0=TpvUInt64($2d358dccaa6c78a5);
             Secret1=TpvUInt64($8bb84b93962eacc9);
             Secret2=TpvUInt64($4b33a62ed433d4a3);
       type TMessageDigest=TpvUInt64;
            PMessageDigest=^TMessageDigest;
      private
{$ifndef cpuamd64}
       class procedure MUM(var aA,aB:TpvUInt64); static; {$ifndef cpuamd64}inline;{$endif}
       class function Mix(aA,aB:TpvUInt64):TpvUInt64; static; inline;
{$ifdef BIG_ENDIAN}
       class function Read32(const aData:Pointer):TpvUInt32; static; inline;
       class function Read64(const aData:Pointer):TpvUInt64; static; inline;
       class function ReadSmall(const aData:Pointer;const aDataLength:TpvSizeUInt):TpvUInt64; static; inline;
{$endif}
{$endif}
      public
       class function Process(const aKey:pointer;const aLength:TpvSizeUInt;aSeed:TpvUInt64=RapidSeed):TMessageDigest; static;
     end;

implementation

{ TpvHashRapidHash }

{$ifndef cpuamd64}
class procedure TpvHashRapidHash.MUM(var aA,aB:TpvUInt64);{$ifdef cpuamd64} assembler; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if defined(Windows)}
 // Pointer of aA is in rcx
 // Pointer of aB is in rdx
 // Save the pointers
 mov r8,rcx
 mov r9,rdx
 // Load aA and aB
 mov rax,qword ptr [rcx]
 mov rdx,qword ptr [rdx]
 // Multiply aA and aB
 mul rdx
 // Lo is in rax, Hi is in rdx 
 // Store the result back to aA and aB
 mov qword ptr [r8],rax
 mov qword ptr [r9],rdx
{$else}
 // Pointer of aA is in rdi
 // Pointer of aB is in rsi
 // Save the pointers
 mov r8,rdi
 mov r9,rsi
 // Load aA and aB
 mov rax,qword ptr [rdi]
 mov rdx,qword ptr [rsi]
 // Multiply aA and aB
 mul rdx
 // Lo is in rax, Hi is in rdx 
 // Store the result back to aA and aB
 mov qword ptr [r8],rax
 mov qword ptr [r9],rdx
{$ifend}
end;
{$else} 
var ha,hb,la,lb,hi,lo:TpvUInt64;
    rh,rm0,rm1,rl:TpvUInt64;
    t:TpvUInt64;
    c:TpvUInt64;
begin
 ha:=aA shr 32;
 hb:=aB shr 32;
 la:=TpvUInt32(aA);
 lb:=TpvUInt32(aB);
 rh:=ha*hb;
 rm0:=ha*lb;
 rm1:=hb*la;
 rl:=la*lb;
 t:=rl+(rm0 shl 32);
 c:=ord(t<rl) and 1;
 lo:=t+(rm1 shl 32);
 inc(c,ord(lo<t) and 1);
 hi:=rh+(rm0 shr 32)+(rm1 shr 32)+c;
 aA:=lo;
 aB:=hi;
end;
{$endif}

class function TpvHashRapidHash.Mix(aA,aB:TpvUInt64):TpvUInt64;
begin
 MUM(aA,aB);
 result:=aA xor aB;
end; 

{$ifdef BIG_ENDIAN}
class function TpvHashRapidHash.Read32(const aData:Pointer):TpvUInt32;
begin
 result:=PpvUInt32(aData)^;
 result:=(result shl 24) or ((result and TpvUInt32($00ff0000)) shr 8) or ((result and TpvUInt32($0000ff00)) shl 8) or (result shr 24);
end;

class function TpvHashRapidHash.Read64(const aData:Pointer):TpvUInt64;
begin
 result:=PpvUInt64(aData)^;
 result:=(result shl 56) or 
         ((result and TpvUInt64($00ff000000000000)) shr 8) or 
         ((result and TpvUInt64($0000ff0000000000)) shl 8) or 
         ((result and TpvUInt64($000000ff00000000)) shr 24) or 
         ((result and TpvUInt64($00000000ff000000)) shl 24) or 
         ((result and TpvUInt64($0000000000ff0000)) shr 40) or 
         ((result and TpvUInt64($000000000000ff00)) shl 40) or
         (result shr 56);
end;

class function TpvHashRapidHash.ReadSmall(const aData:Pointer;const aDataLength:TpvSizeUInt):TpvUInt64;
begin
 result:=(PpvUInt8Array(aData)^[0] shl 56) or (PpvUInt8Array(aData)^[TpvPtrUInt(aDataLength) shr 1] shl 32) or PpvUInt8Array(aData)^[TpvPtrUInt(aDataLength)-1];
end;
{$endif}
{$endif}

{$ifdef cpuamd64}
function TpvHashRapidHashProcess(aKey:pointer;aLength:TpvSizeUInt;aSeed:TpvUInt64):TpvUInt64; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
  
 // Windows x64 calling convention (forced by ms_abi_default, even on Non-Windows x86-64 targets)
 // Function arguments are passed in registers:  
 // rcx = aKey (pointer to the key data)
 // rdx = aLength (length of the key data) 
 // r8  = aSeed (initial seed value)
 // rax = return value (hash result)
 
 push r15 // Save non-volatile registers
 push r14
 push r12
 push rsi
 push rdi
 push rbx

 mov rdi,rdx // RDI = len
 mov r10,rcx // R10 = key pointer (p)

 // Load secrets
{$ifdef fpc}
 movabs r9,-8378864009470890807 // R9 = RAPID_SECRET1 (0x8bb84b93962eacc9)
 movabs rbx,3257665815644502181 // RBX = RAPID_SECRET0 (0x2d358dccaa6c78a5)
{$else}
 mov r9,-8378864009470890807    // R9 = RAPID_SECRET1 (0x8bb84b93962eacc9)
 mov rbx,3257665815644502181    // RBX = RAPID_SECRET0 (0x2d358dccaa6c78a5)
{$endif}

 // Initial seed calculation: seed ^= rapid_mix(seed^SECRET0, SECRET1) ^ len
 mov rax,r8  // RAX = initial seed
 xor rax,rbx // seed ^ SECRET0
 mul r9      // 128-bit multiply: (seed ^ SECRET0) * SECRET1. Result in RDX:RAX
 xor rdx,rdi // Mix high64 with len
 xor rdx,r8  // Mix with initial seed
 xor rdx,rax // Mix with low64. RDX now holds the updated seed.

 cmp rdi,16 // Check if len <= 16
 ja @Handle_Len_GreaterThan_16 // If len > 16, jump to long input handler

 // --- Handle Short Inputs (len <= 16) ---
 cmp rdi,4 // Check if len < 4
 jb @Handle_Len_1_to_3 // If len < 4, jump to very short input handler

 // --- Handle Length 4 to 16 ---
 // Corresponds to: a = (read32(p) << 32) | read32(p + len - 4); b = ... complex delta calculation ...
 lea rax,[r10+rdi] // RAX = p + len
 add rax,-4        // RAX = p + len - 4 (points to last 4 bytes)
 mov ecx,dword ptr [r10] // ECX = first 4 bytes
 shl rcx,32              // RCX = first 4 bytes << 32
 mov r8d,dword ptr [rax] // R8D = last 4 bytes
 or r8,rcx               // R8 = (first 4 bytes << 32) | last 4 bytes ('a' value)
 // Calculate 'b' value based on delta offset reads
 mov r11d,edi            // R11D = len
 and r11d,24             // R11D = len & 24
 mov ecx,edi             // ECX = len
 shr ecx,3               // ECX = len >> 3
 shr r11,cl              // R11 = (len & 24) >> (len >> 3) ('delta')
 mov ecx,dword ptr [r10+r11] // ECX = read32(p + delta)
 shl rcx,32                  // RCX = read32(p + delta) << 32
 sub rax,r11                 // RAX = (p + len - 4) - delta (points to plast - delta)
 mov eax,dword ptr [rax]     // EAX = read32(plast - delta)
 or rax,rcx                  // RAX = (read32(p + delta) << 32) | read32(plast - delta) ('b' value)
 // Fall through to final mix (@Final_Mix_And_Return_Path)
 // Note: R8 = 'a', RAX = 'b' for the final mixing stage.

@Final_Mix_And_Return_Path:
 // --- Final Mixing Stage ---
 // Finishes the hash calculation using accumulated state.
 // Input State: R8='a', RAX='b', RDX='seed', R9=SECRET1, RBX=SECRET0, RDI='len'
 xor rax,rdx  // b ^= seed
 xor r8,r9    // a ^= SECRET1
 mul r8       // rapid_mum(&rax, &r8) -> 128-bit result in RDX:RAX
 // Final rapid_mix step: rapid_mix(a^SECRET0^len, b^SECRET1)
 xor rdi,rbx  // len ^= SECRET0
 xor rdi,rax  // (len ^ SECRET0) ^ low64(a*b) -> RDI = a' = a^SECRET0^len
 xor r9,rdx   // SECRET1 ^= high64(a*b) -> R9 = b' = b^SECRET1
 mov rax,r9   // RAX = b'
 mul rdi      // rapid_mix(a', b') -> 128-bit result in RDX:RAX
 xor rax,rdx  // Final hash result = low64 ^ high64

 // --- Function Epilogue ---
 pop rbx      // Restore non-volatile registers
 pop rdi
 pop rsi
 pop r12
 pop r14
 pop r15
 jmp @Exit    // Jump to return

@Handle_Len_GreaterThan_16:
 // --- Handle Long Inputs (len > 16) ---
{$ifdef fpc}
 movabs r15,5418857496715711651 // R15 = RAPID_SECRET2 (0x4b33a62ed433d4a3)
{$else}
 mov r15,5418857496715711651    // R15 = RAPID_SECRET2 (0x4b33a62ed433d4a3)
{$endif}
 cmp rdi,49 // Check if len >= 49 (i.e., len > 48)
 jae @Handle_Len_GreaterThan_48 // If len > 48, jump to main loop processing

 // --- Handle Length 17 to 48 (or remainder < 48 after loops) ---
 mov r14,rdi // R14 = remaining length (i)

@Process_Remaining_17_to_48_Bytes_Mix:
 // Corresponds to `if(i>16)` block in C - mix first 8/16/24/32 bytes
 mov rcx,qword ptr [r10] // Read p[0..7]
 xor rcx,r15             // rcx ^ SECRET2
 xor rdx,qword ptr [r10+8] // seed ^ p[8..15]
 xor rdx,r9              // (seed ^ p[8..15]) ^ SECRET1
 mov rax,rdx
 mul rcx                 // rapid_mix(p[0..7]^S2, seed^p[8..15]^S1) -> RDX=new seed
 xor rdx,rax             // Finalize mix into RDX (seed)
 cmp r14,33 // Check if remaining length > 32
 jb @Read_Last_16_Bytes // If not, skip next mix (only needed for len > 32)
 // Handle `if(i > 32)` part - mix next 16 bytes
 xor r15,qword ptr [r10+16] // SECRET2 ^ p[16..23]
 xor rdx,qword ptr [r10+24] // seed ^ p[24..31]
 mov rax,rdx
 mul r15                 // rapid_mix(p[16..23]^S2, seed^p[24..31]) -> RDX=new seed
 xor rdx,rax             // Finalize mix into RDX (seed)
 // Fall through to read last 16 bytes

@Read_Last_16_Bytes:
 // Reads the last 16 bytes regardless of exact length (if > 16)
 // Corresponds to: a=read64(p+i-16), b=read64(p+i-8)
 mov r8,qword ptr [r10+r14-16] // R8 = a = read64(p+i-16)
 mov rax,qword ptr [r10+r14-8] // RAX = b = read64(p+i-8)
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing stage

@Handle_Len_1_to_3:
 // --- Handle Length 1 to 3 ---
 test rdi,rdi // Check if len == 0
 je @Handle_Len_0 // If len is 0, jump to zero handler
 // Corresponds to `a = rapid_readSmall(p, len); b = 0;`
 // Combine first byte, middle byte, and last byte into R8 ('a')
 movzx eax,byte ptr [r10] // Read p[0]
 shl rax,56               // RAX = p[0] << 56
 mov rcx,rdi              // RCX = len
 shr rcx,1                // RCX = len >> 1 (middle index)
 movzx ecx,byte ptr [r10+rcx] // Read p[len >> 1]
 shl rcx,32               // RCX = p[len >> 1] << 32
 or rcx,rax               // RCX = (p[0] << 56) | (p[len >> 1] << 32)
 movzx r8d,byte ptr [r10+rdi-1] // Read p[len - 1]
 or r8,rcx                // R8 = (p[0] << 56) | (p[len >> 1] << 32) | p[len - 1] ('a')
 xor eax,eax              // RAX = 0 ('b')
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing

@Handle_Len_GreaterThan_48:
 // --- Setup for Large Input Processing (len > 48) ---
 // Initialize intermediate seed states see1, see2 (from C code)
 mov rsi,rdx // RSI = seed (used for see2 accumulation)
 mov r11,rdx // R11 = seed (used for seed accumulation)
 mov rcx,rsi // RCX = seed (used for see1 accumulation)
 mov r14,rdi // R14 = remaining length (i)
 cmp rdi,96 // Check if length >= 96 for the unrolled loop
 jb @Process_48_Byte_Chunk // If less than 96, jump to handle potential 48-byte chunk first

@Loop_Process_96_Bytes:
 // --- Main Loop: Process 96 Bytes per Iteration (Unrolled) ---
 // Mix 6 blocks of 16 bytes (total 96 bytes) using seed, see1, see2 accumulators
 // Block 1 (seed: R11)
 mov rdx,qword ptr [r10]    // read p[0..7]
 xor r11,qword ptr [r10+8]  // seed ^ p[8..15]
 xor rdx,rbx                // p[0..7] ^ SECRET0
 mov rax,r11
 mul rdx                    // rapid_mix(...)
 mov r11,rax
 xor r11,rdx                // Update intermediate seed (R11)
 // Block 2 (see1: RCX)
 mov rdx,qword ptr [r10+16] // read p[16..23]
 xor rdx,r9                 // p[16..23] ^ SECRET1
 xor rcx,qword ptr [r10+24] // see1 ^ p[24..31]
 mov rax,rcx
 mul rdx                    // rapid_mix(...)
 mov rcx,rax
 xor rcx,rdx                // Update see1 (RCX)
 // Block 3 (see2: RSI)
 mov rdx,qword ptr [r10+32] // read p[32..39]
 mov rax,rsi                // see2
 xor rax,qword ptr [r10+40] // see2 ^ p[40..47]
 xor rdx,r15                // p[32..39] ^ SECRET2
 mul rdx                    // rapid_mix(...)
 mov rsi,rax
 xor rsi,rdx                // Update see2 (RSI)
 // Block 4 (seed: R11)
 mov rdx,qword ptr [r10+48] // read p[48..55]
 xor rdx,rbx                // p[48..55] ^ SECRET0
 xor r11,qword ptr [r10+56] // seed ^ p[56..63]
 mov rax,r11
 mul rdx                    // rapid_mix(...)
 mov r11,rdx
 xor r11,rax                // Update intermediate seed (R11)
 // Block 5 (see1: RCX)
 mov rdx,qword ptr [r10+64] // read p[64..71]
 xor rcx,qword ptr [r10+72] // see1 ^ p[72..79]
 xor rdx,r9                 // p[64..71] ^ SECRET1
 mov rax,rcx
 mul rdx                    // rapid_mix(...)
 mov rcx,rdx
 xor rcx,rax                // Update see1 (RCX)
 // Block 6 (see2: RSI)
 mov rdx,qword ptr [r10+80] // read p[80..87]
 xor rdx,r15                // p[80..87] ^ SECRET2
 xor rsi,qword ptr [r10+88] // see2 ^ p[88..95]
 mov rax,rsi
 mul rdx                    // rapid_mix(...)
 xor rdx,rax
 mov rsi,rdx                // Update see2 (RSI)

 add r10,96  // Advance key pointer by 96 bytes
 add r14,-96 // Decrement remaining length by 96
 cmp r14,95  // Check if remaining length >= 96
 ja @Loop_Process_96_Bytes // Loop if more 96-byte chunks exist

 // --- After 96-byte Loop ---
 cmp r14,48 // Check if remaining length >= 48
 jae @Process_48_Byte_Chunk // If yes, handle the final 48-byte chunk

 // --- Fall through if remaining length < 48 ---

@Combine_Loop_States_Check_Remainder:
 // Combine the intermediate seed states: seed ^= see1 ^ see2
 // R11 holds seed, RCX holds see1, RSI holds see2
 xor r11,rcx // R11 = seed ^ see1
 mov rdx,rsi // RDX = see2
 xor rdx,r11 // RDX = see2 ^ (seed ^ see1) = final seed state after loops
 // Check how many bytes remain (R14 holds remaining length `i`)
 cmp r14,17 // Check if remaining length >= 17 (i.e., i > 16)
 jae @Process_Remaining_17_to_48_Bytes_Mix // If > 16, process those remaining bytes using the 17-48 logic
 jmp @Read_Last_16_Bytes // Otherwise (remainder <= 16), just read the last 16 bytes

@Handle_Len_0:
 // --- Handle Length 0 ---
 // Set 'a' and 'b' to 0 for final mixing
 xor r8d,r8d // R8 = a = 0
 xor eax,eax // RAX = b = 0
 jmp @Final_Mix_And_Return_Path // Proceed to final mixing

@Process_48_Byte_Chunk:
 // --- Process a Single 48-Byte Chunk ---
 // Used if len was 49-95 initially, or as the last chunk after the 96-byte loop.
 // Mix 3 blocks of 16 bytes (total 48 bytes)
 // Block 1 (seed: R11)
 mov rdx,qword ptr [r10]    // read p[0..7]
 xor rdx,rbx                // p[0..7] ^ SECRET0
 xor r11,qword ptr [r10+8]  // seed ^ p[8..15]
 mov rax,r11
 mul rdx                    // rapid_mix(...) -> RDX:RAX
 mov r8,rax                 // Store low64 temporarily in R8
 // Block 2 (see1: RCX)
 mov r12,qword ptr [r10+16] // read p[16..23]
 xor r12,r9                 // p[16..23] ^ SECRET1
 xor rcx,qword ptr [r10+24] // see1 ^ p[24..31]
 mov r11,rdx                // R11 = high64 from previous mix
 mov rax,rcx
 mul r12                    // rapid_mix(...) -> RDX:RAX
 xor r11,r8                 // Update R11 (intermediate seed)
 mov rcx,rdx                // RCX = high64 from this mix
 xor rcx,rax                // Update RCX (see1)
 // Block 3 (see2: RSI)
 mov rdx,qword ptr [r10+32] // read p[32..39]
 xor rdx,r15                // p[32..39] ^ SECRET2
 mov rax,rsi                // see2
 xor rax,qword ptr [r10+40] // see2 ^ p[40..47]
 mul rdx                    // rapid_mix(...) -> RDX:RAX
 xor rdx,rax                // high64 ^ low64
 mov rsi,rdx                // Update RSI (see2)

 add r10,48  // Advance key pointer by 48 bytes
 add r14,-48 // Decrement remaining length by 48
 jmp @Combine_Loop_States_Check_Remainder // Combine states and check remainder

@Exit:
 // Function return point (RET instruction would typically be here or implicitly after last POP)
end;
{$endif}

class function TpvHashRapidHash.Process(const aKey:pointer;const aLength:TpvSizeUInt;aSeed:TpvUInt64):TMessageDigest;
{$ifdef cpuamd64}
begin
 result:=TpvHashRapidHashProcess(aKey,aLength,aSeed);
end;
{$else}
var p,pLast:PpvUInt8;
    i:TpvSizeUInt;
    a,b:TpvUInt64;
    Delta:TpvUInt64;
    See1,See2:TpvUInt64;
begin
 p:=aKey;
 aSeed:=aSeed xor (Mix(aSeed xor Secret0,Secret1) xor aLength);
 if aLength<=16 then begin
  if aLength>=4 then begin
   pLast:=@PpvUInt8Array(aKey)^[aLength-4];
{$ifdef BIG_ENDIAN}   
   a:=(Read32(p) shl 32) or Read32(pLast);
{$else}
   a:=(PpvUInt32(p)^ shl 32) or PpvUInt32(pLast)^;
{$endif}
   Delta:=(aLength and 24) shr (aLength shr 3);
{$ifdef BIG_ENDIAN}
   b:=(Read32(@PpvUInt8Array(aKey)^[Delta]) shl 32) or Read32(@PpvUInt8Array(aKey)^[aLength-Delta]);
{$else}
   b:=(PpvUInt32(@PpvUInt8Array(aKey)^[Delta])^ shl 32) or PpvUInt32(@PpvUInt8Array(aKey)^[aLength-Delta])^;
{$endif}
  end else if aLength>0 then begin
{$ifdef BIG_ENDIAN}  
   a:=ReadSmall(p,aLength);
{$else}
   a:=(TpvUInt64(PpvUInt8Array(p)^[0]) shl 56) or (TpvUInt64(PpvUInt8Array(p)^[TpvPtrUInt(aLength) shr 1]) shl 32) or PpvUInt8Array(p)^[TpvPtrUInt(aLength)-1];
{$endif}
   b:=0;
  end else begin
   a:=0;
   b:=0;
  end;
 end else begin
  i:=aLength;
  if i>48 then begin
   See1:=aSeed;
   See2:=aSeed;
   while i>=96 do begin
{$ifdef BIG_ENDIAN}
    aSeed:=Mix(Read64(p)^ xor Secret0,Read64(@PpvUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(Read64(@PpvUInt8Array(p)^[16])^ xor Secret1,Read64(@PpvUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(Read64(@PpvUInt8Array(p)^[32])^ xor Secret2,Read64(@PpvUInt8Array(p)^[40])^ xor See2);
    aSeed:=Mix(Read64(@PpvUInt8Array(p)^[48])^ xor Secret0,Read64(@PpvUInt8Array(p)^[56])^ xor aSeed);
    See1:=Mix(Read64(@PpvUInt8Array(p)^[64])^ xor Secret1,Read64(@PpvUInt8Array(p)^[72])^ xor See1);
    See2:=Mix(Read64(@PpvUInt8Array(p)^[80])^ xor Secret2,Read64(@PpvUInt8Array(p)^[88])^ xor See2);
{$else}
    aSeed:=Mix(PpvUInt64(p)^ xor Secret0,PpvUInt64(@PpvUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(PpvUInt64(@PpvUInt8Array(p)^[16])^ xor Secret1,PpvUInt64(@PpvUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(PpvUInt64(@PpvUInt8Array(p)^[32])^ xor Secret2,PpvUInt64(@PpvUInt8Array(p)^[40])^ xor See2);
    aSeed:=Mix(PpvUInt64(@PpvUInt8Array(p)^[48])^ xor Secret0,PpvUInt64(@PpvUInt8Array(p)^[56])^ xor aSeed);
    See1:=Mix(PpvUInt64(@PpvUInt8Array(p)^[64])^ xor Secret1,PpvUInt64(@PpvUInt8Array(p)^[72])^ xor See1);
    See2:=Mix(PpvUInt64(@PpvUInt8Array(p)^[80])^ xor Secret2,PpvUInt64(@PpvUInt8Array(p)^[88])^ xor See2);
{$endif}
    p:=@PpvUInt8Array(p)^[96];
    dec(i,96);
   end;
   if i>=48 then begin
{$ifdef BIG_ENDIAN}
    aSeed:=Mix(Read64(p)^ xor Secret0,Read64(@PpvUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(Read64(@PpvUInt8Array(p)^[16])^ xor Secret1,Read64(@PpvUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(Read64(@PpvUInt8Array(p)^[32])^ xor Secret2,Read64(@PpvUInt8Array(p)^[40])^ xor See2);
{$else}
    aSeed:=Mix(PpvUInt64(p)^ xor Secret0,PpvUInt64(@PpvUInt8Array(p)^[8])^ xor aSeed);
    See1:=Mix(PpvUInt64(@PpvUInt8Array(p)^[16])^ xor Secret1,PpvUInt64(@PpvUInt8Array(p)^[24])^ xor See1);
    See2:=Mix(PpvUInt64(@PpvUInt8Array(p)^[32])^ xor Secret2,PpvUInt64(@PpvUInt8Array(p)^[40])^ xor See2);
{$endif}
    p:=@PpvUInt8Array(p)^[48];
    dec(i,48);
   end;
   aSeed:=aSeed xor See1 xor See2;
  end;
  if i>16 then begin
{$ifdef BIG_ENDIAN}
   aSeed:=Mix(Read64(p)^ xor Secret2,Read64(@PpvUInt8Array(p)^[8])^ xor aSeed xor Secret1);
   if i>32 then begin
    aSeed:=Mix(Read64(@PpvUInt8Array(p)^[16])^ xor Secret2,Read64(@PpvUInt8Array(p)^[24])^ xor aSeed);
   end;
{$else}
   aSeed:=Mix(PpvUInt64(p)^ xor Secret2,PpvUInt64(@PpvUInt8Array(p)^[8])^ xor aSeed xor Secret1);
   if i>32 then begin
    aSeed:=Mix(PpvUInt64(@PpvUInt8Array(p)^[16])^ xor Secret2,PpvUInt64(@PpvUInt8Array(p)^[24])^ xor aSeed);
   end;
{$endif}
  end;
{$ifdef BIG_ENDIAN}
  a:=Read64(@PpvUInt8Array(aKey)^[i-16]);
  b:=Read64(@PpvUInt8Array(aKey)^[i-8]);
{$else}
  a:=PpvUInt64(@PpvUInt8Array(aKey)^[i-16])^;
  b:=PpvUInt64(@PpvUInt8Array(aKey)^[i-8])^;
{$endif}
 end;
 a:=a xor Secret1;
 b:=b xor aSeed;
 MUM(a,b);
 result:=Mix(a xor Secret0 xor aLength,b xor Secret1);
end;
{$endif}

end.
