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
unit PasVulkan.Hash.xxHash64;
{$i PasVulkan.inc}
{$ifndef fpc}
 {$ifdef conditionalexpressions}
  {$if CompilerVersion>=24.0}
   {$legacyifend on}
  {$ifend}
 {$endif}
{$endif}

{$ifdef fpc}
 {$optimization off}
 {$optimization level1}
{$endif}

interface

uses SysUtils,
     Classes,
     Math,
     Vulkan,
     PasVulkan.Types;

type TpvHashXXHash64=class
      public
       const PRIME64_1=TpvUInt64($9e3779b185ebca87);
             PRIME64_2=TpvUInt64($c2b2ae3d27d4eb4f);
             PRIME64_3=TpvUInt64($165667b19e3779f9);
             PRIME64_4=TpvUInt64($85ebca77c2b2ae63);
             PRIME64_5=TpvUInt64($27d4eb2f165667c5);
       type TMessageDigest=TpvUInt64;
            PMessageDigest=^TMessageDigest;
      private
       fTotalLength:TpvSizeUInt;
       fSeed:TpvUInt64;
       fV1:TpvUInt64;
       fV2:TpvUInt64;
       fV3:TpvUInt64;
       fV4:TpvUInt64;
       fDataSize:TpvSizeUInt;
       fData:array[0..31] of TpvUInt8;
{$if not declared(ROLQWord)}
       class function ROLQWord(const aValue:TpvUInt64;const aBits:TpvSizeUInt):TpvUInt64; static; inline;
{$ifend}
      public
       constructor Create(const aSeed:TpvUInt64=0); reintroduce;
       destructor Destroy; override;
       procedure Update(const aData:pointer;const aDataLength:TpvSizeUInt);
       function Final:TMessageDigest;
       class function Process(const aData:pointer;const aDataLength:TpvSizeUInt;const aSeed:TpvUInt64=0):TMessageDigest; static;
       class function ProcessStream(const aStream:TStream;const aCheckSumPosition:TpvInt64=-1;const aSeed:TpvUInt64=0):TMessageDigest; static;
     end;

implementation

{ TpvHashXXHash64 }

{$if not declared(ROLQWord)}
class function TpvHashxxHash64.ROLQWord(const aValue:TpvUInt64;const aBits:TpvSizeUInt):TpvUInt64;
begin
 result:=(aValue shl aBits) or (aValue shr (64-aBits));
end;
{$ifend}

