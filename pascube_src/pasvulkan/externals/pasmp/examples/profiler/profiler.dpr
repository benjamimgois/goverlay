program profiler;

uses
  Forms,
  UnitFormMain in 'UnitFormMain.pas' {FormMain},
  PasMP in '..\..\src\PasMP.pas',
  PasMPProfilerHistoryView in '..\..\src\PasMPProfilerHistoryView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
