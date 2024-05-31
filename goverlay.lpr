program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit;




{$R *.res}



begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='Goverlay';
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.Run;
end.