constructor TpvHashXXHash64.Create(const aSeed:TpvUInt64=0);
begin
 inherited Create;
 fSeed:=aSeed;
 fV1:=aSeed+PRIME64_1;
 fV1:=fV1+PRIME64_2;
 fV2:=aSeed+PRIME64_2;
 fV3:=aSeed;
 fV4:=aSeed-PRIME64_1;
 fTotalLength:=0;
 fDataSize:=0;
 FillChar(fData,SizeOf(fData),#0);
end;

destructor TpvHashXXHash64.Destroy;
begin
 inherited Destroy;
end;

procedure TpvHashXXHash64.Update(const aData:pointer;const aDataLength:TpvSizeUInt);
var v1,v2,v3,v4:TpvUInt64;
    CurrentData,DataEnd,DataStop:Pointer;
begin

 CurrentData:=aData;

 inc(fTotalLength,aDataLength);

 if (fDataSize+aDataLength)<TpvSizeUInt(32) then begin

  Move(CurrentData^,fData[fDataSize],aDataLength);
  inc(fDataSize,32);

 end else begin

  DataEnd:=@PpvUInt8Array(aData)^[aDataLength];

  if fDataSize>0 then begin

   Move(CurrentData^,fData[fDataSize],32-fDataSize);

   fV1:=PRIME64_1*ROLQWord(fV1+(PRIME64_2*PpvUInt64(pointer(@fData[0]))^),31);
   fV2:=PRIME64_1*ROLQWord(fV2+(PRIME64_2*PpvUInt64(pointer(@fData[8]))^),31);
   fV3:=PRIME64_1*ROLQWord(fV3+(PRIME64_2*PpvUInt64(pointer(@fData[16]))^),31);
   fV4:=PRIME64_1*ROLQWord(fV4+(PRIME64_2*PpvUInt64(pointer(@fData[24]))^),31);

   CurrentData:=@PpvUInt8Array(CurrentData)^[32-fDataSize];

   fDataSize:=0;

  end;

  if (TpvPtrUInt(CurrentData)+31)<TpvPtrUInt(DataEnd) then begin
   v1:=fV1;
   v2:=fV2;
   v3:=fV3;
   v4:=fV4;

   DataStop:=Pointer(TpvPtrUInt(TpvPtrUInt(DataEnd)-32));
   repeat
    v1:=PRIME64_1*ROLQWord(v1+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v2:=PRIME64_1*ROLQWord(v2+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v3:=PRIME64_1*ROLQWord(v3+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v4:=PRIME64_1*ROLQWord(v4+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
   until TpvPtrUInt(CurrentData)>TpvPtrUInt(DataStop);

   fV1:=v1;
   fV2:=v2;
   fV3:=v3;
   fV4:=v4;
  end;

  if TpvPtrUInt(CurrentData)<TpvPtrUInt(DataEnd) then begin
   fDataSize:=TpvPtrUInt(DataEnd)-TpvPtrUInt(CurrentData);
   Move(CurrentData^,fData[0],fDataSize);
  end;

 end;

end;

function TpvHashXXHash64.Final:TMessageDigest;
var v1,v2,v3,v4:TpvUInt64;
    CurrentData,DataEnd:Pointer;
begin

 if fTotalLength>=TpvSizeUInt(32) then begin
  v1:=fV1;
  v2:=fV2;
  v3:=fV3;
  v4:=fV4;
  result:=ROLQWord(v1,1)+ROLQWord(v2,7)+ROLQWord(v3,12)+ROLQWord(v4,18);
  v1:=ROLQWord(v1*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v1)*PRIME64_1)+PRIME64_4;
  v2:=ROLQWord(v2*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v2)*PRIME64_1)+PRIME64_4;
  v3:=ROLQWord(v3*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v3)*PRIME64_1)+PRIME64_4;
  v4:=ROLQWord(v4*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v4)*PRIME64_1)+PRIME64_4;
 end else begin
  result:=fSeed+PRIME64_5;
 end;
 inc(result,fTotalLength);

 CurrentData:=@fData[0];
 DataEnd:=@fData[fDataSize];

 while (TpvPtrUInt(CurrentData)+7)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PRIME64_1*ROLQWord(PRIME64_2*PpvUInt64(CurrentData)^,31));
  result:=(ROLQWord(result,27)*PRIME64_1)+PRIME64_4;
  inc(PpvUInt64(CurrentData));
 end;

 while (TpvPtrUInt(CurrentData)+3)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PpvUInt32(CurrentData)^*PRIME64_1);
  result:=(ROLQWord(result,23)*PRIME64_2)+PRIME64_3;
  inc(PpvUInt32(CurrentData));
 end;

 while TpvPtrUInt(CurrentData)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PpvUInt8(CurrentData)^*PRIME64_5);
  result:=ROLQWord(result,11)*PRIME64_1;
  inc(PpvUInt8(CurrentData));
 end;

 result:=(result xor (result shr 33))*PRIME64_2;
 result:=(result xor (result shr 29))*PRIME64_3;
 result:=result xor (result shr 32);

end;

{$ifdef cpuamd64}
function TpvHashXXHash64ProcessAMD64(aData:pointer;aDataLength:TpvSizeUInt;aSeed:TpvUInt64):TpvUInt64; assembler; {$ifdef fpc}nostackframe; ms_abi_default;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
 push r15
 push r14
 push r13
 push r12
 push rsi
 push rdi
 push rbp
 push rbx
{$ifdef fpc}
 movabs r9,$c2b2ae3d27d4eb4f // -4417276706812531889
 movabs r10,$27d4eb2f165667c5 // 2870177450012600261
 movabs r14,$165667b19e3779f9 // 1609587929392839161
{$else}
 mov r9,$c2b2ae3d27d4eb4f // -4417276706812531889
 mov r10,$27d4eb2f165667c5 // 2870177450012600261
 mov r14,$165667b19e3779f9 // 1609587929392839161
{$endif}
 test rcx,rcx
 je @L5
{$ifdef fpc}
 movabs r11,$9e3779b185ebca87 // -7046029288634856825
 movabs rsi,$85ebca77c2b2ae63 // -8796714831421723037
{$else}
 mov r11,$9e3779b185ebca87 // -7046029288634856825
 mov rsi,$85ebca77c2b2ae63 // -8796714831421723037
{$endif}
 cmp rdx,32
 jb @L6
{$ifdef fpc}
 movabs rbp,$60ea27eeadc0b5d6 // 6983438078262162902
{$else}
 mov rbp,$60ea27eeadc0b5d6 // 6983438078262162902
{$endif}
 add rbp,r8
 lea r13,[r8+r9]
{$ifdef fpc}
 movabs r12,$61c8864e7a143579 // 7046029288634856825
{$else}
 mov r12,$61c8864e7a143579 // 7046029288634856825
{$endif}
 add r12,r8
 lea rax,[rcx+rdx]
 add rax,-31
