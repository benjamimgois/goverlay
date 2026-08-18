unit lossless_scaling_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls,
  Clipbrd, IniFiles, Math, themeunit, constants, hintsunit, apputils, configkeys, configmanager, systemdetector;

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
    FLsHardwareCard: TPanel;
    
    // Card 0: DLL file path
    FLsDllTitleLbl: TLabel;
    FLsDllPathEdit: TEdit;
    FLsBrowseDllBtn: TBitBtn;
    
    // Card 1: Configuration
    FLsFgTitleLbl: TLabel;
    FLsMultiplierTitleLbl: TLabel;
    FLsMultiplierComboBox: TComboBox;
    
    FLsFlowScaleTitleLbl: TLabel;
    FLsFlowScaleTrackBar: TTrackBar;
    FLsFlowScaleValueLabel: TLabel;
    
    FLsPerfModeCheckBox: TCheckBox;
    FLsHdrModeCheckBox: TCheckBox;
    
    // Card 2: Hardware & Pacing
    FLsHwTitleLbl: TLabel;
    FLsNoFp16CheckBox: TCheckBox;
    
    FLsPacingTitleLbl: TLabel;
    FLsPacingComboBox: TComboBox;
    
    FLsGpuTitleLbl: TLabel;
    FLsGpuComboBox: TComboBox;
    
    procedure DllPathChange(Sender: TObject);
    procedure BrowseDllClick(Sender: TObject);
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
    function DetectSteamLosslessDll: string;
    
    property DllPathEdit: TEdit read FLsDllPathEdit;
    property MultiplierComboBox: TComboBox read FLsMultiplierComboBox;
    property FlowScaleTrackBar: TTrackBar read FLsFlowScaleTrackBar;
    property PerfModeCheckBox: TCheckBox read FLsPerfModeCheckBox;
    property HdrModeCheckBox: TCheckBox read FLsHdrModeCheckBox;
    property NoFp16CheckBox: TCheckBox read FLsNoFp16CheckBox;
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
  CARD_PAD = 14;
  ROW_H    = 28;

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
  if Assigned(FLsHardwareCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsHardwareCard);

  // QLineEdit & DLL Status styling
  UpdateDllStatus;

  // QComboBoxes
  if IsDark then
    SS := 'QComboBox { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 6px; } ' +
          'QComboBox:hover { border: 1px solid rgb(80,110,170); } ' +
          'QComboBox:focus { border: 1px solid rgb(48,190,240); } ' +
          'QComboBox:disabled { background-color: rgb(28,34,54); color: rgb(100,110,130); } ' +
          'QComboBox QAbstractItemView { background-color: rgb(28,36,60); color: rgb(255,255,255); selection-background-color: rgb(50,90,175); border: 1px solid rgb(55,70,108); }'
  else
    SS := 'QComboBox { background-color: rgb(255,255,255); color: rgb(0,0,0); border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 2px 6px; }';

  if Assigned(FLsMultiplierComboBox) and FLsMultiplierComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsMultiplierComboBox.Handle).Widget, @SS);
  if Assigned(FLsPacingComboBox) and FLsPacingComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsPacingComboBox.Handle).Widget, @SS);
  if Assigned(FLsGpuComboBox) and FLsGpuComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsGpuComboBox.Handle).Widget, @SS);

  // Labels color update
  if Assigned(FLsMultiplierTitleLbl) then FLsMultiplierTitleLbl.Font.Color := TextColor;
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Font.Color := TextColor;
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Font.Color := TextColor;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Font.Color := TextColor;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Font.Color := AccentColor;

  // Slider (QSlider)
  if IsDark then
    SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(38,46,72); border-radius: 3px; } ' +
          'QSlider::sub-page:horizontal { background: rgb(48,190,240); border-radius: 3px; } ' +
          'QSlider::handle:horizontal { background: rgb(220,225,240); border: 1px solid rgb(48,190,240); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; } ' +
          'QSlider::handle:horizontal:hover { background: rgb(255,255,255); }'
  else
    SS := 'QSlider::groove:horizontal { height: 6px; background: rgb(220,220,220); border-radius: 3px; } ' +
          'QSlider::sub-page:horizontal { background: rgb(0,120,215); border-radius: 3px; } ' +
          'QSlider::handle:horizontal { background: rgb(255,255,255); border: 1px solid rgb(180,180,180); width: 14px; margin-top: -4px; margin-bottom: -4px; border-radius: 7px; }';

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
  
  // ── Card 0: DLL file path ─────────────────────────────────────────────────
  FLsGeneralCard := TPanel.Create(FForm);
  FLsGeneralCard.Parent := FLsBgPanel;
  FLsGeneralCard.Caption := '';
  FLsGeneralCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsDllTitleLbl := TLabel.Create(FLsGeneralCard);
  FLsDllTitleLbl.Parent := FLsGeneralCard;
  FLsDllTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsGeneralCard, FLsDllTitleLbl, 'DLL file path');
  
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
  
  // ── Card 1: Configuration ────────────────────────────────────────────────
  FLsFrameGenCard := TPanel.Create(FForm);
  FLsFrameGenCard.Parent := FLsBgPanel;
  FLsFrameGenCard.Caption := '';
  FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsFgTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgTitleLbl.Parent := FLsFrameGenCard;
  FLsFgTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsFrameGenCard, FLsFgTitleLbl, 'Configuration');
  
  FLsMultiplierTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierTitleLbl.Parent := FLsFrameGenCard;
  FLsMultiplierTitleLbl.Caption := 'Multiplier';
  FLsMultiplierTitleLbl.Hint := 'Frame generation multiplier (1x disabled, 2x double, up to 6x)';
  FLsMultiplierTitleLbl.ShowHint := True;
  StyleLabel(FLsMultiplierTitleLbl, lrControlLabel);
  
  FLsMultiplierComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsMultiplierComboBox.Parent := FLsFrameGenCard;
  FLsMultiplierComboBox.Style := csDropDownList;
  FLsMultiplierComboBox.Items.Add('1x (no framegen)');
  FLsMultiplierComboBox.Items.Add('2x (Double FPS)');
  FLsMultiplierComboBox.Items.Add('3x (Triple FPS)');
  FLsMultiplierComboBox.Items.Add('4x (Quadruple FPS)');
  FLsMultiplierComboBox.Items.Add('5x (Quintuple FPS)');
  FLsMultiplierComboBox.Items.Add('6x (Sextuple FPS)');
  FLsMultiplierComboBox.ItemIndex := 0;
  FLsMultiplierComboBox.Hint := 'Frame generation multiplier (1x disabled, 2x double, up to 6x)';
  FLsMultiplierComboBox.ShowHint := True;
  FLsMultiplierComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsMultiplierComboBox);
  
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
  
  FLsPerfModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsPerfModeCheckBox.Parent := FLsFrameGenCard;
  FLsPerfModeCheckBox.ParentColor := True;
  FLsPerfModeCheckBox.Caption := 'Performance Mode';
  FLsPerfModeCheckBox.Hint := 'Massively improve generation performance at a slight cost of image quality';
  FLsPerfModeCheckBox.ShowHint := True;
  FLsPerfModeCheckBox.OnChange := @ControlStateChange;
  StyleToggleControl(FLsPerfModeCheckBox);
  
  FLsHdrModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsHdrModeCheckBox.Parent := FLsFrameGenCard;
  FLsHdrModeCheckBox.ParentColor := True;
  FLsHdrModeCheckBox.Caption := 'HDR Mode';
  FLsHdrModeCheckBox.Hint := 'Switches shaders to HDR mode (only enable if game runs in HDR)';
  FLsHdrModeCheckBox.ShowHint := True;
  FLsHdrModeCheckBox.OnChange := @ControlStateChange;
  StyleToggleControl(FLsHdrModeCheckBox);
  
  // ── Card 2: Hardware & Pacing ─────────────────────────────────────────────
  FLsHardwareCard := TPanel.Create(FForm);
  FLsHardwareCard.Parent := FLsBgPanel;
  FLsHardwareCard.Caption := '';
  FLsHardwareCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsHwTitleLbl := TLabel.Create(FLsHardwareCard);
  FLsHwTitleLbl.Parent := FLsHardwareCard;
  FLsHwTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsHardwareCard, FLsHwTitleLbl, 'Hardware & Pacing');
  
  FLsNoFp16CheckBox := TCheckBox.Create(FLsHardwareCard);
  FLsNoFp16CheckBox.Parent := FLsHardwareCard;
  FLsNoFp16CheckBox.ParentColor := True;
  FLsNoFp16CheckBox.Caption := 'Disable FP16 / Half-Precision';
  FLsNoFp16CheckBox.Hint := 'Has a giant performance uplift on AMD GPUs.' + LineEnding +
    'Does not affect NVIDIA GPUs (GTX 1000-series or older cards will actually see a big performance decrease)';
  FLsNoFp16CheckBox.ShowHint := True;
  FLsNoFp16CheckBox.OnChange := @ControlStateChange;
  StyleToggleControl(FLsNoFp16CheckBox);
  
  FLsPacingTitleLbl := TLabel.Create(FLsHardwareCard);
  FLsPacingTitleLbl.Parent := FLsHardwareCard;
  FLsPacingTitleLbl.Caption := 'Pacing Mode';
  FLsPacingTitleLbl.Hint := 'Frame pacing mode to use (auto, vsync, mailbox, immediate, none)';
  FLsPacingTitleLbl.ShowHint := True;
  StyleLabel(FLsPacingTitleLbl, lrControlLabel);
  
  FLsPacingComboBox := TComboBox.Create(FLsHardwareCard);
  FLsPacingComboBox.Parent := FLsHardwareCard;
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
  
  FLsGpuTitleLbl := TLabel.Create(FLsHardwareCard);
  FLsGpuTitleLbl.Parent := FLsHardwareCard;
  FLsGpuTitleLbl.Caption := 'Target GPU Device';
  FLsGpuTitleLbl.Hint := 'Target GPU device to use for frame generation';
  FLsGpuTitleLbl.ShowHint := True;
  StyleLabel(FLsGpuTitleLbl, lrControlLabel);
  
  FLsGpuComboBox := TComboBox.Create(FLsHardwareCard);
  FLsGpuComboBox.Parent := FLsHardwareCard;
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
  W, CardW, CurY, ColW, RightColX: Integer;
