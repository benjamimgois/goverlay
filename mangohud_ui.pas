unit mangohud_ui;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math,
  StdCtrls, Buttons, Menus, LCLtype, Types, Grids, Spin,
  themeunit, constants, hintsunit, apputils, overlayunit, overlay_config, systemdetector, ComCtrls, overlay_utils,
  {$IFDEF LCLqt6}
  qt6,
  qtobjects,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets, configkeys, toggle_switch;

type
  TTimeFormatApplyEvent = procedure(const AFormat: string) of object;

  { TMangoHudTimeFormatDialog }
  TMangoHudTimeFormatDialog = class(TForm)
  private
    FFormatEdit: TEdit;
    FPresetCombo: TComboBox;
    FPreviewLabel: TLabel;
    FUpdating: Boolean;
    FOnApply: TTimeFormatApplyEvent;
    procedure PresetComboChange(Sender: TObject);
    procedure FormatEditChange(Sender: TObject);
    procedure FormatEditEditingDone(Sender: TObject);
    procedure FormatEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdatePreview;
    procedure DoApply;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent; const AInitialFormat: string; AOnApply: TTimeFormatApplyEvent = nil); reintroduce;
    function GetFormatString: string;
  end;

  TMangoHudUiHelper = class
  private
    FForm: Tgoverlayform;
    FVisualToggles: TFPList;
    FPerfToggles: TFPList;
    FMetricsToggles: TFPList;
    FExtrasToggles: TFPList;
    FVisMonitorPaintBox: TPaintBox;
    FVisHoverAnchor: Integer;
    FframetimetypeLbl: TLabel;
    FFpsPresetLbl: TLabel;
    // When True, the active MangoHud config is the fps_only preset.
    // Any user control interaction (GenericControlChange/Click) clears this.
    FFpsOnly: Boolean;
    procedure ApplyTimeFormat(const AFormat: string);
    function GetActiveScreenAnchor: Integer;
    procedure SetActiveScreenAnchor(AAnchor: Integer);
    procedure UpdateMonitorVisuals;
    procedure VisMonitorPaintBoxPaint(Sender: TObject);
    procedure VisMonitorPaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VisMonitorPaintBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure VisMonitorPaintBoxMouseLeave(Sender: TObject);
  public
    // Visual Tab Toggles
    FhudcompactToggle, FhorizontalstrechToggle, FhidehudToggle: TToggleSwitch;
    FtextoutlineToggle: TToggleSwitch;
    textoutlineCheckBox: TCheckBox;

    // Visual Tab Modular Layout (two columns)
    FVisAppearanceCard, FVisLayoutCard: TPanel;
    FVisTitleSec: TPanel;
    FVisTypographySec, FVisCanvasSec: TPanel;
    FVisScreenSec, FVisFlowSec, FVisSystemSec: TPanel;
    FVisTitleSubLbl: TLabel;
    FVisTypoSubLbl, FVisCanvasSubLbl: TLabel;
    FVisScreenSubLbl, FVisFlowSubLbl, FVisSystemSubLbl: TLabel;
    FVisHudTitleLbl, FVisFontFamilyLbl, FVisFontColorLbl, FVisFontSizeLbl: TLabel;
    FVisBgColorLbl, FVisBorderPillLbl, FVisAlphaLbl: TLabel;
    FVisRadiusLbl, FVisNoMarginLbl: TLabel;
    FroundradiusvalueLabel: TLabel;
    FroundradiusTrackBar: TTrackBar;
    FhudnomarginToggle: TToggleSwitch;
    FVisOffsetXSubLbl, FVisOffsetYSubLbl: TLabel;
    FVisOrientPillLbl, FVisColumnsSubLbl: TLabel;
    FVisGpuBarLbl, FVisShortcutLbl: TLabel;
    FVisOrientPillBtn, FVisBorderPillBtn: TBitBtn;
    FColumnsMinusBtn, FColumnsPlusBtn: TBitBtn;
    FVisColumnsPaintBox: TPaintBox;
    FVisOutlineLbl, FVisStretchLbl, FVisCompactLbl, FVisHideLbl: TLabel;

    // Performance Tab Toggles
    FfpsToggle, FfpsavgToggle, FshowfpslimToggle: TToggleSwitch;
    FframetimegraphToggle, FframetimedetailedToggle: TToggleSwitch;
    FvpsToggle, FftraceToggle, FframecountToggle, FfpscolorToggle: TToggleSwitch;

    // Metrics Tab Sub-Cards
    FGpuCoreSec, FGpuThermalSec, FGpuPowerSec, FGpuInfoSec: TPanel;
    FCpuCoreSec, FCpuThermalSec, FCpuMemSec: TPanel;
    FCpuStorageSec: TPanel;
    FStorageLabel: TLabel;
    FGpuTitleLbl, FCpuTitleLbl, FMemTitleLbl: TLabel;

    // Extras Tab Sub-Cards
    FExtPlatformSec, FExtWineSec, FExtGamingSec, FExtSessionSec: TPanel;
    FExtLogTimingsSec, FExtLogToolsSec: TPanel;
    FExtSysTitleLbl, FExtLogTitleLbl: TLabel;
    FExtPlatformLbl, FExtWineLbl, FExtGamingLbl, FExtSessionLbl: TLabel;
    FExtLogTimingsLbl, FExtLogToolsLbl: TLabel;
    FExtCustomCommandLbl, FExtTempUnitLbl: TLabel;
    FExtLogDurationSubLbl, FExtLogDelaySubLbl, FExtLogIntervalSubLbl: TLabel;
    FExtTempPillBtn: TBitBtn;

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
    FTimeFormat: string;
    FTimeConfigBtn: TBitBtn;

    procedure TimeToggleChanged(Sender: TObject);
    procedure NetworkToggleChanged(Sender: TObject);
    procedure TimeConfigBtnClick(Sender: TObject);
    procedure ExtTempPillBtnClick(Sender: TObject);

    // fps_only preset flag accessor
    procedure SetFpsOnly(AValue: Boolean);

    constructor Create(AForm: Tgoverlayform);
    destructor Destroy; override;
    procedure BuildPresetsWrapper;
    function  FindPresetCard(ASender: TObject): TPanel;
    procedure UpdatePresetCardVisuals;
    procedure PresetCardPaint(Sender: TObject);
    procedure LimitSubCardPaint(Sender: TObject);
    procedure VkNemuFlowCardPaint(Sender: TObject);
    procedure PresetCardClick(Sender: TObject);
    procedure PresetCardMouseEnter(Sender: TObject);
    procedure PresetCardMouseLeave(Sender: TObject);
    procedure InitVisualTab;
    procedure ReflowVisualTab(AContentW, AContentH: Integer);
    procedure SyncVisualToggles;
    procedure VisOrientPillBtnClick(Sender: TObject);
    procedure VisBorderPillBtnClick(Sender: TObject);
    procedure RoundRadiusTrackBarChange(Sender: TObject);
    procedure SyncVisualPills;
    procedure SyncFlowGridVisibility;
    procedure VisColumnsPaintBoxPaint(Sender: TObject);
    procedure UpdateColumnsIndicator;
    procedure UpdateVisualCardTheme;
    procedure BuildFpsLimitEdit;
    procedure InitPerformanceTab;
    procedure ReflowPerformanceTab(AContentW, AContentH: Integer);
    procedure PerfScrollBoxResize(Sender: TObject);
    procedure SyncPerformanceToggles;
    procedure FrametimegraphCheckBoxChange(Sender: TObject);
    procedure UpdatePerfCardTheme;
    procedure InitMetricsTab;
    procedure ReflowMetricsTab(AContentW: Integer);
    procedure MtScrollBoxResize(Sender: TObject);
    procedure SyncMetricsToggles;
    procedure UpdateMetricsCardTheme;
    procedure RefreshFormatPills;
    procedure InitExtrasTab;
    procedure ReflowExtrasTab(AContentW: Integer);
    procedure ExtScrollBoxResize(Sender: TObject);
    procedure SyncExtrasToggles;
    procedure SyncAllToggles;
    procedure UpdateExtrasCardTheme;
    procedure LoadMangoHudConfig;
    procedure ResetMangoHudControls;
    procedure ResetMetricGraphs;
    procedure LoadMangoHudBoolFlag(const ATrimmedLine: string);
    procedure LoadMangoHudKeyValue(const AKey, AValue: string);
    procedure SaveMangoHudConfig;
    procedure MetricGraphClick(Sender: TObject);
  end;

function HexToColor(const HexValue: string): TColor;

implementation

type
  Ptm = Pointer;

function c_time(tloc: Pointer): Int64; cdecl; external 'c' name 'time';
function c_localtime(const timer: PInt64): Ptm; cdecl; external 'c' name 'localtime';
function c_strftime(s: PChar; max: SizeUInt; const format: PChar; const tm: Ptm): SizeUInt; cdecl; external 'c' name 'strftime';

function FormatTimePreview(const AFormat: string): string;
var
  t: Int64;
  tmPtr: Ptm;
  buf: array[0..255] of Char;
  len: SizeUInt;
begin
  if Trim(AFormat) = '' then
    Exit('');
  t := c_time(nil);
  tmPtr := c_localtime(@t);
  if tmPtr = nil then
    Exit('');
  buf[0] := #0;
  len := c_strftime(buf, SizeOf(buf), PChar(AFormat), tmPtr);
  if len > 0 then
    SetString(Result, buf, len)
  else
    Result := '(invalid or unsupported format)';
end;

{ TMangoHudTimeFormatDialog }

constructor TMangoHudTimeFormatDialog.Create(AOwner: TComponent; const AInitialFormat: string; AOnApply: TTimeFormatApplyEvent = nil);
var
  IsLight: Boolean;
  HeaderPanel, PrevPanel: TPanel;
  TitleLabel, SubLabel, PresetLabel, FormatLabel, PrevTitle, HintLbl: TLabel;
begin
  inherited CreateNew(AOwner);
  FOnApply := AOnApply;
  IsLight := CurrentTheme = tmLight;
  Position := poMainFormCenter;
  Width := 460;
  Height := 240;
  BorderStyle := bsDialog;
  BorderIcons := [biSystemMenu];
  Caption := 'MangoHud - Time Format';
  Color := IfThen(IsLight, clWhite, RGBToColor(22, 26, 40));
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  HeaderPanel := TPanel.Create(Self);
  HeaderPanel.Parent := Self;
  HeaderPanel.Align := alTop;
  HeaderPanel.Height := 52;
  HeaderPanel.BevelOuter := bvNone;
  HeaderPanel.Color := IfThen(IsLight, $00F2F2F2, RGBToColor(28, 34, 52));

  TitleLabel := TLabel.Create(HeaderPanel);
  TitleLabel.Parent := HeaderPanel;
  TitleLabel.Caption := 'Time Format Configuration';
  TitleLabel.Font.Style := [fsBold];
  TitleLabel.Font.Size := 11;
  TitleLabel.Font.Color := IfThen(IsLight, clBlack, clWhite);
  TitleLabel.Left := 16;
  TitleLabel.Top := 8;

  SubLabel := TLabel.Create(HeaderPanel);
  SubLabel.Parent := HeaderPanel;
  SubLabel.Caption := 'Select a preset or customize the std::put_time / strftime format string.';
  SubLabel.Font.Size := 8;
  SubLabel.Font.Color := IfThen(IsLight, $00606060, $00A0A0A0);
  SubLabel.Left := 16;
  SubLabel.Top := 30;

  PresetLabel := TLabel.Create(Self);
  PresetLabel.Parent := Self;
  PresetLabel.Caption := 'Preset:';
  PresetLabel.Font.Size := 9;
  PresetLabel.Font.Color := IfThen(IsLight, clBlack, clWhite);
  PresetLabel.Left := 16;
  PresetLabel.Top := 62;

  FPresetCombo := TComboBox.Create(Self);
  FPresetCombo.Parent := Self;
  FPresetCombo.Style := csDropDownList;
  FPresetCombo.Left := 16;
  FPresetCombo.Top := 80;
  FPresetCombo.Width := 428;
  FPresetCombo.Color := IfThen(IsLight, clWhite, RGBToColor(22, 26, 40));
  FPresetCombo.Font.Color := IfThen(IsLight, clBlack, clWhite);
  FPresetCombo.Items.Add('24-hour with seconds (%T) — Default');
  FPresetCombo.Items.Add('24-hour without seconds (%R)');
  FPresetCombo.Items.Add('12-hour AM/PM with seconds (%r)');
  FPresetCombo.Items.Add('12-hour AM/PM without seconds (%I:%M %p)');
  FPresetCombo.Items.Add('Date and 24-hour time (%d/%m/%Y %H:%M)');
  FPresetCombo.Items.Add('ISO 8601 date and time (%Y-%m-%d %H:%M:%S)');
  FPresetCombo.Items.Add('Custom format...');
  FPresetCombo.OnChange := @PresetComboChange;

  FormatLabel := TLabel.Create(Self);
  FormatLabel.Parent := Self;
  FormatLabel.Caption := 'Format string:';
  FormatLabel.Font.Size := 9;
  FormatLabel.Font.Color := IfThen(IsLight, clBlack, clWhite);
  FormatLabel.Left := 16;
  FormatLabel.Top := 112;

  FFormatEdit := TEdit.Create(Self);
  FFormatEdit.Parent := Self;
  FFormatEdit.Font.Name := 'DejaVu Sans Mono';
  FFormatEdit.Font.Size := 9;
  FFormatEdit.Left := 16;
  FFormatEdit.Top := 130;
  FFormatEdit.Width := 428;
  FFormatEdit.Color := IfThen(IsLight, clWhite, RGBToColor(22, 26, 40));
  FFormatEdit.Font.Color := IfThen(IsLight, clBlack, clWhite);
  FFormatEdit.Text := AInitialFormat;
  FFormatEdit.OnChange := @FormatEditChange;
  FFormatEdit.OnEditingDone := @FormatEditEditingDone;
  FFormatEdit.OnKeyDown := @FormatEditKeyDown;

  PrevPanel := TPanel.Create(Self);
  PrevPanel.Parent := Self;
  PrevPanel.BevelOuter := bvNone;
  PrevPanel.Left := 16;
  PrevPanel.Top := 164;
  PrevPanel.Width := 428;
  PrevPanel.Height := 34;
  PrevPanel.Color := IfThen(IsLight, $00E8E8E8, RGBToColor(16, 18, 28));

  PrevTitle := TLabel.Create(PrevPanel);
  PrevTitle.Parent := PrevPanel;
  PrevTitle.Caption := 'Preview:';
  PrevTitle.Font.Style := [fsBold];
  PrevTitle.Font.Size := 9;
  PrevTitle.Font.Color := IfThen(IsLight, clBlack, clWhite);
  PrevTitle.Left := 12;
  PrevTitle.Top := 9;

  FPreviewLabel := TLabel.Create(PrevPanel);
  FPreviewLabel.Parent := PrevPanel;
  FPreviewLabel.Font.Name := 'DejaVu Sans Mono';
  FPreviewLabel.Font.Style := [fsBold];
  FPreviewLabel.Font.Size := 10;
  FPreviewLabel.Font.Color := IfThen(IsLight, $00007A00, clLime);
  FPreviewLabel.Left := 75;
  FPreviewLabel.Top := 8;

  HintLbl := TLabel.Create(Self);
  HintLbl.Parent := Self;
  HintLbl.Caption := 'std::put_time reference: %T (HH:MM:SS), %R (HH:MM), %p (AM/PM), %d (day), %m (month), %Y (year)';
  HintLbl.Font.Size := 7;
  HintLbl.Font.Color := IfThen(IsLight, $00707070, $008E9CA8);
  HintLbl.Left := 16;
  HintLbl.Top := 204;

  FormatEditChange(FFormatEdit);
end;

procedure TMangoHudTimeFormatDialog.DoApply;
begin
  if Assigned(FOnApply) then
    FOnApply(GetFormatString);
end;

procedure TMangoHudTimeFormatDialog.FormatEditEditingDone(Sender: TObject);
begin
  if not FUpdating then
    DoApply;
end;

procedure TMangoHudTimeFormatDialog.FormatEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    DoApply;
    Key := 0;
  end;
end;

procedure TMangoHudTimeFormatDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    ModalResult := mrCancel;
end;

procedure TMangoHudTimeFormatDialog.PresetComboChange(Sender: TObject);
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    case FPresetCombo.ItemIndex of
      0: FFormatEdit.Text := '%T';
      1: FFormatEdit.Text := '%R';
      2: FFormatEdit.Text := '%r';
      3: FFormatEdit.Text := '%I:%M %p';
      4: FFormatEdit.Text := '%d/%m/%Y %H:%M';
      5: FFormatEdit.Text := '%Y-%m-%d %H:%M:%S';
    end;
    UpdatePreview;
  finally
    FUpdating := False;
  end;
  if FPresetCombo.ItemIndex in [0..5] then
    DoApply;
end;

procedure TMangoHudTimeFormatDialog.FormatEditChange(Sender: TObject);
var
  Txt: string;
begin
  if FUpdating then Exit;
  FUpdating := True;
  try
    Txt := Trim(FFormatEdit.Text);
    if Txt = '%T' then
      FPresetCombo.ItemIndex := 0
    else if Txt = '%R' then
      FPresetCombo.ItemIndex := 1
    else if Txt = '%r' then
      FPresetCombo.ItemIndex := 2
    else if Txt = '%I:%M %p' then
      FPresetCombo.ItemIndex := 3
    else if Txt = '%d/%m/%Y %H:%M' then
      FPresetCombo.ItemIndex := 4
    else if Txt = '%Y-%m-%d %H:%M:%S' then
      FPresetCombo.ItemIndex := 5
    else
      FPresetCombo.ItemIndex := 6; // Custom format...
    UpdatePreview;
  finally
    FUpdating := False;
  end;
end;

procedure TMangoHudTimeFormatDialog.UpdatePreview;
var
  S: string;
begin
  S := FormatTimePreview(FFormatEdit.Text);
  if S <> '' then
    FPreviewLabel.Caption := S
  else
    FPreviewLabel.Caption := '(empty)';
end;

function TMangoHudTimeFormatDialog.GetFormatString: string;
begin
  Result := Trim(FFormatEdit.Text);
  if Result = '' then
    Result := '%T';
end;

constructor TMangoHudUiHelper.Create(AForm: Tgoverlayform);
begin
  FForm := AForm;
  FVisualToggles  := TFPList.Create;
  FPerfToggles    := TFPList.Create;
  FMetricsToggles := TFPList.Create;
  FExtrasToggles  := TFPList.Create;
  FTimeFormat     := '%T';
end;

procedure TMangoHudUiHelper.TimeToggleChanged(Sender: TObject);
begin
  if Assigned(FTimeConfigBtn) and Assigned(FForm.timeCheckBox) then
    FTimeConfigBtn.Enabled := FForm.timeCheckBox.Checked;
end;

procedure TMangoHudUiHelper.NetworkToggleChanged(Sender: TObject);
begin
  if Assigned(FForm.networkComboBox) and Assigned(FForm.networkCheckBox) then
    FForm.networkComboBox.Enabled := FForm.networkCheckBox.Checked;
end;

procedure TMangoHudUiHelper.ApplyTimeFormat(const AFormat: string);
var
  WasRunning: Boolean;
  NewFmt: string;
begin
  NewFmt := Trim(AFormat);
  if NewFmt = '' then
    NewFmt := '%T';
  if FTimeFormat = NewFmt then
    Exit;

  FTimeFormat := NewFmt;
  SaveMangoHudConfig;

  WasRunning := IsProcessRunningPure('pascube');
  if WasRunning then
  begin
    ExecuteGUICommand('killall pascube 2>/dev/null; true');
    Sleep(100);
    FForm.PreviewBtnClick(nil);
  end;

  if Assigned(FForm.FFloatingToast) then
    FForm.FFloatingToast.ShowToast('Time format applied');
end;

procedure TMangoHudUiHelper.TimeConfigBtnClick(Sender: TObject);
var
  Dlg: TMangoHudTimeFormatDialog;
begin
  Dlg := TMangoHudTimeFormatDialog.Create(FForm, FTimeFormat, @ApplyTimeFormat);
  try
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TMangoHudUiHelper.ExtTempPillBtnClick(Sender: TObject);
begin
  with FForm do
  begin
    fahrenheitCheckBox.Checked := not fahrenheitCheckBox.Checked;
    GenericControlChange(fahrenheitCheckBox);
  end;
  RefreshFormatPills;
end;

destructor TMangoHudUiHelper.Destroy;
begin
  FreeAndNil(FVisualToggles);
  FreeAndNil(FPerfToggles);
  FreeAndNil(FMetricsToggles);
  FreeAndNil(FExtrasToggles);
  inherited Destroy;
end;

procedure TMangoHudUiHelper.SetFpsOnly(AValue: Boolean);
begin
  FFpsOnly := AValue;
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
  CORNER_R = 6;   // corners' rounding radius (px) — matches the modern card style
var
  Card: TPanel;
  BgClear, BgColor, BorderColor: TColor;
  PenW: Integer;
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

  // State palette — selected = elevated + glowing accent border (2px),
  // hovered = subtly lighter + soft border, normal = flat + faint border.
  if CurrentTheme = tmLight then
  begin
    BgClear := LighterBackgroundColor;
    if IsSelected then
    begin BgColor := RGBToColor(220, 232, 255); BorderColor := RGBToColor(46, 138, 216); PenW := 2; end
    else if IsHovered then
    begin BgColor := RGBToColor(228, 228, 238); BorderColor := RGBToColor(144, 144, 160); PenW := 1; end
    else
    begin BgColor := RGBToColor(242, 242, 242); BorderColor := RGBToColor(192, 192, 200); PenW := 1; end;
  end
  else
  begin
    BgClear := RGBToColor(22, 26, 40);   // wrapper navy — lets rounded corners blend
    if IsSelected then
    begin BgColor := RGBToColor(32, 44, 68); BorderColor := RGBToColor(56, 189, 248); PenW := 2; end
    else if IsHovered then
    begin BgColor := RGBToColor(48, 54, 76); BorderColor := RGBToColor(90, 110, 150); PenW := 1; end
    else
    begin BgColor := RGBToColor(32, 38, 56); BorderColor := RGBToColor(46, 56, 80); PenW := 1; end;
  end;

  // 1. Wipe the client area with the wrapper background so the pixels outside
  //    the rounded shape don't keep stale square corners.
  Card.Canvas.Brush.Color := BgClear;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgClear;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.FillRect(Card.ClientRect);

  {$IFDEF LCLqt6}
  if Card.Canvas.Handle <> 0 then
    TQtDeviceContext(Card.Canvas.Handle).setRenderHint(QPainterAntialiasing, True);
  {$ENDIF}

  // 2. Rounded background fill — child controls paint on top afterwards, so
  //    neither the fill nor the stroke ever clips the card's content.
  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.RoundRect(0, 0, Card.Width, Card.Height, CORNER_R * 2, CORNER_R * 2);

  // 3. Selection accent — a slim rounded bar hugging the bottom edge.
  if IsSelected then
  begin
    Card.Canvas.Brush.Color := BorderColor;
    Card.Canvas.Brush.Style := bsSolid;
    Card.Canvas.Pen.Color   := BorderColor;
    Card.Canvas.Pen.Width   := 1;
    Card.Canvas.RoundRect(CORNER_R, Card.Height - 7,
                          Card.Width - CORNER_R, Card.Height - 4,
                          CORNER_R, CORNER_R);
  end;

  // 4. Rounded border stroke on top of everything (inset by half the pen so
  //    the 2px glow stays fully inside the client area).
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := PenW;
  Card.Canvas.RoundRect(PenW, PenW, Card.Width - PenW, Card.Height - PenW,
                        CORNER_R * 2, CORNER_R * 2);

  // Restore defaults for any subsequent painting on this canvas.
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Brush.Style := bsSolid;
  end;
end;


procedure TMangoHudUiHelper.LimitSubCardPaint(Sender: TObject);
const
  DARK_BG     = $003C2822;  // rgb(34, 40, 60) — distinct elevated card surface
  DARK_BRD    = $00644638;  // rgb(56, 70, 100) — crisp, defined card border
  LIGHT_BG    = $00FCF8F6;  // rgb(246, 248, 252) — distinct light surface
  LIGHT_BRD   = $00D8C8BE;  // rgb(190, 200, 216) — crisp light border
  CORNER_R    = 8;
var
  Card: TPanel;
  BgClear, BgColor, BorderColor: TColor;
begin
  if not (Sender is TPanel) then Exit;
  Card := TPanel(Sender);

  if CurrentTheme = tmLight then
  begin
    BgClear     := $00F0F0F0;
    BgColor     := LIGHT_BG;
    BorderColor := LIGHT_BRD;
  end
  else
  begin
    BgClear     := $002E1E1A;  // Parent Card background rgb(26, 30, 46)
    BgColor     := DARK_BG;
    BorderColor := DARK_BRD;
  end;

  if Card.Parent is TWinControl then
    BgClear := TWinControl(Card.Parent).Color;

  // 1. Wipe client area with parent background for antialiasing
  Card.Canvas.Brush.Color := BgClear;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgClear;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.FillRect(Card.ClientRect);

  {$IFDEF LCLqt6}
  if Card.Canvas.Handle <> 0 then
    TQtDeviceContext(Card.Canvas.Handle).setRenderHint(QPainterAntialiasing, True);
  {$ENDIF}

  // 2. Rounded background fill
  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.RoundRect(0, 0, Card.Width, Card.Height, CORNER_R * 2, CORNER_R * 2);

  // 3. Rounded border stroke
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.RoundRect(1, 1, Card.Width - 1, Card.Height - 1, CORNER_R * 2, CORNER_R * 2);

  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Brush.Style := bsSolid;
end;


