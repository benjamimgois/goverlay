program pasllmappvcl;

uses
  Vcl.Forms,
  UnitFormMain in 'UnitFormMain.pas' {FormMain},
  PasLLM in '..\PasLLM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