begin
  if not Assigned(FLsScrollBox) or not Assigned(FLsGeneralCard) then Exit;
  
  W := AContentW;
  if W <= 0 then W := FLsScrollBox.ClientWidth;
  if W < 500 then W := 500;
  
  FLsBgPanel.Width := W;
  CardW := W - (CARD_PAD * 2);
  CurY := CARD_PAD;
  
  // ── Card 0 Layout: DLL file path ──────────────────────────────────────────
  FLsGeneralCard.SetBounds(CARD_PAD, CurY, CardW, 76);
  FLsDllPathEdit.SetBounds(CARD_PAD, 34, CardW - (CARD_PAD * 2) - 38, ROW_H);
  FLsBrowseDllBtn.SetBounds(CardW - CARD_PAD - 32, 34, 32, ROW_H);
  CurY := CurY + FLsGeneralCard.Height + 12;
  
  // ── Card 1 Layout: Configuration ─────────────────────────────────────────
  // Left column: Multiplier and Flow Scale (controls directly below labels)
  // Right column: Performance Mode and HDR Mode checkboxes
  ColW := (CardW - (CARD_PAD * 2) - 20) div 2;
  RightColX := CARD_PAD + ColW + 20;
  
  FLsFrameGenCard.SetBounds(CARD_PAD, CurY, CardW, 160);
  
  // Left column
  FLsMultiplierTitleLbl.SetBounds(CARD_PAD, 36, ColW, 18);
  FLsMultiplierComboBox.SetBounds(CARD_PAD, 56, ColW, ROW_H);
  
  FLsFlowScaleTitleLbl.SetBounds(CARD_PAD, 94, ColW, 18);
  FLsFlowScaleTrackBar.SetBounds(CARD_PAD, 114, ColW - 48, ROW_H);
  FLsFlowScaleValueLabel.SetBounds(CARD_PAD + ColW - 44, 118, 44, 20);
  
  // Right column
  FLsPerfModeCheckBox.SetBounds(RightColX, 58, ColW, 24);
  FLsHdrModeCheckBox.SetBounds(RightColX, 116, ColW, 24);
  CurY := CurY + FLsFrameGenCard.Height + 12;
  
  // ── Card 2 Layout: Hardware & Pacing ─────────────────────────────────────
  FLsHardwareCard.SetBounds(CARD_PAD, CurY, CardW, 142);
  
  FLsNoFp16CheckBox.SetBounds(CARD_PAD, 36, CardW - (CARD_PAD * 2), 24);
  
  FLsPacingTitleLbl.SetBounds(CARD_PAD, 70, ColW, 18);
  FLsPacingComboBox.SetBounds(CARD_PAD, 90, ColW, ROW_H);
  
  FLsGpuTitleLbl.SetBounds(RightColX, 70, ColW, 18);
  FLsGpuComboBox.SetBounds(RightColX, 90, ColW, ROW_H);
  CurY := CurY + FLsHardwareCard.Height + CARD_PAD;
  
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
  end
  else
  begin
    if IsDark then
      SS := 'QLineEdit { background-color: rgb(38, 46, 72); color: rgb(255, 255, 255); border: 1px solid rgb(55, 70, 108); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; selection-background-color: rgb(48, 190, 240); selection-color: rgb(0, 0, 0); } ' +
            'QLineEdit:focus { border: 1px solid rgb(48, 190, 240); }'
    else
      SS := 'QLineEdit { background-color: rgb(255, 255, 255); color: rgb(0, 0, 0); border: 1px solid rgb(200, 200, 200); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; }';
  end;
  QWidget_setStyleSheet(TQtWidget(FLsDllPathEdit.Handle).Widget, @SS);
  FLsDllPathEdit.SelStart := 0;
  FLsDllPathEdit.SelLength := 0;
