unit vkbasalt_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  StdCtrls, Buttons, Menus, LCLtype, Types, Grids, git2pas,
  themeunit, constants, hintsunit, apputils, overlayunit, overlay_config, systemdetector, ComCtrls, goverlay_strings;

type
  TPipelineChipHit = record
    Rect: TRect;
    LeftBtnRect: TRect;
    RightBtnRect: TRect;
    CloseBtnRect: TRect;
  end;

  TPipelineHoverBtn = (phbNone, phbLeft, phbRight, phbClose, phbChip);

  TVkBasaltTabHelper = class
  private
    FForm: Tgoverlayform;
    FChipHits: array of TPipelineChipHit;
    FDragIdx: Integer;
    FDragStartX: Integer;
    FDragCurrentX: Integer;
    FHoverChipIdx: Integer;
    FHoverBtn: TPipelineHoverBtn;
  public
    constructor Create(AForm: Tgoverlayform);
    destructor Destroy; override;
    procedure InitVkBasaltTab;
    procedure ReflowVkBasaltTab(AContentW: Integer);
    procedure BuildVkSumiTab;
    procedure ReflowVkSumiTab(AContentW: Integer);
    procedure VkSumiSliderChange(Sender: TObject);
    procedure VsRestoreBtnClick(Sender: TObject);
    procedure VkRestoreBtnClick(Sender: TObject);
    procedure reshaderefreshBitBtnClick(Sender: TObject);
    procedure VkReshadeMD3Paint(Sender: TObject);
    procedure VkReshadeMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VkReshadeMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VkReshadeMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure VkReshadeMD3ScrollChange(Sender: TObject);
    procedure VkPipelineCardPaint(Sender: TObject);
    procedure VkPipelineCardMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VkPipelineCardMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VkPipelineCardMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VkPipelineCardMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure VkPipelineScrollChange(Sender: TObject);
    procedure AddEffectToPipeline(const AEffectName: string);
    procedure RemoveEffectFromPipeline(const AEffectName: string);
    procedure DisablePipelineEffect(const AEffectName: string);
    procedure MovePipelineEffect(FromIdx, ToIdx: Integer);
  end;

implementation

constructor TVkBasaltTabHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
  FDragIdx := -1;
  FHoverChipIdx := -1;
  FHoverBtn := phbNone;
end;

destructor TVkBasaltTabHelper.Destroy;
begin
  FreeAndNil(FForm.FPipelineEffects);
  inherited Destroy;
end;

procedure TVkBasaltTabHelper.InitVkBasaltTab;
const
  BG        = $002E1E1A;  // rgb(26,30,46) — matches other tabs
  CLR_WHITE = clWhite;
var
  TitleLbl:  TLabel;
