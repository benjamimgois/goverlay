unit mangohud_ui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  StdCtrls, Buttons, Menus, LCLtype, Types, Grids,
  themeunit, constants, hintsunit, apputils, overlayunit, overlay_config, systemdetector, ComCtrls, overlay_utils,
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets, configkeys, toggle_switch;

type
  TMangoHudUiHelper = class
  private
    FForm: Tgoverlayform;
    FVisualToggles: TFPList;
    FPerfToggles: TFPList;
    FMetricsToggles: TFPList;
    FExtrasToggles: TFPList;
  public
    // Visual Tab Toggles
    FhudcompactToggle, FhorizontalstrechToggle, FhidehudToggle: TToggleSwitch;

    // Performance Tab Toggles
    FfpsToggle, FfpsavgToggle, FshowfpslimToggle: TToggleSwitch;
    FframetimegraphToggle, FframetimedetailedToggle: TToggleSwitch;
    FvpsToggle, FftraceToggle, FframecountToggle, FfpscolorToggle: TToggleSwitch;

    // GPU Metric Toggles
    FgpuavgloadToggle, FgpuloadcolorToggle, FvramusageToggle, FgpufreqToggle, FgpumemfreqToggle: TToggleSwitch;
    FgputempToggle, FgpumemtempToggle, FgpujunctempToggle, FgpufanToggle: TToggleSwitch;
    FgpupowerToggle, FgpuvoltageToggle, FgputhrottlingToggle, FgputhrottlinggraphToggle, FgpuefficiencyToggle, FgpupowerlimitToggle: TToggleSwitch;
    FgpumodelToggle, FvulkandriverToggle, FprocvramToggle: TToggleSwitch;

    // CPU Metric Toggles
    FcpuavgloadToggle, FcpuloadcolorToggle, FcpuloadcoreToggle, FcpufreqToggle, FcpucoretypeToggle: TToggleSwitch;
    FcputempToggle, FcpupowerToggle, FcpuefficiencyToggle, FramtempToggle: TToggleSwitch;
    FramusageToggle, FdiskioToggle, FprocmemToggle, FswapusageToggle: TToggleSwitch;

    // Extras Tab Toggles
    FdistroinfoToggle, FrefreshrateToggle, FresolutionToggle, FdisplayserverToggle, FtimeToggle, FarchToggle: TToggleSwitch;
    FwineToggle, FengineversionToggle, FengineshortToggle, FwinesyncToggle, FdxapiToggle, FfexstatsToggle: TToggleSwitch;
    FhudversionToggle, FgamemodestatusToggle, FvkbasaltstatusToggle, FfcatToggle, FfsrToggle, FhdrToggle: TToggleSwitch;
    FbatteryToggle, FbatterywattToggle, FbatterytimeToggle, FdeviceToggle: TToggleSwitch;
    FmediaToggle, FnetworkToggle, FfahrenheitToggle: TToggleSwitch;

    constructor Create(AForm: Tgoverlayform);
    destructor Destroy; override;
    procedure BuildPresetsWrapper;
    function  FindPresetCard(ASender: TObject): TPanel;
    procedure UpdatePresetCardVisuals;
    procedure PresetCardPaint(Sender: TObject);
    procedure PresetCardClick(Sender: TObject);
    procedure PresetCardMouseEnter(Sender: TObject);
    procedure PresetCardMouseLeave(Sender: TObject);
    procedure InitVisualTab;
    procedure ReflowVisualTab(AContentW, AContentH: Integer);
    procedure SyncVisualToggles;
    procedure UpdateVisualCardTheme;
    procedure BuildFpsLimitEdit;
    procedure InitPerformanceTab;
    procedure ReflowPerformanceTab(AContentW, AContentH: Integer);
    procedure SyncPerformanceToggles;
    procedure FrametimegraphCheckBoxChange(Sender: TObject);
    procedure UpdatePerfCardTheme;
    procedure InitMetricsTab;
    procedure ReflowMetricsTab(AContentW: Integer);
    procedure SyncMetricsToggles;
    procedure InitExtrasTab;
    procedure ReflowExtrasTab(AContentW: Integer);
    procedure SyncExtrasToggles;
    procedure SyncAllToggles;
    procedure UpdateExtrasCardTheme;
    procedure LoadMangoHudConfig;
    procedure ResetMangoHudControls;
    procedure LoadMangoHudBoolFlag(const ATrimmedLine: string);
    procedure LoadMangoHudKeyValue(const AKey, AValue: string);
    procedure SaveMangoHudConfig;
    procedure MetricGraphClick(Sender: TObject);
  end;

implementation

constructor TMangoHudUiHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
  FVisualToggles  := TFPList.Create;
  FPerfToggles    := TFPList.Create;
  FMetricsToggles := TFPList.Create;
  FExtrasToggles  := TFPList.Create;
end;

destructor TMangoHudUiHelper.Destroy;
begin
  FreeAndNil(FVisualToggles);
  FreeAndNil(FPerfToggles);
  FreeAndNil(FMetricsToggles);
  FreeAndNil(FExtrasToggles);
  inherited Destroy;
end;

procedure TMangoHudUiHelper.BuildPresetsWrapper;
const
  WRAPPER_W  = 829;
  PC_W       = 130;   // card outer width
  PC_H       = 140;   // card outer height (18 top + 70 img + 8 gap + 18 label + 23 bottom + 3 sel)
  PC_IMG_SZ  = 70;    // native layoutImageList size — no scaling, no quality loss
  PC_IMG_T   = 18;    // image top padding inside card
  PC_SEL_H   = 3;     // selection indicator bar height
const
  LAYOUT_TITLES: array[0..4] of string = (
    'Full', 'Basic', 'Basic Horizontal', 'FPS only', 'Custom');
  LAYOUT_IMG: array[0..4] of Integer = (0, 1, 2, 3, 4);
  COLOR_TITLES: array[0..3] of string = (
    'MangoHud Stock', 'Goverlay', 'Simple White', 'Old Afterburner');
  COLOR_IMG: array[0..3] of Integer = (5, 8, 6, 7);
var
  i: Integer;
  Bmp: TBitmap;
  CardImg: TImage;
  CardLbl: TLabel;
  CtrlsToMove: array of TControl;

  procedure MakeCard(var ACard: TPanel; var ASelBar: TPanel;
                     ImgIdx: Integer; const Title: string; ATag: Integer);
  begin
    with FForm do
    begin
      ACard := TPanel.Create(FForm);
      ACard.Parent       := FPresetsWrapper;
      ACard.BevelOuter   := bvNone;
      ACard.Caption      := '';
      ACard.Tag          := ATag;
      ACard.Cursor       := crHandPoint;
      ACard.OnPaint      := @PresetCardPaint;
      ACard.OnClick      := @PresetCardClick;
      ACard.OnMouseEnter := @PresetCardMouseEnter;
      ACard.OnMouseLeave := @PresetCardMouseLeave;
      ACard.SetBounds(0, 0, PC_W, PC_H);

      // Image centred horizontally at native 70×70 — no stretch, pixel-perfect
      CardImg := TImage.Create(ACard);
      CardImg.Parent       := ACard;
      CardImg.Stretch      := False;
      CardImg.Proportional := False;
      CardImg.Center       := False;
      CardImg.Transparent  := True;
      CardImg.SetBounds((PC_W - PC_IMG_SZ) div 2, PC_IMG_T, PC_IMG_SZ, PC_IMG_SZ);
      CardImg.Tag          := ATag;
      CardImg.OnClick      := @PresetCardClick;
      CardImg.OnMouseEnter := @PresetCardMouseEnter;
      CardImg.OnMouseLeave := @PresetCardMouseLeave;
      Bmp := TBitmap.Create;
      try
        layoutImageList.GetBitmap(ImgIdx, Bmp);
        CardImg.Picture.Assign(Bmp);
      finally Bmp.Free; end;

      // Title label centred in card width
      CardLbl := TLabel.Create(ACard);
      CardLbl.Parent      := ACard;
      CardLbl.Caption     := Title;
      CardLbl.AutoSize    := False;
      CardLbl.Alignment   := taCenter;
      CardLbl.Width       := PC_W;
      CardLbl.Left        := 0;
      CardLbl.Top         := PC_IMG_T + PC_IMG_SZ + 8;
      CardLbl.Height      := 18;
      CardLbl.Font.Size   := 8;
      CardLbl.Transparent := True;
      CardLbl.Tag         := ATag;
      CardLbl.OnClick     := @PresetCardClick;
      CardLbl.OnMouseEnter := @PresetCardMouseEnter;
      CardLbl.OnMouseLeave := @PresetCardMouseLeave;

      // Selection indicator bar (bottom edge, hidden until active)
      ASelBar := TPanel.Create(ACard);
      ASelBar.Parent     := ACard;
      ASelBar.BevelOuter := bvNone;
      ASelBar.Caption    := '';
      ASelBar.Color      := clHighlight;
      ASelBar.SetBounds(0, PC_H - PC_SEL_H, PC_W, PC_SEL_H);
      ASelBar.Visible    := False;
    end;
  end;

begin
  with FForm do
  begin
  FActiveLayoutCard  := -1;
  FActiveColorCard   := -1;
  FHoveredPresetCard := nil;

  // Move all existing .lfm children into the wrapper so they share the
  // coordinate space; we then hide the legacy BitBtn/Label controls.
  SetLength(CtrlsToMove, presetTabSheet.ControlCount);
  for i := 0 to presetTabSheet.ControlCount - 1 do
    CtrlsToMove[i] := presetTabSheet.Controls[i];

  // TPaintBox as background — drawn first (lowest z-order), fills the entire tab
  FPresetsBgBox := TPaintBox.Create(FForm);
  FPresetsBgBox.Parent  := presetTabSheet;
  FPresetsBgBox.Align   := alClient;
  FPresetsBgBox.OnPaint := @FForm.PresetsBgBoxPaint;

  // Wrapper: child of tabsheet, sits above the paintbox
  // OnPaint fills with the same navy — Qt6 ignores Color on TPanel without it
  FPresetsWrapper := TPanel.Create(FForm);
  FPresetsWrapper.Parent      := presetTabSheet;
  FPresetsWrapper.BevelOuter  := bvNone;
  FPresetsWrapper.BorderStyle := bsNone;
  FPresetsWrapper.Caption     := '';
  FPresetsWrapper.OnPaint     := @FForm.PresetsWrapperPaint;
  FPresetsWrapper.Top         := 0;
  FPresetsWrapper.Left        := 0;
  FPresetsWrapper.Width       := WRAPPER_W;
  FPresetsWrapper.Anchors     := [akTop, akBottom];
  FPresetsWrapper.Height      := presetTabSheet.ClientHeight;

  for i := 0 to High(CtrlsToMove) do
    CtrlsToMove[i].Parent := FPresetsWrapper;

  // Hide all legacy .lfm BitBtn controls and their labels
  fullBitBtn.Visible              := False;
  basicBitBtn.Visible             := False;
  basichorizontalBitBtn.Visible   := False;
  fpsonlyBitBtn.Visible           := False;
  usercustomBitBtn.Visible        := False;
  mangocolorBitBtn.Visible        := False;
  goverlayBitBtn.Visible          := False;
  whitecolorBitBtn.Visible        := False;
  afterburnercolorBitBtn1.Visible := False;
  fullLabel.Visible               := False;
  basicLabel.Visible              := False;
  basichorizontalLabel.Visible    := False;
  fpsonlyLabel.Visible            := False;
  customLabel.Visible             := False;
  mangocolorLabel.Visible         := False;
  customolorLabel.Visible         := False;
  whitecolorLabel.Visible         := False;
  afterburnercolorLabel.Visible   := False;

  // Style the section header labels (already inside FPresetsWrapper)
  layoutsLabel.Font.Size   := 10;
  layoutsLabel.Font.Style  := [fsBold];
  layoutsLabel.Transparent := True;
  layoutsLabel.AutoSize    := True;

  colorthemeLabel.Font.Size   := 10;
  colorthemeLabel.Font.Style  := [fsBold];
  colorthemeLabel.Transparent := True;
  colorthemeLabel.AutoSize    := True;

  // Build layout preset cards — Tags 100-104
  for i := 0 to 4 do
    MakeCard(FPresetLayoutCards[i], FPresetLayoutSelBars[i],
             LAYOUT_IMG[i], LAYOUT_TITLES[i], 100 + i);

  // Build color preset cards — Tags 200-203
  for i := 0 to 3 do
    MakeCard(FPresetColorCards[i], FPresetColorSelBars[i],
             COLOR_IMG[i], COLOR_TITLES[i], 200 + i);
  end;
end;

// ---------------------------------------------------------------------------
// Preset card helpers
// ---------------------------------------------------------------------------


function TMangoHudUiHelper.FindPresetCard(ASender: TObject): TPanel;
var
  SenderTag: PtrInt;
  i: Integer;
begin
  with FForm do
  begin
  Result := nil;
  if not (ASender is TControl) then Exit;
  SenderTag := TControl(ASender).Tag;
  for i := 0 to 4 do
    if Assigned(FPresetLayoutCards[i]) and (FPresetLayoutCards[i].Tag = SenderTag) then
    begin Result := FPresetLayoutCards[i]; Exit; end;
  for i := 0 to 3 do
    if Assigned(FPresetColorCards[i]) and (FPresetColorCards[i].Tag = SenderTag) then
    begin Result := FPresetColorCards[i]; Exit; end;
  end;
end;


procedure TMangoHudUiHelper.UpdatePresetCardVisuals;
var
  i, j: Integer;
  LblColor: TColor;
begin
  with FForm do
  begin
  // Card label text colour depends on the painted background — always light on
  // dark cards, always dark on light cards, regardless of the global theme.
  if CurrentTheme = tmLight then
    LblColor := LightTextColor
  else
    LblColor := DarkTextColor;

  for i := 0 to 4 do
  begin
    FPresetLayoutCards[i].Invalidate;
    for j := 0 to FPresetLayoutCards[i].ControlCount - 1 do
    begin
      if FPresetLayoutCards[i].Controls[j] is TLabel then
        TLabel(FPresetLayoutCards[i].Controls[j]).Font.Color := LblColor
      else if FPresetLayoutCards[i].Controls[j] is TImage then
        TImage(FPresetLayoutCards[i].Controls[j]).Enabled := True;
    end;
  end;
  for i := 0 to 3 do
  begin
    FPresetColorCards[i].Invalidate;
    for j := 0 to FPresetColorCards[i].ControlCount - 1 do
      if FPresetColorCards[i].Controls[j] is TLabel then
        TLabel(FPresetColorCards[i].Controls[j]).Font.Color := LblColor;
  end;
  end;
end;


procedure TMangoHudUiHelper.PresetCardPaint(Sender: TObject);
const
  // Dark theme — Lazarus TColor = $00BBGGRR (Blue, Green, Red byte order)
  DARK_BG     = $003E2E2E;   // RGB( 46, 46, 62) dark blue-gray
  DARK_HOVER  = $004E3A3A;   // RGB( 58, 58, 78) slightly lighter
  DARK_SEL    = $0050321E;   // RGB( 30, 50, 80) blue-tinted selection
  DARK_BRD    = $00645050;   // RGB( 80, 80,100) subtle border
  DARK_H_BRD  = $00998888;   // RGB(136,136,153) hover border

  // Light theme
  LIGHT_BG    = $00F2F2F2;   // RGB(242,242,242) near-white
  LIGHT_HOVER = $00EEE4E4;   // RGB(228,228,238) faint blue tint
  LIGHT_SEL   = $00FFE8DC;   // RGB(220,232,255) light blue selection
  LIGHT_BRD   = $00C8C0C0;   // RGB(192,192,200) light border
  LIGHT_H_BRD = $00A09090;   // RGB(144,144,160) hover border
var
  Card: TPanel;
  BgColor, BorderColor: TColor;
  IsHovered, IsSelected: Boolean;
  i: Integer;
begin
  with FForm do
  begin
  Card      := TPanel(Sender);
  IsHovered := Card = FHoveredPresetCard;
  IsSelected := False;
  for i := 0 to 4 do
    if (Card = FPresetLayoutCards[i]) and (i = FActiveLayoutCard) then
    begin IsSelected := True; Break; end;
  if not IsSelected then
    for i := 0 to 3 do
      if (Card = FPresetColorCards[i]) and (i = FActiveColorCard) then
      begin IsSelected := True; Break; end;

  if CurrentTheme = tmLight then
  begin
    if IsSelected      then BgColor := LIGHT_SEL
    else if IsHovered  then BgColor := LIGHT_HOVER
    else                    BgColor := LIGHT_BG;
    if IsSelected      then BorderColor := clHighlight
    else if IsHovered  then BorderColor := LIGHT_H_BRD
    else                    BorderColor := LIGHT_BRD;
  end
  else
  begin
    if IsSelected      then BgColor := DARK_SEL
    else if IsHovered  then BgColor := DARK_HOVER
    else                    BgColor := DARK_BG;
    if IsSelected      then BorderColor := clHighlight
    else if IsHovered  then BorderColor := DARK_H_BRD
    else                    BorderColor := DARK_BRD;
  end;

  // 1. Background fill
  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.FillRect(Card.ClientRect);

  // 2. Selection accent bar
  if IsSelected then
  begin
    Card.Canvas.Brush.Color := clHighlight;
    Card.Canvas.Brush.Style := bsSolid;
    Card.Canvas.FillRect(Rect(2, Card.Height - 3, Card.Width - 2, Card.Height - 1));
  end;

  // 3. 1px border rectangle on top of everything
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Rectangle(0, 0, Card.Width, Card.Height);
  end;
end;


procedure TMangoHudUiHelper.PresetCardClick(Sender: TObject);
var
  Card: TPanel;
  i: Integer;
begin
  with FForm do
  begin
  Card := FindPresetCard(Sender);
  if Card = nil then Exit;
  for i := 0 to 4 do
    if Card = FPresetLayoutCards[i] then
    begin
      if (i = 4) and not FileExists(GetActiveCustomConfigFile) then
      begin
        usercustomBitBtnClick(usercustomBitBtn);
        Exit;
      end;
      FActiveLayoutCard := i;
      UpdatePresetCardVisuals;
      case i of
        0: fullBitBtnClick(fullBitBtn);
        1: basicBitBtnClick(basicBitBtn);
        2: basichorizontalBitBtnClick(basichorizontalBitBtn);
        3: fpsonlyBitBtnClick(fpsonlyBitBtn);
        4: usercustomBitBtnClick(usercustomBitBtn);
      end;
      SyncAllToggles;
      Exit;
    end;
  for i := 0 to 3 do
    if Card = FPresetColorCards[i] then
    begin
      FActiveColorCard := i;
      UpdatePresetCardVisuals;
      case i of
        0: mangocolorBitBtnClick(mangocolorBitBtn);
        1: goverlayBitBtnClick(goverlayBitBtn);
        2: whitecolorBitBtnClick(whitecolorBitBtn);
        3: afterburnercolorBitBtn1Click(afterburnercolorBitBtn1);
      end;
      Exit;
    end;
  end;
end;


procedure TMangoHudUiHelper.PresetCardMouseEnter(Sender: TObject);
var
  Card, Prev: TPanel;
begin
  with FForm do
  begin
  Card := FindPresetCard(Sender);
  if (Card = nil) or (Card = FHoveredPresetCard) then Exit;
  Prev := FHoveredPresetCard;
  FHoveredPresetCard := Card;
  if Assigned(Prev) then Prev.Invalidate;
  Card.Invalidate;
  end;
end;


procedure TMangoHudUiHelper.PresetCardMouseLeave(Sender: TObject);
var
  Card: TPanel;
  Pos: TPoint;
begin
  with FForm do
  begin
  Card := FindPresetCard(Sender);
  if (Card = nil) or (FHoveredPresetCard <> Card) then Exit;
  // Guard: only clear hover when cursor truly leaves the card bounding box.
  // This prevents spurious clears when moving between child controls
  // (TImage → TLabel within the same card).
  Pos := Card.ScreenToClient(Mouse.CursorPos);
  if not PtInRect(Rect(0, 0, Card.Width, Card.Height), Pos) then
  begin
    FHoveredPresetCard := nil;
    Card.Invalidate;
  end;
  end;
end;

// NAV RAIL — modern sidebar navigation
// ============================================================================


procedure TMangoHudUiHelper.InitVisualTab;
const
  ACCENT_H = 3;
  TITLE_T  = 6;
  TITLE_H  = 22;
  HDR      = ACCENT_H + TITLE_T + TITLE_H + 3;  // = 34, content starts here

  CARD_TITLES: array[0..0] of string = ('Visual Settings');

  procedure MakeCard(AIndex: Integer; ATitle: string);
  var
    Card: TPanel;
    Lbl: TLabel;
  begin
    with FForm do
    begin
      Card := TPanel.Create(FForm);
      Card.Parent  := visualTabSheet;
      Card.Caption := '';
      Card.OnPaint := @FForm.SubCardPaint;
      FVisualCards[AIndex] := Card;

      Lbl := TLabel.Create(Card);
      Lbl.Parent   := Card;
      StyleMainCard(Card, Lbl, ATitle);
    end;
  end;

  // Reparent a control directly onto a card, clearing all anchor dependencies.
  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors := [akLeft, akTop];
    C.Parent  := Card;
    C.Left    := ALeft;
    C.Top     := ATop;
  end;

  procedure MakeSection(AIndex: Integer; ATitle: string);
  var
    Sec: TPanel;
    Lbl: TLabel;
  begin
    with FForm do
    begin
      Sec := TPanel.Create(FVisualCards[0]);
      Sec.Parent  := FVisualCards[0];
      Sec.Caption := '';
      Sec.OnPaint := @FForm.SubCardPaint;
      FVisualSections[AIndex] := Sec;
      Lbl := TLabel.Create(Sec);
      Lbl.Parent := Sec;
      StyleSubCard(Sec, Lbl, ATitle);
    end;
  end;

var
  i: Integer;
  IsLight: Boolean;
  BarBg, TextColor: TColor;
  Lbl: TLabel;
  SS: WideString;
var
  BgBox: TPaintBox;
