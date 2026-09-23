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

type
  TConsoleListener = class(TInterfacedObject, ITestListener)
  public
    procedure AddFailure(ATest: TTest; AFailure: TTestFailure);
    procedure AddError(ATest: TTest; AError: TTestFailure);
    procedure StartTest(ATest: TTest);
    procedure EndTest(ATest: TTest);
    procedure StartTestSuite(ATestSuite: TTestSuite);
    procedure EndTestSuite(ATestSuite: TTestSuite);
  end;

procedure TConsoleListener.AddFailure(ATest: TTest; AFailure: TTestFailure);
begin
  WriteLn(' [FAIL]');
  Flush(Output);
end;

procedure TConsoleListener.AddError(ATest: TTest; AError: TTestFailure);
begin
  WriteLn(' [ERROR]');
  Flush(Output);
end;

procedure TConsoleListener.StartTest(ATest: TTest);
begin
  Write('[RUNNING] ', ATest.TestName, '...');
  Flush(Output);
end;

procedure TConsoleListener.EndTest(ATest: TTest);
begin
  WriteLn(' OK');
  Flush(Output);
end;

procedure TConsoleListener.StartTestSuite(ATestSuite: TTestSuite); begin end;
procedure TConsoleListener.EndTestSuite(ATestSuite: TTestSuite); begin end;

var
  SuiteOk: Boolean = False;

procedure RunSuite;
var
  Results: TTestResult;
  Writer: TPlainResultsWriter;
  Listener: ITestListener;
begin
  Results := TTestResult.Create;
  Writer := TPlainResultsWriter.Create(nil);
  Listener := TConsoleListener.Create;
  try
    Results.AddListener(Listener);
    GetTestRegistry.Run(Results);
    Writer.WriteHeader;
    Writer.WriteResult(Results);
    SuiteOk := (Results.NumberOfErrors = 0) and (Results.NumberOfFailures = 0);
    WriteLn(Format('[gui_tests] %d failures, %d errors',
      [Results.NumberOfFailures, Results.NumberOfErrors]));
  finally
    Results.RemoveListener(Listener);
    Listener := nil;
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
    Halt(1)
  else
    Halt(0);
end.
