unit optiscaler_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons,
  themeunit, constants, hintsunit, apputils, overlayunit, overlay_config,
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets,
  Math, configkeys, StrUtils;

type
  TOptiScalerTabHelper = class
  private
    FForm: Tgoverlayform;
  public
    constructor Create(AForm: Tgoverlayform);
    procedure InitOptiScalerTab;
    procedure ReflowOptiScalerTabNew(AContentW: Integer);
    procedure OsScrollBoxResize(Sender: TObject);
    procedure RefreshOsStatusDots;
    procedure LoadOptiScalerConfig;
    procedure SaveOptiScalerConfig(ASilent: Boolean = False);
    procedure UpdateFrameGenOptionsUI;
  end;

function OsHexToKeyStr(const HexStr: string): string;

implementation

uses bgmod_resources;

constructor TOptiScalerTabHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
end;

function OsHexToKeyStr(const HexStr: string): string;
var
  VkCode: Integer;
begin
  if SameText(HexStr, 'auto') or (HexStr = '') then
  begin
    Result := 'auto';
    Exit;
  end;
  try
    if (Length(HexStr) > 2) and (Copy(HexStr, 1, 2) = '0x') then
      VkCode := StrToInt('$' + Copy(HexStr, 3, MaxInt))
    else
      VkCode := StrToInt(HexStr);
  except
    Result := HexStr;
    Exit;
  end;
  // F1–F24
  if (VkCode >= $70) and (VkCode <= $87) then
  begin
    Result := 'F' + IntToStr(VkCode - $70 + 1);
    Exit;
  end;
  // Numpad 0–9
  if (VkCode >= $60) and (VkCode <= $69) then
  begin
    Result := 'Numpad' + IntToStr(VkCode - $60);
    Exit;
  end;
  // Digits 0–9
  if (VkCode >= $30) and (VkCode <= $39) then
  begin
    Result := Chr(VkCode);
    Exit;
  end;
  // Letters A–Z
  if (VkCode >= $41) and (VkCode <= $5A) then
  begin
    Result := Chr(VkCode);
    Exit;
  end;
  case VkCode of
    $08: Result := 'Backspace';
    $09: Result := 'Tab';
    $0D: Result := 'Enter';
    $13: Result := 'Pause';
    $14: Result := 'CapsLock';
    $1B: Result := 'Escape';
    $20: Result := 'Space';
    $21: Result := 'PageUp';
    $22: Result := 'PageDown';
    $23: Result := 'End';
    $24: Result := 'Home';
    $25: Result := 'Left';
    $26: Result := 'Up';
    $27: Result := 'Right';
    $28: Result := 'Down';
    $2C: Result := 'PrintScreen';
    $2D: Result := 'Insert';
    $2E: Result := 'Delete';
    $6A: Result := 'Numpad*';
    $6B: Result := 'Numpad+';
    $6D: Result := 'Numpad-';
    $6E: Result := 'Numpad.';
    $6F: Result := 'Numpad/';
    $90: Result := 'NumLock';
    $91: Result := 'ScrollLock';
    $BA: Result := 'Semicolon';
    $BB: Result := 'Plus';
    $BC: Result := 'Comma';
    $BD: Result := 'Minus';
    $BE: Result := 'Period';
    $BF: Result := 'Slash';
    $C0: Result := 'Tilde';
    $DB: Result := '[';
    $DC: Result := '\';
    $DD: Result := ']';
    $DE: Result := 'Quote';
  else
    Result := Format('0x%.2x', [VkCode]);
  end;
end;

procedure TOptiScalerTabHelper.InitOptiScalerTab;
const
  BG      = $002E1E1A;  // rgb(28, 33, 52) — Option B
  ACCENT  = $00F0BE30;  // rgb(48, 190, 240) — cyan
  WHITE   = clWhite;
  PURPLE  = $BB99FF;
  GRAY    = $AAAAAA;
  GREEN   = $66CC44;
  BLUELK  = $4499FF;
  COMBOBG = $2A2A40;

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Lbl: TLabel;
  begin
    with FForm do
    begin
      Card := TPanel.Create(FForm);
      Card.Parent  := FOsBgPanel;
      Card.Caption := '';
      Card.OnPaint := @SubCardPaint;
      Lbl := TLabel.Create(Card);
      Lbl.Parent   := Card;
      StyleMainCard(Card, Lbl, ATitle);
    end;
  end;

  procedure ReparentGB(GB: TGroupBox; Card: TPanel);
  var SS: WideString;
  begin
    with FForm do
    begin
      GB.Parent   := Card;
      GB.Visible  := True;
      GB.Caption  := '';
      GB.Color    := DARK_CARD_BG;
      GB.Font.Color := CLR_TEXT_PRIMARY;
      GB.AnchorSideLeft.Control   := nil;
      GB.AnchorSideTop.Control    := nil;
      GB.AnchorSideRight.Control  := nil;
      GB.AnchorSideBottom.Control := nil;
      GB.Anchors := [akLeft, akTop];
      SS := 'QGroupBox { border: none; }';
      QWidget_setStyleSheet(TQtWidget(GB.Handle).Widget, @SS);
    end;
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    StyleToggleControl(C);
  end;

  procedure DarkRadio(R: TRadioButton);
  begin
    StyleToggleControl(R);
  end;

  procedure DarkCombo(C: TComboBox);
  begin
    StyleInputControl(C);
  end;

  procedure DarkLbl(L: TLabel; AColor: TColor);
  begin
    StyleLabel(L, lrControlLabel);
    if AColor <> clWhite then
      L.Font.Color := AColor;
  end;

const
  STAT_NAMES: array[0..5] of string = (
    'OptiScaler', 'DLSS / FSR / XeSS', 'DLSS Enabler', 'FakeNVAPI', 'Streamline SDK', 'OptiPatcher');
var
  i: Integer;
  Dot: TShape;
  NLbl, VLbl: TLabel;
  Png: TPortableNetworkGraphic;
  IconPath: string;
  GbSS: WideString;
