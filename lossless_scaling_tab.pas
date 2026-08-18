unit lossless_scaling_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls,
  Clipbrd, IniFiles, themeunit, constants, hintsunit, apputils, configkeys, configmanager, systemdetector;

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
    
    // Card 1: Frame Generation
    FLsFgTitleLbl: TLabel;
    FLsMultiplierTitleLbl: TLabel;
    FLsMultiplierDescLbl: TLabel;
    FLsMultiplierComboBox: TComboBox;
    
    FLsFlowScaleTitleLbl: TLabel;
    FLsFlowScaleDescLbl: TLabel;
    FLsFlowScaleTrackBar: TTrackBar;
    FLsFlowScaleValueLabel: TLabel;
    
    FLsPerfModeCheckBox: TCheckBox;
    FLsPerfModeDescLbl: TLabel;
    
    // Card 2: Hardware & Pacing
    FLsHwTitleLbl: TLabel;
    FLsNoFp16CheckBox: TCheckBox;
    FLsNoFp16DescLbl: TLabel;
    
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
    procedure LoadLosslessConfig;
    procedure SaveLosslessConfig;
    function GetActiveEnvVars: string;
    function DetectSteamLosslessDll: string;
  end;

implementation

uses
  {$IFDEF LCLqt6}
  qt6,
  {$ELSE}
  qt5,
  {$ENDIF}
  qtwidgets,
  overlayunit;

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
begin
  Result := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder) + 'lossless_scaling.ini';
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

  // Cards
  if Assigned(FLsGeneralCard) then
  begin
    FLsGeneralCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
    FLsGeneralCard.Invalidate;
  end;
  if Assigned(FLsFrameGenCard) then
  begin
    FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
    FLsFrameGenCard.Invalidate;
  end;
  if Assigned(FLsHardwareCard) then
  begin
    FLsHardwareCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
    FLsHardwareCard.Invalidate;
  end;

  // QLineEdit & DLL Status styling
  UpdateDllStatus;

  // QComboBoxes
  if IsDark then
    SS := 'QComboBox { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 6px; } ' +
          'QComboBox::drop-down { subcontrol-origin: padding; subcontrol-position: top right; width: 18px; border-left: none; } ' +
          'QComboBox QAbstractItemView { background-color: rgb(26,30,46); color: rgb(255,255,255); selection-background-color: rgb(48,190,240); selection-color: rgb(0,0,0); border: 1px solid rgb(55,70,108); }'
  else
    SS := 'QComboBox { background-color: rgb(255,255,255); color: rgb(0,0,0); border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 2px 6px; }';

  if Assigned(FLsMultiplierComboBox) and FLsMultiplierComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsMultiplierComboBox.Handle).Widget, @SS);
  if Assigned(FLsPacingComboBox) and FLsPacingComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsPacingComboBox.Handle).Widget, @SS);
  if Assigned(FLsGpuComboBox) and FLsGpuComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsGpuComboBox.Handle).Widget, @SS);

  // QCheckBoxes
  if IsDark then
    SS := 'QCheckBox { color: rgb(255,255,255); background-color: transparent; font-size: 13px; font-family: "Noto Sans", sans-serif; } ' +
          'QCheckBox::indicator { width: 16px; height: 16px; background-color: rgb(26,30,46); border: 1px solid rgb(120,130,160); border-radius: 3px; } ' +
          'QCheckBox::indicator:checked { background-color: rgb(48,190,240); border-color: rgb(48,190,240); }'
  else
    SS := 'QCheckBox { color: rgb(0,0,0); background-color: transparent; font-size: 13px; font-family: "Noto Sans", sans-serif; } ' +
          'QCheckBox::indicator { width: 16px; height: 16px; background-color: rgb(255,255,255); border: 1px solid rgb(180,180,180); border-radius: 3px; } ' +
          'QCheckBox::indicator:checked { background-color: rgb(0,120,215); border-color: rgb(0,120,215); }';

  if Assigned(FLsPerfModeCheckBox) and FLsPerfModeCheckBox.HandleAllocated then
  begin
    FLsPerfModeCheckBox.Font.Color := TextColor;
    QWidget_setStyleSheet(TQtWidget(FLsPerfModeCheckBox.Handle).Widget, @SS);
  end;
  if Assigned(FLsNoFp16CheckBox) and FLsNoFp16CheckBox.HandleAllocated then
  begin
    FLsNoFp16CheckBox.Font.Color := TextColor;
    QWidget_setStyleSheet(TQtWidget(FLsNoFp16CheckBox.Handle).Widget, @SS);
  end;

  // Labels color update
  if Assigned(FLsMultiplierTitleLbl) then FLsMultiplierTitleLbl.Font.Color := TextColor;
  if Assigned(FLsMultiplierDescLbl) then FLsMultiplierDescLbl.Font.Color := HintColor;
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Font.Color := TextColor;
  if Assigned(FLsFlowScaleDescLbl) then FLsFlowScaleDescLbl.Font.Color := HintColor;
  if Assigned(FLsPerfModeDescLbl) then FLsPerfModeDescLbl.Font.Color := HintColor;
  if Assigned(FLsNoFp16DescLbl) then FLsNoFp16DescLbl.Font.Color := HintColor;
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
  if IsDark then
    SS := 'QPushButton, QToolButton { background-color: rgb(38,46,72); color: rgb(255,255,255); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 3px 8px; font-weight: bold; } ' +
          'QPushButton:hover, QToolButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); } ' +
          'QPushButton:pressed, QToolButton:pressed { background-color: rgb(28,34,54); } ' +
          'QPushButton:disabled, QToolButton:disabled { background-color: rgb(28,34,54); color: rgb(100,110,130); border: 1px solid rgb(40,48,70); }'
  else
    SS := 'QPushButton, QToolButton { background-color: rgb(240,240,240); color: rgb(0,0,0); border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 3px 8px; }';

  if Assigned(FLsBrowseDllBtn) and FLsBrowseDllBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsBrowseDllBtn.Handle).Widget, @SS);
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
  FLsBgPanel.Height := 520;
  
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
  FLsDllPathEdit.TextHint := 'Path to Lossless.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll)';
  FLsDllPathEdit.OnChange := @DllPathChange;
  StyleInputControl(FLsDllPathEdit);
  
  FLsBrowseDllBtn := TBitBtn.Create(FLsGeneralCard);
  FLsBrowseDllBtn.Parent := FLsGeneralCard;
  FLsBrowseDllBtn.Caption := '📁 Browse';
  FLsBrowseDllBtn.Cursor := crHandPoint;
  FLsBrowseDllBtn.OnClick := @BrowseDllClick;
  StyleActionButton(FLsBrowseDllBtn);
  
  // ── Card 1: Frame Generation ──────────────────────────────────────────────
  FLsFrameGenCard := TPanel.Create(FForm);
  FLsFrameGenCard.Parent := FLsBgPanel;
  FLsFrameGenCard.Caption := '';
  FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsFgTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgTitleLbl.Parent := FLsFrameGenCard;
  FLsFgTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsFrameGenCard, FLsFgTitleLbl, 'Frame Generation');
  
  FLsMultiplierTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierTitleLbl.Parent := FLsFrameGenCard;
  FLsMultiplierTitleLbl.Caption := 'Multiplier (LSFGVK_MULTIPLIER)';
  StyleLabel(FLsMultiplierTitleLbl, lrControlLabel);
  
  FLsMultiplierDescLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierDescLbl.Parent := FLsFrameGenCard;
  FLsMultiplierDescLbl.Caption := 'Double, triple or quadruple your FPS output';
  StyleLabel(FLsMultiplierDescLbl, lrMutedHint);
  
  FLsMultiplierComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsMultiplierComboBox.Parent := FLsFrameGenCard;
  FLsMultiplierComboBox.Style := csDropDownList;
  FLsMultiplierComboBox.Items.Add('2x (Double FPS)');
  FLsMultiplierComboBox.Items.Add('3x (Triple FPS)');
  FLsMultiplierComboBox.Items.Add('4x (Quadruple FPS)');
  FLsMultiplierComboBox.ItemIndex := 0;
  FLsMultiplierComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsMultiplierComboBox);
  
  FLsFlowScaleTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleTitleLbl.Parent := FLsFrameGenCard;
  FLsFlowScaleTitleLbl.Caption := 'Flow Scale (LSFGVK_FLOW_SCALE)';
  StyleLabel(FLsFlowScaleTitleLbl, lrControlLabel);
  
  FLsFlowScaleDescLbl := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleDescLbl.Parent := FLsFrameGenCard;
  FLsFlowScaleDescLbl.Caption := 'Lower internal motion estimation resolution for higher speed';
  StyleLabel(FLsFlowScaleDescLbl, lrMutedHint);
  
  FLsFlowScaleTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsFlowScaleTrackBar.Parent := FLsFrameGenCard;
  FLsFlowScaleTrackBar.Min := 25;
  FLsFlowScaleTrackBar.Max := 100;
  FLsFlowScaleTrackBar.Position := 100;
  FLsFlowScaleTrackBar.TickStyle := tsNone;
  FLsFlowScaleTrackBar.OnChange := @FlowScaleChange;
  
  FLsFlowScaleValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleValueLabel.Parent := FLsFrameGenCard;
  FLsFlowScaleValueLabel.Caption := '100%';
  FLsFlowScaleValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsFlowScaleValueLabel.Font.Style := [fsBold];
  
  FLsPerfModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsPerfModeCheckBox.Parent := FLsFrameGenCard;
  FLsPerfModeCheckBox.Caption := 'Performance Mode (LSFGVK_PERFORMANCE_MODE=1)';
  FLsPerfModeCheckBox.OnChange := @ControlStateChange;
  StyleToggleControl(FLsPerfModeCheckBox);
  
  FLsPerfModeDescLbl := TLabel.Create(FLsFrameGenCard);
  FLsPerfModeDescLbl.Parent := FLsFrameGenCard;
  FLsPerfModeDescLbl.Caption := 'Massively improve generation performance at a slight cost of image quality';
  StyleLabel(FLsPerfModeDescLbl, lrMutedHint);
  
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
  FLsNoFp16CheckBox.Caption := 'Disable FP16 / Half-Precision (LSFGVK_NO_FP16=1)';
  FLsNoFp16CheckBox.OnChange := @ControlStateChange;
  StyleToggleControl(FLsNoFp16CheckBox);
  
  FLsNoFp16DescLbl := TLabel.Create(FLsHardwareCard);
  FLsNoFp16DescLbl.Parent := FLsHardwareCard;
  FLsNoFp16DescLbl.Caption := 'Disables half-precision arithmetic for compatibility with GPUs lacking FP16 speedups';
  StyleLabel(FLsNoFp16DescLbl, lrMutedHint);
  
  FLsPacingTitleLbl := TLabel.Create(FLsHardwareCard);
  FLsPacingTitleLbl.Parent := FLsHardwareCard;
  FLsPacingTitleLbl.Caption := 'Pacing Mode (LSFGVK_PACING)';
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
  FLsPacingComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsPacingComboBox);
  
  FLsGpuTitleLbl := TLabel.Create(FLsHardwareCard);
  FLsGpuTitleLbl.Parent := FLsHardwareCard;
  FLsGpuTitleLbl.Caption := 'Target GPU Device (LSFGVK_GPU)';
  StyleLabel(FLsGpuTitleLbl, lrControlLabel);
  
  FLsGpuComboBox := TComboBox.Create(FLsHardwareCard);
  FLsGpuComboBox.Parent := FLsHardwareCard;
  FLsGpuComboBox.Style := csDropDownList;
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
  W, CardW, CurY: Integer;
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
  FLsDllPathEdit.SetBounds(CARD_PAD, 34, CardW - 120, ROW_H);
  FLsBrowseDllBtn.SetBounds(CardW - 110, 34, 96, ROW_H);
  CurY := CurY + FLsGeneralCard.Height + 12;
  
  // ── Card 1 Layout: Frame Generation ───────────────────────────────────────
  FLsFrameGenCard.SetBounds(CARD_PAD, CurY, CardW, 204);
  
  FLsMultiplierTitleLbl.SetBounds(CARD_PAD, 36, 240, 18);
  FLsMultiplierDescLbl.SetBounds(CARD_PAD, 54, 280, 16);
  FLsMultiplierComboBox.SetBounds(CardW - 200, 40, 186, ROW_H);
  
  FLsFlowScaleTitleLbl.SetBounds(CARD_PAD, 86, 240, 18);
  FLsFlowScaleDescLbl.SetBounds(CARD_PAD, 104, 280, 16);
  FLsFlowScaleTrackBar.SetBounds(CardW - 260, 90, 196, ROW_H);
  FLsFlowScaleValueLabel.SetBounds(CardW - 54, 95, 48, 20);
  
  FLsPerfModeCheckBox.SetBounds(CARD_PAD, 142, CardW - (CARD_PAD * 2), 22);
  FLsPerfModeDescLbl.SetBounds(CARD_PAD + 22, 166, CardW - (CARD_PAD * 2) - 24, 18);
  CurY := CurY + FLsFrameGenCard.Height + 12;
  
  // ── Card 2 Layout: Hardware & Pacing ──────────────────────────────────────
  FLsHardwareCard.SetBounds(CARD_PAD, CurY, CardW, 168);
  
  FLsNoFp16CheckBox.SetBounds(CARD_PAD, 36, CardW - (CARD_PAD * 2), 22);
  FLsNoFp16DescLbl.SetBounds(CARD_PAD + 22, 58, CardW - (CARD_PAD * 2) - 24, 18);
  
  FLsPacingTitleLbl.SetBounds(CARD_PAD, 88, 240, 18);
  FLsPacingComboBox.SetBounds(CARD_PAD, 108, (CardW div 2) - 20, ROW_H);
  
  FLsGpuTitleLbl.SetBounds((CardW div 2) + 10, 88, 240, 18);
  FLsGpuComboBox.SetBounds((CardW div 2) + 10, 108, (CardW div 2) - 24, ROW_H);
  CurY := CurY + FLsHardwareCard.Height + CARD_PAD;
  
  FLsBgPanel.Height := CurY;
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
      SS := 'QLineEdit { background-color: rgb(24, 56, 36); color: rgb(255, 255, 255); border: 1px solid rgb(68, 204, 102); border-radius: 4px; padding: 2px 6px; selection-background-color: rgb(48, 190, 240); selection-color: rgb(0, 0, 0); } ' +
            'QLineEdit:focus { border: 1px solid rgb(90, 240, 130); }'
    else
      SS := 'QLineEdit { background-color: rgb(232, 250, 236); color: rgb(0, 80, 20); border: 1px solid rgb(46, 125, 50); border-radius: 4px; padding: 2px 6px; }';
  end
  else
  begin
    if IsDark then
      SS := 'QLineEdit { background-color: rgb(38, 46, 72); color: rgb(255, 255, 255); border: 1px solid rgb(55, 70, 108); border-radius: 4px; padding: 2px 6px; selection-background-color: rgb(48, 190, 240); selection-color: rgb(0, 0, 0); } ' +
            'QLineEdit:focus { border: 1px solid rgb(48, 190, 240); }'
    else
      SS := 'QLineEdit { background-color: rgb(255, 255, 255); color: rgb(0, 0, 0); border: 1px solid rgb(200, 200, 200); border-radius: 4px; padding: 2px 6px; }';
  end;
  QWidget_setStyleSheet(TQtWidget(FLsDllPathEdit.Handle).Widget, @SS);
