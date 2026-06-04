// Minimal support unit for static linking of C-based libraries (as such as SDL2)
// This unit reimplements some libc etc. functions, which are typically used by
// third-party C libraries
// Copyright (C) 2016, Benjamin 'BeRo' Rosseaux
// License: zlib
unit UnitStaticLinking;
{$ifdef fpc}
{$mode delphi}
{$packrecords c}
{$ifdef cpu386}
 {$asmmode intel}
{$endif}
{$ifdef cpuamd64}
 {$asmmode intel}
{$endif}
{$endif}

interface

uses {$ifdef Windows}Windows,{$endif}SysUtils,Classes,Math;

{$ifdef fpc}
{$ifdef c_int64}
function c_moddi3(num,den:int64):int64; cdecl;
function c_divdi3(num,den:int64):int64; cdecl;
function c_umoddi3(num,den:uint64):uint64; cdecl;
function c_udivdi3(num,den:uint64):uint64; cdecl;
{$endif}
{$ifdef staticlink}
{$ifdef linux}
{function c_pow(x,y:double):double; cdecl;
function c_ceil(x:double):double; cdecl;
function c_atan2(y,x:double):double; cdecl;}
{$endif}
{$if defined(win32) or defined(win64)}
function __imp__RegOpenKeyExW(hKey:HKEY;lpSubKey:LPCWSTR;ulOptions:DWORD;samDesired:REGSAM;phkResult:PHKEY):LONG; stdcall; //@20
function __imp__RegQueryValueExW(hKey:HKEY;lpValueName:LPCWSTR;lpReserved:LPDWORD;lpType:LPDWORD;lpData:LPBYTE;lpcbData:LPDWORD):LONG; stdcall; //@24
function __imp__RegCloseKey(hKey:HKEY):LONG; stdcall; // @4
{$ifend}
{$ifdef win32}
function itoa(value:longint;str:pansichar;base:longint):pansichar; cdecl;
procedure mingw_raise_matherr(typ:longint;name:pansichar;a1,a2,rslt:double) cdecl;
function cosf(x:single):single; cdecl;
function sinf(x:single):single; cdecl;
function _ceil(x:double):double; cdecl;
function _floor(x:double):double; cdecl;
function _sqrt(x:double):double; cdecl;
function _sqrtf(x:single):single; cdecl;
function _tanf(x:single):single; cdecl;
function _log(x:double):double; cdecl;
function _pow(x,y:double):double; cdecl;
function _copysign(x,y:double):double; cdecl;
function strtod(s,endptr:pansichar):double; cdecl;
function fseeko64(s:pointer;offset:int64;whence:longint):longint; cdecl;
function ftello64(s:pointer):int64; cdecl;
function __ms_vsscanf(s,f,a:pansichar{;Args:Array of const}):longint; cdecl; assembler;
function __ms_vsnprintf(str:pansichar;count:ptrint;format:pansichar{;Args:Array of const}):longint; cdecl; assembler;
function scalbn(x:double;e:longint):double; cdecl;
function divdi3(a,b:int64):int64; cdecl;
function pow(x,y:double):double; cdecl;
function _strdup(s:pansichar):pansichar; cdecl;
procedure snprintf; cdecl; assembler;
function strtoll(str,endptr:pansichar;base:longint):int64; cdecl;
function strtoull(str,endptr:pansichar;base:longint):qword; cdecl;
{$endif}
{$ifdef win64}
function cosf(x:single):single; cdecl;
function sinf(x:single):single; cdecl;
function _ceil(x:double):double; cdecl;
function _floor(x:double):double; cdecl;
function _sqrt(x:double):double; cdecl;
function _sqrtf(x:single):single; cdecl;
function _tanf(x:single):single; cdecl;
function _log(x:double):double; cdecl;
function _pow(x,y:double):double; cdecl;
function _copysign(x,y:double):double; cdecl;
function strtod(s,endptr:pansichar):double; cdecl;
function fseeko64(s:pointer;offset:int64;whence:longint):longint; cdecl;
function ftello64(s:pointer):int64; cdecl;
function __ms_vsscanf(s,f,a:pansichar{;Args:Array of const}):longint; cdecl; assembler;
function __ms_vsnprintf(str:pansichar;count:ptrint;format:pansichar{;Args:Array of const}):longint; cdecl; assembler;
function scalbn(x:double;e:longint):double; cdecl;
function strtoll(str,endptr:pansichar;base:longint):int64; cdecl;
function strtoull(str,endptr:pansichar;base:longint):qword; cdecl;
function strdup(s:pansichar):pansichar; cdecl;
procedure snprintf; cdecl; assembler;
{$endif}
{$endif}
{$endif}