begin
  with FForm do
  begin
  BgBox := TPaintBox.Create(FForm);
  BgBox.Parent  := visualTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @FForm.PresetsBgBoxPaint;

  MakeCard(0, CARD_TITLES[0]);
  FVisualCards[1] := nil; FVisualCards[2] := nil;
  FVisualCards[3] := nil; FVisualCards[4] := nil; FVisualCards[5] := nil;

  IsLight   := CurrentTheme = tmLight;
  BarBg     := IfThen(IsLight, $00F2F2F2, $00362E2E);
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

  // Hide the LFM GroupBoxes — controls reparented directly to section panels.
  orientationGroupBox.Visible := False;
  borderGroupBox.Visible      := False;
  backgroundGroupBox.Visible  := False;
  fontsGroupBox.Visible       := False;
  positionGroupBox.Visible    := False;
  columsGroupBox.Visible      := False;

  // ── Single card — Visual Settings with 6 inner section panels ───────────
  // Row 1: [0]Orientation | [1]Borders | [2]Background
  // Row 2: [3]Fonts       | [4]Position | [5]Columns
  // Section bounds are set by ReflowVisualTab; controls use relative coords.
  MakeSection(0, 'Orientation');
  MakeSection(1, 'Borders');
  MakeSection(2, 'Background');
  MakeSection(3, 'Fonts');
  MakeSection(4, 'Position');
  MakeSection(5, 'Columns');

  // ·· [0] Orientation — positions set by Reflow ···························
  Place(verticalRadioButton,   FVisualSections[0], 6,  50);
  Place(vImage,                FVisualSections[0], 30, 28);
  Place(horizontalRadioButton, FVisualSections[0], 6,  50);
  Place(hImage,                FVisualSections[0], 30, 40);
  verticalRadioButton.Color   := $002E1E1A; verticalRadioButton.ParentColor   := False;
  horizontalRadioButton.Color := $002E1E1A; horizontalRadioButton.ParentColor := False;
  vImage.Transparent := True; hImage.Transparent := True;
  vImage.Width := 30;  vImage.Height := 56;   // portrait — Reflow positions these
  hImage.Width := 56;  hImage.Height := 30;   // landscape
  SS := 'QRadioButton { background-color: rgb(26,30,46); }';
  QWidget_setStyleSheet(TQtWidget(FVisualSections[0].Handle).Widget, @SS);

  // ·· [1] Borders — positions set by Reflow ································
  Place(squareRadioButton, FVisualSections[1], 6,  50);
  Place(squareImage,       FVisualSections[1], 30, 30);
  Place(roundRadioButton,  FVisualSections[1], 6,  50);
  Place(roundImage,        FVisualSections[1], 30, 30);
  squareRadioButton.Color := $002E1E1A; squareRadioButton.ParentColor := False;
  roundRadioButton.Color  := $002E1E1A; roundRadioButton.ParentColor  := False;
  squareImage.Transparent := True; roundImage.Transparent := True;
  squareImage.Width := 48; squareImage.Height := 42;
  roundImage.Width  := 48; roundImage.Height  := 42;
  SS := 'QRadioButton { background-color: rgb(26,30,46); }';
  QWidget_setStyleSheet(TQtWidget(FVisualSections[1].Handle).Widget, @SS);

  // ·· [2] Background ·······················································
  Place(backgroundLabel,          FVisualSections[2], 6,  32);
  Place(hudbackgroundColorButton, FVisualSections[2], 52, 28);
  Place(transparencyLabel,        FVisualSections[2], 6,  72);
  Place(transpTrackBar,           FVisualSections[2], 52, 70);
  Place(alphavalueLabel,          FVisualSections[2], 52 + transpTrackBar.Width + 8, 72);
  backgroundLabel.Font.Color   := TextColor; backgroundLabel.Transparent   := True;
  transparencyLabel.Font.Color := TextColor; transparencyLabel.Transparent := True;
  alphavalueLabel.Font.Color   := CLR_TEXT_ACCENT; alphavalueLabel.Font.Style := [fsBold]; alphavalueLabel.Transparent   := True;
  hudbackgroundColorButton.Color := BarBg;
  transpTrackBar.Color := BarBg; transpTrackBar.ParentColor := False; transpTrackBar.TickStyle := tsNone;

  // ·· [3] Fonts ····························································
  Place(fontComboBox,       FVisualSections[3], 6,  22);
  Place(fontcolorLabel,     FVisualSections[3], 6,  84);
  Place(FontcolorButton,    FVisualSections[3], 60, 82);
  Place(fontLabel,          FVisualSections[3], 6,  142);
  // Slider and colour button start at 60, not 40/52: fontLabel needs room for a
  // caption longer than "Size", and the two rows stay aligned with each other.
  Place(fontsizeTrackBar,   FVisualSections[3], 60, 140);
  Place(fontsizevalueLabel, FVisualSections[3], 60 + fontsizeTrackBar.Width + 8, 142);
  fontcolorLabel.Font.Color     := TextColor; fontcolorLabel.Transparent     := True;
  fontLabel.Font.Color          := TextColor; fontLabel.Transparent          := True;
  fontsizevalueLabel.Font.Color := CLR_TEXT_ACCENT; fontsizevalueLabel.Font.Style := [fsBold]; fontsizevalueLabel.Transparent := True;
  FontcolorButton.Color  := BarBg;
  fontsizeTrackBar.Color := BarBg; fontsizeTrackBar.ParentColor := False; fontsizeTrackBar.TickStyle := tsNone;

  // ·· [4] Position ·························································
  Image1.Stretch      := True;
  Image1.Proportional := False;
  Image1.AnchorSideLeft.Control   := nil; Image1.AnchorSideTop.Control    := nil;
  Image1.AnchorSideRight.Control  := nil; Image1.AnchorSideBottom.Control := nil;
  Image1.Anchors := [akLeft, akTop];
  Image1.BorderSpacing.Left   := 0; Image1.BorderSpacing.Right  := 0;
  Image1.BorderSpacing.Top    := 0; Image1.BorderSpacing.Bottom := 0;
  Image1.Parent := FVisualSections[4];
  Image1.SetBounds(4, 22, 100, 80);  // Reflow sets actual size
  Place(topleftRadioButton,      FVisualSections[4], 10, 30);
  Place(topcenterRadioButton,    FVisualSections[4], 50, 30);
  Place(toprightRadioButton,     FVisualSections[4], 90, 30);
  Place(middleleftRadioButton,   FVisualSections[4], 10, 80);
  Place(middlerightRadioButton,  FVisualSections[4], 90, 80);
  Place(bottomleftRadioButton,   FVisualSections[4], 10, 130);
  Place(bottomcenterRadioButton, FVisualSections[4], 50, 130);
  Place(bottomrightRadioButton,  FVisualSections[4], 90, 130);
  // SpinEdits: modern dark pill input controls centered on the monitor screen
  offsetxSpinEdit.Parent := FVisualSections[4];
  offsetxSpinEdit.AnchorSideLeft.Control := nil; offsetxSpinEdit.AnchorSideTop.Control := nil;
  offsetxSpinEdit.Anchors     := [akLeft, akTop];
  offsetxSpinEdit.Font.Name   := 'Noto Sans';
  offsetxSpinEdit.Font.Size   := 7;
  offsetxSpinEdit.Font.Height := 0;
  offsetxSpinEdit.Font.Style  := [fsBold];
  offsetxSpinEdit.Font.Color  := clWhite;
  offsetxSpinEdit.Width       := 60;
  offsetxSpinEdit.Height      := 22;
  offsetxSpinEdit.Left        := 10; offsetxSpinEdit.Top := 60;

  offsetySpinEdit.Parent := FVisualSections[4];
  offsetySpinEdit.AnchorSideLeft.Control := nil; offsetySpinEdit.AnchorSideTop.Control := nil;
  offsetySpinEdit.Anchors     := [akLeft, akTop];
  offsetySpinEdit.Font.Name   := 'Noto Sans';
  offsetySpinEdit.Font.Size   := 7;
  offsetySpinEdit.Font.Height := 0;
  offsetySpinEdit.Font.Style  := [fsBold];
  offsetySpinEdit.Font.Color  := clWhite;
  offsetySpinEdit.Width       := 60;
  offsetySpinEdit.Height      := 22;
  offsetySpinEdit.Left        := 10; offsetySpinEdit.Top := 90;

  // ·· [5] Columns ··························································
  Place(columShape,      FVisualSections[5], 10, 50);
  Place(columShape1,     FVisualSections[5], 37, 50);
  Place(columShape2,     FVisualSections[5], 64, 50);
  Place(columShape3,     FVisualSections[5], 91, 50);
  Place(columShape4,     FVisualSections[5], 118, 50);
  Place(columShape5,     FVisualSections[5], 145, 50);

  // Hide legacy LFM speed buttons
  minusButton.Visible := False;
  plusSpeedButton.Visible := False;

  // Create modern TBitBtn controls for Columns minus/plus
  FColumnsMinusBtn := TBitBtn.Create(FVisualSections[5]);
  FColumnsMinusBtn.Parent := FVisualSections[5];
  FColumnsMinusBtn.Caption := '-';
  FColumnsMinusBtn.Font.Size := 13;
  FColumnsMinusBtn.Font.Style := [fsBold];
  FColumnsMinusBtn.OnClick := @FForm.minusButtonClick;
  FColumnsMinusBtn.Cursor := crHandPoint;
  FColumnsMinusBtn.SetBounds(64, 162, 24, 24);

  FColumnsPlusBtn := TBitBtn.Create(FVisualSections[5]);
  FColumnsPlusBtn.Parent := FVisualSections[5];
  FColumnsPlusBtn.Caption := '+';
  FColumnsPlusBtn.Font.Size := 13;
  FColumnsPlusBtn.Font.Style := [fsBold];
  FColumnsPlusBtn.OnClick := @FForm.plusSpeedButtonClick;
  FColumnsPlusBtn.Cursor := crHandPoint;
  FColumnsPlusBtn.SetBounds(91, 162, 24, 24);

  Place(columvalueLabel, FVisualSections[5], 124, 164);
  columvalueLabel.Font.Color := TextColor; columvalueLabel.Transparent := True;
  columShape.Height  := 100; columShape1.Height := 100; columShape2.Height := 100;
  columShape3.Height := 100; columShape4.Height := 100; columShape5.Height := 100;

  // ── GPU info bar ─────────────────────────────────────────────────────────
  IsLight   := CurrentTheme = tmLight;
  BarBg     := IfThen(IsLight, $00F2F2F2, RGBToColor(26, 30, 46));
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

  FVisualGpuBar := TPanel.Create(FForm);
  FVisualGpuBar.Parent      := visualTabSheet;
  FVisualGpuBar.BevelOuter  := bvNone;
  FVisualGpuBar.BorderStyle := bsNone;
  FVisualGpuBar.Caption     := '';
  FVisualGpuBar.Color       := BarBg;
  FVisualGpuBar.ParentColor := False;
  FVisualGpuBar.OnPaint     := @FForm.SubCardPaint;

  // "Active GPU" section label
  Lbl := TLabel.Create(FVisualGpuBar);
  Lbl.Parent      := FVisualGpuBar;
  Lbl.Caption     := 'Active GPU';
  Lbl.Font.Style  := [fsBold];
  Lbl.Font.Size   := 9;
  Lbl.Font.Color  := TextColor;
  Lbl.Color       := BarBg;
  Lbl.Transparent := False;
  Lbl.AutoSize    := True;
  Lbl.Left        := 11;
  Lbl.Top         := 6;

  activegpuLabel.Visible := False;

  pcidevComboBox.Parent := FVisualGpuBar;
  pcidevComboBox.AnchorSideLeft.Control  := nil;
  pcidevComboBox.AnchorSideTop.Control   := nil;
  pcidevComboBox.AnchorSideRight.Control := nil;
  pcidevComboBox.Anchors := [akLeft, akTop];
  pcidevComboBox.Left    := 11;
  pcidevComboBox.Top     := 26;
  pcidevComboBox.Height  := 28;
  pcidevComboBox.Color       := BarBg;
  pcidevComboBox.Font.Color  := TextColor;
  SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
  QWidget_setStyleSheet(TQtWidget(pcidevComboBox.Handle).Widget, @SS);

  gpudescEdit.Parent := FVisualGpuBar;
  gpudescEdit.AnchorSideLeft.Control  := nil;
  gpudescEdit.AnchorSideTop.Control   := nil;
  gpudescEdit.AnchorSideRight.Control := nil;
  gpudescEdit.Anchors     := [akLeft, akTop, akRight];
  gpudescEdit.Left        := pcidevComboBox.Left + pcidevComboBox.Width + 4;
  gpudescEdit.Top         := 26;
  gpudescEdit.Height      := 28;
  gpudescEdit.Color       := BarBg;
  gpudescEdit.Font.Color  := TextColor;
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(240,240,240); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; padding: 2px 6px; }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 6px; }';
  QWidget_setStyleSheet(TQtWidget(gpudescEdit.Handle).Widget, @SS);

  // ── HUD Title field — option C: style in place ───────────────────────────
  hudtitleEdit.Color       := BarBg;
  hudtitleEdit.Font.Color  := TextColor;
  hudtitleEdit.BorderStyle := bsSingle;

  // ── HUD settings — integrated into Visual Settings card ──────────────────
  // Horizontal separator between section panels and HUD row (width set in Reflow)
  FVisualHudSep := TPanel.Create(FVisualCards[0]);
  FVisualHudSep.Parent      := FVisualCards[0];
  FVisualHudSep.BevelOuter  := bvNone;
  FVisualHudSep.Caption     := '';
  FVisualHudSep.Color       := $005A5050;
  FVisualHudSep.SetBounds(8, 382, 800, 1);
  FVisualHudSep.Anchors := [akLeft, akTop, akRight];

  FVisualHudBar := TPanel.Create(FVisualCards[0]);
  FVisualHudBar.Parent      := FVisualCards[0];  // child of main card, not tabsheet
  FVisualHudBar.BevelOuter  := bvNone;
  FVisualHudBar.BorderStyle := bsNone;
  FVisualHudBar.Caption     := '';
  FVisualHudBar.Color       := BarBg;
  FVisualHudBar.ParentColor := False;
  FVisualHudBar.OnPaint     := @FForm.SubCardPaint;

  // Reparent HUD toggle label
  hudtoggleLabel.Parent := FVisualHudBar;
  hudtoggleLabel.AnchorSideLeft.Control   := nil;
  hudtoggleLabel.AnchorSideTop.Control    := nil;
  hudtoggleLabel.AnchorSideRight.Control  := nil;
  hudtoggleLabel.AnchorSideBottom.Control := nil;
  hudtoggleLabel.Anchors    := [akLeft, akTop];
  hudtoggleLabel.Font.Color := TextColor;
  hudtoggleLabel.Left := 11;
  hudtoggleLabel.Top  := 6;

  // Hide the keyboard icon — Capture button takes its place
  hudtoggleImage.Parent := FVisualHudBar;
  hudtoggleImage.AnchorSideLeft.Control   := nil;
  hudtoggleImage.AnchorSideTop.Control    := nil;
  hudtoggleImage.AnchorSideRight.Control  := nil;
  hudtoggleImage.AnchorSideBottom.Control := nil;
  hudtoggleImage.Visible := False;

  // Hide the original combobox — now replaced by a styled TEdit
  hudonoffComboBox.Visible := False;

  // Capture button — shows "⌨ Capture" or "⌨ <shortcut>" after capture
  FVisualCaptureBtn := TBitBtn.Create(FVisualHudBar);
  FVisualCaptureBtn.Parent  := FVisualHudBar;
  FVisualCaptureBtn.Tag     := 1; // Visual Tab
  FVisualCaptureBtn.SetBounds(11, 24, 140, 28);
  FVisualCaptureBtn.OnClick := @FForm.CaptureBtnClick;
  FVisualCaptureBtn.Cursor  := crHandPoint;
  if Trim(hudonoffComboBox.Text) <> '' then
    FVisualCaptureBtn.Caption := '⌨ ' + hudonoffComboBox.Text
  else
    FVisualCaptureBtn.Caption := '⌨ Capture';

  // Create and link Compact HUD toggle switch
  FhudcompactToggle := TToggleSwitch.Create(FForm);
  FhudcompactToggle.Parent := FVisualHudBar;
  FhudcompactToggle.LinkToCheckBox(hudcompactCheckBox);
  FhudcompactToggle.Height := 20;
  FhudcompactToggle.Width  := FhudcompactToggle.GetOptimalWidth;
  FVisualToggles.Add(FhudcompactToggle);

  // Create and link Horizontal Strech toggle switch
  if not Assigned(horizontalstrechCheckBox) then
  begin
    horizontalstrechCheckBox := TCheckBox.Create(FVisualHudBar);
    horizontalstrechCheckBox.Parent := FVisualHudBar;
    horizontalstrechCheckBox.Caption := 'Horizontal Strech';
    horizontalstrechCheckBox.Visible := False;
  end;
  FhorizontalstrechToggle := TToggleSwitch.Create(FForm);
  FhorizontalstrechToggle.Parent := FVisualHudBar;
  FhorizontalstrechToggle.LinkToCheckBox(horizontalstrechCheckBox);
  FhorizontalstrechToggle.Height := 20;
  FhorizontalstrechToggle.Width  := FhorizontalstrechToggle.GetOptimalWidth;
  FVisualToggles.Add(FhorizontalstrechToggle);

  // Create and link Hide by default toggle switch
  FhidehudToggle := TToggleSwitch.Create(FForm);
  FhidehudToggle.Parent := FVisualHudBar;
  FhidehudToggle.LinkToCheckBox(hidehudCheckBox);
  FhidehudToggle.Height := 20;
  FhidehudToggle.Width  := FhidehudToggle.GetOptimalWidth;
  FVisualToggles.Add(FhidehudToggle);
  end;
end;


procedure TMangoHudUiHelper.ReflowVisualTab(AContentW, AContentH: Integer);
const
  MARGIN     = 4;
  GPU_TOP    = 52;
  GPU_H      = 67;
  CARD_TOP   = GPU_TOP + GPU_H + 10;  // = 129
  TABBAR_H   = 35;   // TPageControl tab bar header
  HUD_H      = 56;
  HDR        = 34;
  R1_TOP     = HDR + 4;   // = 38
  BASE_R1_H  = 118;
  BASE_R2_H  = 216;
  BASE_CARD_H = 477;
var
  W, S1, S2, SW: Integer;
  SecW1, SecW2, SecW3: Integer;
  RW, RH, CL, CC, CR, RT, RM, RB: Integer;
  ImgW, ImgH: Integer;
  HalfW, GrpW, GrpX, CY, ToggleRight, AvailW, ThirdW: Integer;
  TabH, ActiveCardH, ActiveHUD_TOP, ActiveHUD_SEP: Integer;
  RowsAvail, Extra, PerRow, ActiveR1_H, ActiveR2_H, ActiveR2_TOP: Integer;
begin
  with FForm do
  begin
  if not Assigned(FVisualCards[0]) then Exit;

  W  := AContentW - 2 * MARGIN;
  S1 := W div 3;
  S2 := (W * 2) div 3;
  SW := W - S2;
  SecW1 := S1 - 8;
  SecW2 := S2 - S1 - 8;
  SecW3 := W - S2 - 8;

  // GPU info bar — separate card above Visual Settings
  if Assigned(FVisualGpuBar) then
  begin
    FVisualGpuBar.SetBounds(MARGIN, GPU_TOP, W, GPU_H);
    gpudescEdit.Width := FVisualGpuBar.ClientWidth - gpudescEdit.Left - 5;
  end;

  // Derive available tab height from form height (Self.ClientHeight — always up-to-date
  // during FormResize, unlike child ClientHeight which is stale at that point).
  TabH := Max(606, AContentH - TABBAR_H);
  ActiveCardH := Max(BASE_CARD_H, TabH - CARD_TOP);

  // HUD bar anchors to card bottom; rows fill the space between header and HUD.
  ActiveHUD_TOP := ActiveCardH - HUD_H;
  ActiveHUD_SEP := ActiveHUD_TOP - 6;

  // Distribute extra vertical space equally between Row1 and Row2.
  RowsAvail    := ActiveHUD_SEP - 4 - R1_TOP;
  Extra        := Max(0, RowsAvail - (BASE_R1_H + 4 + BASE_R2_H));
  PerRow       := Extra div 2;
  ActiveR1_H   := BASE_R1_H + PerRow;
  ActiveR2_H   := RowsAvail - ActiveR1_H - 4;   // takes remainder (PerRow or PerRow+1)
  ActiveR2_TOP := R1_TOP + ActiveR1_H + 4;

  FVisualCards[0].SetBounds(MARGIN, CARD_TOP, W, ActiveCardH);

  // ── Row 1 section panels ──────────────────────────────────────────────────
  if Assigned(FVisualSections[0]) then
    FVisualSections[0].SetBounds(4,      R1_TOP, SecW1, ActiveR1_H);
  if Assigned(FVisualSections[1]) then
    FVisualSections[1].SetBounds(S1 + 4, R1_TOP, SecW2, ActiveR1_H);
  if Assigned(FVisualSections[2]) then
    FVisualSections[2].SetBounds(S2 + 4, R1_TOP, SecW3, ActiveR1_H);

  // ── Orientation section: 2 pairs (RB + image) centered in each half ──────
  CY    := 22 + (ActiveR1_H - 22) div 2;  // vertical center of content area
  HalfW := SecW1 div 2;
  // Left half: verticalRB (20×20) + vImage (30×56)
  GrpW := 20 + 6 + 30;
  GrpX := HalfW div 2 - GrpW div 2;
  if GrpX < 4 then GrpX := 4;
  verticalRadioButton.Left := GrpX;
  verticalRadioButton.Top  := CY - 10;
  vImage.Left := GrpX + 26;
  vImage.Top  := CY - 28;
  // Right half: horizontalRB (20×20) + hImage (56×30)
  GrpW := 20 + 6 + 56;
  GrpX := HalfW + HalfW div 2 - GrpW div 2;
  if GrpX + GrpW > SecW1 - 4 then GrpX := SecW1 - 4 - GrpW;
  horizontalRadioButton.Left := GrpX;
  horizontalRadioButton.Top  := CY - 10;
  hImage.Left := GrpX + 26;
  hImage.Top  := CY - 15;

  // ── Borders section: 2 pairs (RB + image) centered in each half ───────────
  HalfW := SecW2 div 2;
  // Left half: squareRB (20×20) + squareImage (48×42)
  GrpW := 20 + 6 + 48;
  GrpX := HalfW div 2 - GrpW div 2;
  if GrpX < 4 then GrpX := 4;
  squareRadioButton.Left := GrpX;
  squareRadioButton.Top  := CY - 10;
  squareImage.Left := GrpX + 26;
  squareImage.Top  := CY - 21;
  // Right half: roundRB + roundImage (48×42)
  GrpX := HalfW + HalfW div 2 - GrpW div 2;
  if GrpX + GrpW > SecW2 - 4 then GrpX := SecW2 - 4 - GrpW;
  roundRadioButton.Left := GrpX;
  roundRadioButton.Top  := CY - 10;
  roundImage.Left := GrpX + 26;
  roundImage.Top  := CY - 21;

  // Background section: transpTrackBar stretches to fill panel leaving room for alphavalueLabel on the right
  transpTrackBar.Width := Max(30, SecW3 - 52 - 44);
  alphavalueLabel.Left := 52 + transpTrackBar.Width + 8;
  alphavalueLabel.Top  := transpTrackBar.Top + 2;

  // ── Row 2 section panels ──────────────────────────────────────────────────
  if Assigned(FVisualSections[3]) then
    FVisualSections[3].SetBounds(4,      ActiveR2_TOP, SecW1, ActiveR2_H);
  if Assigned(FVisualSections[4]) then
    FVisualSections[4].SetBounds(S1 + 4, ActiveR2_TOP, SecW2, ActiveR2_H);
  if Assigned(FVisualSections[5]) then
    FVisualSections[5].SetBounds(S2 + 4, ActiveR2_TOP, SecW3, ActiveR2_H);

  // Fonts section: elastic widths (controls are relative to section panel)
  fontComboBox.Width      := SecW1 - 12;
  fontsizeTrackBar.Width  := Max(30, SecW1 - 60 - 44);
  fontsizevalueLabel.Left := 60 + fontsizeTrackBar.Width + 8;
  fontsizevalueLabel.Top  := fontsizeTrackBar.Top + 2;

  // Position section: Image fills panel, radio buttons proportional within it
  ImgW := SecW2 - 8;
  ImgH := ActiveR2_H - 26;
  Image1.SetBounds(4, 22, ImgW, ImgH);
  RW  := topleftRadioButton.Width;
  RH  := topleftRadioButton.Height;
  CL  := 4 + Round(ImgW * 0.094) - RW div 2;
  CC  := 4 + (ImgW div 2) - RW div 2;
  CR  := 4 + Round(ImgW * 0.906) - RW div 2;
  RT  := 22 + Round(ImgH * 0.131) - RH div 2;
  RB  := 22 + Round(ImgH * 0.620) - RH div 2;
  RM  := (RT + RB) div 2;
  topleftRadioButton.SetBounds(CL, RT, RW, RH);
  topcenterRadioButton.SetBounds(CC, RT, RW, RH);
  toprightRadioButton.SetBounds(CR, RT, RW, RH);
  middleleftRadioButton.SetBounds(CL, RM, RW, RH);
  middlerightRadioButton.SetBounds(CR, RM, RW, RH);
  bottomleftRadioButton.SetBounds(CL, RB, RW, RH);
  bottomcenterRadioButton.SetBounds(CC, RB, RW, RH);
  bottomrightRadioButton.SetBounds(CR, RB, RW, RH);
  // offsetxSpinEdit: right of middleleftRadioButton
  offsetxSpinEdit.Width := 60;
  offsetxSpinEdit.Height := 22;
  offsetxSpinEdit.Left := CL + RW + 4;
  offsetxSpinEdit.Top  := RM + (RH - offsetxSpinEdit.Height) div 2;
  // offsetySpinEdit: below topcenterRadioButton
  offsetySpinEdit.Width := 60;
  offsetySpinEdit.Height := 22;
  offsetySpinEdit.Left := CC + (RW - offsetySpinEdit.Width) div 2;
  offsetySpinEdit.Top  := RT + RH + 4;

  // Columns section: center 6 shapes (each 24px, 3px gap = 159px total) in panel
  CL := (SecW3 - 159) div 2;
  if CL < 6 then CL := 6;
  columShape.Left  := CL;       columShape1.Left := CL + 27;
  columShape2.Left := CL + 54;  columShape3.Left := CL + 81;
  columShape4.Left := CL + 108; columShape5.Left := CL + 135;
  minusButton.Visible := False;
  plusSpeedButton.Visible := False;
  if Assigned(FColumnsMinusBtn) then
    FColumnsMinusBtn.SetBounds(CL + 54, 162, 24, 24);
  if Assigned(FColumnsPlusBtn) then
    FColumnsPlusBtn.SetBounds(CL + 81, 162, 24, 24);
  columvalueLabel.Left := CL + 110;

  // HUD separator and bar — anchored to bottom of card
  if Assigned(FVisualHudSep) then
    FVisualHudSep.SetBounds(8, ActiveHUD_SEP, W - 16, 1);
  if Assigned(FVisualHudBar) then
  begin
    FVisualHudBar.SetBounds(0, ActiveHUD_TOP, W, HUD_H);

    // Vertically align toggles with FVisualCaptureBtn (Top 24, Height 28 -> center 28)
    CY := FVisualCaptureBtn.Top + (FVisualCaptureBtn.Height - 20) div 2;
    if Assigned(FhudcompactToggle) then FhudcompactToggle.Top := CY;
    if Assigned(FhorizontalstrechToggle) then FhorizontalstrechToggle.Top := CY;
    if Assigned(FhidehudToggle) then FhidehudToggle.Top := CY;

    // Position toggles sequentially to the right of FVisualCaptureBtn
    ToggleRight := FVisualCaptureBtn.Left + FVisualCaptureBtn.Width + 24;
    if Assigned(FhudcompactToggle) then
    begin
      FhudcompactToggle.Left := ToggleRight;
      ToggleRight := FhudcompactToggle.Left + FhudcompactToggle.Width + 18;
    end;
    if Assigned(FhorizontalstrechToggle) then
    begin
      FhorizontalstrechToggle.Left := ToggleRight;
      ToggleRight := FhorizontalstrechToggle.Left + FhorizontalstrechToggle.Width + 18;
    end;
    if Assigned(FhidehudToggle) then
    begin
      FhidehudToggle.Left := ToggleRight;
    end;
  end;
  end;
