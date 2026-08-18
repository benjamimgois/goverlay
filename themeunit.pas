unit themeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, StdCtrls, ExtCtrls, Forms, Dialogs, IniFiles, Buttons, ComCtrls, Math,
  configmanager;

type
  TThemeMode = (tmLight, tmDark);
  TUiLabelRole = (lrCardTitle, lrSectionTitle, lrControlLabel, lrMutedHint, lrHighlight, lrStatusOk);

const
  // ── Color Palette Tokens (BGR format) ──────────────────────────────
  DARK_TAB_BG        = $00281A16; // rgb(22, 26, 40)
  DARK_CARD_BG       = $002E1E1A; // rgb(26, 30, 46)
  DARK_CARD_BORDER   = $00342620; // rgb(32, 38, 52)
  DARK_INPUT_BG      = $00482E26; // rgb(38, 46, 72)
  DARK_INPUT_BORDER  = $006C4637; // rgb(55, 70, 108)

  // Dark theme legacy colors
  DarkBackgroundColor = $0045403A;
  DarkerBackgroundColor = $00232323;
  DarkTextColor = clWhite;

  // Light theme colors
  LightBackgroundColor = clWhite;
  LighterBackgroundColor = $00F5F5F5;
  LightTextColor = clBlack;
  LightBorderColor = $00D0D0D0;
  LightButtonColor = $00E0E0E0;

  // ── Typography Color Tokens ─────────────────────────────────────────
  CLR_TEXT_PRIMARY   = clWhite;   // Title & primary text
  CLR_TEXT_SECONDARY = $00CCAAAA; // Section / Sub-card titles (Cyan-Gray)
  CLR_TEXT_MUTED     = $00AAAAAA; // Secondary hints & muted labels
  CLR_TEXT_HIGHLIGHT = $00FF99BB; // Version tags & key highlights (purple BGR)
  CLR_TEXT_ACCENT    = $00F0BE30; // Cyan accent
  CLR_TEXT_SUCCESS   = $0066CC44; // Green status

  // ── Typography Scale Tokens ──────────────────────────────────────────
  UI_FONT_FAMILY     = 'Sans';
  FONT_SZ_CARD_HDR   = 10; // Card level 1 title (Bold)
  FONT_SZ_SEC_HDR    = 8;  // Sub-card level 2 title (Bold)
  FONT_SZ_CONTROL    = 9;  // Form controls & labels (Regular)
  FONT_SZ_HINT       = 8;  // Auxiliary hints & badges (Regular)

  // ── Layout Metric Tokens ────────────────────────────────────────────
  LAYOUT_MARGIN      = 4;  // Outer scrollbox margin
  LAYOUT_GAP         = 6;  // Gap between cards & sub-cards
  LAYOUT_PAD         = 12; // Inner card padding
  LAYOUT_HDR_HEIGHT  = 34; // Top card header height
  LAYOUT_ROW_HEIGHT  = 26; // Standard row height for controls
  LAYOUT_BTN_HEIGHT  = 28; // Standard height for buttons
  LAYOUT_COMBO_HEIGHT= 26; // Standard height for comboboxes

var
  CurrentTheme: TThemeMode = tmDark;

/// <summary>
/// Styles a main card panel with background, border, and title header
/// </summary>
procedure StyleMainCard(ACard: TPanel; ATitleLbl: TLabel; const ATitle: string);

/// <summary>
/// Styles a sub-card panel with subtle border and section header
/// </summary>
procedure StyleSubCard(ASubCard: TPanel; AHeaderLbl: TLabel; const ATitle: string);

/// <summary>
/// Styles a label according to its role in the UI hierarchy
/// </summary>
procedure StyleLabel(ALabel: TLabel; ARole: TUiLabelRole);

/// <summary>
/// Styles input controls (ComboBox, Edit, SpinEdit)
/// </summary>
procedure StyleInputControl(AControl: TControl);

/// <summary>
/// Styles CheckBoxes and RadioButtons
/// </summary>
procedure StyleToggleControl(AControl: TControl);

/// <summary>
/// Styles Action Buttons (TBitBtn, TSpeedButton)
/// </summary>
procedure StyleActionButton(AButton: TControl);

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
/// Saves the last selected OptiScaler GPU driver preference
/// </summary>
/// <param name="ADriver">'nvidia' or 'mesa'</param>
procedure SaveOptiScalerDriverPreference(const ADriver: string);

