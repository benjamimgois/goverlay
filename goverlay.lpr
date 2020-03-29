program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit, crosshairUnit, hudbackgroundUnit, logpathUnit
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TcrosshairsizeForm, crosshairsizeForm);
  Application.CreateForm(ThudbackgroundForm, hudbackgroundForm);
  Application.CreateForm(TlogpathForm, logpathForm);
  Application.Run;
end.

