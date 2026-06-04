program FLRETest;
{$ifdef fpc}
 {$mode delphi}
{$endif}
{$ifdef win32}
 {$apptype console}
{$endif}
{$ifdef win64}
 {$apptype console}
{$endif}

uses
  Classes,
  FLRE in '..\FLRE.pas',
  PUCU in '..\PUCU.pas',
  UnitTestGlobals in 'UnitTestGlobals.pas',
  UnitSearchTests in 'UnitSearchTests.pas',
  UnitReplaceTests in 'UnitReplaceTests.pas',
  UnitSplitTests in 'UnitSplitTests.pas';

{procedure test;
var FLREInstance:TFLRE;
begin
//FLREInstance:=TFLRE.Create('(31|32|33|34|35|36|41|42|43|44|45|46)a*a*b*(37|47|37|27)',[]);
 FLREInstance:=TFLRE.Create('^(31|32|33|34|35|36|37|38|39)(13|23|33|43|53|63|73|83|93|3)$',[]);
 try
  Writeln(FLREInstance.DumpRegularExpression);
  Writeln(FLREInstance.Test('3713'));
  Writeln(FLREInstance.Test('3963'));
  Writeln(FLREInstance.Test('3243'));
  Writeln(FLREInstance.Test('3823'));
 finally
  FLREInstance.Free;
 end;
 readln;
 halt;
end;}

begin
{TFLRE.Create('A+', []).Test('');
 readln;
 exit;{}
//test;
 ExecuteSearchTests;
 ExecuteReplaceTests;
 ExecuteSplitTests;
//readln;
{$ifndef fpc}
 if DebugHook<>0 then begin
  readln;
 end;
{$endif}
end.