implementation

{$ifdef fpc}

{$ifdef c_int64}
function c_moddi3(num,den:int64):int64; cdecl; {$ifdef darwin}[public, alias: '___moddi3'];{$else}[public, alias: '__moddi3'];{$endif}
begin
 result:=num mod den;
end;

function c_divdi3(num,den:int64):int64; cdecl; {$ifdef darwin}[public, alias: '___divdi3'];{$else}[public, alias: '__divdi3'];{$endif}
begin
 result:=num div den;
end;

function c_umoddi3(num,den:uint64):uint64; cdecl; {$ifdef darwin}[public, alias: '___umoddi3'];{$else}[public, alias: '__umoddi3'];{$endif}
begin
 result:=num mod den;
end;

function c_udivdi3(num,den:uint64):uint64; cdecl; {$ifdef darwin}[public, alias: '___udivdi3'];{$else}[public, alias: '__udivdi3'];{$endif}
begin
 result:=num div den;
end;
{$endif}

{$ifdef staticlink}

{$ifdef linux}
{function c_pow(x,y:double):double; cdecl; [alias: 'pow'];
begin
 result:=power(x,y);
end;

function c_ceil(x:double):double; cdecl; [alias: 'ceil'];
begin
 result:=ceil(x);
end;

function c_atan2(y,x:double):double; cdecl; [alias: 'atan2'];
begin
 result:=arctan2(y,x);
end;

procedure c_sincos(x:double;sinus,cosinus:pointer):double; cdecl; [alias: 'sincos'];
begin
 double(sinus^):=sin(x);
 double(cosinus^):=cos(x);
end;}

{$endif}

{$if defined(win32) or defined(win64)}
function __imp__RegOpenKeyExW(hKey:HKEY;lpSubKey:LPCWSTR;ulOptions:DWORD;samDesired:REGSAM;phkResult:PHKEY):LONG; stdcall; {$if defined(win32)}[alias: '__imp__RegOpenKeyExW@20'];{$else}[alias: '__imp_RegOpenKeyExW'];{$ifend}
begin
 result:=RegOpenKeyExW(hKey,lpSubKey,ulOptions,samDesired,phkResult);
end;

function __imp__RegQueryValueExW(hKey:HKEY;lpValueName:LPCWSTR;lpReserved:LPDWORD;lpType:LPDWORD;lpData:LPBYTE;lpcbData:LPDWORD):LONG; stdcall; {$if defined(win32)}[alias: '__imp__RegQueryValueExW@24'];{$else}[alias: '__imp_RegQueryValueExW'];{$ifend}
begin
 result:=RegQueryValueExW(hKey,lpValueName,lpReserved,lpType,lpData,lpcbData);
end;

function __imp__RegCloseKey(hKey:HKEY):LONG; stdcall; {$if defined(win32)}[alias: '__imp__RegCloseKey@4'];{$else}[alias: '__imp_RegCloseKey'];{$ifend}
begin
 result:=RegCloseKey(hKey);
end;
{$ifend}

{$ifdef win32}
function itoa(value:longint;str:pansichar;base:longint):pansichar; cdecl; [alias: '_itoa'];
const BaseChars:array[0..35] of ansichar='0123456789abcdefghijklmnopqrstuvwxyz';
var WorkValue:int64;
    s:array[0..63] of ansichar;
    i:longint;
