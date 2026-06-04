(**********************************************************´*******************
 *                     PUCU Pascal UniCode Utils Libary                       *
 ******************************************************************************
 *                                zlib license                                *
 *============================================================================*
 *                                                                            *
 * Copyright (C) 2016-2022, Benjamin Rosseaux (benjamin@rosseaux.de)          *
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
 * 3. After a pull request, check the status of your pull request on          *
      http://github.com/BeRo1985/pucu                                         *
 * 4. Write code, which is compatible with Delphi 7-XE7 and FreePascal >= 3.0 *
 *    so don't use generics/templates, operator overloading and another newer *
 *    syntax features than Delphi 7 has support for that, but if needed, make *
 *    it out-ifdef-able.                                                      *
 * 5. Don't use Delphi-only, FreePascal-only or Lazarus-only libraries/units, *
 *    but if needed, make it out-ifdef-able.                                  *
 * 6. No use of third-party libraries/units as possible, but if needed, make  *
 *    it out-ifdef-able.                                                      *
 * 7. Try to use const when possible.                                         *
 * 8. Make sure to comment out writeln, used while debugging.                 *
 * 9. Make sure the code compiles on 32-bit and 64-bit platforms (x86-32,     *
 *    x86-64, ARM, ARM64, etc.).                                              *
 *                                                                            *
 ******************************************************************************)
program PUCUGnCodePages;
{$ifdef fpc}
 {$mode delphi}
 {$ifdef cpui386}
  {$define cpu386}
 {$endif}
 {$ifdef cpu386}
  {$asmmode intel}
 {$endif}
 {$ifdef cpuamd64}
  {$asmmode intel}
 {$endif}
 {$ifdef FPC_LITTLE_ENDIAN}
  {$define LITTLE_ENDIAN}
 {$else}
  {$ifdef FPC_BIG_ENDIAN}
   {$define BIG_ENDIAN}
  {$endif}
 {$endif}
 {-$pic off}
 {$define caninline}
 {$ifdef FPC_HAS_TYPE_EXTENDED}
  {$define HAS_TYPE_EXTENDED}
 {$else}
  {$undef HAS_TYPE_EXTENDED}
 {$endif}
 {$ifdef FPC_HAS_TYPE_DOUBLE}
  {$define HAS_TYPE_DOUBLE}
 {$else}
  {$undef HAS_TYPE_DOUBLE}
 {$endif}
 {$ifdef FPC_HAS_TYPE_SINGLE}
  {$define HAS_TYPE_SINGLE}
 {$else}
  {$undef HAS_TYPE_SINGLE}
 {$endif}
 {$if declared(RawByteString)}
  {$define HAS_TYPE_RAWBYTESTRING}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$ifend}
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$ifdef conditionalexpressions}
  {$if declared(RawByteString)}
   {$define HAS_TYPE_RAWBYTESTRING}
  {$else}
   {$undef HAS_TYPE_RAWBYTESTRING}
  {$ifend}
 {$else}
  {$undef HAS_TYPE_RAWBYTESTRING}
 {$endif}
{$endif}
{$ifdef win32}
 {$define windows}
{$endif}
{$ifdef win64}
 {$define windows}
{$endif}
{$ifdef wince}
 {$define windows}
{$endif}
{$rangechecks off}
{$extendedsyntax on}
{$writeableconst on}
{$hints off}
{$booleval off}
{$typedaddress off}
{$stackframes off}
{$varstringchecks on}
{$typeinfo on}
{$overflowchecks off}
{$longstrings on}
{$openstrings on}
{$assertions on}
{$ifdef windows}
 {$apptype console}
{$endif}
uses
  Windows,
  SysUtils,
  ActiveX,
  Registry,
  Classes;

type _cpinfoex=record
      MaxCharSize:UINT; { max length (bytes) of a char }
      DefaultChar:array[0..MAX_DEFAULTCHAR-1] of Byte; { default character }
      LeadByte:array[0..MAX_LEADBYTES-1] of Byte; { lead byte ranges }
      UnicodeDefaultChar:WCHAR;
      CodePage:UINT;
      CodePageName:array[0..MAX_PATH] of char;
     end;
     TCPInfoEx=_cpinfoex;
     CPINFOEX=_cpinfoex;

var s:ansistring;
    cp,i,j,cu:longint;
    w:widestring;
    u,supported:array[word] of boolean;
    SubSubPages:array[word] of boolean;
    SubPages:array[word] of boolean;
    CodePageNames:array[word] of ansistring;
    t:text;

