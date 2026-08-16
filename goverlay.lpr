program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cmem,
  cthreads, // <--- Agora será sempre incluído no Linux
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, goverlay_i18n, overlayunit, aboutunit, blacklistUnit, howto;




{$R *.res}



{$if defined(CPUAARCH64) and defined(LINUX)}
procedure Dummy_libc_csu_init; cdecl; public name '__libc_csu_init';
begin
end;

procedure Dummy_libc_csu_fini; cdecl; public name '__libc_csu_fini';
begin
end;
{$endif}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='Goverlay';
  // Has to happen before the forms below are created, see goverlay_i18n.
  InitTranslation;
  Application.Initialize;
  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TblacklistForm, blacklistForm);
  Application.CreateForm(ThowtoForm, howtoForm);
  Application.Run;
end.

