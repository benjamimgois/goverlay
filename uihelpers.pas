unit uihelpers;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Buttons, Graphics,
  constants;

/// <summary>Apply modern typography recursively to a control and its children.</summary>
procedure ApplyModernTypography(AControl: TWinControl);

/// <summary>Apply modern spacing (margins, padding) recursively.</summary>
procedure ApplyModernSpacing(AControl: TWinControl);

/// <summary>Add Unicode icons to main action buttons on a form.</summary>
procedure ApplyIconsToButtons(AForm: TForm);

/// <summary>Apply Radeon red theme to a form and its immediate controls.</summary>
procedure ApplyRadeonTheme(AForm: TForm);

implementation

procedure ApplyModernTypography(AControl: TWinControl);
var
  i: Integer;
begin
  AControl.Font.Name := FONT_NAME_PRIMARY;
  AControl.Font.Size := FONT_SIZE_BODY;
  AControl.Font.Quality := fqAntialiased;

  for i := 0 to AControl.ControlCount - 1 do
  begin
    if AControl.Controls[i] is TGroupBox then
    begin
      TGroupBox(AControl.Controls[i]).Font.Size := FONT_SIZE_TITLE;
      TGroupBox(AControl.Controls[i]).Font.Style := [fsBold];
      TGroupBox(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;

    if AControl.Controls[i] is TButton then
    begin
      TButton(AControl.Controls[i]).Font.Size := FONT_SIZE_BODY;
      TButton(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;

    if AControl.Controls[i] is TLabel then
    begin
      TLabel(AControl.Controls[i]).Font.Size := FONT_SIZE_BODY;
      TLabel(AControl.Controls[i]).Font.Quality := fqAntialiased;
    end;

    if AControl.Controls[i] is TWinControl then
      ApplyModernTypography(TWinControl(AControl.Controls[i]));
  end;
end;

procedure ApplyModernSpacing(AControl: TWinControl);
var
  i: Integer;
  Checkbox: TCheckBox;
  PrevCheckbox: TCheckBox;
begin
  for i := 0 to AControl.ControlCount - 1 do
  begin
    if AControl.Controls[i] is TGroupBox then
    begin
      with TGroupBox(AControl.Controls[i]) do
      begin
        BorderSpacing.Left   := MARGIN_MEDIUM;
        BorderSpacing.Top    := MARGIN_MEDIUM;
        BorderSpacing.Right  := MARGIN_MEDIUM;
        BorderSpacing.Bottom := MARGIN_MEDIUM;
      end;
    end;

    if AControl.Controls[i] is TCheckBox then
    begin
      Checkbox := TCheckBox(AControl.Controls[i]);
      if i > 0 then
      begin
        if AControl.Controls[i-1] is TCheckBox then
        begin
          PrevCheckbox := TCheckBox(AControl.Controls[i-1]);
          if Checkbox.Top - (PrevCheckbox.Top + PrevCheckbox.Height) < MARGIN_MEDIUM then
            Checkbox.Top := PrevCheckbox.Top + PrevCheckbox.Height + MARGIN_MEDIUM;
        end;
      end;
    end;

    if AControl.Controls[i] is TButton then
    begin
      with TButton(AControl.Controls[i]) do
      begin
        BorderSpacing.Around := MARGIN_SMALL;
      end;
    end;

    if AControl.Controls[i] is TWinControl then
      ApplyModernSpacing(TWinControl(AControl.Controls[i]));
  end;
end;

procedure ApplyIconsToButtons(AForm: TForm);
begin
  if Assigned(AForm.FindComponent('gupdateBitBtn')) then
    TBitBtn(AForm.FindComponent('gupdateBitBtn')).Caption := '🔄 ' + 'Update';
end;

procedure ApplyRadeonTheme(AForm: TForm);
var
  i: Integer;
begin
  AForm.Color := clRADEON;
  for i := 0 to AForm.ControlCount - 1 do
  begin
    if AForm.Controls[i] is TButton then
    begin
      TButton(AForm.Controls[i]).Font.Color := clWhite;
      TButton(AForm.Controls[i]).Color     := clRADEON;
    end
    else if AForm.Controls[i] is TLabel then
      TLabel(AForm.Controls[i]).Font.Color := clWhite;
  end;
end;

end.
