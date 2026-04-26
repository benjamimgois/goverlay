unit themeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, StdCtrls, ExtCtrls, Forms, Dialogs, IniFiles, Buttons, ComCtrls,
  configmanager;

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
/// Detects if the application is running on GNOME
/// </summary>
/// <returns>True if running on GNOME, False otherwise</returns>
function IsGNOMEDesktop: Boolean;

/// <summary>
/// Centers a form on the screen
/// </summary>
/// <param name="AForm">The form to center</param>
procedure CenterFormOnScreen(AForm: TForm);

implementation

function GetConfigFilePath: string;
begin
  // Use the centralized Flatpak-aware helper so all XDG paths are resolved
  // consistently across the application.
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetHostConfigDir) +
            'goverlay/goverlay.conf';
end;

function IsGNOMEDesktop: Boolean;
var
  DesktopEnv, CurrentDesktop: string;
begin
  Result := False;

  // Check XDG_CURRENT_DESKTOP environment variable
  CurrentDesktop := UpperCase(GetEnvironmentVariable('XDG_CURRENT_DESKTOP'));
  if (Pos('GNOME', CurrentDesktop) > 0) or
     (Pos('UNITY', CurrentDesktop) > 0) or
     (Pos('PANTHEON', CurrentDesktop) > 0) then
  begin
    Result := True;
    Exit;
  end;

  // Fallback: Check DESKTOP_SESSION
  DesktopEnv := UpperCase(GetEnvironmentVariable('DESKTOP_SESSION'));
  if (Pos('GNOME', DesktopEnv) > 0) or
     (Pos('UNITY', DesktopEnv) > 0) or
     (Pos('PANTHEON', DesktopEnv) > 0) then
  begin
    Result := True;
  end;
end;

procedure DoApplyTheme(AControl: TWinControl; ATheme: TThemeMode);
var
  i, j: Integer;
  ctrl: TControl;
  BgColor, TextColor, BtnColor: TColor;