begin
  with FForm do
  begin
    // ── Hide the old LFM group boxes (functional children are reparented below)
  reshadeGroupBox.Visible        := False;
  builtineffectsGroupBox.Visible := False;
  vktoggleLabel.Visible          := False;
  toggleImage.Visible            := False;

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 1 — Reshade Effects
  // ══════════════════════════════════════════════════════════════════════════
  FVkReshadeCard := TPanel.Create(FForm);
  FVkReshadeCard.Parent     := vkbasaltTabSheet;
  FVkReshadeCard.BevelOuter := bvNone;
  FVkReshadeCard.Color      := BG;
  FVkReshadeCard.Caption    := '';
  FVkReshadeCard.OnPaint    := @SubCardPaint;

  TitleLbl := TLabel.Create(FVkReshadeCard);
  TitleLbl.Parent      := FVkReshadeCard;
  StyleLabel(TitleLbl, lrCardTitle);
  TitleLbl.Caption     := 'Reshade Effects';
  TitleLbl.SetBounds(12, 10, 200, 22);

  // Hide old dual-listbox UI (data still kept in hidden listboxes for save/load)
  if Assigned(FVkAvHdrLbl) then FVkAvHdrLbl.Visible := False;
  if Assigned(FVkActHdrLbl) then FVkActHdrLbl.Visible := False;
  aveffectsListBox.Visible     := False;
  aveffectsListBox.Parent      := FForm;   // move off-card so it doesn't clip
  acteffectsListBox.Visible    := False;
  acteffectsListBox.Parent     := FForm;
  addBitBtn.Visible            := False;
  subBitBtn.Visible            := False;
  reshaderefreshBitBtn.Visible := False;

  // ── MD3-style reshade effects list ──
  FVkReshadePB := TPaintBox.Create(FForm);
  FVkReshadePB.Parent      := FVkReshadeCard;
  FVkReshadePB.Color       := BG;
  FVkReshadePB.OnPaint     := @VkReshadeMD3Paint;
  FVkReshadePB.OnMouseMove := @VkReshadeMD3MouseMove;
  FVkReshadePB.OnMouseDown := @VkReshadeMD3MouseDown;
  FVkReshadePB.OnMouseWheel:= @VkReshadeMD3MouseWheel;

  FVkReshadeSB := TScrollBar.Create(FForm);
  FVkReshadeSB.Parent      := FVkReshadeCard;
  FVkReshadeSB.Kind        := sbVertical;
  FVkReshadeSB.Visible     := False;
  FVkReshadeSB.OnChange    := @VkReshadeMD3ScrollChange;

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 2 — Built-in Effects
  // ══════════════════════════════════════════════════════════════════════════
  FVkBuiltinCard := TPanel.Create(FForm);
  FVkBuiltinCard.Parent     := vkbasaltTabSheet;
  FVkBuiltinCard.BevelOuter := bvNone;
  FVkBuiltinCard.Color      := BG;
  FVkBuiltinCard.Caption    := '';
  FVkBuiltinCard.OnPaint    := @SubCardPaint;

  TitleLbl := TLabel.Create(FVkBuiltinCard);
  TitleLbl.Parent      := FVkBuiltinCard;
  StyleLabel(TitleLbl, lrCardTitle);
  TitleLbl.Caption     := 'Built-in Effects';
  TitleLbl.SetBounds(12, 10, 200, 22);

  // Clear LFM anchors to prevent conflicting alignment
  casTrackBar.AnchorSideLeft.Control := nil; casTrackBar.AnchorSideTop.Control := nil; casTrackBar.AnchorSideRight.Control := nil; casTrackBar.AnchorSideBottom.Control := nil;
  fxaaTrackBar.AnchorSideLeft.Control := nil; fxaaTrackBar.AnchorSideTop.Control := nil; fxaaTrackBar.AnchorSideRight.Control := nil; fxaaTrackBar.AnchorSideBottom.Control := nil;
  smaaTrackBar.AnchorSideLeft.Control := nil; smaaTrackBar.AnchorSideTop.Control := nil; smaaTrackBar.AnchorSideRight.Control := nil; smaaTrackBar.AnchorSideBottom.Control := nil;
  dlsTrackBar.AnchorSideLeft.Control := nil; dlsTrackBar.AnchorSideTop.Control := nil; dlsTrackBar.AnchorSideRight.Control := nil; dlsTrackBar.AnchorSideBottom.Control := nil;

  casLabel.AnchorSideLeft.Control := nil; casLabel.AnchorSideTop.Control := nil; casLabel.AnchorSideRight.Control := nil; casLabel.AnchorSideBottom.Control := nil;
  fxaaLabel.AnchorSideLeft.Control := nil; fxaaLabel.AnchorSideTop.Control := nil; fxaaLabel.AnchorSideRight.Control := nil; fxaaLabel.AnchorSideBottom.Control := nil;
  smaaLabel.AnchorSideLeft.Control := nil; smaaLabel.AnchorSideTop.Control := nil; smaaLabel.AnchorSideRight.Control := nil; smaaLabel.AnchorSideBottom.Control := nil;
  dlsLabel.AnchorSideLeft.Control := nil; dlsLabel.AnchorSideTop.Control := nil; dlsLabel.AnchorSideRight.Control := nil; dlsLabel.AnchorSideBottom.Control := nil;

  // Reparent trackbars + name labels; hide old value labels (replaced below)
  casTrackBar.Parent  := FVkBuiltinCard; casTrackBar.Anchors := [akLeft, akTop]; casTrackBar.Visible := True;
  fxaaTrackBar.Parent := FVkBuiltinCard; fxaaTrackBar.Anchors := [akLeft, akTop]; fxaaTrackBar.Visible := True;
  smaaTrackBar.Parent := FVkBuiltinCard; smaaTrackBar.Anchors := [akLeft, akTop]; smaaTrackBar.Visible := True;
  dlsTrackBar.Parent  := FVkBuiltinCard; dlsTrackBar.Anchors  := [akLeft, akTop]; dlsTrackBar.Visible  := True;

  casLabel.Parent  := FVkBuiltinCard; casLabel.Anchors  := [akLeft, akTop];
  casLabel.Font.Color := $BB99FF; casLabel.Font.Style := [fsBold]; casLabel.Font.Size := 9;
  casLabel.Color := BG; casLabel.Visible := True;

  fxaaLabel.Parent := FVkBuiltinCard; fxaaLabel.Anchors := [akLeft, akTop];
  fxaaLabel.Font.Color := $BB99FF; fxaaLabel.Font.Style := [fsBold]; fxaaLabel.Font.Size := 9;
  fxaaLabel.Color := BG; fxaaLabel.Visible := True;

  smaaLabel.Parent := FVkBuiltinCard; smaaLabel.Anchors := [akLeft, akTop];
  smaaLabel.Font.Color := $BB99FF; smaaLabel.Font.Style := [fsBold]; smaaLabel.Font.Size := 9;
  smaaLabel.Color := BG; smaaLabel.Visible := True;

  dlsLabel.Parent  := FVkBuiltinCard; dlsLabel.Anchors  := [akLeft, akTop];
  dlsLabel.Font.Color := $BB99FF; dlsLabel.Font.Style := [fsBold]; dlsLabel.Font.Size := 9;
  dlsLabel.Color := BG; dlsLabel.Visible := True;

  // Fresh value labels — created here to avoid any LFM inheritance issues
  FVkCasValLbl := TLabel.Create(FForm);
  FVkCasValLbl.Parent := FVkBuiltinCard;
  FVkCasValLbl.Caption := casvalueLabel.Caption;
  FVkCasValLbl.Font.Color := RGBToColor(48, 190, 240); FVkCasValLbl.Font.Style := [fsBold]; FVkCasValLbl.Font.Size := 9;
  FVkCasValLbl.Color := BG; FVkCasValLbl.Anchors := [akLeft, akTop];

  FVkFxaaValLbl := TLabel.Create(FForm);
  FVkFxaaValLbl.Parent := FVkBuiltinCard;
  FVkFxaaValLbl.Caption := fxaavalueLabel.Caption;
  FVkFxaaValLbl.Font.Color := RGBToColor(48, 190, 240); FVkFxaaValLbl.Font.Style := [fsBold]; FVkFxaaValLbl.Font.Size := 9;
  FVkFxaaValLbl.Color := BG; FVkFxaaValLbl.Anchors := [akLeft, akTop];

  FVkSmaaValLbl := TLabel.Create(FForm);
  FVkSmaaValLbl.Parent := FVkBuiltinCard;
  FVkSmaaValLbl.Caption := smaavalueLabel.Caption;
  FVkSmaaValLbl.Font.Color := RGBToColor(48, 190, 240); FVkSmaaValLbl.Font.Style := [fsBold]; FVkSmaaValLbl.Font.Size := 9;
  FVkSmaaValLbl.Color := BG; FVkSmaaValLbl.Anchors := [akLeft, akTop];

  FVkDlsValLbl := TLabel.Create(FForm);
  FVkDlsValLbl.Parent := FVkBuiltinCard;
  FVkDlsValLbl.Caption := dlsvalueLabel.Caption;
  FVkDlsValLbl.Font.Color := RGBToColor(48, 190, 240); FVkDlsValLbl.Font.Style := [fsBold]; FVkDlsValLbl.Font.Size := 9;
  FVkDlsValLbl.Color := BG; FVkDlsValLbl.Anchors := [akLeft, akTop];

  // Load custom icons for Built-in Effects card
  FVkCasIcon := TImage.Create(FForm);
  FVkCasIcon.Parent := FVkBuiltinCard;
  FVkCasIcon.AntialiasingMode := amOn;
  FVkCasIcon.Proportional := True;
  FVkCasIcon.Stretch := True;
  if FileExists(GetAppBaseDir + 'assets/icons/vk_cas.png') then
    FVkCasIcon.Picture.LoadFromFile(GetAppBaseDir + 'assets/icons/vk_cas.png');

  FVkFxaaIcon := TImage.Create(FForm);
  FVkFxaaIcon.Parent := FVkBuiltinCard;
  FVkFxaaIcon.AntialiasingMode := amOn;
  FVkFxaaIcon.Proportional := True;
  FVkFxaaIcon.Stretch := True;
  if FileExists(GetAppBaseDir + 'assets/icons/vk_fxaa.png') then
    FVkFxaaIcon.Picture.LoadFromFile(GetAppBaseDir + 'assets/icons/vk_fxaa.png');

  FVkSmaaIcon := TImage.Create(FForm);
  FVkSmaaIcon.Parent := FVkBuiltinCard;
  FVkSmaaIcon.AntialiasingMode := amOn;
  FVkSmaaIcon.Proportional := True;
  FVkSmaaIcon.Stretch := True;
  if FileExists(GetAppBaseDir + 'assets/icons/vk_smaa.png') then
    FVkSmaaIcon.Picture.LoadFromFile(GetAppBaseDir + 'assets/icons/vk_smaa.png');

  FVkDlsIcon := TImage.Create(FForm);
  FVkDlsIcon.Parent := FVkBuiltinCard;
  FVkDlsIcon.AntialiasingMode := amOn;
  FVkDlsIcon.Proportional := True;
  FVkDlsIcon.Stretch := True;
  if FileExists(GetAppBaseDir + 'assets/icons/vk_dls.png') then
    FVkDlsIcon.Picture.LoadFromFile(GetAppBaseDir + 'assets/icons/vk_dls.png');

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 3 — Effect Pipeline
  // ══════════════════════════════════════════════════════════════════════════
  FVkPipelineCard := TPanel.Create(FForm);
  FVkPipelineCard.Parent     := vkbasaltTabSheet;
  FVkPipelineCard.BevelOuter := bvNone;
  FVkPipelineCard.Color      := BG;
  FVkPipelineCard.Caption    := '';
  FVkPipelineCard.OnPaint    := @SubCardPaint;

  TitleLbl := TLabel.Create(FVkPipelineCard);
  TitleLbl.Parent      := FVkPipelineCard;
  StyleLabel(TitleLbl, lrCardTitle);
  TitleLbl.Caption     := 'Effect Pipeline';
  TitleLbl.SetBounds(12, 8, 280, 20);

  FVkPipelinePB := TPaintBox.Create(FForm);
  FVkPipelinePB.Parent      := FVkPipelineCard;
  FVkPipelinePB.Color       := BG;
  FVkPipelinePB.OnPaint     := @VkPipelineCardPaint;
  FVkPipelinePB.OnMouseDown := @VkPipelineCardMouseDown;
  FVkPipelinePB.OnMouseMove := @VkPipelineCardMouseMove;
  FVkPipelinePB.OnMouseUp   := @VkPipelineCardMouseUp;
  FVkPipelinePB.OnMouseWheel:= @VkPipelineCardMouseWheel;

  FVkPipelineSB := TScrollBar.Create(FForm);
  FVkPipelineSB.Parent      := FVkPipelineCard;
  FVkPipelineSB.Kind        := sbHorizontal;
  FVkPipelineSB.Visible     := False;
  FVkPipelineSB.OnChange    := @VkPipelineScrollChange;

  if not Assigned(FPipelineEffects) then
    FPipelineEffects := TStringList.Create;

  // ══════════════════════════════════════════════════════════════════════════
  // CARD 4 — Toggle Key
  // ══════════════════════════════════════════════════════════════════════════
  FVkToggleCard := TPanel.Create(FForm);
  FVkToggleCard.Parent     := vkbasaltTabSheet;
  FVkToggleCard.BevelOuter := bvNone;
  FVkToggleCard.Color      := BG;
  FVkToggleCard.Caption    := '';
  FVkToggleCard.OnPaint    := @SubCardPaint;

  FVkToggleTitleLbl := TLabel.Create(FVkToggleCard);
  FVkToggleTitleLbl.Parent      := FVkToggleCard;
  StyleLabel(FVkToggleTitleLbl, lrCardTitle);
  FVkToggleTitleLbl.Caption     := 'Toggle key';
  FVkToggleTitleLbl.SetBounds(12, 10, 100, 22);

  // Reparent combobox off the vkbasalt tab (hidden data store)
  vkbtogglekeyCombobox.Visible := False;
  vkbtogglekeyCombobox.Parent  := FForm;
  if vkbtogglekeyCombobox.Text = '' then
    vkbtogglekeyCombobox.Text := 'Home';

  FVkToggleCaptureBtn := TBitBtn.Create(FVkToggleCard);
  FVkToggleCaptureBtn.Parent   := FVkToggleCard;
  FVkToggleCaptureBtn.Tag      := 4;
  FVkToggleCaptureBtn.Anchors  := [akLeft, akTop];
  FVkToggleCaptureBtn.Cursor   := crHandPoint;
  FVkToggleCaptureBtn.OnClick  := @CaptureBtnClick;
  FVkToggleCaptureBtn.Caption  := '⌨ ' + vkbtogglekeyCombobox.Text;
  StyleActionButton(FVkToggleCaptureBtn);

  // ── Restore defaults button (placed to the right of Toggle Key button)
  FVkRestoreBtn := TBitBtn.Create(FVkToggleCard);
  FVkRestoreBtn.Parent   := FVkToggleCard;
  FVkRestoreBtn.Caption  := 'Restore Defaults';
  FVkRestoreBtn.Hint     := 'Reset all vkBasalt sliders and active effects';
  FVkRestoreBtn.ShowHint := True;
  FVkRestoreBtn.Anchors  := [akLeft, akTop];
  FVkRestoreBtn.Cursor   := crHandPoint;
  FVkRestoreBtn.OnClick  := @VkRestoreBtnClick;
  StyleActionButton(FVkRestoreBtn);

  // ── Reshade sync button (placed to the right of Restore Defaults button)
  FVkReshadeSyncBtn := TBitBtn.Create(FVkToggleCard);
  FVkReshadeSyncBtn.Parent   := FVkToggleCard;
  FVkReshadeSyncBtn.Anchors  := [akLeft, akTop];
  FVkReshadeSyncBtn.Cursor   := crHandPoint;
  FVkReshadeSyncBtn.Caption  := '↻ Sync Shaders';
  FVkReshadeSyncBtn.OnClick  := @reshaderefreshBitBtnClick;
  StyleActionButton(FVkReshadeSyncBtn);
  end;
end;

procedure TVkBasaltTabHelper.ReflowVkBasaltTab(AContentW: Integer);
const
  MARGIN   = 4;   // outer margin each side
  GAP      = 8;    // gap between cards
  BTIN_H   = 145;  // built-in effects card height
  PIPE_H   = 72;   // effect pipeline card height
  TOGL_H   = 75;   // toggle key card height
  PAD      = 12;   // inner horizontal padding
  NAME_W   = 52;   // effect name label width
  VAL_W    = 32;   // value label width
  SB_W     = 6;    // scrollbar width
var
  CW:      Integer;
  TabH:    Integer;
  RSHD_H:  Integer;
  ColW:    Integer;
  Col0:    Integer;
  Col1:    Integer;
  Row0:    Integer;
  Row1:    Integer;