@L3:
 mov r15,qword ptr [rcx]
 imul r15,r9
 add r15,rbp
 rol r15,31
 mov rbp,r15
 imul rbp,r11
 mov r14,qword ptr [rcx+8]
 imul r14,r9
 add r14,r13
 rol r14,31
 mov r13,r14
 mov rbx,qword ptr [rcx+16]
 imul rbx,r9
 add rbx,r8
 rol rbx,31
 imul r13,r11
 mov r8,rbx
 imul r8,r11
 mov rdi,qword ptr [rcx+24]
 imul rdi,r9
 add rdi,r12
 rol rdi,31
 mov r12,rdi
 imul r12,r11
 add rcx,32
 cmp rcx,rax
 jb @L3
 rol rbp,1
 rol r13,7
 add r13,rbp
 rol r8,12
 rol r12,18
 add r12,r8
 add r12,r13
{$ifdef fpc}
 movabs rax,$def35b010f796ca9 // -2381459717836149591
{$else}
 mov rax,$def35b010f796ca9 // -2381459717836149591
{$endif}
 imul r15,rax
 rol r15,31
 imul r15,r11
 xor r15,r12
 imul r15,r11
 imul r14,rax
 rol r14,31
 add r15,rsi
 imul r14,r11
 xor r14,r15
 imul r14,r11
 add r14,rsi
 imul rbx,rax
 rol rbx,31
 imul rbx,r11
 xor rbx,r14
 imul rbx,r11
 add rbx,rsi
 imul rdi,rax
 rol rdi,31
 imul rdi,r11
 xor rdi,rbx
 imul rdi,r11
 add rdi,rdx
 add rdi,rsi
{$ifdef fpc}
 movabs r14,$165667b19e3779f9 //1609587929392839161
{$else}
 mov r14,$165667b19e3779f9 //1609587929392839161
{$endif}
 and edx,31
 cmp rdx,8
 jae @L8
 jmp @L13
@L5:
 add r8,r10
 jmp @L25
@L6:
 add r8,r10
 add r8,rdx
 mov rdi,r8
 and edx,31
 cmp rdx,8
 jb @L13
@L8:
 lea rbx,[rdx-8]
 test bl,8
 jne @L9
 mov r8,qword ptr [rcx]
 imul r8,r9
 rol r8,31
 imul r8,r11
 add rcx,8
 xor r8,rdi
 rol r8,27
 imul r8,r11
 add r8,rsi
 mov rdi,r8
 mov rdx,rbx
 cmp rbx,8
 jae @L12
 jmp @L14
@L9:
 cmp rbx,8
 jb @L14
@L12:
 mov rax,qword ptr [rcx]
 imul rax,r9
 rol rax,31
 imul rax,r11
 xor rax,rdi
 rol rax,27
 imul rax,r11
 add rax,rsi
 mov rdi,qword ptr [rcx+8]
 imul rdi,r9
 rol rdi,31
 imul rdi,r11
 xor rdi,rax
 add rcx,16
 rol rdi,27
 imul rdi,r11
 add rdi,rsi
 add rdx,-16
 cmp rdx,7
 ja @L12
@L13:
 mov rbx,rdx
 mov r8,rdi
@L14:
 cmp rbx,4
 jae @L15
 test rbx,rbx
 jne @L17
 jmp @L25
@L15:
 mov eax,dword ptr [rcx]
 imul rax,r11
 xor rax,r8
 add rcx,4
 rol rax,23
 imul rax,r9
 add rax,r14
 add rbx,-4
 mov r8,rax
 test rbx,rbx
 je @L25
@L17:
 mov rdx,rbx
 and rdx,3
 je @L18
 xor eax,eax
@L20:
 movzx esi,byte ptr [rcx+rax]
 imul rsi,r10
 xor rsi,r8
 rol rsi,11
 mov r8,rsi
 imul r8,r11
 inc rax
 cmp rdx,rax
 jne @L20
 add rcx,rax
 mov rdx,rbx
 sub rdx,rax
 cmp rbx,4
 jae @L23
 jmp @L25
@L18:
 mov rdx,rbx
 cmp rbx,4
 jb @L25
@L23:
 xor eax,eax
