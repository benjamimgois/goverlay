program goverlay;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cmem,
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms, SysUtils, DefaultTranslator, goverlay_i18n, overlayunit, aboutunit, blacklistUnit, howto, pasplot_form;

{$R *.res}



{$if defined(CPUAARCH64) and defined(LINUX)}
procedure Dummy_libc_csu_init; cdecl; public name '__libc_csu_init';
begin
end;

procedure Dummy_libc_csu_fini; cdecl; public name '__libc_csu_fini';
begin
end;
{$endif}

var
  I: Integer;
  LaunchPasPlot: Boolean;
  PasPlotGameArg: string;
begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Title:='Goverlay';
  // Has to happen before the forms below are created, see goverlay_i18n.
  InitTranslation;
  Application.Initialize;

  LaunchPasPlot := False;
  PasPlotGameArg := '';
  for I := 1 to ParamCount do
  begin
    if SameText(ParamStr(I), '--pasplot') or SameText(ParamStr(I), '-pasplot') or
       SameText(ParamStr(I), '--gplot') or SameText(ParamStr(I), '-gplot') then
    begin
      LaunchPasPlot := True;
      if (I < ParamCount) and (Copy(ParamStr(I + 1), 1, 1) <> '-') then
        PasPlotGameArg := ParamStr(I + 1);
      Break;
    end;
  end;

  if LaunchPasPlot then
  begin
    ShowPasPlotDialog(nil, PasPlotGameArg);
    Exit;
  end;

  Application.CreateForm(Tgoverlayform, goverlayform);
  Application.CreateForm(TaboutForm, aboutForm);
  Application.CreateForm(TblacklistForm, blacklistForm);
  Application.CreateForm(ThowtoForm, howtoForm);
  Application.Run;
end.

