unit lossless_scaling_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls,
  Clipbrd, IniFiles, Math, themeunit, constants, hintsunit, apputils, configkeys, configmanager, systemdetector, toggle_switch;

type
  { TLosslessScalingTabHelper }

  TLosslessScalingTabHelper = class
  private
    FForm: TForm;
    FLsScrollBox: TScrollBox;
    FLsBgPanel: TPanel;
    
    // Cards
    FLsGeneralCard: TPanel;
    FLsFrameGenCard: TPanel;
    
    // Card 0: LossLess Scaling
    FLsDllTitleLbl: TLabel;
    FLsLogoImage: TImage;
    FLsDllPathEdit: TEdit;
    FLsBrowseDllBtn: TBitBtn;
    FLsDllStatusLabel: TLabel;
    
    // Card 1: Configuration (consolidated)
    FLsFgTitleLbl: TLabel;
    FLsMultiplierTitleLbl: TLabel;
    FLsMultiplierTrackBar: TTrackBar;
    FLsMultiplierValueLabel: TLabel;
    
    FLsFlowScaleTitleLbl: TLabel;
    FLsFlowScaleTrackBar: TTrackBar;
    FLsFlowScaleValueLabel: TLabel;
    
    FLsPerfModeCheckBox: TCheckBox;
    FLsHdrModeCheckBox: TCheckBox;
    FLsNoFp16CheckBox: TCheckBox;
    FLsPerfModeToggle: TToggleSwitch;
    FLsHdrModeToggle: TToggleSwitch;
    FLsNoFp16Toggle: TToggleSwitch;
    
    FLsPacingTitleLbl: TLabel;
    FLsPacingComboBox: TComboBox;
    
    FLsGpuTitleLbl: TLabel;
    FLsGpuComboBox: TComboBox;
    
    procedure DllPathChange(Sender: TObject);
    procedure BrowseDllClick(Sender: TObject);
    procedure MultiplierChange(Sender: TObject);
    procedure FlowScaleChange(Sender: TObject);
    procedure ControlStateChange(Sender: TObject);
    procedure LsScrollBoxResize(Sender: TObject);
    
    procedure UpdateDllStatus;
    procedure PopulateGpuList;
    function GetConfigFile: string;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    
    procedure InitLosslessScalingTab;
    procedure ReflowLosslessScalingTab(AContentW: Integer);
    procedure ApplyThemeStyles;
    procedure UpdateControlsEnabled;
    procedure LoadLosslessConfig;
    procedure SaveLosslessConfig;
    function GetActiveEnvVars: string;
    function BuildEnvLine: string;
    function WriteLsfgTomlConfig(const ATargetDir: string = ''): string;
    function WriteDefaultLsfgToml(const ATargetDir: string = ''): string;
    function DetectSteamLosslessDll: string;
    
    property LogoImage: TImage read FLsLogoImage;
    property DllPathEdit: TEdit read FLsDllPathEdit;
    property DllStatusLabel: TLabel read FLsDllStatusLabel;
    property MultiplierTrackBar: TTrackBar read FLsMultiplierTrackBar;
    property MultiplierValueLabel: TLabel read FLsMultiplierValueLabel;
    property FlowScaleTrackBar: TTrackBar read FLsFlowScaleTrackBar;
    property FlowScaleValueLabel: TLabel read FLsFlowScaleValueLabel;
    property PerfModeCheckBox: TCheckBox read FLsPerfModeCheckBox;
    property HdrModeCheckBox: TCheckBox read FLsHdrModeCheckBox;
    property NoFp16CheckBox: TCheckBox read FLsNoFp16CheckBox;
    property PerfModeToggle: TToggleSwitch read FLsPerfModeToggle;
    property HdrModeToggle: TToggleSwitch read FLsHdrModeToggle;
    property NoFp16Toggle: TToggleSwitch read FLsNoFp16Toggle;
    property PacingComboBox: TComboBox read FLsPacingComboBox;
    property GpuComboBox: TComboBox read FLsGpuComboBox;
  end;

implementation

uses
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets,
  overlayunit,
  overlay_config;

const
  MARGIN   = 4;   // outer margin inside scroll box (standard across all tabs)
  GAP      = 6;   // gap between cards
  PAD      = 14;  // inner horizontal padding inside cards
  ROW_H    = 28;  // control row height

constructor TLosslessScalingTabHelper.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
end;

destructor TLosslessScalingTabHelper.Destroy;
begin
  inherited Destroy;
end;

function TLosslessScalingTabHelper.GetConfigFile: string;
var
  GameName: string;
begin
  GameName := '';
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    GameName := Tgoverlayform(FForm).FActiveGameName;
  Result := GetGameConfigDir(GameName) + 'bgmod.conf';
end;

function TLosslessScalingTabHelper.DetectSteamLosslessDll: string;
const
  RelDll = 'common/Lossless Scaling/Lossless.dll';
var
  Libs: TStringList;
  i: Integer;
  Candidate: string;
begin
  Result := '';
  Libs := TStringList.Create;
  try
    Tgoverlayform(FForm).GetSteamLibraries(Libs);
    for i := 0 to Libs.Count - 1 do
    begin
      Candidate := IncludeTrailingPathDelimiter(Libs[i]) + RelDll;
      if FileExists(Candidate) then
      begin
        Result := Candidate;
        Exit;
      end;
    end;
  finally
    Libs.Free;
  end;
  
  // Direct fallback checks
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/Steam/steamapps/' + RelDll;
  if FileExists(Candidate) then Exit(Candidate);
  
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.steam/steam/steamapps/' + RelDll;
  if FileExists(Candidate) then Exit(Candidate);
  
  Candidate := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/' + RelDll;
  if FileExists(Candidate) then Exit(Candidate);
end;

procedure TLosslessScalingTabHelper.PopulateGpuList;
var
  SR: TSearchRec;
  DrmPath, VendorPath, DevicePath: string;
  VendorId, DeviceId, DevName, GlxModel: string;
  SL: TStringList;
  GpuCount: Integer;