begin
  with FForm do
  begin
    if not Assigned(FVkReshadeCard) then Exit;

  CW   := AContentW - 2 * MARGIN;
  TabH := vkbasaltTabSheet.ClientHeight;
  if (TabH < 150) or (goverlayPageControl.ShowTabs and (TabH >= goverlayPageControl.ClientHeight - 10)) then
  begin
    if Assigned(goverlayPageControl) and (goverlayPageControl.ClientHeight > 150) then
      TabH := goverlayPageControl.ClientHeight - 38
    else
      TabH := FForm.ClientHeight - 170;
  end;

  // ── Card 1: Reshade (fills remaining space above bottom cards) ─────────
  RSHD_H := TabH - 2 * MARGIN - BTIN_H - PIPE_H - TOGL_H - 3 * GAP;
  if RSHD_H < 120 then RSHD_H := 120;  // minimum sensible height
  FVkReshadeCard.SetBounds(MARGIN, MARGIN, CW, RSHD_H);

  if Assigned(FVkReshadePB) then
    FVkReshadePB.SetBounds(PAD, 40, CW - 2 * PAD - SB_W, RSHD_H - 40 - PAD);
  if Assigned(FVkReshadeSB) then
    FVkReshadeSB.SetBounds(CW - PAD - SB_W, 40, SB_W, RSHD_H - 40 - PAD);

  // ── Card 2: Built-in Effects (bottom area, left) ───────────────────────
  FVkBuiltinCard.SetBounds(MARGIN, MARGIN + RSHD_H + GAP, CW, BTIN_H);

  ColW  := (CW - 3 * PAD) div 2;
  Col0  := PAD;
  Col1  := PAD + ColW + PAD;
  Row0  := 44;              // Row 0 Y-coordinate (CAS / FXAA)

  // CAS (Column 0, Row 0)
  if Assigned(FVkCasIcon) then FVkCasIcon.SetBounds(Col0, Row0 + 6, 16, 16);
  casLabel.SetBounds(Col0 + 22, Row0 + 5, 45, 18);
  casTrackBar.SetBounds(Col0 + 72, Row0, ColW - 72 - VAL_W - 8, 28);
  if Assigned(FVkCasValLbl)  then FVkCasValLbl.SetBounds(Col0 + ColW - VAL_W, Row0 + 5, VAL_W, 18);

  // FXAA (Column 1, Row 0)
  if Assigned(FVkFxaaIcon) then FVkFxaaIcon.SetBounds(Col1, Row0 + 6, 16, 16);
  fxaaLabel.SetBounds(Col1 + 22, Row0 + 5, 45, 18);
  fxaaTrackBar.SetBounds(Col1 + 72, Row0, ColW - 72 - VAL_W - 8, 28);
  if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.SetBounds(Col1 + ColW - VAL_W, Row0 + 5, VAL_W, 18);

  Row1  := Row0 + 28 + 14;  // Row 1 Y-coordinate (SMAA / DLS)

  // SMAA (Column 0, Row 1)
  if Assigned(FVkSmaaIcon) then FVkSmaaIcon.SetBounds(Col0, Row1 + 6, 16, 16);
  smaaLabel.SetBounds(Col0 + 22, Row1 + 5, 45, 18);
  smaaTrackBar.SetBounds(Col0 + 72, Row1, ColW - 72 - VAL_W - 8, 28);
  if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.SetBounds(Col0 + ColW - VAL_W, Row1 + 5, VAL_W, 18);

  // DLS (Column 1, Row 1)
  if Assigned(FVkDlsIcon) then FVkDlsIcon.SetBounds(Col1, Row1 + 6, 16, 16);
  dlsLabel.SetBounds(Col1 + 22, Row1 + 5, 45, 18);
  dlsTrackBar.SetBounds(Col1 + 72, Row1, ColW - 72 - VAL_W - 8, 28);
  if Assigned(FVkDlsValLbl)  then FVkDlsValLbl.SetBounds(Col1 + ColW - VAL_W, Row1 + 5, VAL_W, 18);

  // ── Card 3: Effect Pipeline (Execution Order) ──────────────────────────
  if Assigned(FVkPipelineCard) then
  begin
    FVkPipelineCard.SetBounds(MARGIN, MARGIN + RSHD_H + GAP + BTIN_H + GAP, CW, PIPE_H);
    if Assigned(FVkPipelinePB) then
      FVkPipelinePB.SetBounds(PAD, 24, CW - 2 * PAD, 34);
    if Assigned(FVkPipelineSB) then
      FVkPipelineSB.SetBounds(PAD, 60, CW - 2 * PAD, 8);
  end;

  // ── Card 4: Toggle Key (bottom area, right) ────────────────────────────
  FVkToggleCard.SetBounds(MARGIN, MARGIN + RSHD_H + GAP + BTIN_H + GAP + PIPE_H + GAP, CW, TOGL_H);

  if Assigned(FVkToggleCaptureBtn) and Assigned(FVkToggleTitleLbl) then
    FVkToggleCaptureBtn.SetBounds(FVkToggleTitleLbl.Left,
                                   FVkToggleTitleLbl.Top + FVkToggleTitleLbl.Height + 4, 120, 28);

  if Assigned(FVkRestoreBtn) and Assigned(FVkToggleCaptureBtn) then
    FVkRestoreBtn.SetBounds(FVkToggleCaptureBtn.Left + FVkToggleCaptureBtn.Width + 12,
                            FVkToggleCaptureBtn.Top, 140, 28);

  if Assigned(FVkReshadeSyncBtn) and Assigned(FVkRestoreBtn) then
    FVkReshadeSyncBtn.SetBounds(FVkRestoreBtn.Left + FVkRestoreBtn.Width + 12,
                                FVkToggleCaptureBtn.Top, 130, 28);
  end;
end;

procedure TVkBasaltTabHelper.BuildVkSumiTab;
const
  CARD_M   = 0;
  CARD_P   = 14;
  ROW_H    = 32;
  LBL_W    = 100;
  SLD_W    = 200;
  GB_PAD   = 8;
var
  IsLight: Boolean;
  BgClr, CardBg, TxtClr: TColor;
  Card: TPanel;
  ToneSec, BandSec, ColorSec, GainSec: TPanel;
  Y, i, RowY, CW: Integer;

  function MkCard(AY, AH: Integer): TPanel;
  begin
    Result := TPanel.Create(FForm);
    Result.Parent       := FForm.FVsBgPanel;
    Result.BevelOuter   := bvNone;
    Result.BorderStyle  := bsNone;
    Result.Caption      := '';
    Result.Color        := CardBg;
    Result.ParentColor  := False;
    Result.Left         := CARD_M;
    Result.Top          := AY;
    Result.Width        := CW - 2 * CARD_M;
    Result.Height       := AH;
    Result.Anchors      := [akLeft, akTop];
    Result.OnPaint      := @FForm.SubCardPaint;
  end;

  function MkSection(AParent: TPanel; const ATitle: string;
    AY, AH: Integer): TPanel;
  var
    TitleLbl: TLabel;
  begin
    // Outer panel (card-like section)
    Result := TPanel.Create(FForm);
    Result.Parent       := AParent;
    Result.BevelOuter   := bvNone;
    Result.BorderStyle  := bsNone;
    Result.Caption      := '';
    Result.Color        := CardBg;
    Result.ParentColor  := False;
    Result.Left         := CARD_P;
    Result.Top          := AY;
    Result.Width        := AParent.Width - 2 * CARD_P;
    Result.Height       := AH;
    Result.Anchors      := [akLeft, akTop, akRight];
    Result.OnPaint      := @FForm.SubCardPaint;

    // Title label (left-aligned, soft color/bold to match OptiScaler groupboxes)
    TitleLbl := TLabel.Create(FForm);
    TitleLbl.Parent      := Result;
    TitleLbl.Caption     := ATitle;
    TitleLbl.Font.Bold   := True;
    TitleLbl.Font.Size   := 8;
    if IsLight then
      TitleLbl.Font.Color := LightTextColor
    else
      TitleLbl.Font.Color := RGBToColor(170, 170, 204); // matches OptiScaler's soft text $00CCAAAA
    TitleLbl.Left        := 6;
    TitleLbl.Top         := 4;
    TitleLbl.Transparent := True;
    TitleLbl.AutoSize    := True;
  end;

  function GetIconForParam(AIndex: Integer): string;
  begin
    case AIndex of
      0:  Result := '';  // Brightness
      1:  Result := '◑';  // Contrast
      2:  Result := '󰃠';  // Exposure
      3:  Result := '󰃠';  // Gamma
      4:  Result := '';  // Saturation (originally thermometer, monochromatic)
      5:  Result := '';  // Vibrance (originally paintbrush, monochromatic)
      6:  Result := '';  // Hue (originally sparkles, now monochromatic magic wand/sparkles)
      7:  Result := '';  // Temperature (originally palette, now monochromatic fire/temp)
      8:  Result := '';  // Tint (originally droplet, now monochromatic droplet/tint)
      9:  Result := '🔴';
      10: Result := '🟢';
      11: Result := '🔵';
      12: Result := '';
      13: Result := '󰃟';
      14: Result := '󰃠';
    else
      Result := '';
    end;
  end;

  procedure AddSliderLine(AParent: TPanel; const AParam: TParamDef;
    AIndex: Integer; var AY: Integer);
  begin
    FForm.FVsNameLabels[AIndex] := TLabel.Create(FForm);
    FForm.FVsNameLabels[AIndex].Parent     := AParent;
    FForm.FVsNameLabels[AIndex].Caption    := GetIconForParam(AIndex) + '  ' + AParam.Name;
    FForm.FVsNameLabels[AIndex].Font.Color := TxtClr;
    FForm.FVsNameLabels[AIndex].Font.Size  := 9;
    FForm.FVsNameLabels[AIndex].Left       := GB_PAD;
    FForm.FVsNameLabels[AIndex].Top        := AY + 5;
    FForm.FVsNameLabels[AIndex].AutoSize   := True;

    FForm.FVsTrackbars[AIndex] := TTrackBar.Create(FForm);
    FForm.FVsTrackbars[AIndex].Parent      := AParent;
    FForm.FVsTrackbars[AIndex].Min         := AParam.Min;
    FForm.FVsTrackbars[AIndex].Max         := AParam.Max;
    FForm.FVsTrackbars[AIndex].Position    := AParam.Default;
    FForm.FVsTrackbars[AIndex].TickStyle   := tsNone;
    FForm.FVsTrackbars[AIndex].Height      := 26;
    FForm.FVsTrackbars[AIndex].Left        := GB_PAD + LBL_W;
    FForm.FVsTrackbars[AIndex].Top         := AY;
    FForm.FVsTrackbars[AIndex].Anchors     := [akLeft, akTop, akRight];
    FForm.FVsTrackbars[AIndex].Width       := SLD_W;
    FForm.FVsTrackbars[AIndex].Tag         := AIndex;
    FForm.FVsTrackbars[AIndex].OnChange    := @VkSumiSliderChange;
    FForm.FVsTrackbars[AIndex].Hint        := PARAM_HINTS[AIndex];
    FForm.FVsTrackbars[AIndex].ShowHint    := True;

    FForm.FVsNameLabels[AIndex].Hint       := PARAM_HINTS[AIndex];
    FForm.FVsNameLabels[AIndex].ShowHint   := True;

    FForm.FVsValLabels[AIndex] := TLabel.Create(FForm);
    FForm.FVsValLabels[AIndex].Parent      := AParent;
    FForm.FVsValLabels[AIndex].Font.Color  := RGBToColor(48, 190, 240);
    FForm.FVsValLabels[AIndex].Font.Size   := 9;
    FForm.FVsValLabels[AIndex].Font.Style  := [fsBold];
    FForm.FVsValLabels[AIndex].Left        := GB_PAD + LBL_W + SLD_W + 8;
    FForm.FVsValLabels[AIndex].Top         := AY + 5;
    FForm.FVsValLabels[AIndex].Anchors     := [akTop, akRight];
    FForm.FVsValLabels[AIndex].AutoSize    := True;
    FForm.FVsValLabels[AIndex].Caption     := '0.00';

    AY := AY + ROW_H;
  end;

