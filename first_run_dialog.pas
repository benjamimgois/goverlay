unit first_run_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, Types, configmanager, toggle_switch;

type
  TSetupCardRec = record
    Panel: TPanel;
    Check: TCheckBox;
    Toggle: TToggleSwitch;
    TitleLbl: TLabel;
    DescLbl: TLabel;
    IsCore: Boolean;
    Hovered: Boolean;
    CategoryIdx: Integer;
  end;

  TCategoryHeaderRec = record
    Panel: TPanel;
    Title: string;
    CategoryIdx: Integer;
  end;

  { TFirstRunSetupDialog }
  TFirstRunSetupDialog = class(TForm)
  private
    FIsFirstRun: Boolean;
    FCards: array of TSetupCardRec;
    FCategories: array of TCategoryHeaderRec;
    FSyncingUI: Boolean;

    // Header
    FHeaderPanel: TPanel;
    FHeaderIconBox: TPanel;
    FHeaderIconImg: TImage;
    FTitleLabel: TLabel;
    FSubtitleLabel: TLabel;
    FHeaderSep: TPanel;

    // Scroll container
    FContentBox: TScrollBox;

    // Individual checkboxes (hidden, linked to TToggleSwitch for test/API compatibility)
    FMangoCheck: TCheckBox;
    FVkBasaltCheck: TCheckBox;
    FReShadeCheck: TCheckBox;
    FVkSumiCheck: TCheckBox;
    FOptiScalerCheck: TCheckBox;
    FDlssEnablerCheck: TCheckBox;
    FHelixSRCheck: TCheckBox;
    FLsfgVkCheck: TCheckBox;
    FMakoCheck: TCheckBox;
    FAfmfCheck: TCheckBox;

    // Bottom
    FBottomPanel: TPanel;
    FFooterSep: TPanel;
    FSelectAllBtn: TBitBtn;
    FTotalCountLabel: TLabel;
    FConfirmBtn: TBitBtn;

    function FindCardByControl(Sender: TObject): Integer;
    function AreAllOptionalChecked: Boolean;
    function CountActiveInCategory(ACatIdx: Integer; out ATotal: Integer): Integer;
    procedure RefreshUIState;
    procedure StyleFooterButtons;

    procedure BuildUI;
    procedure HeaderIconFallbackPaint(Sender: TObject);
    procedure CategoryHeaderPaint(Sender: TObject);
    procedure CardPaint(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure CardMouseEnter(Sender: TObject);
    procedure CardMouseLeave(Sender: TObject);
    procedure ToggleSwitchChange(Sender: TObject);
    procedure SelectAllBtnClick(Sender: TObject);
    procedure ConfirmBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent; AIsFirstRun: Boolean = True); reintroduce;
    destructor Destroy; override;

    function CardCount: Integer;
    function GetCardToggle(AIndex: Integer): TToggleSwitch;
    function GetCategorySummaryText(ACategoryIdx: Integer): string;

    property MangoCheck: TCheckBox read FMangoCheck;
    property VkBasaltCheck: TCheckBox read FVkBasaltCheck;
    property ReShadeCheck: TCheckBox read FReShadeCheck;
    property VkSumiCheck: TCheckBox read FVkSumiCheck;
    property OptiScalerCheck: TCheckBox read FOptiScalerCheck;
    property DlssEnablerCheck: TCheckBox read FDlssEnablerCheck;
    property HelixSRCheck: TCheckBox read FHelixSRCheck;
    property LsfgVkCheck: TCheckBox read FLsfgVkCheck;
    property MakoCheck: TCheckBox read FMakoCheck;
    property AfmfCheck: TCheckBox read FAfmfCheck;

    // Backwards compatibility properties for existing test suite
    property PostProcessingCheck: TCheckBox read FVkBasaltCheck;
    property UpscalersCheck: TCheckBox read FOptiScalerCheck;
    property FrameGenCheck: TCheckBox read FLsfgVkCheck;

    property SelectAllBtn: TBitBtn read FSelectAllBtn;
    property ConfirmBtn: TBitBtn read FConfirmBtn;
    property TotalCountLabel: TLabel read FTotalCountLabel;
    property HeaderPanel: TPanel read FHeaderPanel;
    property HeaderIconBox: TPanel read FHeaderIconBox;
    property HeaderIconImg: TImage read FHeaderIconImg;
    property TitleLabel: TLabel read FTitleLabel;
    property SubtitleLabel: TLabel read FSubtitleLabel;
    property ContentBox: TScrollBox read FContentBox;
  end;

function ShowFirstRunSetupDialog(AOwner: TComponent; AIsFirstRun: Boolean = True): Boolean;

implementation

uses
  {$IFDEF LCLqt6}
  qt6, qtobjects, qtwidgets,
  {$ENDIF}
  apputils, bgmod_resources, optiscaler_update, themeunit;

type
  TDialogPalette = record
    IsLight: Boolean;
    BgColor: TColor;
    HeaderFooterBg: TColor;
    DividerColor: TColor;
    CardBg: TColor;
    CardBgChecked: TColor;
    CardBgHover: TColor;
    CardBgCore: TColor;
    CardBorder: TColor;
    CardBorderChecked: TColor;
    CardBorderHover: TColor;
    CardBorderCore: TColor;
    StripChecked: TColor;
    StripCore: TColor;
    TextMain: TColor;
    TextDim: TColor;
    Accent: TColor;
    CorePillBg: TColor;
    CorePillBorder: TColor;
    CorePillText: TColor;
    CatPillBg: TColor;
    CatPillBorder: TColor;
    CatPillText: TColor;
    CatPillActiveBg: TColor;
    CatPillActiveBorder: TColor;
    CatPillActiveText: TColor;
  end;