end;

procedure TMangoHudUiHelper.SyncVisualToggles;
var
  i: Integer;
begin
  if Assigned(FVisualToggles) then
    for i := 0 to FVisualToggles.Count - 1 do
      TToggleSwitch(FVisualToggles[i]).SyncFromLinked;
end;

// ============================================================================
// FPS LIMIT CHIPS — visual tag-style chip grid
// ============================================================================


procedure TMangoHudUiHelper.UpdateVisualCardTheme;
const
  DARK_BG   = $002E1E1A;  // matches PerfCardPaint / SubCardPaint dark fill
  LIGHT_BG  = $00F0F0F0;  // matches PerfCardPaint / SubCardPaint light fill
var
  i: Integer;
  CardBg, GbBg, TextColor: TColor;
  Card: TPanel;
  j: Integer;
  SS: WideString;
begin
  with FForm do
  begin
  if not Assigned(FVisualCards[0]) then Exit;

  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    GbBg      := LIGHT_BG;
    TextColor := LightTextColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    GbBg      := DARK_BG;
    TextColor := DarkTextColor;
  end;

  for i := 0 to 5 do
  begin
    Card := FVisualCards[i];
    if not Assigned(Card) then Continue;
    Card.Color := CardBg;
    Card.Invalidate;
    for j := 0 to Card.ControlCount - 1 do
    begin
      if Card.Controls[j] is TLabel then
      begin
        TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Transparent := True;
      end;
    end;
  end;

  // Invalidate inner section panels (section title labels keep their muted color)
  for i := 0 to 5 do
  begin
    if Assigned(FVisualSections[i]) then
    begin
      FVisualSections[i].Color := CardBg;
      FVisualSections[i].Invalidate;
    end;
  end;

  // Update GPU info bar
  if Assigned(FVisualGpuBar) then
  begin
    FVisualGpuBar.Color := CardBg;
    FVisualGpuBar.Invalidate;
    for j := 0 to FVisualGpuBar.ControlCount - 1 do
    begin
      if FVisualGpuBar.Controls[j] is TLabel then
      begin
        TLabel(FVisualGpuBar.Controls[j]).Font.Color := TextColor;
        TLabel(FVisualGpuBar.Controls[j]).Color      := CardBg;
      end;
    end;
    pcidevComboBox.Color     := CardBg;
    pcidevComboBox.Font.Color := TextColor;
    gpudescEdit.Color        := CardBg;
    gpudescEdit.Font.Color   := TextColor;
    hudtitleEdit.Color       := CardBg;
    hudtitleEdit.Font.Color  := TextColor;

    // Force Qt stylesheets — KDE/Breeze ignores LCL Color/Font.Color
    SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
    QWidget_setStyleSheet(TQtWidget(pcidevComboBox.Handle).Widget, @SS);
    if CurrentTheme = tmLight then
      SS := 'QLineEdit { background-color: rgb(240,240,240); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; padding: 2px 6px; }'
    else
      SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 6px; }';
    QWidget_setStyleSheet(TQtWidget(gpudescEdit.Handle).Widget, @SS);
    if CurrentTheme = tmLight then
      SS := 'QLineEdit { background-color: rgb(242,242,242); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; padding: 2px; }'
    else
      SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px; }' +
            'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
            'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
    QWidget_setStyleSheet(TQtWidget(hudtitleEdit.Handle).Widget, @SS);
  end;

  // Style Columns minus/plus TBitBtn controls
  if CurrentTheme = tmLight then
    SS := 'QPushButton { background-color: rgb(240,240,240); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; font-weight: bold; padding: 0px; }'
  else
    SS := 'QPushButton { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; font-weight: bold; padding: 0px; } ' +
          'QPushButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); } ' +
          'QPushButton:pressed { background-color: rgb(28,34,54); }';

  if Assigned(FColumnsMinusBtn) and FColumnsMinusBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FColumnsMinusBtn.Handle).Widget, @SS);
  if Assigned(FColumnsPlusBtn) and FColumnsPlusBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FColumnsPlusBtn.Handle).Widget, @SS);

  // Style Position offset spin edits
  if Assigned(offsetxSpinEdit) and offsetxSpinEdit.HandleAllocated then
  begin
    offsetxSpinEdit.Font.Size   := 7;
    offsetxSpinEdit.Font.Height := 0;
    offsetxSpinEdit.Font.Style  := [fsBold];
    offsetxSpinEdit.Font.Color  := clWhite;
    offsetxSpinEdit.Width       := 60;
    offsetxSpinEdit.Height      := 22;
    if CurrentTheme = tmLight then
      SS := 'QSpinBox { background-color: rgb(240, 240, 240); color: rgb(0, 0, 0); border: 1px solid rgb(200, 200, 200); border-radius: 4px; padding-left: 2px; padding-right: 15px; font-size: 8px; font-weight: bold; } ' +
            'QSpinBox QLineEdit { background: transparent; color: rgb(0, 0, 0); font-size: 8px; font-weight: bold; padding: 0px; margin: 0px; border: none; } ' +
            'QSpinBox::up-button { subcontrol-origin: border; subcontrol-position: top right; width: 13px; background-color: rgb(225, 225, 225); border-left: 1px solid rgb(200, 200, 200); border-bottom: 1px solid rgb(200, 200, 200); } ' +
            'QSpinBox::down-button { subcontrol-origin: border; subcontrol-position: bottom right; width: 13px; background-color: rgb(225, 225, 225); border-left: 1px solid rgb(200, 200, 200); }'
    else
      SS := 'QSpinBox { background-color: rgb(34, 42, 64); color: rgb(255, 255, 255); border: 1px solid rgb(64, 82, 126); border-radius: 4px; padding-left: 2px; padding-right: 15px; font-size: 8px; font-weight: bold; } ' +
            'QSpinBox QLineEdit { background: transparent; color: rgb(255, 255, 255); font-size: 8px; font-weight: bold; padding: 0px; margin: 0px; border: none; } ' +
            'QSpinBox::up-button { subcontrol-origin: border; subcontrol-position: top right; width: 13px; background-color: rgb(44, 54, 82); border-left: 1px solid rgb(64, 82, 126); border-bottom: 1px solid rgb(64, 82, 126); } ' +
            'QSpinBox::up-button:hover { background-color: rgb(64, 78, 116); } ' +
            'QSpinBox::down-button { subcontrol-origin: border; subcontrol-position: bottom right; width: 13px; background-color: rgb(44, 54, 82); border-left: 1px solid rgb(64, 82, 126); } ' +
            'QSpinBox::down-button:hover { background-color: rgb(64, 78, 116); }';
    QWidget_setStyleSheet(TQtWidget(offsetxSpinEdit.Handle).Widget, @SS);
  end;

  if Assigned(offsetySpinEdit) and offsetySpinEdit.HandleAllocated then
  begin
    offsetySpinEdit.Font.Size   := 7;
    offsetySpinEdit.Font.Height := 0;
    offsetySpinEdit.Font.Style  := [fsBold];
    offsetySpinEdit.Font.Color  := clWhite;
    offsetySpinEdit.Width       := 60;
    offsetySpinEdit.Height      := 22;
    if CurrentTheme = tmLight then
      SS := 'QSpinBox { background-color: rgb(240, 240, 240); color: rgb(0, 0, 0); border: 1px solid rgb(200, 200, 200); border-radius: 4px; padding-left: 2px; padding-right: 15px; font-size: 8px; font-weight: bold; } ' +
            'QSpinBox QLineEdit { background: transparent; color: rgb(0, 0, 0); font-size: 8px; font-weight: bold; padding: 0px; margin: 0px; border: none; } ' +
            'QSpinBox::up-button { subcontrol-origin: border; subcontrol-position: top right; width: 13px; background-color: rgb(225, 225, 225); border-left: 1px solid rgb(200, 200, 200); border-bottom: 1px solid rgb(200, 200, 200); } ' +
            'QSpinBox::down-button { subcontrol-origin: border; subcontrol-position: bottom right; width: 13px; background-color: rgb(225, 225, 225); border-left: 1px solid rgb(200, 200, 200); }'
    else
      SS := 'QSpinBox { background-color: rgb(34, 42, 64); color: rgb(255, 255, 255); border: 1px solid rgb(64, 82, 126); border-radius: 4px; padding-left: 2px; padding-right: 15px; font-size: 8px; font-weight: bold; } ' +
            'QSpinBox QLineEdit { background: transparent; color: rgb(255, 255, 255); font-size: 8px; font-weight: bold; padding: 0px; margin: 0px; border: none; } ' +
            'QSpinBox::up-button { subcontrol-origin: border; subcontrol-position: top right; width: 13px; background-color: rgb(44, 54, 82); border-left: 1px solid rgb(64, 82, 126); border-bottom: 1px solid rgb(64, 82, 126); } ' +
            'QSpinBox::up-button:hover { background-color: rgb(64, 78, 116); } ' +
            'QSpinBox::down-button { subcontrol-origin: border; subcontrol-position: bottom right; width: 13px; background-color: rgb(44, 54, 82); border-left: 1px solid rgb(64, 82, 126); } ' +
            'QSpinBox::down-button:hover { background-color: rgb(64, 78, 116); }';
    QWidget_setStyleSheet(TQtWidget(offsetySpinEdit.Handle).Widget, @SS);
  end;

  // Update HUD settings bar
  if Assigned(FVisualHudBar) then
  begin
    FVisualHudBar.Color := CardBg;
    FVisualHudBar.Invalidate;
    hudtoggleLabel.Font.Color    := TextColor;
    hudcompactCheckBox.ParentColor := True;
    hudcompactCheckBox.Font.Color := TextColor;
    horizontalstrechCheckBox.ParentColor := True;
    horizontalstrechCheckBox.Font.Color := TextColor;
    hidehudCheckBox.ParentColor := True;
    hidehudCheckBox.Font.Color   := TextColor;

    // Force QCheckBox text color via stylesheet (background transparent)
    if CurrentTheme = tmLight then
      SS := 'QCheckBox { color: rgb(0,0,0); background-color: transparent; }'
    else
      SS := 'QCheckBox { color: rgb(255,255,255); background-color: transparent; }';
    QWidget_setStyleSheet(TQtWidget(FVisualHudBar.Handle).Widget, @SS);
  end;

  alphavalueLabel.Font.Color    := CLR_TEXT_ACCENT;
  alphavalueLabel.Font.Style    := [fsBold];
  fontsizevalueLabel.Font.Color := CLR_TEXT_ACCENT;
  fontsizevalueLabel.Font.Style := [fsBold];
  end;
end;


procedure TMangoHudUiHelper.BuildFpsLimitEdit;
var
  IsLight: Boolean;
  Bg, TextColor, EditBg: TColor;
  Lbl: TLabel;
  ContL, ContT, ContW, ContH: Integer;
  SS: WideString;
begin
  with FForm do
  begin
  IsLight   := CurrentTheme = tmLight;
  Bg        := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);
  EditBg    := IfThen(IsLight, $00F5F5F5, $002E2E2E);

  // ── Free anchors that pointed to fpslimCheckGroup ─────────────────────────
  fpscolorCheckBox.AnchorSideLeft.Control   := nil;
  fpscolorCheckBox.AnchorSideTop.Control    := nil;
  fpscolorCheckBox.AnchorSideBottom.Control := nil;
  fpscolorCheckBox.Anchors := [akLeft, akTop];

  fpscolor1ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor1ColorButton.AnchorSideTop.Control    := nil;
  fpscolor1ColorButton.AnchorSideBottom.Control := nil;
  fpscolor1ColorButton.Anchors := [akLeft, akTop];

  fpscolor2ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor2ColorButton.AnchorSideTop.Control    := nil;
  fpscolor2ColorButton.AnchorSideBottom.Control := nil;
  fpscolor2ColorButton.Anchors := [akLeft, akTop];

  fpscolor3ColorButton.AnchorSideLeft.Control   := nil;
  fpscolor3ColorButton.AnchorSideRight.Control  := nil;
  fpscolor3ColorButton.AnchorSideTop.Control    := nil;
  fpscolor3ColorButton.AnchorSideBottom.Control := nil;
  fpscolor3ColorButton.Anchors := [akLeft, akTop];

  fpscolor2SpinEdit.AnchorSideLeft.Control   := nil;
  fpscolor2SpinEdit.AnchorSideTop.Control    := nil;
  fpscolor2SpinEdit.AnchorSideBottom.Control := nil;
  fpscolor2SpinEdit.Anchors := [akLeft, akTop];

  fpscolor3SpinEdit.AnchorSideLeft.Control   := nil;
  fpscolor3SpinEdit.AnchorSideTop.Control    := nil;
  fpscolor3SpinEdit.AnchorSideRight.Control  := nil;
  fpscolor3SpinEdit.AnchorSideBottom.Control := nil;
  fpscolor3SpinEdit.Anchors := [akLeft, akTop];

  methodLabel.AnchorSideLeft.Control   := nil;
  methodLabel.AnchorSideTop.Control    := nil;
  methodLabel.AnchorSideBottom.Control := nil;
  methodLabel.Anchors := [akLeft, akTop];

  fpslimmetComboBox.AnchorSideLeft.Control   := nil;
  fpslimmetComboBox.AnchorSideTop.Control    := nil;
  fpslimmetComboBox.AnchorSideBottom.Control := nil;
  fpslimmetComboBox.Anchors := [akLeft, akTop];

  limtoggleLabel.AnchorSideLeft.Control   := nil;
  limtoggleLabel.AnchorSideTop.Control    := nil;
  limtoggleLabel.AnchorSideRight.Control  := nil;
  limtoggleLabel.AnchorSideBottom.Control := nil;
  limtoggleLabel.Anchors := [akLeft, akTop];

  // Hide legacy controls
  fpslimCheckGroup.Visible := False;
  offsetSpinEdit.Visible   := False;
  offsetLabel.Visible      := False;
  fpslimLabel.Visible      := False;

  // Reparent controls to FPerfLimitSec
  fpscolorCheckBox.Parent          := FPerfLimitSec;
  fpscolor1ColorButton.Parent      := FPerfLimitSec;
  fpscolor2ColorButton.Parent      := FPerfLimitSec;
  fpscolor3ColorButton.Parent      := FPerfLimitSec;
  fpscolor2SpinEdit.Parent         := FPerfLimitSec;
  fpscolor3SpinEdit.Parent         := FPerfLimitSec;
  methodLabel.Parent               := FPerfLimitSec;
  fpslimmetComboBox.Parent         := FPerfLimitSec;

  fpscolor1ColorButton.BorderWidth := 0;
  fpscolor1ColorButton.ButtonColorSize := 80;
  fpscolor2ColorButton.BorderWidth := 0;
  fpscolor2ColorButton.ButtonColorSize := 80;
  fpscolor3ColorButton.BorderWidth := 0;
  fpscolor3ColorButton.ButtonColorSize := 80;

  ContL := 12;
  ContT := 32;
  ContW := FPerfLimitSec.Width - 24;
  ContH := FPerfLimitSec.Height - ContT;

  // Title label with lightning icon
  FFpsLimitTitleLbl := TLabel.Create(FForm);
  FFpsLimitTitleLbl.Parent := FPerfLimitSec;
  FFpsLimitTitleLbl.Caption := '⚡ FPS Limit';
  FFpsLimitTitleLbl.Font.Name := 'Noto Sans';
  FFpsLimitTitleLbl.Font.Color := TextColor;
  FFpsLimitTitleLbl.Font.Style := [fsBold];
  FFpsLimitTitleLbl.Font.Size := 9;
  FFpsLimitTitleLbl.Transparent := True;
  FFpsLimitTitleLbl.Alignment := taCenter;
  FFpsLimitTitleLbl.AutoSize := False;
  FFpsLimitTitleLbl.SetBounds(ContL + 6, ContT + 8, 140, 20);
  FFpsLimitTitleLbl.Anchors := [akLeft, akTop];

  // Create the edit — very large font for readability
  FFpsLimitEdit := TEdit.Create(FForm);
  FFpsLimitEdit.Parent := FPerfLimitSec;
  FFpsLimitEdit.SetBounds(ContL + 6, ContT + 34, 232, 44);
  FFpsLimitEdit.Constraints.MinWidth := 232;
  FFpsLimitEdit.Constraints.MaxWidth := 232;
  FFpsLimitEdit.Anchors := [akLeft, akTop];
  FFpsLimitEdit.Font.Name := 'DejaVu Sans Mono';
  FFpsLimitEdit.Font.Size := 24;
  FFpsLimitEdit.Font.Color := TextColor;
  FFpsLimitEdit.Color := EditBg;
  FFpsLimitEdit.BorderStyle := bsNone;
  FFpsLimitEdit.Alignment := taCenter;
  FFpsLimitEdit.Text := '0';
  // Force QLineEdit stylesheet — KDE/Breeze ignores LCL Color/Font.Color
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: none; }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px; }' +
          'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
  QWidget_setStyleSheet(TQtWidget(FFpsLimitEdit.Handle).Widget, @SS);

  // Small hint label below the edit
  FFpsLimitHintLbl := TLabel.Create(FForm);
  FFpsLimitHintLbl.Parent := FPerfLimitSec;
  FFpsLimitHintLbl.Caption := 'e.g. 30,60,120,0 — 0 to unlimited';
  FFpsLimitHintLbl.Font.Name := 'Noto Sans';
  FFpsLimitHintLbl.Font.Color := IfThen(IsLight, $00777777, $009E9E9E);
  FFpsLimitHintLbl.Font.Size := 8;
  FFpsLimitHintLbl.Transparent := True;
  FFpsLimitHintLbl.Alignment := taCenter;
  FFpsLimitHintLbl.AutoSize := False;
  FFpsLimitHintLbl.SetBounds(ContL + 6, ContT + 84, ContW - 12, 18);
  FFpsLimitHintLbl.Anchors := [akLeft, akTop];

  // ── Spread controls vertically: edit top, colours middle, method bottom ───
  fpscolorCheckBox.SetBounds(ContL + (ContW - 150) div 2, ContT + 115, 150, 21);
  fpscolorCheckBox.Font.Color := TextColor;

  fpscolor1ColorButton.SetBounds(ContL + 6,        ContT + 140, 80, 18);
  fpscolor2ColorButton.SetBounds(ContL + ContW div 2 - 40, ContT + 140, 80, 18);
  fpscolor3ColorButton.SetBounds(ContL + ContW - 86,      ContT + 140, 80, 18);

  fpscolor2SpinEdit.SetBounds(ContL + ContW div 2 - 35, ContT + 165, 70, 26);
  fpscolor3SpinEdit.SetBounds(ContL + ContW - 81,      ContT + 165, 70, 26);

  // ── Method / Limit toggle key pinned to the bottom of the card ───────────
  methodLabel.SetBounds(ContL + 6, ContT + ContH - 70, 60, 18);
  methodLabel.Font.Color := TextColor;

  fpslimmetComboBox.SetBounds(ContL + 6, ContT + ContH - 48, 110, 32);

  limtoggleLabel.SetBounds(ContL + 140, ContT + ContH - 70, 120, 18);
  if Assigned(FLimitCaptureBtn) then
    FLimitCaptureBtn.SetBounds(ContL + 140, ContT + ContH - 48, 160, 28);
  end;
end;