begin
  FLsGpuComboBox.Items.Clear;
  FLsGpuComboBox.Items.Add('Auto (Primary Display GPU)');
  
  GlxModel := GetSysGPUModel;
  GpuCount := 0;
  
  SL := TStringList.Create;
  try
    if FindFirst('/sys/class/drm/card*', faAnyFile, SR) = 0 then
    begin
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') and (Pos('-', SR.Name) = 0) then
        begin
          DrmPath := '/sys/class/drm/' + SR.Name + '/device/';
          if DirectoryExists(DrmPath) then
          begin
            VendorPath := DrmPath + 'vendor';
            DevicePath := DrmPath + 'device';
            VendorId := '';
            DeviceId := '';
            
            if FileExists(VendorPath) then
            begin
              try
                SL.LoadFromFile(VendorPath);
                if SL.Count > 0 then VendorId := LowerCase(Trim(SL[0]));
              except end;
            end;
            
            if FileExists(DevicePath) then
            begin
              try
                SL.LoadFromFile(DevicePath);
                if SL.Count > 0 then DeviceId := LowerCase(Trim(SL[0]));
              except end;
            end;
            
            if VendorId <> '' then
            begin
              if (Pos('1002', VendorId) > 0) or (Pos('0x1002', VendorId) > 0) then
                DevName := 'AMD GPU'
              else if (Pos('10de', VendorId) > 0) or (Pos('0x10de', VendorId) > 0) then
                DevName := 'NVIDIA GPU'
              else if (Pos('8086', VendorId) > 0) or (Pos('0x8086', VendorId) > 0) then
                DevName := 'Intel GPU'
              else
                DevName := 'GPU (' + VendorId + ':' + DeviceId + ')';
              
              if (GpuCount = 0) and (GlxModel <> 'Unknown GPU') and (GlxModel <> '') then
                DevName := GlxModel;
                
              FLsGpuComboBox.Items.Add(Format('GPU %d: %s (%s)', [GpuCount, DevName, SR.Name]));
              Inc(GpuCount);
            end;
          end;
        end;
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
  finally
    SL.Free;
  end;
  
  if FLsGpuComboBox.Items.Count = 1 then
  begin
    if (GlxModel <> 'Unknown GPU') and (GlxModel <> '') then
      FLsGpuComboBox.Items.Add('GPU 0: ' + GlxModel)
    else
      FLsGpuComboBox.Items.Add('GPU 0: Default Vulkan Device');
  end;
  
  FLsGpuComboBox.ItemIndex := 0;
end;

procedure TLosslessScalingTabHelper.ApplyThemeStyles;
var
  SS: WideString;
  IsDark: Boolean;
  TextColor, HintColor, AccentColor: TColor;
begin
  IsDark := (CurrentTheme = tmDark);
  if IsDark then
  begin
    TextColor   := clWhite;
    HintColor   := CLR_TEXT_MUTED;
    AccentColor := CLR_TEXT_ACCENT;
  end
  else
  begin
    TextColor   := LightTextColor;
    HintColor   := RGBToColor(100, 100, 110);
    AccentColor := RGBToColor(0, 120, 215);
  end;

  if Assigned(FLsScrollBox) then
  begin
    if IsDark then
      FLsScrollBox.Color := RGBToColor(22, 26, 40)
    else
      FLsScrollBox.Color := LightBackgroundColor;
  end;

  if Assigned(FLsBgPanel) then
  begin
    if IsDark then
      FLsBgPanel.Color := RGBToColor(22, 26, 40)
    else
      FLsBgPanel.Color := LightBackgroundColor;
    FLsBgPanel.OnPaint := @Tgoverlayform(FForm).PresetsWrapperPaint;
    FLsBgPanel.Invalidate;
  end;

  // Cards - styled using standard UpdateGenericCardTheme (which enforces transparent checkboxes)
  if Assigned(FLsGeneralCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsGeneralCard);
  if Assigned(FLsFrameGenCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsFrameGenCard);

  // QLineEdit & DLL Status styling
  UpdateDllStatus;

  // QComboBoxes
  SS := GetComboBoxStyleSheet(IsDark);
  if Assigned(FLsPacingComboBox) and FLsPacingComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsPacingComboBox.Handle).Widget, @SS);
  if Assigned(FLsGpuComboBox) and FLsGpuComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsGpuComboBox.Handle).Widget, @SS);

  // Labels color update
  if Assigned(FLsMultiplierTitleLbl) then FLsMultiplierTitleLbl.Font.Color := TextColor;
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Font.Color := TextColor;
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Font.Color := TextColor;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Font.Color := TextColor;
  if Assigned(FLsMultiplierValueLabel) then FLsMultiplierValueLabel.Font.Color := AccentColor;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Font.Color := AccentColor;

  // Sliders (QSlider)
  if IsDark then
    SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(38,46,72); border-radius: 3px; } ' +
          'QSlider::sub-page:horizontal { background: rgb(48,190,240); border-radius: 3px; } ' +
          'QSlider::handle:horizontal { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; } ' +
          'QSlider::handle:horizontal:hover { background: rgb(255,255,255); }'
  else
    SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(220,220,220); border-radius: 3px; } ' +
          'QSlider::sub-page:horizontal { background: rgb(0,120,215); border-radius: 3px; } ' +
          'QSlider::handle:horizontal { background: rgb(255,255,255); border: 1px solid rgb(180,180,180); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; }';

  if Assigned(FLsMultiplierTrackBar) and FLsMultiplierTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsMultiplierTrackBar.Handle).Widget, @SS);
  if Assigned(FLsFlowScaleTrackBar) and FLsFlowScaleTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsFlowScaleTrackBar.Handle).Widget, @SS);

  // Action Buttons (QPushButtons)
  if Assigned(FLsBrowseDllBtn) and FLsBrowseDllBtn.HandleAllocated then
  begin
    if IsDark then
      SS := 'QPushButton, QToolButton { background-color: rgb(38,46,72); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px; } ' +
            'QPushButton:hover, QToolButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); } ' +
            'QPushButton:pressed, QToolButton:pressed { background-color: rgb(28,34,54); } ' +
            'QPushButton:disabled, QToolButton:disabled { background-color: rgb(28,34,54); border: 1px solid rgb(40,48,70); }'
  else
      SS := 'QPushButton, QToolButton { background-color: rgb(240,240,240); border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 2px; }';
    QWidget_setStyleSheet(TQtWidget(FLsBrowseDllBtn.Handle).Widget, @SS);
  end;
end;

procedure TLosslessScalingTabHelper.InitLosslessScalingTab;
var
  Tab: TTabSheet;