const
  DLG_WIDTH    = 660;
  DLG_HEIGHT   = 700;
  CARD_LEFT    = 16;
  CARD_WIDTH   = 622;
  CARD_HEIGHT  = 58;
  CARD_GAP     = 6;
  CAT_HEADER_H = 22;

function GetDialogPalette: TDialogPalette;
begin
  Result.IsLight := (CurrentTheme = tmLight);
  if Result.IsLight then
  begin
    Result.BgColor             := LightBackgroundColor;
    Result.HeaderFooterBg      := RGBToColor(245, 246, 248);
    Result.DividerColor        := RGBToColor(220, 224, 232);
    Result.CardBg              := RGBToColor(245, 246, 248);
    Result.CardBgChecked       := RGBToColor(235, 244, 252);
    Result.CardBgHover         := RGBToColor(236, 240, 246);
    Result.CardBgCore          := RGBToColor(238, 247, 242);
    Result.CardBorder          := RGBToColor(218, 222, 230);
    Result.CardBorderChecked   := RGBToColor(48, 150, 215);
    Result.CardBorderHover     := RGBToColor(165, 180, 205);
    Result.CardBorderCore      := RGBToColor(122, 196, 154);
    Result.StripChecked        := RGBToColor(14, 140, 200);
    Result.StripCore           := RGBToColor(34, 160, 95);
    Result.TextMain            := LightTextColor;
    Result.TextDim             := RGBToColor(90, 98, 112);
    Result.Accent              := RGBToColor(14, 140, 200);
    Result.CorePillBg          := RGBToColor(220, 245, 231);
    Result.CorePillBorder      := RGBToColor(108, 196, 144);
    Result.CorePillText        := RGBToColor(21, 127, 68);
    Result.CatPillBg           := RGBToColor(232, 236, 244);
    Result.CatPillBorder       := RGBToColor(207, 214, 227);
    Result.CatPillText         := RGBToColor(74, 85, 104);
    Result.CatPillActiveBg     := RGBToColor(218, 240, 252);
    Result.CatPillActiveBorder := RGBToColor(116, 195, 239);
    Result.CatPillActiveText   := RGBToColor(11, 120, 176);
  end
  else
  begin
    Result.BgColor             := DARK_TAB_BG;
    Result.HeaderFooterBg      := DARK_TAB_BG;
    Result.DividerColor        := RGBToColor(42, 50, 72);
    Result.CardBg              := RGBToColor(27, 32, 46);
    Result.CardBgChecked       := RGBToColor(28, 38, 58);
    Result.CardBgHover         := RGBToColor(36, 44, 68);
    Result.CardBgCore          := RGBToColor(26, 35, 52);
    Result.CardBorder          := RGBToColor(46, 56, 80);
    Result.CardBorderChecked   := RGBToColor(48, 130, 185);
    Result.CardBorderHover     := RGBToColor(65, 84, 128);
    Result.CardBorderCore      := RGBToColor(38, 94, 66);
    Result.StripChecked        := CLR_TEXT_ACCENT;
    Result.StripCore           := RGBToColor(46, 204, 113);
    Result.TextMain            := clWhite;
    Result.TextDim             := RGBToColor(145, 155, 175);
    Result.Accent              := CLR_TEXT_ACCENT;
    Result.CorePillBg          := RGBToColor(22, 48, 36);
    Result.CorePillBorder      := RGBToColor(36, 120, 75);
    Result.CorePillText        := RGBToColor(74, 222, 128);
    Result.CatPillBg           := RGBToColor(31, 40, 59);
    Result.CatPillBorder       := RGBToColor(48, 61, 88);
    Result.CatPillText         := RGBToColor(159, 177, 204);
    Result.CatPillActiveBg     := RGBToColor(22, 48, 66);
    Result.CatPillActiveBorder := RGBToColor(37, 104, 141);
    Result.CatPillActiveText   := RGBToColor(86, 204, 242);
  end;
end;

procedure EnableCanvasAntialias(ACanvas: TCanvas);
begin
  {$IFDEF LCLqt6}
  if ACanvas.Handle <> 0 then
  begin
    TQtDeviceContext(ACanvas.Handle).setRenderHint(QPainterAntialiasing, True);
    TQtDeviceContext(ACanvas.Handle).setRenderHint(QPainterSmoothPixmapTransform, True);
  end;
  {$ENDIF}
end;

function ShowFirstRunSetupDialog(AOwner: TComponent; AIsFirstRun: Boolean): Boolean;
var
  Dlg: TFirstRunSetupDialog;
begin
  Dlg := TFirstRunSetupDialog.Create(AOwner, AIsFirstRun);
  try
    Result := (Dlg.ShowModal = mrOk);
    if AIsFirstRun and not TConfigManager.IsFirstRunWizardCompleted then
    begin
      // User dismissed dialog on first run; default safely to MangoHud only
      TConfigManager.SetFirstRunWizardCompleted(True);
      TConfigManager.SetModuleEnabled(MODULE_VKBASALT, False);
      TConfigManager.SetModuleEnabled(MODULE_RESHADE, False);
      TConfigManager.SetModuleEnabled(MODULE_VKSUMI, False);
      TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, False);
      TConfigManager.SetModuleEnabled(MODULE_DLSSENABLER, False);
      TConfigManager.SetModuleEnabled(MODULE_HELIXSR, False);
      TConfigManager.SetModuleEnabled(MODULE_LSFGVK, False);
      TConfigManager.SetModuleEnabled(MODULE_MAKO, False);
      TConfigManager.SetModuleEnabled(MODULE_AFMF, False);
      TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, False);
      TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, False);
      TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, False);
      UninstallAllUserModules;
    end;
  finally
    Dlg.Free;
  end;
