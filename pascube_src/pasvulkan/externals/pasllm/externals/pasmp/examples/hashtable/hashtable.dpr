program hashtable;
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

var TestHashTable:TPasMPHashTable;
    TestStringHashTable:TPasMPStringHashTable;
    TestStringStringHashTable:TPasMPStringStringHashTable;
    a,b:longint;
    s:string;
begin

 TestHashTable:=TPasMPHashTable.Create(SizeOf(longint),SizeOf(longint));
 try
  a:=4;
  b:=2;
  TestHashTable.SetKeyValue(a,b);
  a:=2;
  b:=4;
  TestHashTable.SetKeyValue(a,b);
  a:=3;
  b:=8;
  TestHashTable.SetKeyValue(a,b);
  a:=42;
  b:=23;
  TestHashTable.SetKeyValue(a,b);
  a:=23;
  b:=42;
  TestHashTable.SetKeyValue(a,b);
  a:=23;
  if TestHashTable.GetKeyValue(a,b) then begin
   writeln(b);
  end;
  TestHashTable.DeleteKey(a);
  if TestHashTable.GetKeyValue(a,b) then begin
   writeln(b);
  end;
 finally
  TestHashTable.Free;
 end;

 writeln;

 TestStringHashTable:=TPasMPStringHashTable.Create(SizeOf(longint));
 try
  b:=23;
  TestStringHashTable.SetKeyValue('bla',b);
  b:=42;
  TestStringHashTable.SetKeyValue('blup',b);
  b:=64;
  TestStringHashTable.SetKeyValue('piep',b);
  if TestStringHashTable.GetKeyValue('blup',b) then begin
   writeln(b);
  end;
  TestStringHashTable.DeleteKey('blup');
  if TestStringHashTable.GetKeyValue('blup',b) then begin
   writeln(b);
  end;
 finally
  TestStringHashTable.Free;
 end;

 writeln;

 TestStringHashTable:=TPasMPStringHashTable.Create(SizeOf(longint));
 try
  b:=23;
  TestStringHashTable.SetKeyValue('bla',b);
  b:=42;
  TestStringHashTable.SetKeyValue('blup',b);
  b:=64;
  TestStringHashTable.SetKeyValue('piep',b);
  if TestStringHashTable.GetKeyValue('blup',b) then begin
   writeln(b);
  end;
  TestStringHashTable.DeleteKey('blup');
  if TestStringHashTable.GetKeyValue('blup',b) then begin
   writeln(b);
  end;
 finally
  TestStringHashTable.Free;
 end;

 writeln;

 TestStringStringHashTable:=TPasMPStringStringHashTable.Create;
 try
  TestStringStringHashTable.SetKeyValue('bla','23!');
  TestStringStringHashTable.SetKeyValue('blup','42?');
  TestStringStringHashTable.SetKeyValue('piep','64.');
  if TestStringStringHashTable.GetKeyValue('blup',s) then begin
   writeln(s);
  end;
  TestStringStringHashTable.DeleteKey('blup');
  if TestStringStringHashTable.GetKeyValue('blup',s) then begin
   writeln(s);
  end;
 finally
  TestStringHashTable.Free;
 end;

 readln;
end.