end;

procedure TLosslessScalingTabHelper.UpdateControlsEnabled;
var
  FgActive: Boolean;
begin
  FgActive := Assigned(FLsMultiplierComboBox) and (FLsMultiplierComboBox.ItemIndex > 0);
  
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Enabled := FgActive;
  if Assigned(FLsFlowScaleTrackBar) then FLsFlowScaleTrackBar.Enabled := FgActive;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Enabled := FgActive;
  if Assigned(FLsPerfModeCheckBox) then FLsPerfModeCheckBox.Enabled := FgActive;
  if Assigned(FLsHdrModeCheckBox) then FLsHdrModeCheckBox.Enabled := FgActive;
  if Assigned(FLsNoFp16CheckBox) then FLsNoFp16CheckBox.Enabled := FgActive;
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Enabled := FgActive;
  if Assigned(FLsPacingComboBox) then FLsPacingComboBox.Enabled := FgActive;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Enabled := FgActive;
  if Assigned(FLsGpuComboBox) then FLsGpuComboBox.Enabled := FgActive;
end;

procedure TLosslessScalingTabHelper.DllPathChange(Sender: TObject);
begin
  UpdateDllStatus;
  if Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig then Exit;
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
  SaveLosslessConfig;
end;

procedure TLosslessScalingTabHelper.ControlStateChange(Sender: TObject);
begin
  UpdateControlsEnabled;
  if Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig then Exit;
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
  if FLsMultiplierComboBox.ItemIndex <= 0 then Exit;
  
  DllP := Trim(FLsDllPathEdit.Text);
  if (DllP = '') or not FileExists(DllP) then Exit;
  
  if ATargetDir <> '' then
    OutDir := ATargetDir
  else if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    OutDir := Tgoverlayform(FForm).GetGameConfigDir(Tgoverlayform(FForm).FActiveGameName)
  else
    OutDir := TConfigManager.GetGoverlayFolder;
    
  if not DirectoryExists(OutDir) then
    ForceDirectories(OutDir);
    
  OutPath := IncludeTrailingPathDelimiter(OutDir) + 'lsfg.toml';
  
  case FLsMultiplierComboBox.ItemIndex of
    1: MultVal := 2;
    2: MultVal := 3;
    3: MultVal := 4;
    4: MultVal := 5;
    5: MultVal := 6;
  else
    MultVal := 2;
  end;
  
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