begin
  with FForm do
  begin
    // Scroll container fills the tab
    FOsScrollBox := TScrollBox.Create(FForm);
    if Assigned(optiscalerTabSheet) then
      optiscalerTabSheet.Color := RGBToColor(22, 26, 40);
    FOsScrollBox.Parent      := optiscalerTabSheet;
    FOsScrollBox.Align       := alClient;
    FOsScrollBox.AutoScroll  := True;
    FOsScrollBox.BorderStyle := bsNone;
    FOsScrollBox.HorzScrollBar.Visible := False;
    FOsScrollBox.Color       := RGBToColor(22, 26, 40);
    FOsScrollBox.ParentColor := False;
    FOsScrollBox.OnResize    := @OsScrollBoxResize;

    // FOsBgPanel fills the scroll box and reliably paints the dark background
    // in the Qt6 backend (TScrollBox.Color is ignored by the Qt viewport).
    FOsBgPanel := TPanel.Create(FForm);
    FOsBgPanel.Parent     := FOsScrollBox;
    FOsBgPanel.BevelOuter := bvNone;
    FOsBgPanel.Color      := RGBToColor(22, 26, 40);
    FOsBgPanel.Caption    := '';
    FOsBgPanel.OnPaint    := @PresetsWrapperPaint;
    FOsBgPanel.Left       := 0;
    FOsBgPanel.Top        := 0;
    FOsBgPanel.Width      := FOsScrollBox.ClientWidth;
    FOsBgPanel.Height     := 600;  // provisional; updated by ReflowOptiScalerTabNew

    // ── Card 0a: Method (Left) ──────────────────────────────────────────
    MakeCard(FOsUpscalerCard, 'Method');

    optiscalerRadioButton := TRadioButton.Create(FForm);
    optiscalerRadioButton.Parent := FOsUpscalerCard;
    optiscalerRadioButton.Caption := '';
    DarkRadio(optiscalerRadioButton);
    optiscalerRadioButton.Checked := True;
    optiscalerRadioButton.OnClick := @optiscalerRadioButtonClick;

    dlssenablerRadioButton := TRadioButton.Create(FForm);
    dlssenablerRadioButton.Parent := FOsUpscalerCard;
    dlssenablerRadioButton.Caption := '';
    DarkRadio(dlssenablerRadioButton);
    dlssenablerRadioButton.Checked := False;
    dlssenablerRadioButton.OnClick := @dlssenablerRadioButtonClick;

    optiscalerLogoImage := TImage.Create(FForm);
    optiscalerLogoImage.AntialiasingMode := amOn;
    optiscalerLogoImage.Parent := FOsUpscalerCard;
    optiscalerLogoImage.Transparent := True;
    optiscalerLogoImage.Center := True;
    optiscalerLogoImage.Proportional := True;
    optiscalerLogoImage.Stretch := True;

    dlssEnablerLogoImage := TImage.Create(FForm);
    dlssEnablerLogoImage.Parent := FOsUpscalerCard;
    dlssEnablerLogoImage.Transparent := True;
    dlssEnablerLogoImage.Center := True;
    dlssEnablerLogoImage.Proportional := True;
    dlssEnablerLogoImage.Stretch := True;

    dlssEnablerVersionLabel := TLabel.Create(FForm);
    dlssEnablerVersionLabel.Parent := FOsUpscalerCard;
    dlssEnablerVersionLabel.Visible := False;

    streamlineVersionLabel := TLabel.Create(FForm);
    streamlineVersionLabel.Parent := FOsUpscalerCard;
    streamlineVersionLabel.Visible := False;

    FOptiScalerPngLogo := TPortableNetworkGraphic.Create;
    FDlssEnablerPngLogo := TPortableNetworkGraphic.Create;

    IconPath := GetAppBaseDir + 'assets/icons/upscaler_optiscaler.png';
    if FileExists(IconPath) then
      FOptiScalerPngLogo.LoadFromFile(IconPath);

    IconPath := GetAppBaseDir + 'assets/icons/upscaler_dlss_enabler.png';
    if FileExists(IconPath) then
      FDlssEnablerPngLogo.LoadFromFile(IconPath);

    optiscalerLogoImage.Picture.Assign(FOptiScalerPngLogo);
    dlssEnablerLogoImage.Picture.Assign(FDlssEnablerPngLogo);
    UpdateUpscalerImageOpacity;

    // ── Card 0b: GPU Driver (Right) ─────────────────────────────────────
    MakeCard(FOsGpuCard, 'GPU Driver');
    GbSS := 'QRadioButton::indicator { width:14px; height:14px; background-color:rgb(26,30,46); border:1px solid rgb(130,140,170); border-radius:7px; }'
          + 'QRadioButton::indicator:checked { background-color:rgb(48,190,240); border-color:rgb(48,190,240); }';
    QWidget_setStyleSheet(TQtWidget(FOsGpuCard.Handle).Widget, @GbSS);

    nvidiaRadioButton.AnchorSideLeft.Control   := nil;
    nvidiaRadioButton.AnchorSideTop.Control    := nil;
    nvidiaRadioButton.AnchorSideRight.Control  := nil;
    nvidiaRadioButton.AnchorSideBottom.Control := nil;
    nvidiaRadioButton.Anchors := [akLeft, akTop];
    nvidiaRadioButton.Top     := nvidiaRadioButton.Top + 62;
    nvidiaRadioButton.Parent  := FOsGpuCard;
    nvidiaRadioButton.Enabled := True;
    nvidiaRadioButton.Visible := True;
    DarkRadio(nvidiaRadioButton);

    mesaRadioButton.AnchorSideLeft.Control   := nil;
    mesaRadioButton.AnchorSideTop.Control    := nil;
    mesaRadioButton.AnchorSideRight.Control  := nil;
    mesaRadioButton.AnchorSideBottom.Control := nil;
    mesaRadioButton.Anchors := [akLeft, akTop];
    mesaRadioButton.Top     := mesaRadioButton.Top + 62;
    mesaRadioButton.Parent  := FOsGpuCard;
    mesaRadioButton.Enabled := True;
    mesaRadioButton.Visible := True;
    DarkRadio(mesaRadioButton);

    nvidiaImage.AnchorSideLeft.Control   := nil;
    nvidiaImage.AnchorSideTop.Control    := nil;
    nvidiaImage.AnchorSideRight.Control  := nil;
    nvidiaImage.AnchorSideBottom.Control := nil;
    nvidiaImage.Anchors     := [akLeft, akTop];
    nvidiaImage.Top         := nvidiaImage.Top + 62;
    nvidiaImage.Transparent       := True;
    nvidiaImage.StretchInEnabled  := True;
    nvidiaImage.StretchOutEnabled := True;
    nvidiaImage.AntialiasingMode  := amOn;
    nvidiaImage.Center            := True;
    nvidiaImage.Proportional      := True;
    nvidiaImage.Stretch          := False;
    nvidiaImage.Parent            := FOsGpuCard;

    mesaImage.AnchorSideLeft.Control   := nil;
    mesaImage.AnchorSideTop.Control    := nil;
    mesaImage.AnchorSideRight.Control  := nil;
    mesaImage.AnchorSideBottom.Control := nil;
    mesaImage.Anchors     := [akLeft, akTop];
    mesaImage.Top         := mesaImage.Top + 62;
    mesaImage.Transparent       := True;
    mesaImage.StretchInEnabled  := True;
    mesaImage.StretchOutEnabled := True;
    mesaImage.AntialiasingMode  := amOn;
    mesaImage.Center            := True;
    mesaImage.Proportional      := True;
    mesaImage.Stretch          := False;
    mesaImage.Parent            := FOsGpuCard;

    autodetectnvLabel.AnchorSideLeft.Control   := nil;
    autodetectnvLabel.AnchorSideTop.Control    := nil;
    autodetectnvLabel.AnchorSideRight.Control  := nil;
    autodetectnvLabel.AnchorSideBottom.Control := nil;
    autodetectnvLabel.Anchors     := [akLeft, akTop];
    autodetectnvLabel.Top         := autodetectnvLabel.Top + 62;
    autodetectnvLabel.Transparent := True;
    autodetectnvLabel.Font.Color  := GREEN;
    autodetectnvLabel.Font.Size   := 8;
    autodetectnvLabel.Parent      := FOsGpuCard;
    autodetectnvLabel.BringToFront;

    autodetectmesaLabel.AnchorSideLeft.Control   := nil;
    autodetectmesaLabel.AnchorSideTop.Control    := nil;
    autodetectmesaLabel.AnchorSideRight.Control  := nil;
    autodetectmesaLabel.AnchorSideBottom.Control := nil;
    autodetectmesaLabel.Anchors     := [akLeft, akTop];
    autodetectmesaLabel.Top         := autodetectmesaLabel.Top + 62;
    autodetectmesaLabel.Transparent := True;
    autodetectmesaLabel.Font.Color  := GREEN;
    autodetectmesaLabel.Font.Size   := 8;
    autodetectmesaLabel.Parent      := FOsGpuCard;
    autodetectmesaLabel.BringToFront;

    gpudriverGroupBox.Visible := False;

    // ── Card 1: Options (3-column inner layout) ─────────────────────────
    MakeCard(FOsOptionsCard, 'Options');
    optionsGroupBox.Visible    := False;
    optiscalerGroupBox.Visible := False;
    imgmenuGroupBox.Visible    := False;
    fakenvapiGroupBox.Visible  := False;

    FOsMainSec := TPanel.Create(FForm);
    FOsMainSec.Parent  := FOsOptionsCard;
    FOsMainSec.Caption := '';
    FOsMainSec.OnPaint := @SubCardPaint;
    FOsMainLbl := TLabel.Create(FOsMainSec);
    FOsMainLbl.Parent := FOsMainSec;
    StyleSubCard(FOsMainSec, FOsMainLbl, 'Main');

    FOsSpatialSec := TPanel.Create(FForm);
    FOsSpatialSec.Parent  := FOsOptionsCard;
    FOsSpatialSec.Caption := '';
    FOsSpatialSec.OnPaint := @SubCardPaint;
    FOsSpatialLbl := TLabel.Create(FOsSpatialSec);
    FOsSpatialLbl.Parent := FOsSpatialSec;
    StyleSubCard(FOsSpatialSec, FOsSpatialLbl, 'Spatial Upscaler');

    FOsTemporalSec := TPanel.Create(FForm);
    FOsTemporalSec.Parent  := FOsOptionsCard;
    FOsTemporalSec.Caption := '';
    FOsTemporalSec.OnPaint := @SubCardPaint;
    FOsTemporalLbl := TLabel.Create(FOsTemporalSec);
    FOsTemporalLbl.Parent := FOsTemporalSec;
    StyleSubCard(FOsTemporalSec, FOsTemporalLbl, 'Temporal Upscaler');

    FOsImgSec := TPanel.Create(FForm);
    FOsImgSec.Parent      := FOsOptionsCard;
    FOsImgSec.BevelOuter  := bvNone;
    FOsImgSec.BorderStyle := bsNone;
    FOsImgSec.Caption     := '';
    FOsImgSec.Color       := DARK_CARD_BG;
    FOsImgSec.Visible     := False;

    FOsFakeSec := TPanel.Create(FForm);
    FOsFakeSec.Parent  := FOsOptionsCard;
    FOsFakeSec.Caption := '';
    FOsFakeSec.OnPaint := @SubCardPaint;
    FOsFakeLbl := TLabel.Create(FOsFakeSec);
    FOsFakeLbl.Parent := FOsFakeSec;
    StyleSubCard(FOsFakeSec, FOsFakeLbl, 'Reflex / Antilag');

    // Reparent controls to their sub-cards
    // --- Sub-card 1: Main controls ---
    filenameLabel.AnchorSideLeft.Control   := nil; filenameLabel.AnchorSideTop.Control    := nil;
    filenameLabel.AnchorSideRight.Control  := nil; filenameLabel.AnchorSideBottom.Control := nil;
    filenameLabel.Anchors := [akLeft, akTop]; filenameLabel.Parent  := FOsMainSec;

    filenameComboBox.AnchorSideLeft.Control   := nil; filenameComboBox.AnchorSideTop.Control    := nil;
    filenameComboBox.AnchorSideRight.Control  := nil; filenameComboBox.AnchorSideBottom.Control := nil;
    filenameComboBox.Anchors := [akLeft, akTop]; filenameComboBox.Parent  := FOsMainSec;

    menuLabel.AnchorSideLeft.Control   := nil; menuLabel.AnchorSideTop.Control    := nil;
    menuLabel.AnchorSideRight.Control  := nil; menuLabel.AnchorSideBottom.Control := nil;
    menuLabel.Anchors := [akLeft, akTop]; menuLabel.Caption := 'Menu scale';
    menuLabel.Parent  := FOsMainSec;

    if menuscaleComboBox = nil then
    begin
      menuscaleComboBox := TComboBox.Create(FForm);
      menuscaleComboBox.Name := 'menuscaleComboBox';
      menuscaleComboBox.Style := csDropDownList;
      menuscaleComboBox.Items.Add('auto');
      menuscaleComboBox.Items.Add('1.0');
      menuscaleComboBox.Items.Add('1.1');
      menuscaleComboBox.Items.Add('1.2');
      menuscaleComboBox.Items.Add('1.3');
      menuscaleComboBox.Items.Add('1.4');
      menuscaleComboBox.Items.Add('1.5');
      menuscaleComboBox.Items.Add('1.6');
      menuscaleComboBox.Items.Add('1.7');
      menuscaleComboBox.Items.Add('1.8');
      menuscaleComboBox.Items.Add('1.9');
      menuscaleComboBox.Items.Add('2.0');
      menuscaleComboBox.ItemIndex := 0; // default auto
    end;
    menuscaleComboBox.AnchorSideLeft.Control   := nil; menuscaleComboBox.AnchorSideTop.Control    := nil;
    menuscaleComboBox.AnchorSideRight.Control  := nil; menuscaleComboBox.AnchorSideBottom.Control := nil;
    menuscaleComboBox.Anchors := [akLeft, akTop]; menuscaleComboBox.Parent  := FOsMainSec;

    optipatcherCheckBox.AnchorSideLeft.Control   := nil; optipatcherCheckBox.AnchorSideTop.Control    := nil;
    optipatcherCheckBox.AnchorSideRight.Control  := nil; optipatcherCheckBox.AnchorSideBottom.Control := nil;
    optipatcherCheckBox.Anchors := [akLeft, akTop]; optipatcherCheckBox.Parent  := FOsMainSec;

    patcherlistLabel.Visible := False;

    if FOsPatcherListBtn = nil then
    begin
      FOsPatcherListBtn := TSpeedButton.Create(FForm);
      FOsPatcherListBtn.Name := 'FOsPatcherListBtn';
      FOsPatcherListBtn.Parent := FOsMainSec;
      FOsPatcherListBtn.Flat := True;
      FOsPatcherListBtn.Transparent := True;
      FOsPatcherListBtn.Caption := '🔗';
      FOsPatcherListBtn.Hint := 'Games supported';
      FOsPatcherListBtn.ShowHint := True;
      FOsPatcherListBtn.Cursor := crHandPoint;
      FOsPatcherListBtn.OnClick := @patcherlistLabelClick;
    end;
    FOsPatcherListBtn.AnchorSideLeft.Control   := nil; FOsPatcherListBtn.AnchorSideTop.Control    := nil;
    FOsPatcherListBtn.AnchorSideRight.Control  := nil; FOsPatcherListBtn.AnchorSideBottom.Control := nil;
    FOsPatcherListBtn.Anchors := [akLeft, akTop]; FOsPatcherListBtn.Parent := FOsMainSec;

    shortcutkeyLabel.AnchorSideLeft.Control   := nil; shortcutkeyLabel.AnchorSideTop.Control    := nil;
    shortcutkeyLabel.AnchorSideRight.Control  := nil; shortcutkeyLabel.AnchorSideBottom.Control := nil;
    shortcutkeyLabel.Anchors  := [akLeft, akTop]; shortcutkeyLabel.Caption  := 'Optiscaler toggle';
    shortcutkeyLabel.Parent   := FOsMainSec;

    shortcutImage.Visible := False;
    shortcutkeyComboBox.Visible := False;
    shortcutkeyComboBox.Parent  := FOsMainSec;
    if (shortcutkeyComboBox.Text = '') or SameText(shortcutkeyComboBox.Text, 'auto') then
      shortcutkeyComboBox.Text := '0x2d';  // INSERT = default ShortcutKey

    if FOsShortcutCaptureBtn = nil then
      FOsShortcutCaptureBtn := TBitBtn.Create(FOsMainSec);
    FOsShortcutCaptureBtn.Parent   := FOsMainSec;
    FOsShortcutCaptureBtn.Tag      := 5;
    FOsShortcutCaptureBtn.Anchors  := [akLeft, akTop];
    FOsShortcutCaptureBtn.Cursor   := crHandPoint;
    FOsShortcutCaptureBtn.OnClick  := @CaptureBtnClick;
    FOsShortcutCaptureBtn.Width    := 100;
    FOsShortcutCaptureBtn.Height   := 28;
    FOsShortcutCaptureBtn.Caption  := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

    if dlssenablerToggleLabel = nil then
    begin
      dlssenablerToggleLabel := TLabel.Create(FForm);
      dlssenablerToggleLabel.Name := 'dlssenablerToggleLabel';
    end;
    dlssenablerToggleLabel.AnchorSideLeft.Control   := nil; dlssenablerToggleLabel.AnchorSideTop.Control    := nil;
    dlssenablerToggleLabel.AnchorSideRight.Control  := nil; dlssenablerToggleLabel.AnchorSideBottom.Control := nil;
    dlssenablerToggleLabel.Anchors := [akLeft, akTop];
    dlssenablerToggleLabel.Caption := 'DLSS-Enabler toggle';
    dlssenablerToggleLabel.Parent  := FOsMainSec;

    if dlssenablerToggleBtn = nil then
    begin
      dlssenablerToggleBtn := TBitBtn.Create(FForm);
      dlssenablerToggleBtn.Name := 'dlssenablerToggleBtn';
    end;
    dlssenablerToggleBtn.AnchorSideLeft.Control   := nil; dlssenablerToggleBtn.AnchorSideTop.Control    := nil;
    dlssenablerToggleBtn.AnchorSideRight.Control  := nil; dlssenablerToggleBtn.AnchorSideBottom.Control := nil;
    dlssenablerToggleBtn.Anchors  := [akLeft, akTop];
    dlssenablerToggleBtn.Parent   := FOsMainSec;
    dlssenablerToggleBtn.Width    := 100;
    dlssenablerToggleBtn.Height   := 28;
    dlssenablerToggleBtn.Caption  := '⌨ `';
    dlssenablerToggleBtn.Enabled  := False;

    // --- Sub-card 2: Spatial Upscaler controls ---
    preferredUpscalerLabel.AnchorSideLeft.Control   := nil; preferredUpscalerLabel.AnchorSideTop.Control    := nil;
    preferredUpscalerLabel.AnchorSideRight.Control  := nil; preferredUpscalerLabel.AnchorSideBottom.Control := nil;
    preferredUpscalerLabel.Anchors := [akLeft, akTop]; preferredUpscalerLabel.Parent  := FOsSpatialSec;

    preferredUpscalerComboBox.AnchorSideLeft.Control   := nil; preferredUpscalerComboBox.AnchorSideTop.Control    := nil;
    preferredUpscalerComboBox.AnchorSideRight.Control  := nil; preferredUpscalerComboBox.AnchorSideBottom.Control := nil;
    preferredUpscalerComboBox.Anchors := [akLeft, akTop]; preferredUpscalerComboBox.Parent  := FOsSpatialSec;

    spoofCheckBox.AnchorSideLeft.Control   := nil; spoofCheckBox.AnchorSideTop.Control    := nil;
    spoofCheckBox.AnchorSideRight.Control  := nil; spoofCheckBox.AnchorSideBottom.Control := nil;
    spoofCheckBox.Anchors := [akLeft, akTop]; spoofCheckBox.Parent  := FOsSpatialSec;

    forceFsr4Int8CheckBox := TCheckBox.Create(FForm);
    forceFsr4Int8CheckBox.Name := 'forceFsr4Int8CheckBox';
    forceFsr4Int8CheckBox.Caption := 'Force FSR4-i8';
    forceFsr4Int8CheckBox.AnchorSideLeft.Control   := nil; forceFsr4Int8CheckBox.AnchorSideTop.Control    := nil;
    forceFsr4Int8CheckBox.AnchorSideRight.Control  := nil; forceFsr4Int8CheckBox.AnchorSideBottom.Control := nil;
    forceFsr4Int8CheckBox.Anchors := [akLeft, akTop]; forceFsr4Int8CheckBox.Parent  := FOsSpatialSec;

    // --- Sub-card 3: Temporal Upscaler controls ---
    if fgInputLabel = nil then
    begin
      fgInputLabel := TLabel.Create(FForm);
      fgInputLabel.Name := 'fgInputLabel';
      fgInputLabel.Caption := 'FG Input';
    end;
    fgInputLabel.AnchorSideLeft.Control   := nil; fgInputLabel.AnchorSideTop.Control    := nil;
    fgInputLabel.AnchorSideRight.Control  := nil; fgInputLabel.AnchorSideBottom.Control := nil;
    fgInputLabel.Anchors := [akLeft, akTop]; fgInputLabel.Parent  := FOsTemporalSec;

    if fgInputComboBox = nil then
    begin
      fgInputComboBox := TComboBox.Create(FForm);
      fgInputComboBox.Name := 'fgInputComboBox';
      fgInputComboBox.Style := csDropDownList;
    end;
    fgInputComboBox.AnchorSideLeft.Control   := nil; fgInputComboBox.AnchorSideTop.Control    := nil;
    fgInputComboBox.AnchorSideRight.Control  := nil; fgInputComboBox.AnchorSideBottom.Control := nil;
    fgInputComboBox.Anchors := [akLeft, akTop]; fgInputComboBox.Parent  := FOsTemporalSec;

    if fgOutputLabel = nil then
    begin
      fgOutputLabel := TLabel.Create(FForm);
      fgOutputLabel.Name := 'fgOutputLabel';
      fgOutputLabel.Caption := 'FG Output';
    end;
    fgOutputLabel.AnchorSideLeft.Control   := nil; fgOutputLabel.AnchorSideTop.Control    := nil;
    fgOutputLabel.AnchorSideRight.Control  := nil; fgOutputLabel.AnchorSideBottom.Control := nil;
    fgOutputLabel.Anchors := [akLeft, akTop]; fgOutputLabel.Parent  := FOsTemporalSec;

    if fgOutputComboBox = nil then
    begin
      fgOutputComboBox := TComboBox.Create(FForm);
      fgOutputComboBox.Name := 'fgOutputComboBox';
      fgOutputComboBox.Style := csDropDownList;
    end;
    UpdateFrameGenOptionsUI;
    fgOutputComboBox.AnchorSideLeft.Control   := nil; fgOutputComboBox.AnchorSideTop.Control    := nil;
    fgOutputComboBox.AnchorSideRight.Control  := nil; fgOutputComboBox.AnchorSideBottom.Control := nil;
    fgOutputComboBox.Anchors := [akLeft, akTop]; fgOutputComboBox.Parent  := FOsTemporalSec;

    emufp8CheckBox.Caption := 'Force MLFG in RDNA3';
    emufp8CheckBox.Hint    := 'Emulate FP8 to active MLFG';
    emufp8CheckBox.ShowHint := True;
    emufp8CheckBox.AnchorSideLeft.Control   := nil; emufp8CheckBox.AnchorSideTop.Control    := nil;
    emufp8CheckBox.AnchorSideRight.Control  := nil; emufp8CheckBox.AnchorSideBottom.Control := nil;
    emufp8CheckBox.Anchors := [akLeft, akTop]; emufp8CheckBox.Parent  := FOsTemporalSec;

    // Hide legacy FSR version controls
    fsrversionLabel.Visible := False;
    fsrversionComboBox.Visible := False;
    menuscaleTrackBar.Visible := False;
    menuscalevalueLabel.Visible := False;
    mark1Label.Visible := False;
    mark2Label.Visible := False;
    mark3Label.Visible := False;

    // Reparent FakeNVAPI controls → FOsFakeSec
    forcereflexCheckBox.AnchorSideLeft.Control   := nil; forcereflexCheckBox.AnchorSideTop.Control    := nil;
    forcereflexCheckBox.AnchorSideRight.Control  := nil; forcereflexCheckBox.AnchorSideBottom.Control := nil;
    forcereflexCheckBox.Anchors := [akLeft, akTop]; forcereflexCheckBox.Top := 45;
    forcereflexCheckBox.Parent  := FOsFakeSec;

    reflexComboBox.AnchorSideLeft.Control   := nil; reflexComboBox.AnchorSideTop.Control    := nil;
    reflexComboBox.AnchorSideRight.Control  := nil; reflexComboBox.AnchorSideBottom.Control := nil;
    reflexComboBox.Anchors := [akLeft, akTop]; reflexComboBox.Top := 70;
    reflexComboBox.Parent  := FOsFakeSec;

    forcelatencyflexCheckBox.AnchorSideLeft.Control   := nil; forcelatencyflexCheckBox.AnchorSideTop.Control    := nil;
    forcelatencyflexCheckBox.AnchorSideRight.Control  := nil; forcelatencyflexCheckBox.AnchorSideBottom.Control := nil;
    forcelatencyflexCheckBox.Anchors := [akLeft, akTop]; forcelatencyflexCheckBox.Top := 115;
    forcelatencyflexCheckBox.Parent  := FOsFakeSec;

    latencyflexComboBox.AnchorSideLeft.Control   := nil; latencyflexComboBox.AnchorSideTop.Control    := nil;
    latencyflexComboBox.AnchorSideRight.Control  := nil; latencyflexComboBox.AnchorSideBottom.Control := nil;
    latencyflexComboBox.Anchors := [akLeft, akTop]; latencyflexComboBox.Top := 140;
    latencyflexComboBox.Parent  := FOsFakeSec;

    overrideCheckBox.AnchorSideLeft.Control   := nil; overrideCheckBox.AnchorSideTop.Control    := nil;
    overrideCheckBox.AnchorSideRight.Control  := nil; overrideCheckBox.AnchorSideBottom.Control := nil;
    overrideCheckBox.Anchors := [akLeft, akTop]; overrideCheckBox.Top := 190;
    overrideCheckBox.Parent  := FOsFakeSec;
    overrideCheckBox.Visible := False;

    tracelogCheckBox.AnchorSideLeft.Control   := nil; tracelogCheckBox.AnchorSideTop.Control    := nil;
    tracelogCheckBox.AnchorSideRight.Control  := nil; tracelogCheckBox.AnchorSideBottom.Control := nil;
    tracelogCheckBox.Anchors := [akLeft, akTop]; tracelogCheckBox.Top := 235;
    tracelogCheckBox.Parent  := FOsFakeSec;
    tracelogCheckBox.Visible := False;

    // DLL & Options section
    DarkLbl(filenameLabel,    PURPLE); filenameLabel.Transparent    := True;
    DarkCombo(filenameComboBox);
    DarkCheck(spoofCheckBox);
    DarkCheck(emufp8CheckBox);
    DarkCheck(forceFsr4Int8CheckBox);
    forceFsr4Int8CheckBox.Hint := 'Force FSR4-i8' + LineEnding + 'Force INT8 model on unsupported GPUs';
    forceFsr4Int8CheckBox.ShowHint := True;
    forceFsr4Int8CheckBox.Visible := False;
    DarkCheck(optipatcherCheckBox);
    DarkLbl(fsrversionLabel,  PURPLE); fsrversionLabel.Transparent := True;
    DarkCombo(fsrversionComboBox);
    DarkLbl(preferredUpscalerLabel,   GRAY); preferredUpscalerLabel.Transparent := True;
    DarkCombo(preferredUpscalerComboBox);
    if Assigned(fgInputLabel) then
    begin
      DarkLbl(fgInputLabel, GRAY); fgInputLabel.Transparent := True;
    end;
    if Assigned(fgInputComboBox) then
    begin
      DarkCombo(fgInputComboBox);
    end;
    if Assigned(fgOutputLabel) then
    begin
      DarkLbl(fgOutputLabel, GRAY); fgOutputLabel.Transparent := True;
    end;
    if Assigned(fgOutputComboBox) then
    begin
      DarkCombo(fgOutputComboBox);
    end;
    UpdateFrameGenOptionsUI;
    DarkLbl(patcherlistLabel, BLUELK); patcherlistLabel.Transparent := True;
    // In-Game Menu section
    DarkLbl(menuLabel,           PURPLE);
    DarkLbl(menuscalevalueLabel, WHITE);
    menuLabel.Transparent          := True;
    menuscalevalueLabel.Transparent := True;
    DarkLbl(mark1Label,          GRAY); mark1Label.Transparent := True;
    DarkLbl(mark2Label,          GRAY); mark2Label.Transparent := True;
    DarkLbl(mark3Label,          GRAY); mark3Label.Transparent := True;
    DarkLbl(shortcutkeyLabel,    PURPLE); shortcutkeyLabel.Transparent := True;
    if Assigned(dlssenablerToggleLabel) then
    begin
      DarkLbl(dlssenablerToggleLabel, PURPLE);
      dlssenablerToggleLabel.Transparent := True;
    end;
    DarkCombo(shortcutkeyComboBox);
    // FakeNVAPI section
    DarkCheck(forcereflexCheckBox);
    DarkCheck(overrideCheckBox);
    DarkCheck(forcelatencyflexCheckBox);
    DarkCheck(tracelogCheckBox);
    DarkCombo(reflexComboBox);
    DarkCombo(latencyflexComboBox);

    // ── Card 2: Software Status ──────────────────────────────────────────
    MakeCard(FOsStatusCard, 'Software Status');
    statusGroupBox.Visible := False;

    optversionComboBox.Parent  := FOsStatusCard;
    optversionComboBox.Anchors := [akLeft, akTop];
    optversionComboBox.Visible := True;
    DarkCombo(optversionComboBox);

    updateBitBtn.Parent      := FOsStatusCard;
    updateBitBtn.Anchors     := [akLeft, akTop];
    updateBitBtn.Visible     := True;
    updateBitBtn.Caption     := 'Update';
    updateBitBtn.Font.Color  := clWhite;
    updateBitBtn.Font.Size   := 9;
    updateBitBtn.Font.Style  := [fsBold];
    updateBitBtn.Glyph.Clear;
    updateBitBtn.Images      := nil;
    IconPath := GetAppBaseDir + 'data/icons/buttons/24x24/download.png';
    if FileExists(IconPath) then
    begin
      Png := TPortableNetworkGraphic.Create;
      try
        Png.LoadFromFile(IconPath);
        updateBitBtn.Glyph.Assign(Png);
      finally
        Png.Free;
      end;
    end;
    updateBitBtn.Layout  := blGlyphLeft;
    updateBitBtn.Spacing := 6;

    checkupdBitBtn.Parent    := FOsStatusCard;
    checkupdBitBtn.Anchors   := [akLeft, akTop];
    checkupdBitBtn.Visible   := True;
    checkupdBitBtn.Font.Color := clWhite;
    checkupdBitBtn.Font.Size := 9;
    checkupdBitBtn.Layout    := blGlyphLeft;
    checkupdBitBtn.Spacing   := 6;

    updateProgressBar.Parent  := FOsStatusCard;
    updateProgressBar.Anchors := [akLeft, akTop];
    updateProgressBar.Visible := False;   // shown only during update
    updatestatusLabel.Parent  := FOsStatusCard;
    updatestatusLabel.Anchors := [akLeft, akTop];
    updatestatusLabel.Visible := False;   // shown only during update
    DarkLbl(updatestatusLabel, $AAAAAA);
    updatestatusLabel.Transparent := True;

    // Build dot + name + version rows for each library
    for i := 0 to 5 do
    begin
      Dot := TShape.Create(FForm);
      Dot.Parent      := FOsStatusCard;
      Dot.Shape       := stEllipse;
      Dot.Brush.Color := $00888888;
      Dot.Pen.Style   := psClear;
      FOsStatDots[i]  := Dot;

      NLbl := TLabel.Create(FForm);
      NLbl.Parent      := FOsStatusCard;
      NLbl.Caption     := STAT_NAMES[i];
      NLbl.Font.Color  := $AAAAAA;
      NLbl.Font.Size   := 9;
      NLbl.AutoSize    := True;
      NLbl.Transparent := True;
      FOsStatNameLbls[i] := NLbl;

      VLbl := TLabel.Create(FForm);
      VLbl.Parent      := FOsStatusCard;
      VLbl.Caption     := '—';
      VLbl.Font.Color  := $BB99FF;
      VLbl.Font.Size   := 9;
      VLbl.AutoSize    := True;
      VLbl.Transparent := True;
      FOsStatVerLbls[i] := VLbl;
    end;

    RefreshOsStatusDots;
  end;