procedure TMangoHudUiHelper.VkNemuFlowCardPaint(Sender: TObject);
const
  DARK_BG      = $00241A14;  // rgb(20, 26, 36)
  DARK_BRD     = $003C3026;  // rgb(38, 48, 60)
  LIGHT_BG     = $00F0F5F2;  // rgb(242, 245, 240)
  LIGHT_BRD    = $00D0D5E0;
  CLR_EMERALD  = $006EE744;  // rgb(68, 231, 110)
  CLR_SLATE    = $00949AA8;  // rgb(168, 154, 148)
  CLR_ARROW    = $00808898;  // rgb(152, 136, 128)
  CLR_AMBER    = $0038C8F8;  // rgb(248, 200, 56)
  CORNER_R     = 8;
var
  Card: TPanel;
  BgClear, BgColor, BorderColor: TColor;
  Node1Color, Node2Color, SubColor, ArrowColor: TColor;
  IsEnabled: Boolean;
  W, H, X1, X2, X3, Arrow1X, Arrow2X: Integer;
  TitleY, SubY, ArrowY: Integer;
  IdleFps, TimeoutVal, DelayVal: Integer;
  InputModeStr: string;

  procedure DrawCentered(ACenterX, AY: Integer; const AText: string;
                         ASize: Integer; AStyle: TFontStyles; AColor: TColor);
  begin
    Card.Canvas.Font.Name    := 'Noto Sans';
    Card.Canvas.Font.Size    := ASize;
    Card.Canvas.Font.Style   := AStyle;
    Card.Canvas.Font.Color   := AColor;
    Card.Canvas.Font.Quality := fqAntialiased;
    Card.Canvas.Brush.Style  := bsClear;
    Card.Canvas.TextOut(ACenterX - (Card.Canvas.TextWidth(AText) div 2), AY, AText);
  end;

begin
  if not (Sender is TPanel) then Exit;
  Card := TPanel(Sender);

  if CurrentTheme = tmLight then
  begin
    BgClear     := $00F0F0F0;
    BgColor     := LIGHT_BG;
    BorderColor := LIGHT_BRD;
  end
  else
  begin
    BgClear     := $002E1E1A;
    BgColor     := DARK_BG;
    BorderColor := DARK_BRD;
  end;

  IsEnabled := Assigned(FForm.FVkNemuCheckBox) and FForm.FVkNemuCheckBox.Checked;
  if not IsEnabled then
  begin
    if CurrentTheme = tmLight then
    begin
      BgColor     := $00E6E8EB;
      BorderColor := $00C0C6D0;
    end
    else
    begin
      BgColor     := $001A1410;
      BorderColor := $002E241C;
    end;
  end;

  if IsEnabled then
  begin
    Node1Color := CLR_EMERALD;
    Node2Color := CLR_AMBER;
    SubColor   := CLR_SLATE;
    ArrowColor := CLR_ARROW;
  end
  else
  begin
    Node1Color := $00646E82;
    Node2Color := $00646E82;
    SubColor   := $004A5260;
    ArrowColor := $00424A56;
  end;

  if Card.Parent is TWinControl then
    BgClear := TWinControl(Card.Parent).Color;

  W := Card.ClientWidth;
  H := Card.ClientHeight;

  // Clear the client area so rounded corners blend with the parent surface.
  Card.Canvas.Brush.Color := BgClear;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgClear;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.FillRect(Card.ClientRect);

  {$IFDEF LCLqt6}
  if Card.Canvas.Handle <> 0 then
    TQtDeviceContext(Card.Canvas.Handle).setRenderHint(QPainterAntialiasing, True);
  {$ENDIF}

  // Rounded surface fill.
  Card.Canvas.Brush.Color := BgColor;
  Card.Canvas.Brush.Style := bsSolid;
  Card.Canvas.Pen.Color   := BgColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.RoundRect(0, 0, W, H, CORNER_R, CORNER_R);

  // Rounded border stroke.
  Card.Canvas.Brush.Style := bsClear;
  Card.Canvas.Pen.Color   := BorderColor;
  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.RoundRect(1, 1, W - 1, H - 1, CORNER_R, CORNER_R);

  // Live values
  if Assigned(FForm.FVkNemuIdleFpsSpin) then
    IdleFps := FForm.FVkNemuIdleFpsSpin.Value
  else
    IdleFps := 30;
  if Assigned(FForm.FVkNemuTimeoutSpin) then
    TimeoutVal := FForm.FVkNemuTimeoutSpin.Value
  else
    TimeoutVal := 2;
  if Assigned(FForm.FVkNemuDelaySpin) then
    DelayVal := FForm.FVkNemuDelaySpin.Value
  else
    DelayVal := 0;
  if Assigned(FForm.FVkNemuInputCombo) and (Trim(FForm.FVkNemuInputCombo.Text) <> '') then
    InputModeStr := LowerCase(Trim(FForm.FVkNemuInputCombo.Text))
  else
    InputModeStr := 'all';

  // Flow geometry
  X2       := W div 2;
  X1       := 56;
  X3       := W - 56;
  Arrow1X  := (X1 + X2) div 2;
  Arrow2X  := (X2 + X3) div 2;
  TitleY   := 9;
  SubY     := 30;
  ArrowY   := 19;

  // Node 1: Active Game
  DrawCentered(X1, TitleY, 'Active Game', 9, [fsBold], Node1Color);
  DrawCentered(X1, SubY, 'Max FPS', 8, [], SubColor);

  // Arrow 1: idle timeout
  DrawCentered(Arrow1X, ArrowY, Format('-[ %ds ]->', [TimeoutVal]), 8, [], ArrowColor);

  // Node 2: Standby
  DrawCentered(X2, TitleY, 'Standby', 9, [fsBold], Node2Color);
  DrawCentered(X2, SubY, Format('%d FPS', [IdleFps]), 8, [fsBold], SubColor);

  // Arrow 2: wake input mode
  DrawCentered(Arrow2X, ArrowY, Format('-[ %s ]->', [InputModeStr]), 8, [], ArrowColor);

  // Node 3: Resume
  DrawCentered(X3, TitleY, 'Resume', 9, [fsBold], Node1Color);
  DrawCentered(X3, SubY, Format('%ds delay', [DelayVal]), 8, [], SubColor);

  Card.Canvas.Pen.Width   := 1;
  Card.Canvas.Brush.Style := bsSolid;
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
      if i in [0..3] then
        ResetMetricGraphs;
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
  HDR      = ACCENT_H + TITLE_T + TITLE_H + 3;  // = 34

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

var
  IsLight: Boolean;
  BarBg, TextColor: TColor;
  SS: WideString;
  BgBox: TPaintBox;
begin
  FVisHoverAnchor := -1;
  with FForm do
  begin
  BgBox := TPaintBox.Create(FForm);
  BgBox.Parent  := visualTabSheet;
  BgBox.Align   := alClient;
  BgBox.OnPaint := @FForm.PresetsBgBoxPaint;

  IsLight   := CurrentTheme = tmLight;
  BarBg     := IfThen(IsLight, $00F2F2F2, $00362E2E);
  TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

  FVisualHudBar := nil;
  FVisualGpuBar := nil;
  FVisualHudSep := nil;

  // ── Six independent cards, direct children of visualTabSheet ─────────────
  FVisTitleSec := TPanel.Create(FForm);
  FVisTitleSec.Parent  := visualTabSheet;
  FVisTitleSec.Caption := '';
  FVisTitleSec.OnPaint := @FForm.SubCardPaint;
  FVisTitleSubLbl := TLabel.Create(FVisTitleSec);
  FVisTitleSubLbl.Parent := FVisTitleSec;
  StyleMainCard(FVisTitleSec, FVisTitleSubLbl, 'HUD Header && Title');

  FVisTypographySec := TPanel.Create(FForm);
  FVisTypographySec.Parent  := visualTabSheet;
  FVisTypographySec.Caption := '';
  FVisTypographySec.OnPaint := @FForm.SubCardPaint;
  FVisTypoSubLbl := TLabel.Create(FVisTypographySec);
  FVisTypoSubLbl.Parent := FVisTypographySec;
  StyleMainCard(FVisTypographySec, FVisTypoSubLbl, 'Typography');

  FVisCanvasSec := TPanel.Create(FForm);
  FVisCanvasSec.Parent  := visualTabSheet;
  FVisCanvasSec.Caption := '';
  FVisCanvasSec.OnPaint := @FForm.SubCardPaint;
  FVisCanvasSubLbl := TLabel.Create(FVisCanvasSec);
  FVisCanvasSubLbl.Parent := FVisCanvasSec;
  StyleMainCard(FVisCanvasSec, FVisCanvasSubLbl, 'Canvas && Frame');

  FVisScreenSec := TPanel.Create(FForm);
  FVisScreenSec.Parent  := visualTabSheet;
  FVisScreenSec.Caption := '';
  FVisScreenSec.OnPaint := @FForm.SubCardPaint;
  FVisScreenSubLbl := TLabel.Create(FVisScreenSec);
  FVisScreenSubLbl.Parent := FVisScreenSec;
  StyleMainCard(FVisScreenSec, FVisScreenSubLbl, 'Screen Placement');

  FVisFlowSec := TPanel.Create(FForm);
  FVisFlowSec.Parent  := visualTabSheet;
  FVisFlowSec.Caption := '';
  FVisFlowSec.OnPaint := @FForm.SubCardPaint;
  FVisFlowSubLbl := TLabel.Create(FVisFlowSec);
  FVisFlowSubLbl.Parent := FVisFlowSec;
  StyleMainCard(FVisFlowSec, FVisFlowSubLbl, 'Flow && Grid');

  FVisSystemSec := TPanel.Create(FForm);
  FVisSystemSec.Parent  := visualTabSheet;
  FVisSystemSec.Caption := '';
  FVisSystemSec.OnPaint := @FForm.SubCardPaint;
  FVisSystemSubLbl := TLabel.Create(FVisSystemSec);
  FVisSystemSubLbl.Parent := FVisSystemSec;
  StyleMainCard(FVisSystemSec, FVisSystemSubLbl, 'Display && System');

  FVisualCards[0] := FVisTitleSec;
  FVisualCards[1] := FVisTypographySec;
  FVisualCards[2] := FVisCanvasSec;
  FVisualCards[3] := FVisScreenSec;
  FVisualCards[4] := FVisFlowSec;
  FVisualCards[5] := FVisSystemSec;
  FVisAppearanceCard := FVisTitleSec;
  FVisLayoutCard := FVisScreenSec;

  Place(verticalRadioButton, FVisFlowSec, -100, -100);
  Place(horizontalRadioButton, FVisFlowSec, -100, -100);
  Place(squareRadioButton, FVisCanvasSec, -100, -100);
  Place(roundRadioButton, FVisCanvasSec, -100, -100);
  verticalRadioButton.Visible := False;
  horizontalRadioButton.Visible := False;
  squareRadioButton.Visible   := False;
  roundRadioButton.Visible    := False;
  pcidevComboBox.Visible := True;
  pcidevComboBox.Parent  := FVisSystemSec;
  hudonoffComboBox.Visible    := False;

  // ── Controls: Appearance Card ────────────────────────────────────────────
  // HUD Title
  FVisHudTitleLbl := TLabel.Create(FVisTitleSec);
  FVisHudTitleLbl.Parent      := FVisTitleSec;
  FVisHudTitleLbl.Caption     := 'HUD Title:';
  FVisHudTitleLbl.Font.Color  := TextColor;
  FVisHudTitleLbl.Transparent := True;
  Place(hudtitleEdit, FVisTitleSec, 12, 42);
  hudtitleEdit.Parent      := FVisTitleSec;
  hudtitleEdit.Color       := BarBg;
  hudtitleEdit.Font.Color  := TextColor;
  hudtitleEdit.BorderStyle := bsSingle;
  hudtitleEdit.Height      := 28;

  // Typography Sub-Panel controls
  FVisFontFamilyLbl := TLabel.Create(FVisTypographySec);
  FVisFontFamilyLbl.Parent      := FVisTypographySec;
  FVisFontFamilyLbl.Caption     := 'Font family:';
  FVisFontFamilyLbl.Font.Color  := TextColor;
  FVisFontFamilyLbl.Transparent := True;
  Place(fontComboBox, FVisTypographySec, 10, 36);
  fontComboBox.Height := 28;

  FVisFontColorLbl := TLabel.Create(FVisTypographySec);
  FVisFontColorLbl.Parent      := FVisTypographySec;
  FVisFontColorLbl.Caption     := 'Color:';
  FVisFontColorLbl.Font.Color  := TextColor;
  FVisFontColorLbl.Transparent := True;
  Place(FontcolorButton, FVisTypographySec, 50, 72);
  FontcolorButton.Color := BarBg;
  FontcolorButton.SetBounds(50, 72, 28, 24);
  fontcolorLabel.Visible := False;

  FVisOutlineLbl := TLabel.Create(FVisTypographySec);
  FVisOutlineLbl.Parent      := FVisTypographySec;
  FVisOutlineLbl.Caption     := 'Text outline';
  FVisOutlineLbl.Font.Color  := TextColor;
  FVisOutlineLbl.Transparent := True;

  if not Assigned(textoutlineCheckBox) then
  begin
    textoutlineCheckBox := TCheckBox.Create(FVisTypographySec);
    textoutlineCheckBox.Name := 'textoutlineCheckBox';
    textoutlineCheckBox.Parent := FVisTypographySec;
    textoutlineCheckBox.Caption := 'Text outline';
    textoutlineCheckBox.Visible := False;
  end;
  textoutlineCheckBox.Hint := 'Text outline' + LineEnding + 'Renders high-contrast outline around text';
  textoutlineCheckBox.ShowHint := True;
  FtextoutlineToggle := TToggleSwitch.Create(FForm);
  FtextoutlineToggle.Parent := FVisTypographySec;
  FtextoutlineToggle.LinkToCheckBox(textoutlineCheckBox);
  FtextoutlineToggle.Caption := '';
  FtextoutlineToggle.Height := 20;
  FtextoutlineToggle.Width  := FtextoutlineToggle.GetOptimalWidth;
  FVisualToggles.Add(FtextoutlineToggle);

  FVisFontSizeLbl := TLabel.Create(FVisTypographySec);
  FVisFontSizeLbl.Parent      := FVisTypographySec;
  FVisFontSizeLbl.Caption     := 'Size:';
  FVisFontSizeLbl.Font.Color  := TextColor;
  FVisFontSizeLbl.Transparent := True;
  fontLabel.Visible := False;

  Place(fontsizeTrackBar, FVisTypographySec, 50, 106);
  fontsizeTrackBar.Color := BarBg;
  fontsizeTrackBar.ParentColor := False;
  fontsizeTrackBar.TickStyle := tsNone;

  Place(fontsizevalueLabel, FVisTypographySec, 200, 108);
  fontsizevalueLabel.Font.Color   := CLR_TEXT_ACCENT;
  fontsizevalueLabel.Font.Style   := [fsBold];
  fontsizevalueLabel.Transparent := True;

  // Canvas & Frame Sub-Panel controls
  FVisBgColorLbl := TLabel.Create(FVisCanvasSec);
  FVisBgColorLbl.Parent      := FVisCanvasSec;
  FVisBgColorLbl.Caption     := 'Background color:';
  FVisBgColorLbl.Font.Color  := TextColor;
  FVisBgColorLbl.Transparent := True;
  backgroundLabel.Visible := False;
  Place(hudbackgroundColorButton, FVisCanvasSec, 130, 30);
  hudbackgroundColorButton.Color := BarBg;
  hudbackgroundColorButton.SetBounds(130, 30, 28, 24);

  FVisBorderPillLbl := TLabel.Create(FVisCanvasSec);
  FVisBorderPillLbl.Parent      := FVisCanvasSec;
  FVisBorderPillLbl.Caption     := 'Corners:';
  FVisBorderPillLbl.Font.Color  := TextColor;
  FVisBorderPillLbl.Transparent := True;

  FVisBorderPillBtn := TBitBtn.Create(FVisCanvasSec);
  FVisBorderPillBtn.Parent  := FVisCanvasSec;
  FVisBorderPillBtn.Cursor  := crHandPoint;
  FVisBorderPillBtn.OnClick := @VisBorderPillBtnClick;

  FVisAlphaLbl := TLabel.Create(FVisCanvasSec);
  FVisAlphaLbl.Parent      := FVisCanvasSec;
  FVisAlphaLbl.Caption     := 'Opacity:';
  FVisAlphaLbl.Font.Color  := TextColor;
  FVisAlphaLbl.Transparent := True;
  transparencyLabel.Visible := False;

  Place(transpTrackBar, FVisCanvasSec, 66, 68);
  transpTrackBar.Color := BarBg;
  transpTrackBar.ParentColor := False;
  transpTrackBar.TickStyle := tsNone;

  Place(alphavalueLabel, FVisCanvasSec, 200, 70);
  alphavalueLabel.Font.Color   := CLR_TEXT_ACCENT;
  alphavalueLabel.Font.Style   := [fsBold];
  alphavalueLabel.Transparent := True;

  FVisRadiusLbl := TLabel.Create(FVisCanvasSec);
  FVisRadiusLbl.Parent      := FVisCanvasSec;
  FVisRadiusLbl.Caption     := 'Corner radius:';
  FVisRadiusLbl.Font.Color  := TextColor;
  FVisRadiusLbl.Transparent := True;

  FroundradiusTrackBar := TTrackBar.Create(FVisCanvasSec);
  FroundradiusTrackBar.Parent     := FVisCanvasSec;
  FroundradiusTrackBar.Min        := 0;
  FroundradiusTrackBar.Max        := 25;
  FroundradiusTrackBar.Position   := 10;
  FroundradiusTrackBar.TickStyle  := tsNone;
  FroundradiusTrackBar.Color      := BarBg;
  FroundradiusTrackBar.ParentColor := False;
  FroundradiusTrackBar.OnChange   := @RoundRadiusTrackBarChange;

  FroundradiusvalueLabel := TLabel.Create(FVisCanvasSec);
  FroundradiusvalueLabel.Parent      := FVisCanvasSec;
  FroundradiusvalueLabel.Caption     := '10px';
  FroundradiusvalueLabel.Font.Color  := CLR_TEXT_ACCENT;
  FroundradiusvalueLabel.Font.Style  := [fsBold];
  FroundradiusvalueLabel.Transparent := True;

  // ── Controls: Layout Card ────────────────────────────────────────────────
  // Screen Placement Sub-Panel controls
  Place(topleftRadioButton,      FVisScreenSec, 10, 30);
  Place(topcenterRadioButton,    FVisScreenSec, 50, 30);
  Place(toprightRadioButton,     FVisScreenSec, 90, 30);
  Place(middleleftRadioButton,   FVisScreenSec, 10, 80);
  Place(middlerightRadioButton,  FVisScreenSec, 90, 80);
  Place(bottomleftRadioButton,   FVisScreenSec, 10, 130);
  Place(bottomcenterRadioButton, FVisScreenSec, 50, 130);
  Place(bottomrightRadioButton,  FVisScreenSec, 90, 130);

  topleftRadioButton.Visible      := False;
  topcenterRadioButton.Visible    := False;
  toprightRadioButton.Visible     := False;
  middleleftRadioButton.Visible   := False;
  middlerightRadioButton.Visible  := False;
  bottomleftRadioButton.Visible   := False;
  bottomcenterRadioButton.Visible := False;
  bottomrightRadioButton.Visible  := False;

  FVisMonitorPaintBox := TPaintBox.Create(FVisScreenSec);
  FVisMonitorPaintBox.Parent      := FVisScreenSec;
  FVisMonitorPaintBox.OnPaint     := @VisMonitorPaintBoxPaint;
  FVisMonitorPaintBox.OnMouseMove := @VisMonitorPaintBoxMouseMove;
  FVisMonitorPaintBox.OnMouseDown := @VisMonitorPaintBoxMouseDown;
  FVisMonitorPaintBox.OnMouseLeave := @VisMonitorPaintBoxMouseLeave;

  // Dedicated, uncluttered offset inputs placed below monitor
  FVisOffsetXSubLbl := TLabel.Create(FVisScreenSec);
  FVisOffsetXSubLbl.Parent      := FVisScreenSec;
  FVisOffsetXSubLbl.Caption     := 'Offset X:';
  FVisOffsetXSubLbl.Font.Color  := TextColor;
  FVisOffsetXSubLbl.Transparent := True;
  offsetxSpinEdit.Parent := FVisScreenSec;
  offsetxSpinEdit.AnchorSideLeft.Control := nil; offsetxSpinEdit.AnchorSideTop.Control := nil;
  offsetxSpinEdit.Anchors     := [akLeft, akTop];
  offsetxSpinEdit.Font.Name   := 'Noto Sans';
  offsetxSpinEdit.Font.Size   := 8;
  offsetxSpinEdit.Font.Height := 0;
  offsetxSpinEdit.Font.Style  := [fsBold];
  offsetxSpinEdit.Font.Color  := clWhite;
  offsetxSpinEdit.Width       := 60;
  offsetxSpinEdit.Height      := 22;

  FVisOffsetYSubLbl := TLabel.Create(FVisScreenSec);
  FVisOffsetYSubLbl.Parent      := FVisScreenSec;
  FVisOffsetYSubLbl.Caption     := 'Offset Y:';
  FVisOffsetYSubLbl.Font.Color  := TextColor;
  FVisOffsetYSubLbl.Transparent := True;
  offsetySpinEdit.Parent := FVisScreenSec;
  offsetySpinEdit.AnchorSideLeft.Control := nil; offsetySpinEdit.AnchorSideTop.Control := nil;
  offsetySpinEdit.Anchors     := [akLeft, akTop];
  offsetySpinEdit.Font.Name   := 'Noto Sans';
  offsetySpinEdit.Font.Size   := 8;
  offsetySpinEdit.Font.Height := 0;
  offsetySpinEdit.Font.Style  := [fsBold];
  offsetySpinEdit.Font.Color  := clWhite;
  offsetySpinEdit.Width       := 60;
  offsetySpinEdit.Height      := 22;

  // Flow & Grid Sub-Panel controls
  FVisOrientPillLbl := TLabel.Create(FVisFlowSec);
  FVisOrientPillLbl.Parent      := FVisFlowSec;
  FVisOrientPillLbl.Caption     := 'Orientation:';
  FVisOrientPillLbl.Font.Color  := TextColor;
  FVisOrientPillLbl.Transparent := True;

  FVisOrientPillBtn := TBitBtn.Create(FVisFlowSec);
  FVisOrientPillBtn.Parent  := FVisFlowSec;
  FVisOrientPillBtn.Cursor  := crHandPoint;
  FVisOrientPillBtn.OnClick := @VisOrientPillBtnClick;

  FVisColumnsSubLbl := TLabel.Create(FVisFlowSec);
  FVisColumnsSubLbl.Parent      := FVisFlowSec;
  FVisColumnsSubLbl.Caption     := 'Columns:';
  FVisColumnsSubLbl.Font.Color  := TextColor;
  FVisColumnsSubLbl.Transparent := True;

  minusButton.Visible := False;
  plusSpeedButton.Visible := False;

  Self.FColumnsMinusBtn := TBitBtn.Create(FVisFlowSec);
  FForm.FColumnsMinusBtn := Self.FColumnsMinusBtn;
  Self.FColumnsMinusBtn.Parent := FVisFlowSec;
  Self.FColumnsMinusBtn.Caption := '-';
  Self.FColumnsMinusBtn.Font.Size := 13;
  Self.FColumnsMinusBtn.Font.Style := [fsBold];
  Self.FColumnsMinusBtn.Font.Color := TextColor;
  Self.FColumnsMinusBtn.OnClick := @FForm.minusButtonClick;
  Self.FColumnsMinusBtn.Cursor := crHandPoint;
  Self.FColumnsMinusBtn.SetBounds(74, 68, 24, 24);

  Place(columvalueLabel, FVisFlowSec, 100, 70);
  columvalueLabel.AutoSize := False;
  columvalueLabel.Alignment := taCenter;
  columvalueLabel.SetBounds(100, 68, 32, 24);
  columvalueLabel.Font.Color := TextColor;
  columvalueLabel.Transparent := True;

  Self.FColumnsPlusBtn := TBitBtn.Create(FVisFlowSec);
  FForm.FColumnsPlusBtn := Self.FColumnsPlusBtn;
  Self.FColumnsPlusBtn.Parent := FVisFlowSec;
  Self.FColumnsPlusBtn.Caption := '+';
  Self.FColumnsPlusBtn.Font.Size := 13;
  Self.FColumnsPlusBtn.Font.Style := [fsBold];
  Self.FColumnsPlusBtn.Font.Color := TextColor;
  Self.FColumnsPlusBtn.OnClick := @FForm.plusSpeedButtonClick;
  Self.FColumnsPlusBtn.Cursor := crHandPoint;
  Self.FColumnsPlusBtn.SetBounds(134, 68, 24, 24);

  StyleBitBtnTheme(Self.FColumnsMinusBtn, TextColor, BarBg);
  StyleBitBtnTheme(Self.FColumnsPlusBtn, TextColor, BarBg);

  FVisColumnsPaintBox := TPaintBox.Create(FVisFlowSec);
  FVisColumnsPaintBox.Parent  := FVisFlowSec;
  FVisColumnsPaintBox.OnPaint := @VisColumnsPaintBoxPaint;
  FVisColumnsPaintBox.SetBounds(166, 70, 72, 20);
  FVisColumnsPaintBox.ShowHint := True;
  FVisColumnsPaintBox.Hint := 'Active HUD columns (1 to 6)';

  FVisStretchLbl := TLabel.Create(FVisFlowSec);
  FVisStretchLbl.Parent      := FVisFlowSec;
  FVisStretchLbl.Caption     := 'Horizontal stretch';
  FVisStretchLbl.Font.Color  := TextColor;
  FVisStretchLbl.Transparent := True;

  if not Assigned(horizontalstrechCheckBox) then
  begin
    horizontalstrechCheckBox := TCheckBox.Create(FVisFlowSec);
    horizontalstrechCheckBox.Parent := FVisFlowSec;
    horizontalstrechCheckBox.Caption := 'Horizontal Strech';
    horizontalstrechCheckBox.Visible := False;
  end;
  FhorizontalstrechToggle := TToggleSwitch.Create(FForm);
  FhorizontalstrechToggle.Parent := FVisFlowSec;
  FhorizontalstrechToggle.LinkToCheckBox(horizontalstrechCheckBox);
  FhorizontalstrechToggle.Caption := '';
  FhorizontalstrechToggle.Height := 20;
  FhorizontalstrechToggle.Width  := FhorizontalstrechToggle.GetOptimalWidth;
  FVisualToggles.Add(FhorizontalstrechToggle);

  // ── Controls: System & Hotkey Sub-Card ───────────────────────────────────
  FVisShortcutLbl := TLabel.Create(FVisSystemSec);
  FVisShortcutLbl.Parent      := FVisSystemSec;
  FVisShortcutLbl.Caption     := 'HUD Toggle:';
  FVisShortcutLbl.Font.Color  := TextColor;
  FVisShortcutLbl.Transparent := True;

  FVisualCaptureBtn := TBitBtn.Create(FVisSystemSec);
  FVisualCaptureBtn.Parent  := FVisSystemSec;
  FVisualCaptureBtn.Tag     := 1; // Visual Tab
  FVisualCaptureBtn.SetBounds(90, 64, 126, 28);
  FVisualCaptureBtn.OnClick := @FForm.CaptureBtnClick;
  FVisualCaptureBtn.Cursor  := crHandPoint;
  FVisualCaptureBtn.Font.Color := TextColor;
  if Trim(hudonoffComboBox.Text) <> '' then
    FVisualCaptureBtn.Caption := '⌨ ' + hudonoffComboBox.Text
  else
    FVisualCaptureBtn.Caption := '⌨ Capture';
  StyleBitBtnTheme(FVisualCaptureBtn, TextColor, BarBg);

  FVisCompactLbl := TLabel.Create(FVisCanvasSec);
  FVisCompactLbl.Parent      := FVisCanvasSec;
  FVisCompactLbl.Caption     := 'Compact';
  FVisCompactLbl.Font.Color  := TextColor;
  FVisCompactLbl.Transparent := True;

  FVisNoMarginLbl := TLabel.Create(FVisCanvasSec);
  FVisNoMarginLbl.Parent      := FVisCanvasSec;
  FVisNoMarginLbl.Caption     := 'No outer margins';
  FVisNoMarginLbl.Font.Color  := TextColor;
  FVisNoMarginLbl.Transparent := True;

  FhudcompactToggle := TToggleSwitch.Create(FForm);
  FhudcompactToggle.Parent := FVisCanvasSec;
  FhudcompactToggle.LinkToCheckBox(hudcompactCheckBox);
  FhudcompactToggle.Caption := '';
  FhudcompactToggle.Height := 20;
  FhudcompactToggle.Width  := FhudcompactToggle.GetOptimalWidth;
  FVisualToggles.Add(FhudcompactToggle);

  FhudnomarginToggle := TToggleSwitch.Create(FForm);
  FhudnomarginToggle.Parent := FVisCanvasSec;
  FhudnomarginToggle.Caption := '';
  FhudnomarginToggle.Height := 20;
  FhudnomarginToggle.Width  := FhudnomarginToggle.GetOptimalWidth;
  FhudnomarginToggle.OnChange := @FForm.GenericControlChange;
  FVisualToggles.Add(FhudnomarginToggle);

  FVisHideLbl := TLabel.Create(FVisSystemSec);
  FVisHideLbl.Parent      := FVisSystemSec;
  FVisHideLbl.Caption     := 'Hide by default';
  FVisHideLbl.Font.Color  := TextColor;
  FVisHideLbl.Transparent := True;

  FhidehudToggle := TToggleSwitch.Create(FForm);
  FhidehudToggle.Parent := FVisSystemSec;
  FhidehudToggle.LinkToCheckBox(hidehudCheckBox);
  FhidehudToggle.Caption := '';
  FhidehudToggle.Height := 20;
  FhidehudToggle.Width  := FhidehudToggle.GetOptimalWidth;
  FVisualToggles.Add(FhidehudToggle);

  FVisGpuBarLbl := TLabel.Create(FVisSystemSec);
  FVisGpuBarLbl.Parent      := FVisSystemSec;
  FVisGpuBarLbl.Caption     := 'Active GPU:';
  FVisGpuBarLbl.Font.Color  := TextColor;
  FVisGpuBarLbl.Transparent := True;

  pcidevComboBox.Parent := FVisSystemSec;
  pcidevComboBox.AnchorSideLeft.Control  := nil;
  pcidevComboBox.AnchorSideTop.Control   := nil;
  pcidevComboBox.AnchorSideRight.Control := nil;
  pcidevComboBox.Anchors := [akLeft, akTop];
  pcidevComboBox.Height  := 28;
  pcidevComboBox.Color       := BarBg;
  pcidevComboBox.Font.Color  := TextColor;
  SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
  QWidget_setStyleSheet(TQtWidget(pcidevComboBox.Handle).Widget, @SS);

  SyncVisualPills;
  SyncFlowGridVisibility;
  end;