/// <summary>
/// Loads the last selected OptiScaler GPU driver preference
/// </summary>
/// <returns>'nvidia', 'mesa', or empty string if not set</returns>
function LoadOptiScalerDriverPreference: string;

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

/// <summary>
/// Applies modern semitransparent scrollbar styling (QSS) to a control
/// </summary>
/// <param name="AWinControl">The wincontrol to apply scrollbar QSS to</param>
procedure ApplyModernScrollBarStylesheet(AWinControl: TWinControl);

implementation

uses
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets;

function ColorToRGBString(AColor: TColor): string;
var
  RGBVal: Longint;
begin
  RGBVal := ColorToRGB(AColor);
  Result := Format('rgb(%d,%d,%d)', [Red(RGBVal), Green(RGBVal), Blue(RGBVal)]);
end;

function GetConfigFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) +
            'goverlay.conf';
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

procedure ApplyModernScrollBarStylesheet(AWinControl: TWinControl);
var
  SS: WideString;
begin
  if not Assigned(AWinControl) then Exit;
  if not AWinControl.HandleAllocated then
    AWinControl.HandleNeeded;
  if not AWinControl.HandleAllocated then Exit;

  SS := 'QScrollBar:vertical { border: none; background: transparent; width: 6px; margin: 0px; } ' +
        'QScrollBar::handle:vertical { background: rgba(255, 255, 255, 0.25); min-height: 20px; border-radius: 3px; } ' +
        'QScrollBar::handle:vertical:hover { background: rgba(255, 255, 255, 0.5); } ' +
        'QScrollBar::handle:vertical:pressed { background: rgba(255, 255, 255, 0.75); } ' +
        'QScrollBar::sub-line:vertical, QScrollBar::add-line:vertical { border: none; background: none; height: 0px; } ' +
        'QScrollBar::add-page:vertical, QScrollBar::sub-page:vertical { background: none; } ' +
        'QScrollBar:horizontal { border: none; background: transparent; height: 6px; margin: 0px; } ' +
        'QScrollBar::handle:horizontal { background: rgba(255, 255, 255, 0.25); min-width: 20px; border-radius: 3px; } ' +
        'QScrollBar::handle:horizontal:hover { background: rgba(255, 255, 255, 0.5); } ' +
        'QScrollBar::sub-line:horizontal, QScrollBar::add-line:horizontal { border: none; background: none; width: 0px; } ' +
        'QScrollBar::add-page:horizontal, QScrollBar::sub-page:horizontal { background: none; }';
  QWidget_setStyleSheet(TQtWidget(AWinControl.Handle).Widget, @SS);
end;

