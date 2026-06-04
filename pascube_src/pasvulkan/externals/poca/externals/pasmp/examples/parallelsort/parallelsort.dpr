program parallelsort;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$APPTYPE CONSOLE}

uses
{$ifdef unix}
  cthreads,
{$endif}
  SysUtils,
  PasMP in '..\..\src\PasMP.pas';

{$if defined(win32) or defined(win64) or defined(windows)}
procedure Sleep(ms:longword); stdcall; external 'kernel32.dll' name 'Sleep';
{$ifend}

const N=65536;

var DataArray:array[0..N-1] of longint;

function CompareInteger(const a,b:pointer):longint;
begin
 if longint(a^)<longint(b^) then begin
  result:=-1;
 end else if longint(a^)>longint(b^) then begin
  result:=1;
 end else begin
  result:=0;
 end;
end;

var Index,XorShift:longint;
    OK:boolean;
begin

 TPasMP.CreateGlobalInstance;

 XorShift:=$312ca04f;
 for Index:=0 to N-1 do begin
  XorShift:=XorShift xor (XorShift shl 13);
  XorShift:=XorShift xor (XorShift shr 17);
  XorShift:=XorShift xor (XorShift shl 5);
  DataArray[Index]:=XorShift;
 end;

 GlobalPasMP.Invoke(GlobalPasMP.ParallelDirectIntroSort(@DataArray[0],0,N-1,SizeOf(longint),CompareInteger,16,8)); // <= Invoke = Run+Wait+Release into a single call

 OK:=true;
 for Index:=0 to N-2 do begin
  if DataArray[Index]>DataArray[Index+1] then begin
   OK:=false;
   break;
  end;
 end;

 if OK then begin
  writeln('IntroSort successfully');
 end else begin
  writeln('IntroSort failed');
 end;

 XorShift:=$704f312c;
 for Index:=0 to N-1 do begin
  XorShift:=XorShift xor (XorShift shl 13);
  XorShift:=XorShift xor (XorShift shr 17);
  XorShift:=XorShift xor (XorShift shl 5);
  DataArray[Index]:=XorShift;
 end;

 GlobalPasMP.Invoke(GlobalPasMP.ParallelDirectMergeSort(@DataArray[0],0,N-1,SizeOf(longint),CompareInteger,16,8)); // <= Invoke = Run+Wait+Release into a single call

 OK:=true;
 for Index:=0 to N-2 do begin
  if DataArray[Index]>DataArray[Index+1] then begin
   OK:=false;
   break;
  end;
 end;

 if OK then begin
  writeln('MergeSort successfully');
 end else begin
  writeln('MergeSort failed');
 end;

 readln;

end.