end;

constructor TFirstRunSetupDialog.Create(AOwner: TComponent; AIsFirstRun: Boolean);
begin
  inherited CreateNew(AOwner);
  FIsFirstRun := AIsFirstRun;
  BuildUI;
  RefreshUIState;
end;

destructor TFirstRunSetupDialog.Destroy;
begin
  inherited Destroy;
end;

function TFirstRunSetupDialog.CardCount: Integer;
begin
  Result := Length(FCards);
end;

function TFirstRunSetupDialog.GetCardToggle(AIndex: Integer): TToggleSwitch;
begin
  if (AIndex >= 0) and (AIndex < Length(FCards)) then
    Result := FCards[AIndex].Toggle
  else
    Result := nil;
end;

function TFirstRunSetupDialog.CountActiveInCategory(ACatIdx: Integer; out ATotal: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  ATotal := 0;
  for i := 0 to High(FCards) do
  begin
    if FCards[i].CategoryIdx = ACatIdx then
    begin
      Inc(ATotal);
      if Assigned(FCards[i].Check) and FCards[i].Check.Checked then
        Inc(Result);
    end;
  end;
end;

function TFirstRunSetupDialog.GetCategorySummaryText(ACategoryIdx: Integer): string;
var
  ActiveCnt, TotalCnt: Integer;
begin
  ActiveCnt := CountActiveInCategory(ACategoryIdx, TotalCnt);
  Result := Format('%d / %d active', [ActiveCnt, TotalCnt]);
end;

function TFirstRunSetupDialog.FindCardByControl(Sender: TObject): Integer;
var
  i: Integer;
begin
  Result := -1;
  if Sender = nil then Exit;
  for i := 0 to High(FCards) do
  begin
    if (Sender = FCards[i].Panel) or (Sender = FCards[i].TitleLbl) or
       (Sender = FCards[i].DescLbl) or (Sender = FCards[i].Toggle) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TFirstRunSetupDialog.AreAllOptionalChecked: Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to High(FCards) do
  begin
    if not FCards[i].IsCore and Assigned(FCards[i].Check) and (not FCards[i].Check.Checked) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TFirstRunSetupDialog.RefreshUIState;
var
  i, ActiveTotal, CardTotal: Integer;
begin
  if FSyncingUI then Exit;
  FSyncingUI := True;
  try
    ActiveTotal := 0;
    CardTotal := Length(FCards);

    for i := 0 to High(FCards) do
    begin
      if Assigned(FCards[i].Check) and Assigned(FCards[i].Toggle) then
      begin
        if FCards[i].Toggle.Checked <> FCards[i].Check.Checked then
          FCards[i].Toggle.SyncFromLinked;
        if FCards[i].Check.Checked then
          Inc(ActiveTotal);
      end;
      if Assigned(FCards[i].Panel) then
        FCards[i].Panel.Invalidate;
    end;

    for i := 0 to High(FCategories) do
      if Assigned(FCategories[i].Panel) then
        FCategories[i].Panel.Invalidate;

    if Assigned(FTotalCountLabel) then
      FTotalCountLabel.Caption := Format('%d of %d active', [ActiveTotal, CardTotal]);

    if Assigned(FSelectAllBtn) then
    begin
      if AreAllOptionalChecked then
        FSelectAllBtn.Caption := 'Deselect All'
      else
        FSelectAllBtn.Caption := 'Select All';
    end;
  finally
    FSyncingUI := False;
  end;
end;

procedure TFirstRunSetupDialog.StyleFooterButtons;
var
  Pal: TDialogPalette;
  SS: WideString;
  {$IFDEF LCLqt6}
  Wdgt: QWidgetH;
  {$ENDIF}
begin
  Pal := GetDialogPalette;
  if Assigned(FSelectAllBtn) then
    StyleBitBtnTheme(FSelectAllBtn, Pal.TextMain, Pal.CardBg);

  if Assigned(FConfirmBtn) then
  begin
    FConfirmBtn.Font.Color := clWhite;
    {$IFDEF LCLqt6}
    if not FConfirmBtn.HandleAllocated then
      FConfirmBtn.HandleNeeded;
    if FConfirmBtn.HandleAllocated then
    begin
      Wdgt := TQtWidget(FConfirmBtn.Handle).Widget;
      if Wdgt <> nil then
      begin
        SS := 'QPushButton, QToolButton { ' +
              'background-color: rgb(32, 120, 180); color: rgb(255, 255, 255); ' +
              'border: 1px solid rgb(48, 190, 240); border-radius: 8px; ' +
              'padding: 2px 12px; font-weight: bold; } ' +
              'QPushButton:hover, QToolButton:hover { ' +
              'background-color: rgb(43, 148, 220); border: 1px solid rgb(85, 215, 255); } ' +
              'QPushButton:pressed, QToolButton:pressed { ' +
              'background-color: rgb(24, 95, 155); }';
        QWidget_setStyleSheet(Wdgt, @SS);
      end;
    end;
    {$ENDIF}
  end;
end;

procedure TFirstRunSetupDialog.HeaderIconFallbackPaint(Sender: TObject);
var
  P: TPanel;
  Pal: TDialogPalette;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  Pal := GetDialogPalette;

  P.Canvas.Brush.Color := Pal.HeaderFooterBg;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);

  EnableCanvasAntialias(P.Canvas);

  P.Canvas.Brush.Color := Pal.CardBgChecked;
  P.Canvas.Pen.Color := Pal.CardBorderChecked;
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(0, 0, P.ClientWidth, P.ClientHeight, 12, 12);

  P.Canvas.Pen.Color := Pal.Accent;
  P.Canvas.Pen.Width := 2;
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.RoundRect(11, 11, 18, 18, 3, 3);
  P.Canvas.RoundRect(22, 11, 29, 18, 3, 3);
  P.Canvas.RoundRect(11, 22, 18, 29, 3, 3);
  P.Canvas.RoundRect(22, 22, 29, 29, 3, 3);
