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
unit PasVulkan.CPU.Info;
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
     PasMP,
     PasVulkan.Types;

const CPUFeatures_X86_F16C_Mask=1 shl 0;
      CPUFeatures_X86_SSE42_Mask=1 shl 1;
      CPUFeatures_X86_PCLMUL_Mask=1 shl 2;

type TCPUFeatures=TpvUInt32;

var CPUFeatures:TCPUFeatures=0;

procedure CheckCPU;

implementation

var CPUChecked:TPasMPBool32=false;

{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
type TCPUIDData=record
      case TpvUInt32 of
       0:(
        Data:array[0..3] of TpvUInt32;
       );
       1:(
        EAX,EBX,EDX,ECX:TpvUInt32;
       );
       2:(
        String_:array[0..15] of AnsiChar;
       );
      end;

      PCPUIDData=^TCPUIDData;

procedure GetCPUID(Value:TpvUInt32;out Data:TCPUIDData); assembler;
asm
{$if defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
 push rbx
{$if defined(Windows) or defined(Win32) or defined(Win64)}
 // Win64 ABI (rcx, rdx, ...)
 mov eax,ecx
 mov r8,rdx
{$else}
 // SysV x64 ABI (rdi, rsi, ...)
 mov eax,edi
 mov r8,rsi
{$ifend}
{$else}
 // register (eax, edx, ...)
 push ebx
 push edi
 mov edi,edx
{$ifend}
 cpuid
{$if defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
 mov dword ptr [r8+0],eax
 mov dword ptr [r8+4],ebx
 mov dword ptr [r8+8],edx
 mov dword ptr [r8+12],ecx
 pop rbx
{$else}
 mov dword ptr [edi+0],eax
 mov dword ptr [edi+4],ebx
 mov dword ptr [edi+8],edx
 mov dword ptr [edi+12],ecx
 pop edi
 pop ebx
{$ifend}
end;
{$ifend}

procedure DoCheckCPU;
{$if defined(cpu386) or defined(cpuamd64) or defined(cpux86_64) or defined(cpux64)}
var CPUIDData:TCPUIDData;
begin
 CPUFeatures:=0;
 begin
  GetCPUID(0,CPUIDData);
 end;
 begin
  GetCPUID(1,CPUIDData);
  if (CPUIDData.ECX and (TpvUInt32(1) shl 1))<>0 then begin
   CPUFeatures:=CPUFeatures or CPUFeatures_X86_PCLMUL_Mask;
  end;
  if (CPUIDData.ECX and (TpvUInt32(1) shl 20))<>0 then begin
   CPUFeatures:=CPUFeatures or CPUFeatures_X86_SSE42_Mask;
  end;
  if (CPUIDData.ECX and (TpvUInt32(1) shl 29))<>0 then begin
   CPUFeatures:=CPUFeatures or CPUFeatures_X86_F16C_Mask;
  end;
 end;
end;
{$else}
begin
end;
{$ifend}

procedure CheckCPU;
begin
 if (not CPUChecked) and
    (not TPasMPInterlocked.CompareExchange(CPUChecked,TPasMPBool32(true),TPasMPBool32(false))) then begin
  DoCheckCPU;
 end;
end;

initialization
 CheckCPU;
end.
