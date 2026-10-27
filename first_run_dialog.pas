unit first_run_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls,
  Buttons, configmanager;

type
  { TFirstRunSetupDialog }
  TFirstRunSetupDialog = class(TForm)
  private
    FIsFirstRun: Boolean;

    // Header
    FHeaderPanel: TPanel;
    FTitleLabel: TLabel;
    FSubtitleLabel: TLabel;

    // Scroll container
    FContentBox: TScrollBox;

    // Individual checkboxes
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
    FMinimalBtn: TBitBtn;
    FSelectAllBtn: TBitBtn;
    FConfirmBtn: TBitBtn;

    procedure BuildUI;
    procedure CardPaint(Sender: TObject);
    procedure CardClick(Sender: TObject);
    procedure MinimalBtnClick(Sender: TObject);
    procedure SelectAllBtnClick(Sender: TObject);
    procedure ConfirmBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    constructor Create(AOwner: TComponent; AIsFirstRun: Boolean = True); reintroduce;
    destructor Destroy; override;

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

    property MinimalBtn: TBitBtn read FMinimalBtn;
    property SelectAllBtn: TBitBtn read FSelectAllBtn;
    property ConfirmBtn: TBitBtn read FConfirmBtn;
  end;

function ShowFirstRunSetupDialog(AOwner: TComponent; AIsFirstRun: Boolean = True): Boolean;

implementation

uses
  optiscaler_update;

const
  CLR_BG_DARK   = $00281A16; // RGB(22, 26, 40)
  CLR_CARD_BG   = $003C281F; // RGB(31, 40, 60)
  CLR_BORDER    = $005A3C2D; // RGB(45, 60, 90)
  CLR_TEXT_MAIN = $00F0F0F0; // RGB(240, 240, 240)
  CLR_TEXT_DIM  = $00C0A890; // RGB(144, 168, 192)
  CLR_ACCENT    = $00F0BE30; // RGB(48, 190, 240)

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
end;

destructor TFirstRunSetupDialog.Destroy;
begin
  inherited Destroy;
end;

procedure TFirstRunSetupDialog.CardPaint(Sender: TObject);
var
  P: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  P.Canvas.Brush.Color := P.Color;
  P.Canvas.Pen.Color := CLR_BORDER;
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(0, 0, P.Width - 1, P.Height - 1, 8, 8);
end;

procedure TFirstRunSetupDialog.CardClick(Sender: TObject);
var
  P: TPanel;
  i: Integer;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  for i := 0 to P.ControlCount - 1 do
  begin
    if (P.Controls[i] is TCheckBox) and P.Controls[i].Enabled then
    begin
      TCheckBox(P.Controls[i]).Checked := not TCheckBox(P.Controls[i]).Checked;
      Break;
    end;
  end;
end;

procedure TFirstRunSetupDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 27 then // Escape
    Close;
end;

procedure TFirstRunSetupDialog.MinimalBtnClick(Sender: TObject);
begin
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
  ModalResult := mrOk;
end;

procedure TFirstRunSetupDialog.SelectAllBtnClick(Sender: TObject);
begin
  if Assigned(FVkBasaltCheck) then FVkBasaltCheck.Checked := True;
  if Assigned(FReShadeCheck) then FReShadeCheck.Checked := True;
  if Assigned(FVkSumiCheck) then FVkSumiCheck.Checked := True;
  if Assigned(FOptiScalerCheck) then FOptiScalerCheck.Checked := True;
  if Assigned(FDlssEnablerCheck) then FDlssEnablerCheck.Checked := True;
  if Assigned(FHelixSRCheck) then FHelixSRCheck.Checked := True;
  if Assigned(FLsfgVkCheck) then FLsfgVkCheck.Checked := True;
  if Assigned(FMakoCheck) then FMakoCheck.Checked := True;
  if Assigned(FAfmfCheck) then FAfmfCheck.Checked := True;
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
  CardTop: Integer;

  procedure CreateCategoryHeader(const ATitle: string);
  var
    Hdr: TLabel;
  begin
    Hdr := TLabel.Create(Self);
    Hdr.Parent := FContentBox;
    Hdr.SetBounds(18, CardTop, 580, 18);
    Hdr.Caption := ATitle;
    Hdr.Font.Name := 'Noto Sans';
    Hdr.Font.Size := 8;
    Hdr.Font.Style := [fsBold];
    Hdr.Font.Color := CLR_ACCENT;
    Hdr.ShowAccelChar := False;
    Inc(CardTop, 24);
  end;

  function CreateLibraryCard(const ATitle, ADesc: string;
    out ACheck: TCheckBox; AIsLocked: Boolean = False;
    AInitialState: Boolean = False): TPanel;
  var
    P: TPanel;
    DescLbl: TLabel;
  begin
    P := TPanel.Create(Self);
    P.Parent := FContentBox;
    P.SetBounds(16, CardTop, 580, 56);
    P.Color := CLR_CARD_BG;
    P.ParentColor := False;
    P.BevelOuter := bvNone;
    P.BorderStyle := bsNone;
    P.Cursor := crHandPoint;
    P.OnPaint := @CardPaint;
    if not AIsLocked then
      P.OnClick := @CardClick;

    ACheck := TCheckBox.Create(Self);
    ACheck.Parent := P;
    ACheck.SetBounds(14, 8, 552, 22);
    ACheck.Caption := ATitle;
    ACheck.Font.Name := 'Noto Sans';
    ACheck.Font.Size := 9;
    ACheck.Font.Style := [fsBold];
    ACheck.Font.Color := CLR_TEXT_MAIN;
    ACheck.Checked := AInitialState;
    if AIsLocked then
    begin
      ACheck.Checked := True;
      ACheck.Enabled := False;
    end;

    DescLbl := TLabel.Create(Self);
    DescLbl.Parent := P;
    DescLbl.SetBounds(34, 30, 532, 20);
    DescLbl.Caption := ADesc;
    DescLbl.Font.Name := 'Noto Sans';
    DescLbl.Font.Size := 8;
    DescLbl.Font.Color := CLR_TEXT_DIM;
    DescLbl.ShowAccelChar := False;
    if not AIsLocked then
      DescLbl.OnClick := @CardClick;

    Inc(CardTop, 62);
    Result := P;
  end;