end;


procedure TMangoHudUiHelper.ReflowVisualTab(AContentW, AContentH: Integer);
const
  MARGIN     = 4;
  GAP        = 8;
  TABBAR_H   = 35;
var
  W, ColW, RightColW, TabH, ActiveCardsH, InnerW: Integer;
  LeftTop3, LeftH3, RightH3: Integer;
  CY, HalfW, StartLeft, MonH: Integer;
begin
  with FForm do
  begin
  if not Assigned(FVisTitleSec) then Exit;

  W := AContentW - 2 * MARGIN;
  if W < 100 then Exit;

  TabH := Max(600, AContentH - TABBAR_H);
  ActiveCardsH := Max(520, TabH - 2 * MARGIN);
  ColW := (W - GAP) div 2;
  RightColW := W - ColW - GAP;
  LeftTop3 := MARGIN + 260 + 2 * GAP;
  LeftH3 := Max(130, ActiveCardsH - LeftTop3 + MARGIN);
  RightH3 := LeftH3;

  // ── Left column: Title, Typography, Canvas ──────────────────────────────
  if Assigned(FVisTitleSec) then
    FVisTitleSec.SetBounds(MARGIN, MARGIN, ColW, 95);
  if Assigned(FVisTypographySec) then
    FVisTypographySec.SetBounds(MARGIN, MARGIN + 95 + GAP, ColW, 165);
  if Assigned(FVisCanvasSec) then
    FVisCanvasSec.SetBounds(MARGIN, LeftTop3, ColW, LeftH3);

  // ── Right column: Flow, System, Screen ──────────────────────────────────
  if Assigned(FVisFlowSec) then
    FVisFlowSec.SetBounds(MARGIN + ColW + GAP, MARGIN, RightColW, 95);
  if Assigned(FVisSystemSec) then
    FVisSystemSec.SetBounds(MARGIN + ColW + GAP, MARGIN + 95 + GAP, RightColW, 165);
  if Assigned(FVisScreenSec) then
    FVisScreenSec.SetBounds(MARGIN + ColW + GAP, LeftTop3, RightColW, RightH3);

  // ── Card 1: HUD Header & Title ──────────────────────────────────────────
  InnerW := ColW - 16;
  if Assigned(FVisTitleSec) then
  begin
    if Assigned(FVisHudTitleLbl) then FVisHudTitleLbl.SetBounds(12, 36, 80, 20);
    hudtitleEdit.SetBounds(92, 32, Max(80, InnerW - 84), 26);
  end;

  // ── Card 2: Typography ──────────────────────────────────────────────────
  if Assigned(FVisTypographySec) then
  begin
    if Assigned(FVisFontFamilyLbl) then FVisFontFamilyLbl.SetBounds(10, 34, 80, 20);
    fontComboBox.SetBounds(90, 32, Max(60, InnerW - 100), 26);

    if Assigned(FVisFontColorLbl) then FVisFontColorLbl.SetBounds(10, 74, 44, 20);
    FontcolorButton.SetBounds(56, 72, 28, 24);

    if Assigned(FVisOutlineLbl) then FVisOutlineLbl.SetBounds(Max(10, InnerW - 130), 74, 84, 20);
    if Assigned(FtextoutlineToggle) then FtextoutlineToggle.SetBounds(Max(100, InnerW - 42), 72, 30, 20);

    if Assigned(FVisFontSizeLbl) then FVisFontSizeLbl.SetBounds(10, 118, 60, 20);
    fontsizeTrackBar.SetBounds(72, 116, Max(30, InnerW - 124), 24);
    fontsizevalueLabel.SetBounds(Max(80, InnerW - 46), 118, 38, 20);
  end;

  // ── Card 3: Canvas & Frame ──────────────────────────────────────────────
  if Assigned(FVisCanvasSec) then
  begin
    // Row 1: corners (border style)
    if Assigned(FVisBorderPillLbl) then FVisBorderPillLbl.SetBounds(10, 34, 60, 20);
    if Assigned(FVisBorderPillBtn) then
      FVisBorderPillBtn.SetBounds(90, 30, FVisBorderPillBtn.Width, 26);

    // Row 2: corner radius
    if Assigned(FVisRadiusLbl) then FVisRadiusLbl.SetBounds(10, 74, 90, 20);
    if Assigned(FroundradiusTrackBar) then
      FroundradiusTrackBar.SetBounds(102, 72, Max(30, InnerW - 156), 24);
    if Assigned(FroundradiusvalueLabel) then
      FroundradiusvalueLabel.SetBounds(Max(80, InnerW - 46), 74, 38, 20);

    // Row 3: background color
    if Assigned(FVisBgColorLbl) then FVisBgColorLbl.SetBounds(10, 116, 112, 20);
    hudbackgroundColorButton.SetBounds(130, 114, 28, 24);

    // Row 4: opacity
    if Assigned(FVisAlphaLbl) then FVisAlphaLbl.SetBounds(10, 156, 54, 20);
    transpTrackBar.SetBounds(66, 154, Max(30, InnerW - 120), 24);
    alphavalueLabel.SetBounds(Max(80, InnerW - 46), 156, 38, 20);

    // Row 5: compact & no outer margins
    if Assigned(FVisCompactLbl) then FVisCompactLbl.SetBounds(10, 196, 60, 20);
    if Assigned(FhudcompactToggle) then FhudcompactToggle.SetBounds(72, 194, 30, 20);
    if Assigned(FVisNoMarginLbl) then
      FVisNoMarginLbl.SetBounds(Max(10, InnerW - 146), 196, 108, 20);
    if Assigned(FhudnomarginToggle) then
      FhudnomarginToggle.SetBounds(Max(10, InnerW - 36), 194, 30, 20);
  end;

  // ── Card 4: Flow & Grid ─────────────────────────────────────────────────
  InnerW := RightColW - 16;
  if Assigned(FVisFlowSec) then
  begin
    if Assigned(FVisFlowSubLbl) then FVisFlowSubLbl.SetBounds(12, 8, 200, 22);
    if Assigned(FVisOrientPillLbl) then FVisOrientPillLbl.SetBounds(12, 34, 80, 20);
    if Assigned(FVisOrientPillBtn) then FVisOrientPillBtn.SetBounds(92, 30, FVisOrientPillBtn.Width, 26);

    if Assigned(FVisColumnsSubLbl) then FVisColumnsSubLbl.SetBounds(12, 64, 58, 20);
    if Assigned(FColumnsMinusBtn) then FColumnsMinusBtn.SetBounds(74, 61, 24, 24);
    if Assigned(FForm.FColumnsMinusBtn) then FForm.FColumnsMinusBtn.SetBounds(74, 61, 24, 24);
    columvalueLabel.AutoSize := False;
    columvalueLabel.Alignment := taCenter;
    columvalueLabel.SetBounds(100, 63, 28, 20);
    if Assigned(FColumnsPlusBtn) then FColumnsPlusBtn.SetBounds(130, 61, 24, 24);
    if Assigned(FForm.FColumnsPlusBtn) then FForm.FColumnsPlusBtn.SetBounds(130, 61, 24, 24);
    if Assigned(FVisColumnsPaintBox) then FVisColumnsPaintBox.SetBounds(162, 63, 50, 20);

    if Assigned(FVisStretchLbl) then FVisStretchLbl.SetBounds(12, 64, 114, 20);
    if Assigned(FhorizontalstrechToggle) then FhorizontalstrechToggle.SetBounds(130, 62, 30, 20);

    SyncFlowGridVisibility;
  end;

  // ── Card 5: Display & System ────────────────────────────────────────────
  if Assigned(FVisSystemSec) then
  begin
    if Assigned(FVisSystemSubLbl) then FVisSystemSubLbl.SetBounds(12, 8, 200, 22);
    if Assigned(FVisGpuBarLbl) then FVisGpuBarLbl.SetBounds(12, 36, 75, 20);
    pcidevComboBox.SetBounds(90, 32, Max(80, RightColW - 102), 26);
    pcidevComboBox.Visible := True;

    if Assigned(FVisShortcutLbl) then FVisShortcutLbl.SetBounds(12, 74, 75, 20);
    FVisualCaptureBtn.SetBounds(90, 70, 140, 28);

    if Assigned(FVisHideLbl) then FVisHideLbl.SetBounds(12, 114, 100, 20);
    if Assigned(FhidehudToggle) then FhidehudToggle.SetBounds(120, 112, 30, 20);
  end;

  // ── Card 6: Screen Placement ────────────────────────────────────────────
  if Assigned(FVisScreenSec) then
  begin
    if Assigned(FVisScreenSubLbl) then FVisScreenSubLbl.SetBounds(12, 8, 200, 22);
    MonH := Min(205, Max(165, RightH3 - 130));
    if Assigned(FVisMonitorPaintBox) then
      FVisMonitorPaintBox.SetBounds(8, 26, RightColW - 16, MonH);

    CY := 26 + MonH + 4;
    HalfW := RightColW div 2;
    StartLeft := Max(14, HalfW - 130);
    if Assigned(FVisOffsetXSubLbl) then FVisOffsetXSubLbl.SetBounds(StartLeft, CY + 2, 52, 20);
    offsetxSpinEdit.SetBounds(StartLeft + 54, CY, 65, 26);

    if Assigned(FVisOffsetYSubLbl) then FVisOffsetYSubLbl.SetBounds(StartLeft + 130, CY + 2, 52, 20);
    offsetySpinEdit.SetBounds(StartLeft + 184, CY, 65, 26);
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

procedure TMangoHudUiHelper.VisOrientPillBtnClick(Sender: TObject);
begin
  with FForm do
  begin
    if horizontalRadioButton.Checked then
    begin
      verticalRadioButton.Checked := True;
      horizontalRadioButton.Checked := False;
      GenericControlChange(verticalRadioButton);
    end
    else
    begin
      horizontalRadioButton.Checked := True;
      verticalRadioButton.Checked := False;
      GenericControlChange(horizontalRadioButton);
    end;
  end;
  SyncVisualPills;
end;

procedure TMangoHudUiHelper.VisBorderPillBtnClick(Sender: TObject);
begin
  with FForm do
  begin
    if roundRadioButton.Checked then
    begin
      squareRadioButton.Checked := True;
      roundRadioButton.Checked := False;
      if Assigned(FroundradiusTrackBar) then
        FroundradiusTrackBar.Position := 0;
      GenericControlChange(squareRadioButton);
    end
    else
    begin
      roundRadioButton.Checked := True;
      squareRadioButton.Checked := False;
      if Assigned(FroundradiusTrackBar) and (FroundradiusTrackBar.Position = 0) then
        FroundradiusTrackBar.Position := 10;
      GenericControlChange(roundRadioButton);
    end;
  end;
  SyncVisualPills;
end;

procedure TMangoHudUiHelper.RoundRadiusTrackBarChange(Sender: TObject);
begin
  if not Assigned(FroundradiusTrackBar) then Exit;

  if Assigned(FroundradiusvalueLabel) then
    FroundradiusvalueLabel.Caption := IntToStr(FroundradiusTrackBar.Position) + 'px';

  with FForm do
  begin
    if FroundradiusTrackBar.Position = 0 then
    begin
      squareRadioButton.Checked := True;
      roundRadioButton.Checked := False;
    end
    else
    begin
      roundRadioButton.Checked := True;
      squareRadioButton.Checked := False;
    end;
    GenericControlChange(Sender);
  end;
  SyncVisualPills;
end;

procedure TMangoHudUiHelper.UpdateColumnsIndicator;
begin
  if Assigned(FVisColumnsPaintBox) then FVisColumnsPaintBox.Invalidate;
end;

procedure TMangoHudUiHelper.VisColumnsPaintBoxPaint(Sender: TObject);
var
  PB: TPaintBox;
  Cols, BarW, BarH, Gap, R, Y, StartX, i, X: Integer;
  ActiveClr, InactiveClr, DivClr: TColor;
begin
  if not (Sender is TPaintBox) then Exit;
  PB := TPaintBox(Sender);

  with FForm do
    Cols := StrToIntDef(columvalueLabel.Caption, 3);
  if Cols < 1 then Cols := 1;
  if Cols > 6 then Cols := 6;

  BarW := 6;
  BarH := 18;
  Gap := 4;
  R := 2;
  Y := (PB.Height - BarH) div 2;
  StartX := 10;

  if CurrentTheme = tmLight then
  begin
    ActiveClr := $00C06000;
    InactiveClr := $00D0D0D0;
    DivClr := $00B8B8B8;
  end
  else
  begin
    ActiveClr := CLR_TEXT_ACCENT;
    InactiveClr := $00554133;
    DivClr := $004D3123;
  end;

  PB.Canvas.Pen.Color := DivClr;
  PB.Canvas.Pen.Style := psSolid;
  PB.Canvas.Pen.Width := 1;
  PB.Canvas.Line(3, Y + 1, 3, Y + BarH - 1);

  PB.Canvas.Pen.Style := psClear;
  for i := 0 to 5 do
  begin
    X := StartX + i * (BarW + Gap);
    if i < Cols then
      PB.Canvas.Brush.Color := ActiveClr
    else
      PB.Canvas.Brush.Color := InactiveClr;
    PB.Canvas.RoundRect(X, Y, X + BarW, Y + BarH, R, R);
  end;
end;

function TMangoHudUiHelper.GetActiveScreenAnchor: Integer;
begin
  Result := 0;
  with FForm do
  begin
    if topcenterRadioButton.Checked then
      Result := 1
    else if toprightRadioButton.Checked then
      Result := 2
    else if middleleftRadioButton.Checked then
      Result := 3
    else if middlerightRadioButton.Checked then
      Result := 4
    else if bottomleftRadioButton.Checked then
      Result := 5
    else if bottomcenterRadioButton.Checked then
      Result := 6
    else if bottomrightRadioButton.Checked then
      Result := 7;
  end;
end;

procedure TMangoHudUiHelper.SetActiveScreenAnchor(AAnchor: Integer);
begin
  with FForm do
  begin
    case AAnchor of
      1: topcenterRadioButton.Checked    := True;
      2: toprightRadioButton.Checked     := True;
      3: middleleftRadioButton.Checked   := True;
      4: middlerightRadioButton.Checked  := True;
      5: bottomleftRadioButton.Checked   := True;
      6: bottomcenterRadioButton.Checked := True;
      7: bottomrightRadioButton.Checked  := True;
    else
      topleftRadioButton.Checked := True;
    end;
    if Assigned(FVisMonitorPaintBox) then
      GenericControlChange(FVisMonitorPaintBox);
  end;
  UpdateMonitorVisuals;
end;

procedure TMangoHudUiHelper.UpdateMonitorVisuals;
begin
  if Assigned(FVisMonitorPaintBox) then
    FVisMonitorPaintBox.Invalidate;
end;

procedure TMangoHudUiHelper.VisMonitorPaintBoxPaint(Sender: TObject);
const
  AnchorCol: array[0..7] of Integer = (0, 1, 2, 0, 2, 0, 1, 2);
  AnchorRow: array[0..7] of Integer = (0, 0, 0, 1, 1, 2, 2, 2);
  StandH    = 18;
  ChipW     = 46;
  ChipH     = 18;
var
  PB: TPaintBox;
  IsLight: Boolean;
  BzW, BzH, BzL, BzT, BzR, BzB: Integer;
  ScrnL, ScrnT, ScrnR, ScrnB: Integer;
  CellW, CellH, PX, PY, i: Integer;
  NeckW, FootW, NeckH, FootH, NeckL, FootL, StandTop: Integer;
  Active, ChipL, ChipT, TH: Integer;
  BezelClr, BezelBorder, ScreenClr, ScreenBorder: TColor;
  AccentClr, ChipBg, ChipText, PinClr: TColor;
begin
  if not (Sender is TPaintBox) then Exit;
  PB := TPaintBox(Sender);

  IsLight := CurrentTheme = tmLight;
  if IsLight then
  begin
    BezelClr     := $00DCE2E8;
    BezelBorder  := $00B5C0CC;
    ScreenClr    := $00FFFFFF;
    ScreenBorder := $00CBD5E1;
    AccentClr    := $00C06000;
    ChipBg       := $00FFFFFF;
    ChipText     := $002A170F;
  end
  else
  begin
    BezelClr     := $0023190E;
    BezelBorder  := $003D2817;
    ScreenClr    := $00120B07;
    ScreenBorder := $00332214;
    AccentClr    := $38BDF8;
    ChipBg       := $002A170F;
    ChipText     := clWhite;
  end;

  // Clear the paint box with the card background.
  PB.Canvas.Brush.Color := IfThen(IsLight, $00F0F0F0, $002E1E1A);
  PB.Canvas.Brush.Style := bsSolid;
  PB.Canvas.Pen.Color   := PB.Canvas.Brush.Color;
  PB.Canvas.FillRect(PB.ClientRect);

  BzW := Min(PB.Width - 12, 330);
  if BzW < 40 then BzW := Max(40, PB.Width - 4);
  BzH := Min(PB.Height - StandH - 4, Max(110, Round(BzW * 9 / 16)));
  if BzH < 36 then BzH := Max(36, PB.Height - 4);
  BzL := (PB.Width - BzW) div 2;
  BzT := 2;
  BzR := BzL + BzW;
  BzB := BzT + BzH;

  // Monitor stand (neck + foot), drawn behind the bezel.
  NeckW := Min(28, Max(12, BzW div 8));
  FootW := Min(72, Max(28, BzW div 3));
  NeckH := 10;
  FootH := 5;
  NeckL := (PB.Width - NeckW) div 2;
  FootL := (PB.Width - FootW) div 2;
  StandTop := BzB;
  PB.Canvas.Brush.Color := BezelClr;
  PB.Canvas.Pen.Color   := BezelBorder;
  PB.Canvas.Pen.Width   := 1;
  PB.Canvas.RoundRect(NeckL, StandTop, NeckL + NeckW, StandTop + NeckH, 3, 3);
  PB.Canvas.RoundRect(FootL, StandTop + NeckH, FootL + FootW, StandTop + NeckH + FootH, 3, 3);

  // Outer bezel.
  PB.Canvas.Brush.Color := BezelClr;
  PB.Canvas.Pen.Color   := BezelBorder;
  PB.Canvas.RoundRect(BzL, BzT, BzR, BzB, 6, 6);

  // Inner screen.
  ScrnL := BzL + 5;
  ScrnT := BzT + 5;
  ScrnR := BzR - 5;
  ScrnB := BzB - 5;
  if (ScrnR <= ScrnL) or (ScrnB <= ScrnT) then Exit;

  PB.Canvas.Brush.Color := ScreenClr;
  PB.Canvas.Pen.Color   := ScreenBorder;
  PB.Canvas.RoundRect(ScrnL, ScrnT, ScrnR, ScrnB, 4, 4);

  // Anchor pins at each grid-cell centre (the centre cell has no pin).
  CellW := ScrnR - ScrnL;
  CellH := ScrnB - ScrnT;
  Active := GetActiveScreenAnchor;
  PB.Canvas.Pen.Style := psClear;
  for i := 0 to 7 do
  begin
    PX := ScrnL + (CellW * (2 * AnchorCol[i] + 1)) div 6;
    PY := ScrnT + (CellH * (2 * AnchorRow[i] + 1)) div 6;
    if i = Active then
      PinClr := AccentClr
    else if i = FVisHoverAnchor then
      PinClr := AccentClr
    else
      PinClr := IfThen(IsLight, $008A9AAB, $00574333);
    PB.Canvas.Brush.Color := PinClr;
    PB.Canvas.Ellipse(PX - 3, PY - 3, PX + 3, PY + 3);
  end;

  // Live mini-HUD preview chip at the active anchor.
  if (CellW > ChipW + 8) and (CellH > ChipH + 6) then
  begin
    case AnchorCol[Active] of
      0: ChipL := ScrnL + 3;
      1: ChipL := (ScrnL + ScrnR - ChipW) div 2;
    else
      ChipL := ScrnR - ChipW - 3;
    end;
    case AnchorRow[Active] of
      0: ChipT := ScrnT + 3;
      1: ChipT := (ScrnT + ScrnB - ChipH) div 2;
    else
      ChipT := ScrnB - ChipH - 3;
    end;

    PB.Canvas.Brush.Color := ChipBg;
    PB.Canvas.Pen.Color   := AccentClr;
    PB.Canvas.Pen.Style   := psSolid;
    PB.Canvas.Pen.Width   := 1;
    PB.Canvas.RoundRect(ChipL, ChipT, ChipL + ChipW, ChipT + ChipH, 3, 3);

    // Green status dot.
    PB.Canvas.Pen.Style   := psClear;
    PB.Canvas.Brush.Color := $0000C000;
    PB.Canvas.Ellipse(ChipL + 4, ChipT + ChipH div 2 - 2,
      ChipL + 8, ChipT + ChipH div 2 + 2);

    // 'HUD' label.
    PB.Canvas.Font.Name  := 'Noto Sans';
    PB.Canvas.Font.Size  := 7;
    PB.Canvas.Font.Style := [fsBold];
    PB.Canvas.Font.Color := ChipText;
    TH := PB.Canvas.TextHeight('HUD');
    PB.Canvas.Brush.Style := bsClear;
    PB.Canvas.TextOut(ChipL + 11, ChipT + (ChipH - TH) div 2, 'HUD');
    PB.Canvas.Brush.Style := bsSolid;
  end;
