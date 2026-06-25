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
    procedure RefreshOsStatusDots;
    procedure LoadOptiScalerConfig;
    procedure SaveOptiScalerConfig;
  end;

function OsHexToKeyStr(const HexStr: string): string;

implementation

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
      Card.Parent     := FOsBgPanel;
      Card.BevelOuter := bvNone;
      Card.BorderStyle := bsNone;
      Card.Color      := BG;
      Card.Caption    := '';
      Card.OnPaint    := @SubCardPaint;
      Lbl := TLabel.Create(Card);
      Lbl.Parent      := Card;
      Lbl.Caption     := ATitle;
      Lbl.Font.Color  := WHITE;
      Lbl.Font.Size   := 10;
      Lbl.Font.Style  := [fsBold];
      Lbl.AutoSize    := True;
      Lbl.SetBounds(12, 8, 200, 22);
      Lbl.Transparent := True;
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
      GB.Color    := BG;
      GB.Font.Color := WHITE;
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
    C.ParentColor := True; C.Font.Color := WHITE; C.Font.Size := 9;
  end;

  procedure DarkRadio(R: TRadioButton);
  begin
    R.ParentColor := False; R.Color := BG; R.Font.Color := WHITE; R.Font.Size := 9;
  end;

  procedure DarkCombo(C: TComboBox);
  begin
    C.Color := COMBOBG; C.Font.Color := WHITE; C.Font.Size := 9;
  end;

  procedure DarkLbl(L: TLabel; AColor: TColor);
  begin
    L.Color      := BG;
    L.Font.Color := AColor;
    L.Font.Size  := 9;
    L.Transparent := False;
  end;