begin
 result:=str;
 if Base=10 then begin
  WorkValue:=Value;
 end else begin
  WorkValue:=longword(Value);
 end;
 if WorkValue<0 then begin
  str^:='-';
  inc(str);
 end;
 if WorkValue=0 then begin
  str^:='0';
  inc(str);
 end else begin
  i:=0;
  while WorkValue>0 do begin
   s[i]:=BaseChars[WorkValue mod Base];
   inc(i);
   WorkValue:=WorkValue div Base;
  end;
  while i>0 do begin
   dec(i);
   str^:=s[i];
   inc(str);
  end;
 end;
 str^:=#0;
end;

procedure mingw_raise_matherr(typ:longint;name:pansichar;a1,a2,rslt:double) cdecl; [alias: '___mingw_raise_matherr'];
begin
end;

function cosf(x:single):single; cdecl; [alias: '_cosf'];
begin
 result:=cos(x);
end;

function sinf(x:single):single; cdecl; [alias: '_sinf'];
begin
 result:=sin(x);
end;

function _ceil(x:double):double; cdecl; [alias: '_ceil'];
begin
 result:=ceil(x);
end;

function _floor(x:double):double; cdecl; [alias: '_floor'];
begin
 result:=floor(x);
end;

function _sqrt(x:double):double; cdecl; [alias: '_sqrt'];
begin
 result:=sqrt(x);
end;

function _sqrtf(x:single):single; cdecl; [alias: '_sqrtf'];
begin
 result:=sqrt(x);
end;

function _tanf(x:single):single; cdecl; [alias: '_tanf'];
begin
 result:=tan(x);
end;

function _log(x:double):double; cdecl; [alias: '_log'];
begin
 result:=ln(x);
end;

function _pow(x,y:double):double; cdecl; [alias: '_pow'];
begin
 result:=power(x,y);
end;

function _copysign(x,y:double):double; cdecl; [alias: '_copysign'];
begin
 result:=abs(x)*sign(y);
end;

function strtod(s,endptr:pansichar):double; cdecl; [alias: '__strtod'];
var t:ansistring;
    i:longinT;
begin
 t:=s;
 if assigned(endptr) then begin
  SetLength(t,endptr-s);
 end;
 result:=0.0;
 val(t,result,i);
end;

function fseek(s:pointer;offset:int64;whence:longint):longint; cdecl; external name 'fseek';

function fseeko64(s:pointer;offset:int64;whence:longint):longint; cdecl; [alias: '_fseeko64'];
begin
 result:=fseek(s,Offset,whence);
end;

function ftell(s:pointer):longint; cdecl; external name 'ftell';

function ftello64(s:pointer):int64; cdecl; [alias: '_ftello64'];
begin
 result:=ftell(s);
end;

function _memcpy(a,b:pointer;size:ptrint):pointer; cdecl; external name 'memcpy';

function _sscanf(s,f:pansichar;Args:Array of const):longint; cdecl; external name 'sscanf';

function __ms_vsscanf(s,f,a:pansichar{;Args:Array of const}):longint; cdecl; assembler; [alias: '___ms_vsscanf']; nostackframe;
const var_30=-$30;
      var_2C=-$2C;
      var_28=-$28;
      var_24=-$24;
      var_20=-$20;
      var_1C=-$1C;
      var_10=-$10;
      arg_0=$4;
      arg_4=$8;
      arg_8=$C;
asm
 push    edi
 push    esi
 push    ebx
 sub     esp, 10h
 lea     eax, [esp+1Ch+var_10]
 mov     ecx, [esp+1Ch+arg_0]
 mov     edx, [esp+1Ch+arg_4]
 mov     esi, [esp+1Ch+arg_8]
 mov     ebx, esp
 lea     esp, [esp+eax-14h]
 sub     esp, esi
 mov     [esp+30h+var_24], ecx
 mov     [esp+30h+var_20], edx
 lea     edi, [esp+30h+var_1C]
 mov     [esp+30h+var_30], edi // char *
 mov     [esp+30h+var_2C], esi // char *
 mov     [esp+30h+var_28], esi // size_t
 sub     [esp+30h+var_28], eax
 call    _memcpy
 add     esp, 0Ch
 call    _sscanf
 mov     esp, ebx
 add     esp, 10h
 pop     ebx
 pop     esi
 pop     edi
 retn