begin
  with FForm do
  begin
    IsLight := CurrentTheme = tmLight;
    BgClr   := IfThen(IsLight, $00F0F0F0, RGBToColor(22, 25, 37));
    CardBg  := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
    TxtClr  := IfThen(IsLight, LightTextColor, DarkTextColor);

    vksumiTabSheet.Color := BgClr;

    // Create ScrollBox for dynamic height / scrollability
    FVsScrollBox := TScrollBox.Create(FForm);
    FVsScrollBox.Parent      := vksumiTabSheet;
    FVsScrollBox.Align       := alClient;
    FVsScrollBox.AutoScroll  := True;
    FVsScrollBox.BorderStyle := bsNone;
    FVsScrollBox.HorzScrollBar.Visible := False;
    FVsScrollBox.Color       := BgClr;
    FVsScrollBox.ParentColor := False;

    // Background panel filling the scroll box
    FVsBgPanel := TPanel.Create(FForm);
    FVsBgPanel.Parent     := FVsScrollBox;
    FVsBgPanel.BevelOuter := bvNone;
    FVsBgPanel.Color      := BgClr;
    FVsBgPanel.Caption    := '';
    FVsBgPanel.Left       := 0;
    FVsBgPanel.Top        := 0;
    FVsBgPanel.Width      := FVsScrollBox.ClientWidth;
    FVsBgPanel.Height     := 692;

    CW      := FVsScrollBox.ClientWidth;
    if CW < 200 then CW := 200;

    // ── Settings card (Visible, containing Restore default + Toggle key) ──────
    Card := MkCard(0, 85);
    FVsCards[0] := Card;

    FVsEnabledCB := TCheckBox.Create(FForm);
    FVsEnabledCB.Parent      := FForm;
    FVsEnabledCB.Visible     := False;
    FVsEnabledCB.Checked     := True;

    FVsToggleEdit := TEdit.Create(FForm);
    FVsToggleEdit.Parent      := FForm;
    FVsToggleEdit.Visible     := False;
    FVsToggleEdit.Text        := 'Shift_R+F9';

    FVsToggleTitleLbl := TLabel.Create(Card);
    FVsToggleTitleLbl.Parent      := Card;
    StyleLabel(FVsToggleTitleLbl, lrCardTitle);
    FVsToggleTitleLbl.Caption     := 'Toggle key';
    FVsToggleTitleLbl.SetBounds(CARD_P, CARD_P, 100, 22);

    FVsToggleCaptureBtn := TBitBtn.Create(Card);
    FVsToggleCaptureBtn.Parent   := Card;
    FVsToggleCaptureBtn.Tag      := 6;
    FVsToggleCaptureBtn.Anchors  := [akLeft, akTop];
    FVsToggleCaptureBtn.Cursor   := crHandPoint;
    FVsToggleCaptureBtn.OnClick  := @CaptureBtnClick;
    FVsToggleCaptureBtn.Caption  := '⌨ ' + FVsToggleEdit.Text;
    FVsToggleCaptureBtn.SetBounds(CARD_P, CARD_P + 26, 150, 30);
    StyleActionButton(FVsToggleCaptureBtn);

    FVsRestoreBtn := TBitBtn.Create(Card);
    FVsRestoreBtn.Parent      := Card;
    FVsRestoreBtn.Caption     := 'Restore default';
    FVsRestoreBtn.Anchors     := [akLeft, akTop];
    FVsRestoreBtn.Cursor      := crHandPoint;
    FVsRestoreBtn.OnClick     := @VsRestoreBtnClick;
    FVsRestoreBtn.SetBounds(CARD_P + 180, CARD_P + 26, 150, 30);
    StyleActionButton(FVsRestoreBtn);

    // ── Left Card: Tone + 3-Band ──────────────────────────────────────────
    Card := MkCard(0, 400);
    FVsCards[1] := Card;

    FVsLuminanceTitleLbl := TLabel.Create(Card);
    FVsLuminanceTitleLbl.Parent      := Card;
    StyleLabel(FVsLuminanceTitleLbl, lrCardTitle);
    FVsLuminanceTitleLbl.Caption     := 'Luminance';
    FVsLuminanceTitleLbl.SetBounds(CARD_P, CARD_P, 150, 22);

    ToneSec := MkSection(Card, 'Tone', CARD_P + 30, 4 * ROW_H + 32);
    RowY := 24;
    for i := 0 to 3 do AddSliderLine(ToneSec, PARAMS[i], i, RowY);

    BandSec := MkSection(Card, '3-Band', ToneSec.Top + ToneSec.Height + 8, 3 * ROW_H + 32);
    RowY := 24;
    for i := 12 to 14 do AddSliderLine(BandSec, PARAMS[i], i, RowY);

    Card.Height := BandSec.Top + BandSec.Height + CARD_P;

    // ── Right Card: Color + Per-channel Gain ─────────────────────────────
    Card := MkCard(0, 400);
    FVsCards[2] := Card;

    FVsChrominanceTitleLbl := TLabel.Create(Card);
    FVsChrominanceTitleLbl.Parent      := Card;
    StyleLabel(FVsChrominanceTitleLbl, lrCardTitle);
    FVsChrominanceTitleLbl.Caption     := 'Chrominance';
    FVsChrominanceTitleLbl.SetBounds(CARD_P, CARD_P, 150, 22);

    ColorSec := MkSection(Card, 'Color', CARD_P + 30, 5 * ROW_H + 32);
    RowY := 24;
    for i := 4 to 8 do AddSliderLine(ColorSec, PARAMS[i], i, RowY);

    GainSec := MkSection(Card, 'Per-channel Gain', ColorSec.Top + ColorSec.Height + 8, 3 * ROW_H + 32);
    RowY := 24;
    for i := 9 to 11 do AddSliderLine(GainSec, PARAMS[i], i, RowY);

    Card.Height := GainSec.Top + GainSec.Height + CARD_P;

    // ── Show value labels ────────────────────────────────────────────────
    for i := 0 to 14 do
      if Assigned(FVsTrackbars[i]) then
        VkSumiSliderChange(FVsTrackbars[i]);

    // Reflow cards to proper 2-column layout
    ReflowVkSumiTab(Max(800, vksumiTabSheet.ClientWidth));
  end;
end;

procedure TVkBasaltTabHelper.ReflowVkSumiTab(AContentW: Integer);
const
  MARGIN   = 4;
  GAP      = 12;
  CARD_P   = 14;
  GB_PAD   = 8;
  LBL_W    = 100;
  ROW_H    = 32;
var
  CW, CardWidth, i: Integer;
  R0_H, R1_H: Integer;
  Col0_X: Integer;
  Card: TPanel;
  Sec: TPanel;
  CtrlIdx: Integer;
  ToneSec, BandSec, ColorSec, GainSec: TPanel;
  HalfW: Integer;
begin
  with FForm do
  begin
    if not Assigned(FVsCards[1]) then Exit;

  // Use AContentW (from FormResize) as primary source; fall back to scrollbox
  if AContentW > 0 then
    CW := AContentW
  else if Assigned(FVsScrollBox) then
    CW := FVsScrollBox.ClientWidth
  else
    CW := 800;

  if CW < 400 then CW := 400;

  // Find the sections dynamically by checking child trackbar tags
  ToneSec := nil;
  BandSec := nil;
  Card := FVsCards[1];
  for i := 0 to Card.ControlCount - 1 do
    if Card.Controls[i] is TPanel then
    begin
      Sec := TPanel(Card.Controls[i]);
      for CtrlIdx := 0 to Sec.ControlCount - 1 do
        if Sec.Controls[CtrlIdx] is TTrackBar then
        begin
          if TTrackBar(Sec.Controls[CtrlIdx]).Tag <= 3 then
            ToneSec := Sec
          else
            BandSec := Sec;
          Break;
        end;
    end;

  ColorSec := nil;
  GainSec := nil;
  Card := FVsCards[2];
  for i := 0 to Card.ControlCount - 1 do
    if Card.Controls[i] is TPanel then
    begin
      Sec := TPanel(Card.Controls[i]);
      for CtrlIdx := 0 to Sec.ControlCount - 1 do
        if Sec.Controls[CtrlIdx] is TTrackBar then
        begin
          if TTrackBar(Sec.Controls[CtrlIdx]).Tag <= 8 then
            ColorSec := Sec
          else
            GainSec := Sec;
          Break;
        end;
    end;

  // CardWidth is the full width of the tab sheet
  CardWidth := CW - 2 * MARGIN;
  Col0_X    := MARGIN;
  HalfW     := (CardWidth - 2 * CARD_P - GAP) div 2;

  // Set R0_H and R1_H based on the layout side-by-side (with card titles)
  R0_H := CARD_P + 30 + 160 + CARD_P; // 218
  R1_H := CARD_P + 30 + 192 + CARD_P; // 250

  // Position Card 1 and its sections side-by-side
  Card := FVsCards[1];
  Card.SetBounds(Col0_X, MARGIN, CardWidth, R0_H);
  if Assigned(ToneSec) then
    ToneSec.SetBounds(CARD_P, CARD_P + 30, HalfW, 160);
  if Assigned(BandSec) then
    BandSec.SetBounds(CARD_P + HalfW + GAP, CARD_P + 30, HalfW, 128);

  // Position Card 2 and its sections side-by-side
  Card := FVsCards[2];
  Card.SetBounds(Col0_X, MARGIN + R0_H + GAP, CardWidth, R1_H);
  if Assigned(ColorSec) then
    ColorSec.SetBounds(CARD_P, CARD_P + 30, HalfW, 192);
  if Assigned(GainSec) then
    GainSec.SetBounds(CARD_P + HalfW + GAP, CARD_P + 30, HalfW, 128);

  // Position Card 0 (Settings/Toggle card)
  if Assigned(FVsCards[0]) then
  begin
    FVsCards[0].Visible := True;
    FVsCards[0].SetBounds(Col0_X, MARGIN + R0_H + GAP + R1_H + GAP, CardWidth, 85);
    if Assigned(FVsRestoreBtn) then
      FVsRestoreBtn.Left := CardWidth - CARD_P - FVsRestoreBtn.Width;
  end;

  // Reflow sliders inside sections
  if Assigned(ToneSec) then
  begin
    ReflowSliderInSection(ToneSec, 0);
    ReflowSliderInSection(ToneSec, 1);
    ReflowSliderInSection(ToneSec, 2);
    ReflowSliderInSection(ToneSec, 3);
    ToneSec.Invalidate;
  end;
  if Assigned(BandSec) then
  begin
    ReflowSliderInSection(BandSec, 12);
    ReflowSliderInSection(BandSec, 13);
    ReflowSliderInSection(BandSec, 14);
    BandSec.Invalidate;
  end;
  if Assigned(ColorSec) then
  begin
    ReflowSliderInSection(ColorSec, 4);
    ReflowSliderInSection(ColorSec, 5);
    ReflowSliderInSection(ColorSec, 6);
    ReflowSliderInSection(ColorSec, 7);
    ReflowSliderInSection(ColorSec, 8);
    ColorSec.Invalidate;
  end;
  if Assigned(GainSec) then
  begin
    ReflowSliderInSection(GainSec, 9);
    ReflowSliderInSection(GainSec, 10);
    ReflowSliderInSection(GainSec, 11);
    GainSec.Invalidate;
  end;

  // Update scrollbox content dimensions
  if Assigned(FVsBgPanel) then
  begin
    FVsBgPanel.Width  := CW;
    FVsBgPanel.Height := MARGIN + R0_H + GAP + R1_H + GAP + 85 + MARGIN;
  end;
  end;