end;

procedure TFirstRunSetupDialog.CategoryHeaderPaint(Sender: TObject);
var
  P: TPanel;
  Pal: TDialogPalette;
  CatIdx, ActiveCnt, TotalCnt: Integer;
  PillText: string;
  TxtW, PillW, PillX, PillY, TitleY: Integer;
  PillBg, PillBorder, PillTextClr: TColor;
const
  PILL_H = 18;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  CatIdx := P.Tag;
  if (CatIdx < 0) or (CatIdx >= Length(FCategories)) then Exit;

  Pal := GetDialogPalette;
  P.Canvas.Brush.Color := Pal.BgColor;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);

  EnableCanvasAntialias(P.Canvas);

  // Left uppercase category label
  P.Canvas.Font.Name := 'Noto Sans';
  P.Canvas.Font.Size := 8;
  P.Canvas.Font.Style := [fsBold];
  P.Canvas.Font.Color := Pal.Accent;
  P.Canvas.Brush.Style := bsClear;
  TitleY := (P.ClientHeight - P.Canvas.TextHeight(FCategories[CatIdx].Title)) div 2;
  P.Canvas.TextOut(2, TitleY, FCategories[CatIdx].Title);

  // Right-aligned active counter pill ("X / Y active")
  ActiveCnt := CountActiveInCategory(CatIdx, TotalCnt);
  PillText := Format('%d / %d active', [ActiveCnt, TotalCnt]);
  if ActiveCnt > 0 then
  begin
    PillBg := Pal.CatPillActiveBg;
    PillBorder := Pal.CatPillActiveBorder;
    PillTextClr := Pal.CatPillActiveText;
  end
  else
  begin
    PillBg := Pal.CatPillBg;
    PillBorder := Pal.CatPillBorder;
    PillTextClr := Pal.CatPillText;
  end;

  P.Canvas.Font.Name := 'DejaVu Sans';
  P.Canvas.Font.Size := 7;
  P.Canvas.Font.Style := [fsBold];
  TxtW := P.Canvas.TextWidth(PillText);
  PillW := TxtW + 14;
  PillX := P.ClientWidth - PillW;
  PillY := (P.ClientHeight - PILL_H) div 2;

  P.Canvas.Brush.Color := PillBg;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.Pen.Color := PillBorder;
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(PillX, PillY, PillX + PillW, PillY + PILL_H, PILL_H, PILL_H);

  P.Canvas.Font.Color := PillTextClr;
  P.Canvas.Brush.Style := bsClear;
  P.Canvas.TextOut(PillX + 7, PillY + (PILL_H - P.Canvas.TextHeight(PillText)) div 2, PillText);
end;

procedure TFirstRunSetupDialog.CardPaint(Sender: TObject);
var
  P: TPanel;
  Idx: Integer;
  Pal: TDialogPalette;
  IsChecked: Boolean;
  BgClr, BorderClr, StripClr: TColor;
  R, BadgeR: TRect;
  BadgeW, BadgeX, BadgeY, TxtH: Integer;
const
  BADGE_TEXT = 'Core';
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  Idx := P.Tag;
  if (Idx < 0) or (Idx >= Length(FCards)) then Exit;

  // Keep linked toggle synced even when tests mutate TCheckBox directly
  if Assigned(FCards[Idx].Toggle) and Assigned(FCards[Idx].Check) and
     (FCards[Idx].Toggle.Checked <> FCards[Idx].Check.Checked) then
    FCards[Idx].Toggle.SyncFromLinked;

  Pal := GetDialogPalette;
  IsChecked := Assigned(FCards[Idx].Check) and FCards[Idx].Check.Checked;

  if FCards[Idx].IsCore then
  begin
    BgClr     := Pal.CardBgCore;
    BorderClr := Pal.CardBorderCore;
    StripClr  := Pal.StripCore;
  end
  else if IsChecked then
  begin
    if FCards[Idx].Hovered then
      BgClr := Pal.CardBgHover
    else
      BgClr := Pal.CardBgChecked;
    BorderClr := Pal.CardBorderChecked;
    StripClr  := Pal.StripChecked;
  end
  else
  begin
    if FCards[Idx].Hovered then
    begin
      BgClr     := Pal.CardBgHover;
      BorderClr := Pal.CardBorderHover;
    end
    else
    begin
      BgClr     := Pal.CardBg;
      BorderClr := Pal.CardBorder;
    end;
    StripClr := clNone;
  end;

  // Clear outer corners with parent background color
  P.Canvas.Brush.Color := Pal.BgColor;
  P.Canvas.Brush.Style := bsSolid;
  P.Canvas.FillRect(P.ClientRect);

  EnableCanvasAntialias(P.Canvas);

  // Main rounded card body
  R := Rect(0, 0, P.ClientWidth, P.ClientHeight);
  P.Canvas.Brush.Color := BgClr;
  P.Canvas.Pen.Color := BorderClr;
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 16, 16);

  // Subtle 3px left accent strip when active / core
  if StripClr <> clNone then
  begin
    P.Canvas.Brush.Color := StripClr;
    P.Canvas.Pen.Color := StripClr;
    P.Canvas.RoundRect(1, 6, 4, P.ClientHeight - 6, 3, 3);
  end;

  // Green "Core" pill badge right next to MangoHud title
  if FCards[Idx].IsCore and Assigned(FCards[Idx].TitleLbl) then
  begin
    P.Canvas.Font.Assign(FCards[Idx].TitleLbl.Font);
    BadgeX := FCards[Idx].TitleLbl.Left + P.Canvas.TextWidth(FCards[Idx].TitleLbl.Caption) + 10;

    P.Canvas.Font.Name := 'DejaVu Sans';
    P.Canvas.Font.Size := 7;
    P.Canvas.Font.Style := [fsBold];
    TxtH := P.Canvas.TextHeight(BADGE_TEXT);
    BadgeW := P.Canvas.TextWidth(BADGE_TEXT) + 14;
    BadgeY := FCards[Idx].TitleLbl.Top + 1;
    BadgeR := Rect(BadgeX, BadgeY, BadgeX + BadgeW, BadgeY + TxtH + 5);

    P.Canvas.Brush.Color := Pal.CorePillBg;
    P.Canvas.Brush.Style := bsSolid;
    P.Canvas.Pen.Color := Pal.CorePillBorder;
    P.Canvas.RoundRect(BadgeR.Left, BadgeR.Top, BadgeR.Right, BadgeR.Bottom, 10, 10);

    P.Canvas.Font.Color := Pal.CorePillText;
    P.Canvas.Brush.Style := bsClear;
    P.Canvas.TextOut(BadgeX + 7, BadgeY + 2, BADGE_TEXT);
  end;