const
  STAT_NAMES: array[0..5] of string = (
    'OptiScaler', 'FakeNVAPI', 'FSR', 'XeSS', 'DLSS', 'OptiPatcher');
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
    FOsScrollBox.Parent      := optiscalerTabSheet;
    FOsScrollBox.Align       := alClient;
    FOsScrollBox.AutoScroll  := True;
    FOsScrollBox.BorderStyle := bsNone;
    FOsScrollBox.HorzScrollBar.Visible := False;
    FOsScrollBox.Color       := $1E1E2E;
    FOsScrollBox.ParentColor := False;

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

    // ── Card 0: GPU Driver ──────────────────────────────────────────────
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
    DarkRadio(nvidiaRadioButton);

    mesaRadioButton.AnchorSideLeft.Control   := nil;
    mesaRadioButton.AnchorSideTop.Control    := nil;
    mesaRadioButton.AnchorSideRight.Control  := nil;
    mesaRadioButton.AnchorSideBottom.Control := nil;
    mesaRadioButton.Anchors := [akLeft, akTop];
    mesaRadioButton.Top     := mesaRadioButton.Top + 62;
    mesaRadioButton.Parent  := FOsGpuCard;
    DarkRadio(mesaRadioButton);

    nvidiaImage.AnchorSideLeft.Control   := nil;
    nvidiaImage.AnchorSideTop.Control    := nil;
    nvidiaImage.AnchorSideRight.Control  := nil;
    nvidiaImage.AnchorSideBottom.Control := nil;
    nvidiaImage.Anchors     := [akLeft, akTop];
    nvidiaImage.Top         := nvidiaImage.Top + 62;
    nvidiaImage.Transparent := True;
    nvidiaImage.Parent      := FOsGpuCard;

    mesaImage.AnchorSideLeft.Control   := nil;
    mesaImage.AnchorSideTop.Control    := nil;
    mesaImage.AnchorSideRight.Control  := nil;
    mesaImage.AnchorSideBottom.Control := nil;
    mesaImage.Anchors     := [akLeft, akTop];
    mesaImage.Top         := mesaImage.Top + 62;
    mesaImage.Transparent := True;
    mesaImage.Parent      := FOsGpuCard;

    autodetectnvLabel.AnchorSideLeft.Control   := nil;
    autodetectnvLabel.AnchorSideTop.Control    := nil;
    autodetectnvLabel.AnchorSideRight.Control  := nil;
    autodetectnvLabel.AnchorSideBottom.Control := nil;
    autodetectnvLabel.Anchors     := [akLeft, akTop];
    autodetectnvLabel.Top         := autodetectnvLabel.Top + 62;
    autodetectnvLabel.Transparent := True;
    autodetectnvLabel.Font.Color  := GREEN;
    autodetectnvLabel.Parent      := FOsGpuCard;

    autodetectmesaLabel.AnchorSideLeft.Control   := nil;
    autodetectmesaLabel.AnchorSideTop.Control    := nil;
    autodetectmesaLabel.AnchorSideRight.Control  := nil;
    autodetectmesaLabel.AnchorSideBottom.Control := nil;
    autodetectmesaLabel.Anchors     := [akLeft, akTop];
    autodetectmesaLabel.Top         := autodetectmesaLabel.Top + 62;
    autodetectmesaLabel.Transparent := True;
    autodetectmesaLabel.Font.Color  := GREEN;
    autodetectmesaLabel.Parent      := FOsGpuCard;

    gpudriverGroupBox.Visible := False;

    // ── Card 1: Options (3-column inner layout) ─────────────────────────
    MakeCard(FOsOptionsCard, 'Options');
    optionsGroupBox.Visible    := False;
    optiscalerGroupBox.Visible := False;
    imgmenuGroupBox.Visible    := False;
    fakenvapiGroupBox.Visible  := False;

    FOsOptiSec := TPanel.Create(FForm);
    FOsOptiSec.Parent      := FOsOptionsCard;
    FOsOptiSec.BevelOuter  := bvNone;
    FOsOptiSec.BorderStyle := bsNone;
    FOsOptiSec.Caption     := '';
    FOsOptiSec.Color       := BG;
    FOsOptiSec.OnPaint     := @SubCardPaint;
    with TLabel.Create(FOsOptiSec) do begin
      Parent := FOsOptiSec; Caption := 'OptiScaler';
      Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
      Left := 6; Top := 4; Transparent := True; AutoSize := True;
    end;

    FOsImgSec := TPanel.Create(FForm);
    FOsImgSec.Parent      := FOsOptionsCard;
    FOsImgSec.BevelOuter  := bvNone;
    FOsImgSec.BorderStyle := bsNone;
    FOsImgSec.Caption     := '';
    FOsImgSec.Color       := BG;
    FOsImgSec.OnPaint     := @SubCardPaint;
    with TLabel.Create(FOsImgSec) do begin
      Parent := FOsImgSec; Caption := 'ImGUI Menu';
      Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
      Left := 6; Top := 4; Transparent := True; AutoSize := True;
    end;

    FOsFakeSec := TPanel.Create(FForm);
    FOsFakeSec.Parent      := FOsOptionsCard;
    FOsFakeSec.BevelOuter  := bvNone;
    FOsFakeSec.BorderStyle := bsNone;
    FOsFakeSec.Caption     := '';
    FOsFakeSec.Color       := BG;
    FOsFakeSec.OnPaint     := @SubCardPaint;
    with TLabel.Create(FOsFakeSec) do begin
      Parent := FOsFakeSec; Caption := 'FakeNVAPI';
      Font.Color := $00CCAAAA; Font.Style := [fsBold]; Font.Size := 8;
      Left := 6; Top := 4; Transparent := True; AutoSize := True;
    end;

    // Reparent OptiScaler controls → FOsOptiSec (top += 22 past section title)
    filenameLabel.AnchorSideLeft.Control   := nil; filenameLabel.AnchorSideTop.Control    := nil;
    filenameLabel.AnchorSideRight.Control  := nil; filenameLabel.AnchorSideBottom.Control := nil;
    filenameLabel.Anchors := [akLeft, akTop]; filenameLabel.Top := 45;
    filenameLabel.Parent  := FOsOptiSec;

    filenameComboBox.AnchorSideLeft.Control   := nil; filenameComboBox.AnchorSideTop.Control    := nil;
    filenameComboBox.AnchorSideRight.Control  := nil; filenameComboBox.AnchorSideBottom.Control := nil;
    filenameComboBox.Anchors := [akLeft, akTop]; filenameComboBox.Top := 66;
    filenameComboBox.Parent  := FOsOptiSec;

    spoofCheckBox.AnchorSideLeft.Control   := nil; spoofCheckBox.AnchorSideTop.Control    := nil;
    spoofCheckBox.AnchorSideRight.Control  := nil; spoofCheckBox.AnchorSideBottom.Control := nil;
    spoofCheckBox.Anchors := [akLeft, akTop]; spoofCheckBox.Top := 72;
    spoofCheckBox.Parent  := FOsOptiSec;

    fsrversionLabel.AnchorSideLeft.Control   := nil; fsrversionLabel.AnchorSideTop.Control    := nil;
    fsrversionLabel.AnchorSideRight.Control  := nil; fsrversionLabel.AnchorSideBottom.Control := nil;
    fsrversionLabel.Anchors := [akLeft, akTop]; fsrversionLabel.Top := 115;
    fsrversionLabel.Parent  := FOsOptiSec;

    fsrversionComboBox.AnchorSideLeft.Control   := nil; fsrversionComboBox.AnchorSideTop.Control    := nil;
    fsrversionComboBox.AnchorSideRight.Control  := nil; fsrversionComboBox.AnchorSideBottom.Control := nil;
    fsrversionComboBox.Anchors := [akLeft, akTop]; fsrversionComboBox.Top := 136;
    fsrversionComboBox.Parent  := FOsOptiSec;

    emufp8CheckBox.AnchorSideLeft.Control   := nil; emufp8CheckBox.AnchorSideTop.Control    := nil;
    emufp8CheckBox.AnchorSideRight.Control  := nil; emufp8CheckBox.AnchorSideBottom.Control := nil;
    emufp8CheckBox.Anchors := [akLeft, akTop]; emufp8CheckBox.Top := 142;
    emufp8CheckBox.Parent  := FOsOptiSec;

    osversionLabel.AnchorSideLeft.Control   := nil; osversionLabel.AnchorSideTop.Control    := nil;
    osversionLabel.AnchorSideRight.Control  := nil; osversionLabel.AnchorSideBottom.Control := nil;
    osversionLabel.Anchors := [akLeft, akTop]; osversionLabel.Top := 190;
    osversionLabel.Parent  := FOsOptiSec;

    protontricksManagerButton.AnchorSideLeft.Control   := nil; protontricksManagerButton.AnchorSideTop.Control    := nil;
    protontricksManagerButton.AnchorSideRight.Control  := nil; protontricksManagerButton.AnchorSideBottom.Control := nil;
    protontricksManagerButton.Anchors := [akLeft, akTop]; protontricksManagerButton.Top := 211;
    protontricksManagerButton.Parent  := FOsOptiSec;

    optipatcherCheckBox.AnchorSideLeft.Control   := nil; optipatcherCheckBox.AnchorSideTop.Control    := nil;
    optipatcherCheckBox.AnchorSideRight.Control  := nil; optipatcherCheckBox.AnchorSideBottom.Control := nil;
    optipatcherCheckBox.Anchors := [akLeft, akTop]; optipatcherCheckBox.Top := 216;
    optipatcherCheckBox.Left    := 134;
    optipatcherCheckBox.Parent  := FOsOptiSec;

    patcherlistLabel.AnchorSideLeft.Control   := nil; patcherlistLabel.AnchorSideTop.Control    := nil;
    patcherlistLabel.AnchorSideRight.Control  := nil; patcherlistLabel.AnchorSideBottom.Control := nil;
    patcherlistLabel.Anchors := [akLeft, akTop]; patcherlistLabel.Top := 238;
    patcherlistLabel.Left    := 142;
    patcherlistLabel.Parent  := FOsOptiSec;

    // Reparent ImGUI Menu controls → FOsImgSec
    menuLabel.AnchorSideLeft.Control   := nil; menuLabel.AnchorSideTop.Control    := nil;
    menuLabel.AnchorSideRight.Control  := nil; menuLabel.AnchorSideBottom.Control := nil;
    menuLabel.Anchors := [akLeft, akTop]; menuLabel.Top := 45;
    menuLabel.Parent  := FOsImgSec;

    menuscalevalueLabel.AnchorSideLeft.Control   := nil; menuscalevalueLabel.AnchorSideTop.Control    := nil;
    menuscalevalueLabel.AnchorSideRight.Control  := nil; menuscalevalueLabel.AnchorSideBottom.Control := nil;
    menuscalevalueLabel.Anchors := [akLeft, akTop]; menuscalevalueLabel.Top := 70;
    menuscalevalueLabel.Left    := 252;
    menuscalevalueLabel.Parent  := FOsImgSec;

    menuscaleTrackBar.AnchorSideLeft.Control   := nil; menuscaleTrackBar.AnchorSideTop.Control    := nil;
    menuscaleTrackBar.AnchorSideRight.Control  := nil; menuscaleTrackBar.AnchorSideBottom.Control := nil;
    menuscaleTrackBar.Anchors := [akLeft, akTop]; menuscaleTrackBar.Top := 70;
    menuscaleTrackBar.Parent  := FOsImgSec;

    mark1Label.AnchorSideLeft.Control   := nil; mark1Label.AnchorSideTop.Control    := nil;
    mark1Label.AnchorSideRight.Control  := nil; mark1Label.AnchorSideBottom.Control := nil;
    mark1Label.Anchors := [akLeft, akTop]; mark1Label.Top := 95;
    mark1Label.Parent  := FOsImgSec;

    mark2Label.AnchorSideLeft.Control   := nil; mark2Label.AnchorSideTop.Control    := nil;
    mark2Label.AnchorSideRight.Control  := nil; mark2Label.AnchorSideBottom.Control := nil;
    mark2Label.Anchors := [akLeft, akTop]; mark2Label.Top := 95;
    mark2Label.Parent  := FOsImgSec;

    mark3Label.AnchorSideLeft.Control   := nil; mark3Label.AnchorSideTop.Control    := nil;
    mark3Label.AnchorSideRight.Control  := nil; mark3Label.AnchorSideBottom.Control := nil;
    mark3Label.Anchors := [akLeft, akTop]; mark3Label.Top := 95;
    mark3Label.Parent  := FOsImgSec;

    shortcutkeyLabel.AnchorSideLeft.Control   := nil; shortcutkeyLabel.AnchorSideTop.Control    := nil;
    shortcutkeyLabel.AnchorSideRight.Control  := nil; shortcutkeyLabel.AnchorSideBottom.Control := nil;
    shortcutkeyLabel.Anchors  := [akLeft, akTop];
    shortcutkeyLabel.Top      := 185;
    shortcutkeyLabel.Caption  := 'Menu Toggle Key';
    shortcutkeyLabel.Parent   := FOsImgSec;

    shortcutImage.Visible := False;

    shortcutkeyComboBox.Visible := False;
    shortcutkeyComboBox.Parent  := FOsImgSec;
    if (shortcutkeyComboBox.Text = '') or SameText(shortcutkeyComboBox.Text, 'auto') then
      shortcutkeyComboBox.Text := '0x2d';  // INSERT = default ShortcutKey

    FOsShortcutCaptureBtn := TBitBtn.Create(FOsImgSec);
    FOsShortcutCaptureBtn.Parent   := FOsImgSec;
    FOsShortcutCaptureBtn.Tag      := 5;
    FOsShortcutCaptureBtn.Anchors  := [akLeft, akTop];
    FOsShortcutCaptureBtn.Cursor   := crHandPoint;
    FOsShortcutCaptureBtn.OnClick  := @CaptureBtnClick;
    FOsShortcutCaptureBtn.Left     := shortcutkeyLabel.Left;
    FOsShortcutCaptureBtn.Top      := shortcutkeyLabel.Top + shortcutkeyLabel.Height + 4;
    FOsShortcutCaptureBtn.Width    := 100;
    FOsShortcutCaptureBtn.Height   := 28;
    FOsShortcutCaptureBtn.Caption  := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

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

    tracelogCheckBox.AnchorSideLeft.Control   := nil; tracelogCheckBox.AnchorSideTop.Control    := nil;
    tracelogCheckBox.AnchorSideRight.Control  := nil; tracelogCheckBox.AnchorSideBottom.Control := nil;
    tracelogCheckBox.Anchors := [akLeft, akTop]; tracelogCheckBox.Top := 235;
    tracelogCheckBox.Parent  := FOsFakeSec;

    // DLL & Options section
    DarkLbl(filenameLabel,    PURPLE); filenameLabel.Transparent    := True;
    DarkCombo(filenameComboBox);
    DarkCheck(spoofCheckBox);
    DarkCheck(emufp8CheckBox);
    DarkCheck(optipatcherCheckBox);
    DarkLbl(fsrversionLabel,  PURPLE); fsrversionLabel.Transparent := True;
    DarkCombo(fsrversionComboBox);
    DarkLbl(osversionLabel,   GRAY); osversionLabel.Transparent := True;
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
  PREFIX_LEN = 17; // Length('Update Available ')
