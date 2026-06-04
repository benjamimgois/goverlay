unit UnitSplitTests;
{$ifdef fpc}
 {$mode delphi}
{$endif}

interface

uses SysUtils,UnitTestGlobals,FLRE;

procedure ExecuteSplitTests;

implementation

procedure ExecuteSplitTests;
var FLREInstance:TFLRE;
    SplittedStrings:TFLREStrings;
begin

 FLREInstance:=TFLRE.Create('/,/');
 try
  SplittedStrings:=nil;
  try
   CheckTestResult(FLREInstance.Split('a1,b2,c3',SplittedStrings) and
                   (length(SplittedStrings)=3) and
                   (SplittedStrings[0]='a1') and
                   (SplittedStrings[1]='b2') and
                   (SplittedStrings[2]='c3'),
                   'Split(''a1,b2,c3'')');
  finally
   SplittedStrings:=nil;
  end;
 finally
  FreeAndNil(FLREInstance);
 end;

 FLREInstance:=TFLRE.Create('/,/');
 try
  SplittedStrings:=nil;
  try
   CheckTestResult(FLREInstance.PtrSplit(PAnsiChar('a1,b2,c3'),8,SplittedStrings,0,-1,true) and
                   (length(SplittedStrings)=3) and
                   (SplittedStrings[0]='a1') and
                   (SplittedStrings[1]='b2') and
                   (SplittedStrings[2]='c3'),
                   'Split(''a1,b2,c3'')');
  finally
   SplittedStrings:=nil;
  end;
 finally
  FreeAndNil(FLREInstance);
 end;

 FLREInstance:=TFLRE.Create('/,/');
 try
  SplittedStrings:=nil;
  try
   CheckTestResult(FLREInstance.PtrSplit(PAnsiChar('a1,b2,c3'),8,SplittedStrings,0,-1,true) and
                   (length(SplittedStrings)=3) and
                   (SplittedStrings[0]='a1') and
                   (SplittedStrings[1]='b2') and
                   (SplittedStrings[2]='c3'),
                   'Split(''a1,b2,c3'')');
  finally
   SplittedStrings:=nil;
  end;
 finally
  FreeAndNil(FLREInstance);
 end;

end;

end.

