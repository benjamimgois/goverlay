(******************************************************************************
 *                                 PasVulkan                                  *
 ******************************************************************************
 *                       Version see PasVulkan.Framework.pas                  *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2026, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
unit PasVulkan.Math.Utils;
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
     PasVulkan.Types;

{$if declared(SARLongint)}
 {$define HasSARLongint}
{$else}
 {$undef HasSARLongint}
{$endif}

{$if declared(SARInt64)}
 {$define HasSARInt64}
{$else}
 {$undef HasSARInt64}
{$endif}

{$if not defined(HasSARLongint)}
function SARLongint(Value,Shift:longint):longint;
{$if defined(cpu386)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
{$elseif defined(cpux64) or defined(cpuamd64) or defined(cpux86_64)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
{$elseif defined(cpuarm)} assembler; {$ifdef fpc}nostackframe;{$endif}
{$else}inline;
{$ifend}
{$ifend}

{$if not defined(HasSARInt64)}
function SARInt64(Value:TpvInt64;Shift:TpvInt32):TpvInt64;
{$if defined(cpux64) or defined(cpuamd64) or defined(cpux86_64)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
{$else}inline;
{$ifend}
{$ifend}


implementation

{$if not defined(HasSARLongint)}
function SARLongint(Value,Shift:longint):longint;
{$if defined(cpu386)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
 mov ecx,edx
 sar eax,cl
end;
{$elseif defined(cpux64) or defined(cpuamd64) or defined(cpux86_64)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 mov eax,ecx
 mov ecx,edx
{$else}
 mov eax,edi
 mov ecx,esi
{$ifend}
 sar eax,cl
end;
{$elseif defined(cpuarm)} assembler; {$ifdef fpc}nostackframe;{$endif}
asm
 mov r0,r0,asr r1
{$if defined(cpuarm_has_bx)}
 bx lr
{$else}
 mov pc,lr
{$ifend}
end;
{$else}inline;
begin
 Shift:=Shift and 31;
 result:=(longword(Value) shr Shift) or (longword(longint(longword(0-longword(longword(Value) shr 31)) and longword(0-longword(ord(Shift<>0))))) shl (32-Shift));
end;
{$ifend}
{$ifend}

{$if not defined(HasSARInt64)}
function SARInt64(Value:TpvInt64;Shift:TpvInt32):TpvInt64;
{$if defined(cpux64) or defined(cpuamd64) or defined(cpux86_64)} assembler; register; {$ifdef fpc}nostackframe;{$endif}
asm
{$ifndef fpc}
 .noframe
{$endif}
{$if defined(Win32) or defined(Win64) or defined(Windows)}
 mov rax,rcx
 mov rcx,rdx
{$else}
 mov rax,edi
 mov rcx,rsi
{$ifend}
 sar rax,cl
end;
{$else}inline;
begin
 Shift:=Shift and 63;
 result:=TpvInt64(TpvUInt64(TpvUInt64(TpvUInt64(Value) shr Shift) or (TpvUInt64(TpvInt64(TpvUInt64(0-TpvUInt64(TpvUInt64(Value) shr 63)) and TpvUInt64(TpvInt64(0-(ord(Shift<>0) and 1))))) shl (64-Shift))));
end;
{$ifend}
{$ifend}

end.