procedure TMangoHudUiHelper.InitPerformanceTab;
const
  GB_OFFSET = 24;

  // Vertical layout: 2 full-width cards
  ROW1_TOP = 0;
  ROW1_H   = 180;
  ROW2_TOP = 185;
  ROW2_H   = 389;

  // Each card holds two side-by-side sections
  procedure MakeCard(AIndex: Integer;
                     ATitle1: string; AGB1: TGroupBox;
                     ATitle2: string; AGB2: TGroupBox;
                     ATop, AHeight: Integer);
  var
    Card: TPanel;
    Lbl1, Lbl2: TLabel;
    IsLight: Boolean;
    BgColor, TextColor: TColor;
    HalfW: Integer;
    Sec1, Sec2: TPanel;
  begin
    with FForm do
    begin
      IsLight   := CurrentTheme = tmLight;
      BgColor   := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
      TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

      Card := TPanel.Create(FForm);
      Card.Parent      := performanceTabSheet;
      Card.BevelOuter  := bvNone;
      Card.BorderStyle := bsNone;
      Card.Caption     := '';
      Card.Color       := BgColor;
      Card.ParentColor := False;
      Card.OnPaint     := @FForm.SubCardPaint;
      Card.SetBounds(2, ATop, 800, AHeight);  // provisional; corrected by Reflow
      FPerfCards[AIndex] := Card;

      HalfW := Card.Width div 2;

      // Create the two sub-panels
      Sec1 := TPanel.Create(FForm);
      Sec1.Parent      := Card;
      Sec1.BevelOuter  := bvNone;
      Sec1.BorderStyle := bsNone;
      Sec1.Caption     := '';
      Sec1.Color       := BgColor;
      Sec1.OnPaint     := @FForm.SubCardPaint;
      Sec1.SetBounds(6, GB_OFFSET, HalfW - 10, AHeight - GB_OFFSET - 6);

      Sec2 := TPanel.Create(FForm);
      Sec2.Parent      := Card;
      Sec2.BevelOuter  := bvNone;
      Sec2.BorderStyle := bsNone;
      Sec2.Caption     := '';
      Sec2.Color       := BgColor;
      Sec2.OnPaint     := @FForm.SubCardPaint;
      Sec2.SetBounds(HalfW + 4, GB_OFFSET, HalfW - 10, AHeight - GB_OFFSET - 6);

      if AIndex = 0 then
      begin
        FPerfInfoSec  := Sec1;
        FPerfVsyncSec := Sec2;
      end
      else
      begin
        FPerfLimitSec   := Sec1;
        FPerfFiltersSec := Sec2;
      end;

      // Left section title
      Lbl1 := TLabel.Create(Card);
      Lbl1.Parent      := Card;
      StyleLabel(Lbl1, lrSectionTitle);
      Lbl1.Caption     := ATitle1;
      Lbl1.SetBounds(18, 5, 200, 18);
      FPerfLeftLbl[AIndex] := Lbl1;

      // Right section title
      Lbl2 := TLabel.Create(Card);
      Lbl2.Parent      := Card;
      StyleLabel(Lbl2, lrSectionTitle);
      Lbl2.Caption     := ATitle2;
      Lbl2.SetBounds(HalfW + 16, 5, 200, 18);
      FPerfRightLbl[AIndex] := Lbl2;

      // Hide original LFM groupboxes
      AGB1.Visible := False;
      AGB2.Visible := False;

      // Custom UI for FPS Limit Toggle in Limiters card (AIndex = 1, AGB1 = fpslimiterGroupBox)
      if AIndex = 1 then
      begin
        fpslimtoggleComboBox.Visible := False;
        fpstoggleImage.Visible := False;

        limtoggleLabel.AnchorSideLeft.Control   := nil;
        limtoggleLabel.AnchorSideTop.Control    := nil;
        limtoggleLabel.AnchorSideRight.Control  := nil;
        limtoggleLabel.AnchorSideBottom.Control := nil;
        limtoggleLabel.Anchors := [akLeft, akTop];
        limtoggleLabel.Parent  := Sec1;
        limtoggleLabel.Font.Color := TextColor;
        limtoggleLabel.ParentColor := True;

        FLimitCaptureBtn := TBitBtn.Create(Sec1);
        FLimitCaptureBtn.Parent  := Sec1;
        FLimitCaptureBtn.Tag     := 2;
        FLimitCaptureBtn.OnClick := @FForm.CaptureBtnClick;
        FLimitCaptureBtn.Cursor  := crHandPoint;
        if Trim(fpslimtoggleComboBox.Text) <> '' then
          FLimitCaptureBtn.Caption := '⌨ ' + fpslimtoggleComboBox.Text
        else
          FLimitCaptureBtn.Caption := '⌨ Capture';
      end;
    end;
  end;

  procedure MakeVsyncRow(AIndex: Integer; ARow, AHeight: Integer;
                         Logo: TImage; Combo: TComboBox);
  var
    Row: TPanel;
  begin
    with FForm do
    begin
      Row := TPanel.Create(FPerfVsyncSec);
      Row.Parent      := FPerfVsyncSec;
      Row.BevelOuter  := bvNone;
      Row.Caption     := '';
      Row.ParentColor := True;
      Row.SetBounds(8, ARow, FPerfVsyncSec.ClientWidth - 16, AHeight);
      Row.Anchors     := [akLeft, akTop, akRight];
      FVsyncRows[AIndex] := Row;

      Logo.Parent      := Row;
      Logo.Transparent := True;
      Logo.AnchorSideLeft.Control  := nil;
      Logo.AnchorSideTop.Control   := nil;
      Logo.AnchorSideRight.Control := nil;
      Logo.Anchors := [akLeft, akTop];
      Logo.Left    := 8;
      Logo.Top     := (AHeight - Logo.Height) div 2;

      Combo.Parent := Row;
      Combo.AnchorSideLeft.Control   := nil;
      Combo.AnchorSideTop.Control    := nil;
      Combo.AnchorSideRight.Control  := nil;
      Combo.AnchorSideBottom.Control := nil;
      Combo.Anchors := [akLeft, akTop];
      Combo.Top     := (AHeight - Combo.Height) div 2;
      Combo.Left    := Logo.Left + Logo.Width + 8;
    end;
  end;

  function PlacePerfToggle(ACheckBox: TCheckBox; AParent: TWinControl): TToggleSwitch;
  begin
    Result := TToggleSwitch.Create(FForm);
    Result.Parent := AParent;
    Result.LinkToCheckBox(ACheckBox);
    Result.Height := 20;
    Result.Width  := Result.GetOptimalWidth;
    FPerfToggles.Add(Result);
  end;

var
  BgBox: TPaintBox;
  SS: WideString;
begin
  with FForm do
  begin
  BgBox := TPaintBox.Create(FForm);
  BgBox.Parent  := performanceTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @FForm.PresetsBgBoxPaint;

  MakeCard(0, 'Information', fpsGroupBox,        'VSYNC',   vsyncGroupBox,   ROW1_TOP, ROW1_H);
  MakeCard(1, 'Limiters',    fpslimiterGroupBox, 'Filters', filtersGroupBox, ROW2_TOP, ROW2_H);
  FPerfCards[2] := nil;
  FPerfCards[3] := nil;

  // Reparent Information controls to FPerfInfoSec
  fpsCheckBox.Parent                := FPerfInfoSec;
  frametimegraphCheckBox.Parent     := FPerfInfoSec;
  if not Assigned(frametimedetailedCheckBox) then
  begin
    frametimedetailedCheckBox := TCheckBox.Create(FForm);
    frametimedetailedCheckBox.Name := 'frametimedetailedCheckBox';
    frametimedetailedCheckBox.Caption := 'Frame Time +';
    frametimedetailedCheckBox.Hint := 'Show detailed frame timing breakdown';
    frametimedetailedCheckBox.ShowHint := True;
  end;
  frametimedetailedCheckBox.Parent  := FPerfInfoSec;
  frametimegraphColorButton.Parent  := FPerfInfoSec;
  frametimetypeBitBtn.Parent        := FPerfInfoSec;
  fpsavgCheckBox.Parent             := FPerfInfoSec;
  fpsavgBitBtn.Parent               := FPerfInfoSec;
  framecountCheckBox.Parent         := FPerfInfoSec;
  ftraceCheckBox.Parent             := FPerfInfoSec;
  showfpslimCheckBox.Parent         := FPerfInfoSec;
  vpsCheckBox.Parent                := FPerfInfoSec;

  // Create and link Performance Information toggles
  FfpsToggle               := PlacePerfToggle(fpsCheckBox, FPerfInfoSec);
  FframetimegraphToggle    := PlacePerfToggle(frametimegraphCheckBox, FPerfInfoSec);
  FframetimedetailedToggle := PlacePerfToggle(frametimedetailedCheckBox, FPerfInfoSec);
  FfpsavgToggle            := PlacePerfToggle(fpsavgCheckBox, FPerfInfoSec);
  FframecountToggle        := PlacePerfToggle(framecountCheckBox, FPerfInfoSec);
  FftraceToggle            := PlacePerfToggle(ftraceCheckBox, FPerfInfoSec);
  FshowfpslimToggle        := PlacePerfToggle(showfpslimCheckBox, FPerfInfoSec);
  FvpsToggle               := PlacePerfToggle(vpsCheckBox, FPerfInfoSec);

  // Free all Information grid controls from anchor chains — Reflow will center them
  frametimegraphColorButton.AnchorSideLeft.Control := nil; frametimegraphColorButton.AnchorSideTop.Control := nil; frametimegraphColorButton.AnchorSideRight.Control := nil; frametimegraphColorButton.AnchorSideBottom.Control := nil; frametimegraphColorButton.Anchors := [akLeft, akTop];
  frametimetypeBitBtn.AnchorSideLeft.Control    := nil; frametimetypeBitBtn.AnchorSideTop.Control    := nil; frametimetypeBitBtn.AnchorSideRight.Control    := nil; frametimetypeBitBtn.AnchorSideBottom.Control    := nil; frametimetypeBitBtn.Anchors    := [akLeft, akTop];
  fpsavgBitBtn.AnchorSideLeft.Control           := nil; fpsavgBitBtn.AnchorSideTop.Control           := nil; fpsavgBitBtn.AnchorSideRight.Control           := nil; fpsavgBitBtn.AnchorSideBottom.Control           := nil; fpsavgBitBtn.Anchors           := [akLeft, akTop];

  frametimedetailedCheckBox.Enabled := frametimegraphCheckBox.Checked;
  FframetimedetailedToggle.Enabled  := frametimegraphCheckBox.Checked;
  frametimegraphCheckBox.OnChange   := @FrametimegraphCheckBoxChange;

  // Reparent Filters controls to FPerfFiltersSec and clear LCL anchors
  filterRadioGroup.Parent   := FPerfFiltersSec;
  afLabel.Parent            := FPerfFiltersSec;
  afTrackBar.Parent         := FPerfFiltersSec;
  afvalueLabel.Parent       := FPerfFiltersSec;
  mipmapLabel.Parent        := FPerfFiltersSec;
  mipmapTrackBar.Parent     := FPerfFiltersSec;
  mipmapvalueLabel.Parent   := FPerfFiltersSec;

  filterRadioGroup.AnchorSideLeft.Control := nil; filterRadioGroup.AnchorSideTop.Control := nil; filterRadioGroup.AnchorSideRight.Control := nil; filterRadioGroup.AnchorSideBottom.Control := nil; filterRadioGroup.Anchors := [akLeft, akTop];
  afLabel.AnchorSideLeft.Control := nil; afLabel.AnchorSideTop.Control := nil; afLabel.AnchorSideRight.Control := nil; afLabel.AnchorSideBottom.Control := nil; afLabel.Anchors := [akLeft, akTop];
  afTrackBar.AnchorSideLeft.Control := nil; afTrackBar.AnchorSideTop.Control := nil; afTrackBar.AnchorSideRight.Control := nil; afTrackBar.AnchorSideBottom.Control := nil; afTrackBar.Anchors := [akLeft, akTop];
      mipmapvalueLabel.AnchorSideLeft.Control := nil; mipmapvalueLabel.AnchorSideTop.Control := nil; mipmapvalueLabel.AnchorSideRight.Control := nil; mipmapvalueLabel.AnchorSideBottom.Control := nil; mipmapvalueLabel.Anchors := [akLeft, akTop];

  afTrackBar.Orientation := trHorizontal;
  afTrackBar.Reversed    := False;
  afTrackBar.TickStyle   := tsNone;
  afTrackBar.Height      := 24;
  mipmapTrackBar.Orientation := trHorizontal;
  mipmapTrackBar.Reversed    := False;
  mipmapTrackBar.TickStyle   := tsNone;
  mipmapTrackBar.Height      := 24;
  afvalueLabel.Font.Color := CLR_TEXT_ACCENT;
  afvalueLabel.Font.Style := [fsBold];
  afvalueLabel.Transparent := True;
  mipmapvalueLabel.Font.Color := CLR_TEXT_ACCENT;
  mipmapvalueLabel.Font.Style := [fsBold];
  mipmapvalueLabel.Transparent := True;

  SS := 'QGroupBox { border: none; }';
  QWidget_setStyleSheet(TQtWidget(filterRadioGroup.Handle).Widget, @SS);
  filterRadioGroup.OnClick := @FForm.filterRadioGroupClick;
  filterRadioGroup.OnSelectionChanged := @FForm.filterRadioGroupClick;

  // VSYNC card — Vulkan in top half, OpenGL in bottom half
  MakeVsyncRow(0, 4, 44, vulkanImage, vsyncComboBox);
  MakeVsyncRow(1, 50, 44, openglImage, glvsyncComboBox);

  // FPS Limit — single comma-separated input field
  BuildFpsLimitEdit;
  FfpscolorToggle := PlacePerfToggle(fpscolorCheckBox, FPerfLimitSec);
  end;
end;

procedure TMangoHudUiHelper.ReflowPerformanceTab(AContentW, AContentH: Integer);
const
  MARGIN     = 4;
  GAP        = 5;   // gap between cards
  ROW1_TOP   = 0;
  ROW1_H     = 180;  // Information card — fixed height
  BASE_ROW2_H = 389;
  ROW2_TOP   = ROW1_TOP + ROW1_H + GAP;  // = 185
  TABBAR_H   = 35;   // TPageControl tab bar header
  GB_OFF     = 24;
  IMARGIN    = 6;
  IGAP       = 8;
var
  CardW, SecW, ContW, ContH, i: Integer;
  LeftM, Col1W, Col2W, Col3W, InnerGap: Integer;
  Col1Left, Col2Left, Col3Left: Integer;
  ColorGroupW, ColorGap, ColorStart, ColW, SpinW: Integer;
  GroupH, MiddleStart, MiddleEnd, GroupTop: Integer;
  ComboW, BtnW, MiddleGap, TotalRowW, RowStart: Integer;
  TabH, ActiveRow2H, FilterSecH: Integer;
  FilterContentW, FilterLeft, FilterValW, FilterGapW, FilterTrackW: Integer;
begin
  with FForm do
  begin
  CardW := AContentW - MARGIN * 2;

  TabH        := Max(606, AContentH - TABBAR_H);
  ActiveRow2H := Max(BASE_ROW2_H, TabH - ROW1_H - GAP - 2 * MARGIN);

  if Assigned(FPerfCards[0]) then
  begin
    FPerfCards[0].SetBounds(MARGIN, ROW1_TOP, CardW, ROW1_H);
    FPerfCards[1].SetBounds(MARGIN, ROW2_TOP, CardW, ActiveRow2H);

    SecW := (CardW - 2 * IMARGIN - IGAP) div 2;

    // Position sub-section panels
    if Assigned(FPerfInfoSec) then
      FPerfInfoSec.SetBounds(IMARGIN, GB_OFF, SecW, ROW1_H - GB_OFF - IMARGIN);
    if Assigned(FPerfVsyncSec) then
      FPerfVsyncSec.SetBounds(IMARGIN + SecW + IGAP, GB_OFF, SecW, ROW1_H - GB_OFF - IMARGIN);

    if Assigned(FPerfLimitSec) then
      FPerfLimitSec.SetBounds(IMARGIN, GB_OFF, SecW, ActiveRow2H - GB_OFF - IMARGIN);

    // Reposition Filter controls within FPerfFiltersSec
    if Assigned(FPerfFiltersSec) then
    begin
      FilterSecH := ActiveRow2H - GB_OFF - IMARGIN;
      FPerfFiltersSec.SetBounds(IMARGIN + SecW + IGAP, GB_OFF, SecW, FilterSecH);

      filterRadioGroup.Left   := (FPerfFiltersSec.ClientWidth - filterRadioGroup.Width) div 2;
      filterRadioGroup.Top    := 20;

      FilterValW   := 35;
      FilterGapW   := 8;
      FilterLeft   := 20;
      FilterTrackW := FPerfFiltersSec.ClientWidth - FilterLeft - FilterGapW - FilterValW - 16;
      if FilterTrackW < 80 then FilterTrackW := 80;

      afLabel.Left          := FilterLeft;
      afLabel.Top           := 130;
      afTrackBar.Left       := FilterLeft;
      afTrackBar.Top        := 150;
      afTrackBar.Width      := FilterTrackW;
      afTrackBar.Height     := 24;

      afvalueLabel.Left     := afTrackBar.Left + afTrackBar.Width + FilterGapW;
      afvalueLabel.Top      := afTrackBar.Top + (afTrackBar.Height - afvalueLabel.Height) div 2;

      mipmapLabel.Left      := FilterLeft;
      mipmapLabel.Top       := 190;
      mipmapTrackBar.Left   := FilterLeft;
      mipmapTrackBar.Top    := 210;
      mipmapTrackBar.Width  := FilterTrackW;
      mipmapTrackBar.Height := 24;

      mipmapvalueLabel.Left := mipmapTrackBar.Left + mipmapTrackBar.Width + FilterGapW;
      mipmapvalueLabel.Top  := mipmapTrackBar.Top + (mipmapTrackBar.Height - mipmapvalueLabel.Height) div 2;
    end;

    // Position section title labels
    for i := 0 to 1 do
    begin
      if Assigned(FPerfLeftLbl[i]) then
        FPerfLeftLbl[i].Left := IMARGIN + 12;
      if Assigned(FPerfRightLbl[i]) then
        FPerfRightLbl[i].Left := IMARGIN + SecW + IGAP + 12;
    end;

    // Center Information grid columns within FPerfInfoSec dynamically
    if Assigned(FPerfInfoSec) then
    begin
      LeftM := 16;
      Col1W := 100;
      Col2W := 115;
      Col3W := 105;
      InnerGap := (FPerfInfoSec.ClientWidth - 2 * LeftM - (Col1W + Col2W + Col3W)) div 2;
      if InnerGap < 8 then InnerGap := 8;

      Col1Left := LeftM;
      Col2Left := Col1Left + Col1W + InnerGap;
      Col3Left := Col2Left + Col2W + InnerGap;

      // Column 1: Show FPS (Row 1), Frame Time (Row 2), Color (Row 2.5), Curve/Hist (Row 3, centered below Frame Time)
      fpsCheckBox.Left                := Col1Left;
      fpsCheckBox.Top                 := 6;
      frametimegraphCheckBox.Left     := Col1Left;
      frametimegraphCheckBox.Top      := 56;
      if Assigned(FfpsToggle) then begin FfpsToggle.Left := Col1Left; FfpsToggle.Top := 6; end;
      if Assigned(FframetimegraphToggle) then begin FframetimegraphToggle.Left := Col1Left; FframetimegraphToggle.Top := 56; end;
      frametimegraphColorButton.Left  := Col1Left + (Col1W - frametimegraphColorButton.Width) div 2;
      frametimegraphColorButton.Top   := 78;
      frametimetypeBitBtn.Left        := Col1Left + (Col1W - frametimetypeBitBtn.Width) div 2;
      frametimetypeBitBtn.Top         := 94;

      // Column 2: FPS Average (Row 1), 1% low button (Row 1.5), Frame Time + (Row 2, right of Frame Time), ftrace debug (Row 3)
      fpsavgCheckBox.Left             := Col2Left;
      fpsavgCheckBox.Top              := 6;
      fpsavgBitBtn.Left               := Col2Left;
      fpsavgBitBtn.Top                := 28;
      if Assigned(frametimedetailedCheckBox) then
      begin
        frametimedetailedCheckBox.Left := Col2Left;
        frametimedetailedCheckBox.Top  := 56;
      end;
      ftraceCheckBox.Left             := Col2Left;
      ftraceCheckBox.Top              := 94;
      if Assigned(FfpsavgToggle) then begin FfpsavgToggle.Left := Col2Left; FfpsavgToggle.Top := 6; end;
      if Assigned(FframetimedetailedToggle) then
      begin
        FframetimedetailedToggle.Left := Col2Left;
        FframetimedetailedToggle.Top  := 56;
      end;
      if Assigned(FftraceToggle) then begin FftraceToggle.Left := Col2Left; FftraceToggle.Top := 94; end;

      // Column 3: FPS limit (Row 1), VPS (Row 2), Count Frames (Row 3, vertically aligned with ftrace debug)
      showfpslimCheckBox.Left         := Col3Left;
      showfpslimCheckBox.Top          := 6;
      vpsCheckBox.Left                := Col3Left;
      vpsCheckBox.Top                 := 56;
      framecountCheckBox.Left         := Col3Left;
      framecountCheckBox.Top          := 94;
      if Assigned(FshowfpslimToggle) then begin FshowfpslimToggle.Left := Col3Left; FshowfpslimToggle.Top := 6; end;
      if Assigned(FvpsToggle) then begin FvpsToggle.Left := Col3Left; FvpsToggle.Top := 56; end;
      if Assigned(FframecountToggle) then begin FframecountToggle.Left := Col3Left; FframecountToggle.Top := 94; end;
    end;

    // Center logo+combo block (101+8+109=218px) within each VSYNC row
    if Assigned(FPerfVsyncSec) then
    begin
      if Assigned(FVsyncRows[0]) then
      begin
        FVsyncRows[0].Top    := 20;
        FVsyncRows[0].Width  := FPerfVsyncSec.ClientWidth - 16;
        vulkanImage.Left     := (FVsyncRows[0].Width - 218) div 2;
        vsyncComboBox.Left   := vulkanImage.Left + vulkanImage.Width + 8;
      end;
      if Assigned(FVsyncRows[1]) then
      begin
        FVsyncRows[1].Top    := 84;
        FVsyncRows[1].Width  := FPerfVsyncSec.ClientWidth - 16;
        openglImage.Left     := (FVsyncRows[1].Width - 218) div 2;
        glvsyncComboBox.Left := openglImage.Left + openglImage.Width + 8;
      end;
    end;

    // Reposition dynamic elements in FPS Limit card based on final width/height of FPerfLimitSec
    if Assigned(FPerfLimitSec) then
    begin
      ContW := FPerfLimitSec.Width - 24;
      ContH := FPerfLimitSec.Height - 32;

      if Assigned(FFpsLimitTitleLbl) then
      begin
        FFpsLimitTitleLbl.Left := 0;
        FFpsLimitTitleLbl.Width := FPerfLimitSec.ClientWidth;
        FFpsLimitTitleLbl.Top := 4;
      end;
      if Assigned(FFpsLimitEdit) then
      begin
        FFpsLimitEdit.Width := 232;
        FFpsLimitEdit.Constraints.MinWidth := 232;
        FFpsLimitEdit.Constraints.MaxWidth := 232;
        FFpsLimitEdit.Left := (FPerfLimitSec.ClientWidth - FFpsLimitEdit.Width) div 2;
        FFpsLimitEdit.Top := 22;
      end;
      if Assigned(FFpsLimitHintLbl) then
      begin
        FFpsLimitHintLbl.Left := 0;
        FFpsLimitHintLbl.Width := FPerfLimitSec.ClientWidth;
        if Assigned(FFpsLimitEdit) then
          FFpsLimitHintLbl.Top := FFpsLimitEdit.Top + FFpsLimitEdit.Height + 6
        else
          FFpsLimitHintLbl.Top := 72;
        FFpsLimitHintLbl.Height := 18;
      end;

      if Assigned(FfpscolorToggle) then
      begin
        FfpscolorToggle.Left := (FPerfLimitSec.ClientWidth - FfpscolorToggle.Width) div 2;
      end;

      ColW := 80;
      SpinW := 70;
      ColorGap := -4;
      ColorGroupW := 3 * ColW + 2 * ColorGap;
      ColorStart := (FPerfLimitSec.ClientWidth - ColorGroupW) div 2;

      fpscolor1ColorButton.Left := ColorStart;
      fpscolor2ColorButton.Left := ColorStart + ColW + ColorGap;
      fpscolor3ColorButton.Left := ColorStart + 2 * (ColW + ColorGap);

      fpscolor2SpinEdit.Left := fpscolor2ColorButton.Left + (ColW - SpinW) div 2;
      fpscolor3SpinEdit.Left := fpscolor3ColorButton.Left + (ColW - SpinW) div 2;

      GroupH := 81;
      MiddleStart := FFpsLimitHintLbl.Top + FFpsLimitHintLbl.Height + 6;
      MiddleEnd := FPerfLimitSec.Height - 70;
      GroupTop := MiddleStart + (MiddleEnd - MiddleStart - GroupH) div 2;

      if Assigned(FfpscolorToggle) then
        FfpscolorToggle.Top := GroupTop;
      fpscolor1ColorButton.Top := GroupTop + 21 + 8;
      fpscolor2ColorButton.Top := fpscolor1ColorButton.Top;
      fpscolor3ColorButton.Top := fpscolor1ColorButton.Top;

      fpscolor2SpinEdit.Top := fpscolor1ColorButton.Top + 18 + 8;
      fpscolor3SpinEdit.Top := fpscolor2SpinEdit.Top;

      ComboW := 110;
      BtnW := 100;
      MiddleGap := 24;
      TotalRowW := ComboW + MiddleGap + BtnW;
      RowStart := (FPerfLimitSec.ClientWidth - TotalRowW) div 2;

      methodLabel.Left := RowStart;
      methodLabel.Top := FPerfLimitSec.Height - 70;
      fpslimmetComboBox.Left := RowStart;
      fpslimmetComboBox.Top := FPerfLimitSec.Height - 48;

      limtoggleLabel.Left := RowStart + ComboW + MiddleGap;
      limtoggleLabel.Top := FPerfLimitSec.Height - 70;
      if Assigned(FLimitCaptureBtn) then
      begin
        FLimitCaptureBtn.Left := RowStart + ComboW + MiddleGap;
        FLimitCaptureBtn.Top := FPerfLimitSec.Height - 48;
        FLimitCaptureBtn.Width := BtnW;
      end;
    end;
  end;
  end;