end;

procedure TVkBasaltTabHelper.VkSumiSliderChange(Sender: TObject);
var
  Idx: Integer;
  TB: TTrackBar;
  Val: Double;
  S: string;
begin
  with FForm do
  begin
    TB := Sender as TTrackBar;
    Idx := TB.Tag;
    case Idx of
      6: // Hue — degrees, -180..180
        Val := TB.Position - 180;
      2: // Exposure — -3..3
        Val := (TB.Position - 300) / 100;
      else // -1..1
        Val := (TB.Position - 100) / 100;
    end;
    S := FormatFloat('0.00', Val);
    if S = '-0.00' then S := '0.00';
    FVsValLabels[Idx].Caption := S;
    StartAutoSaveTimer;
  end;
end;

procedure TVkBasaltTabHelper.VsRestoreBtnClick(Sender: TObject);
var
  i: Integer;
begin
  with FForm do
  begin
    for i := 0 to 14 do
    begin
      if Assigned(FVsTrackbars[i]) then
      begin
        FVsTrackbars[i].Position := PARAMS[i].Default;
        VkSumiSliderChange(FVsTrackbars[i]);
      end;
    end;
    TriggerAutoSave;
  end;
end;

procedure TVkBasaltTabHelper.VkRestoreBtnClick(Sender: TObject);
begin
  with FForm do
  begin
    acteffectsListBox.Items.Clear;
    casTrackBar.Position := 0;
    fxaaTrackBar.Position := 0;
    smaaTrackBar.Position := 0;
    dlsTrackBar.Position := 0;
    casvalueLabel.Caption := '0';
    fxaavalueLabel.Caption := '0';
    smaavalueLabel.Caption := '0';
    dlsvalueLabel.Caption := '0';
    if Assigned(FVkCasValLbl) then FVkCasValLbl.Caption := '0';
    if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.Caption := '0';
    if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.Caption := '0';
    if Assigned(FVkDlsValLbl) then FVkDlsValLbl.Caption := '0';
    FVkPipelineScrollPos := 0;
    if Assigned(FVkPipelineSB) then
    begin
      FVkPipelineSB.Position := 0;
      FVkPipelineSB.Visible := False;
    end;
    if Assigned(FPipelineEffects) then FPipelineEffects.Clear;
    if Assigned(FVkPipelinePB) then FVkPipelinePB.Invalidate;
    if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;

    TriggerAutoSave;
    ShowStatusMessage('🔄 vkBasalt settings restored to defaults');
  end;
end;