procedure DoApplyTheme(AControl: TWinControl; ATheme: TThemeMode);
var
  i, j: Integer;
  ctrl: TControl;
  BgColor, TextColor, BtnColor: TColor;
  SS: WideString;
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
  begin
    TForm(AControl).Color := BgColor;
    ApplyModernScrollBarStylesheet(AControl);
  end;

  for i := 0 to AControl.ControlCount - 1 do
  begin
    ctrl := AControl.Controls[i];

    // Skip controls marked to preserve their custom colors / styling
    if ctrl.Tag = 9999 then
      Continue;

    if ctrl is TScrollBox then
    begin
      if ctrl is TWinControl then
      begin
        ApplyModernScrollBarStylesheet(TWinControl(ctrl));
        DoApplyTheme(TWinControl(ctrl), ATheme);
      end;
    end
    else if ctrl is TMemo then
    begin
      TMemo(ctrl).Font.Color := TextColor;
      if ATheme = tmDark then
        TMemo(ctrl).Color := DarkerBackgroundColor
      else
        TMemo(ctrl).Color := LightBackgroundColor;
      if ctrl is TWinControl then
        ApplyModernScrollBarStylesheet(TWinControl(ctrl));
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
      if TEdit(ctrl).HandleAllocated then
      begin
        SS := 'QLineEdit { background-color: ' + ColorToRGBString(TEdit(ctrl).Color) +
              '; color: ' + ColorToRGBString(TEdit(ctrl).Font.Color) + '; }';
        QWidget_setStyleSheet(TQtWidget(TEdit(ctrl).Handle).Widget, @SS);
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
      if ATheme = tmDark then
      begin
        TBitBtn(ctrl).Color := RGBToColor(38, 46, 72);
        TBitBtn(ctrl).Font.Color := TextColor;
        if TBitBtn(ctrl).HandleAllocated then
        begin
          SS := 'QPushButton, QToolButton { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 3px 8px; } ' +
                'QPushButton:hover, QToolButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); } ' +
                'QPushButton:pressed, QToolButton:pressed { background-color: rgb(28,34,54); } ' +
                'QPushButton:disabled, QToolButton:disabled { background-color: rgb(28,34,54); color: rgb(100,110,130); border: 1px solid rgb(40,48,70); }';
          QWidget_setStyleSheet(TQtWidget(TBitBtn(ctrl).Handle).Widget, @SS);
        end;
      end
      else
      begin
        TBitBtn(ctrl).Color := BtnColor;
        TBitBtn(ctrl).Font.Color := TextColor;
        if TBitBtn(ctrl).HandleAllocated then
        begin
          SS := 'QPushButton, QToolButton { background-color: ' + ColorToRGBString(TBitBtn(ctrl).Color) +
                '; color: ' + ColorToRGBString(TBitBtn(ctrl).Font.Color) + '; }';
          QWidget_setStyleSheet(TQtWidget(TBitBtn(ctrl).Handle).Widget, @SS);
        end;
      end;
    end
    else if ctrl is TSpeedButton then
      TSpeedButton(ctrl).Font.Color := TextColor
    else if ctrl is TColorButton then
      TColorButton(ctrl).Color := BgColor
    else if ctrl is TListBox then
    begin
      if ATheme = tmDark then
        TListBox(ctrl).Color := DarkerBackgroundColor
      else
        TListBox(ctrl).Color := LightBackgroundColor;
      TListBox(ctrl).Font.Color := TextColor;
      if ctrl is TWinControl then
        ApplyModernScrollBarStylesheet(TWinControl(ctrl));
    end
    else if ctrl is TListView then
    begin
      if ATheme = tmDark then
        TListView(ctrl).Color := DarkerBackgroundColor
      else
        TListView(ctrl).Color := LightBackgroundColor;
      TListView(ctrl).Font.Color := TextColor;
      if ctrl is TWinControl then
        ApplyModernScrollBarStylesheet(TWinControl(ctrl));
    end
    else if ctrl is TButton then
    begin
      if ATheme = tmDark then
        TButton(ctrl).Color := BgColor
      else
        TButton(ctrl).Color := LighterBackgroundColor;
      TButton(ctrl).Font.Color := TextColor;
    end
    else if ctrl is TTrackBar then
    begin
      TTrackBar(ctrl).TickStyle := tsNone;
      if TTrackBar(ctrl).HandleAllocated then
      begin
        if ATheme = tmDark then
          SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(38,46,72); border-radius: 3px; } ' +
                'QSlider::sub-page:horizontal { background: rgb(48,190,240); border-radius: 3px; } ' +
                'QSlider::handle:horizontal { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; } ' +
                'QSlider::handle:horizontal:hover { background: rgb(255,255,255); } ' +
                'QSlider::groove:vertical { width: 6px; background: rgb(38,46,72); border-radius: 3px; } ' +
                'QSlider::add-page:vertical { background: rgb(48,190,240); border-radius: 3px; } ' +
                'QSlider::handle:vertical { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); height: 14px; margin-left: -4px; margin-right: -4px; border-radius: 7px; } ' +
                'QSlider::handle:vertical:hover { background: rgb(255,255,255); }'
        else
          SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(220,220,220); border-radius: 3px; } ' +
                'QSlider::sub-page:horizontal { background: rgb(0,120,215); border-radius: 3px; } ' +
                'QSlider::handle:horizontal { background: rgb(255,255,255); border: 1px solid rgb(180,180,180); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; } ' +
                'QSlider::handle:horizontal:hover { background: rgb(240,240,240); } ' +
                'QSlider::groove:vertical { width: 6px; background: rgb(220,220,220); border-radius: 3px; } ' +
                'QSlider::add-page:vertical { background: rgb(0,120,215); border-radius: 3px; } ' +
                'QSlider::handle:vertical { background: rgb(255,255,255); border: 1px solid rgb(180,180,180); height: 14px; margin-left: -4px; margin-right: -4px; border-radius: 7px; } ' +
                'QSlider::handle:vertical:hover { background: rgb(240,240,240); }';
        QWidget_setStyleSheet(TQtWidget(TTrackBar(ctrl).Handle).Widget, @SS);
      end;
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