end;

procedure TLosslessScalingTabHelper.DllPathChange(Sender: TObject);
begin
  UpdateDllStatus;
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
  SaveLosslessConfig;
end;

procedure TLosslessScalingTabHelper.ControlStateChange(Sender: TObject);
begin
  SaveLosslessConfig;
end;

function TLosslessScalingTabHelper.GetActiveEnvVars: string;
var
  Parts: TStringList;
  DllP: string;
  MultVal: Integer;
  FlowVal: Double;
  PacingStr: string;
begin
  Parts := TStringList.Create;
  try
    Parts.Add('LSFGVK_ENV=1');
    
    DllP := Trim(FLsDllPathEdit.Text);
    if DllP <> '' then
      Parts.Add('LSFGVK_DLL_PATH="' + DllP + '"');
      
    case FLsMultiplierComboBox.ItemIndex of
      0: MultVal := 2;
      1: MultVal := 3;
      2: MultVal := 4;
    else
      MultVal := 2;
    end;
    Parts.Add('LSFGVK_MULTIPLIER=' + IntToStr(MultVal));
    
    if FLsFlowScaleTrackBar.Position < 100 then
    begin
      FlowVal := FLsFlowScaleTrackBar.Position / 100.0;
      Parts.Add('LSFGVK_FLOW_SCALE=' + FloatToStr(FlowVal));
    end;
    
    if FLsPerfModeCheckBox.Checked then
      Parts.Add('LSFGVK_PERFORMANCE_MODE=1');
      
    if FLsNoFp16CheckBox.Checked then
      Parts.Add('LSFGVK_NO_FP16=1');
      
    case FLsPacingComboBox.ItemIndex of
      1: PacingStr := 'vsync';
      2: PacingStr := 'mailbox';
      3: PacingStr := 'immediate';
      4: PacingStr := 'none';
    else
      PacingStr := '';
    end;
    if PacingStr <> '' then
      Parts.Add('LSFGVK_PACING=' + PacingStr);
      
    if FLsGpuComboBox.ItemIndex > 0 then
      Parts.Add('LSFGVK_GPU=' + IntToStr(FLsGpuComboBox.ItemIndex - 1));
      
    Result := '';
    for MultVal := 0 to Parts.Count - 1 do
    begin
      if MultVal > 0 then Result := Result + ' ';
      Result := Result + Parts[MultVal];
    end;
  finally
    Parts.Free;
  end;