end;

procedure TFirstRunSetupDialog.CardClick(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := FindCardByControl(Sender);
  if (Idx < 0) or FCards[Idx].IsCore then Exit;

  if Assigned(FCards[Idx].Check) then
  begin
    FCards[Idx].Check.Checked := not FCards[Idx].Check.Checked;
    if Assigned(FCards[Idx].Toggle) then
      FCards[Idx].Toggle.SyncFromLinked;
  end;
  RefreshUIState;
end;

procedure TFirstRunSetupDialog.CardMouseEnter(Sender: TObject);
var
  Idx: Integer;
begin
  Idx := FindCardByControl(Sender);
  if (Idx < 0) or FCards[Idx].IsCore then Exit;
  if not FCards[Idx].Hovered then
  begin
    FCards[Idx].Hovered := True;
    FCards[Idx].Panel.Invalidate;
  end;
end;

procedure TFirstRunSetupDialog.CardMouseLeave(Sender: TObject);
var
  Idx: Integer;
  Pt: TPoint;
begin
  Idx := FindCardByControl(Sender);
  if (Idx < 0) or FCards[Idx].IsCore then Exit;

  Pt := FCards[Idx].Panel.ScreenToClient(Mouse.CursorPos);
  if PtInRect(FCards[Idx].Panel.ClientRect, Pt) then
    Exit;

  if FCards[Idx].Hovered then
  begin
    FCards[Idx].Hovered := False;
    FCards[Idx].Panel.Invalidate;
  end;
end;

procedure TFirstRunSetupDialog.ToggleSwitchChange(Sender: TObject);
var
  Idx: Integer;
begin
  if FSyncingUI then Exit;
  Idx := FindCardByControl(Sender);
  if (Idx < 0) or FCards[Idx].IsCore then Exit;

  if Assigned(FCards[Idx].Check) and Assigned(FCards[Idx].Toggle) then
    FCards[Idx].Check.Checked := FCards[Idx].Toggle.Checked;
  RefreshUIState;
end;

procedure TFirstRunSetupDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then // Escape
    Close;
end;

procedure TFirstRunSetupDialog.SelectAllBtnClick(Sender: TObject);
var
  i: Integer;
  NextState: Boolean;
begin
  NextState := not AreAllOptionalChecked;
  for i := 0 to High(FCards) do
  begin
    if not FCards[i].IsCore and Assigned(FCards[i].Check) then
      FCards[i].Check.Checked := NextState;
  end;
  RefreshUIState;
end;

procedure TFirstRunSetupDialog.ConfirmBtnClick(Sender: TObject);
var
  PPEnabled, UpscalersEnabled, FGEnabled: Boolean;
begin
  TConfigManager.SetFirstRunWizardCompleted(True);

  TConfigManager.SetModuleEnabled(MODULE_VKBASALT, FVkBasaltCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_RESHADE, FReShadeCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_VKSUMI, FVkSumiCheck.Checked);

  TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, FOptiScalerCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_DLSSENABLER, FDlssEnablerCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_HELIXSR, FHelixSRCheck.Checked);

  TConfigManager.SetModuleEnabled(MODULE_LSFGVK, FLsfgVkCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_MAKO, FMakoCheck.Checked);
  TConfigManager.SetModuleEnabled(MODULE_AFMF, FAfmfCheck.Checked);

  PPEnabled := FVkBasaltCheck.Checked or FReShadeCheck.Checked or FVkSumiCheck.Checked;
  UpscalersEnabled := FOptiScalerCheck.Checked or FDlssEnablerCheck.Checked or FHelixSRCheck.Checked;
  FGEnabled := FLsfgVkCheck.Checked or FMakoCheck.Checked or FAfmfCheck.Checked;

  TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, PPEnabled);
  TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, UpscalersEnabled);
  TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, FGEnabled);

  // Remove user-space layers and binaries for unselected modules
  if not FVkBasaltCheck.Checked then UninstallUserModule(MODULE_VKBASALT);
  if not FReShadeCheck.Checked then UninstallUserModule(MODULE_RESHADE);
  if not FVkSumiCheck.Checked then UninstallUserModule(MODULE_VKSUMI);

  if not FOptiScalerCheck.Checked then UninstallUserModule(MODULE_OPTISCALER);
  if not FDlssEnablerCheck.Checked then UninstallUserModule(MODULE_DLSSENABLER);
  if not FHelixSRCheck.Checked then UninstallUserModule(MODULE_HELIXSR);

  if not FLsfgVkCheck.Checked then UninstallUserModule(MODULE_LSFGVK);
  if not FMakoCheck.Checked then UninstallUserModule(MODULE_MAKO);
  if not FAfmfCheck.Checked then UninstallUserModule(MODULE_AFMF);

  if (not FOptiScalerCheck.Checked) and (not FDlssEnablerCheck.Checked) then
    UninstallUserModule('vkNemu');

  ModalResult := mrOk;