end;

procedure TMangoHudUiHelper.VisMonitorPaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
const
  StandH = 18;
var
  PB: TPaintBox;
  BzW, BzH, BzL, BzT, BzR, BzB: Integer;
  ScrnL, ScrnT, ScrnR, ScrnB: Integer;
  Col, Row, Anchor: Integer;
begin
  if not (Sender is TPaintBox) then Exit;
  PB := TPaintBox(Sender);

  BzW := Min(PB.Width - 12, 330);
  if BzW < 40 then BzW := Max(40, PB.Width - 4);
  BzH := Min(PB.Height - StandH - 4, Max(110, Round(BzW * 9 / 16)));
  if BzH < 36 then BzH := Max(36, PB.Height - 4);
  BzL := (PB.Width - BzW) div 2;
  BzT := 2;
  BzR := BzL + BzW;
  BzB := BzT + BzH;

  ScrnL := BzL + 5;
  ScrnT := BzT + 5;
  ScrnR := BzR - 5;
  ScrnB := BzB - 5;

  Anchor := -1;
  if (ScrnR > ScrnL) and (ScrnB > ScrnT) and
     (X >= ScrnL) and (X < ScrnR) and (Y >= ScrnT) and (Y < ScrnB) then
  begin
    Col := ((X - ScrnL) * 3) div (ScrnR - ScrnL);
    Row := ((Y - ScrnT) * 3) div (ScrnB - ScrnT);
    if Col > 2 then Col := 2;
    if Row > 2 then Row := 2;

    case Row of
      0: case Col of
           0: Anchor := 0;
           1: Anchor := 1;
           2: Anchor := 2;
         end;
      1: case Col of
           0: Anchor := 3;
           1: Anchor := -1;
           2: Anchor := 4;
         end;
      2: case Col of
           0: Anchor := 5;
           1: Anchor := 6;
           2: Anchor := 7;
         end;
    end;
  end;

  if Anchor <> FVisHoverAnchor then
  begin
    FVisHoverAnchor := Anchor;
    if FVisHoverAnchor >= 0 then
      PB.Cursor := crHandPoint
    else
      PB.Cursor := crDefault;
    PB.Invalidate;
  end;
end;

procedure TMangoHudUiHelper.VisMonitorPaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (FVisHoverAnchor >= 0) and (FVisHoverAnchor <= 7) then
    SetActiveScreenAnchor(FVisHoverAnchor);
end;

procedure TMangoHudUiHelper.VisMonitorPaintBoxMouseLeave(Sender: TObject);
begin
  FVisHoverAnchor := -1;
  if Assigned(FVisMonitorPaintBox) then
  begin
    FVisMonitorPaintBox.Cursor := crDefault;
    FVisMonitorPaintBox.Invalidate;
  end;
end;

procedure TMangoHudUiHelper.SyncVisualPills;
begin
  with FForm do
  begin
    if Assigned(FVisOrientPillBtn) then
    begin
      SetSegmentedPillGlyph(FVisOrientPillBtn, 'Vertical', 'Horizontal', IfThen(horizontalRadioButton.Checked, 1, 0));
      StyleSegmentedFormatBtn(FVisOrientPillBtn);
      FVisOrientPillBtn.Width  := FVisOrientPillBtn.Glyph.Width + 24;
      FVisOrientPillBtn.Height := 24;
      FVisOrientPillBtn.ShowHint := True;
      FVisOrientPillBtn.Hint := 'HUD orientation: Vertical or Horizontal layout';
    end;
    if Assigned(FVisBorderPillBtn) then
    begin
      SetSegmentedPillGlyph(FVisBorderPillBtn, 'Square', 'Round', IfThen(roundRadioButton.Checked, 1, 0));
      StyleSegmentedFormatBtn(FVisBorderPillBtn);
      FVisBorderPillBtn.Width  := FVisBorderPillBtn.Glyph.Width + 24;
      FVisBorderPillBtn.Height := 24;
      FVisBorderPillBtn.ShowHint := True;
      FVisBorderPillBtn.Hint := 'HUD border style: Square or Round corners';
    end;
  end;
  UpdateColumnsIndicator;
  SyncFlowGridVisibility;
end;

procedure TMangoHudUiHelper.SyncFlowGridVisibility;
var
  IsHoriz: Boolean;
begin
  with FForm do
    IsHoriz := horizontalRadioButton.Checked;

  // In Vertical mode: show Columns controls, hide Horizontal Stretch
  if Assigned(FVisColumnsSubLbl) then FVisColumnsSubLbl.Visible := not IsHoriz;
  if Assigned(FColumnsMinusBtn) then FColumnsMinusBtn.Visible := not IsHoriz;
  if Assigned(FForm.FColumnsMinusBtn) then FForm.FColumnsMinusBtn.Visible := not IsHoriz;
  if Assigned(FForm.columvalueLabel) then FForm.columvalueLabel.Visible := not IsHoriz;
  if Assigned(FColumnsPlusBtn) then FColumnsPlusBtn.Visible := not IsHoriz;
  if Assigned(FForm.FColumnsPlusBtn) then FForm.FColumnsPlusBtn.Visible := not IsHoriz;
  if Assigned(FVisColumnsPaintBox) then FVisColumnsPaintBox.Visible := not IsHoriz;

  // In Horizontal mode: show Horizontal Stretch, hide Columns controls
  if Assigned(FVisStretchLbl) then FVisStretchLbl.Visible := IsHoriz;
  if Assigned(FhorizontalstrechToggle) then FhorizontalstrechToggle.Visible := IsHoriz;

  if Assigned(FVisFlowSec) then FVisFlowSec.Invalidate;
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
  CardBg, TextColor: TColor;
  Card: TPanel;
  j: Integer;
  SS: WideString;
begin
  with FForm do
  begin
  if not Assigned(FVisAppearanceCard) then Exit;

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
        if (Card.Controls[j] <> alphavalueLabel) and
           (Card.Controls[j] <> fontsizevalueLabel) and
           (Card.Controls[j] <> FroundradiusvalueLabel) and
           (Card.Controls[j] <> columvalueLabel) then
          TLabel(Card.Controls[j]).Font.Color := TextColor;
        TLabel(Card.Controls[j]).Transparent := True;
      end;
    end;
    UpdateGenericCardTheme(Card);
  end;

  if Assigned(FVisRadiusLbl) then
    FVisRadiusLbl.Font.Color := TextColor;
  if Assigned(FVisNoMarginLbl) then
    FVisNoMarginLbl.Font.Color := TextColor;
  if Assigned(FroundradiusvalueLabel) then
    FroundradiusvalueLabel.Font.Color := CLR_TEXT_ACCENT;

  pcidevComboBox.Color      := CardBg;
  pcidevComboBox.Font.Color := TextColor;
  SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
  QWidget_setStyleSheet(TQtWidget(pcidevComboBox.Handle).Widget, @SS);

  hudtitleEdit.Color      := CardBg;
  hudtitleEdit.Font.Color := TextColor;
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(242,242,242); color: rgb(0,0,0); border: 1px solid rgb(210,210,210); border-radius: 4px; padding: 2px; }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px; }' +
          'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
  QWidget_setStyleSheet(TQtWidget(hudtitleEdit.Handle).Widget, @SS);

  if Assigned(FColumnsMinusBtn) then
    StyleBitBtnTheme(FColumnsMinusBtn, TextColor, CardBg);
  if Assigned(FColumnsPlusBtn) then
    StyleBitBtnTheme(FColumnsPlusBtn, TextColor, CardBg);

  if Assigned(FVisualCaptureBtn) then
    StyleBitBtnTheme(FVisualCaptureBtn, TextColor, CardBg);

  if Assigned(offsetxSpinEdit) and offsetxSpinEdit.HandleAllocated then
  begin
    offsetxSpinEdit.Font.Size   := 8;
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
    offsetySpinEdit.Font.Size   := 8;
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

  alphavalueLabel.Font.Color    := CLR_TEXT_ACCENT;
  alphavalueLabel.Font.Style    := [fsBold];
  alphavalueLabel.Transparent   := True;
  fontsizevalueLabel.Font.Color := CLR_TEXT_ACCENT;
  fontsizevalueLabel.Font.Style := [fsBold];
  fontsizevalueLabel.Transparent := True;
  columvalueLabel.Font.Color    := CLR_TEXT_ACCENT;
  columvalueLabel.Font.Style    := [fsBold];
  columvalueLabel.Transparent   := True;
  columvalueLabel.Alignment     := taCenter;

  UpdateColumnsIndicator;
  SyncVisualPills;
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
  FFpsLimitTitleLbl.Caption := 'FPS Limit';
  FFpsLimitTitleLbl.Font.Name := 'Noto Sans';
  FFpsLimitTitleLbl.Font.Color := TextColor;
  FFpsLimitTitleLbl.Font.Style := [];
  FFpsLimitTitleLbl.Font.Size := 9;
  FFpsLimitTitleLbl.Transparent := True;
  FFpsLimitTitleLbl.Alignment := taLeftJustify;
  FFpsLimitTitleLbl.AutoSize := False;
  FFpsLimitTitleLbl.SetBounds(ContL + 6, ContT + 8, 140, 20);
  FFpsLimitTitleLbl.Anchors := [akLeft, akTop];

  // Create the edit — compact, proportionate font
  FFpsLimitEdit := TEdit.Create(FForm);
  FFpsLimitEdit.Parent := FPerfLimitSec;
  FFpsLimitEdit.SetBounds(ContL + 6, ContT + 30, 105, 28);
  FFpsLimitEdit.AutoSize := False;
  FFpsLimitEdit.Constraints.MinWidth := 80;
  FFpsLimitEdit.Constraints.MaxWidth := 220;
  FFpsLimitEdit.Anchors := [akLeft, akTop];
  FFpsLimitEdit.Font.Name := 'Noto Sans';
  FFpsLimitEdit.Font.Size := 10;
  FFpsLimitEdit.Font.Color := TextColor;
  FFpsLimitEdit.Color := EditBg;
  FFpsLimitEdit.BorderStyle := bsNone;
  FFpsLimitEdit.Alignment := taCenter;
  FFpsLimitEdit.Text := '0';
  FFpsLimitEdit.Hint := 'e.g. 30,60,120,0 — 0 to unlimited' + LineEnding + 'Separate values with commas to cycle limits using the toggle key';
  FFpsLimitEdit.ShowHint := True;
  // Force QLineEdit stylesheet — KDE/Breeze ignores LCL Color/Font.Color
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: 1px solid rgb(210,215,225); border-radius: 4px; padding: 2px 4px; }' +
          'QLineEdit:hover { border: 1px solid rgb(160,175,200); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,120,200); }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 4px; }' +
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
  FFpsLimitHintLbl.Visible := False;

  // ── Spread controls vertically: edit top, colours middle, method bottom ───
  fpscolorCheckBox.SetBounds(ContL + (ContW - 150) div 2, ContT + 115, 150, 21);
  fpscolorCheckBox.Font.Color := TextColor;

  fpscolor1ColorButton.SetBounds(ContL + 6,        ContT + 140, 80, 18);
  fpscolor2ColorButton.SetBounds(ContL + ContW div 2 - 40, ContT + 140, 80, 18);
  fpscolor3ColorButton.SetBounds(ContL + ContW - 86,      ContT + 140, 80, 18);

  fpscolor2SpinEdit.SetBounds(ContL + ContW div 2 - 35, ContT + 165, 70, 26);
  fpscolor3SpinEdit.SetBounds(ContL + ContW - 81,      ContT + 165, 70, 26);

  // ── Method / Limit toggle key pinned above the vkNemu section ─────────────
  methodLabel.SetBounds(ContL + 6, 185, 60, 18);
  methodLabel.Font.Color := TextColor;

  fpslimmetComboBox.SetBounds(ContL + 6, 203, 110, 32);

  limtoggleLabel.SetBounds(ContL + 140, 185, 120, 18);
  if Assigned(FLimitCaptureBtn) then
    FLimitCaptureBtn.SetBounds(ContL + 140, 203, 160, 28);
  end;
end;


procedure TMangoHudUiHelper.InitPerformanceTab;
const
  GB_OFFSET = 24;
  CARD_BG   = $002E1E1A;  // rgb(26, 30, 46)
  IMARGIN   = 6;
  IGAP      = 8;

  // Vertical layout: 3 stacked master cards
  CARD0_TOP = 4;
  CARD0_H   = 185;
  CARD1_TOP = CARD0_TOP + CARD0_H + 8;
  CARD1_H   = 170;
  CARD2_TOP = CARD1_TOP + CARD1_H + 8;
  CARD2_H   = 250;

  procedure MakePerfCard(AIndex, ATop, AHeight: Integer;
                         const ATitle1, ATitle2: string;
                         out Sec1, Sec2: TPanel);
  var
    Card: TPanel;
    Lbl1, Lbl2: TLabel;
    IsLight: Boolean;
    BgColor, TextColor: TColor;
    HalfW: Integer;
  begin
    with FForm do
    begin
      IsLight   := CurrentTheme = tmLight;
      BgColor   := IfThen(IsLight, clWhite, RGBToColor(26, 30, 46));
      TextColor := IfThen(IsLight, LightTextColor, DarkTextColor);

      Card := TPanel.Create(FForm);
      Card.Parent      := FPerfBgPanel;
      Card.BevelOuter  := bvNone;
      Card.BorderStyle := bsNone;
      Card.Caption     := '';
      Card.Color       := BgColor;
      Card.ParentColor := False;
      Card.OnPaint     := @FForm.SubCardPaint;
      Card.SetBounds(4, ATop, 800, AHeight);  // provisional; corrected by Reflow
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
      Sec1.SetBounds(IMARGIN, GB_OFFSET, HalfW - 10, AHeight - GB_OFFSET - IMARGIN);

      Sec2 := TPanel.Create(FForm);
      Sec2.Parent      := Card;
      Sec2.BevelOuter  := bvNone;
      Sec2.BorderStyle := bsNone;
      Sec2.Caption     := '';
      Sec2.Color       := BgColor;
      Sec2.OnPaint     := @FForm.SubCardPaint;
      Sec2.SetBounds(HalfW + 4, GB_OFFSET, HalfW - 10, AHeight - GB_OFFSET - IMARGIN);

      // Left section title
      Lbl1 := TLabel.Create(Card);
      Lbl1.Parent      := Card;
      StyleLabel(Lbl1, lrSectionTitle);
      Lbl1.Caption     := ATitle1;
      Lbl1.SetBounds(IMARGIN + 12, 5, 200, 18);
      FPerfLeftLbl[AIndex] := Lbl1;

      // Right section title
      Lbl2 := TLabel.Create(Card);
      Lbl2.Parent      := Card;
      StyleLabel(Lbl2, lrSectionTitle);
      Lbl2.Caption     := ATitle2;
      Lbl2.ShowAccelChar := False;
      Lbl2.SetBounds(HalfW + 16, 5, 200, 18);
      FPerfRightLbl[AIndex] := Lbl2;
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
      Combo.Width  := 140;
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
  SS: WideString;
  TextColor: TColor;
  i: Integer;
  PresetCaptions: array[0..3] of string;
  PresetValues: array[0..3] of Integer;
begin
  with FForm do
  begin
  TextColor := IfThen(CurrentTheme = tmLight, LightTextColor, DarkTextColor);

  // ── Scroll container fills the tab ──────────────────────────────────────
  FPerfScrollBox := TScrollBox.Create(FForm);
  FPerfScrollBox.Parent      := performanceTabSheet;
  FPerfScrollBox.Align       := alClient;
  FPerfScrollBox.AutoScroll  := True;
  FPerfScrollBox.BorderStyle := bsNone;
  FPerfScrollBox.HorzScrollBar.Visible := False;
  FPerfScrollBox.Color       := RGBToColor(22, 26, 40);
  FPerfScrollBox.ParentColor := False;
  ApplyModernScrollBarStylesheet(FPerfScrollBox);
  FPerfScrollBox.OnResize := @PerfScrollBoxResize;

  FPerfBgPanel := TPanel.Create(FForm);
  FPerfBgPanel.Parent     := FPerfScrollBox;
  FPerfBgPanel.BevelOuter := bvNone;
  FPerfBgPanel.Color      := RGBToColor(22, 26, 40);
  FPerfBgPanel.OnPaint    := @FForm.PresetsWrapperPaint;
  FPerfBgPanel.Caption    := '';
  FPerfBgPanel.Left       := 0;
  FPerfBgPanel.Top        := 0;
  FPerfBgPanel.Width      := FPerfScrollBox.ClientWidth;
  FPerfBgPanel.Height     := 700;

  // Three master cards: Rate Control & Sync, Telemetry, Energy & Visual.
  MakePerfCard(0, CARD0_TOP, CARD0_H, 'Rate Control', 'VSYNC', FPerfLimitSec, FPerfVsyncSec);
  MakePerfCard(1, CARD1_TOP, CARD1_H, 'Frame Rate', 'Frame Timing', FPerfInfoSec, FPerfFrametimeSec);
  MakePerfCard(2, CARD2_TOP, CARD2_H, 'Idle Limiter (vkNemu)', 'Filters & LOD', FVkNemuSec, FPerfFiltersSec);
  FPerfCards[3] := nil;

  // ── Card 0: FPS Limiter toggle-key capture button ───────────────────────
  fpslimtoggleComboBox.Visible := False;

  limtoggleLabel.AnchorSideLeft.Control   := nil;
  limtoggleLabel.AnchorSideTop.Control    := nil;
  limtoggleLabel.AnchorSideRight.Control  := nil;
  limtoggleLabel.AnchorSideBottom.Control := nil;
  limtoggleLabel.Anchors := [akLeft, akTop];
  limtoggleLabel.Parent  := FPerfLimitSec;
  limtoggleLabel.Font.Color := TextColor;
  limtoggleLabel.ParentColor := True;

  FLimitCaptureBtn := TBitBtn.Create(FPerfLimitSec);
  FLimitCaptureBtn.Parent  := FPerfLimitSec;
  FLimitCaptureBtn.Tag     := 2;
  FLimitCaptureBtn.OnClick := @FForm.CaptureBtnClick;
  FLimitCaptureBtn.Cursor  := crHandPoint;
  FLimitCaptureBtn.Font.Color := TextColor;
  if Trim(fpslimtoggleComboBox.Text) <> '' then
    FLimitCaptureBtn.Caption := '⌨ ' + fpslimtoggleComboBox.Text
  else
    FLimitCaptureBtn.Caption := '⌨ Capture';

  StyleBitBtnTheme(FLimitCaptureBtn, TextColor, CARD_BG);

  // ── Card 1 left: Frame Rate telemetry ───────────────────────────────────
  fpsCheckBox.Parent                := FPerfInfoSec;
  fpsavgCheckBox.Parent             := FPerfInfoSec;
  fpsavgBitBtn.Parent               := FPerfInfoSec;
  showfpslimCheckBox.Parent         := FPerfInfoSec;
  framecountCheckBox.Parent         := FPerfInfoSec;
  vpsCheckBox.Parent                := FPerfFrametimeSec;

  // ── Card 1 right: Frame Timing & plots ──────────────────────────────────
  frametimegraphCheckBox.Parent     := FPerfFrametimeSec;
  if not Assigned(frametimedetailedCheckBox) then
  begin
    frametimedetailedCheckBox := TCheckBox.Create(FForm);
    frametimedetailedCheckBox.Name := 'frametimedetailedCheckBox';
    frametimedetailedCheckBox.Caption := 'Frame Time +';
    frametimedetailedCheckBox.Hint := 'Show detailed frame timing breakdown';
    frametimedetailedCheckBox.ShowHint := True;
  end;
  frametimedetailedCheckBox.Parent  := FPerfFrametimeSec;
  frametimegraphColorButton.Parent  := FPerfFrametimeSec;
  frametimetypeBitBtn.Parent        := FPerfFrametimeSec;
  ftraceCheckBox.Parent             := FPerfFrametimeSec;

  FframetimetypeLbl := TLabel.Create(FForm);
  FframetimetypeLbl.Parent := FPerfFrametimeSec;
  StyleLabel(FframetimetypeLbl, lrControlLabel);
  FframetimetypeLbl.Caption := 'Plot style:';
  FframetimetypeLbl.Visible := False;

  RefreshFormatPills;

  // Create and link Performance toggles
  FfpsToggle               := PlacePerfToggle(fpsCheckBox, FPerfInfoSec);
  FfpsavgToggle            := PlacePerfToggle(fpsavgCheckBox, FPerfInfoSec);
  FshowfpslimToggle        := PlacePerfToggle(showfpslimCheckBox, FPerfInfoSec);
  FframecountToggle        := PlacePerfToggle(framecountCheckBox, FPerfInfoSec);
  FvpsToggle               := PlacePerfToggle(vpsCheckBox, FPerfFrametimeSec);
  FframetimegraphToggle    := PlacePerfToggle(frametimegraphCheckBox, FPerfFrametimeSec);
  FframetimedetailedToggle := PlacePerfToggle(frametimedetailedCheckBox, FPerfFrametimeSec);
  FftraceToggle            := PlacePerfToggle(ftraceCheckBox, FPerfFrametimeSec);

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
  afvalueLabel.AnchorSideLeft.Control := nil; afvalueLabel.AnchorSideTop.Control := nil; afvalueLabel.AnchorSideRight.Control := nil; afvalueLabel.AnchorSideBottom.Control := nil; afvalueLabel.Anchors := [akLeft, akTop];
  mipmapLabel.AnchorSideLeft.Control := nil; mipmapLabel.AnchorSideTop.Control := nil; mipmapLabel.AnchorSideRight.Control := nil; mipmapLabel.AnchorSideBottom.Control := nil; mipmapLabel.Anchors := [akLeft, akTop];
  mipmapTrackBar.AnchorSideLeft.Control := nil; mipmapTrackBar.AnchorSideTop.Control := nil; mipmapTrackBar.AnchorSideRight.Control := nil; mipmapTrackBar.AnchorSideBottom.Control := nil; mipmapTrackBar.Anchors := [akLeft, akTop];
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

  filterRadioGroup.Font.Color := TextColor;
  if CurrentTheme = tmLight then
    SS := 'QGroupBox { border: none; } QRadioButton { color: rgb(0,0,0); background-color: transparent; }'
  else
    SS := 'QGroupBox { border: none; } QRadioButton { color: rgb(255,255,255); background-color: transparent; }';
  QWidget_setStyleSheet(TQtWidget(filterRadioGroup.Handle).Widget, @SS);
  filterRadioGroup.OnClick := @FForm.filterRadioGroupClick;
  filterRadioGroup.OnSelectionChanged := @FForm.filterRadioGroupClick;

  // VSYNC card — Vulkan in top half, OpenGL in bottom half
  MakeVsyncRow(0, 4, 44, vulkanImage, vsyncComboBox);
  MakeVsyncRow(1, 50, 44, openglImage, glvsyncComboBox);

  // FPS Limit — single comma-separated input field
  BuildFpsLimitEdit;

  // FPS color gradient controls belong to the Rate Control section
  fpscolorCheckBox.Parent      := FPerfLimitSec;
  fpscolor1ColorButton.Parent  := FPerfLimitSec;
  fpscolor2ColorButton.Parent  := FPerfLimitSec;
  fpscolor3ColorButton.Parent  := FPerfLimitSec;
  fpscolor2spinedit.Parent     := FPerfLimitSec;
  fpscolor3spinedit.Parent     := FPerfLimitSec;
  FfpscolorToggle := PlacePerfToggle(fpscolorCheckBox, FPerfLimitSec);

  FFpsPresetLbl := TLabel.Create(FForm);
  FFpsPresetLbl.Parent := FPerfLimitSec;
  StyleLabel(FFpsPresetLbl, lrControlLabel);
  FFpsPresetLbl.Caption := 'Presets:';
  FFpsPresetLbl.Font.Size := 8;
  FFpsPresetLbl.Visible := False;

  // Quick FPS preset chips (60 / 120 / 144 / Off)
  PresetCaptions[0] := '60';  PresetValues[0] := 60;
  PresetCaptions[1] := '120'; PresetValues[1] := 120;
  PresetCaptions[2] := '144'; PresetValues[2] := 144;
  PresetCaptions[3] := 'Off'; PresetValues[3] := 0;
  for i := 0 to 3 do
  begin
    FFpsPresetChips[i] := TBitBtn.Create(FForm);
    FFpsPresetChips[i].Parent   := FPerfLimitSec;
    FFpsPresetChips[i].Caption  := PresetCaptions[i];
    FFpsPresetChips[i].Tag      := PresetValues[i];
    FFpsPresetChips[i].OnClick  := @FForm.FpsPresetChipClick;
    FFpsPresetChips[i].Cursor   := crHandPoint;
    FFpsPresetChips[i].ShowHint := False;
    FFpsPresetChips[i].Hint     := IntToStr(PresetValues[i]);
    FFpsPresetChips[i].Font.Size := 8;
    StyleBitBtnTheme(FFpsPresetChips[i], TextColor, CARD_BG);
    FFpsPresetChips[i].Visible := False;
  end;

  // vkNemu is now a dedicated sub-card with full breathing room
  FVkNemuDivider := TPanel.Create(FForm);
  FVkNemuDivider.Parent := FVkNemuSec;
  FVkNemuDivider.BevelOuter := bvNone;
  FVkNemuDivider.Caption := '';
  FVkNemuDivider.Color := IfThen(CurrentTheme = tmLight, $00D0D5E0, $003C3026);
  FVkNemuDivider.Height := 1;
  FVkNemuDivider.Visible := False;

  FVkNemuSectionLbl := TLabel.Create(FForm);
  FVkNemuSectionLbl.Parent := FVkNemuSec;
  StyleLabel(FVkNemuSectionLbl, lrSectionTitle);
  FVkNemuSectionLbl.Caption := '🌙 Idle Limiter (vkNemu)';
  FVkNemuSectionLbl.AutoSize := False;

  FVkNemuFlowCard := TPanel.Create(FForm);
  FVkNemuFlowCard.Parent := FVkNemuSec;
  FVkNemuFlowCard.BevelOuter := bvNone;
  FVkNemuFlowCard.OnPaint := @VkNemuFlowCardPaint;
  FVkNemuFlowCard.ParentColor := False;
  FVkNemuFlowCard.DoubleBuffered := True;

  FVkNemuCheckBox := TCheckBox.Create(FForm);
  FVkNemuCheckBox.Parent := FVkNemuSec;
  FVkNemuCheckBox.Caption := '';
  FVkNemuCheckBox.Visible := False;
  FVkNemuToggle := PlacePerfToggle(FVkNemuCheckBox, FVkNemuSec);
  FVkNemuToggle.OnClick := @FForm.VkNemuToggleChange;
  FVkNemuToggle.Visible := False;

  FVkNemuToggleBtn := TSpeedButton.Create(FForm);
  FVkNemuToggleBtn.Parent := FVkNemuSec;
  FVkNemuToggleBtn.Flat := True;
  FVkNemuToggleBtn.Images := FForm.globalbuttonImageList;
  FVkNemuToggleBtn.ImageIndex := 0;
  FVkNemuToggleBtn.Cursor := crHandPoint;
  FVkNemuToggleBtn.OnClick := @FForm.VkNemuToggleClick;

  FVkNemuIdleFpsLbl := TLabel.Create(FForm);
  FVkNemuIdleFpsLbl.Parent := FVkNemuSec;
  StyleLabel(FVkNemuIdleFpsLbl, lrControlLabel);
  FVkNemuIdleFpsLbl.Caption := 'Idle FPS';
  FVkNemuIdleFpsLbl.AutoSize := False;

  FVkNemuIdleFpsSpin := TSpinEdit.Create(FForm);
  FVkNemuIdleFpsSpin.Parent := FVkNemuSec;
  FVkNemuIdleFpsSpin.AutoSize := False;
  FVkNemuIdleFpsSpin.MinValue := 10;
  FVkNemuIdleFpsSpin.MaxValue := 360;
  FVkNemuIdleFpsSpin.Value := 30;
  FVkNemuIdleFpsSpin.OnChange := @FForm.VkNemuControlChange;

  FVkNemuTimeoutLbl := TLabel.Create(FForm);
  FVkNemuTimeoutLbl.Parent := FVkNemuSec;
  StyleLabel(FVkNemuTimeoutLbl, lrControlLabel);
  FVkNemuTimeoutLbl.Caption := 'Timeout (seconds)';
  FVkNemuTimeoutLbl.AutoSize := False;

  FVkNemuTimeoutSpin := TSpinEdit.Create(FForm);
  FVkNemuTimeoutSpin.Parent := FVkNemuSec;
  FVkNemuTimeoutSpin.AutoSize := False;
  FVkNemuTimeoutSpin.MinValue := 1;
  FVkNemuTimeoutSpin.MaxValue := 60;
  FVkNemuTimeoutSpin.Value := 2;
  FVkNemuTimeoutSpin.OnChange := @FForm.VkNemuControlChange;

  FVkNemuInputLbl := TLabel.Create(FForm);
  FVkNemuInputLbl.Parent := FVkNemuSec;
  StyleLabel(FVkNemuInputLbl, lrControlLabel);
  FVkNemuInputLbl.Caption := 'Wake Input Trigger';
  FVkNemuInputLbl.AutoSize := False;

  FVkNemuInputCombo := TComboBox.Create(FForm);
  FVkNemuInputCombo.Parent := FVkNemuSec;
  FVkNemuInputCombo.Style := csDropDownList;
  FVkNemuInputCombo.Constraints.MinHeight := 28;
  FVkNemuInputCombo.Items.Add('all');
  FVkNemuInputCombo.Items.Add('keyboard');
  FVkNemuInputCombo.Items.Add('gamepad');
  FVkNemuInputCombo.Items.Add('none');
  FVkNemuInputCombo.ItemIndex := 0;
  FVkNemuInputCombo.OnChange := @FForm.VkNemuControlChange;

  FVkNemuUnfocusedCheckBox := TCheckBox.Create(FForm);
  FVkNemuUnfocusedCheckBox.Parent := FVkNemuSec;
  FVkNemuUnfocusedCheckBox.Caption := 'Cap on window unfocus (Alt+Tab)';
  FVkNemuUnfocusedCheckBox.Visible := False;
  FVkNemuUnfocusedToggle := PlacePerfToggle(FVkNemuUnfocusedCheckBox, FVkNemuSec);
  FVkNemuUnfocusedToggle.OnClick := @FForm.VkNemuControlChange;

  FVkNemuDelayLbl := TLabel.Create(FForm);
  FVkNemuDelayLbl.Parent := FVkNemuSec;
  StyleLabel(FVkNemuDelayLbl, lrControlLabel);
  FVkNemuDelayLbl.Caption := 'Resume Delay (seconds)';
  FVkNemuDelayLbl.AutoSize := False;

  FVkNemuDelaySpin := TSpinEdit.Create(FForm);
  FVkNemuDelaySpin.Parent := FVkNemuSec;
  FVkNemuDelaySpin.AutoSize := False;
  FVkNemuDelaySpin.MinValue := 0;
  FVkNemuDelaySpin.MaxValue := 60;
  FVkNemuDelaySpin.Value := 0;
  FVkNemuDelaySpin.OnChange := @FForm.VkNemuControlChange;

  FForm.UpdateVkNemuFlowDiagram;
  FVkNemuIdleFpsSpin.Enabled := False;
  FVkNemuTimeoutSpin.Enabled := False;
  FVkNemuInputCombo.Enabled := False;
  FVkNemuDelaySpin.Enabled := False;
  FVkNemuUnfocusedToggle.Enabled := False;
  FVkNemuIdleFpsLbl.Enabled := False;
  FVkNemuTimeoutLbl.Enabled := False;
  FVkNemuInputLbl.Enabled := False;
  FVkNemuDelayLbl.Enabled := False;
  FVkNemuIdleFpsLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00A0A0A0, RGBToColor(100, 110, 130));
  FVkNemuTimeoutLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00A0A0A0, RGBToColor(100, 110, 130));
  FVkNemuInputLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00A0A0A0, RGBToColor(100, 110, 130));
  FVkNemuDelayLbl.Font.Color := IfThen(CurrentTheme = tmLight, $00A0A0A0, RGBToColor(100, 110, 130));
  if Assigned(FVkNemuToggleBtn) then
    FVkNemuToggleBtn.ImageIndex := 0;
  end;