end;

procedure TOptiScalerTabHelper.RefreshOsStatusDots;
const
  CLR_OK     = $0044BB44;   // green — library found
  CLR_NONE   = $00666666;   // gray  — not installed
  PURPLE     = $BB99FF;
  CLR_UPDATE = $0044AAFF;   // blue highlight — update available
var
  i: Integer;
  Ver, NewTag, VerCaption: string;
  DlssV, FsrV, XessV: string;
  HasAnyUpscaler: Boolean;
  IsDlssEnablerActive: Boolean;
begin
  with FForm do
  begin
    if not Assigned(FOsStatDots[0]) then Exit;

    IsDlssEnablerActive := Assigned(dlssenablerRadioButton) and dlssenablerRadioButton.Checked;

    for i := 0 to 5 do
    begin
      case i of
        0: // OptiScaler
          begin
            Ver := optlabel1.Caption;
            VerCaption := IfThen(Ver <> '', Ver, '—');

            if (not IsDlssEnablerActive) and optLabel2.Visible and (optLabel2.Caption <> '') then
            begin
              // The update notice stores the bare tag in Hint; its caption is
              // a sentence and must not be taken apart to recover the tag.
              NewTag := optLabel2.Hint;
              if NewTag <> '' then
              begin
                VerCaption := VerCaption + ' → ' + NewTag;
                FOsStatVerLbls[0].Caption    := VerCaption;
                FOsStatVerLbls[0].Font.Color := CLR_UPDATE;
                FOsStatDots[0].Brush.Color   := CLR_OK;
                Continue;
              end;
            end;

            FOsStatVerLbls[0].Caption    := VerCaption;
            FOsStatVerLbls[0].Font.Color := PURPLE;
            if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
              FOsStatDots[0].Brush.Color := CLR_OK
            else
              FOsStatDots[0].Brush.Color := CLR_NONE;
          end;

        1: // DLSS / FSR / XeSS
          begin
            DlssV := dlssLabel1.Caption;
            FsrV  := fsrLabel1.Caption;
            XessV := xessLabel1.Caption;

            if (DlssV = '') or (DlssV = '--') then DlssV := '—';
            if (FsrV  = '') or (FsrV  = '--') then FsrV  := '—';
            if (XessV = '') or (XessV = '--') then XessV := '—';

            VerCaption := DlssV + ' / ' + FsrV + ' / ' + XessV;
            FOsStatVerLbls[1].Caption    := VerCaption;
            FOsStatVerLbls[1].Font.Color := PURPLE;

            HasAnyUpscaler := (DlssV <> '—') or (FsrV <> '—') or (XessV <> '—');
            if HasAnyUpscaler then
              FOsStatDots[1].Brush.Color := CLR_OK
            else
              FOsStatDots[1].Brush.Color := CLR_NONE;
          end;

        2: // DLSS Enabler
          begin
            if not IsDlssEnablerActive then
            begin
              FOsStatVerLbls[2].Caption    := '--';
              FOsStatVerLbls[2].Font.Color := PURPLE;
              FOsStatDots[2].Brush.Color   := CLR_NONE;
            end
            else
            begin
              Ver := dlssEnablerVersionLabel.Caption;
              VerCaption := IfThen(Ver <> '', Ver, '—');

              if optLabel2.Visible and (optLabel2.Caption <> '') then
              begin
                NewTag := optLabel2.Hint;
                if NewTag <> '' then
                begin
                  VerCaption := VerCaption + ' → ' + NewTag;
                  FOsStatVerLbls[2].Caption    := VerCaption;
                  FOsStatVerLbls[2].Font.Color := CLR_UPDATE;
                  FOsStatDots[2].Brush.Color   := CLR_OK;
                  Continue;
                end;
              end;

              FOsStatVerLbls[2].Caption    := VerCaption;
              FOsStatVerLbls[2].Font.Color := PURPLE;
              if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
                FOsStatDots[2].Brush.Color := CLR_OK
              else
                FOsStatDots[2].Brush.Color := CLR_NONE;
            end;
          end;

        3: // FakeNVAPI
          begin
            Ver := fakenvapi1.Caption;
            VerCaption := IfThen(Ver <> '', Ver, '—');
            FOsStatVerLbls[3].Caption    := VerCaption;
            FOsStatVerLbls[3].Font.Color := PURPLE;
            if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
              FOsStatDots[3].Brush.Color := CLR_OK
            else
              FOsStatDots[3].Brush.Color := CLR_NONE;
          end;

        4: // Streamline SDK
          begin
            if Assigned(streamlineVersionLabel) then
              Ver := streamlineVersionLabel.Caption
            else
              Ver := '';
            VerCaption := IfThen(Ver <> '', Ver, '—');
            FOsStatVerLbls[4].Caption    := VerCaption;
            FOsStatVerLbls[4].Font.Color := PURPLE;
            if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
              FOsStatDots[4].Brush.Color := CLR_OK
            else
              FOsStatDots[4].Brush.Color := CLR_NONE;
          end;

        5: // OptiPatcher
          begin
            Ver := optipatcherLabel1.Caption;
            VerCaption := IfThen(Ver <> '', Ver, '—');
            FOsStatVerLbls[5].Caption    := VerCaption;
            FOsStatVerLbls[5].Font.Color := PURPLE;
            if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
              FOsStatDots[5].Brush.Color := CLR_OK
            else
              FOsStatDots[5].Brush.Color := CLR_NONE;
          end;
      end;
    end;

    ReflowOptiScalerTabNew(0);
  end;
