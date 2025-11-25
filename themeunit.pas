unit themeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, StdCtrls, ExtCtrls, Forms, CheckLst, Dialogs;

const
  // Dark theme colors (BGR format)
  DarkBackgroundColor = $0045403A;  // Dark panel color
  DarkTextColor = clWhite;          // Light text color

/// <summary>
/// Recursively applies dark theme colors to all controls in a form
/// </summary>
/// <param name="AControl">The parent control to apply dark theme to</param>
procedure ApplyDarkTheme(AControl: TWinControl);

/// <summary>
/// Centers a form on the screen
/// </summary>
/// <param name="AForm">The form to center</param>
procedure CenterFormOnScreen(AForm: TForm);

implementation

procedure ApplyDarkTheme(AControl: TWinControl);
var
  i: Integer;
  ctrl: TControl;
begin
  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    if ctrl is TMemo then
      TMemo(ctrl).Font.Color := DarkTextColor
    else if ctrl is TLabel then
      TLabel(ctrl).Font.Color := DarkTextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := DarkTextColor
    else if ctrl is TGroupBox then
    begin
      TGroupBox(ctrl).Font.Color := DarkTextColor;
      TGroupBox(ctrl).Color := DarkBackgroundColor;
      if TGroupBox(ctrl) is TWinControl then
        ApplyDarkTheme(TWinControl(ctrl));
    end
    else if ctrl is TCheckGroup then
    begin
      TCheckGroup(ctrl).Font.Color := DarkTextColor;
      TCheckGroup(ctrl).Color := DarkBackgroundColor;
      if TCheckGroup(ctrl) is TWinControl then
        ApplyDarkTheme(TWinControl(ctrl));
    end
    else if ctrl is TRadioGroup then
    begin
      TRadioGroup(ctrl).Font.Color := DarkTextColor;
      TRadioGroup(ctrl).Color := DarkBackgroundColor;
    end
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := DarkBackgroundColor
    else if ctrl is TWinControl then
      ApplyDarkTheme(TWinControl(ctrl));
  end;
end;

procedure CenterFormOnScreen(AForm: TForm);
begin
  AForm.Left := (Screen.Width - AForm.Width) div 2;
  AForm.Top := (Screen.Height - AForm.Height) div 2;
end;

end.