end;

procedure TFirstRunSetupDialog.BuildUI;
var
  Pal: TDialogPalette;
  CardTop, CurrentCatIdx: Integer;
  BottomSpacer: TPanel;
  IconPath, BaseDir: string;

  procedure CreateCategoryHeader(const ATitle: string);
  var
    P: TPanel;
    Idx: Integer;
  begin
    Idx := Length(FCategories);
    SetLength(FCategories, Idx + 1);
    CurrentCatIdx := Idx;

    P := TPanel.Create(Self);
    P.Parent := FContentBox;
    P.SetBounds(CARD_LEFT, CardTop, CARD_WIDTH, CAT_HEADER_H);
    P.Color := Pal.BgColor;
    P.ParentColor := False;
    P.BevelOuter := bvNone;
    P.BorderStyle := bsNone;
    P.Tag := Idx;
    P.OnPaint := @CategoryHeaderPaint;

    FCategories[Idx].Panel := P;
    FCategories[Idx].Title := ATitle;
    FCategories[Idx].CategoryIdx := Idx;

    Inc(CardTop, CAT_HEADER_H + 4);
  end;

  function CreateLibraryCard(const ATitle, ADesc: string;
    out ACheck: TCheckBox; AIsLocked: Boolean = False;
    AInitialState: Boolean = False): TPanel;
  var
    P: TPanel;
    TitleLbl, DescLbl: TLabel;
    Toggle: TToggleSwitch;
    Idx, ContentLeft, ContentW: Integer;
  begin
    Idx := Length(FCards);
    SetLength(FCards, Idx + 1);

    P := TPanel.Create(Self);
    P.Parent := FContentBox;
    P.SetBounds(CARD_LEFT, CardTop, CARD_WIDTH, CARD_HEIGHT);
    P.Color := Pal.BgColor;
    P.ParentColor := False;
    P.BevelOuter := bvNone;
    P.BorderStyle := bsNone;
    P.Tag := Idx;
    P.OnPaint := @CardPaint;
    if not AIsLocked then
    begin
      P.Cursor := crHandPoint;
      P.OnClick := @CardClick;
      P.OnMouseEnter := @CardMouseEnter;
      P.OnMouseLeave := @CardMouseLeave;
    end;

    // Hidden TCheckBox linked behind TToggleSwitch for full test/API compatibility.
    // Keep Caption empty so TToggleSwitch.SyncFromLinked never restores text onto the toggle track.
    ACheck := TCheckBox.Create(Self);
    ACheck.Parent := P;
    ACheck.SetBounds(0, 0, 20, 20);
    ACheck.Caption := '';
    ACheck.Checked := AInitialState;
    if AIsLocked then
    begin
      ACheck.Checked := True;
      ACheck.Enabled := False;
    end;

    // Modern left-aligned TToggleSwitch without inline text caption
    Toggle := TToggleSwitch.Create(Self);
    Toggle.Parent := P;
    Toggle.Size := tssNormal;
    Toggle.LinkToCheckBox(ACheck);
    Toggle.Caption := '';
    Toggle.Width := Toggle.GetOptimalWidth;
    Toggle.Height := 22;
    Toggle.SetBounds(16, (CARD_HEIGHT - 22) div 2, Toggle.Width, 22);
    if not AIsLocked then
    begin
      Toggle.Cursor := crHandPoint;
      Toggle.OnChange := @ToggleSwitchChange;
    end;

    ContentLeft := 16 + Toggle.Width + 14;
    ContentW := CARD_WIDTH - ContentLeft - 14;

    TitleLbl := TLabel.Create(Self);
    TitleLbl.Parent := P;
    TitleLbl.AutoSize := False;
    TitleLbl.SetBounds(ContentLeft, 10, ContentW, 20);
    TitleLbl.Caption := ATitle;
    TitleLbl.Font.Name := 'Noto Sans';
    TitleLbl.Font.Size := 10;
    TitleLbl.Font.Style := [fsBold];
    TitleLbl.Font.Color := Pal.TextMain;
    TitleLbl.ShowAccelChar := False;
    if not AIsLocked then
    begin
      TitleLbl.Cursor := crHandPoint;
      TitleLbl.OnClick := @CardClick;
      TitleLbl.OnMouseEnter := @CardMouseEnter;
      TitleLbl.OnMouseLeave := @CardMouseLeave;
    end;

    DescLbl := TLabel.Create(Self);
    DescLbl.Parent := P;
    DescLbl.AutoSize := False;
    DescLbl.SetBounds(ContentLeft, 32, ContentW, 18);
    DescLbl.Caption := ADesc;
    DescLbl.Font.Name := 'Noto Sans';
    DescLbl.Font.Size := 8;
    DescLbl.Font.Color := Pal.TextDim;
    DescLbl.ShowAccelChar := False;
    if not AIsLocked then
    begin
      DescLbl.Cursor := crHandPoint;
      DescLbl.OnClick := @CardClick;
      DescLbl.OnMouseEnter := @CardMouseEnter;
      DescLbl.OnMouseLeave := @CardMouseLeave;
    end;

    FCards[Idx].Panel := P;
    FCards[Idx].Check := ACheck;
    FCards[Idx].Toggle := Toggle;
    FCards[Idx].TitleLbl := TitleLbl;
    FCards[Idx].DescLbl := DescLbl;
    FCards[Idx].IsCore := AIsLocked;
    FCards[Idx].Hovered := False;
    FCards[Idx].CategoryIdx := CurrentCatIdx;

    Inc(CardTop, CARD_HEIGHT + CARD_GAP);
    Result := P;
  end;