end;

procedure TOptiScalerTabHelper.ReflowOptiScalerTabNew(AContentW: Integer);
const
  MARGIN  = 4;    // outer margin inside scroll box
  GAP     = 6;    // gap between cards
  HDR     = 34;   // accent bar (3) + title area (31)
  PAD     = 14;   // inner horizontal padding
  GPU_GH  = 68;   // reduced from 96
  GPU_H   = HDR + GPU_GH;    // 102 (reduced from 130)
  DOT_SZ    = 10;
  ROW_H     = 26;   // standard row height
  STAT_ROWS = 3;    // 3 rows × 2 columns
  CB_H      = 26;   // combo height
  BTN_H     = 32;   // update buttons height
  PB_H      = 16;   // progress bar height
  STAT_H    = HDR + 6 + BTN_H + 8 + STAT_ROWS * ROW_H + 12;
  BOX_TOP = 6;
  IMARGIN = 4;
  IGAP    = 6;
var
  CW, CardW, CardTop, Y, Row, DotY, TotalH, ItemW, LogoW: Integer;
  MesaW, NvW: Integer;
  ColX, MaxNameW: array[0..1] of Integer;
  ColW, i, Col, RowIdx: Integer;
  InnerW, SubCardW, OptH, BoxH, MinOptH: Integer;
  OptW, FakeW, ColM, X1, X2, X3, X4, Y0: Integer;
  ComboW, CheckW: Integer;
  SliderW, TotalW, StartX: Integer;
  TBarMargin, TrackL: Integer;