end;

procedure TMangoHudUiHelper.PerfScrollBoxResize(Sender: TObject);
begin
  if Assigned(FForm.FPerfScrollBox) then
    ReflowPerformanceTab(FForm.FPerfScrollBox.ClientWidth, FForm.FPerfScrollBox.ClientHeight);
end;

procedure TMangoHudUiHelper.ReflowPerformanceTab(AContentW, AContentH: Integer);
const
  MARGIN     = 4;
  GAP        = 8;
  GB_OFF     = 24;
  IMARGIN    = 6;
  IGAP       = 8;
  CARD0_H    = 185;
  CARD1_H    = 170;
  CARD2_H    = 250;
var
  CardW, SecW, ContW, ContH, i, TotalH: Integer;
  Col1X, Col2X, Col1Left, Col2Left, ColGap: Integer;
  ColorStart, ColW: Integer;
  PillW: Integer;
  LimitW, MethodW, ToggleW, RowGap, TotalRowW, RowStart: Integer;
  Row1LblTop, Row1CtrlTop, Row1CtrlH: Integer;
  FilterSecH: Integer;
  FilterGroupW, FilterLeft, FilterValW, FilterGapW, FilterTrackW: Integer;
  ControlH, LabelW, CtrlW: Integer;
  NemuCtrlH: Integer;
begin
  with FForm do
  begin
  if Assigned(FPerfScrollBox) and (FPerfScrollBox.ClientWidth > 100) then
    AContentW := FPerfScrollBox.ClientWidth;
  CardW := AContentW - 2 * MARGIN;
  if CardW < 100 then Exit;

  if Assigned(FPerfScrollBox) then
    FPerfScrollBox.HorzScrollBar.Range := 0;

  TotalH := MARGIN + CARD0_H + GAP + CARD1_H + GAP + CARD2_H + MARGIN + 100;
  if AContentH > TotalH then
    TotalH := AContentH;
  if Assigned(FPerfBgPanel) then
    FPerfBgPanel.SetBounds(0, 0, CardW + MARGIN * 2, TotalH);
  if Assigned(FPerfScrollBox) then
  begin
    FPerfScrollBox.VertScrollBar.Range   := TotalH;
    FPerfScrollBox.VertScrollBar.Visible := True;
  end;

  if Assigned(FPerfCards[0]) then
  begin
    FPerfCards[0].SetBounds(MARGIN, MARGIN, CardW, CARD0_H);
    FPerfCards[1].SetBounds(MARGIN, MARGIN + CARD0_H + GAP, CardW, CARD1_H);
    FPerfCards[2].SetBounds(MARGIN, MARGIN + CARD0_H + GAP + CARD1_H + GAP, CardW, CARD2_H);

    SecW := (CardW - 2 * IMARGIN - IGAP) div 2;

    // Position sub-section panels for the three cards
    if Assigned(FPerfLimitSec) then
      FPerfLimitSec.SetBounds(IMARGIN, GB_OFF, SecW, CARD0_H - GB_OFF - IMARGIN);
    if Assigned(FPerfVsyncSec) then
      FPerfVsyncSec.SetBounds(IMARGIN + SecW + IGAP, GB_OFF, SecW, CARD0_H - GB_OFF - IMARGIN);

    if Assigned(FPerfInfoSec) then
      FPerfInfoSec.SetBounds(IMARGIN, GB_OFF, SecW, CARD1_H - GB_OFF - IMARGIN);
    if Assigned(FPerfFrametimeSec) then
      FPerfFrametimeSec.SetBounds(IMARGIN + SecW + IGAP, GB_OFF, SecW, CARD1_H - GB_OFF - IMARGIN);

    if Assigned(FVkNemuSec) then
      FVkNemuSec.SetBounds(IMARGIN, GB_OFF, SecW, CARD2_H - GB_OFF - IMARGIN);

    // Reposition Filter controls within FPerfFiltersSec
    if Assigned(FPerfFiltersSec) then
    begin
      FilterSecH := CARD2_H - GB_OFF - IMARGIN;
      FPerfFiltersSec.SetBounds(IMARGIN + SecW + IGAP, GB_OFF, SecW, FilterSecH);

      filterRadioGroup.Left   := (FPerfFiltersSec.ClientWidth - filterRadioGroup.Width) div 2;
      filterRadioGroup.Top    := 10;
      filterRadioGroup.Height := 36;

      FilterValW   := 35;
      FilterGapW   := 8;
      FilterGroupW := Min(460, FPerfFiltersSec.ClientWidth - 40);
      if FilterGroupW < 260 then FilterGroupW := 260;
      FilterLeft   := (FPerfFiltersSec.ClientWidth - FilterGroupW) div 2;
      FilterTrackW := FilterGroupW - FilterGapW - FilterValW;
      if FilterTrackW < 80 then FilterTrackW := 80;

      afLabel.Left          := FilterLeft;
      afLabel.Top           := 50;
      afTrackBar.Left       := FilterLeft;
      afTrackBar.Top        := 68;
      afTrackBar.Width      := FilterTrackW;
      afTrackBar.Height     := 24;

      afvalueLabel.Left     := afTrackBar.Left + afTrackBar.Width + FilterGapW;
      afvalueLabel.Top      := 68;

      mipmapLabel.Left      := FilterLeft;
      mipmapLabel.Top       := 98;
      mipmapTrackBar.Left   := FilterLeft;
      mipmapTrackBar.Top    := 116;
      mipmapTrackBar.Width  := FilterTrackW;
      mipmapTrackBar.Height := 24;

      mipmapvalueLabel.Left := mipmapTrackBar.Left + mipmapTrackBar.Width + FilterGapW;
      mipmapvalueLabel.Top  := 116;
    end;

    // Position section title labels
    for i := 0 to 2 do
    begin
      if Assigned(FPerfLeftLbl[i]) then
        FPerfLeftLbl[i].Left := IMARGIN + 12;
      if Assigned(FPerfRightLbl[i]) then
        FPerfRightLbl[i].Left := IMARGIN + SecW + IGAP + 12;
    end;

    // Frame Rate section — 4 clean rows
    if Assigned(FPerfInfoSec) then
    begin
      // Row 1 (Y=12): Show FPS
      if Assigned(FfpsToggle) then begin FfpsToggle.Left := 16; FfpsToggle.Top := 12; end;

      // Row 2 (Y=44): FPS Average + 1% low / 0.1% low pill right-aligned
      if Assigned(FfpsavgToggle) then begin FfpsavgToggle.Left := 16; FfpsavgToggle.Top := 44; end;
      PillW := Max(128, fpsavgBitBtn.Width);
      fpsavgBitBtn.SetBounds(FPerfInfoSec.ClientWidth - PillW - 16, 41, PillW, 24);

      // Row 3 (Y=76): Show FPS Limit on HUD
      if Assigned(FshowfpslimToggle) then begin FshowfpslimToggle.Left := 16; FshowfpslimToggle.Top := 76; end;

      // Row 4 (Y=108): Count frames
      if Assigned(FframecountToggle) then begin FframecountToggle.Left := 16; FframecountToggle.Top := 108; end;
    end;

    // Frame Timing section — 4 symmetrical rows
    if Assigned(FPerfFrametimeSec) then
    begin
      // Row 1 (Y=12): Frame Time + square swatch + Curve | Histogram pill right-aligned
      if Assigned(FframetimegraphToggle) then
      begin
        FframetimegraphToggle.Left  := 16;
        FframetimegraphToggle.Top   := 12;
        FframetimegraphToggle.Width := FframetimegraphToggle.GetOptimalWidth;
      end;
      frametimegraphColorButton.SetBounds(FframetimegraphToggle.Left + FframetimegraphToggle.Width + 10, 11, 22, 22);
      frametimegraphColorButton.ButtonColorSize := 22;
      PillW := Max(128, frametimetypeBitBtn.Width);
      frametimetypeBitBtn.SetBounds(FPerfFrametimeSec.ClientWidth - PillW - 16, 10, PillW, 24);

      // Row 2 (Y=44): Frame Time +
      if Assigned(FframetimedetailedToggle) then begin FframetimedetailedToggle.Left := 16; FframetimedetailedToggle.Top := 44; end;

      // Row 3 (Y=76): ftrace debug
      if Assigned(FftraceToggle) then begin FftraceToggle.Left := 16; FftraceToggle.Top := 76; end;

      // Row 4 (Y=108): Vulkan Pacing (VPS)
      if Assigned(FvpsToggle) then begin FvpsToggle.Left := 16; FvpsToggle.Top := 108; end;

      if Assigned(FframetimetypeLbl) then FframetimetypeLbl.Visible := False;
    end;

    // Center logo+combo block within each VSYNC row
    if Assigned(FPerfVsyncSec) then
    begin
      if Assigned(FVsyncRows[0]) then
      begin
        FVsyncRows[0].Top    := 20;
        FVsyncRows[0].Height := 48;
        FVsyncRows[0].Width  := FPerfVsyncSec.ClientWidth - 16;
        vulkanImage.Top      := (FVsyncRows[0].Height - vulkanImage.Height) div 2;
        vsyncComboBox.Top    := (FVsyncRows[0].Height - vsyncComboBox.Height) div 2;
        vulkanImage.Left     := (FVsyncRows[0].Width - (vulkanImage.Width + 8 + vsyncComboBox.Width)) div 2;
        vsyncComboBox.Left   := vulkanImage.Left + vulkanImage.Width + 8;
      end;
      if Assigned(FVsyncRows[1]) then
      begin
        FVsyncRows[1].Top    := 80;
        FVsyncRows[1].Height := 48;
        FVsyncRows[1].Width  := FPerfVsyncSec.ClientWidth - 16;
        openglImage.Top      := (FVsyncRows[1].Height - openglImage.Height) div 2;
        glvsyncComboBox.Top  := (FVsyncRows[1].Height - glvsyncComboBox.Height) div 2;
        openglImage.Left     := (FVsyncRows[1].Width - (openglImage.Width + 8 + glvsyncComboBox.Width)) div 2;
        glvsyncComboBox.Left := openglImage.Left + openglImage.Width + 8;
      end;
    end;

    // Reposition controls in the MangoHud Limit sub-card
    if Assigned(FPerfLimitSec) then
    begin
      // Quick preset chips (60 / 120 / 144 / Off) — hidden along with presets label
      if Assigned(FFpsPresetLbl) then
        FFpsPresetLbl.Visible := False;
      for i := 0 to 3 do
        if Assigned(FFpsPresetChips[i]) then
          FFpsPresetChips[i].Visible := False;

      // Place the 3 controls in 3 homogeneous columns
      LimitW  := 105;
      MethodW := 105;
      ToggleW := 105;
      RowGap  := 8;
      TotalRowW := LimitW + RowGap + MethodW + RowGap + ToggleW;
      RowStart  := (FPerfLimitSec.ClientWidth - TotalRowW) div 2;
      if RowStart < 12 then RowStart := 12;
      Row1LblTop  := 22;
      Row1CtrlTop := 42;
      Row1CtrlH   := 32;
      if Assigned(fpslimmetComboBox) and (fpslimmetComboBox.Height > 24) then
        Row1CtrlH := fpslimmetComboBox.Height;

      // Column 1: FPS Limit
      if Assigned(FFpsLimitTitleLbl) then
      begin
        FFpsLimitTitleLbl.Caption := 'FPS Limit';
        FFpsLimitTitleLbl.SetBounds(RowStart, Row1LblTop, LimitW, 16);
        FFpsLimitTitleLbl.Alignment := taLeftJustify;
        FFpsLimitTitleLbl.Visible := True;
      end;
      if Assigned(FFpsLimitEdit) then
      begin
        FFpsLimitEdit.AutoSize := False;
        FFpsLimitEdit.Constraints.MinHeight := Row1CtrlH;
        FFpsLimitEdit.Constraints.MaxHeight := Row1CtrlH;
        FFpsLimitEdit.SetBounds(RowStart, Row1CtrlTop, LimitW, Row1CtrlH);
      end;

      // Column 2: Method
      methodLabel.SetBounds(RowStart + LimitW + RowGap, Row1LblTop, MethodW, 16);
      methodLabel.Alignment := taLeftJustify;
      fpslimmetComboBox.SetBounds(RowStart + LimitW + RowGap, Row1CtrlTop, MethodW, Row1CtrlH);

      // Column 3: Toggle key
      limtoggleLabel.SetBounds(RowStart + LimitW + RowGap + MethodW + RowGap, Row1LblTop, ToggleW, 16);
      limtoggleLabel.Alignment := taLeftJustify;
      if Assigned(FLimitCaptureBtn) then
        FLimitCaptureBtn.SetBounds(RowStart + LimitW + RowGap + MethodW + RowGap, Row1CtrlTop, ToggleW, Row1CtrlH);

      // Hide FFpsLimitHintLbl on the panel
      if Assigned(FFpsLimitHintLbl) then
        FFpsLimitHintLbl.Visible := False;

      // Change FPS colors toggle below Row 1
      if Assigned(FfpscolorToggle) then
      begin
        FfpscolorToggle.Left := (FPerfLimitSec.ClientWidth - FfpscolorToggle.Width) div 2;
        FfpscolorToggle.Top  := 88;
      end;

      // Color swatches & spin edits below toggle
      ColorStart := (FPerfLimitSec.ClientWidth - 250) div 2;
      if ColorStart < 12 then ColorStart := 12;
      fpscolor1ColorButton.SetBounds(ColorStart, 118, 34, 22);
      fpscolor2ColorButton.SetBounds(ColorStart + 48, 118, 34, 22);
      fpscolor2SpinEdit.SetBounds(ColorStart + 90, 116, 52, 24);
      fpscolor3ColorButton.SetBounds(ColorStart + 154, 118, 34, 22);
      fpscolor3SpinEdit.SetBounds(ColorStart + 196, 116, 52, 24);
    end;

    // Idle Limiter (vkNemu) section
    if Assigned(FVkNemuSec) then
    begin
      if Assigned(FVkNemuDivider) then
        FVkNemuDivider.Visible := False;
      if Assigned(FVkNemuToggleBtn) then
        FVkNemuToggleBtn.SetBounds(FVkNemuSec.ClientWidth - 44 - 14, 5, 44, 24);
      if Assigned(FVkNemuSectionLbl) then
      begin
        FVkNemuSectionLbl.Visible := True;
        FVkNemuSectionLbl.SetBounds(14, 8, FVkNemuSec.ClientWidth - 44 - 28, 18);
      end;

      if Assigned(FVkNemuFlowCard) then
        FVkNemuFlowCard.SetBounds(14, 28, FVkNemuSec.ClientWidth - 28, 44);

      ColW := (FVkNemuSec.ClientWidth - 28 - 14) div 2;
      Col1Left := 14;
      Col2Left := 14 + ColW + 14;

      NemuCtrlH := 32;
      if Assigned(FVkNemuInputCombo) and (FVkNemuInputCombo.Height > 24) then
        NemuCtrlH := FVkNemuInputCombo.Height;

      // Row 1: Idle FPS | Timeout
      if Assigned(FVkNemuIdleFpsLbl) then
      begin
        FVkNemuIdleFpsLbl.Caption := 'Idle FPS:';
        FVkNemuIdleFpsLbl.SetBounds(Col1Left, 78, ColW, 16);
      end;
      if Assigned(FVkNemuIdleFpsSpin) then
      begin
        FVkNemuIdleFpsSpin.AutoSize := False;
        FVkNemuIdleFpsSpin.Constraints.MinHeight := NemuCtrlH;
        FVkNemuIdleFpsSpin.Constraints.MaxHeight := NemuCtrlH;
        FVkNemuIdleFpsSpin.SetBounds(Col1Left, 96, ColW, NemuCtrlH);
      end;

      if Assigned(FVkNemuTimeoutLbl) then
      begin
        FVkNemuTimeoutLbl.Caption := 'Timeout (sec):';
        FVkNemuTimeoutLbl.SetBounds(Col2Left, 78, ColW, 16);
      end;
      if Assigned(FVkNemuTimeoutSpin) then
      begin
        FVkNemuTimeoutSpin.AutoSize := False;
        FVkNemuTimeoutSpin.Constraints.MinHeight := NemuCtrlH;
        FVkNemuTimeoutSpin.Constraints.MaxHeight := NemuCtrlH;
        FVkNemuTimeoutSpin.SetBounds(Col2Left, 96, ColW, NemuCtrlH);
      end;

      // Row 2: Wake | Delay
      if Assigned(FVkNemuInputLbl) then
      begin
        FVkNemuInputLbl.Caption := 'Wake:';
        FVkNemuInputLbl.SetBounds(Col1Left, 134, ColW, 16);
      end;
      if Assigned(FVkNemuInputCombo) then
      begin
        FVkNemuInputCombo.Constraints.MinHeight := NemuCtrlH;
        FVkNemuInputCombo.Constraints.MaxHeight := NemuCtrlH;
        FVkNemuInputCombo.SetBounds(Col1Left, 152, ColW, NemuCtrlH);
      end;

      if Assigned(FVkNemuDelayLbl) then
      begin
        FVkNemuDelayLbl.Caption := 'Delay (sec):';
        FVkNemuDelayLbl.SetBounds(Col2Left, 134, ColW, 16);
      end;
      if Assigned(FVkNemuDelaySpin) then
      begin
        FVkNemuDelaySpin.AutoSize := False;
        FVkNemuDelaySpin.Constraints.MinHeight := NemuCtrlH;
        FVkNemuDelaySpin.Constraints.MaxHeight := NemuCtrlH;
        FVkNemuDelaySpin.SetBounds(Col2Left, 152, ColW, NemuCtrlH);
      end;

      // Row 3: Cap on window unfocus
      if Assigned(FVkNemuUnfocusedToggle) then
      begin
        FVkNemuUnfocusedToggle.Left   := 14;
        FVkNemuUnfocusedToggle.Top    := 192;
        FVkNemuUnfocusedToggle.Width  := FVkNemuUnfocusedToggle.GetOptimalWidth;
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
  if Assigned(FForm) then
    FForm.VkNemuToggleChange(nil);
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

  for i := 0 to 2 do
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
      if Card.Controls[j] is TPanel then
      begin
        TPanel(Card.Controls[j]).Color := CardBg;
        TPanel(Card.Controls[j]).Invalidate;
      end;
    end;
  end;

  if Assigned(FVkNemuDivider) then
    FVkNemuDivider.Color := IfThen(CurrentTheme = tmLight, $00E0E0E0, $00342620);

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

  // Anti-aliasing / mipmap value labels: keep accent styling across themes
  if Assigned(afvalueLabel) then
  begin
    afvalueLabel.Font.Color  := CLR_TEXT_ACCENT;
    afvalueLabel.Font.Style  := [fsBold];
    afvalueLabel.Transparent := True;
  end;
  if Assigned(mipmapvalueLabel) then
  begin
    mipmapvalueLabel.Font.Color  := CLR_TEXT_ACCENT;
    mipmapvalueLabel.Font.Style  := [fsBold];
    mipmapvalueLabel.Transparent := True;
  end;

  if Assigned(FFpsLimitTitleLbl) then
    FFpsLimitTitleLbl.Font.Color := TextColor;

  // FPS Limit edit: update colors for theme
  if Assigned(FFpsLimitEdit) then
  begin
    FFpsLimitEdit.Font.Color := TextColor;
    FFpsLimitEdit.Color := IfThen(CurrentTheme = tmLight, clWhite, RGBToColor(38, 46, 72));
    if CurrentTheme = tmLight then
      SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: 1px solid rgb(210,215,225); border-radius: 4px; padding: 2px; }' +
            'QLineEdit:hover { border: 1px solid rgb(160,175,200); }' +
            'QLineEdit:focus { border: 1px solid rgb(48,120,200); }'
    else
      SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px; }' +
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

  // Filter radio buttons: update colors for theme
  if Assigned(filterRadioGroup) then
  begin
    filterRadioGroup.Font.Color := TextColor;
    if CurrentTheme = tmLight then
      SS := 'QGroupBox { border: none; } QRadioButton { color: rgb(0,0,0); background-color: transparent; }'
    else
      SS := 'QGroupBox { border: none; } QRadioButton { color: rgb(255,255,255); background-color: transparent; }';
    QWidget_setStyleSheet(TQtWidget(filterRadioGroup.Handle).Widget, @SS);
  end;

  // Limit toggle capture button & labels
  if Assigned(methodLabel) then
    methodLabel.Font.Color := TextColor;
  if Assigned(limtoggleLabel) then
    limtoggleLabel.Font.Color := TextColor;

  RefreshFormatPills;
  if Assigned(FLimitCaptureBtn) then
    StyleBitBtnTheme(FLimitCaptureBtn, TextColor, CardBg);

  for i := 0 to 3 do
    if Assigned(FFpsPresetChips[i]) then
      StyleBitBtnTheme(FFpsPresetChips[i], TextColor, CardBg);

  if Assigned(FPerfScrollBox) then
    FPerfScrollBox.Color := IfThen(CurrentTheme = tmLight, RGBToColor(240, 243, 248), RGBToColor(22, 26, 40));
  if Assigned(FPerfBgPanel) then
    FPerfBgPanel.Color := IfThen(CurrentTheme = tmLight, RGBToColor(240, 243, 248), RGBToColor(22, 26, 40));
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
  HDR      = 34;   // accent bar (3px) + title label area

  procedure MakeCard(out Card: TPanel; out TitleLbl: TLabel; const ATitle: string);
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
      TitleLbl := Lbl;
    end;
  end;

  procedure MakeSubSec(out Sec: TPanel; AParent: TPanel);
  begin
    Sec := TPanel.Create(FForm);
    Sec.Parent      := AParent;
    Sec.Caption     := '';
    Sec.BevelOuter  := bvNone;
    Sec.ParentColor := False;
    Sec.Color       := CARD_BG;
    Sec.OnPaint     := @FForm.SubCardPaint;
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

  procedure DarkSectLbl(L: TLabel);
  begin
    L.Font.Color  := clWhite;
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
  FMtScrollBox.AutoScroll  := False;
  FMtScrollBox.BorderStyle := bsNone;
  FMtScrollBox.HorzScrollBar.Visible := False;
  FMtScrollBox.HorzScrollBar.Range   := 0;
  FMtScrollBox.VertScrollBar.Visible := False;
  FMtScrollBox.VertScrollBar.Range   := 0;
  FMtScrollBox.Color       := RGBToColor(22, 26, 40);
  FMtScrollBox.ParentColor := False;
  ApplyModernScrollBarStylesheet(FMtScrollBox);
  FMtScrollBox.OnResize := @MtScrollBoxResize;

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

  // ── Card 0: GPU Metrics ─────────────────────────────────────────────────
  // All Y values = LFM position + HDR (34) to offset below the card header.
  MakeCard(FMtGpuCard, FGpuTitleLbl, 'GPU Metrics');

  // Thematic sub-cards
  MakeSubSec(FGpuCoreSec,    FMtGpuCard);
  MakeSubSec(FGpuThermalSec, FMtGpuCard);
  MakeSubSec(FGpuPowerSec,   FMtGpuCard);
  MakeSubSec(FGpuInfoSec,    FMtGpuCard);

  mainmetricLabel.Caption := 'Core & Telemetry';
  gputempLabel.Caption    := 'Thermals & Cooling';
  gpupowerLabel.Caption   := 'Power & Energy';
  gpuinfoLabel.Caption    := 'Hardware & Drivers';
  mainmetricLabel.ShowAccelChar := False;
  gputempLabel.ShowAccelChar    := False;
  gpupowerLabel.ShowAccelChar   := False;
  gpuinfoLabel.ShowAccelChar    := False;

  // GPU HUD name controls in the card header
  Place(gpuColorButton, FMtGpuCard, 0, 0);
  gpuColorButton.Color    := CARD_BG;
  gpuColorButton.ShowHint := True;

  Place(gpunameEdit, FMtGpuCard, 0, 0);
  gpunameEdit.Color      := CARD_BG;
  gpunameEdit.Font.Color := WHITE;
  gpunameEdit.Font.Size  := 9;
  gpunameEdit.TextHint   := 'Default (GPU)';
  gpunameEdit.ShowHint   := True;

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
  DarkSectLbl(mainmetricLabel);
  gpuload1ColorButton.Color := CARD_BG;
  gpuload2ColorButton.Color := CARD_BG;
  gpuload3ColorButton.Color := CARD_BG;
  vramColorButton.Color := CARD_BG;
  gpuload1ColorButton.ShowHint := True;
  gpuload2ColorButton.ShowHint := True;
  gpuload3ColorButton.ShowHint := True;
  vramColorButton.ShowHint := True;

  // Section: Temperature (label Top=113, controls Top=134)
  Place(gputempLabel,        FMtGpuCard, 11,  113 + HDR);
  FgputempToggle     := PlaceToggle(gputempCheckBox, FMtGpuCard, 11, 134 + HDR);
  FgputempToggle.HasGraphButton := True;
  FgputempToggle.OnGraphClick   := @MetricGraphClick;
  FgpumemtempToggle  := PlaceToggle(gpumemtempCheckBox, FMtGpuCard, 120, 134 + HDR);
  FgpujunctempToggle := PlaceToggle(gpujunctempCheckBox, FMtGpuCard, 266, 134 + HDR);
  FgpufanToggle      := PlaceToggle(gpufanCheckBox, FMtGpuCard, 381, 134 + HDR);
  DarkSectLbl(gputempLabel);

  // Section: Power (label Top=170, controls Top=191/213)
  Place(gpupowerLabel,           FMtGpuCard, 11,  170 + HDR);
  FgpupowerToggle           := PlaceToggle(gpupowerCheckBox, FMtGpuCard, 11, 191 + HDR);
  FgpuvoltageToggle         := PlaceToggle(gpuvoltageCheckBox, FMtGpuCard, 120, 191 + HDR);
  FgputhrottlingToggle      := PlaceToggle(gputhrottlingCheckBox, FMtGpuCard, 266, 191 + HDR);
  FgputhrottlinggraphToggle := PlaceToggle(gputhrottlinggraphCheckBox, FMtGpuCard, 381, 191 + HDR);
  FgpuefficiencyToggle      := PlaceToggle(gpuefficiencyCheckBox, FMtGpuCard, 519, 191 + HDR);
  FgpupowerlimitToggle      := PlaceToggle(gpupowerlimitCheckBox, FMtGpuCard, 611, 191 + HDR);
  Place(gpuframesjouleBitBtn,    FMtGpuCard, 516, 213 + HDR);
  gpuframesjouleBitBtn.ShowHint := True;
  DarkSectLbl(gpupowerLabel);

  // Section: Information (label Top=227, controls Top=248)
  Place(gpuinfoLabel,      FMtGpuCard, 11,  227 + HDR);
  FgpumodelToggle     := PlaceToggle(gpumodelCheckBox, FMtGpuCard, 11, 248 + HDR);
  FvulkandriverToggle := PlaceToggle(vulkandriverCheckBox, FMtGpuCard, 120, 248 + HDR);
  FprocvramToggle     := PlaceToggle(procvramCheckBox, FMtGpuCard, 266, 248 + HDR);
  DarkSectLbl(gpuinfoLabel);

  // ── Card 1: CPU Metrics ─────────────────────────────────────────────────
  MakeCard(FMtCpuCard, FCpuTitleLbl, 'CPU Metrics');

  // Thematic sub-cards
  MakeSubSec(FCpuCoreSec,    FMtCpuCard);
  MakeSubSec(FCpuThermalSec, FMtCpuCard);

  // ── Card 2: Memory Metrics ──────────────────────────────────────────────
  MakeCard(FMtMemCard, FMemTitleLbl, 'Memory metrics');

  // Thematic sub-cards
  MakeSubSec(FCpuMemSec,     FMtMemCard);
  MakeSubSec(FCpuStorageSec, FMtMemCard);

  cpumainmetricsLabel.Caption := 'Processor Core & Freq';
  cputempLabel.Caption        := 'CPU Thermals & Power';
  memLabel.Caption            := 'Memory & Swap';
  FStorageLabel := TLabel.Create(FCpuStorageSec);
  FStorageLabel.Parent := FCpuStorageSec;
  FStorageLabel.Caption := 'Storage & Disk IO';
  DarkSectLbl(FStorageLabel);
  cpumainmetricsLabel.ShowAccelChar := False;
  cputempLabel.ShowAccelChar        := False;
  memLabel.ShowAccelChar            := False;
  FStorageLabel.ShowAccelChar       := False;

  // CPU HUD name controls in the card header
  Place(cpuColorButton, FMtCpuCard, 0, 0);
  cpuColorButton.Color    := CARD_BG;
  cpuColorButton.ShowHint := True;

  Place(cpunameEdit, FMtCpuCard, 0, 0);
  cpunameEdit.Color      := CARD_BG;
  cpunameEdit.Font.Color := WHITE;
  cpunameEdit.Font.Size  := 9;
  cpunameEdit.TextHint   := 'Default (CPU)';
  cpunameEdit.ShowHint   := True;

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
  coreloadtypeBitBtn.Images   := nil;
  coreloadtypeBitBtn.ShowHint := True;
  FcpufreqToggle      := PlaceToggle(cpufreqCheckBox, FMtCpuCard, 382, 66 + HDR);
  FcpucoretypeToggle  := PlaceToggle(cpucoretypeCheckBox, FMtCpuCard, 516, 66 + HDR);
  DarkSectLbl(cpumainmetricsLabel);
  cpuload1ColorButton.Color := CARD_BG;
  cpuload2ColorButton.Color := CARD_BG;
  cpuload3ColorButton.Color := CARD_BG;
  cpuload1ColorButton.ShowHint := True;
  cpuload2ColorButton.ShowHint := True;
  cpuload3ColorButton.ShowHint := True;
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
  cpuframesjouleBitBtn.ShowHint := True;
  DarkSectLbl(cputempLabel);
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
  DarkSectLbl(memLabel);
  ramColorButton.Color    := CARD_BG;
  iordrwColorButton.Color := CARD_BG;
  ramColorButton.ShowHint    := True;
  iordrwColorButton.ShowHint := True;

  // ── Reparent controls into their thematic sub-cards ─────────────────────
  mainmetricLabel.Parent       := FGpuCoreSec;
  FgpuavgloadToggle.Parent     := FGpuCoreSec;
  FgpuloadcolorToggle.Parent   := FGpuCoreSec;
  gpuload1ColorButton.Parent   := FGpuCoreSec;
  gpuload2ColorButton.Parent   := FGpuCoreSec;
  gpuload3ColorButton.Parent   := FGpuCoreSec;
  FvramusageToggle.Parent      := FGpuCoreSec;
  vramColorButton.Parent       := FGpuCoreSec;
  FgpufreqToggle.Parent        := FGpuCoreSec;
  FgpumemfreqToggle.Parent     := FGpuCoreSec;
  FprocvramToggle.Parent       := FGpuCoreSec;

  gputempLabel.Parent          := FGpuThermalSec;
  FgputempToggle.Parent        := FGpuThermalSec;
  FgpumemtempToggle.Parent     := FGpuThermalSec;
  FgpujunctempToggle.Parent    := FGpuThermalSec;
  FgpufanToggle.Parent         := FGpuThermalSec;
  FgputhrottlingToggle.Parent  := FGpuThermalSec;
  FgputhrottlinggraphToggle.Parent := FGpuThermalSec;

  gpupowerLabel.Parent         := FGpuPowerSec;
  FgpupowerToggle.Parent       := FGpuPowerSec;
  FgpuvoltageToggle.Parent     := FGpuPowerSec;
  FgpuefficiencyToggle.Parent  := FGpuPowerSec;
  gpuframesjouleBitBtn.Parent  := FGpuPowerSec;
  FgpupowerlimitToggle.Parent  := FGpuPowerSec;

  gpuinfoLabel.Parent          := FGpuInfoSec;
  FgpumodelToggle.Parent       := FGpuInfoSec;
  FvulkandriverToggle.Parent   := FGpuInfoSec;

  cpumainmetricsLabel.Parent   := FCpuCoreSec;
  FcpuavgloadToggle.Parent     := FCpuCoreSec;
  FcpuloadcolorToggle.Parent   := FCpuCoreSec;
  cpuload1ColorButton.Parent   := FCpuCoreSec;
  cpuload2ColorButton.Parent   := FCpuCoreSec;
  cpuload3ColorButton.Parent   := FCpuCoreSec;
  FcpuloadcoreToggle.Parent    := FCpuCoreSec;
  coreloadtypeBitBtn.Parent    := FCpuCoreSec;
  FcpufreqToggle.Parent        := FCpuCoreSec;
  FcpucoretypeToggle.Parent    := FCpuCoreSec;

  cputempLabel.Parent          := FCpuThermalSec;
  FcputempToggle.Parent        := FCpuThermalSec;
  FcpupowerToggle.Parent       := FCpuThermalSec;
  intelpowerfixBitBtn.Parent   := FCpuThermalSec;
  FcpuefficiencyToggle.Parent  := FCpuThermalSec;
  cpuframesjouleBitBtn.Parent  := FCpuThermalSec;

  memLabel.Parent              := FCpuMemSec;
  FramusageToggle.Parent       := FCpuMemSec;
  ramColorButton.Parent        := FCpuMemSec;
  FramtempToggle.Parent        := FCpuMemSec;
  FprocmemToggle.Parent        := FCpuMemSec;
  FswapusageToggle.Parent      := FCpuMemSec;

  FdiskioToggle.Parent         := FCpuStorageSec;
  iordrwColorButton.Parent     := FCpuStorageSec;
  end;

  // Apply the initial theme so the tab is styled from the first paint
  UpdateMetricsCardTheme;
