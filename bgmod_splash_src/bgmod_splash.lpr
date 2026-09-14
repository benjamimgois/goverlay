program bgmod_splash;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  Classes,
  SysUtils,
  splash_form;

var
  Splash: TSplashForm;
  i: Integer;
  Arg, Key, Val: string;
  EqPos: Integer;
begin
  Application.Scaled := True;
  Application.Initialize;

  Splash := TSplashForm.CreateNew(nil);

  for i := 1 to ParamCount do
  begin
    Arg := ParamStr(i);
    if Pos('--', Arg) = 1 then
    begin
      EqPos := Pos('=', Arg);
      if EqPos > 0 then
      begin
        Key := LowerCase(Copy(Arg, 3, EqPos - 3));
        Val := Copy(Arg, EqPos + 1, MaxInt);
        if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] = Val[1]) then
          Val := Copy(Val, 2, Length(Val) - 2);

        if Key = 'game' then
          Splash.GameTitle := Val
        else if Key = 'item' then
          Splash.Items.Add(Val)
        else if Key = 'duration' then
          Splash.DurationMs := StrToIntDef(Val, 2500);
      end;
    end;
  end;

  Splash.InitAndReflow;
  Splash.Show;
  Application.Run;
  Splash.Free;
end.