end;

procedure TMangoHudUiHelper.SyncPerformanceToggles;
var
  i: Integer;
begin
  if Assigned(FPerfToggles) then
    for i := 0 to FPerfToggles.Count - 1 do
      TToggleSwitch(FPerfToggles[i]).SyncFromLinked;
  if Assigned(FframetimedetailedToggle) and Assigned(FForm.frametimegraphCheckBox) then
    FframetimedetailedToggle.Enabled := FForm.frametimegraphCheckBox.Checked;
end;

procedure TMangoHudUiHelper.FrametimegraphCheckBoxChange(Sender: TObject);
begin
  if Assigned(FForm.frametimedetailedCheckBox) then
  begin
    FForm.frametimedetailedCheckBox.Enabled := FForm.frametimegraphCheckBox.Checked;
    if not FForm.frametimegraphCheckBox.Checked then
      FForm.frametimedetailedCheckBox.Checked := False;
  end;
  if Assigned(FframetimedetailedToggle) then
  begin
    FframetimedetailedToggle.Enabled := FForm.frametimegraphCheckBox.Checked;
    FframetimedetailedToggle.SyncFromLinked;
  end;
end;


procedure TMangoHudUiHelper.UpdatePerfCardTheme;
const
  DARK_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B
  LIGHT_BG = $00FFFFFF;
var
  i, j: Integer;
  CardBg, TextColor: TColor;
  Card: TPanel;
  SS: WideString;
begin
  with FForm do
  begin
  if not Assigned(FPerfCards[0]) then Exit;

  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    TextColor := LightTextColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    TextColor := DarkTextColor;
  end;

  for i := 0 to 1 do
  begin
    Card := FPerfCards[i];
    if not Assigned(Card) then Continue;
    Card.Color := CardBg;
    Card.Invalidate;
    for j := 0 to Card.ControlCount - 1 do
    begin
      if Card.Controls[j] is TLabel then
      begin
        TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Color      := CardBg;
      end;
      if Card.Controls[j] is TGroupBox then
      begin
        TGroupBox(Card.Controls[j]).Color      := CardBg;
        TGroupBox(Card.Controls[j]).Font.Color := TextColor;
      end;
      if Card.Controls[j] is TPanel then
      begin
        TPanel(Card.Controls[j]).Color := CardBg;
        TPanel(Card.Controls[j]).Invalidate;
      end;
    end;
  end;

  // VSYNC row labels: update font color for theme change
  if Assigned(FVsyncRows[0]) or Assigned(FVsyncRows[1]) then
  begin
    for i := 0 to 1 do
    begin
      if not Assigned(FVsyncRows[i]) then Continue;
      for j := 0 to FVsyncRows[i].ControlCount - 1 do
        if FVsyncRows[i].Controls[j] is TLabel then
          TLabel(FVsyncRows[i].Controls[j]).Font.Color := TextColor;
    end;
  end;

  // FPS Limit edit: update colors for theme
  if Assigned(FFpsLimitEdit) then
  begin
    FFpsLimitEdit.Font.Color := TextColor;
    FFpsLimitEdit.Color := IfThen(CurrentTheme = tmLight, clWhite, RGBToColor(38, 46, 72));
    if CurrentTheme = tmLight then
      SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: none; }'
    else
      SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px; }' +
            'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
            'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
    QWidget_setStyleSheet(TQtWidget(FFpsLimitEdit.Handle).Widget, @SS);
  end;

  // SpinEdits: update background, text color, borders, and buttons
  if Assigned(fpscolor2SpinEdit) then
  begin
    fpscolor2SpinEdit.Font.Color := TextColor;
    fpscolor2SpinEdit.Color := IfThen(CurrentTheme = tmLight, $00F5F5F5, RGBToColor(38, 46, 72));
    SS := GetSpinBoxStyleSheet(CurrentTheme = tmDark);
    QWidget_setStyleSheet(TQtWidget(fpscolor2SpinEdit.Handle).Widget, @SS);
  end;

  if Assigned(fpscolor3SpinEdit) then
  begin
    fpscolor3SpinEdit.Font.Color := TextColor;
    fpscolor3SpinEdit.Color := IfThen(CurrentTheme = tmLight, $00F5F5F5, RGBToColor(38, 46, 72));
    SS := GetSpinBoxStyleSheet(CurrentTheme = tmDark);
    QWidget_setStyleSheet(TQtWidget(fpscolor3SpinEdit.Handle).Widget, @SS);
  end;
  end;
end;


procedure TMangoHudUiHelper.InitMetricsTab;
// Fully code-driven layout: every control is reparented directly to its card
// TPanel (no TGroupBox involved).  The card's PerfCardPaint reliably fills
// CARD_BG everywhere, solving the Qt6 GroupBox background rendering issue.
const
  CARD_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B blue-gray
  OUTER_BG = $00281A16;  // navy bg
  WHITE    = clWhite;
  SECT_GPU = $66AAFF;
  SECT_CPU = $FFAA55;
  HDR      = 34;   // accent bar (3px) + title label area

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Lbl: TLabel;
  begin
    with FForm do
    begin
      Card := TPanel.Create(FForm);
      Card.Parent  := FMtBgPanel;
      Card.Caption := '';
      Card.OnPaint := @SubCardPaint;
      Lbl := TLabel.Create(Card);
      Lbl.Parent   := Card;
      StyleMainCard(Card, Lbl, ATitle);
    end;
  end;

  // Reparent a control directly to a card, clearing all anchor dependencies and
  // placing it at (ALeft, ATop) relative to the card.  All controls land directly
  // on the TPanel — no GroupBox in the hierarchy.
  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors  := [akLeft, akTop];
    C.Parent   := Card;
    C.Left     := ALeft;
    C.Top      := ATop;
  end;

  function PlaceToggle(ACheckBox: TCheckBox; Card: TPanel; ALeft, ATop: Integer): TToggleSwitch;
  begin
    Result := TToggleSwitch.Create(FForm);
    Result.Parent := Card;
    Result.LinkToCheckBox(ACheckBox);
    Result.Left   := ALeft;
    Result.Top    := ATop;
    Result.Height := 20;
    Result.Width  := Result.GetOptimalWidth;
    FMetricsToggles.Add(Result);
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    C.ParentColor := True;
    C.Font.Color  := WHITE;
    C.Font.Size   := 9;
  end;

  procedure DarkSectLbl(L: TLabel; AColor: TColor);
  begin
    L.Font.Color  := AColor;
    L.Font.Size   := 9;
    L.Font.Style  := [fsBold];
    L.Transparent := True;
  end;

begin
  with FForm do
  begin
  // ── Scroll container fills the tab ──────────────────────────────────────
  FMtScrollBox := TScrollBox.Create(FForm);
  FMtScrollBox.Parent      := metricsTabSheet;
  FMtScrollBox.Align       := alClient;
  FMtScrollBox.AutoScroll  := True;
  FMtScrollBox.BorderStyle := bsNone;
  FMtScrollBox.HorzScrollBar.Visible := False;
  FMtScrollBox.HorzScrollBar.Range   := 0;
  FMtScrollBox.Color       := RGBToColor(22, 26, 40);
  FMtScrollBox.ParentColor := False;

  FMtBgPanel := TPanel.Create(FForm);
  FMtBgPanel.Parent     := FMtScrollBox;
  FMtBgPanel.BevelOuter := bvNone;
  FMtBgPanel.Color      := RGBToColor(22, 26, 40);
  FMtBgPanel.OnPaint    := @FForm.PresetsWrapperPaint;
  FMtBgPanel.Caption    := '';
  FMtBgPanel.Left       := 0;
  FMtBgPanel.Top        := 0;
  FMtBgPanel.Width      := FMtScrollBox.ClientWidth;
  FMtBgPanel.Height     := 600;

  // Hide the original GroupBoxes — they are no longer needed as containers.
  gpuGroupBox.Visible := False;
  cpuGroupBox.Visible := False;

  // ── Card 0: GPU Metrics ─────────────────────────────────────────────────
  // All Y values = LFM position + HDR (34) to offset below the card header.
  MakeCard(FMtGpuCard, 'GPU Metrics');

  // Name edit (centered in LFM at Left=285, Top=3)
  Place(gpunameEdit, FMtGpuCard, 285, 3 + HDR);
  gpunameEdit.Color      := CARD_BG;
  gpunameEdit.Font.Color := WHITE;
  gpunameEdit.Font.Size  := 9;

  // Main color bar (Left=281, Top=35)
  Place(gpuColorButton, FMtGpuCard, 281, 35 + HDR);
  gpuColorButton.Color := CARD_BG;

  // Section: Main metrics (label Top=56, controls Top=77/99)
  Place(mainmetricLabel,     FMtGpuCard, 11,  56 + HDR);
  FgpuavgloadToggle   := PlaceToggle(gpuavgloadCheckBox, FMtGpuCard, 11, 77 + HDR);
  FgpuavgloadToggle.HasGraphButton := True;
  FgpuavgloadToggle.OnGraphClick   := @MetricGraphClick;
  FgpuloadcolorToggle := PlaceToggle(gpuloadcolorCheckBox, FMtGpuCard, 120, 77 + HDR);
  Place(gpuload1ColorButton, FMtGpuCard, 120, 99 + HDR);
  Place(gpuload2ColorButton, FMtGpuCard, 150, 99 + HDR);
  Place(gpuload3ColorButton, FMtGpuCard, 181, 99 + HDR);
  FvramusageToggle    := PlaceToggle(vramusageCheckBox, FMtGpuCard, 266, 77 + HDR);
  FvramusageToggle.HasGraphButton := True;
  FvramusageToggle.OnGraphClick   := @MetricGraphClick;
  Place(vramColorButton,     FMtGpuCard, 264, 99 + HDR);
  FgpufreqToggle      := PlaceToggle(gpufreqCheckBox, FMtGpuCard, 381, 77 + HDR);
  FgpufreqToggle.HasGraphButton := True;
  FgpufreqToggle.OnGraphClick   := @MetricGraphClick;
  FgpumemfreqToggle   := PlaceToggle(gpumemfreqCheckBox, FMtGpuCard, 519, 77 + HDR);
  FgpumemfreqToggle.HasGraphButton := True;
  FgpumemfreqToggle.OnGraphClick   := @MetricGraphClick;
  DarkSectLbl(mainmetricLabel, SECT_GPU);
  gpuload1ColorButton.Color := CARD_BG;
  gpuload2ColorButton.Color := CARD_BG;
  gpuload3ColorButton.Color := CARD_BG;
  vramColorButton.Color := CARD_BG;

  // Section: Temperature (label Top=113, controls Top=134)
  Place(gputempLabel,        FMtGpuCard, 11,  113 + HDR);
  FgputempToggle     := PlaceToggle(gputempCheckBox, FMtGpuCard, 11, 134 + HDR);
  FgputempToggle.HasGraphButton := True;
  FgputempToggle.OnGraphClick   := @MetricGraphClick;
  FgpumemtempToggle  := PlaceToggle(gpumemtempCheckBox, FMtGpuCard, 120, 134 + HDR);
  FgpujunctempToggle := PlaceToggle(gpujunctempCheckBox, FMtGpuCard, 266, 134 + HDR);
  FgpufanToggle      := PlaceToggle(gpufanCheckBox, FMtGpuCard, 381, 134 + HDR);
  DarkSectLbl(gputempLabel, SECT_GPU);

  // Section: Power (label Top=170, controls Top=191/213)
  Place(gpupowerLabel,           FMtGpuCard, 11,  170 + HDR);
  FgpupowerToggle           := PlaceToggle(gpupowerCheckBox, FMtGpuCard, 11, 191 + HDR);
  FgpuvoltageToggle         := PlaceToggle(gpuvoltageCheckBox, FMtGpuCard, 120, 191 + HDR);
  FgputhrottlingToggle      := PlaceToggle(gputhrottlingCheckBox, FMtGpuCard, 266, 191 + HDR);
  FgputhrottlinggraphToggle := PlaceToggle(gputhrottlinggraphCheckBox, FMtGpuCard, 381, 191 + HDR);
  FgpuefficiencyToggle      := PlaceToggle(gpuefficiencyCheckBox, FMtGpuCard, 519, 191 + HDR);
  FgpupowerlimitToggle      := PlaceToggle(gpupowerlimitCheckBox, FMtGpuCard, 611, 191 + HDR);
  Place(gpuframesjouleBitBtn,    FMtGpuCard, 516, 213 + HDR);
  DarkSectLbl(gpupowerLabel, SECT_GPU);
  gpuframesjouleBitBtn.Font.Color := WHITE;

  // Section: Information (label Top=227, controls Top=248)
  Place(gpuinfoLabel,      FMtGpuCard, 11,  227 + HDR);
  FgpumodelToggle     := PlaceToggle(gpumodelCheckBox, FMtGpuCard, 11, 248 + HDR);
  FvulkandriverToggle := PlaceToggle(vulkandriverCheckBox, FMtGpuCard, 120, 248 + HDR);
  FprocvramToggle     := PlaceToggle(procvramCheckBox, FMtGpuCard, 266, 248 + HDR);
  DarkSectLbl(gpuinfoLabel, SECT_GPU);

  // GPU image — right-anchored, positioned in ReflowMetricsTab
  gpuImage.AnchorSideLeft.Control   := nil;
  gpuImage.AnchorSideTop.Control    := nil;
  gpuImage.AnchorSideRight.Control  := nil;
  gpuImage.AnchorSideBottom.Control := nil;
  gpuImage.Anchors := [akLeft, akTop];
  gpuImage.Parent  := FMtGpuCard;
  gpuImage.Top     := 5 + HDR;

  // ── Card 1: CPU / Memory Metrics ────────────────────────────────────────
  MakeCard(FMtCpuCard, 'CPU / Memory Metrics');

  // Name edit (Left=285, Top=3)
  Place(cpunameEdit, FMtCpuCard, 285, 3 + HDR);
  cpunameEdit.Color      := CARD_BG;
  cpunameEdit.Font.Color := WHITE;
  cpunameEdit.Font.Size  := 9;

  // Main color bar (Left=281, Top=35)
  Place(cpuColorButton, FMtCpuCard, 281, 35 + HDR);
  cpuColorButton.Color := CARD_BG;

  // Section: Main metrics (label Top=45, controls Top=66/88)
  Place(cpumainmetricsLabel, FMtCpuCard, 11,  45 + HDR);
  FcpuavgloadToggle   := PlaceToggle(cpuavgloadCheckBox, FMtCpuCard, 11, 66 + HDR);
  FcpuavgloadToggle.HasGraphButton := True;
  FcpuavgloadToggle.OnGraphClick   := @MetricGraphClick;
  FcpuloadcolorToggle := PlaceToggle(cpuloadcolorCheckBox, FMtCpuCard, 120, 66 + HDR);
  Place(cpuload1ColorButton, FMtCpuCard, 120, 88 + HDR);
  Place(cpuload2ColorButton, FMtCpuCard, 150, 88 + HDR);
  Place(cpuload3ColorButton, FMtCpuCard, 181, 88 + HDR);
  FcpuloadcoreToggle  := PlaceToggle(cpuloadcoreCheckBox, FMtCpuCard, 266, 66 + HDR);
  Place(coreloadtypeBitBtn,  FMtCpuCard, 264, 88 + HDR);
  FcpufreqToggle      := PlaceToggle(cpufreqCheckBox, FMtCpuCard, 382, 66 + HDR);
  FcpucoretypeToggle  := PlaceToggle(cpucoretypeCheckBox, FMtCpuCard, 516, 66 + HDR);
  DarkSectLbl(cpumainmetricsLabel, SECT_CPU);
  cpuload1ColorButton.Color := CARD_BG;
  cpuload2ColorButton.Color := CARD_BG;
  cpuload3ColorButton.Color := CARD_BG;
  coreloadtypeBitBtn.Font.Color := WHITE;

  // Section: Temperature / Power (label Top=113, controls Top=134/156)
  Place(cputempLabel,      FMtCpuCard, 11,  113 + HDR);
  FcputempToggle      := PlaceToggle(cputempCheckBox, FMtCpuCard, 11, 134 + HDR);
  FcputempToggle.HasGraphButton := True;
  FcputempToggle.OnGraphClick   := @MetricGraphClick;
  FcpupowerToggle     := PlaceToggle(cpupowerCheckBox, FMtCpuCard, 120, 134 + HDR);
  Place(intelpowerfixBitBtn,FMtCpuCard,213, 135 + HDR);
  FcpuefficiencyToggle:= PlaceToggle(cpuefficiencyCheckBox, FMtCpuCard, 266, 134 + HDR);
  FramtempToggle      := PlaceToggle(ramtempCheckBox, FMtCpuCard, 382, 134 + HDR);
  Place(cpuframesjouleBitBtn,FMtCpuCard,263,156 + HDR);
  DarkSectLbl(cputempLabel, SECT_CPU);
  cpuframesjouleBitBtn.Font.Color := WHITE;
  intelpowerfixBitBtn.Font.Color  := WHITE;

  // Section: Memory / IO (label Top=181, controls Top=202/224)
  Place(memLabel,          FMtCpuCard, 11,  181 + HDR);
  FramusageToggle  := PlaceToggle(ramusageCheckBox, FMtCpuCard, 11, 202 + HDR);
  FramusageToggle.HasGraphButton := True;
  FramusageToggle.OnGraphClick   := @MetricGraphClick;
  FdiskioToggle    := PlaceToggle(diskioCheckBox, FMtCpuCard, 120, 202 + HDR);
  FprocmemToggle   := PlaceToggle(procmemCheckBox, FMtCpuCard, 266, 202 + HDR);
  FswapusageToggle := PlaceToggle(swapusageCheckBox, FMtCpuCard, 382, 202 + HDR);
  Place(ramColorButton,    FMtCpuCard, 5,   224 + HDR);
  Place(iordrwColorButton, FMtCpuCard, 114, 224 + HDR);
  DarkSectLbl(memLabel, SECT_CPU);
  ramColorButton.Color    := CARD_BG;
  iordrwColorButton.Color := CARD_BG;

  // CPU image — right-anchored, positioned in ReflowMetricsTab
  cpuImage.AnchorSideLeft.Control   := nil;
  cpuImage.AnchorSideTop.Control    := nil;
  cpuImage.AnchorSideRight.Control  := nil;
  cpuImage.AnchorSideBottom.Control := nil;
  cpuImage.Anchors := [akLeft, akTop];
  cpuImage.Parent  := FMtCpuCard;
  cpuImage.Top     := 5 + HDR;
  end;
end;


procedure TMangoHudUiHelper.ReflowMetricsTab(AContentW: Integer);
const
  MARGIN = 4;
  GAP    = 6;
  HDR    = 34;
  BASE_GPU_H = 315;
  BASE_CPU_H = 300;
var
  CW, TotalH, CardTop, AvailH, ActiveGpuH, ActiveCpuH: Integer;
  ColW, X0, X1, X2, X3, X4, X5: Integer;
  YOff1, YOff2, YOff3, CpuYOff1, CpuYOff2: Integer;