end;


procedure TMangoHudUiHelper.RefreshFormatPills;
begin
  with FForm do
  begin
    if Assigned(coreloadtypeBitBtn) then
    begin
      SetSegmentedPillGlyph(coreloadtypeBitBtn, '%', 'Bars', IfThen(coreloadtypeBitBtn.ImageIndex = 7, 1, 0));
      StyleSegmentedFormatBtn(coreloadtypeBitBtn);
    end;
    if Assigned(gpuframesjouleBitBtn) then
    begin
      SetSegmentedPillGlyph(gpuframesjouleBitBtn, 'F/J', 'J/F', IfThen(gpuframesjouleBitBtn.Tag = 1, 1, 0));
      StyleSegmentedFormatBtn(gpuframesjouleBitBtn);
    end;
    if Assigned(cpuframesjouleBitBtn) then
    begin
      SetSegmentedPillGlyph(cpuframesjouleBitBtn, 'F/J', 'J/F', IfThen(cpuframesjouleBitBtn.Tag = 1, 1, 0));
      StyleSegmentedFormatBtn(cpuframesjouleBitBtn);
    end;
    if Assigned(fpsavgBitBtn) then
    begin
      SetSegmentedPillGlyph(fpsavgBitBtn, '1% low', '0.1% low', IfThen(fpsavgBitBtn.ImageIndex = 10, 1, 0));
      StyleSegmentedFormatBtn(fpsavgBitBtn);
      fpsavgBitBtn.Width  := fpsavgBitBtn.Glyph.Width + 24;
      fpsavgBitBtn.Height := 22;
      fpsavgBitBtn.ShowHint := True;
    end;
    if Assigned(frametimetypeBitBtn) then
    begin
      SetSegmentedPillGlyph(frametimetypeBitBtn, 'Curve', 'Histogram', IfThen(frametimetypeBitBtn.ImageIndex = 7, 1, 0));
      StyleSegmentedFormatBtn(frametimetypeBitBtn);
      frametimetypeBitBtn.Width  := frametimetypeBitBtn.Glyph.Width + 24;
      frametimetypeBitBtn.Height := 22;
      frametimetypeBitBtn.ShowHint := True;
    end;
    if Assigned(FExtTempPillBtn) then
    begin
      SetSegmentedPillGlyph(FExtTempPillBtn, '°C', '°F', IfThen(fahrenheitCheckBox.Checked, 1, 0));
      StyleSegmentedFormatBtn(FExtTempPillBtn);
      FExtTempPillBtn.Width  := FExtTempPillBtn.Glyph.Width + 24;
      FExtTempPillBtn.Height := 22;
      FExtTempPillBtn.ShowHint := True;
      FExtTempPillBtn.Hint := 'Temperature display unit (°C / °F)';
    end;
  end;
end;

procedure TMangoHudUiHelper.UpdateMetricsCardTheme;
var
  TextColor, TitleColor: TColor;
  SS: WideString;

  procedure ApplySectLabel(L: TLabel; AColor: TColor);
  begin
    if not Assigned(L) then Exit;
    L.Font.Color  := AColor;
    L.Font.Style  := [fsBold];
    L.Transparent := True;
  end;

  procedure ApplyNameEdit(E: TEdit);
  begin
    if not Assigned(E) then Exit;
    E.Font.Color := TextColor;
    if CurrentTheme = tmLight then
      E.Color := clWhite
    else
      E.Color := RGBToColor(38, 46, 72);
    if E.HandleAllocated then
      QWidget_setStyleSheet(TQtWidget(E.Handle).Widget, @SS);
  end;

begin
  with FForm do
  begin
  if not Assigned(FMtGpuCard) and not Assigned(FMtCpuCard) and not Assigned(FMtMemCard) then Exit;

  if CurrentTheme = tmLight then
  begin
    TextColor  := LightTextColor;
    TitleColor := LightTextColor;
  end
  else
  begin
    TextColor  := DarkTextColor;
    TitleColor := clWhite;
  end;

  // Card backgrounds / generic control colors first
  UpdateGenericCardTheme(FMtGpuCard);
  UpdateGenericCardTheme(FMtCpuCard);
  UpdateGenericCardTheme(FMtMemCard);

  // Thematic sub-cards and their child labels / controls
  UpdateGenericCardTheme(FGpuCoreSec);
  UpdateGenericCardTheme(FGpuThermalSec);
  UpdateGenericCardTheme(FGpuPowerSec);
  UpdateGenericCardTheme(FGpuInfoSec);
  UpdateGenericCardTheme(FCpuCoreSec);
  UpdateGenericCardTheme(FCpuThermalSec);
  UpdateGenericCardTheme(FCpuMemSec);
  UpdateGenericCardTheme(FCpuStorageSec);

  // Force QLineEdit stylesheet — KDE/Breeze ignores LCL Color/Font.Color
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: 1px solid rgb(210,215,225); border-radius: 6px; padding: 2px 6px; }' +
          'QLineEdit:hover { border: 1px solid rgb(160,175,200); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,120,200); }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px 6px; }' +
          'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
  ApplyNameEdit(gpunameEdit);
  ApplyNameEdit(cpunameEdit);

  // Section titles: white in dark theme, dark in light theme
  ApplySectLabel(mainmetricLabel,     TitleColor);
  ApplySectLabel(gputempLabel,        TitleColor);
  ApplySectLabel(gpupowerLabel,       TitleColor);
  ApplySectLabel(gpuinfoLabel,        TitleColor);
  ApplySectLabel(cpumainmetricsLabel, TitleColor);
  ApplySectLabel(cputempLabel,        TitleColor);
  ApplySectLabel(memLabel,            TitleColor);
  ApplySectLabel(FStorageLabel,       TitleColor);

  // Segmented dual-pill format buttons
  RefreshFormatPills;
  end;
end;


procedure TMangoHudUiHelper.ReflowMetricsTab(AContentW: Integer);
const
  MARGIN       = 4;
  GAP          = 8;
  BASE_GPU_H   = 302;
  BASE_CPU_H   = 180;
  BASE_MEM_H   = 146;
  BASE_TOTAL_H = BASE_GPU_H + BASE_CPU_H + BASE_MEM_H; // = 628
  Col1X        = 12;
  R1Y          = 28;
  R2Y          = 56;
  R3Y          = 84;
var
  CW, SecW, Sec1Left, Sec2Left: Integer;
  Row1Top, Row2Top, ActiveGpuH, Sec1H_GPU, Sec2H_GPU: Integer;
  CpuRow1Top, ActiveCpuH, SecH_CPU: Integer;
  MemRow1Top, ActiveMemH, SecH_Mem: Integer;
  Col2X, TotalH, AvailH, ExtraH, AvailGpuSub: Integer;
