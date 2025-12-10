unit themeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, StdCtrls, ExtCtrls, Forms, CheckLst, Dialogs, IniFiles, Buttons;

type
  TThemeMode = (tmLight, tmDark);

const
  // Dark theme colors (BGR format)
  DarkBackgroundColor = $0045403A;  // Dark panel color
  DarkerBackgroundColor = $00232323;  // Darker panel color for unselected items
  DarkTextColor = clWhite;          // Light text color

  // Light theme colors
  LightBackgroundColor = clWhite;   // Light panel color
  LighterBackgroundColor = $00F5F5F5;  // Lighter gray for unselected items
  LightTextColor = clBlack;         // Dark text color
  LightBorderColor = $00D0D0D0;     // Light border color
  LightButtonColor = $00E0E0E0;     // Light gray for buttons

var
  CurrentTheme: TThemeMode = tmDark;  // Default to dark theme

/// <summary>
/// Recursively applies dark theme colors to all controls in a form
/// </summary>
/// <param name="AControl">The parent control to apply dark theme to</param>
procedure ApplyDarkTheme(AControl: TWinControl);

/// <summary>
/// Recursively applies light theme colors to all controls in a form
/// </summary>
/// <param name="AControl">The parent control to apply light theme to</param>
procedure ApplyLightTheme(AControl: TWinControl);

/// <summary>
/// Applies the specified theme to a control
/// </summary>
/// <param name="AControl">The control to apply theme to</param>
/// <param name="ATheme">The theme to apply (tmLight or tmDark)</param>
procedure ApplyTheme(AControl: TWinControl; ATheme: TThemeMode);

/// <summary>
/// Toggles between light and dark theme
/// </summary>
/// <param name="AControl">The control to toggle theme on</param>
/// <returns>The new theme mode</returns>
function ToggleTheme(AControl: TWinControl): TThemeMode;

/// <summary>
/// Saves theme preference to config file
/// </summary>
/// <param name="ATheme">The theme to save</param>
procedure SaveThemePreference(ATheme: TThemeMode);

/// <summary>
/// Loads theme preference from config file
/// </summary>
/// <returns>The saved theme mode, or tmDark if not found</returns>
function LoadThemePreference: TThemeMode;

/// <summary>
/// Gets the config file path
/// </summary>
function GetConfigFilePath: string;

/// <summary>
/// Centers a form on the screen
/// </summary>
/// <param name="AForm">The form to center</param>
procedure CenterFormOnScreen(AForm: TForm);

implementation

function GetConfigFilePath: string;
begin
  Result := GetEnvironmentVariable('HOME') + '/.config/goverlay/goverlay.conf';
end;

procedure ApplyDarkTheme(AControl: TWinControl);
var
  i: Integer;
  ctrl: TControl;