begin
  with FForm do
  begin
  if not Assigned(FMtScrollBox) then Exit;
  CW := FMtScrollBox.ClientWidth - 2 * MARGIN;
  if CW < 100 then Exit;

  FMtScrollBox.HorzScrollBar.Range := 0;

  AvailH := FMtScrollBox.ClientHeight - 3 * MARGIN - GAP;
  if AvailH > (BASE_GPU_H + BASE_CPU_H) then
  begin
    ActiveGpuH := Max(BASE_GPU_H, Round(AvailH * 0.52));
    ActiveCpuH := Max(BASE_CPU_H, AvailH - ActiveGpuH);
  end
  else
  begin
    ActiveGpuH := BASE_GPU_H;
    ActiveCpuH := BASE_CPU_H;
  end;

  TotalH := MARGIN + ActiveGpuH + GAP + ActiveCpuH + MARGIN;
  if FMtScrollBox.ClientHeight > TotalH then
    TotalH := FMtScrollBox.ClientHeight;
  FMtBgPanel.SetBounds(0, 0, FMtScrollBox.ClientWidth, TotalH);

  // GPU card
  FMtGpuCard.SetBounds(MARGIN, MARGIN, CW, ActiveGpuH);
  // GPU image: right-aligned, 5px from right edge
  gpuImage.Left := CW - gpuImage.Width - 5;
  // Center GPU name edit & color button
  gpunameEdit.Left    := (CW - gpunameEdit.Width) div 2;
  gpuColorButton.Left := (CW - gpuColorButton.Width) div 2;

  // CPU card
  CardTop := MARGIN + ActiveGpuH + GAP;
  FMtCpuCard.SetBounds(MARGIN, CardTop, CW, ActiveCpuH);
  // CPU image: right-aligned
  cpuImage.Left := CW - cpuImage.Width - 5;
  // Center CPU name edit & color button
  cpunameEdit.Left    := (CW - cpunameEdit.Width) div 2;
  cpuColorButton.Left := (CW - cpuColorButton.Width) div 2;

  // Compute dynamic column positions across CW
  ColW := Max(115, (CW - 50) div 6);
  X0 := 11;
  X1 := X0 + ColW;
  X2 := X0 + ColW * 2;
  X3 := X0 + ColW * 3;
  X4 := X0 + ColW * 4;
  X5 := X0 + ColW * 5;

  // Compute dynamic vertical section offsets
  YOff1 := Max(0, (ActiveGpuH - BASE_GPU_H) div 3);
  YOff2 := Max(0, ((ActiveGpuH - BASE_GPU_H) * 2) div 3);
  YOff3 := Max(0, ActiveGpuH - BASE_GPU_H);

  CpuYOff1 := Max(0, (ActiveCpuH - BASE_CPU_H) div 2);
  CpuYOff2 := Max(0, ActiveCpuH - BASE_CPU_H);

  // Reposition GPU Metrics controls dynamically across X0..X5 and Y offsets
  mainmetricLabel.Top            := 56 + HDR;
  if Assigned(FgpuavgloadToggle) then begin FgpuavgloadToggle.Left := X0; FgpuavgloadToggle.Top := 77 + HDR; end;
  if Assigned(FgpuloadcolorToggle) then begin FgpuloadcolorToggle.Left := X1; FgpuloadcolorToggle.Top := 77 + HDR; end;
  gpuload1ColorButton.Left       := X1;
  gpuload1ColorButton.Top        := 99 + HDR;
  gpuload2ColorButton.Left       := X1 + 30;
  gpuload2ColorButton.Top        := 99 + HDR;
  gpuload3ColorButton.Left       := X1 + 61;
  gpuload3ColorButton.Top        := 99 + HDR;
  if Assigned(FvramusageToggle) then begin FvramusageToggle.Left := X2; FvramusageToggle.Top := 77 + HDR; end;
  vramColorButton.Left           := X2 - 2;
  vramColorButton.Top            := 99 + HDR;
  if Assigned(FgpufreqToggle) then begin FgpufreqToggle.Left := X3; FgpufreqToggle.Top := 77 + HDR; end;
  if Assigned(FgpumemfreqToggle) then begin FgpumemfreqToggle.Left := X4; FgpumemfreqToggle.Top := 77 + HDR; end;

  gputempLabel.Top               := 113 + HDR + YOff1;
  if Assigned(FgputempToggle) then begin FgputempToggle.Left := X0; FgputempToggle.Top := 134 + HDR + YOff1; end;
  if Assigned(FgpumemtempToggle) then begin FgpumemtempToggle.Left := X1; FgpumemtempToggle.Top := 134 + HDR + YOff1; end;
  if Assigned(FgpujunctempToggle) then begin FgpujunctempToggle.Left := X2; FgpujunctempToggle.Top := 134 + HDR + YOff1; end;
  if Assigned(FgpufanToggle) then begin FgpufanToggle.Left := X3; FgpufanToggle.Top := 134 + HDR + YOff1; end;

  gpupowerLabel.Top              := 170 + HDR + YOff2;
  if Assigned(FgpupowerToggle) then begin FgpupowerToggle.Left := X0; FgpupowerToggle.Top := 191 + HDR + YOff2; end;
  if Assigned(FgpuvoltageToggle) then begin FgpuvoltageToggle.Left := X1; FgpuvoltageToggle.Top := 191 + HDR + YOff2; end;
  if Assigned(FgputhrottlingToggle) then begin FgputhrottlingToggle.Left := X2; FgputhrottlingToggle.Top := 191 + HDR + YOff2; end;
  if Assigned(FgputhrottlinggraphToggle) then begin FgputhrottlinggraphToggle.Left := X3; FgputhrottlinggraphToggle.Top := 191 + HDR + YOff2; end;
  if Assigned(FgpuefficiencyToggle) then begin FgpuefficiencyToggle.Left := X4; FgpuefficiencyToggle.Top := 191 + HDR + YOff2; end;
  if Assigned(FgpupowerlimitToggle) then begin FgpupowerlimitToggle.Left := X5; FgpupowerlimitToggle.Top := 191 + HDR + YOff2; end;
  gpuframesjouleBitBtn.Left      := X4 - 3;
  gpuframesjouleBitBtn.Top       := 213 + HDR + YOff2;

  gpuinfoLabel.Top               := 227 + HDR + YOff3;
  if Assigned(FgpumodelToggle) then begin FgpumodelToggle.Left := X0; FgpumodelToggle.Top := 248 + HDR + YOff3; end;
  if Assigned(FvulkandriverToggle) then begin FvulkandriverToggle.Left := X1; FvulkandriverToggle.Top := 248 + HDR + YOff3; end;
  if Assigned(FprocvramToggle) then begin FprocvramToggle.Left := X2; FprocvramToggle.Top := 248 + HDR + YOff3; end;

  // Reposition CPU Metrics controls dynamically across X0..X5 and CpuYOffs
  cpumainmetricsLabel.Top        := 45 + HDR;
  if Assigned(FcpuavgloadToggle) then begin FcpuavgloadToggle.Left := X0; FcpuavgloadToggle.Top := 66 + HDR; end;
  if Assigned(FcpuloadcolorToggle) then begin FcpuloadcolorToggle.Left := X1; FcpuloadcolorToggle.Top := 66 + HDR; end;
  cpuload1ColorButton.Left       := X1;
  cpuload1ColorButton.Top        := 88 + HDR;
  cpuload2ColorButton.Left       := X1 + 30;
  cpuload2ColorButton.Top        := 88 + HDR;
  cpuload3ColorButton.Left       := X1 + 61;
  cpuload3ColorButton.Top        := 88 + HDR;
  if Assigned(FcpuloadcoreToggle) then begin FcpuloadcoreToggle.Left := X2; FcpuloadcoreToggle.Top := 66 + HDR; end;
  coreloadtypeBitBtn.Left        := X2 - 2;
  coreloadtypeBitBtn.Top         := 88 + HDR;
  if Assigned(FcpufreqToggle) then begin FcpufreqToggle.Left := X3; FcpufreqToggle.Top := 66 + HDR; end;
  if Assigned(FcpucoretypeToggle) then begin FcpucoretypeToggle.Left := X4; FcpucoretypeToggle.Top := 66 + HDR; end;

  cputempLabel.Top               := 113 + HDR + CpuYOff1;
  if Assigned(FcputempToggle) then begin FcputempToggle.Left := X0; FcputempToggle.Top := 134 + HDR + CpuYOff1; end;
  if Assigned(FcpupowerToggle) then begin FcpupowerToggle.Left := X1; FcpupowerToggle.Top := 134 + HDR + CpuYOff1; end;
  intelpowerfixBitBtn.Left       := X1 + 105;
  intelpowerfixBitBtn.Top        := 135 + HDR + CpuYOff1;
  if Assigned(FcpuefficiencyToggle) then begin FcpuefficiencyToggle.Left := X2; FcpuefficiencyToggle.Top := 134 + HDR + CpuYOff1; end;
  cpuframesjouleBitBtn.Left      := X2 - 3;
  cpuframesjouleBitBtn.Top       := 156 + HDR + CpuYOff1;
  if Assigned(FramtempToggle) then begin FramtempToggle.Left := X3; FramtempToggle.Top := 134 + HDR + CpuYOff1; end;

  memLabel.Top                   := 181 + HDR + CpuYOff2;
  if Assigned(FramusageToggle) then begin FramusageToggle.Left := X0; FramusageToggle.Top := 202 + HDR + CpuYOff2; end;
  ramColorButton.Left            := X0 - 6;
  ramColorButton.Top             := 224 + HDR + CpuYOff2;
  if Assigned(FdiskioToggle) then begin FdiskioToggle.Left := X1; FdiskioToggle.Top := 202 + HDR + CpuYOff2; end;
  iordrwColorButton.Left         := X1 - 6;
  iordrwColorButton.Top          := 224 + HDR + CpuYOff2;
  if Assigned(FprocmemToggle) then begin FprocmemToggle.Left := X2; FprocmemToggle.Top := 202 + HDR + CpuYOff2; end;
  if Assigned(FswapusageToggle) then begin FswapusageToggle.Left := X3; FswapusageToggle.Top := 202 + HDR + CpuYOff2; end;
  end;
end;

procedure TMangoHudUiHelper.SyncMetricsToggles;
var
  i: Integer;
begin
  if Assigned(FMetricsToggles) then
    for i := 0 to FMetricsToggles.Count - 1 do
      TToggleSwitch(FMetricsToggles[i]).SyncFromLinked;
end;

procedure TMangoHudUiHelper.MetricGraphClick(Sender: TObject);
begin
  SaveMangoHudConfig;
  if Assigned(FForm.FFloatingToast) then
    FForm.FFloatingToast.ShowToast('Settings saved');
end;

procedure TMangoHudUiHelper.InitExtrasTab;
// Fully code-driven layout matching the Metrics tab pattern.
const
  CARD_BG  = $002E1E1A;  // rgb(28, 33, 52) — Option B
  OUTER_BG = $00281A16;
  WHITE    = clWhite;
  HDR      = 34;

  procedure MakeCard(out Card: TPanel; const ATitle: string);
  var
    Lbl: TLabel;
  begin
    with FForm do
    begin
      Card := TPanel.Create(FForm);
      Card.Parent  := FExtBgPanel;
      Card.Caption := '';
      Card.OnPaint := @SubCardPaint;
      Lbl := TLabel.Create(Card);
      Lbl.Parent   := Card;
      StyleMainCard(Card, Lbl, ATitle);
    end;
  end;

  procedure Place(C: TControl; Card: TPanel; ALeft, ATop: Integer);
  begin
    C.AnchorSideLeft.Control   := nil;
    C.AnchorSideTop.Control    := nil;
    C.AnchorSideRight.Control  := nil;
    C.AnchorSideBottom.Control := nil;
    C.Anchors := [akLeft, akTop];
    C.Parent  := Card;
    C.Left    := ALeft;
    C.Top     := ATop;
  end;

  function PlaceExtToggle(ACheckBox: TCheckBox; Card: TPanel; ALeft, ATop: Integer): TToggleSwitch;
  begin
    Result := TToggleSwitch.Create(FForm);
    Result.Parent := Card;
    Result.LinkToCheckBox(ACheckBox);
    Result.Left   := ALeft;
    Result.Top    := ATop;
    Result.Height := 20;
    Result.Width  := Result.GetOptimalWidth;
    FExtrasToggles.Add(Result);
  end;

  procedure DarkCheck(C: TCheckBox);
  begin
    C.ParentColor := True;
    C.Font.Color  := WHITE;
    C.Font.Size   := 9;
  end;

  procedure DarkLabel(L: TLabel);
  begin
    if L = nil then Exit;
    StyleLabel(L, lrSectionTitle);
  end;

begin
  with FForm do
  begin
  FExtScrollBox := TScrollBox.Create(FForm);
  FExtScrollBox.Parent      := extrasTabSheet;
  FExtScrollBox.Align       := alClient;
  FExtScrollBox.AutoScroll  := True;
  FExtScrollBox.BorderStyle := bsNone;
  FExtScrollBox.Color       := RGBToColor(22, 26, 40);

  FExtBgPanel := TPanel.Create(FForm);
  FExtBgPanel.Parent      := FExtScrollBox;
  FExtBgPanel.BevelOuter  := bvNone;
  FExtBgPanel.BorderStyle := bsNone;
  FExtBgPanel.Color       := RGBToColor(22, 26, 40);
  FExtBgPanel.OnPaint     := @FForm.PresetsWrapperPaint;
  FExtBgPanel.Caption     := '';

  // ── Card 1: System info ─────────────────────────────────────────────────
  MakeCard(FExtSysCard, 'System info');

  Place(systemLabel,           FExtSysCard, 11,  11 + HDR);  DarkLabel(systemLabel);
  FdistroinfoToggle    := PlaceExtToggle(distroinfoCheckBox,    FExtSysCard, 11,  32 + HDR);
  FrefreshrateToggle   := PlaceExtToggle(refreshrateCheckBox,   FExtSysCard, 128, 32 + HDR);
  FresolutionToggle    := PlaceExtToggle(resolutionCheckBox,    FExtSysCard, 254, 32 + HDR);
  FdisplayserverToggle := PlaceExtToggle(displayserverCheckBox, FExtSysCard, 372, 32 + HDR);
  FtimeToggle          := PlaceExtToggle(timeCheckBox,          FExtSysCard, 513, 32 + HDR);
  FarchToggle          := PlaceExtToggle(archCheckBox,          FExtSysCard, 597, 32 + HDR);

  Place(wineLabel,             FExtSysCard, 11,  68 + HDR);  DarkLabel(wineLabel);
  FwineToggle          := PlaceExtToggle(wineCheckBox,          FExtSysCard, 11,  89 + HDR);
  FengineversionToggle := PlaceExtToggle(engineversionCheckBox, FExtSysCard, 128, 89 + HDR);
  FengineshortToggle   := PlaceExtToggle(engineshortCheckBox,   FExtSysCard, 254, 89 + HDR);
  FwinesyncToggle      := PlaceExtToggle(winesyncCheckBox,      FExtSysCard, 372, 89 + HDR);
  FdxapiToggle         := PlaceExtToggle(dxapiCheckBox,         FExtSysCard, 513, 89 + HDR);
  FfexstatsToggle      := PlaceExtToggle(fexstatsCheckBox,      FExtSysCard, 597, 89 + HDR);
  Place(wineColorButton,       FExtSysCard, 7,   111 + HDR);
  Place(engineColorButton,     FExtSysCard, 122, 111 + HDR);

  Place(optionsLabel,           FExtSysCard, 11,  131 + HDR); DarkLabel(optionsLabel);
  FhudversionToggle    := PlaceExtToggle(hudversionCheckBox,     FExtSysCard, 11,  152 + HDR);
  FgamemodestatusToggle:= PlaceExtToggle(gamemodestatusCheckBox, FExtSysCard, 128, 152 + HDR);
  FvkbasaltstatusToggle:= PlaceExtToggle(vkbasaltstatusCheckBox, FExtSysCard, 254, 152 + HDR);
  FfcatToggle          := PlaceExtToggle(fcatCheckBox,           FExtSysCard, 372, 152 + HDR);
  FfsrToggle           := PlaceExtToggle(fsrCheckBox,            FExtSysCard, 513, 152 + HDR);
  FhdrToggle           := PlaceExtToggle(hdrCheckBox,            FExtSysCard, 597, 152 + HDR);

  Place(batteryLabel,        FExtSysCard, 8,   190 + HDR); DarkLabel(batteryLabel);
  FbatteryToggle     := PlaceExtToggle(batteryCheckBox,     FExtSysCard, 11,  211 + HDR);
  FbatterywattToggle := PlaceExtToggle(batterywattCheckBox, FExtSysCard, 128, 211 + HDR);
  FbatterytimeToggle := PlaceExtToggle(batterytimeCheckBox, FExtSysCard, 254, 211 + HDR);
  FdeviceToggle      := PlaceExtToggle(deviceCheckBox,      FExtSysCard, 372, 211 + HDR);
  Place(batteryColorButton,  FExtSysCard, 6,   233 + HDR);

  Place(othersLabel,         FExtSysCard, 11,  262 + HDR); DarkLabel(othersLabel);
  FmediaToggle       := PlaceExtToggle(mediaCheckBox,       FExtSysCard, 11,  283 + HDR);
  FnetworkToggle     := PlaceExtToggle(networkCheckBox,     FExtSysCard, 128, 283 + HDR);
  FfahrenheitToggle  := PlaceExtToggle(fahrenheitCheckBox,  FExtSysCard, 254, 283 + HDR);
  Place(customcommandEdit,   FExtSysCard, 11,  315 + HDR); // keeps black/lime colors
  customcommandEdit.Font.Name := 'DejaVu Sans Mono';
  Place(mediaColorButton,    FExtSysCard, 6,   305 + HDR);
  Place(networkComboBox,     FExtSysCard, 128, 305 + HDR);
  networkComboBox.Color      := OUTER_BG;
  networkComboBox.Font.Color := WHITE;

  // Icon in card header — positioned in ReflowExtrasTab
  Place(sysinfoImage, FExtSysCard, 4, 5);
  systemGroupBox.Visible := False;

  // ── Card 2: Logging ─────────────────────────────────────────────────────
  MakeCard(FExtLogCard, 'Logging');

  Place(logdurationLabel,  FExtLogCard, 11,  11 + HDR);  DarkLabel(logdurationLabel);
  Place(logdelayLabel,     FExtLogCard, 105, 11 + HDR);  DarkLabel(logdelayLabel);
  Place(logintervalLabel,  FExtLogCard, 206, 11 + HDR);  DarkLabel(logintervalLabel);
  Place(durationTrackBar,  FExtLogCard, 26,  40 + HDR);
  Place(delayTrackBar,     FExtLogCard, 123, 40 + HDR);
  Place(intervalTrackBar,  FExtLogCard, 218, 40 + HDR);
  Place(durationvalueLabel,FExtLogCard, 54,  96 + HDR);
  Place(delayvalueLabel,   FExtLogCard, 151, 96 + HDR);
  Place(intervalvalueLabel,FExtLogCard, 246, 96 + HDR);

  durationTrackBar.TickStyle := tsNone;
  delayTrackBar.TickStyle := tsNone;
  intervalTrackBar.TickStyle := tsNone;
  durationvalueLabel.Font.Color := CLR_TEXT_ACCENT; durationvalueLabel.Font.Style := [fsBold]; durationvalueLabel.Transparent := True;
  delayvalueLabel.Font.Color := CLR_TEXT_ACCENT; delayvalueLabel.Font.Style := [fsBold]; delayvalueLabel.Transparent := True;
  intervalvalueLabel.Font.Color := CLR_TEXT_ACCENT; intervalvalueLabel.Font.Style := [fsBold]; intervalvalueLabel.Transparent := True;

  // Top row: Log folder
  Place(logfolderLabel,  FExtLogCard, 356, 40 + HDR); DarkLabel(logfolderLabel);
  Place(logfolderEdit,   FExtLogCard, 356, 61 + HDR);
  logfolderEdit.Color      := OUTER_BG;
  logfolderEdit.Font.Color := WHITE;
  logfolderEdit.Font.Name  := 'DejaVu Sans Mono';
  Place(logfolderBitBtn, FExtLogCard, 783, 61 + HDR);

  // Bottom row: Logging toggle
  Place(logtoggleLabel, FExtLogCard, 356, 106 + HDR);
  logtoggleLabel.Caption     := 'Logging toggle';
  logtoggleLabel.Font.Color  := WHITE;
  logtoggleLabel.Transparent := True;

  Place(logtoggleComboBox, FExtLogCard, 356, 127 + HDR);
  logtoggleComboBox.Visible := False;

  FLoggingCaptureBtn := TBitBtn.Create(FExtLogCard);
  FLoggingCaptureBtn.Parent  := FExtLogCard;
  FLoggingCaptureBtn.Tag     := 3;
  FLoggingCaptureBtn.SetBounds(356, 127 + HDR, 140, 28);
  FLoggingCaptureBtn.OnClick := @FForm.CaptureBtnClick;
  FLoggingCaptureBtn.Cursor  := crHandPoint;
  if Trim(logtoggleComboBox.Text) <> '' then
    FLoggingCaptureBtn.Caption := '⌨ ' + logtoggleComboBox.Text
  else
    FLoggingCaptureBtn.Caption := '⌨ Capture';

  Place(autouploadCheckBox, FExtLogCard, 530, 67 + HDR); DarkCheck(autouploadCheckBox);
  autouploadCheckBox.Visible := False;
  Place(versioningCheckBox, FExtLogCard, 665, 67 + HDR); DarkCheck(versioningCheckBox);
  versioningCheckBox.Visible := False;

  Place(logtoggleImage, FExtLogCard, 325, 63 + HDR);
  logtoggleImage.Visible := False;
  // Log icon in card header — right-anchored
  // Icon in card header — positioned in ReflowExtrasTab
  Place(Image2, FExtLogCard, 4, 5);

  loggingGroupBox.Visible := False;
  end;
end;





procedure TMangoHudUiHelper.ReflowExtrasTab(AContentW: Integer);
const
  MARGIN = 4;
  GAP    = 6;
  HDR    = 34;
  BASE_SYS_H = 385;
  BASE_LOG_H = 195;
var
  CW, TotalH, AvailH, ActiveSysH, ActiveLogH: Integer;
  ColW, X0, X1, X2, X3, X4, X5: Integer;
  SysYOff1, SysYOff2, SysYOff3, SysYOff4, LogYOff: Integer;
begin
  with FForm do
  begin
  if not Assigned(FExtScrollBox) then Exit;
  CW := AContentW - 2 * MARGIN;
  if CW < 100 then Exit;

  FExtScrollBox.HorzScrollBar.Range := 0;

  AvailH := FExtScrollBox.ClientHeight - 3 * MARGIN - GAP;
  if AvailH > (BASE_SYS_H + BASE_LOG_H) then
  begin
    ActiveSysH := Max(BASE_SYS_H, Round(AvailH * 0.65));
    ActiveLogH := Max(BASE_LOG_H, AvailH - ActiveSysH);
  end
  else
  begin
    ActiveSysH := BASE_SYS_H;
    ActiveLogH := BASE_LOG_H;
  end;

  TotalH := MARGIN + ActiveSysH + GAP + ActiveLogH + MARGIN;
  if FExtScrollBox.ClientHeight > TotalH then
    TotalH := FExtScrollBox.ClientHeight;
  FExtBgPanel.SetBounds(0, 0, AContentW, TotalH);

  FExtSysCard.SetBounds(MARGIN, MARGIN, CW, ActiveSysH);
  sysinfoImage.Left := CW - sysinfoImage.Width - 4;
  sysinfoImage.Top  := 5;

  FExtLogCard.SetBounds(MARGIN, MARGIN + ActiveSysH + GAP, CW, ActiveLogH);
  Image2.Left := CW - Image2.Width - 4;
  Image2.Top  := 5;

  // Compute dynamic column positions across CW
  ColW := Max(115, (CW - 50) div 6);
  X0 := 11;
  X1 := X0 + ColW;
  X2 := X0 + ColW * 2;
  X3 := X0 + ColW * 3;
  X4 := X0 + ColW * 4;
  X5 := X0 + ColW * 5;

  // Compute dynamic vertical section offsets
  SysYOff1 := Max(0, (ActiveSysH - BASE_SYS_H) div 4);
  SysYOff2 := Max(0, ((ActiveSysH - BASE_SYS_H) * 2) div 4);
  SysYOff3 := Max(0, ((ActiveSysH - BASE_SYS_H) * 3) div 4);
  SysYOff4 := Max(0, ActiveSysH - BASE_SYS_H);
  LogYOff := Max(0, ActiveLogH - BASE_LOG_H);

  // Reposition System Info controls
  systemLabel.Top            := 11 + HDR;
  if Assigned(FdistroinfoToggle) then begin FdistroinfoToggle.Left := X0; FdistroinfoToggle.Top := 32 + HDR; end;
  if Assigned(FrefreshrateToggle) then begin FrefreshrateToggle.Left := X1; FrefreshrateToggle.Top := 32 + HDR; end;
  if Assigned(FresolutionToggle) then begin FresolutionToggle.Left := X2; FresolutionToggle.Top := 32 + HDR; end;
  if Assigned(FdisplayserverToggle) then begin FdisplayserverToggle.Left := X3; FdisplayserverToggle.Top := 32 + HDR; end;
  if Assigned(FtimeToggle) then begin FtimeToggle.Left := X4; FtimeToggle.Top := 32 + HDR; end;
  if Assigned(FarchToggle) then begin FarchToggle.Left := X5; FarchToggle.Top := 32 + HDR; end;

  wineLabel.Top              := 60 + HDR + SysYOff1;
  if Assigned(FwineToggle) then begin FwineToggle.Left := X0; FwineToggle.Top := 81 + HDR + SysYOff1; end;
  if Assigned(FengineversionToggle) then begin FengineversionToggle.Left := X1; FengineversionToggle.Top := 81 + HDR + SysYOff1; end;
  if Assigned(FengineshortToggle) then begin FengineshortToggle.Left := X2; FengineshortToggle.Top := 81 + HDR + SysYOff1; end;
  if Assigned(FwinesyncToggle) then begin FwinesyncToggle.Left := X3; FwinesyncToggle.Top := 81 + HDR + SysYOff1; end;
  if Assigned(FdxapiToggle) then begin FdxapiToggle.Left := X4; FdxapiToggle.Top := 81 + HDR + SysYOff1; end;
  if Assigned(FfexstatsToggle) then begin FfexstatsToggle.Left := X5; FfexstatsToggle.Top := 81 + HDR + SysYOff1; end;
  wineColorButton.Left       := X0 - 4;
  wineColorButton.Top        := 103 + HDR + SysYOff1;
  engineColorButton.Left     := X1 - 6;
  engineColorButton.Top      := 103 + HDR + SysYOff1;

  optionsLabel.Top           := 120 + HDR + SysYOff2;
  if Assigned(FhudversionToggle) then begin FhudversionToggle.Left := X0; FhudversionToggle.Top := 141 + HDR + SysYOff2; end;
  if Assigned(FgamemodestatusToggle) then begin FgamemodestatusToggle.Left := X1; FgamemodestatusToggle.Top := 141 + HDR + SysYOff2; end;
  if Assigned(FvkbasaltstatusToggle) then begin FvkbasaltstatusToggle.Left := X2; FvkbasaltstatusToggle.Top := 141 + HDR + SysYOff2; end;
  if Assigned(FfcatToggle) then begin FfcatToggle.Left := X3; FfcatToggle.Top := 141 + HDR + SysYOff2; end;
  if Assigned(FfsrToggle) then begin FfsrToggle.Left := X4; FfsrToggle.Top := 141 + HDR + SysYOff2; end;
  if Assigned(FhdrToggle) then begin FhdrToggle.Left := X5; FhdrToggle.Top := 141 + HDR + SysYOff2; end;

  batteryLabel.Top           := 170 + HDR + SysYOff3;
  if Assigned(FbatteryToggle) then begin FbatteryToggle.Left := X0; FbatteryToggle.Top := 191 + HDR + SysYOff3; end;
  if Assigned(FbatterywattToggle) then begin FbatterywattToggle.Left := X1; FbatterywattToggle.Top := 191 + HDR + SysYOff3; end;
  if Assigned(FbatterytimeToggle) then begin FbatterytimeToggle.Left := X2; FbatterytimeToggle.Top := 191 + HDR + SysYOff3; end;
  if Assigned(FdeviceToggle) then begin FdeviceToggle.Left := X3; FdeviceToggle.Top := 191 + HDR + SysYOff3; end;
  batteryColorButton.Left    := X0 - 5;
  batteryColorButton.Top     := 213 + HDR + SysYOff3;

  othersLabel.Top            := 238 + HDR + SysYOff4;
  if Assigned(FmediaToggle) then begin FmediaToggle.Left := X0; FmediaToggle.Top := 259 + HDR + SysYOff4; end;
  mediaColorButton.Left      := X0 - 5;
  mediaColorButton.Top       := 281 + HDR + SysYOff4;
  if Assigned(FnetworkToggle) then begin FnetworkToggle.Left := X1; FnetworkToggle.Top := 259 + HDR + SysYOff4; end;
  networkComboBox.Left       := X1;
  networkComboBox.Top        := 281 + HDR + SysYOff4;
  if Assigned(FfahrenheitToggle) then begin FfahrenheitToggle.Left := X2; FfahrenheitToggle.Top := 259 + HDR + SysYOff4; end;
  customcommandEdit.Left     := X0;
  customcommandEdit.Top      := 315 + HDR + SysYOff4;
  customcommandEdit.Width    := (X2 + IfThen(Assigned(FfahrenheitToggle), FfahrenheitToggle.Width, 120)) - X0;

  // Reposition Logging controls
  logdurationLabel.Left      := X0;
  logdurationLabel.Top       := 11 + HDR;
  durationTrackBar.Left      := X0 + 15;
  durationTrackBar.Top       := 40 + HDR;
  durationvalueLabel.Left    := X0 + 43;
  durationvalueLabel.Top     := 96 + HDR;

  logdelayLabel.Left         := X1;
  logdelayLabel.Top          := 11 + HDR;
  delayTrackBar.Left         := X1 + 15;
  delayTrackBar.Top          := 40 + HDR;
  delayvalueLabel.Left       := X1 + 43;
  delayvalueLabel.Top        := 96 + HDR;

  logintervalLabel.Left      := X2;
  logintervalLabel.Top       := 11 + HDR;
  intervalTrackBar.Left      := X2 + 15;
  intervalTrackBar.Top       := 40 + HDR;
  intervalvalueLabel.Left    := X2 + 43;
  intervalvalueLabel.Top     := 96 + HDR;

  // Top row: Log folder (spans across the card above the floating dock)
  logfolderLabel.Left        := X3;
  logfolderLabel.Top         := 40 + HDR;
  logfolderEdit.Left         := X3;
  logfolderEdit.Top          := 61 + HDR;
  logfolderEdit.Width        := Max(200, CW - X3 - 48);
  logfolderBitBtn.Left       := X3 + logfolderEdit.Width + 4;
  logfolderBitBtn.Top        := 61 + HDR;

  // Bottom row: Logging toggle key (compact button at X3, avoiding bottom-right floating dock)
  logtoggleLabel.Left        := X3;
  logtoggleLabel.Top         := 106 + HDR;
  logtoggleComboBox.Left     := X3;
  logtoggleComboBox.Top      := 127 + HDR;
  if Assigned(FLoggingCaptureBtn) then
  begin
    FLoggingCaptureBtn.Left  := X3;
    FLoggingCaptureBtn.Top   := 127 + HDR;
  end;

  autouploadCheckBox.Visible := False;
  versioningCheckBox.Visible := False;
  end;