var
  i: Integer;
  Ver, NewTag, VerCaption: string;
  SrcLbls: array[0..5] of StdCtrls.TLabel;
begin
  with FForm do
  begin
    if not Assigned(FOsStatDots[0]) then Exit;

    SrcLbls[0] := optlabel1;
    SrcLbls[1] := fakenvapi1;
    SrcLbls[2] := fsrLabel1;
    SrcLbls[3] := xessLabel1;
    SrcLbls[4] := dlssLabel1;
    SrcLbls[5] := optipatcherLabel1;

    for i := 0 to 5 do
    begin
      Ver := SrcLbls[i].Caption;
      VerCaption := IfThen(Ver <> '', Ver, '—');

      if (i = 0) and optLabel2.Visible and (optLabel2.Caption <> '') then
      begin
        NewTag := optLabel2.Caption;
        if Pos('Update Available ', NewTag) = 1 then
          NewTag := Copy(NewTag, PREFIX_LEN + 1, MaxInt);
        if NewTag <> '' then
        begin
          VerCaption := VerCaption + ' → ' + NewTag;
          FOsStatVerLbls[i].Caption    := VerCaption;
          FOsStatVerLbls[i].Font.Color := CLR_UPDATE;
          FOsStatDots[i].Brush.Color   := CLR_OK;
          Continue;
        end;
      end;

      FOsStatVerLbls[i].Caption    := VerCaption;
      FOsStatVerLbls[i].Font.Color := PURPLE;
      if (Ver <> '') and (Ver <> '—') and (Ver <> '--') then
        FOsStatDots[i].Brush.Color := CLR_OK
      else
        FOsStatDots[i].Brush.Color := CLR_NONE;
    end;
  end;