begin
  if ATheme = tmDark then
  begin
    BgColor := DarkBackgroundColor;
    TextColor := DarkTextColor;
    BtnColor := DarkBackgroundColor;
  end
  else
  begin
    BgColor := LightBackgroundColor;
    TextColor := LightTextColor;
    BtnColor := LightButtonColor;
  end;

  if AControl is TForm then
    TForm(AControl).Color := BgColor;

  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    // Skip controls marked to preserve their custom colors / styling
    if ctrl.Tag = 9999 then
      Continue;

    if ctrl is TMemo then
    begin
      TMemo(ctrl).Font.Color := TextColor;
      if ATheme = tmDark then
        TMemo(ctrl).Color := DarkerBackgroundColor
      else
        TMemo(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TComboBox then
    begin
      TComboBox(ctrl).Font.Color := TextColor;
      if ATheme = tmDark then
        TComboBox(ctrl).Color := DarkerBackgroundColor
      else
        TComboBox(ctrl).Color := LightBackgroundColor;
    end
    else if ctrl is TEdit then
    begin
      if (ctrl.Name = 'commandEdit') or (ctrl.Name = 'customcommandEdit') then
      begin
        TEdit(ctrl).Font.Color := clWhite;
        TEdit(ctrl).Color := clBlack;
      end
      else if (ATheme = tmLight) and (ctrl.Name = 'logfolderEdit') then
      begin
        TEdit(ctrl).Font.Color := LightTextColor;
        TEdit(ctrl).Color := LighterBackgroundColor;
      end
      else
      begin
        TEdit(ctrl).Font.Color := TextColor;
        if ATheme = tmDark then
          TEdit(ctrl).Color := DarkerBackgroundColor
        else
          TEdit(ctrl).Color := LightBackgroundColor;
      end;
    end
    else if ctrl is TLabel then
      TLabel(ctrl).Font.Color := TextColor
    else if ctrl is TCheckBox then
      TCheckBox(ctrl).Font.Color := TextColor
    else if ctrl is TRadioButton then
      TRadioButton(ctrl).Font.Color := TextColor
    else if ctrl is TGroupBox then
    begin
      TGroupBox(ctrl).Font.Color := TextColor;
      TGroupBox(ctrl).Color := BgColor;
      if TGroupBox(ctrl) is TWinControl then
        DoApplyTheme(TWinControl(ctrl), ATheme);
    end
    else if ctrl is TCheckGroup then
    begin
      TCheckGroup(ctrl).Font.Color := TextColor;
      TCheckGroup(ctrl).Color := BgColor;
      if TCheckGroup(ctrl) is TWinControl then
        DoApplyTheme(TWinControl(ctrl), ATheme);
    end
    else if ctrl is TRadioGroup then
    begin
      TRadioGroup(ctrl).Font.Color := TextColor;
      TRadioGroup(ctrl).Color := BgColor;
    end
    else if ctrl is TPanel then
    begin
      if ctrl.Tag <> 9999 then
      begin
        if ATheme = tmDark then
        begin
          TPanel(ctrl).Color := BgColor;
          TPanel(ctrl).Font.Color := TextColor;
        end
        else
        begin
          TPanel(ctrl).Color := LighterBackgroundColor;
          TPanel(ctrl).Font.Color := TextColor;
        end;
      end;
      if (ctrl.Name = 'mangobarPanel') or (ctrl.Name = 'goverlaybarPanel') then
        TPanel(ctrl).BevelOuter := bvNone;
      if TPanel(ctrl) is TWinControl then
        DoApplyTheme(TWinControl(ctrl), ATheme);
    end
    else if ctrl is TBitBtn then
    begin
      if (ctrl.Name = 'saveBitBtn') or
         (ctrl.Name = 'gupdateBitBtn') or
         (ctrl.Name = 'updateBitBtn') then
        Continue;
      TBitBtn(ctrl).Color := BtnColor;
      TBitBtn(ctrl).Font.Color := TextColor;
    end
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := BgColor
    else if ctrl is TListView then
    begin
      if ATheme = tmDark then
        TListView(ctrl).Color := DarkerBackgroundColor
      else
        TListView(ctrl).Color := LightBackgroundColor;
      TListView(ctrl).Font.Color := TextColor;
    end
    else if ctrl is TButton then
    begin
      if ATheme = tmDark then
        TButton(ctrl).Color := BgColor
      else
        TButton(ctrl).Color := LighterBackgroundColor;
      TButton(ctrl).Font.Color := TextColor;
    end
    else if ctrl is TPageControl then
    begin
      for j := 0 to TPageControl(ctrl).PageCount - 1 do
      begin
        if IsGNOMEDesktop then
        begin
          TPageControl(ctrl).Pages[j].Font.Color := clDefault;
          TPageControl(ctrl).Pages[j].ParentFont := False;
        end
        else
          TPageControl(ctrl).Pages[j].Font.Color := TextColor;
      end;
      DoApplyTheme(TWinControl(ctrl), ATheme);
    end
    else if ctrl is TTabSheet then
    begin
      if IsGNOMEDesktop then
      begin
        TTabSheet(ctrl).Font.Color := clDefault;
        TTabSheet(ctrl).ParentFont := False;
      end
      else
        TTabSheet(ctrl).Font.Color := TextColor;
      if TTabSheet(ctrl) is TWinControl then
        DoApplyTheme(TWinControl(ctrl), ATheme);
    end
    else if ctrl is TWinControl then
      DoApplyTheme(TWinControl(ctrl), ATheme);
  end;
end;

procedure ApplyDarkTheme(AControl: TWinControl);
begin
  DoApplyTheme(AControl, tmDark);
end;

procedure ApplyLightTheme(AControl: TWinControl);
begin
  DoApplyTheme(AControl, tmLight);
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