end;

function vsnprintf_crt(str:pansichar;count:ptrint;format:pansichar;const v:array of const):longint; cdecl; external name '_vsnprintf';

function __ms_vsnprintf(str:pansichar;count:ptrint;format:pansichar{;Args:Array of const}):longint; cdecl; assembler; [alias: '___ms_vsnprintf']; nostackframe;
asm
 jmp vsnprintf_crt
end;

function scalbn(x:double;e:longint):double; cdecl; [alias: '_scalbn'];
const FLT_RADIX=2;
begin
 result:=power(x*FLT_RADIX,e);
end;

function divdi3(a,b:int64):int64; cdecl; [alias: '___divdi3'];
begin
 result:=a div b;
end;

function pow(x,y:double):double; cdecl; [alias: 'pow'];
begin
 result:=power(x,y);
end;

function malloc(size:longint):pointer; cdecl; external name 'malloc';

function _strdup(s:pansichar):pansichar; cdecl; [alias: '_strdup'];
var l:longint;
begin
 l:=length(s);
 result:=malloc(l+1);
 if assigned(s) then begin
  move(s^,result^,l);
  result[l]:=#0;
 end;
end;

function snprintf_crt(str,format:pansichar;v:array of const):longint; cdecl; external name '_snprintf';

procedure snprintf; cdecl; assembler; [alias: '_snprintf']; nostackframe;
asm
 jmp snprintf_crt
end;

function strtoll(str,endptr:pansichar;base:longint):int64; cdecl; [alias: '_strtoll'];
var s:longint;
begin
 result:=0;
 s:=1;
 while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
  case str^ of
   '-':begin
    s:=-s;
   end;
   '+':begin
   end;
   '0'..'9':begin
    result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
   end;
   'a'..'z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
   end;
   'A'..'Z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
   end;
  end;
  inc(str^);
 end;
end;

function strtoull(str,endptr:pansichar;base:longint):qword; cdecl; [alias: '_strtoull'];
var s:longint;
begin
 result:=0;
 s:=1;
 while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
  case str^ of
   '-':begin
    s:=-s;
   end;
   '+':begin
   end;
   '0'..'9':begin
    result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
   end;
   'a'..'z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
   end;
   'A'..'Z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
   end;
  end;
  inc(str^);
 end;
end;

{$endif}
{$ifdef win64}

function cosf(x:single):single; cdecl; [alias: 'cosf'];
begin
 result:=cos(x);
end;

function sinf(x:single):single; cdecl; [alias: 'sinf'];
begin
 result:=sin(x);
end;

function _ceil(x:double):double; cdecl; [alias: 'ceil'];
begin
 result:=ceil(x);
end;

function _floor(x:double):double; cdecl; [alias: 'floor'];
begin
 result:=floor(x);
end;

function _sqrt(x:double):double; cdecl; [alias: 'sqrt'];
begin
 result:=sqrt(x);
end;

function _sqrtf(x:single):single; cdecl; [alias: 'sqrtf'];
begin
 result:=sqrt(x);
end;

function _tanf(x:single):single; cdecl; [alias: 'tanf'];
begin
 result:=tan(x);
end;

function _log(x:double):double; cdecl; [alias: 'log'];
begin
 result:=ln(x);
end;

function _pow(x,y:double):double; cdecl; [alias: 'pow'];
begin
 result:=power(x,y);
end;

function _copysign(x,y:double):double; cdecl; [alias: 'copysign'];
begin
 result:=abs(x)*sign(y);
end;

function strtod(s,endptr:pansichar):double; cdecl; [alias: '__strtod'];
var t:ansistring;
    i:longinT;
begin
 t:=s;
 if assigned(endptr) then begin
  SetLength(t,endptr-s);
 end;
 result:=0.0;
 val(t,result,i);
end;

function fseek(s:pointer;offset:int64;whence:longint):longint; cdecl; external name 'fseek';