function TLosslessScalingTabHelper.GetActiveEnvVars: string;
var
  TomlP, DllP: string;
begin
  if FLsMultiplierComboBox.ItemIndex <= 0 then
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
    FLsMultiplierComboBox.ItemIndex := 0; // 1x (no framegen)
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
        case MultInt of
          2: FLsMultiplierComboBox.ItemIndex := 1;
          3: FLsMultiplierComboBox.ItemIndex := 2;
          4: FLsMultiplierComboBox.ItemIndex := 3;
          5: FLsMultiplierComboBox.ItemIndex := 4;
          6: FLsMultiplierComboBox.ItemIndex := 5;
        else
          FLsMultiplierComboBox.ItemIndex := 1;
        end;
      end
      else
        FLsMultiplierComboBox.ItemIndex := 0;
        
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
          case MultInt of
            2: FLsMultiplierComboBox.ItemIndex := 1;
            3: FLsMultiplierComboBox.ItemIndex := 2;
            4: FLsMultiplierComboBox.ItemIndex := 3;
            5: FLsMultiplierComboBox.ItemIndex := 4;
            6: FLsMultiplierComboBox.ItemIndex := 5;
          else
            FLsMultiplierComboBox.ItemIndex := 1;
          end;
        end
        else
          FLsMultiplierComboBox.ItemIndex := 0;
          
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
  IsEnabled := (DllPath <> '') and FileExists(DllPath) and (FLsMultiplierComboBox.ItemIndex > 0);
  
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