begin
  with FForm do
  begin
    if not Assigned(FOsScrollBox) then Exit;
    CW := FOsScrollBox.ClientWidth - 2 * MARGIN;
    if CW < 100 then Exit;

    TotalH := FOsScrollBox.ClientHeight;
    if TotalH < 100 then TotalH := 600;

    MinOptH := 315;
    CardTop := TotalH - MARGIN - STAT_H;
    if CardTop < MARGIN + GPU_H + GAP + MinOptH + GAP then
    begin
      OptH := MinOptH;
      CardTop := MARGIN + GPU_H + GAP + OptH + GAP;
      TotalH := CardTop + STAT_H + MARGIN;
    end
    else
    begin
      OptH := CardTop - GAP - (MARGIN + GPU_H + GAP);
    end;

    FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, Max(FOsScrollBox.ClientHeight, TotalH));

    CardW := (CW - GAP) div 2;

    // ── Card 0a: Upscaler (Left 50%) ────────────────────────────────────
    if Assigned(FOsUpscalerCard) then
    begin
      FOsUpscalerCard.SetBounds(MARGIN, MARGIN, CardW, GPU_H);
      ItemW := (CardW - 2 * PAD) div 2;
      LogoW := Min(120, Max(40, ItemW - 36));

      if Assigned(optiscalerRadioButton) then
        optiscalerRadioButton.SetBounds(PAD, HDR + (GPU_GH - 20) div 2, 20, 20);
      if Assigned(optiscalerLogoImage) then
        optiscalerLogoImage.SetBounds(PAD + 22, HDR + (GPU_GH - 17) div 2, LogoW, 17);

      if Assigned(dlssenablerRadioButton) then
        dlssenablerRadioButton.SetBounds(PAD + ItemW, HDR + (GPU_GH - 20) div 2, 20, 20);
      if Assigned(dlssEnablerLogoImage) then
        dlssEnablerLogoImage.SetBounds(PAD + ItemW + 22, HDR + (GPU_GH - 18) div 2, LogoW, 18);
    end;

    // ── Card 0b: GPU Driver (Right 50%) ─────────────────────────────────
    FOsGpuCard.SetBounds(MARGIN + CardW + GAP, MARGIN, CW - CardW - GAP, GPU_H);
    ItemW := (CardW - 2 * PAD) div 2;

    MesaW := Min(144, ItemW - 24);
    mesaRadioButton.SetBounds(PAD, HDR + (GPU_GH - 20) div 2 - 2, 20, 20);
    mesaImage.SetBounds(PAD + 22, HDR + (GPU_GH - 58) div 2 - 2, MesaW, 58);
    autodetectmesaLabel.SetBounds(PAD + 22 + (MesaW - autodetectmesaLabel.Width) div 2, HDR + GPU_GH - autodetectmesaLabel.Height - 2, autodetectmesaLabel.Width, autodetectmesaLabel.Height);

    NvW := Min(185, ItemW - 24);
    nvidiaRadioButton.SetBounds(PAD + ItemW, HDR + (GPU_GH - 20) div 2 - 2, 20, 20);
    nvidiaImage.SetBounds(PAD + ItemW + 22, HDR + (GPU_GH - 42) div 2 - 2, NvW, 42);
    autodetectnvLabel.SetBounds(PAD + ItemW + 22 + (NvW - autodetectnvLabel.Width) div 2, HDR + GPU_GH - autodetectnvLabel.Height - 2, autodetectnvLabel.Width, autodetectnvLabel.Height);

    // ── Card 1: Options (4 Equal Columns: Main 25%, Spatial 25%, Temporal 25%, Reflex/Antilag 25%) ──
    FOsOptionsCard.SetBounds(MARGIN, MARGIN + GPU_H + GAP, CW, OptH);

    InnerW := CW - 2 * IMARGIN;
    ColW   := (InnerW - 3 * IGAP) div 4;
    if ColW < 100 then ColW := 100;

    BoxH   := OptH - HDR - 12;
    if BoxH < 240 then BoxH := 240;

    X1 := IMARGIN;
    X2 := IMARGIN + ColW + IGAP;
    X3 := IMARGIN + 2 * (ColW + IGAP);
    X4 := IMARGIN + 3 * (ColW + IGAP);

    if Assigned(FOsMainSec) then
      FOsMainSec.SetBounds(X1, HDR + BOX_TOP, ColW, BoxH);
    if Assigned(FOsSpatialSec) then
      FOsSpatialSec.SetBounds(X2, HDR + BOX_TOP, ColW, BoxH);
    if Assigned(FOsTemporalSec) then
      FOsTemporalSec.SetBounds(X3, HDR + BOX_TOP, ColW, BoxH);
    if Assigned(FOsFakeSec) then
      FOsFakeSec.SetBounds(X4, HDR + BOX_TOP, InnerW - 3 * (ColW + IGAP), BoxH);

    if Assigned(FOsImgSec) then
      FOsImgSec.Visible := False;

    Y0 := 36;
    ComboW := Min(ColW - 20, 165);

    // Reflow Sub-card 1: Main
    if Assigned(FOsMainSec) then
    begin
      if Assigned(FOsMainLbl) then FOsMainLbl.SetBounds(10, 6, ColW - 20, 16);

      filenameLabel.SetBounds(10, Y0, ColW - 20, 16);
      filenameComboBox.SetBounds(10, Y0 + 18, ComboW, 26);

      menuLabel.Caption := 'Menu scale';
      menuLabel.SetBounds(10, Y0 + 56, ColW - 20, 16);
      if Assigned(menuscaleComboBox) then
        menuscaleComboBox.SetBounds(10, Y0 + 74, ComboW, 26);

      optipatcherCheckBox.SetBounds(10, Y0 + 124, 95, 20);
      if Assigned(FOsPatcherListBtn) then
        FOsPatcherListBtn.SetBounds(108, Y0 + 122, 22, 22);

      shortcutkeyLabel.SetBounds(10, Y0 + 166, ColW - 20, 16);
      if Assigned(FOsShortcutCaptureBtn) then
        FOsShortcutCaptureBtn.SetBounds(10, Y0 + 184, Min(ColW - 20, 120), 28);

      if Assigned(dlssenablerToggleLabel) then
        dlssenablerToggleLabel.SetBounds(10, Y0 + 218, ColW - 20, 16);
      if Assigned(dlssenablerToggleBtn) then
        dlssenablerToggleBtn.SetBounds(10, Y0 + 236, Min(ColW - 20, 120), 28);
    end;

    // Reflow Sub-card 2: Spatial Upscaler
    if Assigned(FOsSpatialSec) then
    begin
      if Assigned(FOsSpatialLbl) then FOsSpatialLbl.SetBounds(10, 6, ColW - 20, 16);

      preferredUpscalerLabel.SetBounds(10, Y0, ColW - 20, 16);
      preferredUpscalerComboBox.SetBounds(10, Y0 + 18, ComboW, 26);

      spoofCheckBox.SetBounds(10, Y0 + 56, ColW - 20, 20);
      forceFsr4Int8CheckBox.SetBounds(10, Y0 + 88, ColW - 20, 20);
    end;

    // Reflow Sub-card 3: Temporal Upscaler
    if Assigned(FOsTemporalSec) then
    begin
      if Assigned(FOsTemporalLbl) then FOsTemporalLbl.SetBounds(10, 6, ColW - 20, 16);

      fgInputLabel.SetBounds(10, Y0, ColW - 20, 16);
      fgInputComboBox.SetBounds(10, Y0 + 18, ComboW, 26);

      fgOutputLabel.SetBounds(10, Y0 + 56, ColW - 20, 16);
      fgOutputComboBox.SetBounds(10, Y0 + 74, ComboW, 26);

      emufp8CheckBox.SetBounds(10, Y0 + 124, ColW - 20, 20);
    end;

    // Reflow Sub-card 4: Reflex / Antilag
    if Assigned(FOsFakeSec) then
    begin
      if Assigned(FOsFakeLbl) then FOsFakeLbl.SetBounds(10, 6, ColW - 20, 16);

      forcereflexCheckBox.SetBounds(10, Y0, ColW - 20, 20);
      reflexComboBox.SetBounds(10, Y0 + 22, ComboW, 26);

      forcelatencyflexCheckBox.SetBounds(10, Y0 + 56, ColW - 20, 20);
      latencyflexComboBox.SetBounds(10, Y0 + 78, ComboW, 26);

      overrideCheckBox.Visible := False;
      tracelogCheckBox.Visible := False;
    end;

    // ── Card 2: Software Status (Anchored to Bottom) ─────────────────────
    FOsStatusCard.SetBounds(MARGIN, CardTop, CW, STAT_H);

    CheckW := 130;
    ComboW := CW - 2 * PAD - 8 - CheckW;
    if ComboW < 80 then ComboW := 80;
    Y := HDR + 6;
    optversionComboBox.SetBounds(PAD, Y + (BTN_H - 28) div 2, ComboW, 28);
    checkupdBitBtn.SetBounds(PAD + ComboW + 8, Y + (BTN_H - 28) div 2, CheckW, 28);
    updateBitBtn.SetBounds(PAD + ComboW + 8, Y + (BTN_H - 28) div 2, CheckW, 28);

    updateProgressBar.SetBounds(PAD, Y + (BTN_H - PB_H) div 2, ComboW, PB_H);
    updatestatusLabel.SetBounds(PAD + ComboW + 4, Y + (BTN_H - PB_H) div 2, CheckW + 4, PB_H);

    Y := Y + BTN_H + 8;
    ColW    := (CW - 2 * PAD) div 2;
    ColX[0] := PAD;
    ColX[1] := PAD + ColW;

    MaxNameW[0] := 0;
    MaxNameW[1] := 0;
    for i := 0 to 5 do
    begin
      Col := i mod 2;
      if FOsStatNameLbls[i].Width > MaxNameW[Col] then
        MaxNameW[Col] := FOsStatNameLbls[i].Width;
    end;

    for i := 0 to 5 do
    begin
      Col    := i mod 2;
      RowIdx := i div 2;
      Row    := Y + RowIdx * ROW_H;
      DotY   := Row + (ROW_H - DOT_SZ) div 2;

      FOsStatDots[i].SetBounds(ColX[Col], DotY, DOT_SZ, DOT_SZ);
      FOsStatNameLbls[i].Left := ColX[Col] + DOT_SZ + 6;
      FOsStatNameLbls[i].Top  := Row + (ROW_H - 16) div 2;

      FOsStatVerLbls[i].Left := ColX[Col] + DOT_SZ + 6 + MaxNameW[Col] + 12;
      FOsStatVerLbls[i].Top  := Row + (ROW_H - 16) div 2;
    end;
  end;