function fseeko64(s:pointer;offset:int64;whence:longint):longint; cdecl; [alias: 'fseeko64'];
begin
 result:=fseek(s,Offset,whence);
end;

function ftell(s:pointer):longint; cdecl; external name 'ftell';

function ftello64(s:pointer):int64; cdecl; [alias: 'ftello64'];
begin
 result:=ftell(s);
end;

function _memcpy(a,b:pointer;size:ptrint):pointer; cdecl; external name 'memcpy';

function _sscanf(s,f:pansichar;Args:Array of const):longint; cdecl; external name 'sscanf';

function __ms_vsscanf(s,f,a:pansichar{;Args:Array of const}):longint; cdecl; assembler; [alias: '__ms_vsscanf']; nostackframe;
asm
 push    rdi
 push    rsi
 push    rbx
 sub     rsp, $10
 lea     rax, [rsp+$0C]
 mov     rsi, r8
 mov     rbx, rsp
 lea     rsp, [rsp+rax-$28]
 sub     rsp, rsi
 mov     [rsp+$18], rcx
 mov     [rsp+$20], rdx
 lea     rdi, [rsp+$28]
 mov     [rsp], rdi
 mov     [rsp+8], rsi
 mov     [rsp+$10], rsi
 sub     [rsp+$10], rax
 mov     r8, [rsp+$10]
 mov     rdx, [rsp+8]
 mov     rcx, [rsp]
 call    _memcpy
 add     rsp, $18
 mov     r9, [rsp+$18]
 mov     r8, [rsp+$10]
 mov     rdx, [rsp+$8]
 mov     rcx, [rsp]
 call    _sscanf
 mov     rsp, rbx
 add     rsp, $10
 pop     rbx
 pop     rsi
 pop     rdi
 retn
end;

function vsnprintf_crt(str:pansichar;count:ptrint;format:pansichar;const v:array of const):longint; cdecl; external name 'vsnprintf';

function __ms_vsnprintf(str:pansichar;count:ptrint;format:pansichar{;Args:Array of const}):longint; cdecl; assembler; [alias: '__ms_vsnprintf']; nostackframe;
asm
 jmp vsnprintf_crt
end;

function scalbn(x:double;e:longint):double; cdecl; [alias: 'scalbn'];
const FLT_RADIX=2;
begin
 result:=power(x*FLT_RADIX,e);
end;

function strtoll(str,endptr:pansichar;base:longint):int64; cdecl; [alias: 'strtoll'];
var s:longint;
begin
 result:=0;
 s:=1;
 while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
  case str^ of
   '-':begin
    s:=-s;
   end;
   '+':begin
   end;
   '0'..'9':begin
    result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
   end;
   'a'..'z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
   end;
   'A'..'Z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
   end;
  end;
  inc(str^);
 end;
end;

function strtoull(str,endptr:pansichar;base:longint):qword; cdecl; [alias: 'strtoull'];
var s:longint;
begin
 result:=0;
 s:=1;
 while (str^<>#0) and (ptruint(str)<ptruint(endptr)) do begin
  case str^ of
   '-':begin
    s:=-s;
   end;
   '+':begin
   end;
   '0'..'9':begin
    result:=(result*base)+(byte(ansichar(str^))-byte(ansichar('0')));
   end;
   'a'..'z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('a')))+$a);
   end;
   'A'..'Z':begin
    result:=(result*base)+((byte(ansichar(str^))-byte(ansichar('A')))+$a);
   end;
  end;
  inc(str^);
 end;
end;

function malloc(size:int64):pointer; cdecl; external name 'malloc';

function strdup(s:pansichar):pansichar; cdecl; [alias: 'strdup'];
var l:longint;
begin
 l:=length(s);
 result:=malloc(l+1);
 if assigned(s) then begin
  move(s^,result^,l);
  result[l]:=#0;
 end;
end;

function snprintf_crt(str,format:pansichar;const v:array of const):longint; cdecl; external name '_snprintf';

procedure snprintf; cdecl; assembler; [alias: 'snprintf']; nostackframe;
asm
 jmp snprintf_crt
end;
{$endif}
{$endif}
{$endif}

end.

