program typeddynamicarray;
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

var TestDynamicArray:TPasMPDynamicArray<TPasMPInt32>;
    TestDynamicArray2:TPasMPDynamicArray<string>;
    a,b:longint;
begin

 TestDynamicArray:=TPasMPDynamicArray<TPasMPInt32>.Create;
 try

  TestDynamicArray.Push(64);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(128);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(32);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(16);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(64);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(128);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(32);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(16);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(64);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(128);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(32);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(16);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(64);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(128);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(32);
  writeln(TestDynamicArray.Size);
  TestDynamicArray.Push(16);
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
  if TestDynamicArray.SetItem(0,42) then begin
   if TestDynamicArray.GetItem(0,b) then begin
    writeln(b);
   end;
  end;

  writeln(TestDynamicArray[0]);
  TestDynamicArray[0]:=23;
  writeln(TestDynamicArray[0]);

  writeln(TestDynamicArray.Size);

  TestDynamicArray.Clear;
  writeln(TestDynamicArray.Size);

 finally
  TestDynamicArray.Free;
 end;

 writeln;
 TestDynamicArray2:=TPasMPDynamicArray<string>.Create;
 try
  TestDynamicArray2.Push('Hello');
  TestDynamicArray2.Push('world');
  writeln(TestDynamicArray2[0]+' '+TestDynamicArray2[1]);
  TestDynamicArray2.Size:=3;
  TestDynamicArray2[2]:='!';
  writeln(TestDynamicArray2[0]+' '+TestDynamicArray2[1]+TestDynamicArray2[2]);
 finally
  TestDynamicArray2.Free;
 end;

 readln;
end.
