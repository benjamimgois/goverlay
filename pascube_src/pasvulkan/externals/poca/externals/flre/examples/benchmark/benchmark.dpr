(*
** You do need the mtent12.txt from
** http://www.gutenberg.org/files/3200/old/mtent12.zip for this benchmark
**)
program benchmark;
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
{$else}
 {$realcompatibility off}
 {$localsymbols on}
 {$define LITTLE_ENDIAN}
 {$ifndef cpu64}
  {$define cpu32}
 {$endif}
 {$define HAS_TYPE_EXTENDED}
 {$define HAS_TYPE_DOUBLE}
 {$define HAS_TYPE_SINGLE}
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
{$apptype console}

uses
  SysUtils,
  Classes,
  FLRE in '..\..\src\FLRE.pas',
  PUCU in '..\..\src\PUCU.pas',
  BeRoHighResolutionTimer in '..\common\BeRoHighResolutionTimer.pas';

const BenchmarkCount=1;

      BenchmarkPatterns:array[0..14] of TFLRERawByteString=('Twain',
                                                            '(?i)Twain',
                                                            '[a-z]shing',
                                                            'Huck[a-zA-Z]+|Saw[a-zA-Z]+',
                                                            '\b\w+nn\b',
                                                            '[a-q][^u-z]{13}x',
                                                            'Tom|Sawyer|Huckleberry|Finn',
                                                            '(?i)Tom|Sawyer|Huckleberry|Finn',
                                                            '.{0,2}(Tom|Sawyer|Huckleberry|Finn)',
                                                            '.{2,4}(Tom|Sawyer|Huckleberry|Finn)',
                                                            'Tom.{10,25}river|river.{10,25}Tom',
                                                            '[a-zA-Z]+ing',
                                                            '\s[a-zA-Z]{0,12}ing\s',
                                                            '([A-Za-z]awyer|[A-Za-z]inn)\s',
                                                            '["''][^"'']{0,30}[?!\.]["'']');

{$ifdef windows}
function IsDebuggerPresent:boolean; stdcall; external 'kernel32.dll' name 'IsDebuggerPresent';
{$endif}

var i,j:integer;
    s:TFLRERawByteString;
    FileStream:TFileStream;
    FLREInstance:TFLRE;
    StartTime,EndTime:int64;
    Captures:TFLREMultiCaptures;
    HighResolutionTimer:THighResolutionTimer;
begin
 HighResolutionTimer:=THighResolutionTimer.Create;
 try

  FileStream:=TFileStream.Create('mtent12.txt',fmOpenRead);
  try
   SetLength(s,FileStream.Size);
   FileStream.Read(s[1],FileStream.Size);
  finally
   FileStream.Free;
  end;

  writeln(' ':50,'      Time     | Match count');

  writeln('==============================================================================');
  writeln('FLRE:');
  for i:=low(BenchmarkPatterns) to high(BenchmarkPatterns) do begin
   try
    FLREInstance:=TFLRE.Create(BenchmarkPatterns[i],[]);
    FLREInstance.MaximalDFAStates:=65536;
    try
     write('/'+BenchmarkPatterns[i]+'/ : ':50,'Please wait... ');
     StartTime:=HighResolutionTimer.GetTime;
     for j:=1 to BenchmarkCount do begin
      FLREInstance.MatchAll(s,Captures);
     end;
     EndTime:=HighResolutionTimer.GetTime;
     write(#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8);
     writeln((HighResolutionTimer.ToMicroSeconds(EndTime-StartTime) div BenchmarkCount)/1000.0:11:2,' ms |',length(Captures):12);
//   writeln(FLREInstance.DumpRegularExpression);
    finally
     SetLength(Captures,0);
     FLREInstance.Free;
    end;
   except
    on e:Exception do begin
     writeln(e.Message);
    end;
   end;
  end;

 finally
  HighResolutionTimer.Free;
 end;
 writeln;
 writeln('Done!');
 writeln;
{$ifdef fpc}
 if IsDebuggerPresent then begin
  readln;
 end;
{$else}
 if DebugHook<>0 then begin
  readln;
 end;
{$endif}
end.