@L24:
 movzx esi,byte ptr [rcx+rax]
 imul rsi,r10
 xor rsi,r8
 rol rsi,11
 imul rsi,r11
 movzx r8d,byte ptr [rcx+rax+1]
 imul r8,r10
 xor r8,rsi
 rol r8,11
 imul r8,r11
 movzx esi,byte ptr [rcx+rax+2]
 imul rsi,r10
 xor rsi,r8
 rol rsi,11
 imul rsi,r11
 movzx r8d,byte ptr [rcx+rax+3]
 imul r8,r10
 xor r8,rsi
 rol r8,11
 imul r8,r11
 add rax,4
 cmp rdx,rax
 jne @L24
@L25:
 mov rax,r8
 shr rax,33
 xor rax,r8
 imul rax,r9
 mov rcx,rax
 shr rcx,29
 xor rcx,rax
 imul rcx,r14
 mov rax,rcx
 shr rax,32
 xor rax,rcx
 pop rbx
 pop rbp
 pop rdi
 pop rsi
 pop r12
 pop r13
 pop r14
 pop r15
end;
{$endif}

class function TpvHashXXHash64.Process(const aData:pointer;const aDataLength:TpvSizeUInt;const aSeed:TpvUInt64):TpvHashXXHash64.TMessageDigest;
{$if defined(cpuamd64)}
begin
 result:=TpvHashXXHash64ProcessAMD64(aData,aDataLength,aSeed);
end;
{$elseif true}
var TotalLength:TpvSizeUInt;
    v1:TpvUInt64;
    v2:TpvUInt64;
    v3:TpvUInt64;
    v4:TpvUInt64;
    DataSize:TpvSizeUInt;
    Data:array[0..31] of TpvUInt8;
    CurrentData,DataEnd,DataStop:Pointer;
begin
 v1:=aSeed+PRIME64_1;
 v1:=v1+PRIME64_2;
 v2:=aSeed+PRIME64_2;
 v3:=aSeed;
 v4:=aSeed-PRIME64_1;
 TotalLength:=0;
 DataSize:=0;
 FillChar(Data,SizeOf(Data),#0);

 CurrentData:=aData;

 inc(TotalLength,aDataLength);

 if (DataSize+aDataLength)<TpvSizeUInt(32) then begin

  Move(CurrentData^,Data[DataSize],aDataLength);
  inc(DataSize,32);

 end else begin

  DataEnd:=@PpvUInt8Array(aData)^[aDataLength];

  if DataSize>0 then begin

   Move(CurrentData^,Data[DataSize],32-DataSize);

   v1:=PRIME64_1*ROLQWord(v1+(PRIME64_2*PpvUInt64(pointer(@Data[0]))^),31);
   v2:=PRIME64_1*ROLQWord(v2+(PRIME64_2*PpvUInt64(pointer(@Data[8]))^),31);
   v3:=PRIME64_1*ROLQWord(v3+(PRIME64_2*PpvUInt64(pointer(@Data[16]))^),31);
   v4:=PRIME64_1*ROLQWord(v4+(PRIME64_2*PpvUInt64(pointer(@Data[24]))^),31);

   CurrentData:=@PpvUInt8Array(CurrentData)^[32-DataSize];

   DataSize:=0;

  end;

  if (TpvPtrUInt(CurrentData)+31)<TpvPtrUInt(DataEnd) then begin

   DataStop:=Pointer(TpvPtrUInt(TpvPtrUInt(DataEnd)-32));
   repeat
    v1:=PRIME64_1*ROLQWord(v1+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v2:=PRIME64_1*ROLQWord(v2+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v3:=PRIME64_1*ROLQWord(v3+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
    v4:=PRIME64_1*ROLQWord(v4+(PRIME64_2*PpvUInt64(CurrentData)^),31);
    inc(PpvUInt64(CurrentData));
   until TpvPtrUInt(CurrentData)>TpvPtrUInt(DataStop);

  end;

  if TpvPtrUInt(CurrentData)<TpvPtrUInt(DataEnd) then begin
   DataSize:=TpvPtrUInt(DataEnd)-TpvPtrUInt(CurrentData);
   Move(CurrentData^,Data[0],DataSize);
  end;

 end;

 if TotalLength>=TpvSizeUInt(32) then begin
  result:=ROLQWord(v1,1)+ROLQWord(v2,7)+ROLQWord(v3,12)+ROLQWord(v4,18);
  v1:=ROLQWord(v1*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v1)*PRIME64_1)+PRIME64_4;
  v2:=ROLQWord(v2*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v2)*PRIME64_1)+PRIME64_4;
  v3:=ROLQWord(v3*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v3)*PRIME64_1)+PRIME64_4;
  v4:=ROLQWord(v4*PRIME64_2,31)*PRIME64_1;
  result:=((result xor v4)*PRIME64_1)+PRIME64_4;
 end else begin
  result:=aSeed+PRIME64_5;
 end;

 inc(result,TotalLength);

 CurrentData:=@Data[0];
 DataEnd:=@Data[DataSize];

 while (TpvPtrUInt(CurrentData)+7)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PRIME64_1*ROLQWord(PRIME64_2*PpvUInt64(CurrentData)^,31));
  result:=(ROLQWord(result,27)*PRIME64_1)+PRIME64_4;
  inc(PpvUInt64(CurrentData));
 end;

 while (TpvPtrUInt(CurrentData)+3)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PpvUInt32(CurrentData)^*PRIME64_1);
  result:=(ROLQWord(result,23)*PRIME64_2)+PRIME64_3;
  inc(PpvUInt32(CurrentData));
 end;

 while TpvPtrUInt(CurrentData)<TpvPtrUInt(DataEnd) do begin
  result:=result xor (PpvUInt8(CurrentData)^*PRIME64_5);
  result:=ROLQWord(result,11)*PRIME64_1;
  inc(PpvUInt8(CurrentData));
 end;

 result:=(result xor (result shr 33))*PRIME64_2;
 result:=(result xor (result shr 29))*PRIME64_3;
 result:=result xor (result shr 32);

