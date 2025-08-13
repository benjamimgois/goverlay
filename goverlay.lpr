program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit, blacklistUnit;




{$R *.res}



begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='Goverlay';
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TblacklistForm, blacklistForm);
  Application.Run;
end.