end;

procedure TOptiScalerTabHelper.ReflowOptiScalerTabNew(AContentW: Integer);
const
  MARGIN  = 8;    // outer margin inside scroll box
  GAP     = 6;    // gap between cards
  HDR     = 34;   // accent bar (3) + title area (31)
  PAD     = 14;   // inner horizontal padding
  GPU_GH  = 96;   // reduced from 130
  OPT_GH  = 290;  // reduced from 335 to 290
  GPU_H   = HDR + GPU_GH;    // 130
  OPT_H   = HDR + OPT_GH;    // 324
  DOT_SZ    = 10;
  ROW_H     = 26;   // standard row height
  STAT_ROWS = 3;    // 3 rows × 2 columns
  CB_H      = 26;   // combo height
  BTN_H     = 32;   // update buttons height
  PB_H      = 16;   // progress bar height
  STAT_H    = HDR + 6 + BTN_H + 8 + STAT_ROWS * ROW_H + 12;
  W1      = 252;
  W3      = 252;
  MIN_W2  = 180;
  BOX_H   = 280;
  BOX_TOP = 6;
  IMARGIN = 4;
  IGAP    = 4;
var
  CW, CardTop, Y, Row, DotY, TotalH: Integer;
  ColX: array[0..1] of Integer;
  ColW, i, Col, RowIdx: Integer;
  InnerW, Center, W2, X1, X2, X3: Integer;
  ComboW, CheckW: Integer;
  SliderW, TotalW, StartX: Integer;
  TBarMargin, TrackL: Integer;