begin
  Tab := Tgoverlayform(FForm).losslessScalingTabSheet;
  if not Assigned(Tab) then Exit;
  
  Tab.Color := RGBToColor(22, 26, 40);
  
  // ── ScrollBox ─────────────────────────────────────────────────────────────
  FLsScrollBox := TScrollBox.Create(FForm);
  FLsScrollBox.Parent := Tab;
  FLsScrollBox.Align := alClient;
  FLsScrollBox.AutoScroll := True;
  FLsScrollBox.BorderStyle := bsNone;
  FLsScrollBox.HorzScrollBar.Visible := False;
  FLsScrollBox.Color := RGBToColor(22, 26, 40);
  FLsScrollBox.ParentColor := False;
  FLsScrollBox.OnResize := @LsScrollBoxResize;
  
  // ── Background Panel ──────────────────────────────────────────────────────
  FLsBgPanel := TPanel.Create(FForm);
  FLsBgPanel.Parent := FLsScrollBox;
  FLsBgPanel.BevelOuter := bvNone;
  FLsBgPanel.Color := RGBToColor(22, 26, 40);
  FLsBgPanel.Caption := '';
  FLsBgPanel.OnPaint := @Tgoverlayform(FForm).PresetsWrapperPaint;
  FLsBgPanel.Left := 0;
  FLsBgPanel.Top := 0;
  FLsBgPanel.Width := FLsScrollBox.ClientWidth;
  FLsBgPanel.Height := 480;
  
  // ── Card 0: LossLess Scaling ──────────────────────────────────────────────
  FLsGeneralCard := TPanel.Create(FForm);
  FLsGeneralCard.Parent := FLsBgPanel;
  FLsGeneralCard.Caption := '';
  FLsGeneralCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsDllTitleLbl := TLabel.Create(FLsGeneralCard);
  FLsDllTitleLbl.Parent := FLsGeneralCard;
  FLsDllTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsGeneralCard, FLsDllTitleLbl, 'LossLess Scaling');
  
  FLsLogoImage := TImage.Create(FLsGeneralCard);
  FLsLogoImage.Parent := FLsGeneralCard;
  FLsLogoImage.AntialiasingMode := amOn;
  FLsLogoImage.Transparent := True;
  FLsLogoImage.Center := True;
  FLsLogoImage.Proportional := True;
  FLsLogoImage.Stretch := True;
  if FileExists(Tgoverlayform(FForm).GetAppBaseDir + 'assets/icons/lossless_scaling.png') then
    FLsLogoImage.Picture.LoadFromFile(Tgoverlayform(FForm).GetAppBaseDir + 'assets/icons/lossless_scaling.png');
  
  FLsDllPathEdit := TEdit.Create(FLsGeneralCard);
  FLsDllPathEdit.Parent := FLsGeneralCard;
  FLsDllPathEdit.Font.Name := 'DejaVu Sans Mono';
  FLsDllPathEdit.Font.Height := -13;
  FLsDllPathEdit.Font.Quality := fqAntialiased;
  FLsDllPathEdit.ReadOnly := True;
  FLsDllPathEdit.AutoSelect := False;
  FLsDllPathEdit.TabStop := False;
  FLsDllPathEdit.TextHint := 'Path to Lossless.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll)';
  FLsDllPathEdit.OnChange := @DllPathChange;
  StyleInputControl(FLsDllPathEdit);
  
  FLsBrowseDllBtn := TBitBtn.Create(FLsGeneralCard);
  FLsBrowseDllBtn.Parent := FLsGeneralCard;
  FLsBrowseDllBtn.Caption := '';
  FLsBrowseDllBtn.Images := Tgoverlayform(FForm).iconsImageList;
  FLsBrowseDllBtn.ImageIndex := 24;
  FLsBrowseDllBtn.Cursor := crHandPoint;
  FLsBrowseDllBtn.OnClick := @BrowseDllClick;
  StyleActionButton(FLsBrowseDllBtn);
  
  FLsDllStatusLabel := TLabel.Create(FLsGeneralCard);
  FLsDllStatusLabel.Parent := FLsGeneralCard;
  FLsDllStatusLabel.Caption := '● DLL file located';
  FLsDllStatusLabel.Font.Style := [fsBold];
  FLsDllStatusLabel.Font.Size := 9;
  FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
  
  // ── Card 1: Configuration (Consolidated) ──────────────────────────────────
  FLsFrameGenCard := TPanel.Create(FForm);
  FLsFrameGenCard.Parent := FLsBgPanel;
  FLsFrameGenCard.Caption := '';
  FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsFgTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgTitleLbl.Parent := FLsFrameGenCard;
  FLsFgTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsFrameGenCard, FLsFgTitleLbl, 'Configuration');
  
  // Row 1: Multiplier & Flow Scale Sliders
  FLsMultiplierTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierTitleLbl.Parent := FLsFrameGenCard;
  FLsMultiplierTitleLbl.Caption := 'Multiplier';
  FLsMultiplierTitleLbl.Hint := 'Frame generation multiplier: 1x (disabled), 2x, up to 10x';
  FLsMultiplierTitleLbl.ShowHint := True;
  StyleLabel(FLsMultiplierTitleLbl, lrControlLabel);
  
  FLsMultiplierTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsMultiplierTrackBar.Parent := FLsFrameGenCard;
  FLsMultiplierTrackBar.Min := 1;
  FLsMultiplierTrackBar.Max := 10;
  FLsMultiplierTrackBar.Position := 1;
  FLsMultiplierTrackBar.TickStyle := tsNone;
  FLsMultiplierTrackBar.Hint := 'Frame generation multiplier: 1x (disabled), 2x, up to 10x';
  FLsMultiplierTrackBar.ShowHint := True;
  FLsMultiplierTrackBar.OnChange := @MultiplierChange;
  
  FLsMultiplierValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierValueLabel.Parent := FLsFrameGenCard;
  FLsMultiplierValueLabel.Caption := '1x (Disabled)';
  FLsMultiplierValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsMultiplierValueLabel.Font.Style := [fsBold];
  
  FLsFlowScaleTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleTitleLbl.Parent := FLsFrameGenCard;
  FLsFlowScaleTitleLbl.Caption := 'Flow Scale';
  FLsFlowScaleTitleLbl.Hint := 'Lower internal motion estimation resolution for higher speed';
  FLsFlowScaleTitleLbl.ShowHint := True;
  StyleLabel(FLsFlowScaleTitleLbl, lrControlLabel);
  
  FLsFlowScaleTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsFlowScaleTrackBar.Parent := FLsFrameGenCard;
  FLsFlowScaleTrackBar.Min := 25;
  FLsFlowScaleTrackBar.Max := 100;
  FLsFlowScaleTrackBar.Position := 100;
  FLsFlowScaleTrackBar.TickStyle := tsNone;
  FLsFlowScaleTrackBar.Hint := 'Lower internal motion estimation resolution for higher speed';
  FLsFlowScaleTrackBar.ShowHint := True;
  FLsFlowScaleTrackBar.OnChange := @FlowScaleChange;
  
  FLsFlowScaleValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleValueLabel.Parent := FLsFrameGenCard;
  FLsFlowScaleValueLabel.Caption := '100%';
  FLsFlowScaleValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsFlowScaleValueLabel.Font.Style := [fsBold];
  
  // Row 2: Inline Toggles (3 Columns)
  FLsPerfModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsPerfModeCheckBox.Parent := FLsFrameGenCard;
  FLsPerfModeCheckBox.ParentColor := True;
  FLsPerfModeCheckBox.Caption := 'Performance Mode';
  FLsPerfModeCheckBox.Hint := 'Massively improve generation performance at a slight cost of image quality';
  FLsPerfModeCheckBox.ShowHint := True;
  FLsPerfModeCheckBox.OnChange := @ControlStateChange;
  FLsPerfModeCheckBox.Visible := False;
  
  FLsPerfModeToggle := TToggleSwitch.Create(FForm);
  FLsPerfModeToggle.Parent := FLsFrameGenCard;
  FLsPerfModeToggle.LinkToCheckBox(FLsPerfModeCheckBox);
  FLsPerfModeToggle.Height := 20;
  FLsPerfModeToggle.Width  := FLsPerfModeToggle.GetOptimalWidth;

  FLsHdrModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsHdrModeCheckBox.Parent := FLsFrameGenCard;
  FLsHdrModeCheckBox.ParentColor := True;
  FLsHdrModeCheckBox.Caption := 'HDR Mode';
  FLsHdrModeCheckBox.Hint := 'Switches shaders to HDR mode (only enable if game runs in HDR)';
  FLsHdrModeCheckBox.ShowHint := True;
  FLsHdrModeCheckBox.OnChange := @ControlStateChange;
  FLsHdrModeCheckBox.Visible := False;

  FLsHdrModeToggle := TToggleSwitch.Create(FForm);
  FLsHdrModeToggle.Parent := FLsFrameGenCard;
  FLsHdrModeToggle.LinkToCheckBox(FLsHdrModeCheckBox);
  FLsHdrModeToggle.Height := 20;
  FLsHdrModeToggle.Width  := FLsHdrModeToggle.GetOptimalWidth;

  FLsNoFp16CheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsNoFp16CheckBox.Parent := FLsFrameGenCard;
  FLsNoFp16CheckBox.ParentColor := True;
  FLsNoFp16CheckBox.Caption := 'Disable FP16 / Half-Precision';
  FLsNoFp16CheckBox.Hint := 'Has a giant performance uplift on AMD GPUs.' + LineEnding +
    'Does not affect NVIDIA GPUs (GTX 1000-series or older cards will actually see a big performance decrease)';
  FLsNoFp16CheckBox.ShowHint := True;
  FLsNoFp16CheckBox.OnChange := @ControlStateChange;
  FLsNoFp16CheckBox.Visible := False;

  FLsNoFp16Toggle := TToggleSwitch.Create(FForm);
  FLsNoFp16Toggle.Parent := FLsFrameGenCard;
  FLsNoFp16Toggle.LinkToCheckBox(FLsNoFp16CheckBox);
  FLsNoFp16Toggle.Height := 20;
  FLsNoFp16Toggle.Width  := FLsNoFp16Toggle.GetOptimalWidth;

  // Row 3: Dropdowns (2 Columns)
  FLsPacingTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsPacingTitleLbl.Parent := FLsFrameGenCard;
  FLsPacingTitleLbl.Caption := 'Pacing Mode';
  FLsPacingTitleLbl.Hint := 'Frame pacing mode to use (auto, vsync, mailbox, immediate, none)';
  FLsPacingTitleLbl.ShowHint := True;
  StyleLabel(FLsPacingTitleLbl, lrControlLabel);
  
  FLsPacingComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsPacingComboBox.Parent := FLsFrameGenCard;
  FLsPacingComboBox.Style := csDropDownList;
  FLsPacingComboBox.Items.Add('auto (Default / FIFO Recommended)');
  FLsPacingComboBox.Items.Add('vsync (Standard VSync)');
  FLsPacingComboBox.Items.Add('mailbox (Fast VSync)');
  FLsPacingComboBox.Items.Add('immediate (Uncapped)');
  FLsPacingComboBox.Items.Add('none (No Pacing)');
  FLsPacingComboBox.ItemIndex := 0;
  FLsPacingComboBox.Hint := 'Frame pacing mode to use (auto, vsync, mailbox, immediate, none)';
  FLsPacingComboBox.ShowHint := True;
  FLsPacingComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsPacingComboBox);
  
  FLsGpuTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsGpuTitleLbl.Parent := FLsFrameGenCard;
  FLsGpuTitleLbl.Caption := 'Target GPU Device';
  FLsGpuTitleLbl.Hint := 'Target GPU device to use for frame generation';
  FLsGpuTitleLbl.ShowHint := True;
  StyleLabel(FLsGpuTitleLbl, lrControlLabel);
  
  FLsGpuComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsGpuComboBox.Parent := FLsFrameGenCard;
  FLsGpuComboBox.Style := csDropDownList;
  FLsGpuComboBox.Hint := 'Target GPU device to use for frame generation';
  FLsGpuComboBox.ShowHint := True;
  FLsGpuComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsGpuComboBox);
  PopulateGpuList;
  
  // Load configuration
  LoadLosslessConfig;
  
  // If DLL path is empty, attempt auto-detect on initial load
  if Trim(FLsDllPathEdit.Text) = '' then
  begin
    FLsDllPathEdit.Text := DetectSteamLosslessDll;
  end;
  
  UpdateDllStatus;
  ApplyThemeStyles;
  ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
