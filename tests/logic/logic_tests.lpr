program logic_tests;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils,
  fpcunit, testregistry, fpcunitreport, plaintestreport,
  test_isolation,
  logic_test_cases;

var
  SuiteOk: Boolean = False;

procedure RunSuite;
var
  Results: TTestResult;
  Writer: TPlainResultsWriter;
begin
  Results := TTestResult.Create;
  Writer := TPlainResultsWriter.Create(nil);
  try
    GetTestRegistry.Run(Results);
    Writer.WriteHeader;
    Writer.WriteResult(Results);
    SuiteOk := (Results.NumberOfErrors = 0) and (Results.NumberOfFailures = 0);
    WriteLn(Format('[logic_tests] %d failures, %d errors',
      [Results.NumberOfFailures, Results.NumberOfErrors]));
  finally
    Writer.Free;
    Results.Free;
  end;
end;

begin
  EnsureIsolatedEnvironment('');
  RunSuite;
  CleanupIsolatedEnvironment(SuiteOk);

  if not SuiteOk then
    Halt(1);
end.