begin
  with FForm do
  begin
  if not Assigned(FMtScrollBox) then Exit;
  CW := FMtScrollBox.ClientWidth - 2 * MARGIN;
  if CW < 100 then Exit;

  FMtScrollBox.HorzScrollBar.Range := 0;

  // ── Sub-card grid metrics ───────────────────────────────────────────────
  SecW := (CW - 3 * GAP) div 2;
  Sec1Left := GAP;
  Sec2Left := Sec1Left + SecW + GAP;

  Row1Top    := 56;
  CpuRow1Top := 56;
  MemRow1Top := 46;

  // Dynamically expand card heights to fill the available window height
  AvailH := FMtScrollBox.ClientHeight - 2 * MARGIN - 2 * GAP;
  if AvailH > BASE_TOTAL_H then
  begin
    ExtraH := AvailH - BASE_TOTAL_H;
    ActiveGpuH := BASE_GPU_H + Round(ExtraH * 0.48);
    ActiveCpuH := BASE_CPU_H + Round(ExtraH * 0.28);
    ActiveMemH := AvailH - ActiveGpuH - ActiveCpuH;
  end
  else
  begin
    ActiveGpuH := BASE_GPU_H;
    ActiveCpuH := BASE_CPU_H;
    ActiveMemH := BASE_MEM_H;
  end;

  // Dynamically calculate sub-card heights
  AvailGpuSub := ActiveGpuH - Row1Top - GAP - 10;
  Sec1H_GPU   := AvailGpuSub div 2;
  Sec2H_GPU   := AvailGpuSub - Sec1H_GPU;
  Row2Top     := Row1Top + Sec1H_GPU + GAP;

  SecH_CPU := ActiveCpuH - CpuRow1Top - 10;
  SecH_Mem := ActiveMemH - MemRow1Top - 10;

  TotalH := MARGIN + ActiveGpuH + GAP + ActiveCpuH + GAP + ActiveMemH + MARGIN;
  if FMtScrollBox.ClientHeight > TotalH then
    TotalH := FMtScrollBox.ClientHeight;
  FMtBgPanel.SetBounds(0, 0, FMtScrollBox.ClientWidth, TotalH);
  FMtScrollBox.VertScrollBar.Range := 0;
  FMtScrollBox.VertScrollBar.Visible := False;

  // GPU, CPU and Memory cards
  FMtGpuCard.SetBounds(MARGIN, MARGIN, CW, ActiveGpuH);
  FMtCpuCard.SetBounds(MARGIN, MARGIN + ActiveGpuH + GAP, CW, ActiveCpuH);
  FMtMemCard.SetBounds(MARGIN, MARGIN + ActiveGpuH + GAP + ActiveCpuH + GAP, CW, ActiveMemH);

  FGpuTitleLbl.Left := 16;
  FGpuTitleLbl.Top  := 10;
  gpuColorButton.SetBounds(FGpuTitleLbl.Left + FGpuTitleLbl.Width + 10, 8, 22, 22);
  gpunameEdit.SetBounds(gpuColorButton.Left + gpuColorButton.Width + 8, 7, 185, 24);

  FCpuTitleLbl.Left := 16;
  FCpuTitleLbl.Top  := 10;
  cpuColorButton.SetBounds(FCpuTitleLbl.Left + FCpuTitleLbl.Width + 10, 8, 22, 22);
  cpunameEdit.SetBounds(cpuColorButton.Left + cpuColorButton.Width + 8, 7, 185, 24);

  FMemTitleLbl.Left := 16;
  FMemTitleLbl.Top  := 10;

  // Position GPU sub-cards
  FGpuCoreSec.SetBounds(Sec1Left, Row1Top, SecW, Sec1H_GPU);
  FGpuThermalSec.SetBounds(Sec2Left, Row1Top, SecW, Sec1H_GPU);
  FGpuPowerSec.SetBounds(Sec1Left, Row2Top, SecW, Sec2H_GPU);
  FGpuInfoSec.SetBounds(Sec2Left, Row2Top, SecW, Sec2H_GPU);

  // Position CPU sub-cards
  FCpuCoreSec.SetBounds(Sec1Left, CpuRow1Top, SecW, SecH_CPU);
  FCpuThermalSec.SetBounds(Sec2Left, CpuRow1Top, SecW, SecH_CPU);

  // Position Memory sub-cards
  FCpuMemSec.SetBounds(Sec1Left, MemRow1Top, SecW, SecH_Mem);
  FCpuStorageSec.SetBounds(Sec2Left, MemRow1Top, SecW, SecH_Mem);

  // ── Controls inside sub-cards (inline secondary controls) ───────────────
  Col2X := SecW div 2 + 6;

  // FGpuCoreSec
  mainmetricLabel.SetBounds(12, 8, SecW - 24, 18);
  FgpuavgloadToggle.Left := Col1X; FgpuavgloadToggle.Top := R1Y;
  FgpufreqToggle.Left := Col2X; FgpufreqToggle.Top := R1Y;
  FgpuloadcolorToggle.Left := Col1X; FgpuloadcolorToggle.Top := R2Y;
  gpuload1ColorButton.SetBounds(Col1X + FgpuloadcolorToggle.Width + 6, R2Y, 20, 20);
  gpuload2ColorButton.SetBounds(gpuload1ColorButton.Left + 24, R2Y, 20, 20);
  gpuload3ColorButton.SetBounds(gpuload2ColorButton.Left + 24, R2Y, 20, 20);
  FgpumemfreqToggle.Left := Col2X; FgpumemfreqToggle.Top := R2Y;
  FvramusageToggle.Left := Col1X; FvramusageToggle.Top := R3Y;
  vramColorButton.SetBounds(Col1X + FvramusageToggle.Width + 6, R3Y, 20, 20);
  FprocvramToggle.Left := Col2X; FprocvramToggle.Top := R3Y;

  // FGpuThermalSec
  gputempLabel.SetBounds(12, 8, SecW - 24, 18);
  FgputempToggle.Left := Col1X; FgputempToggle.Top := R1Y;
  FgpumemtempToggle.Left := Col2X; FgpumemtempToggle.Top := R1Y;
  FgpujunctempToggle.Left := Col1X; FgpujunctempToggle.Top := R2Y;
  FgpufanToggle.Left := Col2X; FgpufanToggle.Top := R2Y;
  FgputhrottlingToggle.Left := Col1X; FgputhrottlingToggle.Top := R3Y;
  FgputhrottlinggraphToggle.Left := Col2X; FgputhrottlinggraphToggle.Top := R3Y;

  // FGpuPowerSec
  gpupowerLabel.SetBounds(12, 8, SecW - 24, 18);
  FgpupowerToggle.Left := Col1X; FgpupowerToggle.Top := R1Y;
  FgpuvoltageToggle.Left := Col2X; FgpuvoltageToggle.Top := R1Y;
  FgpupowerlimitToggle.Left := Col1X; FgpupowerlimitToggle.Top := R2Y;
  FgpuefficiencyToggle.Left := Col1X; FgpuefficiencyToggle.Top := R3Y;
  gpuframesjouleBitBtn.SetBounds(Col1X + FgpuefficiencyToggle.Width + 6, R3Y, 88, 22);

  // FGpuInfoSec
  gpuinfoLabel.SetBounds(12, 8, SecW - 24, 18);
  FgpumodelToggle.Left := Col1X; FgpumodelToggle.Top := R1Y;
  FvulkandriverToggle.Left := Col2X; FvulkandriverToggle.Top := R1Y;

  // FCpuCoreSec
  cpumainmetricsLabel.SetBounds(12, 8, SecW - 24, 18);
  FcpuavgloadToggle.Left := Col1X; FcpuavgloadToggle.Top := R1Y;
  FcpufreqToggle.Left := Col2X; FcpufreqToggle.Top := R1Y;
  FcpuloadcolorToggle.Left := Col1X; FcpuloadcolorToggle.Top := R2Y;
  cpuload1ColorButton.SetBounds(Col1X + FcpuloadcolorToggle.Width + 6, R2Y, 20, 20);
  cpuload2ColorButton.SetBounds(cpuload1ColorButton.Left + 24, R2Y, 20, 20);
  cpuload3ColorButton.SetBounds(cpuload2ColorButton.Left + 24, R2Y, 20, 20);
  FcpucoretypeToggle.Left := Col2X; FcpucoretypeToggle.Top := R2Y;
  FcpuloadcoreToggle.Left := Col1X; FcpuloadcoreToggle.Top := R3Y;
  coreloadtypeBitBtn.SetBounds(Col1X + FcpuloadcoreToggle.Width + 4, R3Y, 84, 22);

  // FCpuThermalSec
  cputempLabel.SetBounds(12, 8, SecW - 24, 18);
  FcputempToggle.Left := Col1X; FcputempToggle.Top := R1Y;
  FcpupowerToggle.Left := Col1X; FcpupowerToggle.Top := R2Y;
  intelpowerfixBitBtn.SetBounds(Col1X + FcpupowerToggle.Width + 4, R2Y, 105, 22);
  FcpuefficiencyToggle.Left := Col1X; FcpuefficiencyToggle.Top := R3Y;
  cpuframesjouleBitBtn.SetBounds(Col1X + FcpuefficiencyToggle.Width + 6, R3Y, 88, 22);

  // FCpuMemSec
  memLabel.SetBounds(12, 8, SecW - 24, 18);
  FramusageToggle.Left := Col1X; FramusageToggle.Top := R1Y;
  ramColorButton.SetBounds(Col1X + FramusageToggle.Width + 6, R1Y, 20, 20);
  FramtempToggle.Left := Col2X; FramtempToggle.Top := R1Y;
  FprocmemToggle.Left := Col1X; FprocmemToggle.Top := R2Y;
  FswapusageToggle.Left := Col2X; FswapusageToggle.Top := R2Y;

  // FCpuStorageSec
  if Assigned(FStorageLabel) then
    FStorageLabel.SetBounds(12, 8, SecW - 24, 18);
  FdiskioToggle.Left := Col1X; FdiskioToggle.Top := R1Y;
  iordrwColorButton.SetBounds(Col1X + FdiskioToggle.Width + 6, R1Y, 20, 20);
  end;
end;

procedure TMangoHudUiHelper.MtScrollBoxResize(Sender: TObject);
begin
  if Assigned(FForm.FMtScrollBox) then
    ReflowMetricsTab(FForm.FMtScrollBox.ClientWidth);
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

var
  TextColor: TColor;
  SS: String;

  procedure MakeCard(out Card: TPanel; out TitleLbl: TLabel; const ATitle: string);
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
      TitleLbl := Lbl;
    end;
  end;

  procedure MakeSubSec(out Sec: TPanel; AParent: TPanel);
  begin
    Sec := TPanel.Create(FForm);
    Sec.Parent      := AParent;
    Sec.Caption     := '';
    Sec.BevelOuter  := bvNone;
    Sec.ParentColor := False;
    Sec.Color       := CARD_BG;
    Sec.OnPaint     := @FForm.SubCardPaint;
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
    L.Font.Color  := IfThen(CurrentTheme = tmLight, LightTextColor, clWhite);
    L.Font.Style  := [fsBold];
    L.Transparent := True;
  end;

begin
  with FForm do
  begin
  TextColor := IfThen(CurrentTheme = tmLight, LightTextColor, DarkTextColor);
  FExtScrollBox := TScrollBox.Create(FForm);
  FExtScrollBox.Parent      := extrasTabSheet;
  FExtScrollBox.Align       := alClient;
  FExtScrollBox.AutoScroll  := False;
  FExtScrollBox.BorderStyle := bsNone;
  FExtScrollBox.HorzScrollBar.Visible := False;
  FExtScrollBox.HorzScrollBar.Range   := 0;
  FExtScrollBox.VertScrollBar.Visible := False;
  FExtScrollBox.VertScrollBar.Range   := 0;
  FExtScrollBox.Color       := RGBToColor(22, 26, 40);
  FExtScrollBox.ParentColor := False;
  ApplyModernScrollBarStylesheet(FExtScrollBox);
  FExtScrollBox.OnResize    := @ExtScrollBoxResize;

  FExtBgPanel := TPanel.Create(FForm);
  FExtBgPanel.Parent      := FExtScrollBox;
  FExtBgPanel.BevelOuter  := bvNone;
  FExtBgPanel.BorderStyle := bsNone;
  FExtBgPanel.Color       := RGBToColor(22, 26, 40);
  FExtBgPanel.OnPaint     := @FForm.PresetsWrapperPaint;
  FExtBgPanel.Caption     := '';

  // ── Card 1: System & Environment ───────────────────────────────────────
  MakeCard(FExtSysCard, FExtSysTitleLbl, 'System & Environment');
  FExtSysTitleLbl.ShowAccelChar := False;

  MakeSubSec(FExtPlatformSec, FExtSysCard);
  MakeSubSec(FExtWineSec, FExtSysCard);
  MakeSubSec(FExtGamingSec, FExtSysCard);
  MakeSubSec(FExtSessionSec, FExtSysCard);
  FForm.FExtPlatformSec := FExtPlatformSec;
  FForm.FExtWineSec := FExtWineSec;
  FForm.FExtGamingSec := FExtGamingSec;
  FForm.FExtSessionSec := FExtSessionSec;

  // Platform & Display
  systemLabel.Caption := 'Platform & Display';
  Place(systemLabel, FExtPlatformSec, 12, 8);
  systemLabel.ShowAccelChar := False;
  DarkLabel(systemLabel);
  FdistroinfoToggle    := PlaceExtToggle(distroinfoCheckBox,    FExtPlatformSec, 12,  34);
  FdisplayserverToggle := PlaceExtToggle(displayserverCheckBox, FExtPlatformSec, 160, 34);
  FarchToggle          := PlaceExtToggle(archCheckBox,          FExtPlatformSec, 12,  64);
  FresolutionToggle    := PlaceExtToggle(resolutionCheckBox,    FExtPlatformSec, 160, 64);
  FrefreshrateToggle   := PlaceExtToggle(refreshrateCheckBox,   FExtPlatformSec, 12,  94);
  FtimeToggle          := PlaceExtToggle(timeCheckBox,          FExtPlatformSec, 160, 94);
  FtimeToggle.OnChange := @TimeToggleChanged;

  FTimeConfigBtn := TBitBtn.Create(FExtPlatformSec);
  FTimeConfigBtn.Parent := FExtPlatformSec;
  FTimeConfigBtn.Caption := '⚙';
  FTimeConfigBtn.Font.Name := 'DejaVu Sans';
  FTimeConfigBtn.Font.Size := 9;
  FTimeConfigBtn.Cursor := crHandPoint;
  FTimeConfigBtn.SetBounds(FtimeToggle.Left + FtimeToggle.Width + 4, FtimeToggle.Top, 22, 20);
  FTimeConfigBtn.Hint := 'Configure time format';
  FTimeConfigBtn.ShowHint := True;
  FTimeConfigBtn.Enabled := timeCheckBox.Checked;
  FTimeConfigBtn.OnClick := @TimeConfigBtnClick;
  StyleBitBtnTheme(FTimeConfigBtn, TextColor, CARD_BG);

  // Wine & Compatibility
  wineLabel.Caption := 'Wine & Compatibility';
  Place(wineLabel, FExtWineSec, 12, 8);
  wineLabel.ShowAccelChar := False;
  DarkLabel(wineLabel);
  FwineToggle          := PlaceExtToggle(wineCheckBox,          FExtWineSec, 12,  34);
  FengineversionToggle := PlaceExtToggle(engineversionCheckBox, FExtWineSec, 160, 34);
  FengineshortToggle   := PlaceExtToggle(engineshortCheckBox,   FExtWineSec, 12,  64);
  FwinesyncToggle      := PlaceExtToggle(winesyncCheckBox,      FExtWineSec, 160, 64);
  FdxapiToggle         := PlaceExtToggle(dxapiCheckBox,         FExtWineSec, 12,  94);
  FfexstatsToggle      := PlaceExtToggle(fexstatsCheckBox,      FExtWineSec, 160, 94);
  Place(wineColorButton, FExtWineSec, 0, 34);
  wineColorButton.Color := CARD_BG;
  wineColorButton.ShowHint := True;
  wineColorButton.Hint := 'Wine label color';
  Place(engineColorButton, FExtWineSec, 0, 34);
  engineColorButton.Color := CARD_BG;
  engineColorButton.ShowHint := True;
  engineColorButton.Hint := 'Engine label color';

  // Gaming & Integrations
  optionsLabel.Caption := 'Gaming & Integrations';
  Place(optionsLabel, FExtGamingSec, 12, 8);
  optionsLabel.ShowAccelChar := False;
  DarkLabel(optionsLabel);
  FhudversionToggle     := PlaceExtToggle(hudversionCheckBox,     FExtGamingSec, 12,  34);
  FgamemodestatusToggle := PlaceExtToggle(gamemodestatusCheckBox, FExtGamingSec, 160, 34);
  FvkbasaltstatusToggle := PlaceExtToggle(vkbasaltstatusCheckBox, FExtGamingSec, 12,  64);
  FfcatToggle           := PlaceExtToggle(fcatCheckBox,           FExtGamingSec, 160, 64);
  FfsrToggle            := PlaceExtToggle(fsrCheckBox,            FExtGamingSec, 12,  94);
  FhdrToggle            := PlaceExtToggle(hdrCheckBox,            FExtGamingSec, 160, 94);

  // Hardware & Session
  batteryLabel.Caption := 'Hardware & Session';
  Place(batteryLabel, FExtSessionSec, 12, 8);
  batteryLabel.ShowAccelChar := False;
  DarkLabel(batteryLabel);
  batteryCheckBox.Caption     := 'Battery %';
  batterywattCheckBox.Caption := 'Battery Wattage';
  batterytimeCheckBox.Caption := 'Battery Time';
  deviceCheckBox.Caption      := 'Battery Devices';
  FbatteryToggle     := PlaceExtToggle(batteryCheckBox,     FExtSessionSec, 12,  30);
  FbatterywattToggle := PlaceExtToggle(batterywattCheckBox, FExtSessionSec, 12,  58);
  FbatterytimeToggle := PlaceExtToggle(batterytimeCheckBox, FExtSessionSec, 12,  86);
  FdeviceToggle      := PlaceExtToggle(deviceCheckBox,      FExtSessionSec, 12,  114);
  Place(batteryColorButton, FExtSessionSec, 0, 30);
  batteryColorButton.Color := CARD_BG;
  batteryColorButton.ShowHint := True;
  batteryColorButton.Hint := 'Battery label color';

  FmediaToggle := PlaceExtToggle(mediaCheckBox, FExtSessionSec, 160, 30);
  Place(mediaColorButton, FExtSessionSec, 0, 30);
  mediaColorButton.Color := CARD_BG;
  mediaColorButton.ShowHint := True;
  mediaColorButton.Hint := 'Media info color';

  FnetworkToggle := PlaceExtToggle(networkCheckBox, FExtSessionSec, 160, 58);
  FnetworkToggle.OnChange := @NetworkToggleChanged;
  Place(networkComboBox, FExtSessionSec, 0, 58);
  networkComboBox.Color      := OUTER_BG;
  networkComboBox.Font.Color := WHITE;
  networkComboBox.Enabled    := networkCheckBox.Checked;
  if networkComboBox.HandleAllocated then
  begin
    SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
    QWidget_setStyleSheet(TQtWidget(networkComboBox.Handle).Widget, @SS);
  end;

  fahrenheitCheckBox.Visible := False;
  FExtTempPillBtn := TBitBtn.Create(FExtSessionSec);
  FExtTempPillBtn.Parent := FExtSessionSec;
  FExtTempPillBtn.Cursor := crHandPoint;
  FExtTempPillBtn.OnClick := @ExtTempPillBtnClick;
  FForm.FExtTempPillBtn := FExtTempPillBtn;

  FExtTempUnitLbl := TLabel.Create(FExtSessionSec);
  FExtTempUnitLbl.Parent := FExtSessionSec;
  FExtTempUnitLbl.Caption := 'Temp unit:';
  FExtTempUnitLbl.ShowAccelChar := False;
  DarkLabel(FExtTempUnitLbl);

  FExtCustomCommandLbl := TLabel.Create(FExtSessionSec);
  FExtCustomCommandLbl.Parent := FExtSessionSec;
  FExtCustomCommandLbl.Caption := 'Custom text / exec:';
  FExtCustomCommandLbl.ShowAccelChar := False;
  DarkLabel(FExtCustomCommandLbl);
  customcommandEdit.Parent := FExtSessionSec;
  customcommandEdit.TextHint := 'custom_text=... or exec=...';
  customcommandEdit.Font.Name := 'DejaVu Sans Mono';

  othersLabel.Visible := False;

  // ── Card 2: Benchmarks & Logging ────────────────────────────────────────
  MakeCard(FExtLogCard, FExtLogTitleLbl, 'Benchmarks & Logging');
  FExtLogTitleLbl.ShowAccelChar := False;

  MakeSubSec(FExtLogTimingsSec, FExtLogCard);
  MakeSubSec(FExtLogToolsSec, FExtLogCard);
  FForm.FExtLogTimingsSec := FExtLogTimingsSec;
  FForm.FExtLogToolsSec := FExtLogToolsSec;

  // Session Timings
  logdurationLabel.Caption := 'Session Timings';
  Place(logdurationLabel, FExtLogTimingsSec, 12, 8);
  logdurationLabel.ShowAccelChar := False;
  DarkLabel(logdurationLabel);

  FExtLogDurationSubLbl := TLabel.Create(FExtLogTimingsSec);
  FExtLogDurationSubLbl.Parent := FExtLogTimingsSec;
  FExtLogDurationSubLbl.Caption := 'Duration (s)';
  FExtLogDurationSubLbl.ShowAccelChar := False;
  DarkLabel(FExtLogDurationSubLbl);
  FExtLogDelaySubLbl := TLabel.Create(FExtLogTimingsSec);
  FExtLogDelaySubLbl.Parent := FExtLogTimingsSec;
  FExtLogDelaySubLbl.Caption := 'Delay (s)';
  FExtLogDelaySubLbl.ShowAccelChar := False;
  DarkLabel(FExtLogDelaySubLbl);
  FExtLogIntervalSubLbl := TLabel.Create(FExtLogTimingsSec);
  FExtLogIntervalSubLbl.Parent := FExtLogTimingsSec;
  FExtLogIntervalSubLbl.Caption := 'Interval (ms)';
  FExtLogIntervalSubLbl.ShowAccelChar := False;
  DarkLabel(FExtLogIntervalSubLbl);

  Place(logdelayLabel, FExtLogTimingsSec, 12, 8);
  logdelayLabel.Visible := False;
  Place(logintervalLabel, FExtLogTimingsSec, 12, 8);
  logintervalLabel.Visible := False;

  Place(durationTrackBar,   FExtLogTimingsSec, 12, 40);
  Place(delayTrackBar,      FExtLogTimingsSec, 12, 40);
  Place(intervalTrackBar,   FExtLogTimingsSec, 12, 40);
  Place(durationvalueLabel, FExtLogTimingsSec, 12, 70);
  Place(delayvalueLabel,    FExtLogTimingsSec, 12, 70);
  Place(intervalvalueLabel, FExtLogTimingsSec, 12, 70);

  durationTrackBar.Orientation := trHorizontal;
  durationTrackBar.Reversed    := False;
  durationTrackBar.TickStyle   := tsNone;
  durationTrackBar.Height      := 24;

  delayTrackBar.Orientation    := trHorizontal;
  delayTrackBar.Reversed       := False;
  delayTrackBar.TickStyle      := tsNone;
  delayTrackBar.Height         := 24;

  intervalTrackBar.Orientation := trHorizontal;
  intervalTrackBar.Reversed    := False;
  intervalTrackBar.TickStyle   := tsNone;
  intervalTrackBar.Height      := 24;
  durationvalueLabel.Font.Color := CLR_TEXT_ACCENT; durationvalueLabel.Font.Style := [fsBold]; durationvalueLabel.Transparent := True;
  delayvalueLabel.Font.Color := CLR_TEXT_ACCENT; delayvalueLabel.Font.Style := [fsBold]; delayvalueLabel.Transparent := True;
  intervalvalueLabel.Font.Color := CLR_TEXT_ACCENT; intervalvalueLabel.Font.Style := [fsBold]; intervalvalueLabel.Transparent := True;

  // Storage & Tools
  logfolderLabel.Caption := 'Storage & Tools';
  Place(logfolderLabel, FExtLogToolsSec, 12, 8);
  logfolderLabel.ShowAccelChar := False;
  DarkLabel(logfolderLabel);
  Place(logfolderEdit, FExtLogToolsSec, 12, 34);
  logfolderEdit.Color      := OUTER_BG;
  logfolderEdit.Font.Color := WHITE;
  logfolderEdit.Font.Name  := 'DejaVu Sans Mono';
  if CurrentTheme = tmLight then
    SS := 'QLineEdit { background-color: rgb(245,245,245); color: rgb(0,0,0); border: 1px solid rgb(210,215,225); border-radius: 6px; padding: 2px 6px; }' +
          'QLineEdit:hover { border: 1px solid rgb(160,175,200); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,120,200); }'
  else
    SS := 'QLineEdit { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 6px; padding: 2px 6px; }' +
          'QLineEdit:hover { border: 1px solid rgb(80,110,170); }' +
          'QLineEdit:focus { border: 1px solid rgb(48,190,240); }';
  if logfolderEdit.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(logfolderEdit.Handle).Widget, @SS);
  Place(logfolderBitBtn, FExtLogToolsSec, 0, 34);
  StyleBitBtnTheme(logfolderBitBtn, TextColor, CARD_BG);

  Place(logtoggleLabel, FExtLogToolsSec, 12, 68);
  logtoggleLabel.Visible     := False;
  logtoggleLabel.Caption     := 'Logging toggle';
  logtoggleLabel.ShowAccelChar := False;
  logtoggleLabel.Font.Color  := IfThen(CurrentTheme = tmLight, LightTextColor, clWhite);
  logtoggleLabel.Font.Style  := [fsBold];
  logtoggleLabel.Transparent := True;

  Place(logtoggleComboBox, FExtLogToolsSec, 12, 90);
  logtoggleComboBox.Visible := False;

  FLoggingCaptureBtn := TBitBtn.Create(FExtLogToolsSec);
  FLoggingCaptureBtn.Parent  := FExtLogToolsSec;
  FLoggingCaptureBtn.Tag     := 3;
  FLoggingCaptureBtn.SetBounds(0, 0, 140, 28);
  FLoggingCaptureBtn.OnClick := @FForm.CaptureBtnClick;
  FLoggingCaptureBtn.Cursor  := crHandPoint;
  FLoggingCaptureBtn.Font.Color := WHITE;
  FLoggingCaptureBtn.Hint := 'Shortcut key to toggle benchmark logging';
  FLoggingCaptureBtn.ShowHint := True;
  if Trim(logtoggleComboBox.Text) <> '' then
    FLoggingCaptureBtn.Caption := '⌨ ' + logtoggleComboBox.Text
  else
    FLoggingCaptureBtn.Caption := '⌨ Capture';
  StyleBitBtnTheme(FLoggingCaptureBtn, TextColor, CARD_BG);

  FExtGplotLabel := TLabel.Create(FExtLogToolsSec);
  FExtGplotLabel.Parent      := FExtLogToolsSec;
  FExtGplotLabel.Visible     := False;
  FExtGplotLabel.Left        := 0;
  FExtGplotLabel.Top         := 0;
  FExtGplotLabel.Caption     := 'Benchmark viewer';
  FExtGplotLabel.ShowAccelChar := False;
  FExtGplotLabel.Font.Color  := IfThen(CurrentTheme = tmLight, LightTextColor, clWhite);
  FExtGplotLabel.Font.Style  := [fsBold];
  FExtGplotLabel.Transparent := True;

  FGplotBtn := TBitBtn.Create(FExtLogToolsSec);
  FGplotBtn.Parent      := FExtLogToolsSec;
  FGplotBtn.SetBounds(0, 0, 140, 28);
  FGplotBtn.Caption     := '📊 PasPlot Viewer';
  FGplotBtn.OnClick     := @FForm.GplotBtnClick;
  FGplotBtn.Cursor      := crHandPoint;
  FGplotBtn.Font.Color  := WHITE;
  FGplotBtn.Hint        := 'Open PasPlot Benchmark Viewer';
  FGplotBtn.ShowHint    := True;
  StyleBitBtnTheme(FGplotBtn, TextColor, CARD_BG);

  Place(autouploadCheckBox, FExtLogToolsSec, 0, 0); DarkCheck(autouploadCheckBox);
  autouploadCheckBox.Visible := False;
  Place(versioningCheckBox, FExtLogToolsSec, 0, 0); DarkCheck(versioningCheckBox);
  versioningCheckBox.Visible := False;
  end;

  // Apply the initial theme so the tab is styled from the first paint
  UpdateExtrasCardTheme;
end;

procedure TMangoHudUiHelper.ExtScrollBoxResize(Sender: TObject);
begin
  if Assigned(FForm.FExtScrollBox) then
    ReflowExtrasTab(FForm.FExtScrollBox.ClientWidth);
end;

procedure TMangoHudUiHelper.ReflowExtrasTab(AContentW: Integer);
const
  MARGIN  = 4;
  GAP     = 6;
  SEC_PAD = 8;
  SEC_GAP = 6;
  HDR     = 42;
  SEC_H1  = 125;
  SEC_H2  = 226;