begin
  with FForm do
  begin
    if not Assigned(FOsScrollBox) then Exit;
    CW := FOsScrollBox.ClientWidth - 2 * MARGIN;
    if CW < 100 then Exit;

    TotalH := MARGIN + GPU_H + GAP + OPT_H + GAP + STAT_H + MARGIN;
    if FOsScrollBox.ClientHeight > TotalH then
      TotalH := FOsScrollBox.ClientHeight;
    FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, TotalH);

    // ── Card 0: GPU Driver ──────────────────────────────────────────────
    FOsGpuCard.SetBounds(MARGIN, MARGIN, CW, GPU_H);
    Y := HDR + (GPU_GH - 83) div 2;
    mesaImage.Top          := Y;
    nvidiaImage.Top        := Y + (62 - 43) div 2;
    mesaRadioButton.Top    := Y + (62 - 20) div 2;
    nvidiaRadioButton.Top  := Y + (62 - 20) div 2;
    autodetectmesaLabel.Top := Y + 62 + 4;
    autodetectnvLabel.Top   := Y + 62 + 4;

    // ── Card 1: Options ─────────────────────────────────────────────────
    CardTop := MARGIN + GPU_H + GAP;
    FOsOptionsCard.SetBounds(MARGIN, CardTop, CW, OPT_H);

    InnerW := CW - 8;
    Center := InnerW div 2;
    W2     := Max(MIN_W2, InnerW - IMARGIN - W1 - IGAP - W3 - IMARGIN - IGAP);
    X2     := Center - W2 div 2;
    if X2 - IGAP - W1 < IMARGIN then
      X2 := IMARGIN + W1 + IGAP;
    X1 := X2 - IGAP - W1;
    X3 := X2 + W2 + IGAP;
    if Assigned(FOsOptiSec)  then FOsOptiSec.SetBounds(X1, HDR + BOX_TOP, W1, BOX_H);
    if Assigned(FOsImgSec) then
    begin
      FOsImgSec.SetBounds(X2, HDR + BOX_TOP, W2, BOX_H);
      menuLabel.Left := (W2 - menuLabel.Width) div 2;

      SliderW := Min(200, W2 - 24);
      if SliderW < 120 then SliderW := 120;
      TotalW := SliderW + 6 + menuscalevalueLabel.Width;
      StartX := (W2 - TotalW) div 2;

      menuscaleTrackBar.SetBounds(StartX, 70, SliderW, menuscaleTrackBar.Height);
      menuscalevalueLabel.SetBounds(StartX + SliderW + 6, 70, menuscalevalueLabel.Width, menuscalevalueLabel.Height);

      TBarMargin := 10;
      TrackL := SliderW - 2 * TBarMargin;

      mark1Label.Left := StartX + TBarMargin + TrackL div 3 - mark1Label.Width div 2;
      mark2Label.Left := StartX + TBarMargin + (2 * TrackL) div 3 - mark2Label.Width div 2;
      mark3Label.Left := StartX + SliderW - TBarMargin - mark3Label.Width div 2;

      shortcutkeyLabel.Left := (W2 - shortcutkeyLabel.Width) div 2;
      if Assigned(FOsShortcutCaptureBtn) then
      begin
        FOsShortcutCaptureBtn.Left := (W2 - FOsShortcutCaptureBtn.Width) div 2;
        FOsShortcutCaptureBtn.Top  := shortcutkeyLabel.Top + shortcutkeyLabel.Height + 4;
      end;
    end;
    if Assigned(FOsFakeSec)  then FOsFakeSec.SetBounds(X3, HDR + BOX_TOP, W3, BOX_H);

    // ── Card 2: Software Status ──────────────────────────────────────────
    CardTop := MARGIN + GPU_H + GAP + OPT_H + GAP;
    FOsStatusCard.SetBounds(MARGIN, CardTop, CW, STAT_H);

    CheckW := 130;
    ComboW := CW - 2 * PAD - 8 - CheckW;
    if ComboW < 80 then ComboW := 80;
    Y := HDR + 6;
    optversionComboBox.SetBounds(PAD, Y + (BTN_H - CB_H) div 2, ComboW, CB_H);
    checkupdBitBtn.SetBounds(PAD + ComboW + 8, Y, CheckW, BTN_H);
    updateBitBtn.SetBounds(PAD + ComboW + 8, Y, CheckW, BTN_H);

    updateProgressBar.SetBounds(PAD, Y + (BTN_H - PB_H) div 2, ComboW, PB_H);
    updatestatusLabel.SetBounds(PAD + ComboW + 4, Y + (BTN_H - PB_H) div 2, CheckW + 4, PB_H);

    Y := Y + BTN_H + 8;
    ColW    := (CW - 2 * PAD) div 2;
    ColX[0] := PAD;
    ColX[1] := PAD + ColW;

    for i := 0 to 5 do
    begin
      Col    := i mod 2;
      RowIdx := i div 2;
      Row    := Y + RowIdx * ROW_H;
      DotY   := Row + (ROW_H - DOT_SZ) div 2;

      FOsStatDots[i].SetBounds(ColX[Col], DotY, DOT_SZ, DOT_SZ);
      FOsStatNameLbls[i].Left := ColX[Col] + DOT_SZ + 6;
      FOsStatNameLbls[i].Top  := Row + (ROW_H - 16) div 2;
      FOsStatVerLbls[i].Left  := ColX[Col] + DOT_SZ + 6 + 80;
      FOsStatVerLbls[i].Top   := Row + (ROW_H - 16) div 2;
    end;
  end;