begin
  Pal := GetDialogPalette;
  SetLength(FCards, 0);
  SetLength(FCategories, 0);
  CurrentCatIdx := -1;

  Caption := 'Goverlay - Component Setup';
  Position := poScreenCenter;
  Width := DLG_WIDTH;
  Height := DLG_HEIGHT;
  Color := Pal.BgColor;
  BorderStyle := bsDialog;
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  // Header Panel
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent := Self;
  FHeaderPanel.Align := alTop;
  FHeaderPanel.Height := 90;
  FHeaderPanel.BevelOuter := bvNone;
  FHeaderPanel.Color := Pal.HeaderFooterBg;
  FHeaderPanel.ParentColor := False;

  FHeaderIconBox := TPanel.Create(Self);
  FHeaderIconBox.Parent := FHeaderPanel;
  FHeaderIconBox.SetBounds(20, 16, 42, 42);
  FHeaderIconBox.BevelOuter := bvNone;
  FHeaderIconBox.BorderStyle := bsNone;
  FHeaderIconBox.Color := Pal.HeaderFooterBg;
  FHeaderIconBox.ParentColor := False;

  BaseDir := GetAppBaseDir;
  IconPath := BaseDir + 'data/icons/128x128/goverlay.png';
  if not FileExists(IconPath) then
    IconPath := BaseDir + 'assets/icons/goverlay.png';
  if not FileExists(IconPath) then
    IconPath := GetIconFile;

  FHeaderIconImg := TImage.Create(Self);
  FHeaderIconImg.Parent := FHeaderIconBox;
  FHeaderIconImg.Align := alClient;
  FHeaderIconImg.Stretch := True;
  FHeaderIconImg.Proportional := True;
  FHeaderIconImg.Center := True;
  FHeaderIconImg.AntialiasingMode := amOn;
  if FileExists(IconPath) then
  begin
    try
      FHeaderIconImg.Picture.LoadFromFile(IconPath);
    except
      FHeaderIconImg.Visible := False;
      FHeaderIconBox.OnPaint := @HeaderIconFallbackPaint;
    end;
  end
  else
  begin
    FHeaderIconImg.Visible := False;
    FHeaderIconBox.OnPaint := @HeaderIconFallbackPaint;
  end;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := FHeaderPanel;
  FTitleLabel.AutoSize := False;
  FTitleLabel.SetBounds(74, 14, DLG_WIDTH - 94, 24);
  if FIsFirstRun then
    FTitleLabel.Caption := 'Welcome to Goverlay! Choose Your Setup'
  else
    FTitleLabel.Caption := 'Manage Integrations and Modules';
  FTitleLabel.Font.Name := 'Noto Sans';
  FTitleLabel.Font.Size := 13;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := Pal.Accent;
  FTitleLabel.ShowAccelChar := False;

  FSubtitleLabel := TLabel.Create(Self);
  FSubtitleLabel.Parent := FHeaderPanel;
  FSubtitleLabel.AutoSize := False;
  FSubtitleLabel.WordWrap := True;
  FSubtitleLabel.Constraints.MaxWidth := DLG_WIDTH - 94;
  FSubtitleLabel.SetBounds(74, 41, DLG_WIDTH - 94, 40);
  FSubtitleLabel.Caption :=
    'Select which libraries and features you want to activate. Goverlay will only download and verify runtimes for selected libraries.';
  FSubtitleLabel.Font.Name := 'Noto Sans';
  FSubtitleLabel.Font.Size := 9;
  FSubtitleLabel.Font.Color := Pal.TextDim;
  FSubtitleLabel.ShowAccelChar := False;

  FHeaderSep := TPanel.Create(Self);
  FHeaderSep.Parent := FHeaderPanel;
  FHeaderSep.Align := alBottom;
  FHeaderSep.Height := 1;
  FHeaderSep.BevelOuter := bvNone;
  FHeaderSep.Color := Pal.DividerColor;
  FHeaderSep.ParentColor := False;

  // Content scrollbox
  FContentBox := TScrollBox.Create(Self);
  FContentBox.Parent := Self;
  FContentBox.Align := alClient;
  FContentBox.BorderStyle := bsNone;
  FContentBox.Color := Pal.BgColor;
  FContentBox.ParentColor := False;
  FContentBox.HorzScrollBar.Visible := False;
  FContentBox.VertScrollBar.Tracking := True;
  FContentBox.VertScrollBar.Smooth := True;
  ApplyModernScrollBarStylesheet(FContentBox);

  CardTop := 8;

  // Category 1: Overlay
  CreateCategoryHeader('OVERLAY');
  CreateLibraryCard('MangoHud',
    'Real-time overlay for FPS, frametimes, GPU/CPU telemetry, VRAM, and power metrics.',
    FMangoCheck, True, True);
  Inc(CardTop, 10);

  // Category 2: Post-Processing & Shaders
  CreateCategoryHeader('POST-PROCESSING AND SHADERS');
  CreateLibraryCard('vkBasalt',
    'Vulkan post-processing layer with CAS sharpening, FXAA, and custom shaders.',
    FVkBasaltCheck, False, TConfigManager.IsModuleEnabled(MODULE_VKBASALT, False));
  CreateLibraryCard('ReShade',
    'ReShade 64-bit runtime and standard shader packages (SweetFX, Quint, etc.).',
    FReShadeCheck, False, TConfigManager.IsModuleEnabled(MODULE_RESHADE, False));
  CreateLibraryCard('vkSumi',
    'Real-time color grading, tone mapping, and 3D LUT Vulkan layer.',
    FVkSumiCheck, False, TConfigManager.IsModuleEnabled(MODULE_VKSUMI, False));
  Inc(CardTop, 10);

  // Category 3: Upscaling Ecosystem
  CreateCategoryHeader('UPSCALING ECOSYSTEM');
  CreateLibraryCard('OptiScaler',
    'Cross-vendor upscaling wrapper (XeSS, FSR2/FSR3/FSR4) with OptiPatcher.',
    FOptiScalerCheck, False, TConfigManager.IsModuleEnabled(MODULE_OPTISCALER, False));
  CreateLibraryCard('DLSS Enabler',
    'Translates in-game DLSS inputs to XeSS or FSR runtimes.',
    FDlssEnablerCheck, False, TConfigManager.IsModuleEnabled(MODULE_DLSSENABLER, False));
  CreateLibraryCard('HelixSR',
    'Neural super-resolution model runtime and machine learning weights.',
    FHelixSRCheck, False, TConfigManager.IsModuleEnabled(MODULE_HELIXSR, False));
  Inc(CardTop, 10);

  // Category 4: Frame Generation & Motion
  CreateCategoryHeader('FRAME GENERATION AND MOTION');
  CreateLibraryCard('Lossless Scaling (lsfg-vk)',
    'Optical flow frame interpolation layer for Vulkan games.',
    FLsfgVkCheck, False, TConfigManager.IsModuleEnabled(MODULE_LSFGVK, False));
  CreateLibraryCard('MAKO',
    'High-performance Vulkan frame interpolation engine.',
    FMakoCheck, False, TConfigManager.IsModuleEnabled(MODULE_MAKO, False));
  CreateLibraryCard('AFMF',
    'AMD Fluid Motion Frames Vulkan layer for Linux.',
    FAfmfCheck, False, TConfigManager.IsModuleEnabled(MODULE_AFMF, False));

  // Bottom padding inside scroll area
  BottomSpacer := TPanel.Create(Self);
  BottomSpacer.Parent := FContentBox;
  BottomSpacer.SetBounds(CARD_LEFT, CardTop, CARD_WIDTH, 10);
  BottomSpacer.BevelOuter := bvNone;
  BottomSpacer.Color := Pal.BgColor;
  BottomSpacer.ParentColor := False;

  // Bottom Panel
  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Parent := Self;
  FBottomPanel.Align := alBottom;
  FBottomPanel.Height := 64;
  FBottomPanel.BevelOuter := bvNone;
  FBottomPanel.Color := Pal.HeaderFooterBg;
  FBottomPanel.ParentColor := False;

  FFooterSep := TPanel.Create(Self);
  FFooterSep.Parent := FBottomPanel;
  FFooterSep.Align := alTop;
  FFooterSep.Height := 1;
  FFooterSep.BevelOuter := bvNone;
  FFooterSep.Color := Pal.DividerColor;
  FFooterSep.ParentColor := False;

  FSelectAllBtn := TBitBtn.Create(Self);
  FSelectAllBtn.Parent := FBottomPanel;
  FSelectAllBtn.SetBounds(20, 14, 128, 36);
  FSelectAllBtn.Caption := 'Select All';
  FSelectAllBtn.Font.Name := 'Noto Sans';
  FSelectAllBtn.Font.Size := 9;
  FSelectAllBtn.Cursor := crHandPoint;
  FSelectAllBtn.OnClick := @SelectAllBtnClick;

  FTotalCountLabel := TLabel.Create(Self);
  FTotalCountLabel.Parent := FBottomPanel;
  FTotalCountLabel.AutoSize := False;
  FTotalCountLabel.SetBounds(160, 22, 180, 20);
  FTotalCountLabel.Font.Name := 'Noto Sans';
  FTotalCountLabel.Font.Size := 9;
  FTotalCountLabel.Font.Color := Pal.TextDim;
  FTotalCountLabel.ShowAccelChar := False;

  FConfirmBtn := TBitBtn.Create(Self);
  FConfirmBtn.Parent := FBottomPanel;
  FConfirmBtn.SetBounds(DLG_WIDTH - 20 - 185, 14, 185, 36);
  if FIsFirstRun then
    FConfirmBtn.Caption := 'Save and Continue'
  else
    FConfirmBtn.Caption := 'Save and Apply';
  FConfirmBtn.Font.Name := 'Noto Sans';
  FConfirmBtn.Font.Size := 9;
  FConfirmBtn.Font.Style := [fsBold];
  FConfirmBtn.Cursor := crHandPoint;
  FConfirmBtn.OnClick := @ConfirmBtnClick;

  StyleFooterButtons;
end;

end.