end;

procedure TLosslessScalingTabHelper.LsScrollBoxResize(Sender: TObject);
begin
  if Assigned(FLsScrollBox) then
    ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
end;

procedure TLosslessScalingTabHelper.ReflowLosslessScalingTab(AContentW: Integer);
var
  W, CW, CurY, Col2W, RightColX, Col3W, EditLeft, EditW: Integer;
begin
  if not Assigned(FLsScrollBox) or not Assigned(FLsGeneralCard) then Exit;
  
  W := FLsScrollBox.ClientWidth;
  if (W < 100) and (AContentW > 100) then
    W := AContentW;
  if W < 500 then W := 500;
  
  CW := W - (MARGIN * 2);
  CurY := MARGIN;
  
  // ── Card 0 Layout: LossLess Scaling ───────────────────────────────────────
  FLsGeneralCard.SetBounds(MARGIN, CurY, CW, 102);
  if Assigned(FLsLogoImage) then
    FLsLogoImage.SetBounds(PAD, 36, 52, 52);
    
  EditLeft := PAD + 52 + 14;
  EditW := CW - EditLeft - PAD - 38;
  FLsDllPathEdit.SetBounds(EditLeft, 36, EditW, ROW_H);
  FLsBrowseDllBtn.SetBounds(CW - PAD - 32, 36, 32, ROW_H);
  if Assigned(FLsDllStatusLabel) then
    FLsDllStatusLabel.SetBounds(EditLeft + 2, 68, CW - EditLeft - PAD, 20);
  CurY := CurY + FLsGeneralCard.Height + GAP;
  
  // ── Card 1 Layout: Configuration (Option 2 Grid) ──────────────────────────
  Col2W := (CW - (PAD * 2) - 20) div 2;
  RightColX := PAD + Col2W + 20;
  Col3W := (CW - (PAD * 2) - 24) div 3;
  
  FLsFrameGenCard.SetBounds(MARGIN, CurY, CW, 222);
  
  // Row 1: Sliders
  FLsMultiplierTitleLbl.SetBounds(PAD, 38, Col2W, 18);
  FLsMultiplierTrackBar.SetBounds(PAD, 58, Col2W - 85, ROW_H);
  FLsMultiplierValueLabel.SetBounds(PAD + Col2W - 80, 62, 80, 20);
  
  FLsFlowScaleTitleLbl.SetBounds(RightColX, 38, Col2W, 18);
  FLsFlowScaleTrackBar.SetBounds(RightColX, 58, Col2W - 55, ROW_H);
  FLsFlowScaleValueLabel.SetBounds(RightColX + Col2W - 50, 62, 50, 20);
  
  // Row 2: 3 Inline Toggles
  if Assigned(FLsPerfModeToggle) then FLsPerfModeToggle.SetBounds(PAD, 106, Col3W, 24);
  if Assigned(FLsHdrModeToggle) then FLsHdrModeToggle.SetBounds(PAD + Col3W + 12, 106, Col3W, 24);
  if Assigned(FLsNoFp16Toggle) then FLsNoFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 106, Col3W, 24);
  
  // Row 3: 2 Dropdowns
  FLsPacingTitleLbl.SetBounds(PAD, 148, Col2W, 18);
  FLsPacingComboBox.SetBounds(PAD, 168, Col2W, ROW_H);
  
  FLsGpuTitleLbl.SetBounds(RightColX, 148, Col2W, 18);
  FLsGpuComboBox.SetBounds(RightColX, 168, Col2W, ROW_H);
  
  CurY := CurY + FLsFrameGenCard.Height + MARGIN;
  
  FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY));
  ApplyThemeStyles;