end;

procedure TOptiScalerTabHelper.LoadOptiScalerConfig;
var
  Settings: TOptiScalerSettings;
begin
  with FForm do
  begin
    if not overlay_config.LoadOptiScalerConfig(FActiveGameName, Settings) then
      Exit;

    filenameComboBox.ItemIndex := Settings.FilenameItemIndex;
    emufp8CheckBox.Checked := Settings.EmuFp8Checked;
    shortcutkeyComboBox.Text := Settings.ShortcutKey;
    if Assigned(FOsShortcutCaptureBtn) then
      FOsShortcutCaptureBtn.Caption := '⌨ ' + OsHexToKeyStr(shortcutkeyComboBox.Text);

    menuscaleTrackBar.Position := Settings.MenuScalePosition;
    menuscalevalueLabel.Caption := FormatFloat('#0.0', menuscaleTrackBar.Position / 10);

    overrideCheckBox.Checked := Settings.OverrideChecked;
    optipatcherCheckBox.Checked := Settings.OptipatcherChecked;

    fsrversionComboBox.ItemIndex := Settings.FsrversionItemIndex;
    spoofCheckBox.Checked := Settings.SpoofChecked;

    forcereflexCheckBox.Checked := Settings.ForceReflexChecked;
    reflexComboBox.ItemIndex := Settings.ReflexItemIndex;
    reflexComboBox.Enabled := forcereflexCheckBox.Checked;

    forcelatencyflexCheckBox.Checked := Settings.ForceLatencyFlexChecked;
    latencyflexComboBox.ItemIndex := Settings.LatencyFlexItemIndex;
    latencyflexComboBox.Enabled := forcelatencyflexCheckBox.Checked;

    tracelogCheckBox.Checked := Settings.TraceLogChecked;

    if Settings.OptVersionItemIndex in [0, 1] then
      optversionComboBox.ItemIndex := Settings.OptVersionItemIndex;
  end;
end;

procedure TOptiScalerTabHelper.SaveOptiScalerConfig;
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
    Settings.ShortcutKey := shortcutkeyComboBox.Text;
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

    if not SaveOptiScalerConfigCore(Settings, ENV_GAMEMODERUN, LAUNCH_COMMAND_SUFFIX, GetPerformanceCheckBox(0).Checked, FActiveGameIsNonSteam, FActiveGameIsNonSteam, ErrMsg, LaunchCommand) then
    begin
      if ErrMsg <> '' then
        ShowMessage(ErrMsg);
      Exit;
    end;

    if ErrMsg <> '' then
      ShowMessage(ErrMsg);

    SendNotification('OptiScaler', 'Configuration saved', GetIconFile);

    notificationLabel.Visible := False;
    FLaunchCommand := LaunchCommand;
    commandPaintBox.Invalidate;
    commandPanel.Visible := True;
  end;
end;

end.
