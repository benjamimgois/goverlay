program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads, // <--- Agora será sempre incluído no Linux
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, overlayunit, aboutunit, blacklistUnit, howto, themeunit, urlutils;




{$R *.res}



begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='Goverlay';
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TblacklistForm, blacklistForm);
  Application.CreateForm(ThowtoForm, howtoForm);
  Application.Run;
end.