end;

procedure TLosslessScalingTabHelper.UpdateDllStatus;
var
  P: string;
  SS: WideString;
  IsValid: Boolean;
  IsDark: Boolean;
begin
  if not Assigned(FLsDllPathEdit) or not FLsDllPathEdit.HandleAllocated then Exit;
  P := Trim(FLsDllPathEdit.Text);
  IsValid := (P <> '') and FileExists(P);
  IsDark := (CurrentTheme = tmDark);
  
  if IsValid then
  begin
    if IsDark then
      SS := 'QLineEdit { background-color: rgb(20, 36, 30); color: rgb(240, 250, 242); border: 1px solid rgb(42, 105, 66); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; selection-background-color: rgb(48, 190, 240); selection-color: rgb(0, 0, 0); } ' +
            'QLineEdit:focus { border: 1px solid rgb(55, 140, 88); }'
    else
      SS := 'QLineEdit { background-color: rgb(240, 248, 242); color: rgb(0, 80, 20); border: 1px solid rgb(80, 150, 100); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; }';
      
    if Assigned(FLsDllStatusLabel) then
    begin
      FLsDllStatusLabel.Caption := '● DLL file located';
      FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
    end;
  end
  else
  begin
    if IsDark then
      SS := 'QLineEdit { background-color: rgb(48, 20, 24); color: rgb(255, 210, 210); border: 1px solid rgb(160, 45, 55); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; selection-background-color: rgb(48, 190, 240); selection-color: rgb(0, 0, 0); } ' +
            'QLineEdit:focus { border: 1px solid rgb(220, 60, 70); }'
    else
      SS := 'QLineEdit { background-color: rgb(255, 235, 235); color: rgb(180, 20, 20); border: 1px solid rgb(200, 60, 60); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; }';
      
    if Assigned(FLsDllStatusLabel) then
    begin
      FLsDllStatusLabel.Caption := '● Install Lossless scaling on steam or point the correct file path';
      FLsDllStatusLabel.Font.Color := RGBToColor(255, 90, 95);
    end;
  end;
  QWidget_setStyleSheet(TQtWidget(FLsDllPathEdit.Handle).Widget, @SS);
  FLsDllPathEdit.SelStart := 0;
  FLsDllPathEdit.SelLength := 0;
end;

procedure TLosslessScalingTabHelper.UpdateControlsEnabled;
var
  FgActive: Boolean;
begin
  FgActive := Assigned(FLsMultiplierTrackBar) and (FLsMultiplierTrackBar.Position > 1);
  
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Enabled := FgActive;
  if Assigned(FLsFlowScaleTrackBar) then FLsFlowScaleTrackBar.Enabled := FgActive;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Enabled := FgActive;
  if Assigned(FLsPerfModeCheckBox) then FLsPerfModeCheckBox.Enabled := FgActive;
  if Assigned(FLsHdrModeCheckBox) then FLsHdrModeCheckBox.Enabled := FgActive;
  if Assigned(FLsNoFp16CheckBox) then FLsNoFp16CheckBox.Enabled := FgActive;
  if Assigned(FLsPerfModeToggle) then
  begin
    FLsPerfModeToggle.Enabled := FgActive;
    FLsPerfModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsHdrModeToggle) then
  begin
    FLsHdrModeToggle.Enabled := FgActive;
    FLsHdrModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsNoFp16Toggle) then
  begin
    FLsNoFp16Toggle.Enabled := FgActive;
    FLsNoFp16Toggle.SyncFromLinked;
  end;
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Enabled := FgActive;
  if Assigned(FLsPacingComboBox) then FLsPacingComboBox.Enabled := FgActive;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Enabled := FgActive;
  if Assigned(FLsGpuComboBox) then FLsGpuComboBox.Enabled := FgActive;
end;

procedure TLosslessScalingTabHelper.MultiplierChange(Sender: TObject);
var
  PosVal: Integer;
begin
  if not Assigned(FLsMultiplierTrackBar) then Exit;
  PosVal := FLsMultiplierTrackBar.Position;
  if Assigned(FLsMultiplierValueLabel) then
  begin
    if PosVal <= 1 then
      FLsMultiplierValueLabel.Caption := '1x (Disabled)'
    else
      FLsMultiplierValueLabel.Caption := IntToStr(PosVal) + 'x FPS';
  end;
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.DllPathChange(Sender: TObject);
begin
  UpdateDllStatus;
  if Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig then Exit;
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Tgoverlayform(FForm).StartAutoSaveTimer
  else
    SaveLosslessConfig;
end;

