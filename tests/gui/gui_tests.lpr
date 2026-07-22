program gui_tests;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // LCL widgetset (qt6, offscreen via env)
  Forms, SysUtils,
  fpcunit, testregistry, fpcunitreport, plaintestreport,
  test_isolation,
  overlayunit,
  gui_test_cases;

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
    WriteLn(Format('[gui_tests] %d failures, %d errors',
      [Results.NumberOfFailures, Results.NumberOfErrors]));
  finally
    Writer.Free;
    Results.Free;
  end;
end;

var
  i: Integer;
begin
  EnsureIsolatedEnvironment('nvidia');

  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Title := 'goverlay-gui-tests';
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);

  // Show offscreen so FormShow-time initialization runs, then pump queued
  // async calls until the event queue settles.
  goverlayform.Show;
  for i := 1 to 40 do
  begin
    Application.ProcessMessages;
    Sleep(25);
  end;

  RunSuite;
  CleanupIsolatedEnvironment(SuiteOk);

  if not SuiteOk then
    Halt(1);
end.