end;
{$else}
var Instance:TpvHashXXHash64;
begin
 Instance:=TpvHashXXHash64.Create(aSeed);
 try
  Instance.Update(aData,aDataLength);
  result:=Instance.Final;
 finally
  FreeAndNil(Instance);
 end;
end;
{$ifend}

class function TpvHashXXHash64.ProcessStream(const aStream:TStream;const aCheckSumPosition:TpvInt64=-1;const aSeed:TpvUInt64=0):TMessageDigest; 
const BufferSize=4194304; // four megabytes at once 
var Instance:TpvHashXXHash64;
    Buffer:pointer;
    BytesRead,Remaining,Position,FromIndex,ToIndex:TpvInt64;
    OriginalMessageDigest:TMessageDigest;
begin

 if aStream is TMemoryStream then begin

  if aCheckSumPosition>=0 then begin
   OriginalMessageDigest:=PMessageDigest(Pointer(@PpvUInt8Array(Pointer(TMemoryStream(aStream).Memory))^[aCheckSumPosition]))^;
   PMessageDigest(Pointer(@PpvUInt8Array(Pointer(TMemoryStream(aStream).Memory))^[aCheckSumPosition]))^:=0;
   result:=TpvHashXXHash64.Process(TMemoryStream(aStream).Memory,aStream.Size,aSeed);
   PMessageDigest(Pointer(@PpvUInt8Array(Pointer(TMemoryStream(aStream).Memory))^[aCheckSumPosition]))^:=OriginalMessageDigest;
  end else begin
   result:=TpvHashXXHash64.Process(TMemoryStream(aStream).Memory,aStream.Size,aSeed);
  end;

 end else begin

  GetMem(Buffer,BufferSize);
  try

   Instance:=TpvHashXXHash64.Create(aSeed);
   try

    Position:=0;

    Remaining:=aStream.Size;

    while Remaining>0 do begin

     BytesRead:=aStream.Read(Buffer^,Min(BufferSize,Remaining));

     if BytesRead>0 then begin

      // Blank out the checksum, so that the checksum isn't part of the checksum calculation itself
      if aCheckSumPosition>=0 then begin
       // 1D intersection test between (Position .. Position+BytesRead) and (aCheckSumPosition .. aCheckSumPosition+SizeOf(TMessageDigest))
       if (Position<(aCheckSumPosition+SizeOf(TMessageDigest))) and ((Position+BytesRead)>aCheckSumPosition) then begin
        FromIndex:=Max(0,aCheckSumPosition-Position);
        ToIndex:=Min(Max((aCheckSumPosition+SizeOf(TMessageDigest))-Position,0),BytesRead);
        if FromIndex<ToIndex then begin
         FillChar(PpvUInt8Array(Buffer)^[FromIndex],ToIndex-FromIndex,#0);
        end;
       end;
      end;

      Instance.Update(Buffer,BytesRead);

      dec(Remaining,BytesRead);
      inc(Position,BytesRead);

     end else begin

      break;

     end;

    end;

    result:=Instance.Final;

   finally
    FreeAndNil(Instance);
   end;

  finally
   FreeMem(Buffer);
  end;

 end;

end;

end.