var
  CW, TotalH, ActiveSysH, ActiveLogH, AvailH, SEC_LOG: Integer;
  SecW, Sec1Left, Sec2Left: Integer;
  Row1Top, Row2Top: Integer;
  Col1X, Col2X, R1Y, R2Y, R3Y, R4Y, BtnW: Integer;
  LblW, ValW, TrackW, RowGap, Row1Y, Row2Y, Row3Y, ActionY: Integer;
begin
  with FForm do
  begin
  if not Assigned(FExtScrollBox) then Exit;
  CW := AContentW - 2 * MARGIN;
  if CW < 100 then Exit;

  FExtScrollBox.HorzScrollBar.Range := 0;

  ActiveSysH := HDR + SEC_H1 + SEC_GAP + SEC_H2 + SEC_PAD;
  AvailH := FExtScrollBox.ClientHeight - 2 * MARGIN - GAP;
  if AvailH > ActiveSysH + 185 then
    ActiveLogH := AvailH - ActiveSysH
  else
    ActiveLogH := 185;

  TotalH := MARGIN + ActiveSysH + GAP + ActiveLogH + MARGIN;
  if FExtScrollBox.ClientHeight > TotalH then
    TotalH := FExtScrollBox.ClientHeight;
  FExtBgPanel.SetBounds(0, 0, AContentW, TotalH);

  FExtSysCard.SetBounds(MARGIN, MARGIN, CW, ActiveSysH);
  FExtLogCard.SetBounds(MARGIN, MARGIN + ActiveSysH + GAP, CW, ActiveLogH);

  if Assigned(FExtSysTitleLbl) then
  begin
    FExtSysTitleLbl.Left := 16;
    FExtSysTitleLbl.Top  := 10;
  end;
  if Assigned(FExtLogTitleLbl) then
  begin
    FExtLogTitleLbl.Left := 16;
    FExtLogTitleLbl.Top  := 10;
  end;

  SecW := (CW - 2 * SEC_PAD - SEC_GAP) div 2;
  Sec1Left := SEC_PAD;
  Sec2Left := SEC_PAD + SecW + SEC_GAP;
  Row1Top := HDR;
  Row2Top := HDR + SEC_H1 + SEC_GAP;

  // Position sub-cards in FExtSysCard
  if Assigned(FExtPlatformSec) then FExtPlatformSec.SetBounds(Sec1Left, Row1Top, SecW, SEC_H1);
  if Assigned(FExtWineSec)     then FExtWineSec.SetBounds(Sec2Left, Row1Top, SecW, SEC_H1);
  if Assigned(FExtGamingSec)   then FExtGamingSec.SetBounds(Sec1Left, Row2Top, SecW, SEC_H2);
  if Assigned(FExtSessionSec)  then FExtSessionSec.SetBounds(Sec2Left, Row2Top, SecW, SEC_H2);

  // Position sub-cards in FExtLogCard
  SEC_LOG := ActiveLogH - HDR - SEC_PAD;
  if Assigned(FExtLogTimingsSec) then FExtLogTimingsSec.SetBounds(Sec1Left, HDR, SecW, SEC_LOG);
  if Assigned(FExtLogToolsSec)   then FExtLogToolsSec.SetBounds(Sec2Left, HDR, SecW, SEC_LOG);

  Col1X := 12;
  Col2X := SecW div 2 + 6;
  R1Y   := 32;
  R2Y   := 60;
  R3Y   := 88;
  R4Y   := 114;

  // Inside FExtPlatformSec
  if Assigned(systemLabel) then systemLabel.SetBounds(12, 8, SecW - 24, 18);
  if Assigned(FdistroinfoToggle) then begin FdistroinfoToggle.Left := Col1X; FdistroinfoToggle.Top := R1Y; end;
  if Assigned(FresolutionToggle) then begin FresolutionToggle.Left := Col2X; FresolutionToggle.Top := R1Y; end;
  if Assigned(FdisplayserverToggle) then begin FdisplayserverToggle.Left := Col1X; FdisplayserverToggle.Top := R2Y; end;
  if Assigned(FrefreshrateToggle) then begin FrefreshrateToggle.Left := Col2X; FrefreshrateToggle.Top := R2Y; end;
  if Assigned(FarchToggle) then begin FarchToggle.Left := Col1X; FarchToggle.Top := R3Y; end;
  if Assigned(FtimeToggle) then
  begin
    FtimeToggle.Left := Col2X;
    FtimeToggle.Top  := R3Y;
    if Assigned(FTimeConfigBtn) then
      FTimeConfigBtn.SetBounds(FtimeToggle.Left + FtimeToggle.Width + 4, R3Y, 22, 20);
  end;

  // Inside FExtWineSec
  if Assigned(wineLabel) then wineLabel.SetBounds(12, 8, SecW - 24, 18);
  if Assigned(FwineToggle) then
  begin
    FwineToggle.Left := Col1X;
    FwineToggle.Top  := R1Y;
    wineColorButton.SetBounds(Col1X + FwineToggle.Width + 6, R1Y, 20, 20);
  end;
  if Assigned(FengineversionToggle) then
  begin
    FengineversionToggle.Left := Col2X;
    FengineversionToggle.Top  := R1Y;
    engineColorButton.SetBounds(Col2X + FengineversionToggle.Width + 6, R1Y, 20, 20);
  end;
  if Assigned(FengineshortToggle) then begin FengineshortToggle.Left := Col1X; FengineshortToggle.Top := R2Y; end;
  if Assigned(FwinesyncToggle) then begin FwinesyncToggle.Left := Col2X; FwinesyncToggle.Top := R2Y; end;
  if Assigned(FdxapiToggle) then begin FdxapiToggle.Left := Col1X; FdxapiToggle.Top := R3Y; end;
  if Assigned(FfexstatsToggle) then begin FfexstatsToggle.Left := Col2X; FfexstatsToggle.Top := R3Y; end;

  // Inside FExtGamingSec
  if Assigned(optionsLabel) then optionsLabel.SetBounds(12, 8, SecW - 24, 18);
  if Assigned(FhudversionToggle) then begin FhudversionToggle.Left := Col1X; FhudversionToggle.Top := R1Y; end;
  if Assigned(FfcatToggle) then begin FfcatToggle.Left := Col2X; FfcatToggle.Top := R1Y; end;
  if Assigned(FgamemodestatusToggle) then begin FgamemodestatusToggle.Left := Col1X; FgamemodestatusToggle.Top := R2Y; end;
  if Assigned(FfsrToggle) then begin FfsrToggle.Left := Col2X; FfsrToggle.Top := R2Y; end;
  if Assigned(FvkbasaltstatusToggle) then begin FvkbasaltstatusToggle.Left := Col1X; FvkbasaltstatusToggle.Top := R3Y; end;
  if Assigned(FhdrToggle) then begin FhdrToggle.Left := Col2X; FhdrToggle.Top := R3Y; end;

  // Inside FExtSessionSec
  if Assigned(batteryLabel) then batteryLabel.SetBounds(12, 8, SecW - 24, 18);
  // Col 1 (Battery):
  if Assigned(FbatteryToggle) then
  begin
    FbatteryToggle.Left := Col1X;
    FbatteryToggle.Top  := 30;
    batteryColorButton.SetBounds(Col1X + FbatteryToggle.Width + 6, 30, 20, 20);
  end;
  if Assigned(FbatterywattToggle) then begin FbatterywattToggle.Left := Col1X; FbatterywattToggle.Top := 58; end;
  if Assigned(FbatterytimeToggle) then begin FbatterytimeToggle.Left := Col1X; FbatterytimeToggle.Top := 86; end;
  if Assigned(FdeviceToggle)      then begin FdeviceToggle.Left := Col1X;      FdeviceToggle.Top := 114; end;

  // Col 2 (Media, Network, Temp Unit):
  if Assigned(FmediaToggle) then
  begin
    FmediaToggle.Left := Col2X;
    FmediaToggle.Top  := 30;
    mediaColorButton.SetBounds(Col2X + FmediaToggle.Width + 6, 30, 20, 20);
  end;
  if Assigned(FnetworkToggle) then
  begin
    FnetworkToggle.Left := Col2X;
    FnetworkToggle.Top  := 56;
  end;
  if Assigned(networkComboBox) then
  begin
    networkComboBox.SetBounds(Col2X, 80, SecW - Col2X - 12, 26);
  end;
  if Assigned(FExtTempUnitLbl) then
  begin
    FExtTempUnitLbl.SetBounds(Col2X, 122, 72, 18);
  end;
  if Assigned(FExtTempPillBtn) then
  begin
    FExtTempPillBtn.SetBounds(Col2X + 74, 120, FExtTempPillBtn.Width, 22);
  end;

  // Custom Command at bottom:
  if Assigned(FExtCustomCommandLbl) then
    FExtCustomCommandLbl.SetBounds(11, 158, SecW - 22, 18);
  customcommandEdit.SetBounds(11, 180, Max(120, SecW - 22), 24);

  // Inside FExtLogTimingsSec
  if Assigned(logdurationLabel) then logdurationLabel.SetBounds(12, 8, SecW - 24, 18);
  RowGap := EnsureRange((SEC_LOG - 34) div 3, 30, 42);
  Row1Y := 34;
  Row2Y := Row1Y + RowGap;
  Row3Y := Row2Y + RowGap;

  LblW := 95;
  ValW := 52;
  TrackW := Max(100, SecW - 14 - LblW - ValW - 14);

  if Assigned(FExtLogDurationSubLbl) then
  begin
    FExtLogDurationSubLbl.Visible := True;
    FExtLogDurationSubLbl.SetBounds(14, Row1Y + 4, LblW, 18);
  end;
  durationTrackBar.SetBounds(14 + LblW, Row1Y, TrackW, 26);
  durationvalueLabel.SetBounds(14 + LblW + TrackW + 6, Row1Y + 4, ValW, 18);

  if Assigned(FExtLogDelaySubLbl) then
  begin
    FExtLogDelaySubLbl.Visible := True;
    FExtLogDelaySubLbl.SetBounds(14, Row2Y + 4, LblW, 18);
  end;
  delayTrackBar.SetBounds(14 + LblW, Row2Y, TrackW, 26);
  delayvalueLabel.SetBounds(14 + LblW + TrackW + 6, Row2Y + 4, ValW, 18);

  if Assigned(FExtLogIntervalSubLbl) then
  begin
    FExtLogIntervalSubLbl.Visible := True;
    FExtLogIntervalSubLbl.SetBounds(14, Row3Y + 4, LblW, 18);
  end;
  intervalTrackBar.SetBounds(14 + LblW, Row3Y, TrackW, 26);
  intervalvalueLabel.SetBounds(14 + LblW + TrackW + 6, Row3Y + 4, ValW, 18);

  // Inside FExtLogToolsSec
  if Assigned(logfolderLabel) then logfolderLabel.SetBounds(12, 8, SecW - 24, 18);
  logfolderEdit.SetBounds(12, Row1Y, SecW - 56, 26);
  logfolderBitBtn.SetBounds(SecW - 40, Row1Y, 28, 26);

  LblW := 125;

  logtoggleLabel.SetBounds(12, Row2Y + 5, LblW, 18);
  logtoggleLabel.Visible := False;
  if Assigned(FExtGplotLabel) then
  begin
    FExtGplotLabel.SetBounds(12, Row3Y + 5, LblW, 18);
    FExtGplotLabel.Visible := False;
  end;

  BtnW := (SecW - 24 - 8) div 2;
  if Assigned(FLoggingCaptureBtn) then
    FLoggingCaptureBtn.SetBounds(12, Row2Y, BtnW, 28);
  if Assigned(FGplotBtn) then
    FGplotBtn.SetBounds(12 + BtnW + 8, Row2Y, BtnW, 28);

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
  if Assigned(FTimeConfigBtn) and Assigned(FForm.timeCheckBox) then
    FTimeConfigBtn.Enabled := FForm.timeCheckBox.Checked;
  if Assigned(FForm.networkComboBox) and Assigned(FForm.networkCheckBox) then
    FForm.networkComboBox.Enabled := FForm.networkCheckBox.Checked;
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
  SS: String;
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
  UpdateGenericCardTheme(FExtPlatformSec);
  UpdateGenericCardTheme(FExtWineSec);
  UpdateGenericCardTheme(FExtGamingSec);
  UpdateGenericCardTheme(FExtSessionSec);
  UpdateGenericCardTheme(FExtLogTimingsSec);
  UpdateGenericCardTheme(FExtLogToolsSec);
  RefreshFormatPills;

  if Assigned(FTimeConfigBtn) then
    StyleBitBtnTheme(FTimeConfigBtn, TextColor, CardBg);

  if Assigned(logtoggleLabel) then
    logtoggleLabel.Font.Color := TextColor;
  if Assigned(FExtGplotLabel) then
    FExtGplotLabel.Font.Color := TextColor;

  if Assigned(FLoggingCaptureBtn) then
    StyleBitBtnTheme(FLoggingCaptureBtn, TextColor, CardBg);
  if Assigned(FGplotBtn) then
    StyleBitBtnTheme(FGplotBtn, TextColor, CardBg);
  if Assigned(logfolderBitBtn) then
    StyleBitBtnTheme(logfolderBitBtn, TextColor, CardBg);
    
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
    if networkComboBox.HandleAllocated then
    begin
      SS := GetComboBoxStyleSheet(CurrentTheme = tmDark);
      QWidget_setStyleSheet(TQtWidget(networkComboBox.Handle).Widget, @SS);
    end;
  end;
  end;
end;

function HexToColor(const HexValue: string): TColor;
var
  CleanHex: string;
  R, G, B: Integer;
begin
  CleanHex := Trim(HexValue);
  if (CleanHex <> '') and (CleanHex[1] = '#') then
    CleanHex := Copy(CleanHex, 2, Length(CleanHex));
  CleanHex := Trim(CleanHex);

  if Length(CleanHex) = 3 then
    CleanHex := CleanHex[1] + CleanHex[1] + CleanHex[2] + CleanHex[2] + CleanHex[3] + CleanHex[3];

  if (Length(CleanHex) >= 6) and
     TryStrToInt('$' + Copy(CleanHex, 1, 2), R) and
     TryStrToInt('$' + Copy(CleanHex, 3, 2), G) and
     TryStrToInt('$' + Copy(CleanHex, 5, 2), B) then
  begin
    Result := RGBToColor(R, G, B);
  end
  else
    Result := clWhite;
end;

procedure TMangoHudUiHelper.ResetMetricGraphs;
begin
  if Assigned(FgpuavgloadToggle) then FgpuavgloadToggle.GraphActive := False;
  if Assigned(FvramusageToggle) then FvramusageToggle.GraphActive := False;
  if Assigned(FgpufreqToggle) then FgpufreqToggle.GraphActive := False;
  if Assigned(FgpumemfreqToggle) then FgpumemfreqToggle.GraphActive := False;
  if Assigned(FgputempToggle) then FgputempToggle.GraphActive := False;
  if Assigned(FcpuavgloadToggle) then FcpuavgloadToggle.GraphActive := False;
  if Assigned(FcputempToggle) then FcputempToggle.GraphActive := False;
  if Assigned(FramusageToggle) then FramusageToggle.GraphActive := False;
end;

procedure TMangoHudUiHelper.ResetMangoHudControls;
var
  i: Integer;
  ParentControl: TWinControl;
  WasLoading: Boolean;
  TextColor, CardBg: TColor;
begin
  WasLoading := FForm.FLoadingConfig;
  FForm.FLoadingConfig := True;
  try
    // Reset fps_only state — will be re-set by LoadMangoHudBoolFlag if present
    FFpsOnly := False;
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
    ResetMetricGraphs;

    // 2. Reset other specific MangoHud controls
    hudtitleEdit.Text := '';
    gpunameEdit.Text := '';
    cpunameEdit.Text := '';
    logfolderEdit.Text := FForm.GetGameLogDir(FForm.FActiveGameName);
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
    FTimeFormat := '%T';
    if Assigned(FTimeConfigBtn) and Assigned(timeCheckBox) then
      FTimeConfigBtn.Enabled := timeCheckBox.Checked;

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
    fontsizevalueLabel.Caption := '24px';

    if Assigned(FroundradiusTrackBar) then
    begin
      FroundradiusTrackBar.Position := 10;
      if Assigned(FroundradiusvalueLabel) then
        FroundradiusvalueLabel.Caption := '10px';
    end;
    if Assigned(FhudnomarginToggle) then
      FhudnomarginToggle.Checked := False;
    
    afTrackBar.Position := 0;
    afvalueLabel.Caption := '0 (Off)';
    
    mipmapTrackBar.Position := 0;
    mipmapvalueLabel.Caption := IntToStr(mipmapTrackBar.Position);
    
    durationTrackBar.Position := 0;
    durationvalueLabel.Caption := '0s';
    
    delayTrackBar.Position := 0;
    delayvalueLabel.Caption := '0s';
    
    intervalTrackBar.Position := 100;
    intervalvalueLabel.Caption := '100ms';

    COLUMNS := 3;
    columvalueLabel.Caption := '3';
    UpdateColumnsIndicator;

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

    gpuload1ColorButton.ButtonColor := COLOR_LOAD_LOW;
    gpuload2ColorButton.ButtonColor := COLOR_LOAD_MED;
    gpuload3ColorButton.ButtonColor := COLOR_LOAD_HIGH;
    cpuload1ColorButton.ButtonColor := COLOR_LOAD_LOW;
    cpuload2ColorButton.ButtonColor := COLOR_LOAD_MED;
    cpuload3ColorButton.ButtonColor := COLOR_LOAD_HIGH;

    // BitBtns
    frametimetypeBitBtn.ImageIndex := 8;
    coreloadtypeBitBtn.ImageIndex := 6;
    coreloadtypeBitBtn.Hint    := 'Core load format: Percentage (%) · Click to switch to vertical bars (Bars)';
    gpuframesjouleBitBtn.Tag := 0;
    cpuframesjouleBitBtn.Tag := 0;
    gpuframesjouleBitBtn.Hint    := 'Efficiency format: Frames per Joule (F/J) · Click to switch to Joules per Frame (J/F)';
    cpuframesjouleBitBtn.Hint    := 'Efficiency format: Frames per Joule (F/J) · Click to switch to Joules per Frame (J/F)';
    fpsavgBitBtn.ImageIndex := 9;

    // Re-style after caption/icon changes so the palette text colour sticks
    // on icon-bearing TBitBtns (see StyleBitBtnTheme).
    TextColor := IfThen(CurrentTheme = tmLight, LightTextColor, DarkTextColor);
    CardBg := IfThen(CurrentTheme = tmLight, $00F0F0F0, $002E1E1A);
    RefreshFormatPills;

    // RadioGroups
    filterRadioGroup.ItemIndex := 0;

    // SpinEdits
    offsetxSpinEdit.Value := 0;
    offsetySpinEdit.Value := 0;

    SyncAllToggles;
    UpdateMonitorVisuals;
    end;
  finally
    FForm.FLoadingConfig := WasLoading;
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

        // Ignore comments
        if TrimmedLine[1] = '#' then
          Continue;

        ColonPos := Pos('=', TrimmedLine);

        // Keys without value (boolean flags)
        if ColonPos = 0 then
        begin
          try
            LoadMangoHudBoolFlag(TrimmedLine);
          except
            on E: Exception do
              WriteLn('[MANGOHUD] Warning parsing flag "', TrimmedLine, '": ', E.Message);
          end;
          Continue;
        end;

        // Keys with value
        Key := Trim(Copy(TrimmedLine, 1, ColonPos - 1));
        Value := Trim(Copy(TrimmedLine, ColonPos + 1, Length(TrimmedLine)));

        // Remove quotes if present
        if (Length(Value) > 0) and (Value[1] = '"') then
          Value := StringReplace(Value, '"', '', [rfReplaceAll]);

        try
          LoadMangoHudKeyValue(Key, Value);
        except
          on E: Exception do
            WriteLn('[MANGOHUD] Warning parsing key "', Key, '": ', E.Message);
        end;
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
    RefreshFormatPills;
    UpdateMonitorVisuals;
  finally
    FForm.FLoadingConfig := False;
  end;
end;

procedure TMangoHudUiHelper.LoadMangoHudBoolFlag(const ATrimmedLine: string);
var
  TextColor, CardBg: TColor;
begin
  TextColor := IfThen(CurrentTheme = tmLight, LightTextColor, DarkTextColor);
  CardBg := IfThen(CurrentTheme = tmLight, $00F0F0F0, $002E1E1A);
  with FForm do
  begin
    if SameText(ATrimmedLine, MANGO_FLAG_HORIZONTAL) then
      horizontalRadioButton.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_NO_DISPLAY) then
      hidehudCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_HUD_COMPACT) then
      hudcompactCheckBox.Checked := True
    else if SameText(ATrimmedLine, MANGO_FLAG_HUD_NO_MARGIN) then
    begin
      if Assigned(FhudnomarginToggle) then
        FhudnomarginToggle.Checked := True;
    end
    else if SameText(ATrimmedLine, MANGO_FLAG_TEXT_OUTLINE) then
    begin
      if Assigned(textoutlineCheckBox) then
        textoutlineCheckBox.Checked := True;
    end
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
      gpuframesjouleBitBtn.Hint    := 'Efficiency format: Joules per Frame (J/F) · Click to switch to Frames per Joule (F/J)';
      cpuframesjouleBitBtn.Hint    := 'Efficiency format: Joules per Frame (J/F) · Click to switch to Frames per Joule (F/J)';
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
      coreloadtypeBitBtn.Hint       := 'Core load format: Vertical bars (Bars) · Click to switch to percentage (%)';
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
    else if SameText(ATrimmedLine, MANGO_FLAG_DX_API) then
      dxapiCheckBox.Checked := True
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
      hudversionCheckBox.Checked := True
    else if SameText(ATrimmedLine, 'fps_only') then
      // fps_only is a MangoHud preset token with no direct checkbox counterpart.
      // Record the state so SaveMangoHudConfig can write it back verbatim
      // instead of overwriting it with a full config built from (empty) UI state.
      FFpsOnly := True;
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
        begin
          squareRadioButton.Checked := True;
          roundRadioButton.Checked := False;
        end
        else
        begin
          roundRadioButton.Checked := True;
          squareRadioButton.Checked := False;
        end;
        if Assigned(FroundradiusTrackBar) then
          FroundradiusTrackBar.Position := IntValue;
      end;
    end
    else if SameText(AKey, MANGO_KEY_BG_COLOR) then
      hudbackgroundColorButton.ButtonColor := HexToColor(AValue)
    else if SameText(AKey, MANGO_KEY_FONT_SIZE) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        fontsizeTrackBar.Position := IntValue;
        fontsizevalueLabel.Caption := IntToStr(IntValue) + 'px';
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
        COLUMNS := IntValue;
        columvalueLabel.Caption := AValue;
        UpdateColumnsIndicator;
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
        if afTrackBar.Position = 0 then
          afvalueLabel.Caption := '0 (Off)'
        else
          afvalueLabel.Caption := IntToStr(afTrackBar.Position) + 'x';
      end;
    end
    else if SameText(AKey, MANGO_KEY_PICMIP) then
    begin
      if TryStrToInt(AValue, IntValue) then
      begin
        mipmapTrackBar.Position := IntValue;
        mipmapvalueLabel.Caption := IntToStr(mipmapTrackBar.Position);
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
    begin
      if (AValue = '') or
         SameText(ExcludeTrailingPathDelimiter(AValue),
                  ExcludeTrailingPathDelimiter(GetGOverlayDataDir())) or
         ((FForm.FActiveGameName <> '') and
          ((SameText(ExcludeTrailingPathDelimiter(AValue),
                     ExcludeTrailingPathDelimiter(FForm.GetGameLogDir('')))) or
           (SameText(ExcludeTrailingPathDelimiter(AValue),
                     ExcludeTrailingPathDelimiter(GetGOverlayDataDir()) + '/logs/global')))) then
        logfolderEdit.Text := FForm.GetGameLogDir(FForm.FActiveGameName)
      else
        logfolderEdit.Text := AValue;
      if (logfolderEdit.Text <> '') and not DirectoryExists(logfolderEdit.Text) then
        try ForceDirectories(logfolderEdit.Text); except end;
    end
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
      end
      else if Pos(MANGO_FPS_METRICS_01PCT, AValue) > 0 then
      begin
        fpsavgCheckBox.Checked := True;
        fpsavgBitBtn.ImageIndex := 10;
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
    else if SameText(AKey, MANGO_KEY_TIME_FORMAT) then
    begin
      if AValue <> '' then
        FTimeFormat := AValue;
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
begin
  if MANGOHUDCFGFILE = '' then Exit;

  with FForm do
  begin
    // Initialize TMangoHudSettings record
    FillChar(Settings, SizeOf(Settings), 0);
    Settings.MangoHudCfgFile := MANGOHUDCFGFILE;
    Settings.Version := GVERSION;
    Settings.Channel := GCHANNEL;
    Settings.ActiveGameName := FActiveGameName;
    // Propagate fps_only preset state — when True, SaveMangoHudConfigCore writes
    // only the fps_only token and skips the full config generation below.
    Settings.FpsOnly := FFpsOnly;

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
    Settings.HudNoMargin := Assigned(FhudnomarginToggle) and FhudnomarginToggle.Checked;
    if Assigned(FroundradiusTrackBar) then
      Settings.RoundCornerRadius := FroundradiusTrackBar.Position;
    Settings.HorizontalStretch := horizontalstrechCheckBox.Checked;
    if Assigned(textoutlineCheckBox) then
      Settings.TextOutline := textoutlineCheckBox.Checked
    else
      Settings.TextOutline := False;

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
    Settings.DxApi := dxapiCheckBox.Checked;

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
    Settings.TimeFormat := FTimeFormat;
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