end;

procedure TLosslessScalingTabHelper.LoadLosslessConfig;
var
  Ini: TIniFile;
  CfgPath: string;
begin
  CfgPath := GetConfigFile;
  if not FileExists(CfgPath) then Exit;
  
  Ini := TIniFile.Create(CfgPath);
  try
    FLsDllPathEdit.Text := Ini.ReadString('LosslessScaling', 'DllPath', '');
    FLsMultiplierComboBox.ItemIndex := Ini.ReadInteger('LosslessScaling', 'MultiplierIndex', 0);
    FLsFlowScaleTrackBar.Position := Ini.ReadInteger('LosslessScaling', 'FlowScale', 100);
    if Assigned(FLsFlowScaleValueLabel) then
      FLsFlowScaleValueLabel.Caption := IntToStr(FLsFlowScaleTrackBar.Position) + '%';
    FLsPerfModeCheckBox.Checked := Ini.ReadBool('LosslessScaling', 'PerformanceMode', False);
    FLsNoFp16CheckBox.Checked := Ini.ReadBool('LosslessScaling', 'NoFp16', False);
    FLsPacingComboBox.ItemIndex := Ini.ReadInteger('LosslessScaling', 'PacingIndex', 0);
    FLsGpuComboBox.ItemIndex := Ini.ReadInteger('LosslessScaling', 'GpuIndex', 0);
  finally
    Ini.Free;
  end;
  
  UpdateDllStatus;