begin
  // Set form background
  if AControl is TForm then
    TForm(AControl).Color := DarkBackgroundColor;

  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    // Skip color exceptions - components that should maintain their custom colors
    if (ctrl.Name = 'saveBitBtn') or
       (ctrl.Name = 'notificationLabel') or
       (ctrl.Name = 'vkbasaltLabel') or
       (ctrl.Name = 'deckyLabel1') or
       (ctrl.Name = 'deckyLabel2') or
       (ctrl.Name = 'optLabel1') or
       (ctrl.Name = 'fakenvapi1') or
       (ctrl.Name = 'fakenvapi2') or
       (ctrl.Name = 'fsrLabel1') or
       (ctrl.Name = 'xessLabel1') or
       (ctrl.Name = 'gupdateBitBtn') or
       (ctrl.Name = 'updateBitBtn') or
       (ctrl.Name = 'customcommandEdit') or
       (ctrl.Name = 'mangohudLabel') or
       (ctrl.Name = 'optiscalerLabel') or
       (ctrl.Name = 'mangohudShape') or
       (ctrl.Name = 'vkbasaltShape') or
       (ctrl.Name = 'optiscalerShape') or
       (ctrl.Name = 'autodetectnvLabel') or
       (ctrl.Name = 'autodetectmesaLabel') or
       (ctrl.Name = 'topleftRadioButton') or
       (ctrl.Name = 'topcenterRadioButton') or
       (ctrl.Name = 'toprightRadioButton') or
       (ctrl.Name = 'bottomleftRadioButton') or
       (ctrl.Name = 'bottomrightRadioButton') or
       (ctrl.Name = 'bottomcenterRadioButton') or
       (ctrl.Name = 'middleleftRadioButton') or
       (ctrl.Name = 'middlerightRadioButton') then
      Continue;

    if ctrl is TMemo then
    begin
      TMemo(ctrl).Font.Color := DarkTextColor;
      TMemo(ctrl).Color := DarkerBackgroundColor;
    end
    else if ctrl is TComboBox then
    begin
      TComboBox(ctrl).Font.Color := DarkTextColor;
      TComboBox(ctrl).Color := DarkerBackgroundColor;
    end
    else if ctrl is TEdit then
    begin
      TEdit(ctrl).Font.Color := DarkTextColor;
      TEdit(ctrl).Color := DarkerBackgroundColor;
    end
    else if ctrl is TLabel then
      TLabel(ctrl).Font.Color := DarkTextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := DarkTextColor
    else if ctrl is TRadioButton then
      TRadioButton(ctrl).Font.Color := DarkTextColor
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
    else if ctrl is TPanel then
    begin
      TPanel(ctrl).Color := DarkBackgroundColor;
      TPanel(ctrl).Font.Color := DarkTextColor;
      if ctrl.Name = 'mangobarPanel' then
        TPanel(ctrl).BevelOuter := bvNone;
      if TPanel(ctrl) is TWinControl then
        ApplyDarkTheme(TWinControl(ctrl));
    end
    else if ctrl is TBitBtn then
    begin
      if (ctrl.Name = 'saveBitBtn') or
         (ctrl.Name = 'gupdateBitBtn') or
         (ctrl.Name = 'updateBitBtn') then
        Continue;
      TBitBtn(ctrl).Color := DarkBackgroundColor;
      TBitBtn(ctrl).Font.Color := DarkTextColor;
    end
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := DarkBackgroundColor
    else if ctrl is TWinControl then
      ApplyDarkTheme(TWinControl(ctrl));
  end;
end;

procedure ApplyLightTheme(AControl: TWinControl);
var
  i: Integer;
  ctrl: TControl;