procedure SaveOptiScalerDriverPreference(const ADriver: string);
var
  IniFile: TIniFile;
  ConfigPath: string;
  ConfigDir: string;
begin
  try
    ConfigPath := GetConfigFilePath;
    ConfigDir := ExtractFilePath(ConfigPath);

    if not DirectoryExists(ConfigDir) then
      ForceDirectories(ConfigDir);

    IniFile := TIniFile.Create(ConfigPath);
    try
      IniFile.WriteString('OptiScaler', 'GpuDriver', LowerCase(ADriver));
    finally
      IniFile.Free;
    end;
  except
    // Silently fail if we can't save the preference
  end;
end;

procedure StyleMainCard(ACard: TPanel; ATitleLbl: TLabel; const ATitle: string);
begin
  if not Assigned(ACard) then Exit;
  ACard.BevelOuter := bvNone;
  ACard.BorderStyle := bsNone;
  if CurrentTheme = tmDark then
    ACard.Color := DARK_CARD_BG
  else
    ACard.Color := LightBackgroundColor;

  if Assigned(ATitleLbl) then
  begin
    ATitleLbl.Caption := ATitle;
    ATitleLbl.Font.Name := UI_FONT_FAMILY;
    ATitleLbl.Font.Size := FONT_SZ_CARD_HDR;
    ATitleLbl.Font.Style := [fsBold];
    if CurrentTheme = tmDark then
      ATitleLbl.Font.Color := CLR_TEXT_PRIMARY
    else
      ATitleLbl.Font.Color := LightTextColor;
    ATitleLbl.AutoSize := True;
    ATitleLbl.Transparent := True;
    ATitleLbl.SetBounds(12, 8, 200, 22);
  end;
end;

procedure StyleSubCard(ASubCard: TPanel; AHeaderLbl: TLabel; const ATitle: string);
begin
  if not Assigned(ASubCard) then Exit;
  ASubCard.BevelOuter := bvNone;
  ASubCard.BorderStyle := bsNone;
  if CurrentTheme = tmDark then
    ASubCard.Color := DARK_CARD_BG
  else
    ASubCard.Color := LightBackgroundColor;

  if Assigned(AHeaderLbl) then
  begin
    AHeaderLbl.Caption := ATitle;
    AHeaderLbl.Font.Name := UI_FONT_FAMILY;
    AHeaderLbl.Font.Size := FONT_SZ_SEC_HDR;
    AHeaderLbl.Font.Style := [fsBold];
    if CurrentTheme = tmDark then
      AHeaderLbl.Font.Color := CLR_TEXT_SECONDARY
    else
      AHeaderLbl.Font.Color := LightTextColor;
    AHeaderLbl.AutoSize := True;
    AHeaderLbl.Transparent := True;
    AHeaderLbl.SetBounds(10, 6, Max(100, ASubCard.Width - 20), 16);
  end;
end;

procedure StyleLabel(ALabel: TLabel; ARole: TUiLabelRole);
begin
  if not Assigned(ALabel) then Exit;
  ALabel.Font.Name := UI_FONT_FAMILY;
  case ARole of
    lrCardTitle:
      begin
        ALabel.Font.Size := FONT_SZ_CARD_HDR;
        ALabel.Font.Style := [fsBold];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_PRIMARY else ALabel.Font.Color := LightTextColor;
      end;
    lrSectionTitle:
      begin
        ALabel.Font.Size := FONT_SZ_SEC_HDR;
        ALabel.Font.Style := [fsBold];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_SECONDARY else ALabel.Font.Color := LightTextColor;
      end;
    lrControlLabel:
      begin
        ALabel.Font.Size := FONT_SZ_CONTROL;
        ALabel.Font.Style := [];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_MUTED else ALabel.Font.Color := LightTextColor;
      end;
    lrMutedHint:
      begin
        ALabel.Font.Size := FONT_SZ_HINT;
        ALabel.Font.Style := [];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_MUTED else ALabel.Font.Color := LightTextColor;
      end;
    lrHighlight:
      begin
        ALabel.Font.Size := FONT_SZ_CONTROL;
        ALabel.Font.Style := [];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_HIGHLIGHT else ALabel.Font.Color := LightTextColor;
      end;
    lrStatusOk:
      begin
        ALabel.Font.Size := FONT_SZ_CONTROL;
        ALabel.Font.Style := [fsBold];
        if CurrentTheme = tmDark then ALabel.Font.Color := CLR_TEXT_SUCCESS else ALabel.Font.Color := clGreen;
      end;
  end;