end;

procedure TOptiScalerTabHelper.OsScrollBoxResize(Sender: TObject);
begin
  ReflowOptiScalerTabNew(0);
end;

procedure TOptiScalerTabHelper.LoadOptiScalerConfig;
var
  Settings: TOptiScalerSettings;
  SavedFsrOnChange: TNotifyEvent;
  SavedOptOnChange: TNotifyEvent;
  SavedPreferredUpscalerOnChange: TNotifyEvent;
  Idx: Integer;
begin
  with FForm do
  begin
    if not overlay_config.LoadOptiScalerConfig(FActiveGameName, Settings) then
      Exit;

    // Temporarily disable OnChange handlers to prevent event trigger loops and threads during load
    SavedFsrOnChange := fsrversionComboBox.OnChange;
    SavedOptOnChange := optversionComboBox.OnChange;
    SavedPreferredUpscalerOnChange := preferredUpscalerComboBox.OnChange;
    fsrversionComboBox.OnChange := nil;
    optversionComboBox.OnChange := nil;
    preferredUpscalerComboBox.OnChange := nil;
    try
      filenameComboBox.ItemIndex := Settings.FilenameItemIndex;
      emufp8CheckBox.Checked := Settings.EmuFp8Checked;
      forceFsr4Int8CheckBox.Checked := Settings.ForceFsr4Int8Checked;
      shortcutkeyComboBox.Text := Settings.ShortcutKey;
      if Assigned(FOsShortcutCaptureBtn) then
        FOsShortcutCaptureBtn.Caption := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

      menuscaleTrackBar.Position := Settings.MenuScalePosition;
      if Settings.MenuScalePosition <= 0 then
        menuscalevalueLabel.Caption := 'auto'
      else
        menuscalevalueLabel.Caption := FormatFloat('#0.0', menuscaleTrackBar.Position / 10);
      if Assigned(menuscaleComboBox) then
      begin
        if Settings.MenuScalePosition <= 0 then
          menuscaleComboBox.ItemIndex := 0
        else
        begin
          Idx := Settings.MenuScalePosition - 9; // 10 -> 1 ('1.0'), 20 -> 11 ('2.0')
          if Idx < 1 then Idx := 1;
          if Idx > 11 then Idx := 11;
          menuscaleComboBox.ItemIndex := Idx;
        end;
      end;

      overrideCheckBox.Checked := Settings.OverrideChecked;
      optipatcherCheckBox.Checked := Settings.OptipatcherChecked;

      fsrversionComboBox.ItemIndex := Settings.FsrversionItemIndex;
      spoofCheckBox.Checked := Settings.SpoofChecked;

      forcereflexCheckBox.Checked := Settings.ForceReflexChecked;
      reflexComboBox.ItemIndex := Settings.ReflexItemIndex;
      reflexComboBox.Enabled := forcereflexCheckBox.Checked;

      if nvidiaRadioButton.Checked then
      begin
        forcereflexCheckBox.Enabled := False;
        spoofCheckBox.Enabled := False;
        reflexComboBox.Enabled := False;
      end;

      forcelatencyflexCheckBox.Checked := Settings.ForceLatencyFlexChecked;
      latencyflexComboBox.ItemIndex := Settings.LatencyFlexItemIndex;
      latencyflexComboBox.Enabled := forcelatencyflexCheckBox.Checked;

      tracelogCheckBox.Checked := Settings.TraceLogChecked;
      preferredUpscalerComboBox.ItemIndex := Settings.PreferredUpscalerItemIndex;
      if Assigned(fgInputComboBox) then
        fgInputComboBox.ItemIndex := Settings.FGInputItemIndex;
      if Assigned(fgOutputComboBox) then
        fgOutputComboBox.ItemIndex := Settings.FGOutputItemIndex;

      if Settings.UpscalerTypeItemIndex = 1 then
      begin
        dlssenablerRadioButton.Checked := True;
        optiscalerRadioButton.Checked := False;
        optversionComboBox.Enabled := True;
        if Settings.OptVersionItemIndex in [0, 1] then
          optversionComboBox.ItemIndex := Settings.OptVersionItemIndex
        else
          optversionComboBox.ItemIndex := 0;
      end
      else
      begin
        optiscalerRadioButton.Checked := True;
        dlssenablerRadioButton.Checked := False;
        optversionComboBox.Enabled := True;
        if Settings.OptVersionItemIndex in [0, 1] then
          optversionComboBox.ItemIndex := Settings.OptVersionItemIndex
        else
          optversionComboBox.ItemIndex := 0;
      end;
      UpdateUpscalerImageOpacity;
      UpdateFrameGenOptionsUI;
    finally
      // Restore OnChange handlers
      fsrversionComboBox.OnChange := SavedFsrOnChange;
      optversionComboBox.OnChange := SavedOptOnChange;
      preferredUpscalerComboBox.OnChange := SavedPreferredUpscalerOnChange;
    end;

    // Manually trigger the sync updates once after loading to ensure UI matches the loaded state
    fsrversionComboBoxChange(nil);
  end;