procedure TLosslessScalingTabHelper.BrowseDllClick(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(FForm);
  try
    OD.Title := 'Select Lossless.dll';
    OD.Filter := 'Lossless Scaling DLL (Lossless.dll)|Lossless.dll|Dynamic Libraries (*.dll)|*.dll|All Files (*)|*';
    if Trim(FLsDllPathEdit.Text) <> '' then
      OD.InitialDir := ExtractFilePath(FLsDllPathEdit.Text)
    else
      OD.InitialDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/Steam/steamapps/common/Lossless Scaling';
      
    if OD.Execute then
    begin
      FLsDllPathEdit.Text := OD.FileName;
    end;
  finally
    OD.Free;
  end;
end;

procedure TLosslessScalingTabHelper.FlowScaleChange(Sender: TObject);
begin
  if Assigned(FLsFlowScaleValueLabel) and Assigned(FLsFlowScaleTrackBar) then
    FLsFlowScaleValueLabel.Caption := IntToStr(FLsFlowScaleTrackBar.Position) + '%';
  if Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig then Exit;
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Tgoverlayform(FForm).StartAutoSaveTimer
  else
    SaveLosslessConfig;
end;

procedure TLosslessScalingTabHelper.ControlStateChange(Sender: TObject);
begin
  UpdateControlsEnabled;
  if Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig then Exit;
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Tgoverlayform(FForm).StartAutoSaveTimer
  else
    SaveLosslessConfig;
end;

function TLosslessScalingTabHelper.BuildEnvLine: string;
begin
  Result := GetActiveEnvVars;
end;

function TLosslessScalingTabHelper.WriteLsfgTomlConfig(const ATargetDir: string): string;
var
  Lines: TStringList;
  OutDir, OutPath, PacingStr, DllP: string;
  MultVal: Integer;
  FlowStr, ExeName: string;
  PerfStr, HdrStr, LegacyStr: string;
begin
  Result := '';
  if FLsMultiplierTrackBar.Position <= 1 then Exit;
  
  DllP := Trim(FLsDllPathEdit.Text);
  if (DllP = '') or not FileExists(DllP) then Exit;
  
  if ATargetDir <> '' then
    OutDir := ATargetDir
  else if Assigned(FForm) and (FForm is Tgoverlayform) then
    OutDir := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName)
  else
    OutDir := TConfigManager.GetGoverlayFolder;
    
  if not DirectoryExists(OutDir) then
    ForceDirectories(OutDir);
    
  OutPath := IncludeTrailingPathDelimiter(OutDir) + 'lsfg.toml';
  
  MultVal := FLsMultiplierTrackBar.Position;
  
  FlowStr := StringReplace(FormatFloat('0.00', FLsFlowScaleTrackBar.Position / 100.0), ',', '.', [rfReplaceAll]);
  if FLsPerfModeCheckBox.Checked then PerfStr := 'true' else PerfStr := 'false';
  if FLsHdrModeCheckBox.Checked then HdrStr := 'true' else HdrStr := 'false';
  if FLsNoFp16CheckBox.Checked then LegacyStr := 'true' else LegacyStr := 'false';
  
  case FLsPacingComboBox.ItemIndex of
    1: PacingStr := 'vsync';
    2: PacingStr := 'mailbox';
    3: PacingStr := 'immediate';
    4: PacingStr := 'none';
  else
    PacingStr := 'fifo';
  end;
  
  Lines := TStringList.Create;
  try
    Lines.Add('version = 1');
    Lines.Add('');
    Lines.Add('[global]');
    Lines.Add('dll = "' + DllP + '"');
    Lines.Add('');
    Lines.Add('[[game]]');
    Lines.Add('exe = "pascube"');
    Lines.Add('dll = "' + DllP + '"');
    Lines.Add('multiplier = ' + IntToStr(MultVal));
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('performance_mode = ' + PerfStr);
    Lines.Add('hdr_mode = ' + HdrStr);
    Lines.Add('legacy = ' + LegacyStr);
    Lines.Add('experimental_present_mode = "' + PacingStr + '"');
    Lines.Add('');
    Lines.Add('[[game]]');
    Lines.Add('exe = "vkcube"');
    Lines.Add('dll = "' + DllP + '"');
    Lines.Add('multiplier = ' + IntToStr(MultVal));
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('performance_mode = ' + PerfStr);
    Lines.Add('hdr_mode = ' + HdrStr);
    Lines.Add('legacy = ' + LegacyStr);
    Lines.Add('experimental_present_mode = "' + PacingStr + '"');
    
    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      Lines.Add('');
      Lines.Add('[[game]]');
      Lines.Add('exe = "' + ExeName + '"');
      Lines.Add('dll = "' + DllP + '"');
      Lines.Add('multiplier = ' + IntToStr(MultVal));
      Lines.Add('flow_scale = ' + FlowStr);
      Lines.Add('performance_mode = ' + PerfStr);
      Lines.Add('hdr_mode = ' + HdrStr);
      Lines.Add('legacy = ' + LegacyStr);
      Lines.Add('experimental_present_mode = "' + PacingStr + '"');
    end;
    
    Lines.SaveToFile(OutPath);
    Result := OutPath;
  finally
    Lines.Free;
  end;
end;

function TLosslessScalingTabHelper.WriteDefaultLsfgToml(const ATargetDir: string): string;
var
  Lines: TStringList;
  OutDir, OutPath, DllP, ExeName: string;
begin
  Result := '';
  if ATargetDir <> '' then
    OutDir := ATargetDir
  else if Assigned(FForm) and (FForm is Tgoverlayform) then
    OutDir := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName)
  else
    OutDir := TConfigManager.GetGoverlayFolder;

  if not DirectoryExists(OutDir) then
    ForceDirectories(OutDir);

  OutPath := IncludeTrailingPathDelimiter(OutDir) + 'lsfg.toml';

  DllP := Trim(FLsDllPathEdit.Text);
  if DllP = '' then
    DllP := DetectSteamLosslessDll;

  Lines := TStringList.Create;
  try
    Lines.Add('version = 1');
    Lines.Add('');
    Lines.Add('[global]');
    if (DllP <> '') and FileExists(DllP) then
      Lines.Add('dll = "' + DllP + '"')
    else
      Lines.Add('# dll = "/path/to/Lossless.dll"');
    Lines.Add('');
    Lines.Add('[[game]]');
    Lines.Add('exe = "pascube"');
    if (DllP <> '') and FileExists(DllP) then
      Lines.Add('dll = "' + DllP + '"');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('hdr_mode = false');
    Lines.Add('legacy = true');
    Lines.Add('experimental_present_mode = "fifo"');
    Lines.Add('');
    Lines.Add('[[game]]');
    Lines.Add('exe = "vkcube"');
    if (DllP <> '') and FileExists(DllP) then
      Lines.Add('dll = "' + DllP + '"');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('hdr_mode = false');
    Lines.Add('legacy = true');
    Lines.Add('experimental_present_mode = "fifo"');

    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      Lines.Add('');
      Lines.Add('[[game]]');
      Lines.Add('exe = "' + ExeName + '"');
      if (DllP <> '') and FileExists(DllP) then
        Lines.Add('dll = "' + DllP + '"');
      Lines.Add('multiplier = 2');
      Lines.Add('flow_scale = 1.00');
      Lines.Add('performance_mode = false');
      Lines.Add('hdr_mode = false');
      Lines.Add('legacy = true');
      Lines.Add('experimental_present_mode = "fifo"');
    end;

    Lines.SaveToFile(OutPath);
    Result := OutPath;
  finally
    Lines.Free;
  end;
end;

function TLosslessScalingTabHelper.GetActiveEnvVars: string;
var
  TomlP, DllP: string;
begin
  if FLsMultiplierTrackBar.Position <= 1 then
    Exit('');

  DllP := Trim(FLsDllPathEdit.Text);
  if (DllP = '') or not FileExists(DllP) then
    Exit('');

  TomlP := WriteLsfgTomlConfig;
  if (TomlP <> '') and FileExists(TomlP) then
    Result := 'LSFG_CONFIG="' + TomlP + '"'
  else
    Result := '';
end;

procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string);
var
  Lines: TStringList;
  i, p: Integer;
  Line, Key, Val: string;