end;

procedure StyleInputControl(AControl: TControl);
var
  SS: WideString;
begin
  if not Assigned(AControl) then Exit;
  AControl.Font.Name := UI_FONT_FAMILY;
  AControl.Font.Size := FONT_SZ_CONTROL;
  if CurrentTheme = tmDark then
  begin
    AControl.Color := DARK_INPUT_BG;
    AControl.Font.Color := CLR_TEXT_PRIMARY;
  end
  else
  begin
    AControl.Color := LightBackgroundColor;
    AControl.Font.Color := LightTextColor;
  end;

  if (AControl is TWinControl) and TWinControl(AControl).HandleAllocated then
  begin
    if CurrentTheme = tmDark then
      SS := 'QComboBox, QLineEdit, QSpinBox { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 6px; } ' +
            'QComboBox::drop-down { subcontrol-origin: padding; subcontrol-position: top right; width: 18px; border-left: none; }'
    else
      SS := 'QComboBox, QLineEdit, QSpinBox { border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 2px 6px; }';
    QWidget_setStyleSheet(TQtWidget(TWinControl(AControl).Handle).Widget, @SS);
  end;
end;

procedure StyleToggleControl(AControl: TControl);
begin
  if not Assigned(AControl) then Exit;
  AControl.Font.Name := UI_FONT_FAMILY;
  AControl.Font.Size := FONT_SZ_CONTROL;
  if AControl is TCheckBox then
  begin
    TCheckBox(AControl).ParentColor := True;
    if CurrentTheme = tmDark then
      TCheckBox(AControl).Font.Color := CLR_TEXT_PRIMARY
    else
      TCheckBox(AControl).Font.Color := LightTextColor;
  end;
  if AControl is TRadioButton then
  begin
    TRadioButton(AControl).ParentColor := True;
    if CurrentTheme = tmDark then
      TRadioButton(AControl).Font.Color := CLR_TEXT_PRIMARY
    else
      TRadioButton(AControl).Font.Color := LightTextColor;
  end;
end;

procedure StyleActionButton(AButton: TControl);
var
  SS: WideString;
begin
  if not Assigned(AButton) then Exit;
  AButton.Font.Name := UI_FONT_FAMILY;
  AButton.Font.Size := FONT_SZ_CONTROL;
  if CurrentTheme = tmDark then
  begin
    AButton.Color := DARK_INPUT_BG;
    AButton.Font.Color := CLR_TEXT_PRIMARY;
    if (AButton is TWinControl) and TWinControl(AButton).HandleAllocated then
    begin
      SS := 'QPushButton, QToolButton { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 3px 8px; } ' +
            'QPushButton:hover, QToolButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); } ' +
            'QPushButton:pressed, QToolButton:pressed { background-color: rgb(28,34,54); } ' +
            'QPushButton:disabled, QToolButton:disabled { background-color: rgb(28,34,54); color: rgb(100,110,130); border: 1px solid rgb(40,48,70); }';
      QWidget_setStyleSheet(TQtWidget(TWinControl(AButton).Handle).Widget, @SS);
    end;
  end
  else
  begin
    AButton.Color := LightButtonColor;
    AButton.Font.Color := LightTextColor;
  end;
end;

function LoadOptiScalerDriverPreference: string;
var
  IniFile: TIniFile;
  ConfigPath: string;
begin
  Result := '';
  try
    ConfigPath := GetConfigFilePath;
    if FileExists(ConfigPath) then
    begin
      IniFile := TIniFile.Create(ConfigPath);
      try
        Result := LowerCase(Trim(IniFile.ReadString('OptiScaler', 'GpuDriver', '')));
      finally
        IniFile.Free;
      end;
    end;
  except
    Result := '';
  end;
end;

end.
