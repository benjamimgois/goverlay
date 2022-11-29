program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit, crosshairUnit, hudbackgroundUnit, logpathUnit,
  lazopenglcontext, fullscreenUnit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='GOverlay';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TcrosshairsizeForm, crosshairsizeForm);
  Application.CreateForm(ThudbackgroundForm, hudbackgroundForm);
  Application.CreateForm(TlogpathForm, logpathForm);
  Application.CreateForm(TfullscreenForm, fullscreenForm);
  Application.Run;
end.