end;

procedure TLosslessScalingTabHelper.SaveLosslessConfig;
var
  Ini: TIniFile;
  CfgPath, CfgDir: string;
begin
  CfgPath := GetConfigFile;
  CfgDir := ExtractFilePath(CfgPath);
  if not DirectoryExists(CfgDir) then
    ForceDirectories(CfgDir);
    
  Ini := TIniFile.Create(CfgPath);
  try
    Ini.WriteString('LosslessScaling', 'DllPath', Trim(FLsDllPathEdit.Text));
    Ini.WriteInteger('LosslessScaling', 'MultiplierIndex', FLsMultiplierComboBox.ItemIndex);
    Ini.WriteInteger('LosslessScaling', 'FlowScale', FLsFlowScaleTrackBar.Position);
    Ini.WriteBool('LosslessScaling', 'PerformanceMode', FLsPerfModeCheckBox.Checked);
    Ini.WriteBool('LosslessScaling', 'NoFp16', FLsNoFp16CheckBox.Checked);
    Ini.WriteInteger('LosslessScaling', 'PacingIndex', FLsPacingComboBox.ItemIndex);
    Ini.WriteInteger('LosslessScaling', 'GpuIndex', FLsGpuComboBox.ItemIndex);
  finally
    Ini.Free;
  end;
end;

end.