begin
  Caption := 'Goverlay - Component Setup';
  Position := poScreenCenter;
  Width := 640;
  Height := 660;
  Color := CLR_BG_DARK;
  BorderStyle := bsDialog;
  KeyPreview := True;
  OnKeyDown := @FormKeyDown;

  // Header Panel
  FHeaderPanel := TPanel.Create(Self);
  FHeaderPanel.Parent := Self;
  FHeaderPanel.Align := alTop;
  FHeaderPanel.Height := 80;
  FHeaderPanel.BevelOuter := bvNone;
  FHeaderPanel.Color := CLR_BG_DARK;
  FHeaderPanel.ParentColor := False;

  FTitleLabel := TLabel.Create(Self);
  FTitleLabel.Parent := FHeaderPanel;
  FTitleLabel.SetBounds(20, 16, 600, 26);
  if FIsFirstRun then
    FTitleLabel.Caption := 'Welcome to Goverlay! Choose Your Setup'
  else
    FTitleLabel.Caption := 'Manage Integrations and Modules';
  FTitleLabel.Font.Name := 'Noto Sans';
  FTitleLabel.Font.Size := 13;
  FTitleLabel.Font.Style := [fsBold];
  FTitleLabel.Font.Color := CLR_ACCENT;
  FTitleLabel.ShowAccelChar := False;

  FSubtitleLabel := TLabel.Create(Self);
  FSubtitleLabel.Parent := FHeaderPanel;
  FSubtitleLabel.SetBounds(20, 44, 600, 32);
  FSubtitleLabel.Caption :=
    'Select which libraries and features you want to activate. Goverlay will only download and verify runtimes for selected libraries.';
  FSubtitleLabel.Font.Name := 'Noto Sans';
  FSubtitleLabel.Font.Size := 9;
  FSubtitleLabel.Font.Color := CLR_TEXT_DIM;
  FSubtitleLabel.WordWrap := True;
  FSubtitleLabel.ShowAccelChar := False;

  // Content scrollbox
  FContentBox := TScrollBox.Create(Self);
  FContentBox.Parent := Self;
  FContentBox.Align := alClient;
  FContentBox.BorderStyle := bsNone;
  FContentBox.Color := CLR_BG_DARK;
  FContentBox.ParentColor := False;
  FContentBox.HorzScrollBar.Visible := False;
  FContentBox.VertScrollBar.Tracking := True;

  CardTop := 8;

  // Category 1: Overlay & Telemetry
  CreateCategoryHeader('OVERLAY AND TELEMETRY (CORE)');
  CreateLibraryCard('MangoHud [Core]',
    'Real-time overlay for FPS, frametimes, GPU/CPU telemetry, VRAM, and power metrics.',
    FMangoCheck, True, True);
  Inc(CardTop, 6);

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
  Inc(CardTop, 6);

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
  Inc(CardTop, 6);

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

  // Bottom Panel
  FBottomPanel := TPanel.Create(Self);
  FBottomPanel.Parent := Self;
  FBottomPanel.Align := alBottom;
  FBottomPanel.Height := 65;
  FBottomPanel.BevelOuter := bvNone;
  FBottomPanel.Color := CLR_BG_DARK;
  FBottomPanel.ParentColor := False;

  FMinimalBtn := TBitBtn.Create(Self);
  FMinimalBtn.Parent := FBottomPanel;
  FMinimalBtn.SetBounds(20, 14, 175, 36);
  FMinimalBtn.Caption := 'Keep MangoHud Only';
  FMinimalBtn.Font.Name := 'Noto Sans';
  FMinimalBtn.Font.Size := 9;
  FMinimalBtn.OnClick := @MinimalBtnClick;

  FSelectAllBtn := TBitBtn.Create(Self);
  FSelectAllBtn.Parent := FBottomPanel;
  FSelectAllBtn.SetBounds(205, 14, 110, 36);
  FSelectAllBtn.Caption := 'Select All';
  FSelectAllBtn.Font.Name := 'Noto Sans';
  FSelectAllBtn.Font.Size := 9;
  FSelectAllBtn.OnClick := @SelectAllBtnClick;

  FConfirmBtn := TBitBtn.Create(Self);
  FConfirmBtn.Parent := FBottomPanel;
  FConfirmBtn.SetBounds(430, 14, 185, 36);
  if FIsFirstRun then
    FConfirmBtn.Caption := 'Confirm and Continue'
  else
    FConfirmBtn.Caption := 'Save and Apply';
  FConfirmBtn.Font.Name := 'Noto Sans';
  FConfirmBtn.Font.Size := 9;
  FConfirmBtn.Font.Style := [fsBold];
  FConfirmBtn.OnClick := @ConfirmBtnClick;
end;

end.
