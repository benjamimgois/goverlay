program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit, crosshairUnit, logpathUnit,
  lazopenglcontext;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='GOverlay';
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TlogpathForm, logpathForm);
  Application.Run;
end.