end;

procedure TMangoHudUiHelper.SyncExtrasToggles;
var
  i: Integer;
begin
  if Assigned(FExtrasToggles) then
    for i := 0 to FExtrasToggles.Count - 1 do
      TToggleSwitch(FExtrasToggles[i]).SyncFromLinked;
end;

procedure TMangoHudUiHelper.SyncAllToggles;
begin
  SyncVisualToggles;
  SyncPerformanceToggles;
  SyncMetricsToggles;
  SyncExtrasToggles;
end;

// ============================================================================
// VKBASALT TAB — modern redesign
// ============================================================================


procedure TMangoHudUiHelper.UpdateExtrasCardTheme;
const
  DARK_BG   = $00362E2E;
  LIGHT_BG  = $00FFFFFF;
var
  CardBg, TextColor: TColor;
begin
  with FForm do
  begin
  if CurrentTheme = tmLight then
  begin
    CardBg    := LIGHT_BG;
    TextColor := LightTextColor;
  end
  else
  begin
    CardBg    := DARK_BG;
    TextColor := DarkTextColor;
  end;

  UpdateGenericCardTheme(FExtSysCard);
  UpdateGenericCardTheme(FExtLogCard);

  if Assigned(logtoggleLabel) then
    logtoggleLabel.Font.Color := TextColor;
    
  if Assigned(logfolderEdit) then
  begin
    logfolderEdit.Font.Color := TextColor;
    if CurrentTheme = tmLight then
      logfolderEdit.Color := LighterBackgroundColor
    else
      logfolderEdit.Color := RGBToColor(22, 26, 40); // OUTER_BG default
  end;

  if Assigned(networkComboBox) then
  begin
    networkComboBox.Font.Color := TextColor;
    if CurrentTheme = tmLight then
      networkComboBox.Color := LighterBackgroundColor
    else
      networkComboBox.Color := RGBToColor(22, 26, 40); // OUTER_BG default
  end;
  end;
end;

function HexToColor(const HexValue: string): TColor;
begin
  Result := RGBToColor(StrToInt('$' + Copy(HexValue, 1, 2)),
                       StrToInt('$' + Copy(HexValue, 3, 2)),
                       StrToInt('$' + Copy(HexValue, 5, 2)));
end;

procedure TMangoHudUiHelper.ResetMangoHudControls;
var
  i: Integer;
  ParentControl: TWinControl;
begin
  FForm.FLoadingConfig := True;
  try
    with FForm do
    begin
      FActiveLayoutCard := -1;
    FActiveColorCard  := -1;

    // 1. Reset all checkboxes inside MangoHud tabs to False
    for i := 0 to ComponentCount - 1 do
    begin
      if Components[i] is TCheckBox then
      begin
        ParentControl := (Components[i] as TCheckBox).Parent;
        while Assigned(ParentControl) do
        begin
          if (ParentControl = presetTabSheet) or
             (ParentControl = visualTabSheet) or
             (ParentControl = performanceTabSheet) or
             (ParentControl = metricsTabSheet) or
             (ParentControl = extrasTabSheet) then
          begin
            (Components[i] as TCheckBox).Checked := False;
            Break;
          end;
          ParentControl := ParentControl.Parent;
        end;
      end;
    end;

    if Assigned(frametimedetailedCheckBox) then
    begin
      frametimedetailedCheckBox.Checked := False;
      frametimedetailedCheckBox.Enabled := False;
    end;

    // Reset metric graph toggles
    if Assigned(FgpuavgloadToggle) then FgpuavgloadToggle.GraphActive := False;
    if Assigned(FvramusageToggle) then FvramusageToggle.GraphActive := False;
    if Assigned(FgpufreqToggle) then FgpufreqToggle.GraphActive := False;
    if Assigned(FgpumemfreqToggle) then FgpumemfreqToggle.GraphActive := False;
    if Assigned(FgputempToggle) then FgputempToggle.GraphActive := False;
    if Assigned(FcpuavgloadToggle) then FcpuavgloadToggle.GraphActive := False;
    if Assigned(FcputempToggle) then FcputempToggle.GraphActive := False;
    if Assigned(FramusageToggle) then FramusageToggle.GraphActive := False;

    // 2. Reset other specific MangoHud controls
    hudtitleEdit.Text := '';
    gpunameEdit.Text := '';
    cpunameEdit.Text := '';
    logfolderEdit.Text := GetGOverlayDataDir();
    if Assigned(FFpsLimitEdit) then
      FFpsLimitEdit.Text := '0';

    // ComboBoxes
    fontComboBox.ItemIndex := 0;
    hudonoffComboBox.ItemIndex := 0;
    fpslimmetComboBox.ItemIndex := 0;
    fpslimtoggleComboBox.Text := '';
    if Assigned(FLimitCaptureBtn) then
      FLimitCaptureBtn.Caption := '⌨ None';
    vsyncComboBox.ItemIndex := 4;
    glvsyncComboBox.ItemIndex := 4;
    logtoggleComboBox.ItemIndex := 0;
    networkComboBox.ItemIndex := 0;

    // RadioButtons
    verticalRadioButton.Checked := True;
    horizontalRadioButton.Checked := False;
    squareRadioButton.Checked := False;
    roundRadioButton.Checked := True;
    topleftRadioButton.Checked := True;
    topcenterRadioButton.Checked := False;
    toprightRadioButton.Checked := False;
    middleleftRadioButton.Checked := False;
    middlerightRadioButton.Checked := False;
    bottomleftRadioButton.Checked := False;
    bottomcenterRadioButton.Checked := False;
    bottomrightRadioButton.Checked := False;

    // Trackbars and their labels
    transpTrackBar.Position := 6;
    alphavalueLabel.Caption := '0.6';
    
    fontsizeTrackBar.Position := 24;
    fontsizevalueLabel.Caption := '24';
    
    afTrackBar.Position := 0;
    afvalueLabel.Caption := '0';
    
    mipmapTrackBar.Position := 0;
    mipmapvalueLabel.Caption := '0';
    
    durationTrackBar.Position := 0;
    durationvalueLabel.Caption := '0s';
    
    delayTrackBar.Position := 0;
    delayvalueLabel.Caption := '0s';
    
    intervalTrackBar.Position := 100;
    intervalvalueLabel.Caption := '100ms';

    columvalueLabel.Caption := '3';
    columShape.Visible := True;
    columShape1.Visible := True;
    columShape2.Visible := True;
    columShape3.Visible := False;
    columShape4.Visible := False;
    columShape5.Visible := False;

    // Reset default colors to stock / standard GOverlay colors
    hudbackgroundColorButton.ButtonColor := clBlack;
    fontColorButton.ButtonColor := clWhite;
    gpuColorButton.ButtonColor := clWhite;
    cpuColorButton.ButtonColor := clWhite;
    vramColorButton.ButtonColor := clWhite;
    ramColorButton.ButtonColor := clWhite;
    iordrwColorButton.ButtonColor := clWhite;
    wineColorButton.ButtonColor := clWhite;
    engineColorButton.ButtonColor := clWhite;
    batteryColorButton.ButtonColor := clWhite;
    mediaColorButton.ButtonColor := clWhite;
    frametimegraphColorButton.ButtonColor := clLime;

    fpscolor1ColorButton.ButtonColor := clRed;
    fpscolor2ColorButton.ButtonColor := clYellow;
    fpscolor3ColorButton.ButtonColor := clLime;
    fpscolor2spinedit.Value := 30;
    fpscolor3spinedit.Value := 60;

    gpuload1ColorButton.ButtonColor := clWhite;
    gpuload2ColorButton.ButtonColor := clWhite;
    gpuload3ColorButton.ButtonColor := clWhite;
    cpuload1ColorButton.ButtonColor := clWhite;
    cpuload2ColorButton.ButtonColor := clWhite;
    cpuload3ColorButton.ButtonColor := clWhite;

    // BitBtns
    frametimetypeBitBtn.ImageIndex := 8;
    frametimetypeBitBtn.Caption := 'Curve';
    coreloadtypeBitBtn.ImageIndex := 6;
    coreloadtypeBitBtn.Caption := 'Percent';
    gpuframesjouleBitBtn.Tag := 0;
    cpuframesjouleBitBtn.Tag := 0;
    gpuframesjouleBitBtn.Caption := 'Frames / Joule';
    cpuframesjouleBitBtn.Caption := 'Frames / Joule';
    fpsavgBitBtn.ImageIndex := 9;
    fpsavgBitBtn.Caption := '1% low';

    // RadioGroups
    filterRadioGroup.ItemIndex := 0;

    // SpinEdits
    offsetSpinedit.Value := 0;
    offsetxSpinEdit.Value := 0;
    offsetySpinEdit.Value := 0;

    SyncAllToggles;
    end;
  finally
    FForm.FLoadingConfig := False;
  end;
end;

procedure TMangoHudUiHelper.LoadMangoHudConfig;
var
  ConfigLines: TStringList;
  Line, TrimmedLine, Key, Value: string;
  i, ColonPos: Integer;
  IntValue: Integer;
begin
  FForm.FLoadingConfig := True;
  try
    ResetMangoHudControls;

    if not FileExists(MANGOHUDCFGFILE) then
      Exit;

    ConfigLines := TStringList.Create;
    try
      ConfigLines.LoadFromFile(MANGOHUDCFGFILE);

      for i := 0 to ConfigLines.Count - 1 do
      begin
        Line := ConfigLines[i];
        TrimmedLine := Trim(Line);

        // Ignore empty lines
        if TrimmedLine = '' then
          Continue;

        // Handle special commented line #offset=
        if (Length(TrimmedLine) > 8) and (Copy(TrimmedLine, 1, 8) = MANGO_COMMENT_OFFSET) then
        begin
          if TryStrToInt(Copy(TrimmedLine, 9, Length(TrimmedLine)), IntValue) then
          begin
            with FForm do
              offsetSpinedit.Value := IntValue;
          end;
          Continue;
        end;

        // Ignore other comments
        if TrimmedLine[1] = '#' then
          Continue;

        ColonPos := Pos('=', TrimmedLine);

        // Keys without value (boolean flags)
        if ColonPos = 0 then
        begin
          LoadMangoHudBoolFlag(TrimmedLine);
          Continue;
        end;

        // Keys with value
        Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
        Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

        // Remove quotes if present
        if (Length(Value) > 0) and (Value[1] = '"') then
          Value := StringReplace(Value, '"', '', [rfReplaceAll]);

        LoadMangoHudKeyValue(Key, Value);
      end;

    finally
      ConfigLines.Free;
    end;

    if Assigned(FForm.frametimedetailedCheckBox) then
    begin
      FForm.frametimedetailedCheckBox.Enabled := FForm.frametimegraphCheckBox.Checked;
      if not FForm.frametimegraphCheckBox.Checked then
        FForm.frametimedetailedCheckBox.Checked := False;
    end;

    // Sync all toggles, FPS chip visuals, and preset card selection
    SyncAllToggles;
    UpdatePerfCardTheme;
    UpdatePresetCardVisuals;
  finally
    FForm.FLoadingConfig := False;
  end;
end;

procedure TMangoHudUiHelper.LoadMangoHudBoolFlag(const ATrimmedLine: string);
begin
  with FForm do
  begin
    if SameText(ATrimmedLine, MANGO_FLAG_HORIZONTAL) then
      horizontalRadioButton.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_NO_DISPLAY) then
      hidehudCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_HUD_COMPACT) then
      hudcompactCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FPS) then
      fpsCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FRAME_TIMING) then
      frametimegraphCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FRAME_TIMING_DETAILED) then
    begin
      if Assigned(frametimedetailedCheckBox) then
        frametimedetailedCheckBox.Checked := True;
    end
    else if SameText(ATrimmedLine, MANGO_FLAG_SHOW_FPS_LIMIT) then
      showfpslimCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FRAME_COUNT) then
      framecountCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_HISTOGRAM) then
    begin
      frametimetypeBitBtn.ImageIndex := 7;
      frametimetypeBitBtn.Caption := 'Histogram';
    end
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_STATS) then
      gpuavgloadCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_LOAD_CHANGE) then
      gpuloadcolorCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_VRAM) then
      vramusageCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_CORE_CLOCK) then
      gpufreqCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_MEM_CLOCK) then
      gpumemfreqCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_TEMP) then
      gputempCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_MEM_TEMP) then
      gpumemtempCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_JUNCTION_TEMP) then
      gpujunctempCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_FAN) then
      gpufanCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_POWER) then
      gpupowerCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_POWER_LIMIT) then
      gpupowerlimitCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_EFFICIENCY) then
      gpuefficiencyCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FLIP_EFFICIENCY) then
    begin
      gpuframesjouleBitBtn.Tag := 1;
      cpuframesjouleBitBtn.Tag := 1;
      gpuframesjouleBitBtn.Caption := 'Joules / Frame';
      cpuframesjouleBitBtn.Caption := 'Joules / Frame';
    end
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_VOLTAGE) then
      gpuvoltageCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_THROTTLING) then
      gputhrottlingCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_THROTTLING_GRAPH) then
      gputhrottlinggraphCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GPU_NAME) then
      gpumodelCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_VULKAN_DRIVER) then
      vulkandriverCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_STATS) then
      cpuavgloadCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_LOAD_CHANGE) then
      cpuloadcolorCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CORE_LOAD) then
      cpuloadcoreCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CORE_BARS) then
    begin
      coreloadtypeBitBtn.ImageIndex := 7;
      coreloadtypeBitBtn.Caption := 'Graph';
    end
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_MHZ) then
      cpufreqCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_TEMP) then
      cputempCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_POWER) then
      cpupowerCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CPU_EFFICIENCY) then
      cpuefficiencyCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_CORE_TYPE) then
      cpucoretypeCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_RAM) then
      ramusageCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_IO_READ) then
      diskioCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_IO_WRITE) then
      diskioCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_PROCMEM) then
      procmemCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_PROC_VRAM) then
      procvramCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_SWAP) then
      swapusageCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_RAM_TEMP) then
      ramtempCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_ARCH) then
      archCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_RESOLUTION) then
      resolutionCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_WINE) then
      wineCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_ENGINE_VERSION) then
      engineversionCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_ENGINE_SHORT) then
      engineshortCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_GAMEMODE) then
      gamemodestatusCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_VKBASALT) then
      vkbasaltstatusCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FCAT) then
      fcatCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FEX_STATS) then
      fexstatsCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FSR) then
      fsrCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_HDR) then
      hdrCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_REFRESH_RATE) then
      refreshrateCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY) then
      batteryCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY_WATT) then
      batterywattCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_BATTERY_TIME) then
      batterytimeCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_MEDIA_PLAYER) then
      mediaCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_TEMP_FAHRENHEIT) then
      fahrenheitCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_WINESYNC) then
      winesyncCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_PRESENT_MODE) then
      vpsCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_LOG_VERSIONING) then
      versioningCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_UPLOAD_LOGS) then
      autouploadCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_FPS_COLOR_CHANGE) then
      fpscolorCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_BICUBIC) then
      filterRadioGroup.ItemIndex := 1
    else if SameText(ATrimmedLine, MANGO_FLAG_TRILINEAR) then
      filterRadioGroup.ItemIndex := 2
    else if SameText(ATrimmedLine, MANGO_FLAG_RETRO) then
      filterRadioGroup.ItemIndex := 3
    else if SameText(ATrimmedLine, MANGO_FLAG_DISPLAY_SERVER) then
      displayserverCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_TIME) then
      timeCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_TIME + '#') then
      timeCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_VERSION + '#') then
      hudversionCheckBox.Checked := True;
  end;
end;

procedure TMangoHudUiHelper.LoadMangoHudKeyValue(const AKey, AValue: string);
var
  IntValue: Integer;
  FloatValue: Double;
  j: Integer;
  ColorList: TStringList;
  GraphTokens: TStringList;
  Token: string;