end;

procedure TOptiScalerTabHelper.SaveOptiScalerConfig(ASilent: Boolean);
var
  Settings: TOptiScalerSettings;
  ErrMsg: string;
  LaunchCommand: string;
begin
  with FForm do
  begin
    Settings.ActiveGameName := FActiveGameName;
    Settings.Version := GVERSION;
    Settings.Channel := GCHANNEL;
    Settings.FilenameItemIndex := filenameComboBox.ItemIndex;
    Settings.EmuFp8Checked := emufp8CheckBox.Checked;
    Settings.ForceFsr4Int8Checked := forceFsr4Int8CheckBox.Checked;
    Settings.ShortcutKey := shortcutkeyComboBox.Text;
    if Assigned(menuscaleComboBox) and (menuscaleComboBox.ItemIndex >= 0) then
    begin
      if menuscaleComboBox.ItemIndex = 0 then
        Settings.MenuScalePosition := 0
      else
        Settings.MenuScalePosition := 9 + menuscaleComboBox.ItemIndex;
      menuscaleTrackBar.Position := Settings.MenuScalePosition;
    end
    else
      Settings.MenuScalePosition := menuscaleTrackBar.Position;
    Settings.OverrideChecked := overrideCheckBox.Checked;
    Settings.SpoofChecked := spoofCheckBox.Checked;
    Settings.FsrversionItemIndex := fsrversionComboBox.ItemIndex;
    Settings.OptipatcherChecked := optipatcherCheckBox.Checked;
    Settings.OptVersionItemIndex := optversionComboBox.ItemIndex;
    Settings.ForceReflexChecked := forcereflexCheckBox.Checked;
    Settings.ReflexItemIndex := reflexComboBox.ItemIndex;
    Settings.ForceLatencyFlexChecked := forcelatencyflexCheckBox.Checked;
    Settings.LatencyFlexItemIndex := latencyflexComboBox.ItemIndex;
    Settings.TraceLogChecked := tracelogCheckBox.Checked;
    Settings.PreferredUpscalerItemIndex := preferredUpscalerComboBox.ItemIndex;
    if Assigned(fgInputComboBox) then
      Settings.FGInputItemIndex := fgInputComboBox.ItemIndex
    else
      Settings.FGInputItemIndex := 0;
    if Assigned(fgOutputComboBox) then
      Settings.FGOutputItemIndex := fgOutputComboBox.ItemIndex
    else
      Settings.FGOutputItemIndex := 0;
    if Assigned(dlssenablerRadioButton) and dlssenablerRadioButton.Checked then
      Settings.UpscalerTypeItemIndex := 1
    else
      Settings.UpscalerTypeItemIndex := 0;

    if not SaveOptiScalerConfigCore(Settings, ENV_GAMEMODERUN, LAUNCH_COMMAND_SUFFIX, GetPerformanceCheckBox(0).Checked, FActiveGameIsNonSteam, FActiveGameIsNonSteam, ErrMsg, LaunchCommand) then
    begin
      if ErrMsg <> '' then
        ShowMessage(ErrMsg);
      Exit;
    end;

    // Immediately sync global profile assets (DLLs, plugins, configs) when saving global profile
    if FActiveGameName = '' then
      InitializeGlobalConfigDirectory;

    if ErrMsg <> '' then
      ShowMessage(ErrMsg);

    // if not ASilent then
    //   SendNotification('OptiScaler', 'Configuration saved', GetIconFile);

    if Assigned(FOptiscalerUpdate) then
    begin
      FOptiscalerUpdate.LoadVersionsFromFile;
      RefreshOsStatusDots;
    end;

    if not ASilent then
    begin
      notificationLabel.Visible := False;
      FLaunchCommand := LaunchCommand;
      commandPaintBox.Invalidate;
    end;
  end;