procedure TVkBasaltTabHelper.reshaderefreshBitBtnClick(Sender: TObject);
var
  P: TProcess;
  Buf: array[0..8191] of byte;
  ReadCount: SizeInt;
  Chunk, Piece, S: string;
  Percent: Integer;
  Phase: string;
  GitHelper: TGit2Helper;
  Success: Boolean;
  OrigProgressBarParent, OrigLabelParent: TWinControl;
  OrigPBLeft, OrigPBTop, OrigPBWidth, OrigPBHeight: Integer;
  OrigPBAnchors: TAnchors;
  OrigLblLeft, OrigLblTop, OrigLblWidth, OrigLblHeight: Integer;
  OrigLblAnchors: TAnchors;

  function ExtractPercentAnywhere(const S: string; out Pct: Integer): Boolean;
  var
    i, j: Integer;
  begin
    // search for a number immediately before '%'
    Result := False;
    Pct := -1;
    for i := 1 to Length(S) do
      if S[i] = '%' then
      begin
        j := i - 1;
        while (j >= 1) and (S[j] in ['0'..'9']) do Dec(j);
        Inc(j);
        if (j <= i - 1) and TryStrToInt(Copy(S, j, i - j), Pct) then
        begin
          if Pct < 0 then Pct := 0;
          if Pct > 100 then Pct := 100;
          Exit(True);
        end;
      end;
  end;

  procedure UpdatePhase(const S: string);
  begin
    if Pos('Receiving objects', S) > 0 then Phase := 'Downloading';
    if Pos('Resolving deltas',   S) > 0 then Phase := 'Installing';
    if Pos('Checking out files', S) > 0 then Phase := 'Checking files';
  end;

  procedure ApplyPercent(Pct: Integer);
  begin
    if FForm.updateProgressBar.Min <> 0 then FForm.updateProgressBar.Min := 0;
    if FForm.updateProgressBar.Max <> 100 then FForm.updateProgressBar.Max := 100;
    FForm.updateProgressBar.Position := Pct;
    if FForm.FAutoDownloadingReshade then
      FForm.pbarLabel.Caption := Format('Downloading reshade shaders: %d%%', [Pct])
    else if Phase <> '' then
      FForm.pbarLabel.Caption := Format('%s: %d%%', [Phase, Pct])
    else
      FForm.pbarLabel.Caption := Format('%d%%', [Pct]);
    Application.ProcessMessages; // garante pintura imediata
  end;

  procedure ProcessPiecesFromChunk(var C: string);
  var
    pCR, pLF, pMin: SizeInt;
  begin
    // split by CR (\r) and LF (\n); git uses \r heavily for progress
    while True do
    begin
      pCR := Pos(#13, C);
      pLF := Pos(#10, C);
      if (pCR = 0) and (pLF = 0) then Break;

      if (pCR = 0) then pMin := pLF
      else if (pLF = 0) then pMin := pCR
      else pMin := IfThen(pCR < pLF, pCR, pLF);

      Piece := Copy(C, 1, pMin - 1);
      Delete(C, 1, pMin);
      // if it was CRLF, remove remaining LF
      if (pMin = 1) and (Length(C) > 0) and ((C[1] = #10) or (C[1] = #13)) then
        Delete(C, 1, 1);

      UpdatePhase(Piece);
      if ExtractPercentAnywhere(Piece, Percent) then
        ApplyPercent(Percent);
    end;

    // also try to extract percent from what's left (partial line)
    if (C <> '') and ExtractPercentAnywhere(C, Percent) then
      ApplyPercent(Percent);
  end;

  procedure StartGit(const AParams: array of string; const AWorkDir: string);
  var
    i: Integer;
  begin
    P := TProcess.Create(nil);
    P.Executable := FindDefaultExecutablePath('git');
    for i := 0 to High(AParams) do
      P.Parameters.Add(AParams[i]);
    P.CurrentDirectory := AWorkDir;

    // merge stderr->stdout and use pipes
    P.Options := [poUsePipes, poStderrToOutPut, poNoConsole];

    // force immediate progress
    P.Environment.Add('GIT_PROGRESS_DELAY=0');
    P.Environment.Add('GIT_FLUSH=1');

    P.Execute;
  end;

  procedure PumpOutput;
  begin
    if P.Output.NumBytesAvailable > 0 then
    begin
      ReadCount := P.Output.Read(Buf{%H-}, SizeOf(Buf));
      if ReadCount > 0 then
      begin
        SetString(S, PChar(@Buf[0]), ReadCount);
        Chunk := Chunk + S;
        ProcessPiecesFromChunk(Chunk);
      end;
    end;
  end;

begin
  with FForm do
  begin
    //Disable update button
    reshaderefreshBitbtn.Enabled := False;
    if Assigned(FVkReshadeSyncBtn) then FVkReshadeSyncBtn.Enabled := False;

    if VKBASALTFOLDER = '' then
    begin
      ShowMessage(rsVkBasaltDirMissing);
      Exit;
    end;

    RepoDir := IncludeTrailingPathDelimiter(VKBASALTFOLDER) + 'reshade-shaders';

    // Backup original parent and bounds
    OrigProgressBarParent := updateProgressBar.Parent;
    OrigLabelParent := pbarLabel.Parent;
    OrigPBLeft := updateProgressBar.Left;
    OrigPBTop := updateProgressBar.Top;
    OrigPBWidth := updateProgressBar.Width;
    OrigPBHeight := updateProgressBar.Height;
    OrigPBAnchors := updateProgressBar.Anchors;
    
    OrigLblLeft := pbarLabel.Left;
    OrigLblTop := pbarLabel.Top;
    OrigLblWidth := pbarLabel.Width;
    OrigLblHeight := pbarLabel.Height;
    OrigLblAnchors := pbarLabel.Anchors;

    try
      if goverlayPageControl.ActivePage = vkbasaltTabSheet then
      begin
        if Assigned(FVkToggleCaptureBtn) then FVkToggleCaptureBtn.Visible := False;
        if Assigned(FVkReshadeSyncBtn) then FVkReshadeSyncBtn.Visible := False;

        updateProgressBar.Parent := FVkToggleCard;
        updateProgressBar.Anchors := [akLeft, akTop, akRight];
        updateProgressBar.SetBounds(12, 40, FVkToggleCard.Width - 24, 20);

        pbarLabel.Parent := FVkToggleCard;
        pbarLabel.Anchors := [akLeft, akTop, akRight];
        pbarLabel.SetBounds(12, 12, FVkToggleCard.Width - 24, 20);
        pbarLabel.Font.Color := clWhite;
        pbarLabel.Visible := True;
      end;

      // Show progress bar
      updateProgressBar.Visible := True;
      updateProgressBar.Min := 0;
      updateProgressBar.Max := 100;
      updateProgressBar.Position := 0;
      
      if FAutoDownloadingReshade then
        pbarLabel.Caption := 'Downloading reshade shaders...'
      else
        pbarLabel.Caption := 'Starting...';
        
      Phase := '';
      Chunk := '';

      // Setup progress bar and label references for callback
      FReshadeProgressBar := updateProgressBar;
      FReshadePhaseLabel := pbarLabel;

      // Try libgit2 first (Flatpak-compatible), fallback to git command
      Success := False;
      if TGit2Helper.IsLibGit2Available then
      begin
        // Use libgit2 for git operations (no external dependencies)
        try
          GitHelper := TGit2Helper.Create;
          try
            // Setup progress callback
            GitHelper.OnProgress := @ReshadeGitProgress;

            // Clone or pull repository
            if DirectoryExists(RepoDir) then
            begin
              pbarLabel.Caption := 'Updating repository...';
              Success := GitHelper.Pull(RepoDir);
            end
            else
            begin
              pbarLabel.Caption := 'Cloning repository...';
              Success := GitHelper.Clone(URL_RESHADE_SHADERS_REPO, RepoDir);
            end;

            if Success then
            begin
              ApplyPercent(100);
              pbarLabel.Caption := 'Completed';
              SendNotification('Goverlay', 'Reshade shaders are ready', GetIconFile);
            end;

          finally
            GitHelper.Free;
          end;
        except
          on E: Exception do
          begin
            // libgit2 failed, will fallback to external git
            Success := False;
          end;
        end;
      end;

      // Fallback to external git command if libgit2 failed or unavailable
      if not Success then
      begin
        // Fallback to external git command
        try
          if DirectoryExists(RepoDir) then
            StartGit(['-C', 'reshade-shaders', 'pull', '--progress'], VKBASALTFOLDER)
          else
            StartGit(['clone', '--progress', URL_RESHADE_SHADERS_REPO], VKBASALTFOLDER);
          while P.Running do
          begin
            PumpOutput;
            Application.ProcessMessages; // keep UI alive and repaint the bar
          end;

          // drain remaining output after exit
          PumpOutput;

          if P.ExitStatus = 0 then
          begin
            ApplyPercent(100);
            pbarLabel.Caption := 'Completed';
            SendNotification('Goverlay', 'Reshade shaders are ready', GetIconFile);
          end
          else
            ShowMessage(Format(rsReshadeSyncFailed, [P.ExitStatus]));
        finally
          if Assigned(P) then P.Free;
        end;
      end;

      // List ALL repository files:
      ListFilesToListBox(RepoDir, aveffectsListbox, ['.fx', '.fxh', '.h', '.glsl']);
      if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;

      //Enable elements
      aveffectsListbox.Enabled:=true;
      acteffectsListbox.Enabled:=true;
      addBitbtn.Enabled:=true;
      subBitbtn.Enabled:=true;

      // Hide progress bar
      updateProgressBar.Visible := False;

    finally
      // Restore parent and visibility
      updateProgressBar.Parent := OrigProgressBarParent;
      pbarLabel.Parent := OrigLabelParent;
      
      updateProgressBar.Anchors := OrigPBAnchors;
      updateProgressBar.SetBounds(OrigPBLeft, OrigPBTop, OrigPBWidth, OrigPBHeight);
      
      pbarLabel.Anchors := OrigLblAnchors;
      pbarLabel.SetBounds(OrigLblLeft, OrigLblTop, OrigLblWidth, OrigLblHeight);
      pbarLabel.Visible := False;

      // Enable update button
      reshaderefreshBitbtn.Enabled := True;
      if Assigned(FVkReshadeSyncBtn) then
      begin
        FVkReshadeSyncBtn.Enabled := True;
        FVkReshadeSyncBtn.Visible := True;
      end;
      if Assigned(FVkToggleCaptureBtn) then
        FVkToggleCaptureBtn.Visible := True;
        
      if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkReshadeMD3Paint(Sender: TObject);
  procedure DrawToggle(ACanvas: TCanvas; AX, AY: Integer; AOn: Boolean);
  var
    TrackColor: TColor;
    ThumbLeft, ThumbTop, ThumbRight, ThumbBottom: Integer;
  const
    TRACK_W = 44;
    TRACK_H = 24;
    THUMB_D = 18;
    RADIUS  = 12;
    Pad     = 3;
  begin
    // Track colour
    if AOn then
      TrackColor := RGBToColor(60, 180, 80)   // green
    else
      TrackColor := RGBToColor(70, 70, 70);   // grey

    ACanvas.Brush.Color := TrackColor;
    ACanvas.Pen.Color   := TrackColor;
    ACanvas.Pen.Width   := 1;

    // Central rectangle
    ACanvas.FillRect(AX + RADIUS, AY, AX + TRACK_W - RADIUS, AY + TRACK_H);

    // Left cap (semi-circle)
    ACanvas.Ellipse(AX, AY, AX + RADIUS * 2, AY + TRACK_H);

    // Right cap (semi-circle)
    ACanvas.Ellipse(AX + TRACK_W - RADIUS * 2, AY, AX + TRACK_W, AY + TRACK_H);

    // Thumb
    if AOn then
      ThumbLeft := AX + TRACK_W - THUMB_D - Pad
    else
      ThumbLeft := AX + Pad;
    ThumbTop    := AY + (TRACK_H - THUMB_D) div 2;
    ThumbRight  := ThumbLeft + THUMB_D;
    ThumbBottom := ThumbTop + THUMB_D;

    // Subtle outer ring/shadow
    ACanvas.Brush.Color := RGBToColor(200, 200, 200);
    ACanvas.Pen.Color   := RGBToColor(160, 160, 160);
    ACanvas.Pen.Width   := 1;
    ACanvas.Ellipse(ThumbLeft, ThumbTop, ThumbRight, ThumbBottom);

    // White thumb body
    ACanvas.Brush.Color := clWhite;
    ACanvas.Pen.Color   := clWhite;
    ACanvas.Pen.Width   := 1;
    ACanvas.Ellipse(ThumbLeft + 2, ThumbTop + 2, ThumbRight - 2, ThumbBottom - 2);
  end;

var
  PB: TPaintBox;
  Y, ItemH, i: Integer;
  R: TRect;
  EffectName: string;
  IsActive, Is2Col: Boolean;
  ColWidth, Col, ItemX, ItemW, ItemCount: Integer;
begin
  with FForm do
  begin
    PB := Sender as TPaintBox;
    PB.Canvas.Brush.Color := RGBToColor(22, 25, 37);
    PB.Canvas.FillRect(PB.ClientRect);

    ItemH := 44;
    Y := -FVkReshadeScrollPos;
    Is2Col := PB.Width >= 500;
    ColWidth := PB.Width div 2;
    ItemCount := aveffectsListBox.Items.Count;

    for i := 0 to ItemCount - 1 do
    begin
      if Is2Col then
      begin
        Col := i mod 2;
        if Col = 0 then
        begin
          ItemX := 0;
          ItemW := ColWidth;
        end
        else
        begin
          ItemX := ColWidth;
          ItemW := PB.Width - ColWidth;
        end;
        R := Rect(ItemX, Y, ItemX + ItemW, Y + ItemH);
      end
      else
        R := Rect(0, Y, PB.Width, Y + ItemH);

      // Determine if this effect is active
      IsActive := acteffectsListBox.Items.IndexOf(aveffectsListBox.Items[i]) >= 0;

      // Background
      if IsActive then
        PB.Canvas.Brush.Color := RGBToColor(30, 50, 80)
      else if FVkReshadeHoverIdx = i then
        PB.Canvas.Brush.Color := RGBToColor(50, 55, 70)
      else
        PB.Canvas.Brush.Color := RGBToColor(22, 25, 37);
      PB.Canvas.FillRect(R);

      // Bottom separator
      PB.Canvas.Pen.Color := RGBToColor(40, 45, 60);
      PB.Canvas.Line(R.Left, R.Bottom - 1, R.Right, R.Bottom - 1);

      // Right vertical divider between columns
      if Is2Col and (Col = 0) then
        PB.Canvas.Line(R.Right - 1, R.Top, R.Right - 1, R.Bottom - 1);

      // Toggle (right side)
      DrawToggle(PB.Canvas, R.Right - 60, R.Top + (R.Height - 24) div 2, IsActive);

      // Effect name (friendly basename without extension)
      EffectName := ChangeFileExt(ExtractFileName(aveffectsListBox.Items[i]), '');
      PB.Canvas.Brush.Style := bsClear;  // prevent TextOut from filling background
      PB.Canvas.Font.Name  := 'DejaVu Sans';
      PB.Canvas.Font.Size  := 9;
      PB.Canvas.Font.Style := [];
      PB.Canvas.Font.Color := clWhite;
      PB.Canvas.TextOut(R.Left + 16, R.Top + (R.Height - PB.Canvas.TextHeight(EffectName)) div 2, EffectName);

      if Is2Col then
      begin
        if Col = 1 then
          Inc(Y, ItemH);
      end
      else
        Inc(Y, ItemH);
    end;

    if Is2Col and (ItemCount mod 2 = 1) then
      Inc(Y, ItemH);

    // Update scrollbar
    if Y + FVkReshadeScrollPos > PB.Height then
    begin
      FVkReshadeSB.Max := Y + FVkReshadeScrollPos - PB.Height + 20;
      FVkReshadeSB.PageSize := 1;
      FVkReshadeSB.Visible := True;
    end
    else
    begin
      FVkReshadeSB.Visible := False;
      FVkReshadeScrollPos := 0;
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkReshadeMD3MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  OldHover, ItemH, i: Integer;
  YPos, ColWidth, Col, ItemX, ItemW, ItemCount: Integer;
  Is2Col: Boolean;
begin
  with FForm do
  begin
    PB := Sender as TPaintBox;
    OldHover := FVkReshadeHoverIdx;
    FVkReshadeHoverIdx := -1;

    ItemH := 44;
    YPos := -FVkReshadeScrollPos;
    Is2Col := PB.Width >= 500;
    ColWidth := PB.Width div 2;
    ItemCount := aveffectsListBox.Items.Count;

    for i := 0 to ItemCount - 1 do
    begin
      if Is2Col then
      begin
        Col := i mod 2;
        if Col = 0 then begin ItemX := 0; ItemW := ColWidth; end
        else begin ItemX := ColWidth; ItemW := PB.Width - ColWidth; end;

        if (X >= ItemX) and (X < ItemX + ItemW) and (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FVkReshadeHoverIdx := i;
          Break;
        end;
        if Col = 1 then Inc(YPos, ItemH);
      end
      else
      begin
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          FVkReshadeHoverIdx := i;
          Break;
        end;
        Inc(YPos, ItemH);
      end;
    end;

    if OldHover <> FVkReshadeHoverIdx then
      PB.Invalidate;
  end;
end;

procedure TVkBasaltTabHelper.VkReshadeMD3MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  ItemH, i: Integer;
  YPos, ColWidth, Col, ItemX, ItemW, ItemCount: Integer;
  ToggleX: Integer;
  EffectPath: string;
  Is2Col: Boolean;
begin
  with FForm do
  begin
    if Button <> mbLeft then Exit;
    PB := Sender as TPaintBox;
    ItemH := 44;
    YPos := -FVkReshadeScrollPos;
    Is2Col := PB.Width >= 500;
    ColWidth := PB.Width div 2;
    ItemCount := aveffectsListBox.Items.Count;

    for i := 0 to ItemCount - 1 do
    begin
      if Is2Col then
      begin
        Col := i mod 2;
        if Col = 0 then begin ItemX := 0; ItemW := ColWidth; end
        else begin ItemX := ColWidth; ItemW := PB.Width - ColWidth; end;

        if (X >= ItemX) and (X < ItemX + ItemW) and (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          ToggleX := ItemX + ItemW - 60;
          if X >= ToggleX then
          begin
            EffectPath := aveffectsListBox.Items[i];
            if acteffectsListBox.Items.IndexOf(EffectPath) >= 0 then
            begin
              acteffectsListBox.Items.Delete(acteffectsListBox.Items.IndexOf(EffectPath));
              RemoveEffectFromPipeline(ChangeFileExt(ExtractFileName(EffectPath), ''));
            end
            else
            begin
              acteffectsListBox.Items.Add(EffectPath);
              AddEffectToPipeline(ChangeFileExt(ExtractFileName(EffectPath), ''));
            end;
            PB.Invalidate;
            TriggerAutoSave;
          end;
          Exit;
        end;
        if Col = 1 then Inc(YPos, ItemH);
      end
      else
      begin
        if (Y >= YPos) and (Y < YPos + ItemH) then
        begin
          // Check if click is on toggle (right side)
          ToggleX := PB.Width - 60;
          if X >= ToggleX then
          begin
            EffectPath := aveffectsListBox.Items[i];
            if acteffectsListBox.Items.IndexOf(EffectPath) >= 0 then
            begin
              acteffectsListBox.Items.Delete(acteffectsListBox.Items.IndexOf(EffectPath));
              RemoveEffectFromPipeline(ChangeFileExt(ExtractFileName(EffectPath), ''));
            end
            else
            begin
              acteffectsListBox.Items.Add(EffectPath);
              AddEffectToPipeline(ChangeFileExt(ExtractFileName(EffectPath), ''));
            end;
            PB.Invalidate;
            TriggerAutoSave;
          end;
          Exit;
        end;
        Inc(YPos, ItemH);
      end;
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkReshadeMD3MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  MaxScroll: Integer;
begin
  with FForm do
  begin
    if not FVkReshadeSB.Visible then Exit;
    MaxScroll := FVkReshadeSB.Max;
    FVkReshadeScrollPos := FVkReshadeScrollPos - WheelDelta div 4;
    if FVkReshadeScrollPos < 0 then FVkReshadeScrollPos := 0;
    if FVkReshadeScrollPos > MaxScroll then FVkReshadeScrollPos := MaxScroll;
    FVkReshadeSB.Position := FVkReshadeScrollPos;
    if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;
    Handled := True;
  end;
end;

procedure TVkBasaltTabHelper.VkReshadeMD3ScrollChange(Sender: TObject);
begin
  with FForm do
  begin
    FVkReshadeScrollPos := FVkReshadeSB.Position;
    if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;
  end;
end;

// ============================================================================
// EFFECT PIPELINE CARD RENDERING & INTERACTIONS
// ============================================================================

procedure TVkBasaltTabHelper.VkPipelineCardPaint(Sender: TObject);
var
  PB: TPaintBox;
  i, CurX, ChipW, ChipH, TotalChips, TotalW: Integer;
  LeftPad, TextW, TextH: Integer;
  EffName, DispName: string;
  ChipBg, ChipBorder, DotColor: TColor;
  R: TRect;
  HasLeft, HasRight: Boolean;
  BtnW: Integer;
begin
  with FForm do
  begin
    PB := Sender as TPaintBox;
    if not Assigned(FPipelineEffects) then Exit;

    PB.Canvas.Brush.Color := FVkPipelineCard.Color;
    PB.Canvas.FillRect(0, 0, PB.Width, PB.Height);

    TotalChips := FPipelineEffects.Count;
    if TotalChips = 0 then
    begin
      PB.Canvas.Font.Name := 'DejaVu Sans';
      PB.Canvas.Font.Size := 9;
      PB.Canvas.Font.Style := [fsItalic];
      PB.Canvas.Font.Color := RGBToColor(110, 115, 130);
      PB.Canvas.Brush.Style := bsClear;
      PB.Canvas.TextOut(6, (PB.Height - PB.Canvas.TextHeight('A')) div 2,
        'No active effects. Enable built-in sliders or ReShade shaders above to build the pipeline.');
      SetLength(FChipHits, 0);
      if Assigned(FVkPipelineSB) then
      begin
        FVkPipelineSB.Visible := False;
        FVkPipelineScrollPos := 0;
      end;
      Exit;
    end;

    SetLength(FChipHits, TotalChips);
    ChipH := 26;
    BtnW := 14;

    // Calculate total required width
    TotalW := 4;
    for i := 0 to TotalChips - 1 do
    begin
      EffName := FPipelineEffects[i];
      if SameText(EffName, 'smaa') or SameText(EffName, 'fxaa') or SameText(EffName, 'cas') or SameText(EffName, 'dls') then
        DispName := UpperCase(EffName)
      else
        DispName := EffName;

      PB.Canvas.Font.Name := 'DejaVu Sans';
      PB.Canvas.Font.Size := 9;
      PB.Canvas.Font.Style := [fsBold];
      TextW := PB.Canvas.TextWidth(DispName);

      ChipW := 6 + 8 + 5 + TextW + 6 + BtnW + 6;
      if i > 0 then Inc(ChipW, BtnW + 2);
      if i < TotalChips - 1 then Inc(ChipW, BtnW + 2);

      Inc(TotalW, ChipW + 6);
      if i < TotalChips - 1 then
        Inc(TotalW, 22);
    end;

    // Update horizontal scrollbar
    if Assigned(FVkPipelineSB) then
    begin
      if TotalW > PB.Width then
      begin
        FVkPipelineSB.Max := TotalW - PB.Width + 10;
        FVkPipelineSB.PageSize := 1;
        FVkPipelineSB.Visible := True;
        if FVkPipelineScrollPos > FVkPipelineSB.Max then
          FVkPipelineScrollPos := FVkPipelineSB.Max;
      end
      else
      begin
        FVkPipelineSB.Visible := False;
        FVkPipelineScrollPos := 0;
      end;
      if FVkPipelineScrollPos < 0 then
        FVkPipelineScrollPos := 0;
      FVkPipelineSB.Position := FVkPipelineScrollPos;
    end;

    CurX := 4 - FVkPipelineScrollPos;

    for i := 0 to TotalChips - 1 do
    begin
      EffName := FPipelineEffects[i];
      HasLeft := (i > 0);
      HasRight := (i < TotalChips - 1);

      // Determine category colors
      if SameText(EffName, 'smaa') or SameText(EffName, 'fxaa') then
      begin
        ChipBg     := RGBToColor(18, 42, 32);
        ChipBorder := RGBToColor(25, 120, 85);
        DotColor   := RGBToColor(16, 185, 129); // emerald green
        DispName   := UpperCase(EffName);
      end
      else if SameText(EffName, 'cas') or SameText(EffName, 'dls') then
      begin
        ChipBg     := RGBToColor(16, 36, 48);
        ChipBorder := RGBToColor(14, 110, 135);
        DotColor   := RGBToColor(6, 182, 212);  // cyan/blue
        DispName   := UpperCase(EffName);
      end
      else
      begin
        ChipBg     := RGBToColor(36, 20, 48);
        ChipBorder := RGBToColor(115, 55, 165);
        DotColor   := RGBToColor(168, 85, 247); // purple
        DispName   := EffName;
      end;

      PB.Canvas.Font.Name := 'DejaVu Sans';
      PB.Canvas.Font.Size := 9;
      PB.Canvas.Font.Style := [fsBold];
      TextW := PB.Canvas.TextWidth(DispName);
      TextH := PB.Canvas.TextHeight(DispName);

      ChipW := 6 + 8 + 5 + TextW + 6 + BtnW + 6;
      if HasLeft then Inc(ChipW, BtnW + 2);
      if HasRight then Inc(ChipW, BtnW + 2);

      R := Rect(CurX, (PB.Height - ChipH) div 2, CurX + ChipW, (PB.Height - ChipH) div 2 + ChipH);
      FChipHits[i].Rect := R;

      // Draw Chip Background & Rounded Outline
      PB.Canvas.Brush.Color := ChipBg;
      PB.Canvas.Pen.Color   := ChipBorder;
      PB.Canvas.Pen.Width   := 1;
      PB.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);

      LeftPad := R.Left + 6;

      // Left move button
      if HasLeft then
      begin
        FChipHits[i].LeftBtnRect := Rect(LeftPad, R.Top + 3, LeftPad + BtnW, R.Bottom - 3);
        PB.Canvas.Font.Size := 6;
        PB.Canvas.Font.Style := [fsBold];
        if (FHoverChipIdx = i) and (FHoverBtn = phbLeft) then
          PB.Canvas.Font.Color := clWhite
        else
          PB.Canvas.Font.Color := RGBToColor(140, 150, 170);
        PB.Canvas.Brush.Style := bsClear;
        PB.Canvas.TextOut(LeftPad + 2, R.Top + (ChipH - PB.Canvas.TextHeight('❮')) div 2, '❮');
        Inc(LeftPad, BtnW + 2);
      end
      else
        FChipHits[i].LeftBtnRect := Rect(0, 0, 0, 0);

      // Category Dot
      PB.Canvas.Brush.Color := DotColor;
      PB.Canvas.Pen.Color   := DotColor;
      PB.Canvas.Ellipse(LeftPad, R.Top + (ChipH - 6) div 2, LeftPad + 6, R.Top + (ChipH - 6) div 2 + 6);
      Inc(LeftPad, 6 + 5);

      // Name
      PB.Canvas.Font.Size := 9;
      PB.Canvas.Font.Style := [fsBold];
      PB.Canvas.Font.Color := clWhite;
      PB.Canvas.Brush.Style := bsClear;
      PB.Canvas.TextOut(LeftPad, R.Top + (ChipH - TextH) div 2, DispName);
      Inc(LeftPad, TextW + 6);

      // Right move button
      if HasRight then
      begin
        FChipHits[i].RightBtnRect := Rect(LeftPad, R.Top + 3, LeftPad + BtnW, R.Bottom - 3);
        PB.Canvas.Font.Size := 6;
        PB.Canvas.Font.Style := [fsBold];
        if (FHoverChipIdx = i) and (FHoverBtn = phbRight) then
          PB.Canvas.Font.Color := clWhite
        else
          PB.Canvas.Font.Color := RGBToColor(140, 150, 170);
        PB.Canvas.Brush.Style := bsClear;
        PB.Canvas.TextOut(LeftPad + 2, R.Top + (ChipH - PB.Canvas.TextHeight('❯')) div 2, '❯');
        Inc(LeftPad, BtnW + 2);
      end
      else
        FChipHits[i].RightBtnRect := Rect(0, 0, 0, 0);

      // Close button (✕)
      FChipHits[i].CloseBtnRect := Rect(LeftPad, R.Top + 3, LeftPad + BtnW, R.Bottom - 3);
      PB.Canvas.Font.Size := 8;
      PB.Canvas.Font.Style := [fsBold];
      if (FHoverChipIdx = i) and (FHoverBtn = phbClose) then
        PB.Canvas.Font.Color := RGBToColor(255, 80, 80)
      else
        PB.Canvas.Font.Color := RGBToColor(200, 90, 90);
      PB.Canvas.Brush.Style := bsClear;
      PB.Canvas.TextOut(LeftPad + 2, R.Top + (ChipH - PB.Canvas.TextHeight('✕')) div 2, '✕');

      // Advance X
      CurX := R.Right + 6;

      // Draw Larger Connector Arrow to Next Chip
      if i < TotalChips - 1 then
      begin
        PB.Canvas.Font.Size := 13;
        PB.Canvas.Font.Style := [fsBold];
        PB.Canvas.Font.Color := RGBToColor(130, 145, 175);
        PB.Canvas.Brush.Style := bsClear;
        PB.Canvas.TextOut(CurX + 2, R.Top + (ChipH - PB.Canvas.TextHeight('→')) div 2, '→');
        Inc(CurX, 22);
      end;
    end;

    // If dragging, draw insertion indicator line
    if (FDragIdx >= 0) and (FDragIdx < Length(FChipHits)) then
    begin
      PB.Canvas.Pen.Color := RGBToColor(59, 130, 246); // bright blue
      PB.Canvas.Pen.Width := 2;
      PB.Canvas.Line(FDragCurrentX, (PB.Height - ChipH) div 2 - 2, FDragCurrentX, (PB.Height - ChipH) div 2 + ChipH + 2);
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkPipelineCardMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  if Button <> mbLeft then Exit;
  for i := 0 to High(FChipHits) do
  begin
    if PtInRect(FChipHits[i].CloseBtnRect, Point(X, Y)) then
    begin
      DisablePipelineEffect(FForm.FPipelineEffects[i]);
      Exit;
    end;
    if PtInRect(FChipHits[i].LeftBtnRect, Point(X, Y)) then
    begin
      MovePipelineEffect(i, i - 1);
      Exit;
    end;
    if PtInRect(FChipHits[i].RightBtnRect, Point(X, Y)) then
    begin
      MovePipelineEffect(i, i + 1);
      Exit;
    end;
    if PtInRect(FChipHits[i].Rect, Point(X, Y)) then
    begin
      FDragIdx := i;
      FDragStartX := X;
      FDragCurrentX := X;
      Exit;
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkPipelineCardMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  i: Integer;
  OldHoverIdx, NewHoverIdx: Integer;
  OldHoverBtn, NewHoverBtn: TPipelineHoverBtn;
begin
  with FForm do
  begin
    PB := Sender as TPaintBox;

    if FDragIdx >= 0 then
    begin
      FDragCurrentX := X;

      // Auto-scroll when dragging near left or right borders
      if Assigned(FVkPipelineSB) and FVkPipelineSB.Visible then
      begin
        if (X < 30) and (FVkPipelineScrollPos > 0) then
        begin
          Dec(FVkPipelineScrollPos, 15);
          if FVkPipelineScrollPos < 0 then FVkPipelineScrollPos := 0;
          FVkPipelineSB.Position := FVkPipelineScrollPos;
        end
        else if (X > PB.Width - 30) and (FVkPipelineScrollPos < FVkPipelineSB.Max) then
        begin
          Inc(FVkPipelineScrollPos, 15);
          if FVkPipelineScrollPos > FVkPipelineSB.Max then FVkPipelineScrollPos := FVkPipelineSB.Max;
          FVkPipelineSB.Position := FVkPipelineScrollPos;
        end;
      end;

      PB.Cursor := crSizeWE;
      PB.Invalidate;
      Exit;
    end;

    // Detect hover over buttons
    OldHoverIdx := FHoverChipIdx;
    OldHoverBtn := FHoverBtn;
    NewHoverIdx := -1;
    NewHoverBtn := phbNone;

    for i := 0 to High(FChipHits) do
    begin
      if PtInRect(FChipHits[i].CloseBtnRect, Point(X, Y)) then
      begin
        NewHoverIdx := i;
        NewHoverBtn := phbClose;
        Break;
      end
      else if PtInRect(FChipHits[i].LeftBtnRect, Point(X, Y)) then
      begin
        NewHoverIdx := i;
        NewHoverBtn := phbLeft;
        Break;
      end
      else if PtInRect(FChipHits[i].RightBtnRect, Point(X, Y)) then
      begin
        NewHoverIdx := i;
        NewHoverBtn := phbRight;
        Break;
      end
      else if PtInRect(FChipHits[i].Rect, Point(X, Y)) then
      begin
        NewHoverIdx := i;
        NewHoverBtn := phbChip;
        Break;
      end;
    end;

    if (NewHoverIdx <> OldHoverIdx) or (NewHoverBtn <> OldHoverBtn) then
    begin
      FHoverChipIdx := NewHoverIdx;
      FHoverBtn := NewHoverBtn;
      if NewHoverBtn in [phbLeft, phbRight, phbClose] then
        PB.Cursor := crHandPoint
      else
        PB.Cursor := crDefault;

      PB.Invalidate;
    end;
  end;
end;

procedure TVkBasaltTabHelper.VkPipelineCardMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PB: TPaintBox;
  i, TargetIdx, MidX: Integer;
begin
  if Button <> mbLeft then Exit;
  PB := Sender as TPaintBox;

  if FDragIdx >= 0 then
  begin
    TargetIdx := FDragIdx;
    for i := 0 to High(FChipHits) do
    begin
      MidX := (FChipHits[i].Rect.Left + FChipHits[i].Rect.Right) div 2;
      if (i < FDragIdx) and (X < MidX) then
      begin
        TargetIdx := i;
        Break;
      end
      else if (i > FDragIdx) and (X > MidX) then
        TargetIdx := i;
    end;

    if (TargetIdx >= 0) and (TargetIdx < FForm.FPipelineEffects.Count) and (TargetIdx <> FDragIdx) then
      MovePipelineEffect(FDragIdx, TargetIdx);

    FDragIdx := -1;
    PB.Cursor := crDefault;
    PB.Invalidate;
  end;
end;

procedure TVkBasaltTabHelper.VkPipelineCardMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  MaxScroll: Integer;
begin
  with FForm do
  begin
    if not Assigned(FVkPipelineSB) or not FVkPipelineSB.Visible then Exit;
    MaxScroll := FVkPipelineSB.Max;
    FVkPipelineScrollPos := FVkPipelineScrollPos - WheelDelta div 3;
    if FVkPipelineScrollPos < 0 then FVkPipelineScrollPos := 0;
    if FVkPipelineScrollPos > MaxScroll then FVkPipelineScrollPos := MaxScroll;
    FVkPipelineSB.Position := FVkPipelineScrollPos;
    if Assigned(FVkPipelinePB) then FVkPipelinePB.Invalidate;
    Handled := True;
  end;
end;

procedure TVkBasaltTabHelper.VkPipelineScrollChange(Sender: TObject);
begin
  with FForm do
  begin
    FVkPipelineScrollPos := FVkPipelineSB.Position;
    if Assigned(FVkPipelinePB) then FVkPipelinePB.Invalidate;
  end;
end;

procedure TVkBasaltTabHelper.AddEffectToPipeline(const AEffectName: string);
begin
  if not Assigned(FForm.FPipelineEffects) then
    FForm.FPipelineEffects := TStringList.Create;
  if FForm.FPipelineEffects.IndexOf(AEffectName) = -1 then
  begin
    FForm.FPipelineEffects.Add(AEffectName);
    if Assigned(FForm.FVkPipelineSB) and FForm.FVkPipelineSB.Visible then
      FForm.FVkPipelineScrollPos := FForm.FVkPipelineSB.Max;
    if Assigned(FForm.FVkPipelinePB) then
      FForm.FVkPipelinePB.Invalidate;
    FForm.StartAutoSaveTimer;
  end;
end;

procedure TVkBasaltTabHelper.RemoveEffectFromPipeline(const AEffectName: string);
var
  Idx: Integer;
begin
  if not Assigned(FForm.FPipelineEffects) then Exit;
  Idx := FForm.FPipelineEffects.IndexOf(AEffectName);
  if Idx >= 0 then
  begin
    FForm.FPipelineEffects.Delete(Idx);
    if Assigned(FForm.FVkPipelinePB) then
      FForm.FVkPipelinePB.Invalidate;
    FForm.StartAutoSaveTimer;
  end;
end;

procedure TVkBasaltTabHelper.DisablePipelineEffect(const AEffectName: string);
var
  i: Integer;
begin
  with FForm do
  begin
    if SameText(AEffectName, 'cas') then
    begin
      casTrackBar.Position := 0;
      casvaluelabel.Caption := '0';
      if Assigned(FVkCasValLbl) then FVkCasValLbl.Caption := '0';
    end
    else if SameText(AEffectName, 'fxaa') then
    begin
      fxaaTrackBar.Position := 0;
      fxaavaluelabel.Caption := '0';
      if Assigned(FVkFxaaValLbl) then FVkFxaaValLbl.Caption := '0';
    end
    else if SameText(AEffectName, 'smaa') then
    begin
      smaaTrackBar.Position := 0;
      smaavaluelabel.Caption := '0';
      if Assigned(FVkSmaaValLbl) then FVkSmaaValLbl.Caption := '0';
    end
    else if SameText(AEffectName, 'dls') then
    begin
      dlsTrackBar.Position := 0;
      dlsvaluelabel.Caption := '0';
      if Assigned(FVkDlsValLbl) then FVkDlsValLbl.Caption := '0';
    end
    else
    begin
      for i := acteffectsListBox.Items.Count - 1 downto 0 do
      begin
        if SameText(ChangeFileExt(ExtractFileName(acteffectsListBox.Items[i]), ''), AEffectName) then
          acteffectsListBox.Items.Delete(i);
      end;
      if Assigned(FVkReshadePB) then FVkReshadePB.Invalidate;
    end;
  end;
  RemoveEffectFromPipeline(AEffectName);
end;

procedure TVkBasaltTabHelper.MovePipelineEffect(FromIdx, ToIdx: Integer);
begin
  if not Assigned(FForm.FPipelineEffects) then Exit;
  if (FromIdx >= 0) and (FromIdx < FForm.FPipelineEffects.Count) and
     (ToIdx >= 0) and (ToIdx < FForm.FPipelineEffects.Count) and (FromIdx <> ToIdx) then
  begin
    FForm.FPipelineEffects.Move(FromIdx, ToIdx);
    if Assigned(FForm.FVkPipelinePB) then
      FForm.FVkPipelinePB.Invalidate;
    FForm.StartAutoSaveTimer;
  end;
end;

end.