begin
  ADll := '';
  AMultiplier := 2;
  AFlowScale := 1.0;
  APerfMode := False;
  AHdrMode := False;
  ANoFp16 := True;
  APacing := 'fifo';
  
  if not FileExists(AFilePath) then Exit;
  
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(AFilePath);
    for i := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[i]);
      if (Line = '') or (Line[1] = '#') or (Line[1] = '[') then Continue;
      p := Pos('=', Line);
      if p > 0 then
      begin
        Key := LowerCase(Trim(Copy(Line, 1, p - 1)));
        Val := Trim(Copy(Line, p + 1, MaxInt));
        // Strip surrounding quotes
        if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] in ['"', '''']) then
          Val := Copy(Val, 2, Length(Val) - 2);
          
        if Key = 'dll' then
        begin
          if (ADll = '') or FileExists(Val) then
            ADll := Val;
        end
        else if Key = 'multiplier' then
          AMultiplier := StrToIntDef(Val, AMultiplier)
        else if Key = 'flow_scale' then
          AFlowScale := StrToFloatDef(StringReplace(Val, '.', DecimalSeparator, []), AFlowScale)
        else if Key = 'performance_mode' then
          APerfMode := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'hdr_mode' then
          AHdrMode := (LowerCase(Val) = 'true') or (Val = '1')
        else if (Key = 'legacy') or (Key = 'no_fp16') then
          ANoFp16 := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'experimental_present_mode' then
          APacing := LowerCase(Val);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TLosslessScalingTabHelper.LoadLosslessConfig;
var
  Ini: TIniFile;
  CfgPath, CfgDir, TomlPath, DllVal, PacingVal, GpuVal, FlowVal, MultVal: string;
  FlowInt, MultInt, GpuIdx: Integer;
  IsLosslessOn, TomlFound, PerfModeVal, HdrModeVal, NoFp16Val: Boolean;
  ParsedFlow: Double;
begin
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Tgoverlayform(FForm).FLoadingConfig := True;
  try
    CfgPath := GetConfigFile;
    CfgDir := ExtractFilePath(CfgPath);
    TomlPath := IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml';
    
    // Set defaults
    FLsDllPathEdit.Text := DetectSteamLosslessDll;
    FLsMultiplierTrackBar.Position := 1; // 1x (no framegen)
    if Assigned(FLsMultiplierValueLabel) then
      FLsMultiplierValueLabel.Caption := '1x (Disabled)';
    FLsFlowScaleTrackBar.Position := 100;
    if Assigned(FLsFlowScaleValueLabel) then
      FLsFlowScaleValueLabel.Caption := '100%';
    FLsPerfModeCheckBox.Checked := False;
    FLsHdrModeCheckBox.Checked := False;
    FLsNoFp16CheckBox.Checked := True;
    FLsPacingComboBox.ItemIndex := 0; // auto
    FLsGpuComboBox.ItemIndex := 0; // Auto (-1)

    // Check if GOVERLAY_LOSSLESS is enabled in bgmod.conf
    IsLosslessOn := False;
    if FileExists(CfgPath) then
    begin
      Ini := TIniFile.Create(CfgPath);
      try
        IsLosslessOn := Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0') = '1';
      finally
        Ini.Free;
      end;
    end;

    TomlFound := False;
    if FileExists(TomlPath) then
    begin
      ParseLsfgToml(TomlPath, DllVal, MultInt, ParsedFlow, PerfModeVal, HdrModeVal, NoFp16Val, PacingVal);
      TomlFound := True;
      if DllVal <> '' then
        FLsDllPathEdit.Text := DllVal;
        
      if IsLosslessOn or (MultInt >= 2) then
      begin
        if MultInt < 1 then MultInt := 1;
        if MultInt > 10 then MultInt := 10;
        FLsMultiplierTrackBar.Position := MultInt;
        MultiplierChange(nil);
      end
      else
      begin
        FLsMultiplierTrackBar.Position := 1;
        MultiplierChange(nil);
      end;
        
      FlowInt := Round(ParsedFlow * 100);
      if FlowInt < 25 then FlowInt := 25;
      if FlowInt > 100 then FlowInt := 100;
      FLsFlowScaleTrackBar.Position := FlowInt;
      if Assigned(FLsFlowScaleValueLabel) then
        FLsFlowScaleValueLabel.Caption := IntToStr(FlowInt) + '%';
        
      FLsPerfModeCheckBox.Checked := PerfModeVal;
      FLsHdrModeCheckBox.Checked := HdrModeVal;
      FLsNoFp16CheckBox.Checked := NoFp16Val;
      
      PacingVal := LowerCase(Trim(PacingVal));
      if PacingVal = 'vsync' then FLsPacingComboBox.ItemIndex := 1
      else if PacingVal = 'mailbox' then FLsPacingComboBox.ItemIndex := 2
      else if PacingVal = 'immediate' then FLsPacingComboBox.ItemIndex := 3
      else if PacingVal = 'none' then FLsPacingComboBox.ItemIndex := 4
      else FLsPacingComboBox.ItemIndex := 0;
    end;

    // Fallback migration: if lsfg.toml not found, check legacy bgmod.conf keys
    if not TomlFound and FileExists(CfgPath) then
    begin
      Ini := TIniFile.Create(CfgPath);
      try
        DllVal := Ini.ReadString('Config', 'LS_DLL_PATH', Ini.ReadString('Env', 'LSFG_DLL_PATH', Ini.ReadString('Env', 'LSFGVK_DLL_PATH', '')));
        if DllVal <> '' then
          FLsDllPathEdit.Text := DllVal;
          
        MultVal := Ini.ReadString('Config', 'LS_MULTIPLIER', Ini.ReadString('Env', 'LSFG_MULTIPLIER', Ini.ReadString('Env', 'LSFGVK_MULTIPLIER', '0')));
        MultInt := StrToIntDef(MultVal, 0);
        if IsLosslessOn and (MultInt >= 2) then
        begin
          if MultInt < 1 then MultInt := 1;
          if MultInt > 10 then MultInt := 10;
          FLsMultiplierTrackBar.Position := MultInt;
          MultiplierChange(nil);
        end
        else
        begin
          FLsMultiplierTrackBar.Position := 1;
          MultiplierChange(nil);
        end;
          
        FlowVal := Ini.ReadString('Config', 'LS_FLOW_SCALE', Ini.ReadString('Env', 'LSFG_FLOW_SCALE', Ini.ReadString('Env', 'LSFGVK_FLOW_SCALE', '')));
        if FlowVal <> '' then
        begin
          if Pos('.', FlowVal) > 0 then
            FlowInt := Round(StrToFloatDef(StringReplace(FlowVal, '.', DecimalSeparator, []), 1.0) * 100)
          else
            FlowInt := StrToIntDef(FlowVal, 100);
          if FlowInt < 25 then FlowInt := 25;
          if FlowInt > 100 then FlowInt := 100;
          FLsFlowScaleTrackBar.Position := FlowInt;
          if Assigned(FLsFlowScaleValueLabel) then
            FLsFlowScaleValueLabel.Caption := IntToStr(FlowInt) + '%';
        end;
        
        FLsPerfModeCheckBox.Checked := (Ini.ReadString('Config', 'LS_PERFORMANCE_MODE', Ini.ReadString('Env', 'LSFG_PERFORMANCE_MODE', Ini.ReadString('Env', 'LSFGVK_PERFORMANCE_MODE', '0'))) = '1');
        FLsHdrModeCheckBox.Checked := (Ini.ReadString('Config', 'LS_HDR_MODE', Ini.ReadString('Env', 'LSFG_HDR_MODE', Ini.ReadString('Env', 'LSFGVK_HDR_MODE', '0'))) = '1');
        FLsNoFp16CheckBox.Checked := (Ini.ReadString('Config', 'LS_NO_FP16', Ini.ReadString('Env', 'LSFG_LEGACY', Ini.ReadString('Env', 'LSFGVK_NO_FP16', '1'))) = '1');
        
        PacingVal := LowerCase(Trim(Ini.ReadString('Config', 'LS_PACING', Ini.ReadString('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE', Ini.ReadString('Env', 'LSFGVK_PACING', 'auto')))));
        if PacingVal = 'vsync' then FLsPacingComboBox.ItemIndex := 1
        else if PacingVal = 'mailbox' then FLsPacingComboBox.ItemIndex := 2
        else if PacingVal = 'immediate' then FLsPacingComboBox.ItemIndex := 3
        else if PacingVal = 'none' then FLsPacingComboBox.ItemIndex := 4
        else FLsPacingComboBox.ItemIndex := 0;
        
        GpuVal := Trim(Ini.ReadString('Config', 'LS_GPU', Ini.ReadString('Env', 'LSFG_GPU', Ini.ReadString('Env', 'LSFGVK_GPU', ''))));
        if GpuVal <> '' then
        begin
          GpuIdx := StrToIntDef(GpuVal, -1) + 1;
          if (GpuIdx >= 0) and (GpuIdx < FLsGpuComboBox.Items.Count) then
            FLsGpuComboBox.ItemIndex := GpuIdx;
        end;
      finally
        Ini.Free;
      end;
    end;
  finally
    if Assigned(FForm) and (FForm is Tgoverlayform) then
      Tgoverlayform(FForm).FLoadingConfig := False;
  end;
  
  UpdateControlsEnabled;
  UpdateDllStatus;
  if Assigned(FLsDllPathEdit) then
  begin
    FLsDllPathEdit.SelStart := 0;
    FLsDllPathEdit.SelLength := 0;
  end;
end;

procedure TLosslessScalingTabHelper.SaveLosslessConfig;
var
  Ini: TIniFile;
  CfgPath, CfgDir, DllPath: string;
  IsEnabled: Boolean;
begin
  UpdateControlsEnabled;
  CfgPath := GetConfigFile;
  CfgDir := ExtractFilePath(CfgPath);
  if not DirectoryExists(CfgDir) then
    ForceDirectories(CfgDir);
    
  DllPath := Trim(FLsDllPathEdit.Text);
  IsEnabled := (DllPath <> '') and FileExists(DllPath) and (FLsMultiplierTrackBar.Position > 1);
  
  Ini := TIniFile.Create(CfgPath);
  try
    if IsEnabled then
    begin
      // 1. Write only the master switch to Config section
      Ini.WriteString('Config', 'GOVERLAY_LOSSLESS', '1');

      // 2. Prune any redundant LS_* keys from [Config]
      Ini.DeleteKey('Config', 'LS_DLL_PATH');
      Ini.DeleteKey('Config', 'LS_MULTIPLIER');
      Ini.DeleteKey('Config', 'LS_FLOW_SCALE');
      Ini.DeleteKey('Config', 'LS_PERFORMANCE_MODE');
      Ini.DeleteKey('Config', 'LS_HDR_MODE');
      Ini.DeleteKey('Config', 'LS_NO_FP16');
      Ini.DeleteKey('Config', 'LS_PACING');
      Ini.DeleteKey('Config', 'LS_GPU');

      // 3. Prune any legacy LSFG_* or LSFGVK_* keys from [Env]
      Ini.DeleteKey('Env', 'LSFG_DLL_PATH');
      Ini.DeleteKey('Env', 'LSFG_MULTIPLIER');
      Ini.DeleteKey('Env', 'LSFG_FLOW_SCALE');
      Ini.DeleteKey('Env', 'LSFG_PERFORMANCE_MODE');
      Ini.DeleteKey('Env', 'LSFG_HDR_MODE');
      Ini.DeleteKey('Env', 'LSFG_LEGACY');
      Ini.DeleteKey('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE');
      Ini.DeleteKey('Env', 'LSFG_GPU');
      Ini.DeleteKey('Env', 'LSFGVK_ENV');
      Ini.DeleteKey('Env', 'LSFGVK_DLL_PATH');
      Ini.DeleteKey('Env', 'LSFGVK_MULTIPLIER');
      Ini.DeleteKey('Env', 'LSFGVK_FLOW_SCALE');
      Ini.DeleteKey('Env', 'LSFGVK_PERFORMANCE_MODE');
      Ini.DeleteKey('Env', 'LSFGVK_HDR_MODE');
      Ini.DeleteKey('Env', 'LSFGVK_NO_FP16');
      Ini.DeleteKey('Env', 'LSFGVK_PACING');
      Ini.DeleteKey('Env', 'LSFGVK_GPU');

      // 4. Write target lsfg.toml as the single source of truth
      WriteLsfgTomlConfig(CfgDir);
    end
    else
    begin
      // Disabled (1x or invalid DLL): set GOVERLAY_LOSSLESS=0, prune keys, and remove lsfg.toml
      Ini.WriteString('Config', 'GOVERLAY_LOSSLESS', '0');
      Ini.DeleteKey('Config', 'LS_DLL_PATH');
      Ini.DeleteKey('Config', 'LS_MULTIPLIER');
      Ini.DeleteKey('Config', 'LS_FLOW_SCALE');
      Ini.DeleteKey('Config', 'LS_PERFORMANCE_MODE');
      Ini.DeleteKey('Config', 'LS_HDR_MODE');
      Ini.DeleteKey('Config', 'LS_NO_FP16');
      Ini.DeleteKey('Config', 'LS_PACING');
      Ini.DeleteKey('Config', 'LS_GPU');

      Ini.DeleteKey('Env', 'LSFG_DLL_PATH');
      Ini.DeleteKey('Env', 'LSFG_MULTIPLIER');
      Ini.DeleteKey('Env', 'LSFG_FLOW_SCALE');
      Ini.DeleteKey('Env', 'LSFG_PERFORMANCE_MODE');
      Ini.DeleteKey('Env', 'LSFG_HDR_MODE');
      Ini.DeleteKey('Env', 'LSFG_LEGACY');
      Ini.DeleteKey('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE');
      Ini.DeleteKey('Env', 'LSFG_GPU');
      Ini.DeleteKey('Env', 'LSFGVK_ENV');
      Ini.DeleteKey('Env', 'LSFGVK_DLL_PATH');
      Ini.DeleteKey('Env', 'LSFGVK_MULTIPLIER');
      Ini.DeleteKey('Env', 'LSFGVK_FLOW_SCALE');
      Ini.DeleteKey('Env', 'LSFGVK_PERFORMANCE_MODE');
      Ini.DeleteKey('Env', 'LSFGVK_HDR_MODE');
      Ini.DeleteKey('Env', 'LSFGVK_NO_FP16');
      Ini.DeleteKey('Env', 'LSFGVK_PACING');
      Ini.DeleteKey('Env', 'LSFGVK_GPU');

      if FileExists(IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml') then
        DeleteFile(IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml');
    end;
  finally
    Ini.Free;
  end;
end;

end.