end;

procedure TOptiScalerTabHelper.UpdateFrameGenOptionsUI;
var
  IsDLSSEnabler: Boolean;
  PrevInputText, PrevOutputText: string;
  Idx: Integer;
begin
  if (FForm = nil) or (FForm.fgInputComboBox = nil) or (FForm.fgOutputComboBox = nil) then Exit;

  IsDLSSEnabler := Assigned(FForm.dlssenablerRadioButton) and FForm.dlssenablerRadioButton.Checked;

  if Assigned(FForm.dlssenablerToggleLabel) then
    FForm.dlssenablerToggleLabel.Visible := IsDLSSEnabler;
  if Assigned(FForm.dlssenablerToggleBtn) then
    FForm.dlssenablerToggleBtn.Visible := IsDLSSEnabler;

  PrevInputText := FForm.fgInputComboBox.Text;
  PrevOutputText := FForm.fgOutputComboBox.Text;

  if IsDLSSEnabler and SameText(PrevInputText, 'nukems') then
    PrevInputText := 'nvngxfg'
  else if (not IsDLSSEnabler) and SameText(PrevInputText, 'nvngxfg') then
    PrevInputText := 'nukems';

  if IsDLSSEnabler and SameText(PrevOutputText, 'nukems') then
    PrevOutputText := 'nvngxfg'
  else if (not IsDLSSEnabler) and SameText(PrevOutputText, 'nvngxfg') then
    PrevOutputText := 'nukems';

  // 1. FG Input Items & Hint
  FForm.fgInputComboBox.Items.BeginUpdate;
  try
    FForm.fgInputComboBox.Items.Clear;
    FForm.fgInputComboBox.Items.Add('auto');
    FForm.fgInputComboBox.Items.Add('nofg');
    FForm.fgInputComboBox.Items.Add('dlssg');
    if IsDLSSEnabler then
      FForm.fgInputComboBox.Items.Add('nvngxfg')
    else
      FForm.fgInputComboBox.Items.Add('nukems');
    FForm.fgInputComboBox.Items.Add('fsrfg');
    FForm.fgInputComboBox.Items.Add('upscaler');
    FForm.fgInputComboBox.Items.Add('fsrfg30');
  finally
    FForm.fgInputComboBox.Items.EndUpdate;
  end;

  Idx := FForm.fgInputComboBox.Items.IndexOf(PrevInputText);
  if Idx >= 0 then
    FForm.fgInputComboBox.ItemIndex := Idx
  else
    FForm.fgInputComboBox.ItemIndex := 0;

  if IsDLSSEnabler then
  begin
    FForm.fgInputComboBox.Hint := 'Selected FG Input/Source:' + LineEnding +
      'dlssg - Can be used with any FG Output. Supports Hudless out of the box. Limited to games that use Streamline and DLSSG' + LineEnding +
      'nvngxfg - Limited to FSR 3 FG (MFG with DLSS Enabler''s dll). Requires DLSSG in the game. Supports Hudless out of the box. Uses Streamline swapchain for pacing.' + LineEnding +
      'fsrfg - Can be used with any FG Output. Supports Hudless out of the box.' + LineEnding +
      'upscaler - Upscaler must be enabled. Can be used with any FG Output, but might be imperfect with some. To prevent UI glitching, Hudfix is required' + LineEnding +
      'fsrfg30 - Can be used with any FG Output. Supports Hudless out of the box.';
  end
  else
  begin
    FForm.fgInputComboBox.Hint := 'Selected FG Input/Source:' + LineEnding +
      'dlssg - Can be used with any FG Output. Supports Hudless out of the box. Limited to games that use Streamline v2 and DLSSG' + LineEnding +
      'nukems - Limited to FSR 3 FG. Requires DLSSG in the game. Supports Hudless out of the box. Uses Streamline swapchain for pacing.' + LineEnding +
      'fsrfg - Can be used with any FG Output. Supports Hudless out of the box.' + LineEnding +
      'upscaler - Upscaler must be enabled. Can be used with any FG Output, but might be imperfect with some. To prevent UI glitching, Hudfix is required' + LineEnding +
      'fsrfg30 - Can be used with any FG Output. Supports Hudless out of the box.';
  end;
  FForm.fgInputComboBox.ShowHint := True;

  // 2. FG Output Items & Hint
  FForm.fgOutputComboBox.Items.BeginUpdate;
  try
    FForm.fgOutputComboBox.Items.Clear;
    FForm.fgOutputComboBox.Items.Add('auto');
    FForm.fgOutputComboBox.Items.Add('nofg');
    FForm.fgOutputComboBox.Items.Add('fsrfg');
    FForm.fgOutputComboBox.Items.Add('xefg');
    if IsDLSSEnabler then
    begin
      FForm.fgOutputComboBox.Items.Add('nvngxfg');
      FForm.fgOutputComboBox.Items.Add('dlssg');
      FForm.fgOutputComboBox.Items.Add('dlssgwithnvngx');
    end
    else
    begin
      FForm.fgOutputComboBox.Items.Add('nukems');
    end;
  finally
    FForm.fgOutputComboBox.Items.EndUpdate;
  end;

  Idx := FForm.fgOutputComboBox.Items.IndexOf(PrevOutputText);
  if Idx >= 0 then
    FForm.fgOutputComboBox.ItemIndex := Idx
  else
    FForm.fgOutputComboBox.ItemIndex := 0;

  if IsDLSSEnabler then
  begin
    FForm.fgOutputComboBox.Hint := 'Selected FG Output:' + LineEnding +
      'fsrfg - requires amd_fidelityfx_dx12.dll OR amd_fidelityfx_loader_dx12.dll + amd_fidelityfx_framegeneration_dx12.dll' + LineEnding +
      'xefg - requires libxess_fg.dll and libxell.dll' + LineEnding +
      'nvngxfg - requires dlssg_to_fsr3_amd_is_better.dll OR dlss-enabler-headless.dll' + LineEnding +
      'dlssg - requires streamline dlls inside ''OptiScaler/streamline'' folder + nvngx_dlssg.dll' + LineEnding +
      'dlssgwithnvngx - requires dlssg_to_fsr3_amd_is_better.dll OR dlss-enabler-headless.dll + streamline dlls inside ''OptiScaler/streamline'' folder';
  end
  else
  begin
    FForm.fgOutputComboBox.Hint := 'Selected FG Output:' + LineEnding +
      'fsrfg - requires amd_fidelityfx_dx12.dll or amd_fidelityfx_loader_dx12.dll + amd_fidelityfx_framegeneration_dx12.dll' + LineEnding +
      'xefg - requires libxess_fg.dll, libxell.dll and latest fakenvapi dll' + LineEnding +
      'nukems - requires dlssg_to_fsr3_amd_is_better.dll, AMD/Intel GPU users need to add fakenvapi as well';
  end;
  FForm.fgOutputComboBox.ShowHint := True;
end;

end.