begin
  // Set form background
  if AControl is TForm then
    TForm(AControl).Color := LightBackgroundColor;

  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    // Skip color exceptions - components that should maintain their custom colors
    if (ctrl.Name = 'saveBitBtn') or
       (ctrl.Name = 'notificationLabel') or
       (ctrl.Name = 'dependenciesLabel') or
       (ctrl.Name = 'deckyLabel1') or
       (ctrl.Name = 'deckyLabel2') or
       (ctrl.Name = 'optLabel1') or
       (ctrl.Name = 'fakenvapi1') or
       (ctrl.Name = 'fakenvapi2') or
       (ctrl.Name = 'fsrLabel1') or
       (ctrl.Name = 'xessLabel1') or
       (ctrl.Name = 'gupdateBitBtn') or
       (ctrl.Name = 'updateBitBtn') or
       (ctrl.Name = 'customcommandEdit') or
       (ctrl.Name = 'mangohudLabel') or
       (ctrl.Name = 'vkbasaltLabel') or
       (ctrl.Name = 'optiscalerLabel') or
       (ctrl.Name = 'mangohudShape') or
       (ctrl.Name = 'vkbasaltShape') or
       (ctrl.Name = 'optiscalerShape') or
       (ctrl.Name = 'autodetectnvLabel') or
       (ctrl.Name = 'autodetectmesaLabel') or
       (ctrl.Name = 'topleftRadioButton') or
       (ctrl.Name = 'topcenterRadioButton') or
       (ctrl.Name = 'toprightRadioButton') or
       (ctrl.Name = 'bottomleftRadioButton') or
       (ctrl.Name = 'bottomrightRadioButton') or
       (ctrl.Name = 'bottomcenterRadioButton') or
       (ctrl.Name = 'middleleftRadioButton') or
       (ctrl.Name = 'middlerightRadioButton') then
      Continue;

    if ctrl is TMemo then
    begin
      TMemo(ctrl).Font.Color := LightTextColor;
      TMemo(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TComboBox then
    begin
      TComboBox(ctrl).Font.Color := LightTextColor;
      TComboBox(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TEdit then
    begin
      TEdit(ctrl).Font.Color := LightTextColor;
      TEdit(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TLabel then
      TLabel(ctrl).Font.Color := LightTextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := LightTextColor
    else if ctrl is TRadioButton then
      TRadioButton(ctrl).Font.Color := LightTextColor
    else if ctrl is TGroupBox then
    begin
      TGroupBox(ctrl).Font.Color := LightTextColor;
      TGroupBox(ctrl).Color := LightBackgroundColor;
      if TGroupBox(ctrl) is TWinControl then
        ApplyLightTheme(TWinControl(ctrl));
    end
    else if ctrl is TCheckGroup then
    begin
      TCheckGroup(ctrl).Font.Color := LightTextColor;
      TCheckGroup(ctrl).Color := LightBackgroundColor;
      if TCheckGroup(ctrl) is TWinControl then
        ApplyLightTheme(TWinControl(ctrl));
    end
    else if ctrl is TRadioGroup then
    begin
      TRadioGroup(ctrl).Font.Color := LightTextColor;
      TRadioGroup(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TPanel then
    begin
      TPanel(ctrl).Color := LighterBackgroundColor;
      TPanel(ctrl).Font.Color := LightTextColor;
      if ctrl.Name = 'mangobarPanel' then
        TPanel(ctrl).BevelOuter := bvNone;
      if TPanel(ctrl) is TWinControl then
        ApplyLightTheme(TWinControl(ctrl));
    end
    else if ctrl is TBitBtn then
    begin
      if (ctrl.Name = 'saveBitBtn') or
         (ctrl.Name = 'gupdateBitBtn') or
         (ctrl.Name = 'updateBitBtn') then
        Continue;
      TBitBtn(ctrl).Color := LightButtonColor;
      TBitBtn(ctrl).Font.Color := LightTextColor;
    end
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := LightBackgroundColor
    else if ctrl is TWinControl then
      ApplyLightTheme(TWinControl(ctrl));
  end;
end;

procedure ApplyTheme(AControl: TWinControl; ATheme: TThemeMode);
begin
  CurrentTheme := ATheme;

  case ATheme of
    tmLight: ApplyLightTheme(AControl);
    tmDark: ApplyDarkTheme(AControl);
  end;

  // Refresh the control to show changes
  if AControl is TForm then
    TForm(AControl).Invalidate;
end;

function ToggleTheme(AControl: TWinControl): TThemeMode;
begin
  // Toggle between light and dark
  if CurrentTheme = tmDark then
    Result := tmLight
  else
    Result := tmDark;

  // Apply the new theme
  ApplyTheme(AControl, Result);

  // Save preference
  SaveThemePreference(Result);
end;

procedure SaveThemePreference(ATheme: TThemeMode);
var
  IniFile: TIniFile;
  ConfigPath: string;
  ConfigDir: string;
begin
  try
    ConfigPath := GetConfigFilePath;
    ConfigDir := ExtractFilePath(ConfigPath);

    // Create config directory if it doesn't exist
    if not DirectoryExists(ConfigDir) then
      ForceDirectories(ConfigDir);

    IniFile := TIniFile.Create(ConfigPath);
    try
      if ATheme = tmLight then
        IniFile.WriteString('Appearance', 'Theme', 'light')
      else
        IniFile.WriteString('Appearance', 'Theme', 'dark');
    finally
      IniFile.Free;
    end;
  except
    // Silently fail if we can't save the preference
  end;
end;

function LoadThemePreference: TThemeMode;
var
  IniFile: TIniFile;
  ConfigPath: string;
  ThemeStr: string;
begin
  Result := tmDark;  // Default to dark theme

  try
    ConfigPath := GetConfigFilePath;

    if FileExists(ConfigPath) then
    begin
      IniFile := TIniFile.Create(ConfigPath);
      try
        ThemeStr := IniFile.ReadString('Appearance', 'Theme', 'dark');
        if ThemeStr = 'light' then
          Result := tmLight
        else
          Result := tmDark;
      finally
        IniFile.Free;
      end;
    end;
  except
    // Return default if we can't load
    Result := tmDark;
  end;

  CurrentTheme := Result;
end;

procedure CenterFormOnScreen(AForm: TForm);
begin
  AForm.Left := (Screen.Width - AForm.Width) div 2;
  AForm.Top := (Screen.Height - AForm.Height) div 2;
end;

end.