function SetThreadUILanguage(LangId:WORD):WORD; stdcall; external 'kernel32.dll' name 'SetThreadUILanguage';

function GetCPInfoEx(CodePage:UINT; dwFlags:DWORD; var lpCPInfoEx:TCPInfoEx):BOOL; stdcall; external 'kernel32.dll' name 'GetCPInfoExA';

function CpEnumProc(CodePage:PChar):Cardinal; stdcall;
var CpInfoEx:TCPInfoEx;
    Cp:cardinal;
begin
 Cp:=StrToIntDef(CodePage,0);
 if IsValidCodePage(Cp) then begin
  supported[cp]:=true;
  GetCPInfoEx(Cp,0,CpInfoEx);
  CodePageNames[cp]:=CpInfoEx.CodePageName;
 end;
 result:=1;
end;

function MakeLangID(P,S:Word):Word;
begin
 result:=(S shl 10) or P;
end;

function AnsiStringEscape(const Input:ansistring):ansistring;
var Counter:longint;
    c:ansichar;
begin
 result:='''';
 for Counter:=1 to length(Input) do begin
  C:=Input[Counter];
  case C of
   'A'..'Z','a'..'z',' ','0'..'9','_','-','(',')','[',']','{','}','!','?','&','$','\','/','=','+','"','%','#','*',':',';',',','.':begin
    result:=result+c;
   end;
   else begin
    result:=result+'''#$'+IntToHex(byte(C),2)+'''';
   end;
  end;
 end;
 result:=result+'''';
end;

begin
 SetThreadLocale(MAKELONG(LANG_ENGLISH,SUBLANG_DEFAULT));
 SetThreadUILanguage(MAKELANGID(LANG_ENGLISH,SUBLANG_DEFAULT));
 FillChar(supported,sizeof(supported),#0);
 FillChar(CodePageNames,sizeof(CodePageNames),#0);
 FillChar(SubSubPages,sizeof(SubSubPages),#0);
 FillChar(SubPages,sizeof(SubPages),#0);
 CoInitialize(nil);
 EnumSystemCodePages(@CpEnumProc,CP_SUPPORTED);
 s:='';
 for i:=1 to 256 do begin
  s:=s+AnsiChar(byte(i-1));
 end;
 assignfile(t,'PUCUCodePages.inc');
 rewrite(t);
 writeln(t,'type PPUCUCharSetCodePage=^TPUCUCharSetCodePage;');
 writeln(t,'     TPUCUCharSetCodePage=array[0..255] of longword;');
 writeln(t,'     PPUCUCharSetSubSubCodePages=^TPUCUCharSetSubSubCodePages;');
 writeln(t,'     TPUCUCharSetSubSubCodePages=array[0..15] of PPUCUCharSetCodePage;');
 writeln(t,'     PPUCUCharSetSubCodePages=^TPUCUCharSetSubCodePages;');
 writeln(t,'     TPUCUCharSetSubCodePages=array[0..15] of PPUCUCharSetSubSubCodePages;');
 writeln(t,'     PPUCUCharSetCodePages=^TPUCUCharSetCodePages;');
 writeln(t,'     TPUCUCharSetCodePages=array[0..255] of PPUCUCharSetSubCodePages;');
 writeln(t,'     PPUCUCharSetSubSubCodePageNames=^TPUCUCharSetSubSubCodePageNames;');
 writeln(t,'     TPUCUCharSetSubSubCodePageNames=array[0..15] of ansistring;');
 writeln(t,'     PPUCUCharSetSubCodePageNames=^TPUCUCharSetSubCodePageNames;');
 writeln(t,'     TPUCUCharSetSubCodePageNames=array[0..15] of PPUCUCharSetSubSubCodePageNames;');
 writeln(t,'     PPUCUCharSetCodePageNames=^TPUCUCharSetCodePageNames;');
 writeln(t,'     TPUCUCharSetCodePageNames=array[0..255] of PPUCUCharSetSubCodePageNames;');
 SetLength(w,1024);
 for cp:=0 to 65535 do begin
  u[cp]:=false;
  if (cp<>65001) and supported[cp] then begin
   SubSubPages[cp shr 4]:=true;
   SubPages[cp shr 8]:=true;
   i:=MultiByteToWideChar(cp,0,PAnsiChar(s),256,PWideChar(w),1024);
   if i=256 then begin
    u[cp]:=true;
    write(t,'const PUCUCharSetCodePage',cp,':TPUCUCharSetCodePage=(');
    writeln(t);
    j:=1;
    for i:=1 to 256 do begin
     cu:=Word(WideChar(w[j]));
     inc(j);
     if (j<=length(w)) and ((cu and $fc00)=$d800) and ((Word(WideChar(w[j])) and $fc00)=$dc00) then begin
      cu:=((longword(cu and $3ff) shl 10) or longword(Word(WideChar(w[j])) and $3ff))+$10000;
      inc(j);
     end;
     write(t,'$',LowerCase(IntToHex(cu,8)));
     if i<>256 then begin
      write(t,',');
     end else begin
      write(t,');');
     end;
     if (i and 7)=0 then begin
      writeln(t);
     end;
    end;
   end;
  end;
 end;
 for i:=0 to (256*16)-1 do begin
  if SubSubPages[i] then begin
   writeln(t,'const PUCUCharSetSubSubCodePage',i,':TPUCUCharSetSubSubCodePages=(');
   for cp:=(i*16) to (i*16)+15 do begin
    if u[cp] then begin
     write(t,'@PUCUCharSetCodePage',cp);
    end else begin
     write(t,'nil');
    end;
    if cp<>((i*16)+15) then begin
     write(t,',');
    end;
    writeln(t);
   end;
   writeln(t,');');
  end;
 end;
 for i:=0 to 255 do begin
  if SubPages[i] then begin
   writeln(t,'const PUCUCharSetCodeSubPage',i,':TPUCUCharSetSubCodePages=(');
   for cp:=(i*16) to (i*16)+15 do begin
    if SubSubPages[cp] then begin
     write(t,'@PUCUCharSetSubSubCodePage',cp);
    end else begin
     write(t,'nil');
    end;
    if cp<>((i*16)+15) then begin
     write(t,',');
    end;
    writeln(t);
   end;
   writeln(t,');');
  end;
 end;
 writeln(t,'const PUCUCharSetCodePages:TPUCUCharSetCodePages=(');
 for i:=0 to 256-1 do begin
  if SubPages[i] then begin
   write(t,'@PUCUCharSetCodeSubPage',i);
  end else begin
   write(t,'nil');
  end;
  if i<>255 then begin
   write(t,',');
  end;
  writeln(t);
 end;
 writeln(t,');');
{writeln(t,'const PUCUCharSetCodePageNames:TPUCUCharSetCodePageNames=(');
 for cp:=0 to 65535 do begin
  if u[cp] then begin
   write(t,AnsiStringEscape(CodePageNames[cp]));
  end else begin
   write(t,'''''');
  end;
  if cp<>65535 then begin
   write(t,',');
  end;
  writeln(t);
 end;
 writeln(t,');');}
 for i:=0 to (256*16)-1 do begin
  if SubSubPages[i] then begin
   writeln(t,'const PUCUCharSetSubSubCodePageNames',i,':TPUCUCharSetSubSubCodePageNames=(');
   for cp:=(i*16) to (i*16)+15 do begin
    if u[cp] then begin
     write(t,AnsiStringEscape(CodePageNames[cp]));
    end else begin
     write(t,'''''');
    end;
    if cp<>((i*16)+15) then begin
     write(t,',');
    end;
    writeln(t);
   end;
   writeln(t,');');
  end;
 end;
 for i:=0 to 255 do begin
  if SubPages[i] then begin
   writeln(t,'const PUCUCharSetCodeSubPageNames',i,':TPUCUCharSetSubCodePageNames=(');
   for cp:=(i*16) to (i*16)+15 do begin
    if SubSubPages[cp] then begin
     write(t,'@PUCUCharSetSubSubCodePageNames',cp);
    end else begin
     write(t,'nil');
    end;
    if cp<>((i*16)+15) then begin
     write(t,',');
    end;
    writeln(t);
   end;
   writeln(t,');');
  end;
 end;
 writeln(t,'const PUCUCharSetCodePageNames:TPUCUCharSetCodePageNames=(');
 for i:=0 to 256-1 do begin
  if SubPages[i] then begin
   write(t,'@PUCUCharSetCodeSubPageNames',i);
  end else begin
   write(t,'nil');
  end;
  if i<>255 then begin
   write(t,',');
  end;
  writeln(t);
 end;
 writeln(t,');');
 closefile(t);
end.
