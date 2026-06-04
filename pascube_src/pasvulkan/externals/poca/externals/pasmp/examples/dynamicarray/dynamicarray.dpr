program dynamicarray;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef Win32}
 {$define Windows}
{$endif}
{$ifdef Win64}
 {$define Windows}
{$endif}
{$ifdef WinCE}
 {$define Windows}
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

var TestDynamicArray:TPasMPDynamicArray;
    a,b:longint;
begin

 TestDynamicArray:=TPasMPDynamicArray.Create(SizeOf(longint));
 try

  a:=64;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=128;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=32;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=16;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=64;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=128;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=32;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=16;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=64;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=128;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=32;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=16;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=64;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=128;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=32;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  a:=16;
  TestDynamicArray.Push(a);
  writeln(TestDynamicArray.Size);
  for a:=0 to TestDynamicArray.Size-1 do begin
   if TestDynamicArray.GetItem(a,b) then begin
    write(b,' ');
   end;
  end;
  writeln;
  while TestDynamicArray.Pop(b) do begin
   write(b,' ');
  end;
  writeln;
  TestDynamicArray.Size:=1;
  a:=42;
  if TestDynamicArray.SetItem(0,a) then begin
   if TestDynamicArray.GetItem(0,b) then begin
    writeln(b);
   end;
  end;
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Clear;
  writeln(TestDynamicArray.Size);
 finally
  TestDynamicArray.Free;
 end;

 readln;
end.