begin
  with FForm do
  begin
    // ============= VISUAL TAB =============
    if SameText(AKey, MANGO_KEY_CUSTOM_TEXT) then
      hudtitleEdit.Text := AValue
    else if SameText(AKey, MANGO_KEY_BG_ALPHA) then
    begin
      if TryStrToFloat(AValue, FloatValue) then
      begin
        transpTrackBar.Position := Round(FloatValue * 10);
        alphavalueLabel.Caption := FormatFloat('#0.0', FloatValue);
      end;
    end
    else if SameText(AKey, MANGO_KEY_ROUND_CORNERS) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        if IntValue = 0 then
          squareRadioButton.Checked := True
        else
          roundRadioButton.Checked := True;
      end;
    end
    else if SameText(AKey, MANGO_KEY_BG_COLOR) then
      hudbackgroundColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_FONT_SIZE) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        fontsizeTrackBar.Position := IntValue;
        fontsizevalueLabel.Caption := IntToStr(IntValue);
      end;
    end
    else if SameText(AKey, MANGO_KEY_TEXT_COLOR) then
      fontColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_FONT_FILE) then
      fontComboBox.Text := ExtractFileName(AValue)
    else if SameText(AKey, MANGO_KEY_POSITION) then
    begin
      if SameText(AValue, MANGO_POS_TOP_LEFT) then
        topleftRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_TOP_CENTER) then
        topcenterRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_TOP_RIGHT) then
        toprightRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_MIDDLE_LEFT) then
        middleleftRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_MIDDLE_RIGHT) then
        middlerightRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_BOTTOM_LEFT) then
        bottomleftRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_BOTTOM_CENTER) then
        bottomcenterRadioButton.Checked := True
      else if SameText(AValue, MANGO_POS_BOTTOM_RIGHT) then
        bottomrightRadioButton.Checked := True;
    end
    else if SameText(AKey, MANGO_KEY_OFFSET_X) then
    begin
      if TryStrToInt(AValue, IntValue) then
        offsetxSpinEdit.Value := IntValue;
    end
    else if SameText(AKey, MANGO_KEY_OFFSET_Y) then
    begin
      if TryStrToInt(AValue, IntValue) then
        offsetySpinEdit.Value := IntValue;
    end
    else if SameText(AKey, MANGO_KEY_HORIZONTAL_STRETCH) then
      horizontalstrechCheckBox.Checked := True
    else if SameText(AKey, MANGO_KEY_TOGGLE_HUD) then
    begin
      hudonoffComboBox.Text := AValue;
      if Assigned(FVisualCaptureBtn) and (Trim(AValue) <> '') then
        FVisualCaptureBtn.Caption := '⌨ ' + AValue;
    end
    else if SameText(AKey, MANGO_KEY_TABLE_COLS) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        columvalueLabel.Caption := AValue;
        case IntValue of
          1: begin
            columShape.Visible := True; columShape1.Visible := False; columShape2.Visible := False;
            columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
          end;
          2: begin
            columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := False;
            columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
          end;
          3: begin
            columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
            columShape3.Visible := False; columShape4.Visible := False; columShape5.Visible := False;
          end;
          4: begin
            columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
            columShape3.Visible := True; columShape4.Visible := False; columShape5.Visible := False;
          end;
          5: begin
            columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
            columShape3.Visible := True; columShape4.Visible := True; columShape5.Visible := False;
          end;
          6: begin
            columShape.Visible := True; columShape1.Visible := True; columShape2.Visible := True;
            columShape3.Visible := True; columShape4.Visible := True; columShape5.Visible := True;
          end;
        end;
      end;
    end
    // ============= METRICS TAB =============
    else if SameText(AKey, MANGO_KEY_GPU_TEXT) then
      gpunameEdit.Text := AValue
    else if SameText(AKey, MANGO_KEY_GPU_COLOR) then
      gpuColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_CPU_TEXT) then
      cpunameEdit.Text := AValue
    else if SameText(AKey, MANGO_KEY_CPU_COLOR) then
      cpuColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_VRAM_COLOR) then
      vramColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_RAM_COLOR) then
      ramColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_IO_COLOR) then
      iordrwColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_FRAMETIME_COLOR) then
      frametimegraphColorButton.ButtonColor := HexToColor(AValue)
    // ============= PERFORMANCE TAB =============
    else if SameText(AKey, MANGO_KEY_FPS_LIMIT_METHOD) then
    begin
      if SameText(AValue, MANGO_FPS_LATE) then
        fpslimmetComboBox.ItemIndex := 0
      else if SameText(AValue, MANGO_FPS_EARLY) then
        fpslimmetComboBox.ItemIndex := 1;
    end
    else if SameText(AKey, MANGO_KEY_TOGGLE_FPS_LIMIT) then
    begin
      fpslimtoggleComboBox.Text := AValue;
      if Assigned(FLimitCaptureBtn) and (Trim(AValue) <> '') then
        FLimitCaptureBtn.Caption := '⌨ ' + AValue;
    end
    else if SameText(AKey, MANGO_KEY_FPS_LIMIT) then
    begin
      if Assigned(FFpsLimitEdit) then
        FFpsLimitEdit.Text := AValue;
    end
    else if SameText(AKey, MANGO_KEY_VSYNC) then
    begin
      if TryStrToInt(AValue, IntValue) then
        vsyncComboBox.ItemIndex := IntValue;
    end
    else if SameText(AKey, MANGO_KEY_GPU_LIST) then
    begin
      if SameText(AValue, '0,1') then
      begin
        // Tag holds the 1-based position of the combined-GPU entry, 0 when
        // the machine has a single GPU and the entry was never added.
        if pcidevComboBox.Tag > 0 then
          pcidevComboBox.ItemIndex := pcidevComboBox.Tag - 1;
      end
      else if TryStrToInt(AValue, IntValue) then
      begin
        if (IntValue >= 0) and (IntValue < pcidevComboBox.Items.Count) then
          pcidevComboBox.ItemIndex := IntValue;
      end;
    end
    else if SameText(AKey, MANGO_KEY_GPU_LOAD_COLOR) then
    begin
      ColorList := TStringList.Create;
      try
        ColorList.Delimiter := ',';
        ColorList.StrictDelimiter := True;
        ColorList.DelimitedText := AValue;
        if ColorList.Count >= 3 then
        begin
          gpuload1ColorButton.ButtonColor := HexToColor(ColorList[0]);
          gpuload2ColorButton.ButtonColor := HexToColor(ColorList[1]);
          gpuload3ColorButton.ButtonColor := HexToColor(ColorList[2]);
        end;
      finally
        ColorList.Free;
      end;
    end
    else if SameText(AKey, MANGO_KEY_CPU_LOAD_COLOR) then
    begin
      ColorList := TStringList.Create;
      try
        ColorList.Delimiter := ',';
        ColorList.StrictDelimiter := True;
        ColorList.DelimitedText := AValue;
        if ColorList.Count >= 3 then
        begin
          cpuload1ColorButton.ButtonColor := HexToColor(ColorList[0]);
          cpuload2ColorButton.ButtonColor := HexToColor(ColorList[1]);
          cpuload3ColorButton.ButtonColor := HexToColor(ColorList[2]);
        end;
      finally
        ColorList.Free;
      end;
    end
    else if SameText(AKey, MANGO_KEY_FPS_COLOR) then
    begin
      ColorList := TStringList.Create;
      try
        ColorList.Delimiter := ',';
        ColorList.StrictDelimiter := True;
        ColorList.DelimitedText := AValue;
        if ColorList.Count >= 3 then
        begin
          fpscolor1ColorButton.ButtonColor := HexToColor(ColorList[0]);
          fpscolor2ColorButton.ButtonColor := HexToColor(ColorList[1]);
          fpscolor3ColorButton.ButtonColor := HexToColor(ColorList[2]);
        end;
      finally
        ColorList.Free;
      end;
    end
    else if SameText(AKey, MANGO_KEY_FPS_VALUE) then
    begin
      ColorList := TStringList.Create;
      try
        ColorList.Delimiter := ',';
        ColorList.StrictDelimiter := True;
        ColorList.DelimitedText := AValue;
        if ColorList.Count >= 2 then
        begin
          fpscolor2SpinEdit.Value := StrToIntDef(ColorList[0], fpscolor2SpinEdit.Value);
          fpscolor3SpinEdit.Value := StrToIntDef(ColorList[1], fpscolor3SpinEdit.Value);
        end;
      finally
        ColorList.Free;
      end;
    end
    else if SameText(AKey, MANGO_KEY_GL_VSYNC) then
    begin
      if SameText(AValue, MANGO_GL_VSYNC_MINUS1) then
        glvsyncComboBox.ItemIndex := 0
      else if SameText(AValue, MANGO_GL_VSYNC_0) then
        glvsyncComboBox.ItemIndex := 1
      else if SameText(AValue, MANGO_GL_VSYNC_N) then
        glvsyncComboBox.ItemIndex := 2
      else if SameText(AValue, MANGO_GL_VSYNC_1) then
        glvsyncComboBox.ItemIndex := 3
      else if SameText(AValue, MANGO_GL_VSYNC_4) then
        glvsyncComboBox.ItemIndex := 4;
    end
    else if SameText(AKey, MANGO_KEY_AF) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        afTrackBar.Position := IntValue;
        afvalueLabel.Caption := IntToStr(IntValue);
      end;
    end
    else if SameText(AKey, MANGO_KEY_PICMIP) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        mipmapTrackBar.Position := IntValue;
        mipmapvalueLabel.Caption := IntToStr(IntValue);
      end;
    end
    // ============= EXTRAS TAB =============
    else if SameText(AKey, MANGO_KEY_WINE_COLOR) then
      wineColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_ENGINE_COLOR) then
      engineColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_BATTERY_COLOR) then
      batteryColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_MEDIA_COLOR) then
      mediaColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_DEVICE_BATTERY) then
      deviceCheckBox.Checked := True
    else if SameText(AKey, MANGO_KEY_OUTPUT_FOLDER) then
      logfolderEdit.Text := AValue
    else if SameText(AKey, MANGO_KEY_LOG_DURATION) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        durationTrackBar.Position := IntValue;
        durationvalueLabel.Caption := IntToStr(IntValue) + 's';
      end;
    end
    else if SameText(AKey, MANGO_KEY_AUTOSTART_LOG) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        delayTrackBar.Position := IntValue;
        delayvalueLabel.Caption := IntToStr(IntValue) + 's';
      end;
    end
    else if SameText(AKey, MANGO_KEY_LOG_INTERVAL) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        intervalTrackBar.Position := IntValue;
        intervalvalueLabel.Caption := IntToStr(IntValue) + 'ms';
      end;
    end
    else if SameText(AKey, MANGO_KEY_TOGGLE_LOGGING) then
    begin
      logtoggleComboBox.Text := AValue;
      if Assigned(FLoggingCaptureBtn) and (Trim(AValue) <> '') then
        FLoggingCaptureBtn.Caption := '⌨ ' + AValue;
    end
    else if SameText(AKey, MANGO_KEY_FPS_METRICS) then
    begin
      if Pos(MANGO_FPS_METRICS_1PCT, AValue) > 0 then
      begin
        fpsavgCheckBox.Checked := True;
        fpsavgBitBtn.ImageIndex := 9;
        fpsavgBitBtn.Caption := '1% low';
      end
      else if Pos(MANGO_FPS_METRICS_01PCT, AValue) > 0 then
      begin
        fpsavgCheckBox.Checked := True;
        fpsavgBitBtn.ImageIndex := 10;
        fpsavgBitBtn.Caption := '0.1% low';
      end;
    end
    else if SameText(AKey, MANGO_KEY_NETWORK) then
    begin
      networkCheckBox.Checked := True;
      if AValue <> '' then
      begin
        networkComboBox.ItemIndex := -1;
        for j := 0 to networkComboBox.Items.Count - 1 do
        begin
          if SameText(networkComboBox.Items[j], AValue) then
          begin
            networkComboBox.ItemIndex := j;
            Break;
          end;
        end;
        if networkComboBox.ItemIndex = -1 then
        begin
          networkComboBox.Items.Add(AValue);
          networkComboBox.ItemIndex := networkComboBox.Items.Count - 1;
        end;
      end;
    end
    else if SameText(AKey, MANGO_KEY_EXEC) then
    begin
      if (Pos('uname -r', AValue) > 0) or (Pos('goverlay/distro', AValue) > 0) then
        distroinfoCheckBox.Checked := True;
    end
    else if SameText(AKey, MANGO_KEY_GRAPHS) then
    begin
      GraphTokens := TStringList.Create;
      try
        GraphTokens.Delimiter := ',';
        GraphTokens.StrictDelimiter := True;
        GraphTokens.DelimitedText := AValue;
        for j := 0 to GraphTokens.Count - 1 do
        begin
          Token := Trim(GraphTokens[j]);
          if SameText(Token, 'gpu_load') and Assigned(FgpuavgloadToggle) then
            FgpuavgloadToggle.GraphActive := True
          else if SameText(Token, 'vram') and Assigned(FvramusageToggle) then
            FvramusageToggle.GraphActive := True
          else if SameText(Token, 'gpu_core_clock') and Assigned(FgpufreqToggle) then
            FgpufreqToggle.GraphActive := True
          else if SameText(Token, 'gpu_mem_clock') and Assigned(FgpumemfreqToggle) then
            FgpumemfreqToggle.GraphActive := True
          else if SameText(Token, 'gpu_temp') and Assigned(FgputempToggle) then
            FgputempToggle.GraphActive := True
          else if SameText(Token, 'cpu_load') and Assigned(FcpuavgloadToggle) then
            FcpuavgloadToggle.GraphActive := True
          else if SameText(Token, 'cpu_temp') and Assigned(FcputempToggle) then
            FcputempToggle.GraphActive := True
          else if SameText(Token, 'ram') and Assigned(FramusageToggle) then
            FramusageToggle.GraphActive := True;
        end;
      finally
        GraphTokens.Free;
      end;
    end;
  end;
end;

procedure TMangoHudUiHelper.SaveMangoHudConfig;
var
  Settings: TMangoHudSettings;
  ErrMsg: string;
  FPSNumbers: TStringList;
  TempFPS, MaxFPS, FPS: Integer;
  i: Integer;
begin
  with FForm do
  begin
    // Update FPS color thresholds first based on the text limits
    if Assigned(FFpsLimitEdit) then
    begin
      FPSNumbers := TStringList.Create;
      try
        FPSNumbers.Delimiter := ',';
        FPSNumbers.DelimitedText := Trim(FFpsLimitEdit.Text);
        MaxFPS := 0;
        for i := 0 to FPSNumbers.Count - 1 do
        begin
          FPS := StrToIntDef(FPSNumbers[i], 0);
          if FPS > MaxFPS then
            MaxFPS := FPS;
        end;
        if MaxFPS = 0 then
          MaxFPS := 60;
        fpscolor3SpinEdit.Value := MaxFPS;
        fpscolor2SpinEdit.Value := Round(MaxFPS / 2);
      finally
        FPSNumbers.Free;
      end;
    end;

    // Initialize TMangoHudSettings record
    FillChar(Settings, SizeOf(Settings), 0);
    Settings.MangoHudCfgFile := MANGOHUDCFGFILE;
    Settings.Version := GVERSION;
    Settings.Channel := GCHANNEL;
    Settings.ActiveGameName := FActiveGameName;

    // Visual Tab
    Settings.HudTitle := hudtitleEdit.Text;
    Settings.Horizontal := horizontalRadioButton.Checked;
    Settings.TranspPosition := transpTrackBar.Position;
    Settings.RoundCorners := roundRadioButton.Checked;
    Settings.HudBackgroundColor := hudbackgroundColorButton.ButtonColor;
    if fontComboBox.ItemIndex > 0 then
      Settings.FontText := fontComboBox.Text
    else
      Settings.FontText := '';
    Settings.FontSize := fontsizeTrackBar.Position;
    Settings.FontColor := fontColorButton.ButtonColor;

    if topleftRadioButton.Checked then
      Settings.Position := 'top-left'
    else if topcenterRadioButton.Checked then
      Settings.Position := 'top-center'
    else if toprightRadioButton.Checked then
      Settings.Position := 'top-right'
    else if middleleftRadioButton.Checked then
      Settings.Position := 'middle-left'
    else if middlerightRadioButton.Checked then
      Settings.Position := 'middle-right'
    else if bottomleftRadioButton.Checked then
      Settings.Position := 'bottom-left'
    else if bottomcenterRadioButton.Checked then
      Settings.Position := 'bottom-center'
    else if bottomrightRadioButton.Checked then
      Settings.Position := 'bottom-right';

    Settings.OffsetX := offsetxSpinEdit.Value;
    Settings.OffsetY := offsetySpinEdit.Value;
    Settings.ToggleHudKey := Trim(hudonoffComboBox.Text);
    Settings.HideHud := hidehudCheckBox.Checked;
    Settings.HudCompact := hudcompactCheckBox.Checked;
    Settings.HorizontalStretch := horizontalstrechCheckBox.Checked;

    Settings.PciDevIndex := pcidevComboBox.ItemIndex;
    Settings.PciDevCount := pcidevComboBox.Items.Count;
    if (pcidevComboBox.Tag > 0) and (pcidevComboBox.ItemIndex = pcidevComboBox.Tag - 1) then
      Settings.PciDevText := MANGO_PCIDEV_BOTH_GPUS
    else if pcidevComboBox.ItemIndex <> -1 then
      Settings.PciDevText := pcidevComboBox.Items[pcidevComboBox.ItemIndex]
    else
      Settings.PciDevText := '';

    Settings.TableColumns := columvalueLabel.Caption;

    // Metrics Tab - GPU
    Settings.GpuText := gpunameEdit.Text;
    Settings.GpuAvgLoad := gpuavgloadCheckBox.Checked;
    Settings.GpuLoadColorChecked := gpuloadcolorCheckBox.Checked;
    Settings.GpuLoadColors[0] := gpuload1ColorButton.ButtonColor;
    Settings.GpuLoadColors[1] := gpuload2ColorButton.ButtonColor;
    Settings.GpuLoadColors[2] := gpuload3ColorButton.ButtonColor;
    Settings.VramUsage := vramusageCheckBox.Checked;
    Settings.VramColor := vramColorButton.ButtonColor;
    Settings.GpuFreq := gpufreqCheckBox.Checked;
    Settings.GpuMemFreq := gpumemfreqCheckBox.Checked;
    Settings.GpuTemp := gputempCheckBox.Checked;
    Settings.GpuMemTemp := gpumemtempCheckBox.Checked;
    Settings.GpuJuncTemp := gpujunctempCheckBox.Checked;
    Settings.GpuFan := gpufanCheckBox.Checked;
    Settings.GpuPower := gpupowerCheckBox.Checked;
    Settings.GpuPowerLimit := gpupowerlimitCheckBox.Checked;
    Settings.GpuEfficiency := gpuefficiencyCheckBox.Checked;
    if gpuframesjouleBitBtn.Tag = 1 then
      Settings.GpuFramesJouleCaption := MANGO_CAPTION_JOULES_PER_FRAME
    else
      Settings.GpuFramesJouleCaption := MANGO_CAPTION_FRAMES_PER_JOULE;
    Settings.GpuVoltage := gpuvoltageCheckBox.Checked;
    Settings.GpuThrottling := gputhrottlingCheckBox.Checked;
    Settings.GpuThrottlingGraph := gputhrottlinggraphCheckBox.Checked;
    Settings.GpuModel := gpumodelCheckBox.Checked;
    Settings.VulkanDriver := vulkandriverCheckBox.Checked;
    Settings.GpuColor := gpuColorButton.ButtonColor;

    // Metrics Tab - CPU
    Settings.CpuText := cpunameEdit.Text;
    Settings.CpuAvgLoad := cpuavgloadCheckBox.Checked;
    Settings.CpuLoadCore := cpuloadcoreCheckBox.Checked;
    if coreloadtypeBitBtn.ImageIndex = 7 then
      Settings.CoreLoadTypeCaption := MANGO_CAPTION_CORE_GRAPH
    else
      Settings.CoreLoadTypeCaption := MANGO_CAPTION_CORE_PERCENT;
    Settings.CpuLoadColorChecked := cpuloadcolorCheckBox.Checked;
    Settings.CpuLoadColors[0] := cpuload1ColorButton.ButtonColor;
    Settings.CpuLoadColors[1] := cpuload2ColorButton.ButtonColor;
    Settings.CpuLoadColors[2] := cpuload3ColorButton.ButtonColor;
    Settings.CpuFreq := cpufreqCheckBox.Checked;
    Settings.CpuTemp := cputempCheckBox.Checked;
    Settings.CpuPower := cpupowerCheckBox.Checked;
    Settings.CpuEfficiency := cpuefficiencyCheckBox.Checked;
    Settings.CpuCoreType := cpucoretypeCheckBox.Checked;
    Settings.CpuColor := cpuColorButton.ButtonColor;

    // Metrics Tab - Memory/IO
    Settings.DiskIo := diskioCheckBox.Checked;
    Settings.IoColor := iordrwColorButton.ButtonColor;
    Settings.SwapUsage := swapusageCheckBox.Checked;
    Settings.RamUsage := ramusageCheckBox.Checked;
    Settings.RamColor := ramColorButton.ButtonColor;
    Settings.RamTemp := ramtempCheckBox.Checked;
    Settings.ProcMem := procmemCheckBox.Checked;
    Settings.ProcVram := procvramCheckBox.Checked;

    // Metrics Tab - Graphs
    if Assigned(FgpuavgloadToggle) then
      Settings.GraphGpuLoad := FgpuavgloadToggle.GraphActive;
    if Assigned(FvramusageToggle) then
      Settings.GraphVram := FvramusageToggle.GraphActive;
    if Assigned(FgpufreqToggle) then
      Settings.GraphGpuCoreClock := FgpufreqToggle.GraphActive;
    if Assigned(FgpumemfreqToggle) then
      Settings.GraphGpuMemClock := FgpumemfreqToggle.GraphActive;
    if Assigned(FgputempToggle) then
      Settings.GraphGpuTemp := FgputempToggle.GraphActive;
    if Assigned(FcpuavgloadToggle) then
      Settings.GraphCpuLoad := FcpuavgloadToggle.GraphActive;
    if Assigned(FcputempToggle) then
      Settings.GraphCpuTemp := FcputempToggle.GraphActive;
    if Assigned(FramusageToggle) then
      Settings.GraphRam := FramusageToggle.GraphActive;

    // Metrics Tab - Other
    Settings.Battery := batteryCheckBox.Checked;
    Settings.BatteryColor := batteryColorButton.ButtonColor;
    Settings.BatteryWatt := batterywattCheckBox.Checked;
    Settings.BatteryTime := batterytimeCheckBox.Checked;
    Settings.Device := deviceCheckBox.Checked;
    Settings.Fps := fpsCheckBox.Checked;
    Settings.FpsAvg := fpsavgCheckBox.Checked;
    if fpsavgBitBtn.ImageIndex = 9 then
      Settings.FpsAvgCaption := MANGO_CAPTION_FPS_1PCT_LOW
    else
      Settings.FpsAvgCaption := MANGO_CAPTION_FPS_01PCT_LOW;
    Settings.FrametimeGraph := frametimegraphCheckBox.Checked;
    if Assigned(frametimedetailedCheckBox) then
      Settings.FrametimeDetailed := frametimedetailedCheckBox.Checked and frametimegraphCheckBox.Checked
    else
      Settings.FrametimeDetailed := False;
    Settings.FrametimeGraphColor := frametimegraphColorButton.ButtonColor;
    if frametimetypeBitBtn.ImageIndex = 7 then
      Settings.FrametimeTypeCaption := MANGO_CAPTION_FRAMETIME_HIST
    else
      Settings.FrametimeTypeCaption := MANGO_CAPTION_FRAMETIME_CURVE;
    Settings.FrameCount := framecountCheckBox.Checked;
    Settings.EngineVersion := engineversionCheckBox.Checked;
    Settings.EngineColor := engineColorButton.ButtonColor;
    Settings.EngineShort := engineshortCheckBox.Checked;
    Settings.Arch := archCheckBox.Checked;
    Settings.Wine := wineCheckBox.Checked;
    Settings.WineColor := wineColorButton.ButtonColor;
    Settings.Winesync := winesyncCheckBox.Checked;

    // Performance Tab
    Settings.ShowFpsLim := showfpslimCheckBox.Checked;
    Settings.FpsLimMetItemIndex := fpslimmetComboBox.ItemIndex;
    Settings.FpsLimToggleText := fpslimtoggleComboBox.Text;
    if Assigned(FFpsLimitEdit) then
      Settings.FpsLimitText := FFpsLimitEdit.Text
    else
      Settings.FpsLimitText := '';
    Settings.Resolution := resolutionCheckBox.Checked;
    Settings.RefreshRate := refreshrateCheckBox.Checked;
    Settings.Fcat := fcatCheckBox.Checked;
    Settings.FexStats := fexstatsCheckBox.Checked;
    Settings.Fsr := fsrCheckBox.Checked;
    Settings.Hdr := hdrCheckBox.Checked;
    Settings.Vps := vpsCheckBox.Checked;
    Settings.Fahrenheit := fahrenheitCheckBox.Checked;
    Settings.GamemodeStatus := gamemodestatusCheckBox.Checked;
    Settings.VkbasaltStatus := vkbasaltstatusCheckBox.Checked;
    Settings.VsyncItemIndex := vsyncComboBox.ItemIndex;
    Settings.GlvsyncItemIndex := glvsyncComboBox.ItemIndex;
    Settings.FilterItemIndex := filterRadioGroup.ItemIndex;
    Settings.AfPosition := afTrackBar.Position;
    Settings.MipmapPosition := mipmapTrackBar.Position;
    Settings.FpsColorChecked := fpscolorCheckBox.Checked;
    Settings.FpsColors[0] := fpscolor1ColorButton.ButtonColor;
    Settings.FpsColors[1] := fpscolor2ColorButton.ButtonColor;
    Settings.FpsColors[2] := fpscolor3ColorButton.ButtonColor;
    Settings.FpsColorValues[0] := fpscolor2SpinEdit.Value;
    Settings.FpsColorValues[1] := fpscolor3SpinEdit.Value;

    // Extras Tab
    Settings.DistroInfo := distroinfoCheckBox.Checked;
    Settings.DisplayServer := displayserverCheckBox.Checked;
    Settings.Time := timeCheckBox.Checked;
    Settings.HudVersion := hudversionCheckBox.Checked;
    Settings.Media := mediaCheckBox.Checked;
    Settings.MediaColor := mediaColorButton.ButtonColor;
    Settings.Network := networkCheckBox.Checked;
    Settings.NetworkItemIndex := networkComboBox.ItemIndex;
    if networkComboBox.ItemIndex <> -1 then
      Settings.NetworkInterfaceText := networkComboBox.Items[networkComboBox.ItemIndex]
    else
      Settings.NetworkInterfaceText := '';
    Settings.LogFolder := logfolderEdit.Text;
    Settings.Duration := durationTrackBar.Position;
    Settings.Delay := delayTrackBar.Position;
    Settings.Interval := intervalTrackBar.Position;
    Settings.LogToggleText := logtoggleComboBox.Text;
    Settings.Versioning := versioningCheckBox.Checked;
    Settings.AutoUpload := autouploadCheckBox.Checked;

    if not overlay_config.SaveMangoHudConfigCore(Settings, fontComboBox.Items, ErrMsg) then
    begin
      if ErrMsg <> '' then
        FForm.ShowStatusMessage('Error saving MangoHud config: ' + ErrMsg);
    end;
  end;
end;

end.