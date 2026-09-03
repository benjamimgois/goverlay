unit lossless_scaling_tab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls,
  Clipbrd, IniFiles, Math, themeunit, constants, hintsunit, apputils, configkeys, configmanager, systemdetector, toggle_switch;

type
  TMakoConfig = record
    Dll: string;
    AllowFp16: Boolean;
    Multiplier: Integer;
    FlowScale: Double;
    PerformanceMode: Boolean;
    UltraPerformance: Boolean;
    HdrMode: Boolean;
    FrameGenEnabled: Boolean;
    FrameGenRefreshThreshold: Integer;
    BaseFpsCap: Integer;
    Adaptive: Boolean;
    TargetFps: Integer;
    AdaptiveMaxMultiplier: Integer;
    AdaptiveAutoBaseFpsCap: Boolean;
    ScalingEnabled: Boolean;
    ScalingMethod: string;
    ScalingFactor: Double;
    ScalingSharpness: Double;
    ScalingSupersampling: Boolean;
    Pacing: string;
    Gpu: string;
  end;

procedure InitDefaultMakoConfig(out ACfg: TMakoConfig);
procedure ParseMakoToml(const AFilePath: string; out ACfg: TMakoConfig);
procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string);

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
    FLsSpatialCard: TPanel;
    
    // Card 0: MAKO Engine & LossLess Scaling
    FLsDllTitleLbl: TLabel;
    FLsLogoImage: TImage;
    FLsDllPathEdit: TEdit;
    FLsBrowseDllBtn: TBitBtn;
    FLsInspectDllBtn: TBitBtn;
    FLsDllStatusLabel: TLabel;
    
    FLsEngineStatusLabel: TLabel;
    FLsCheckUpdatesBtn: TBitBtn;
    FLsInstallBtn: TBitBtn;
    FLsProgressBar: TProgressBar;
    FLsProgressLabel: TLabel;
    
    // Card 1: Frame Generation
    FLsFgTitleLbl: TLabel;
    FLsFgModeTitleLbl: TLabel;
    FLsFgModeComboBox: TComboBox;
    
    // Mode: Fixed Multiplier
    FLsMultiplierTitleLbl: TLabel;
    FLsMultiplierTrackBar: TTrackBar;
    FLsMultiplierValueLabel: TLabel;
    
    // Mode: Adaptive Frame Generation
    FLsTargetFpsTitleLbl: TLabel;
    FLsTargetFpsTrackBar: TTrackBar;
    FLsTargetFpsValueLabel: TLabel;
    FLsAdaptiveMaxMultTitleLbl: TLabel;
    FLsAdaptiveMaxMultComboBox: TComboBox;
    FLsSteady2xCapCheckBox: TCheckBox;
    FLsSteady2xCapToggle: TToggleSwitch;
    FLsSmoothCadenceCheckBox: TCheckBox;
    FLsSmoothCadenceToggle: TToggleSwitch;
    
    // Shared FG Controls
    FLsFlowScaleTitleLbl: TLabel;
    FLsFlowScaleTrackBar: TTrackBar;
    FLsFlowScaleValueLabel: TLabel;
    FLsBaseFpsCapTitleLbl: TLabel;
    FLsBaseFpsCapTrackBar: TTrackBar;
    FLsBaseFpsCapValueLabel: TLabel;
    FLsRefreshThresholdTitleLbl: TLabel;
    FLsRefreshThresholdTrackBar: TTrackBar;
    FLsRefreshThresholdValueLabel: TLabel;
    
    // Toggles
    FLsFgLiveCheckBox: TCheckBox;
    FLsFgLiveToggle: TToggleSwitch;
    FLsAllowFp16CheckBox: TCheckBox;
    FLsAllowFp16Toggle: TToggleSwitch;
    FLsPerfModeCheckBox: TCheckBox;
    FLsPerfModeToggle: TToggleSwitch;
    FLsUltraPerfCheckBox: TCheckBox;
    FLsUltraPerfToggle: TToggleSwitch;
    FLsHdrModeCheckBox: TCheckBox;
    FLsHdrModeToggle: TToggleSwitch;
    FLsNoFp16CheckBox: TCheckBox;
    FLsNoFp16Toggle: TToggleSwitch;
    
    FLsPacingTitleLbl: TLabel;
    FLsPacingComboBox: TComboBox;
    FLsGpuTitleLbl: TLabel;
    FLsGpuComboBox: TComboBox;
    
    // Card 2: Spatial Scaling
    FLsSpatialTitleLbl: TLabel;
    FLsScalingEnableCheckBox: TCheckBox;
    FLsScalingEnableToggle: TToggleSwitch;
    FLsScalingMethodTitleLbl: TLabel;
    FLsScalingMethodComboBox: TComboBox;
    FLsScalingFactorTitleLbl: TLabel;
    FLsScalingFactorTrackBar: TTrackBar;
    FLsScalingFactorValueLabel: TLabel;
    FLsScalingSharpnessTitleLbl: TLabel;
    FLsScalingSharpnessTrackBar: TTrackBar;
    FLsScalingSharpnessValueLabel: TLabel;
    FLsScalingSupersamplingCheckBox: TCheckBox;
    FLsScalingSupersamplingToggle: TToggleSwitch;
    FCheckingUpdate: Boolean;
    
    procedure DllPathChange(Sender: TObject);
    procedure BrowseDllClick(Sender: TObject);
    procedure InspectDllClick(Sender: TObject);
    procedure CheckUpdatesClick(Sender: TObject);
    procedure InstallMakoClick(Sender: TObject);
    procedure FgModeChange(Sender: TObject);
    procedure MultiplierChange(Sender: TObject);
    procedure TargetFpsChange(Sender: TObject);
    procedure FlowScaleChange(Sender: TObject);
    procedure BaseFpsCapChange(Sender: TObject);
    procedure RefreshThresholdChange(Sender: TObject);
    procedure ScalingFactorChange(Sender: TObject);
    procedure ScalingSharpnessChange(Sender: TObject);
    procedure ControlStateChange(Sender: TObject);
    procedure LsScrollBoxResize(Sender: TObject);
    
    procedure UpdateDllStatus;
    procedure UpdateEngineStatus;
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
    function WriteMakoTomlConfig(const ATargetDir: string = ''): string;
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
    
    property FgModeComboBox: TComboBox read FLsFgModeComboBox;
    property TargetFpsTrackBar: TTrackBar read FLsTargetFpsTrackBar;
    property TargetFpsValueLabel: TLabel read FLsTargetFpsValueLabel;
    property AdaptiveMaxMultComboBox: TComboBox read FLsAdaptiveMaxMultComboBox;
    property Steady2xCapCheckBox: TCheckBox read FLsSteady2xCapCheckBox;
    property Steady2xCapToggle: TToggleSwitch read FLsSteady2xCapToggle;
    property SmoothCadenceCheckBox: TCheckBox read FLsSmoothCadenceCheckBox;
    property SmoothCadenceToggle: TToggleSwitch read FLsSmoothCadenceToggle;
    property BaseFpsCapTrackBar: TTrackBar read FLsBaseFpsCapTrackBar;
    property BaseFpsCapValueLabel: TLabel read FLsBaseFpsCapValueLabel;
    property RefreshThresholdTrackBar: TTrackBar read FLsRefreshThresholdTrackBar;
    property RefreshThresholdValueLabel: TLabel read FLsRefreshThresholdValueLabel;
    property FgLiveCheckBox: TCheckBox read FLsFgLiveCheckBox;
    property FgLiveToggle: TToggleSwitch read FLsFgLiveToggle;
    property AllowFp16CheckBox: TCheckBox read FLsAllowFp16CheckBox;
    property AllowFp16Toggle: TToggleSwitch read FLsAllowFp16Toggle;
    property UltraPerfCheckBox: TCheckBox read FLsUltraPerfCheckBox;
    property UltraPerfToggle: TToggleSwitch read FLsUltraPerfToggle;
    
    property SpatialCard: TPanel read FLsSpatialCard;
    property ScalingEnableCheckBox: TCheckBox read FLsScalingEnableCheckBox;
    property ScalingEnableToggle: TToggleSwitch read FLsScalingEnableToggle;
    property ScalingMethodComboBox: TComboBox read FLsScalingMethodComboBox;
    property ScalingFactorTrackBar: TTrackBar read FLsScalingFactorTrackBar;
    property ScalingFactorValueLabel: TLabel read FLsScalingFactorValueLabel;
    property ScalingSharpnessTrackBar: TTrackBar read FLsScalingSharpnessTrackBar;
    property ScalingSharpnessValueLabel: TLabel read FLsScalingSharpnessValueLabel;
    property ScalingSupersamplingCheckBox: TCheckBox read FLsScalingSupersamplingCheckBox;
    property ScalingSupersamplingToggle: TToggleSwitch read FLsScalingSupersamplingToggle;
    
    property EngineStatusLabel: TLabel read FLsEngineStatusLabel;
    property CheckUpdatesBtn: TBitBtn read FLsCheckUpdatesBtn;
    property InstallBtn: TBitBtn read FLsInstallBtn;
    property InspectDllBtn: TBitBtn read FLsInspectDllBtn;
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
  overlay_config,
  optiscaler_update;

const
  MARGIN   = 4;   // outer margin inside scroll box (standard across all tabs)
  GAP      = 6;   // gap between cards
  PAD      = 14;  // inner horizontal padding inside cards
  ROW_H    = 28;  // control row height

procedure InitDefaultMakoConfig(out ACfg: TMakoConfig);
begin
  ACfg.Dll := '';
  ACfg.AllowFp16 := True;
  ACfg.Multiplier := 2;
  ACfg.FlowScale := 1.00;
  ACfg.PerformanceMode := False;
  ACfg.UltraPerformance := False;
  ACfg.HdrMode := False;
  ACfg.FrameGenEnabled := True;
  ACfg.FrameGenRefreshThreshold := 0;
  ACfg.BaseFpsCap := 0;
  ACfg.Adaptive := False;
  ACfg.TargetFps := 90;
  ACfg.AdaptiveMaxMultiplier := 3;
  ACfg.AdaptiveAutoBaseFpsCap := False;
  ACfg.ScalingEnabled := False;
  ACfg.ScalingMethod := 'ls1';
  ACfg.ScalingFactor := 1.50;
  ACfg.ScalingSharpness := 0.80;
  ACfg.ScalingSupersampling := False;
  ACfg.Pacing := 'none';
  ACfg.Gpu := '';
end;

procedure ParseMakoToml(const AFilePath: string; out ACfg: TMakoConfig);
var
  Lines: TStringList;
  i, p: Integer;
  Line, Key, Val: string;
begin
  InitDefaultMakoConfig(ACfg);
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
        if (Length(Val) >= 2) and (Val[1] in ['"', '''']) and (Val[Length(Val)] in ['"', '''']) then
          Val := Copy(Val, 2, Length(Val) - 2);

        if Key = 'dll' then
        begin
          if (ACfg.Dll = '') or FileExists(Val) then
            ACfg.Dll := Val;
        end
        else if Key = 'allow_fp16' then
          ACfg.AllowFp16 := (LowerCase(Val) = 'true') or (Val = '1')
        else if (Key = 'no_fp16') or (Key = 'legacy') then
          ACfg.AllowFp16 := not ((LowerCase(Val) = 'true') or (Val = '1'))
        else if Key = 'multiplier' then
          ACfg.Multiplier := StrToIntDef(Val, ACfg.Multiplier)
        else if Key = 'flow_scale' then
          ACfg.FlowScale := StrToFloatDef(StringReplace(Val, '.', DecimalSeparator, []), ACfg.FlowScale)
        else if Key = 'performance_mode' then
          ACfg.PerformanceMode := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'ultra_performance' then
          ACfg.UltraPerformance := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'hdr_mode' then
          ACfg.HdrMode := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'frame_generation_enabled' then
          ACfg.FrameGenEnabled := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'frame_generation_refresh_threshold' then
          ACfg.FrameGenRefreshThreshold := StrToIntDef(Val, ACfg.FrameGenRefreshThreshold)
        else if Key = 'base_fps_cap' then
          ACfg.BaseFpsCap := StrToIntDef(Val, ACfg.BaseFpsCap)
        else if Key = 'adaptive' then
          ACfg.Adaptive := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'target_fps' then
          ACfg.TargetFps := StrToIntDef(Val, ACfg.TargetFps)
        else if Key = 'adaptive_max_multiplier' then
          ACfg.AdaptiveMaxMultiplier := StrToIntDef(Val, ACfg.AdaptiveMaxMultiplier)
        else if Key = 'adaptive_auto_base_fps_cap' then
          ACfg.AdaptiveAutoBaseFpsCap := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'scaling_enabled' then
          ACfg.ScalingEnabled := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'scaling_method' then
          ACfg.ScalingMethod := LowerCase(Val)
        else if Key = 'scaling_factor' then
          ACfg.ScalingFactor := StrToFloatDef(StringReplace(Val, '.', DecimalSeparator, []), ACfg.ScalingFactor)
        else if Key = 'scaling_sharpness' then
          ACfg.ScalingSharpness := StrToFloatDef(StringReplace(Val, '.', DecimalSeparator, []), ACfg.ScalingSharpness)
        else if Key = 'scaling_supersampling' then
          ACfg.ScalingSupersampling := (LowerCase(Val) = 'true') or (Val = '1')
        else if (Key = 'pacing') or (Key = 'experimental_present_mode') then
          ACfg.Pacing := LowerCase(Val);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string);
var
  Cfg: TMakoConfig;
begin
  ParseMakoToml(AFilePath, Cfg);
  ADll := Cfg.Dll;
  AMultiplier := Cfg.Multiplier;
  AFlowScale := Cfg.FlowScale;
  APerfMode := Cfg.PerformanceMode;
  AHdrMode := Cfg.HdrMode;
  ANoFp16 := not Cfg.AllowFp16;
  APacing := Cfg.Pacing;
end;

type
  TMakoInstallThread = class(TThread)
  private
    FHelper: TLosslessScalingTabHelper;
    FProgressPct: Integer;
    FProgressStatus: string;
    FSuccess: Boolean;
    procedure SyncProgress;
    procedure SyncFinished;
    procedure OnProgress(Percentage: Integer; const Status: string);
  protected
    procedure Execute; override;
  public
    constructor Create(AHelper: TLosslessScalingTabHelper);
  end;

  TMakoCheckUpdateThread = class(TThread)
  private
    FHelper: TLosslessScalingTabHelper;
    FRemoteVer: string;
    FLocalVer: string;
    procedure SyncResult;
  protected
    procedure Execute; override;
  public
    constructor Create(AHelper: TLosslessScalingTabHelper);
  end;

constructor TMakoInstallThread.Create(AHelper: TLosslessScalingTabHelper);
begin
  inherited Create(True);
  FHelper := AHelper;
  FreeOnTerminate := True;
end;

procedure TMakoInstallThread.OnProgress(Percentage: Integer; const Status: string);
begin
  FProgressPct := Percentage;
  FProgressStatus := Status;
  Synchronize(@SyncProgress);
end;

procedure TMakoInstallThread.SyncProgress;
begin
  if not Assigned(FHelper) then Exit;
  if Assigned(FHelper.FLsProgressBar) then
  begin
    FHelper.FLsProgressBar.Visible := True;
    FHelper.FLsProgressBar.Position := FProgressPct;
  end;
  if Assigned(FHelper.FLsProgressLabel) then
  begin
    FHelper.FLsProgressLabel.Visible := True;
    FHelper.FLsProgressLabel.Caption := FProgressStatus;
  end;
end;

procedure TMakoInstallThread.SyncFinished;
begin
  if not Assigned(FHelper) then Exit;
  if Assigned(FHelper.FLsProgressBar) then
    FHelper.FLsProgressBar.Visible := False;
  if Assigned(FHelper.FLsProgressLabel) then
    FHelper.FLsProgressLabel.Visible := False;
  if Assigned(FHelper.FLsInstallBtn) then
    FHelper.FLsInstallBtn.Enabled := True;
  if Assigned(FHelper.FLsCheckUpdatesBtn) then
    FHelper.FLsCheckUpdatesBtn.Enabled := True;
  FHelper.UpdateEngineStatus;
  FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
end;

procedure TMakoInstallThread.Execute;
begin
  FSuccess := CheckAndInstallMako(True, @OnProgress);
  Synchronize(@SyncFinished);
end;

constructor TMakoCheckUpdateThread.Create(AHelper: TLosslessScalingTabHelper);
begin
  inherited Create(True);
  FHelper := AHelper;
  FreeOnTerminate := True;
end;

procedure TMakoCheckUpdateThread.Execute;
var
  DummyUrl: string;
begin
  FLocalVer := GetMakoInstalledVersion;
  FRemoteVer := GetMakoLatestRemoteVersion(DummyUrl);
  Synchronize(@SyncResult);
end;

procedure TMakoCheckUpdateThread.SyncResult;
begin
  if not Assigned(FHelper) then Exit;
  FHelper.FCheckingUpdate := False;
  if (FRemoteVer <> '') and (FLocalVer <> '') and (FRemoteVer <> FLocalVer) then
  begin
    if Assigned(FHelper.FLsEngineStatusLabel) then
    begin
      FHelper.FLsEngineStatusLabel.Caption := '▲ Update available: ' + FRemoteVer + ' (Current: ' + FLocalVer + ')';
      FHelper.FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;
    end;
    if Assigned(FHelper.FLsInstallBtn) then
    begin
      FHelper.FLsInstallBtn.Caption := 'Install update';
      FHelper.FLsInstallBtn.Visible := True;
      FHelper.FLsInstallBtn.Enabled := True;
    end;
    FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
  end;
end;

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

  // Cards
  if Assigned(FLsGeneralCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsGeneralCard);
  if Assigned(FLsFrameGenCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsFrameGenCard);
  if Assigned(FLsSpatialCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsSpatialCard);

  // QLineEdit & DLL Status styling
  UpdateDllStatus;

  // QComboBoxes
  SS := GetComboBoxStyleSheet(IsDark);
  if Assigned(FLsFgModeComboBox) and FLsFgModeComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsFgModeComboBox.Handle).Widget, @SS);
  if Assigned(FLsAdaptiveMaxMultComboBox) and FLsAdaptiveMaxMultComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsAdaptiveMaxMultComboBox.Handle).Widget, @SS);
  if Assigned(FLsPacingComboBox) and FLsPacingComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsPacingComboBox.Handle).Widget, @SS);
  if Assigned(FLsGpuComboBox) and FLsGpuComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsGpuComboBox.Handle).Widget, @SS);
  if Assigned(FLsScalingMethodComboBox) and FLsScalingMethodComboBox.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsScalingMethodComboBox.Handle).Widget, @SS);

  // Labels color update
  if Assigned(FLsFgModeTitleLbl) then FLsFgModeTitleLbl.Font.Color := TextColor;
  if Assigned(FLsMultiplierTitleLbl) then FLsMultiplierTitleLbl.Font.Color := TextColor;
  if Assigned(FLsTargetFpsTitleLbl) then FLsTargetFpsTitleLbl.Font.Color := TextColor;
  if Assigned(FLsAdaptiveMaxMultTitleLbl) then FLsAdaptiveMaxMultTitleLbl.Font.Color := TextColor;
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Font.Color := TextColor;
  if Assigned(FLsBaseFpsCapTitleLbl) then FLsBaseFpsCapTitleLbl.Font.Color := TextColor;
  if Assigned(FLsRefreshThresholdTitleLbl) then FLsRefreshThresholdTitleLbl.Font.Color := TextColor;
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Font.Color := TextColor;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Font.Color := TextColor;
  if Assigned(FLsScalingMethodTitleLbl) then FLsScalingMethodTitleLbl.Font.Color := TextColor;
  if Assigned(FLsScalingFactorTitleLbl) then FLsScalingFactorTitleLbl.Font.Color := TextColor;
  if Assigned(FLsScalingSharpnessTitleLbl) then FLsScalingSharpnessTitleLbl.Font.Color := TextColor;

  if Assigned(FLsMultiplierValueLabel) then FLsMultiplierValueLabel.Font.Color := AccentColor;
  if Assigned(FLsTargetFpsValueLabel) then FLsTargetFpsValueLabel.Font.Color := AccentColor;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Font.Color := AccentColor;
  if Assigned(FLsBaseFpsCapValueLabel) then FLsBaseFpsCapValueLabel.Font.Color := AccentColor;
  if Assigned(FLsRefreshThresholdValueLabel) then FLsRefreshThresholdValueLabel.Font.Color := AccentColor;
  if Assigned(FLsScalingFactorValueLabel) then FLsScalingFactorValueLabel.Font.Color := AccentColor;
  if Assigned(FLsScalingSharpnessValueLabel) then FLsScalingSharpnessValueLabel.Font.Color := AccentColor;

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
  if Assigned(FLsTargetFpsTrackBar) and FLsTargetFpsTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsTargetFpsTrackBar.Handle).Widget, @SS);
  if Assigned(FLsFlowScaleTrackBar) and FLsFlowScaleTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsFlowScaleTrackBar.Handle).Widget, @SS);
  if Assigned(FLsBaseFpsCapTrackBar) and FLsBaseFpsCapTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsBaseFpsCapTrackBar.Handle).Widget, @SS);
  if Assigned(FLsRefreshThresholdTrackBar) and FLsRefreshThresholdTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsRefreshThresholdTrackBar.Handle).Widget, @SS);
  if Assigned(FLsScalingFactorTrackBar) and FLsScalingFactorTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsScalingFactorTrackBar.Handle).Widget, @SS);
  if Assigned(FLsScalingSharpnessTrackBar) and FLsScalingSharpnessTrackBar.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsScalingSharpnessTrackBar.Handle).Widget, @SS);

  // Action Buttons
  if IsDark then
    SS := 'QPushButton, QToolButton { background-color: rgb(38,46,72); color: rgb(220,225,240); border: 1px solid rgb(55,70,108); border-radius: 4px; padding: 2px 8px; font-weight: bold; } ' +
          'QPushButton:hover, QToolButton:hover { background-color: rgb(50,62,96); border: 1px solid rgb(80,110,170); color: rgb(255,255,255); } ' +
          'QPushButton:pressed, QToolButton:pressed { background-color: rgb(28,34,54); } ' +
          'QPushButton:disabled, QToolButton:disabled { background-color: rgb(28,34,54); border: 1px solid rgb(40,48,70); color: rgb(120,125,140); }'
  else
    SS := 'QPushButton, QToolButton { background-color: rgb(240,240,240); color: rgb(20,20,20); border: 1px solid rgb(200,200,200); border-radius: 4px; padding: 2px 8px; font-weight: bold; } ' +
          'QPushButton:hover, QToolButton:hover { background-color: rgb(225,225,225); border: 1px solid rgb(160,160,160); }';

  if Assigned(FLsBrowseDllBtn) and FLsBrowseDllBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsBrowseDllBtn.Handle).Widget, @SS);
  if Assigned(FLsInspectDllBtn) and FLsInspectDllBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsInspectDllBtn.Handle).Widget, @SS);
  if Assigned(FLsCheckUpdatesBtn) and FLsCheckUpdatesBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsCheckUpdatesBtn.Handle).Widget, @SS);
  if Assigned(FLsInstallBtn) and FLsInstallBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsInstallBtn.Handle).Widget, @SS);
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
  FLsBgPanel.Height := 620;
  
  // ── Card 0: MAKO Engine & LossLess Scaling ────────────────────────────────
  FLsGeneralCard := TPanel.Create(FForm);
  FLsGeneralCard.Parent := FLsBgPanel;
  FLsGeneralCard.Caption := '';
  FLsGeneralCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsDllTitleLbl := TLabel.Create(FLsGeneralCard);
  FLsDllTitleLbl.Parent := FLsGeneralCard;
  FLsDllTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsGeneralCard, FLsDllTitleLbl, 'Lossless Scaling (MAKO)');
  
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

  FLsInspectDllBtn := TBitBtn.Create(FLsGeneralCard);
  FLsInspectDllBtn.Parent := FLsGeneralCard;
  FLsInspectDllBtn.Caption := 'Inspect';
  FLsInspectDllBtn.Cursor := crHandPoint;
  FLsInspectDllBtn.OnClick := @InspectDllClick;
  StyleActionButton(FLsInspectDllBtn);
  
  FLsDllStatusLabel := TLabel.Create(FLsGeneralCard);
  FLsDllStatusLabel.Parent := FLsGeneralCard;
  FLsDllStatusLabel.Caption := '● DLL file located';
  FLsDllStatusLabel.Font.Style := [fsBold];
  FLsDllStatusLabel.Font.Size := 9;
  FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;

  FLsEngineStatusLabel := TLabel.Create(FLsGeneralCard);
  FLsEngineStatusLabel.Parent := FLsGeneralCard;
  FLsEngineStatusLabel.Caption := '● Checking MAKO Renderer...';
  FLsEngineStatusLabel.Font.Style := [fsBold];
  FLsEngineStatusLabel.Font.Size := 9;
  FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;

  FLsCheckUpdatesBtn := TBitBtn.Create(FLsGeneralCard);
  FLsCheckUpdatesBtn.Parent := FLsGeneralCard;
  FLsCheckUpdatesBtn.Caption := 'Check Updates';
  FLsCheckUpdatesBtn.Cursor := crHandPoint;
  FLsCheckUpdatesBtn.OnClick := @CheckUpdatesClick;
  FLsCheckUpdatesBtn.Visible := False;
  StyleActionButton(FLsCheckUpdatesBtn);

  FLsInstallBtn := TBitBtn.Create(FLsGeneralCard);
  FLsInstallBtn.Parent := FLsGeneralCard;
  FLsInstallBtn.Caption := 'Install MAKO';
  FLsInstallBtn.Cursor := crHandPoint;
  FLsInstallBtn.OnClick := @InstallMakoClick;
  FLsInstallBtn.Visible := False;
  StyleActionButton(FLsInstallBtn);

  FLsProgressBar := TProgressBar.Create(FLsGeneralCard);
  FLsProgressBar.Parent := FLsGeneralCard;
  FLsProgressBar.Min := 0;
  FLsProgressBar.Max := 100;
  FLsProgressBar.Position := 0;
  FLsProgressBar.Visible := False;

  FLsProgressLabel := TLabel.Create(FLsGeneralCard);
  FLsProgressLabel.Parent := FLsGeneralCard;
  FLsProgressLabel.Caption := '';
  FLsProgressLabel.Font.Size := 9;
  FLsProgressLabel.Font.Color := CLR_TEXT_MUTED;
  FLsProgressLabel.Visible := False;
  
  // ── Card 1: Frame Generation ──────────────────────────────────────────────
  FLsFrameGenCard := TPanel.Create(FForm);
  FLsFrameGenCard.Parent := FLsBgPanel;
  FLsFrameGenCard.Caption := '';
  FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsFgTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgTitleLbl.Parent := FLsFrameGenCard;
  FLsFgTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsFrameGenCard, FLsFgTitleLbl, 'Frame Generation');

  // Mode Selection
  FLsFgModeTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgModeTitleLbl.Parent := FLsFrameGenCard;
  FLsFgModeTitleLbl.Caption := 'Frame Generation Mode';
  FLsFgModeTitleLbl.Hint := 'Choose between Fixed Multiplier (2x-5x) or Adaptive Frame Generation';
  FLsFgModeTitleLbl.ShowHint := True;
  StyleLabel(FLsFgModeTitleLbl, lrControlLabel);

  FLsFgModeComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsFgModeComboBox.Parent := FLsFrameGenCard;
  FLsFgModeComboBox.Style := csDropDownList;
  FLsFgModeComboBox.Items.Add('Fixed Multiplier (Standard)');
  FLsFgModeComboBox.Items.Add('Adaptive Frame Generation (Dynamic Multiplier)');
  FLsFgModeComboBox.ItemIndex := 0;
  FLsFgModeComboBox.OnChange := @FgModeChange;
  StyleInputControl(FLsFgModeComboBox);
  
  // Fixed Multiplier Sliders
  FLsMultiplierTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierTitleLbl.Parent := FLsFrameGenCard;
  FLsMultiplierTitleLbl.Caption := 'Multiplier';
  FLsMultiplierTitleLbl.Hint := 'Frame generation multiplier: 1x (disabled), 2x, 3x, 4x, 5x';
  FLsMultiplierTitleLbl.ShowHint := True;
  StyleLabel(FLsMultiplierTitleLbl, lrControlLabel);
  
  FLsMultiplierTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsMultiplierTrackBar.Parent := FLsFrameGenCard;
  FLsMultiplierTrackBar.Min := 1;
  FLsMultiplierTrackBar.Max := 5;
  FLsMultiplierTrackBar.Position := 1;
  FLsMultiplierTrackBar.TickStyle := tsNone;
  FLsMultiplierTrackBar.Hint := 'Frame generation multiplier: 1x (disabled), 2x, 3x, 4x, 5x';
  FLsMultiplierTrackBar.ShowHint := True;
  FLsMultiplierTrackBar.OnChange := @MultiplierChange;
  
  FLsMultiplierValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierValueLabel.Parent := FLsFrameGenCard;
  FLsMultiplierValueLabel.Caption := '1x (Disabled)';
  FLsMultiplierValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsMultiplierValueLabel.Font.Style := [fsBold];

  // Adaptive Controls
  FLsTargetFpsTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsTargetFpsTitleLbl.Parent := FLsFrameGenCard;
  FLsTargetFpsTitleLbl.Caption := 'Target FPS';
  FLsTargetFpsTitleLbl.Hint := 'Dynamic multiplier targets this framerate based on input FPS (30 - 240 FPS)';
  FLsTargetFpsTitleLbl.ShowHint := True;
  FLsTargetFpsTitleLbl.Visible := False;
  StyleLabel(FLsTargetFpsTitleLbl, lrControlLabel);

  FLsTargetFpsTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsTargetFpsTrackBar.Parent := FLsFrameGenCard;
  FLsTargetFpsTrackBar.Min := 30;
  FLsTargetFpsTrackBar.Max := 240;
  FLsTargetFpsTrackBar.Position := 90;
  FLsTargetFpsTrackBar.TickStyle := tsNone;
  FLsTargetFpsTrackBar.Hint := 'Dynamic multiplier targets this framerate based on input FPS';
  FLsTargetFpsTrackBar.ShowHint := True;
  FLsTargetFpsTrackBar.Visible := False;
  FLsTargetFpsTrackBar.OnChange := @TargetFpsChange;

  FLsTargetFpsValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsTargetFpsValueLabel.Parent := FLsFrameGenCard;
  FLsTargetFpsValueLabel.Caption := '90 FPS';
  FLsTargetFpsValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsTargetFpsValueLabel.Font.Style := [fsBold];
  FLsTargetFpsValueLabel.Visible := False;

  FLsAdaptiveMaxMultTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsAdaptiveMaxMultTitleLbl.Parent := FLsFrameGenCard;
  FLsAdaptiveMaxMultTitleLbl.Caption := 'Max Multiplier Ceiling';
  FLsAdaptiveMaxMultTitleLbl.Hint := 'Maximum multiplier allowed in adaptive mode';
  FLsAdaptiveMaxMultTitleLbl.ShowHint := True;
  FLsAdaptiveMaxMultTitleLbl.Visible := False;
  StyleLabel(FLsAdaptiveMaxMultTitleLbl, lrControlLabel);

  FLsAdaptiveMaxMultComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsAdaptiveMaxMultComboBox.Parent := FLsFrameGenCard;
  FLsAdaptiveMaxMultComboBox.Style := csDropDownList;
  FLsAdaptiveMaxMultComboBox.Items.Add('2x Max');
  FLsAdaptiveMaxMultComboBox.Items.Add('3x Max (Balanced)');
  FLsAdaptiveMaxMultComboBox.Items.Add('4x Max');
  FLsAdaptiveMaxMultComboBox.Items.Add('5x Max');
  FLsAdaptiveMaxMultComboBox.ItemIndex := 1;
  FLsAdaptiveMaxMultComboBox.OnChange := @ControlStateChange;
  FLsAdaptiveMaxMultComboBox.Visible := False;
  StyleInputControl(FLsAdaptiveMaxMultComboBox);

  FLsSteady2xCapCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsSteady2xCapCheckBox.Parent := FLsFrameGenCard;
  FLsSteady2xCapCheckBox.ParentColor := True;
  FLsSteady2xCapCheckBox.Caption := 'Steady 2x Base FPS Cap';
  FLsSteady2xCapCheckBox.Hint := 'Prevents multiplier churning between 1x and 2x by enforcing target/2 base cap';
  FLsSteady2xCapCheckBox.ShowHint := True;
  FLsSteady2xCapCheckBox.OnChange := @ControlStateChange;
  FLsSteady2xCapCheckBox.Visible := False;

  FLsSteady2xCapToggle := TToggleSwitch.Create(FForm);
  FLsSteady2xCapToggle.Parent := FLsFrameGenCard;
  FLsSteady2xCapToggle.LinkToCheckBox(FLsSteady2xCapCheckBox);
  FLsSteady2xCapToggle.Height := 20;
  FLsSteady2xCapToggle.Width := FLsSteady2xCapToggle.GetOptimalWidth;
  FLsSteady2xCapToggle.Visible := False;

  FLsSmoothCadenceCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsSmoothCadenceCheckBox.Parent := FLsFrameGenCard;
  FLsSmoothCadenceCheckBox.ParentColor := True;
  FLsSmoothCadenceCheckBox.Caption := 'Smooth Cadence';
  FLsSmoothCadenceCheckBox.Hint := 'Smooth transitions during multiplier switching';
  FLsSmoothCadenceCheckBox.ShowHint := True;
  FLsSmoothCadenceCheckBox.OnChange := @ControlStateChange;
  FLsSmoothCadenceCheckBox.Visible := False;

  FLsSmoothCadenceToggle := TToggleSwitch.Create(FForm);
  FLsSmoothCadenceToggle.Parent := FLsFrameGenCard;
  FLsSmoothCadenceToggle.LinkToCheckBox(FLsSmoothCadenceCheckBox);
  FLsSmoothCadenceToggle.Height := 20;
  FLsSmoothCadenceToggle.Width := FLsSmoothCadenceToggle.GetOptimalWidth;
  FLsSmoothCadenceToggle.Visible := False;
  
  // Flow Scale
  FLsFlowScaleTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleTitleLbl.Parent := FLsFrameGenCard;
  FLsFlowScaleTitleLbl.Caption := 'Flow Scale';
  FLsFlowScaleTitleLbl.Hint := 'Motion estimation resolution scale (default 90% recommended by MAKO)';
  FLsFlowScaleTitleLbl.ShowHint := True;
  StyleLabel(FLsFlowScaleTitleLbl, lrControlLabel);
  
  FLsFlowScaleTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsFlowScaleTrackBar.Parent := FLsFrameGenCard;
  FLsFlowScaleTrackBar.Min := 25;
  FLsFlowScaleTrackBar.Max := 100;
  FLsFlowScaleTrackBar.Position := 100;
  FLsFlowScaleTrackBar.TickStyle := tsNone;
  FLsFlowScaleTrackBar.Hint := 'Motion estimation resolution scale';
  FLsFlowScaleTrackBar.ShowHint := True;
  FLsFlowScaleTrackBar.OnChange := @FlowScaleChange;
  
  FLsFlowScaleValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleValueLabel.Parent := FLsFrameGenCard;
  FLsFlowScaleValueLabel.Caption := '100%';
  FLsFlowScaleValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsFlowScaleValueLabel.Font.Style := [fsBold];

  // Base FPS Cap
  FLsBaseFpsCapTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsBaseFpsCapTitleLbl.Parent := FLsFrameGenCard;
  FLsBaseFpsCapTitleLbl.Caption := 'Base FPS Cap';
  FLsBaseFpsCapTitleLbl.Hint := 'Limits the game''s native base framerate before interpolation to maintain steady pacing and GPU headroom (0 = Disabled / Uncapped)';
  FLsBaseFpsCapTitleLbl.ShowHint := True;
  StyleLabel(FLsBaseFpsCapTitleLbl, lrControlLabel);

  FLsBaseFpsCapTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsBaseFpsCapTrackBar.Parent := FLsFrameGenCard;
  FLsBaseFpsCapTrackBar.Min := 0;
  FLsBaseFpsCapTrackBar.Max := 240;
  FLsBaseFpsCapTrackBar.Position := 0;
  FLsBaseFpsCapTrackBar.TickStyle := tsNone;
  FLsBaseFpsCapTrackBar.Hint := 'Limits the game''s native base framerate before interpolation to maintain steady pacing and GPU headroom (0 = Disabled / Uncapped)';
  FLsBaseFpsCapTrackBar.ShowHint := True;
  FLsBaseFpsCapTrackBar.OnChange := @BaseFpsCapChange;

  FLsBaseFpsCapValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsBaseFpsCapValueLabel.Parent := FLsFrameGenCard;
  FLsBaseFpsCapValueLabel.Caption := 'Disabled';
  FLsBaseFpsCapValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsBaseFpsCapValueLabel.Font.Style := [fsBold];

  // Refresh Threshold
  FLsRefreshThresholdTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsRefreshThresholdTitleLbl.Parent := FLsFrameGenCard;
  FLsRefreshThresholdTitleLbl.Caption := 'Refresh Threshold';
  FLsRefreshThresholdTitleLbl.Hint := 'Minimum display refresh rate (Hz) required to engage frame generation. Automatically bypasses frame generation if your monitor refresh rate is below this threshold (0 = Disabled / Always active)';
  FLsRefreshThresholdTitleLbl.ShowHint := True;
  StyleLabel(FLsRefreshThresholdTitleLbl, lrControlLabel);

  FLsRefreshThresholdTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsRefreshThresholdTrackBar.Parent := FLsFrameGenCard;
  FLsRefreshThresholdTrackBar.Min := 0;
  FLsRefreshThresholdTrackBar.Max := 240;
  FLsRefreshThresholdTrackBar.Position := 0;
  FLsRefreshThresholdTrackBar.TickStyle := tsNone;
  FLsRefreshThresholdTrackBar.Hint := 'Minimum display refresh rate (Hz) required to engage frame generation. Automatically bypasses frame generation if your monitor refresh rate is below this threshold (0 = Disabled / Always active)';
  FLsRefreshThresholdTrackBar.ShowHint := True;
  FLsRefreshThresholdTrackBar.OnChange := @RefreshThresholdChange;

  FLsRefreshThresholdValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsRefreshThresholdValueLabel.Parent := FLsFrameGenCard;
  FLsRefreshThresholdValueLabel.Caption := 'Disabled';
  FLsRefreshThresholdValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsRefreshThresholdValueLabel.Font.Style := [fsBold];
  
  // Toggles
  FLsFgLiveCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsFgLiveCheckBox.Parent := FLsFrameGenCard;
  FLsFgLiveCheckBox.ParentColor := True;
  FLsFgLiveCheckBox.Caption := 'Live FG Switch';
  FLsFgLiveCheckBox.Hint := 'Toggle frame generation runtime activation';
  FLsFgLiveCheckBox.ShowHint := True;
  FLsFgLiveCheckBox.OnChange := @ControlStateChange;
  FLsFgLiveCheckBox.Visible := False;

  FLsFgLiveToggle := TToggleSwitch.Create(FForm);
  FLsFgLiveToggle.Parent := FLsFrameGenCard;
  FLsFgLiveToggle.LinkToCheckBox(FLsFgLiveCheckBox);
  FLsFgLiveToggle.Height := 20;
  FLsFgLiveToggle.Width := FLsFgLiveToggle.GetOptimalWidth;

  FLsAllowFp16CheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsAllowFp16CheckBox.Parent := FLsFrameGenCard;
  FLsAllowFp16CheckBox.ParentColor := True;
  FLsAllowFp16CheckBox.Caption := 'FP16 Acceleration';
  FLsAllowFp16CheckBox.Hint := 'Uses 16-bit half-precision math for frame generation. Recommended ON for AMD GPUs (significant performance uplift), but recommended OFF for NVIDIA GPUs.';
  FLsAllowFp16CheckBox.ShowHint := True;
  FLsAllowFp16CheckBox.OnChange := @ControlStateChange;
  FLsAllowFp16CheckBox.Visible := False;

  FLsAllowFp16Toggle := TToggleSwitch.Create(FForm);
  FLsAllowFp16Toggle.Parent := FLsFrameGenCard;
  FLsAllowFp16Toggle.LinkToCheckBox(FLsAllowFp16CheckBox);
  FLsAllowFp16Toggle.Height := 20;
  FLsAllowFp16Toggle.Width := FLsAllowFp16Toggle.GetOptimalWidth;

  FLsPerfModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsPerfModeCheckBox.Parent := FLsFrameGenCard;
  FLsPerfModeCheckBox.ParentColor := True;
  FLsPerfModeCheckBox.Caption := 'Performance Mode';
  FLsPerfModeCheckBox.Hint := 'Switches to the lighter LSFG neural network model, reducing GPU render time by 30-40% with minimal image quality loss. Recommended if the game is GPU-bound.';
  FLsPerfModeCheckBox.ShowHint := True;
  FLsPerfModeCheckBox.OnChange := @ControlStateChange;
  FLsPerfModeCheckBox.Visible := False;
  
  FLsPerfModeToggle := TToggleSwitch.Create(FForm);
  FLsPerfModeToggle.Parent := FLsFrameGenCard;
  FLsPerfModeToggle.LinkToCheckBox(FLsPerfModeCheckBox);
  FLsPerfModeToggle.Height := 20;
  FLsPerfModeToggle.Width  := FLsPerfModeToggle.GetOptimalWidth;

  FLsUltraPerfCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsUltraPerfCheckBox.Parent := FLsFrameGenCard;
  FLsUltraPerfCheckBox.ParentColor := True;
  FLsUltraPerfCheckBox.Caption := 'Ultra Performance';
  FLsUltraPerfCheckBox.Hint := 'Aggressive Vulkan compute optimizations (downsamples optical flow vectors and skips high-precision passes). Maximizes FPS on low-end GPUs or handhelds, but may introduce visual artifacts.';
  FLsUltraPerfCheckBox.ShowHint := True;
  FLsUltraPerfCheckBox.OnChange := @ControlStateChange;
  FLsUltraPerfCheckBox.Visible := False;

  FLsUltraPerfToggle := TToggleSwitch.Create(FForm);
  FLsUltraPerfToggle.Parent := FLsFrameGenCard;
  FLsUltraPerfToggle.LinkToCheckBox(FLsUltraPerfCheckBox);
  FLsUltraPerfToggle.Height := 20;
  FLsUltraPerfToggle.Width := FLsUltraPerfToggle.GetOptimalWidth;

  // Compatibility Toggles for Tests
  FLsHdrModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsHdrModeCheckBox.Parent := FLsFrameGenCard;
  FLsHdrModeCheckBox.Caption := 'HDR Mode';
  FLsHdrModeCheckBox.Visible := False;
  FLsHdrModeToggle := TToggleSwitch.Create(FForm);
  FLsHdrModeToggle.Parent := FLsFrameGenCard;
  FLsHdrModeToggle.LinkToCheckBox(FLsHdrModeCheckBox);
  FLsHdrModeToggle.Visible := False;

  FLsNoFp16CheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsNoFp16CheckBox.Parent := FLsFrameGenCard;
  FLsNoFp16CheckBox.Caption := 'Disable FP16 / Half-Precision';
  FLsNoFp16CheckBox.Hint := 'Has a giant performance uplift on AMD GPUs.';
  FLsNoFp16CheckBox.OnChange := @ControlStateChange;
  FLsNoFp16CheckBox.Visible := False;
  FLsNoFp16Toggle := TToggleSwitch.Create(FForm);
  FLsNoFp16Toggle.Parent := FLsFrameGenCard;
  FLsNoFp16Toggle.LinkToCheckBox(FLsNoFp16CheckBox);
  FLsNoFp16Toggle.Visible := False;

  // Dropdowns (Pacing & GPU)
  FLsPacingTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsPacingTitleLbl.Parent := FLsFrameGenCard;
  FLsPacingTitleLbl.Caption := 'Pacing Mode';
  FLsPacingTitleLbl.Hint := 'Frame pacing mode to use';
  FLsPacingTitleLbl.ShowHint := True;
  StyleLabel(FLsPacingTitleLbl, lrControlLabel);
  
  FLsPacingComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsPacingComboBox.Parent := FLsFrameGenCard;
  FLsPacingComboBox.Style := csDropDownList;
  FLsPacingComboBox.Items.Add('none (Default / Recommended by MAKO)');
  FLsPacingComboBox.Items.Add('vsync (Standard VSync)');
  FLsPacingComboBox.Items.Add('mailbox (Fast VSync)');
  FLsPacingComboBox.Items.Add('immediate (Uncapped)');
  FLsPacingComboBox.ItemIndex := 0;
  FLsPacingComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsPacingComboBox);
  
  FLsGpuTitleLbl := TLabel.Create(FLsGeneralCard);
  FLsGpuTitleLbl.Parent := FLsGeneralCard;
  FLsGpuTitleLbl.Caption := 'Target GPU Device';
  FLsGpuTitleLbl.Hint := 'Target GPU device to use for frame generation and upscaling';
  FLsGpuTitleLbl.ShowHint := True;
  StyleLabel(FLsGpuTitleLbl, lrControlLabel);
  
  FLsGpuComboBox := TComboBox.Create(FLsGeneralCard);
  FLsGpuComboBox.Parent := FLsGeneralCard;
  FLsGpuComboBox.Style := csDropDownList;
  FLsGpuComboBox.Hint := 'Target GPU device to use for frame generation and upscaling';
  FLsGpuComboBox.ShowHint := True;
  FLsGpuComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsGpuComboBox);
  PopulateGpuList;

  // ── Card 2: Spatial Scaling ───────────────────────────────────────────────
  FLsSpatialCard := TPanel.Create(FForm);
  FLsSpatialCard.Parent := FLsBgPanel;
  FLsSpatialCard.Caption := '';
  FLsSpatialCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsSpatialTitleLbl := TLabel.Create(FLsSpatialCard);
  FLsSpatialTitleLbl.Parent := FLsSpatialCard;
  FLsSpatialTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsSpatialCard, FLsSpatialTitleLbl, 'Spatial Scaling');

  FLsScalingEnableCheckBox := TCheckBox.Create(FLsSpatialCard);
  FLsScalingEnableCheckBox.Parent := FLsSpatialCard;
  FLsScalingEnableCheckBox.ParentColor := True;
  FLsScalingEnableCheckBox.Caption := 'Enable Spatial Scaling';
  FLsScalingEnableCheckBox.Hint := 'Upscale the game resolution before frame generation';
  FLsScalingEnableCheckBox.ShowHint := True;
  FLsScalingEnableCheckBox.OnChange := @ControlStateChange;
  FLsScalingEnableCheckBox.Visible := False;

  FLsScalingEnableToggle := TToggleSwitch.Create(FForm);
  FLsScalingEnableToggle.Parent := FLsSpatialCard;
  FLsScalingEnableToggle.LinkToCheckBox(FLsScalingEnableCheckBox);
  FLsScalingEnableToggle.Height := 20;
  FLsScalingEnableToggle.Width := FLsScalingEnableToggle.GetOptimalWidth;
  FLsScalingEnableToggle.Visible := False;

  FLsScalingMethodTitleLbl := TLabel.Create(FLsSpatialCard);
  FLsScalingMethodTitleLbl.Parent := FLsSpatialCard;
  FLsScalingMethodTitleLbl.Caption := 'Scaling Method';
  FLsScalingMethodTitleLbl.Hint := 'Upscaling algorithm (LS1 requires Lossless.dll)';
  FLsScalingMethodTitleLbl.ShowHint := True;
  StyleLabel(FLsScalingMethodTitleLbl, lrControlLabel);

  FLsScalingMethodComboBox := TComboBox.Create(FLsSpatialCard);
  FLsScalingMethodComboBox.Parent := FLsSpatialCard;
  FLsScalingMethodComboBox.Style := csDropDownList;
  FLsScalingMethodComboBox.Items.Add('No upscaling (Disabled)');
  FLsScalingMethodComboBox.Items.Add('ls1 (LS1 Quality - AI)');
  FLsScalingMethodComboBox.Items.Add('ls1-performance (LS1 Performance - AI)');
  FLsScalingMethodComboBox.Items.Add('mako (MAKO Scaler - Fast Single-Pass)');
  FLsScalingMethodComboBox.Items.Add('native (Native Resolution Pass-through)');
  FLsScalingMethodComboBox.ItemIndex := 0;
  FLsScalingMethodComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsScalingMethodComboBox);

  FLsScalingFactorTitleLbl := TLabel.Create(FLsSpatialCard);
  FLsScalingFactorTitleLbl.Parent := FLsSpatialCard;
  FLsScalingFactorTitleLbl.Caption := 'Scaling Factor';
  FLsScalingFactorTitleLbl.Hint := 'Resolution scale factor: 1.00x to 2.00x';
  FLsScalingFactorTitleLbl.ShowHint := True;
  StyleLabel(FLsScalingFactorTitleLbl, lrControlLabel);

  FLsScalingFactorTrackBar := TTrackBar.Create(FLsSpatialCard);
  FLsScalingFactorTrackBar.Parent := FLsSpatialCard;
  FLsScalingFactorTrackBar.Min := 100;
  FLsScalingFactorTrackBar.Max := 200;
  FLsScalingFactorTrackBar.Position := 150;
  FLsScalingFactorTrackBar.TickStyle := tsNone;
  FLsScalingFactorTrackBar.Hint := 'Scale factor: 1.00x to 2.00x';
  FLsScalingFactorTrackBar.ShowHint := True;
  FLsScalingFactorTrackBar.OnChange := @ScalingFactorChange;

  FLsScalingFactorValueLabel := TLabel.Create(FLsSpatialCard);
  FLsScalingFactorValueLabel.Parent := FLsSpatialCard;
  FLsScalingFactorValueLabel.Caption := '1.50x';
  FLsScalingFactorValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsScalingFactorValueLabel.Font.Style := [fsBold];

  FLsScalingSharpnessTitleLbl := TLabel.Create(FLsSpatialCard);
  FLsScalingSharpnessTitleLbl.Parent := FLsSpatialCard;
  FLsScalingSharpnessTitleLbl.Caption := 'Sharpness';
  FLsScalingSharpnessTitleLbl.Hint := 'Post-upscale sharpening amount (0.00 to 1.00)';
  FLsScalingSharpnessTitleLbl.ShowHint := True;
  StyleLabel(FLsScalingSharpnessTitleLbl, lrControlLabel);

  FLsScalingSharpnessTrackBar := TTrackBar.Create(FLsSpatialCard);
  FLsScalingSharpnessTrackBar.Parent := FLsSpatialCard;
  FLsScalingSharpnessTrackBar.Min := 0;
  FLsScalingSharpnessTrackBar.Max := 100;
  FLsScalingSharpnessTrackBar.Position := 80;
  FLsScalingSharpnessTrackBar.TickStyle := tsNone;
  FLsScalingSharpnessTrackBar.Hint := 'Sharpness amount';
  FLsScalingSharpnessTrackBar.ShowHint := True;
  FLsScalingSharpnessTrackBar.OnChange := @ScalingSharpnessChange;

  FLsScalingSharpnessValueLabel := TLabel.Create(FLsSpatialCard);
  FLsScalingSharpnessValueLabel.Parent := FLsSpatialCard;
  FLsScalingSharpnessValueLabel.Caption := '0.80';
  FLsScalingSharpnessValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsScalingSharpnessValueLabel.Font.Style := [fsBold];

  FLsScalingSupersamplingCheckBox := TCheckBox.Create(FLsSpatialCard);
  FLsScalingSupersamplingCheckBox.Parent := FLsSpatialCard;
  FLsScalingSupersamplingCheckBox.ParentColor := True;
  FLsScalingSupersamplingCheckBox.Caption := 'Quality Supersampling';
  FLsScalingSupersamplingCheckBox.Hint := 'Enhance edge anti-aliasing during upscaling';
  FLsScalingSupersamplingCheckBox.ShowHint := True;
  FLsScalingSupersamplingCheckBox.OnChange := @ControlStateChange;
  FLsScalingSupersamplingCheckBox.Visible := False;

  FLsScalingSupersamplingToggle := TToggleSwitch.Create(FForm);
  FLsScalingSupersamplingToggle.Parent := FLsSpatialCard;
  FLsScalingSupersamplingToggle.LinkToCheckBox(FLsScalingSupersamplingCheckBox);
  FLsScalingSupersamplingToggle.Height := 20;
  FLsScalingSupersamplingToggle.Width := FLsScalingSupersamplingToggle.GetOptimalWidth;
  
  // Load configuration
  LoadLosslessConfig;
  
  // If DLL path is empty, attempt auto-detect on initial load
  if Trim(FLsDllPathEdit.Text) = '' then
  begin
    FLsDllPathEdit.Text := DetectSteamLosslessDll;
  end;
  
  UpdateDllStatus;
  UpdateEngineStatus;
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
  W, CW, CurY, Col2W, RightColX, Col3W, Col4W, EditLeft, EditW, Card0H: Integer;
  IsAdaptive: Boolean;
begin
  if not Assigned(FLsScrollBox) or not Assigned(FLsGeneralCard) then Exit;
  
  W := FLsScrollBox.ClientWidth;
  if AContentW > 100 then
    W := AContentW
  else if W < 500 then
    W := 500;
  
  CW := W - (MARGIN * 2);
  CurY := MARGIN;
  
  Col2W := (CW - (PAD * 2) - 20) div 2;
  RightColX := PAD + Col2W + 20;

  // ── Card 0 Layout: MAKO Engine & LossLess Scaling ──────────────────────────
  if Assigned(FLsProgressBar) and FLsProgressBar.Visible then
    Card0H := 216
  else
    Card0H := 184;

  FLsGeneralCard.SetBounds(MARGIN, CurY, CW, Card0H);
  if Assigned(FLsLogoImage) then
    FLsLogoImage.SetBounds(PAD, 36, 52, 52);
    
  EditLeft := PAD + 52 + 14;
  EditW := CW - EditLeft - PAD - 38 - 85;
  if EditW < 120 then EditW := 120;
  FLsDllPathEdit.SetBounds(EditLeft, 36, EditW, ROW_H);
  FLsBrowseDllBtn.SetBounds(EditLeft + EditW + 6, 36, 32, ROW_H);
  FLsInspectDllBtn.SetBounds(EditLeft + EditW + 44, 36, 75, ROW_H);
  
  if Assigned(FLsDllStatusLabel) then
    FLsDllStatusLabel.SetBounds(EditLeft + 2, 68, CW - EditLeft - PAD, 20);

  if Assigned(FLsCheckUpdatesBtn) then
    FLsCheckUpdatesBtn.Visible := False;

  if Assigned(FLsInstallBtn) and FLsInstallBtn.Visible then
  begin
    FLsInstallBtn.SetBounds(CW - PAD - 120, 94, 120, 26);
    if Assigned(FLsEngineStatusLabel) then
      FLsEngineStatusLabel.SetBounds(PAD, 98, CW - PAD * 2 - 130, 22);
  end
  else
  begin
    if Assigned(FLsEngineStatusLabel) then
      FLsEngineStatusLabel.SetBounds(PAD, 98, CW - PAD * 2, 22);
  end;

  // Target GPU Device moved to Card 0, below MAKO Renderer status
  if Assigned(FLsGpuTitleLbl) then
    FLsGpuTitleLbl.SetBounds(PAD, 124, Col2W, 18);
  if Assigned(FLsGpuComboBox) then
    FLsGpuComboBox.SetBounds(PAD, 144, Col2W, ROW_H);

  if Assigned(FLsProgressBar) and FLsProgressBar.Visible then
  begin
    FLsProgressBar.SetBounds(PAD, 178, CW - PAD * 2, 12);
    FLsProgressLabel.SetBounds(PAD, 192, CW - PAD * 2, 18);
  end;

  CurY := CurY + FLsGeneralCard.Height + GAP;
  
  // ── Card 1 Layout: Frame Generation ────────────────────────────────────────
  Col3W := (CW - (PAD * 2) - 24) div 3;
  Col4W := (CW - (PAD * 2) - 36) div 4;
  
  IsAdaptive := Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1);
  
  FLsFrameGenCard.SetBounds(MARGIN, CurY, CW, 276);
  
  // Row 1: Mode Dropdowns
  FLsFgModeTitleLbl.SetBounds(PAD, 36, Col2W, 18);
  FLsFgModeComboBox.SetBounds(PAD, 56, Col2W, ROW_H);

  FLsAdaptiveMaxMultTitleLbl.Visible := IsAdaptive;
  FLsAdaptiveMaxMultComboBox.Visible := IsAdaptive;
  if IsAdaptive then
  begin
    FLsAdaptiveMaxMultTitleLbl.SetBounds(RightColX, 36, Col2W, 18);
    FLsAdaptiveMaxMultComboBox.SetBounds(RightColX, 56, Col2W, ROW_H);
  end;

  // ── 2x2 Trackbar Grid ──
  // Grid Row 1: Left = Multiplier (or Target FPS) | Right = Flow Scale
  FLsMultiplierTitleLbl.Visible := not IsAdaptive;
  FLsMultiplierTrackBar.Visible := not IsAdaptive;
  FLsMultiplierValueLabel.Visible := not IsAdaptive;
  FLsMultiplierTitleLbl.SetBounds(PAD, 92, Col2W, 18);
  FLsMultiplierTrackBar.SetBounds(PAD, 112, Col2W - 85, ROW_H);
  FLsMultiplierValueLabel.SetBounds(PAD + Col2W - 80, 116, 80, 20);
  if not IsAdaptive then
    FLsMultiplierTrackBar.BringToFront;

  FLsTargetFpsTitleLbl.Visible := IsAdaptive;
  FLsTargetFpsTrackBar.Visible := IsAdaptive;
  FLsTargetFpsValueLabel.Visible := IsAdaptive;
  FLsTargetFpsTitleLbl.SetBounds(PAD, 92, Col2W, 18);
  FLsTargetFpsTrackBar.SetBounds(PAD, 112, Col2W - 85, ROW_H);
  FLsTargetFpsValueLabel.SetBounds(PAD + Col2W - 80, 116, 80, 20);
  if IsAdaptive then
    FLsTargetFpsTrackBar.BringToFront;

  FLsFlowScaleTitleLbl.SetBounds(RightColX, 92, Col2W, 18);
  FLsFlowScaleTrackBar.SetBounds(RightColX, 112, Col2W - 85, ROW_H);
  FLsFlowScaleValueLabel.SetBounds(RightColX + Col2W - 80, 116, 80, 20);

  // Grid Row 2: Left = Base FPS Cap | Right = Refresh Threshold
  FLsBaseFpsCapTitleLbl.SetBounds(PAD, 148, Col2W, 18);
  FLsBaseFpsCapTrackBar.SetBounds(PAD, 168, Col2W - 85, ROW_H);
  FLsBaseFpsCapValueLabel.SetBounds(PAD + Col2W - 80, 172, 80, 20);

  FLsRefreshThresholdTitleLbl.SetBounds(RightColX, 148, Col2W, 18);
  FLsRefreshThresholdTrackBar.SetBounds(RightColX, 168, Col2W - 85, ROW_H);
  FLsRefreshThresholdValueLabel.SetBounds(RightColX + Col2W - 80, 172, 80, 20);

  // Toggles Row 1 (Y = 206): PerfMode, UltraPerf, FP16 Acceleration
  if Assigned(FLsPerfModeToggle) then FLsPerfModeToggle.SetBounds(PAD, 206, Col3W, 24);
  if Assigned(FLsUltraPerfToggle) then FLsUltraPerfToggle.SetBounds(PAD + Col3W + 12, 206, Col3W, 24);
  if Assigned(FLsAllowFp16Toggle) then FLsAllowFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 206, Col3W, 24);

  // Hidden compatibility toggles (placed with valid Left for test assertion compatibility)
  if Assigned(FLsHdrModeToggle) then
  begin
    FLsHdrModeToggle.SetBounds(PAD + Col3W + 12, 206, Col3W, 24);
    FLsHdrModeToggle.Visible := False; // Obsolete in MAKO (handled automatically by swapchain)
  end;
  if Assigned(FLsNoFp16Toggle) then
  begin
    FLsNoFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 206, Col3W, 24);
    FLsNoFp16Toggle.Visible := False; // Redundant toggle
  end;

  // Toggles Row 2 (Y = 238): Live FG Switch, Steady 2x Cap (Adaptive), Smooth Cadence (Adaptive)
  if Assigned(FLsFgLiveToggle) then FLsFgLiveToggle.SetBounds(PAD, 238, Col3W, 24);
  FLsSteady2xCapToggle.Visible := IsAdaptive;
  if IsAdaptive then
    FLsSteady2xCapToggle.SetBounds(PAD + Col3W + 12, 238, Col3W, 24);
  FLsSmoothCadenceToggle.Visible := IsAdaptive;
  if IsAdaptive then
    FLsSmoothCadenceToggle.SetBounds(PAD + (Col3W + 12) * 2, 238, Col3W, 24);

  // Hidden obsolete pacing controls
  if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Visible := False;
  if Assigned(FLsPacingComboBox) then FLsPacingComboBox.Visible := False;

  CurY := CurY + FLsFrameGenCard.Height + GAP;

  // ── Card 2 Layout: Spatial Scaling ─────────────────────────────────────────
  FLsSpatialCard.SetBounds(MARGIN, CurY, CW, 154);

  // Row 1: Scaling Method + Supersampling Toggle
  if Assigned(FLsScalingEnableToggle) then
    FLsScalingEnableToggle.Visible := False;

  FLsScalingMethodTitleLbl.SetBounds(PAD, 36, Col2W, 18);
  FLsScalingMethodComboBox.SetBounds(PAD, 56, Col2W, ROW_H);
  if Assigned(FLsScalingSupersamplingToggle) then
    FLsScalingSupersamplingToggle.SetBounds(RightColX, 58, Col2W, 24);

  // Row 2: Scale Factor + Sharpness
  FLsScalingFactorTitleLbl.SetBounds(PAD, 94, Col2W, 18);
  FLsScalingFactorTrackBar.SetBounds(PAD, 114, Col2W - 65, ROW_H);
  FLsScalingFactorValueLabel.SetBounds(PAD + Col2W - 60, 118, 60, 20);

  FLsScalingSharpnessTitleLbl.SetBounds(RightColX, 94, Col2W, 18);
  FLsScalingSharpnessTrackBar.SetBounds(RightColX, 114, Col2W - 65, ROW_H);
  FLsScalingSharpnessValueLabel.SetBounds(RightColX + Col2W - 60, 118, 60, 20);

  CurY := CurY + FLsSpatialCard.Height + MARGIN;
  
  FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY));
  ApplyThemeStyles;
end;

procedure TLosslessScalingTabHelper.UpdateDllStatus;
var
  P: string;
  SS: WideString;
  IsValid: Boolean;
  IsDark: Boolean;
  Details: string;
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
  UpdateEngineStatus;
end;

procedure TLosslessScalingTabHelper.UpdateEngineStatus;
var
  InstalledVer: string;
begin
  if not Assigned(FLsEngineStatusLabel) then Exit;
  if Assigned(FLsCheckUpdatesBtn) then FLsCheckUpdatesBtn.Visible := False;

  InstalledVer := GetMakoInstalledVersion;
  if InstalledVer <> '' then
  begin
    FLsEngineStatusLabel.Caption := '● MAKO Renderer: ' + InstalledVer + ' (Installed)';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
    if Assigned(FLsInstallBtn) then FLsInstallBtn.Visible := False;

    // Check in background if an update is available so 'Install update' can appear
    if not FCheckingUpdate then
    begin
      FCheckingUpdate := True;
      TMakoCheckUpdateThread.Create(Self).Start;
    end;
  end
  else if IsMakoInstalled then
  begin
    FLsEngineStatusLabel.Caption := '● MAKO Renderer (System Installed)';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
    if Assigned(FLsInstallBtn) then FLsInstallBtn.Visible := False;
  end
  else
  begin
    FLsEngineStatusLabel.Caption := '● MAKO Renderer: Not Installed';
    FLsEngineStatusLabel.Font.Color := RGBToColor(255, 90, 95);
    if Assigned(FLsInstallBtn) then
    begin
      FLsInstallBtn.Caption := 'Install MAKO';
      FLsInstallBtn.Visible := True;
      FLsInstallBtn.Enabled := True;
    end;
  end;
end;

procedure TLosslessScalingTabHelper.InspectDllClick(Sender: TObject);
var
  DllP, Details: string;
begin
  DllP := Trim(FLsDllPathEdit.Text);
  if DllP = '' then
  begin
    FLsDllStatusLabel.Caption := '● No Lossless.dll selected';
    FLsDllStatusLabel.Font.Color := RGBToColor(255, 90, 95);
    Exit;
  end;

  if InspectMakoLosslessDll(DllP, Details) and (Details <> '') then
  begin
    FLsDllStatusLabel.Caption := '● DLL file located: ' + Details;
    FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
  end
  else
  begin
    FLsDllStatusLabel.Caption := '● DLL file located';
    FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
  end;
end;

procedure TLosslessScalingTabHelper.CheckUpdatesClick(Sender: TObject);
var
  LocalVer, RemoteVer, DownloadUrl: string;
begin
  LocalVer := GetMakoInstalledVersion;
  RemoteVer := GetMakoLatestRemoteVersion(DownloadUrl);

  if RemoteVer = '' then
  begin
    FLsEngineStatusLabel.Caption := '● Could not check for updates (GitHub offline/rate-limited)';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_MUTED;
    Exit;
  end;

  if (LocalVer <> '') and (LocalVer = RemoteVer) then
  begin
    FLsEngineStatusLabel.Caption := '● MAKO Renderer ' + LocalVer + ' is up to date';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
  end
  else if (LocalVer <> '') then
  begin
    FLsEngineStatusLabel.Caption := '▲ Update available: ' + RemoteVer + ' (Current: ' + LocalVer + ')';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;
  end
  else
  begin
    FLsEngineStatusLabel.Caption := '● Latest release is ' + RemoteVer + ' (Click Install)';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;
  end;
end;

procedure TLosslessScalingTabHelper.InstallMakoClick(Sender: TObject);
begin
  FLsInstallBtn.Enabled := False;
  FLsCheckUpdatesBtn.Enabled := False;
  FLsProgressBar.Position := 0;
  FLsProgressBar.Visible := True;
  FLsProgressLabel.Caption := 'Starting MAKO installation...';
  FLsProgressLabel.Visible := True;
  ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
  TMakoInstallThread.Create(Self).Start;
end;

procedure TLosslessScalingTabHelper.FgModeChange(Sender: TObject);
begin
  UpdateControlsEnabled;
  ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.TargetFpsChange(Sender: TObject);
begin
  if Assigned(FLsTargetFpsValueLabel) and Assigned(FLsTargetFpsTrackBar) then
    FLsTargetFpsValueLabel.Caption := IntToStr(FLsTargetFpsTrackBar.Position) + ' FPS';
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.BaseFpsCapChange(Sender: TObject);
begin
  if Assigned(FLsBaseFpsCapValueLabel) and Assigned(FLsBaseFpsCapTrackBar) then
  begin
    if FLsBaseFpsCapTrackBar.Position = 0 then
      FLsBaseFpsCapValueLabel.Caption := 'Disabled'
    else
      FLsBaseFpsCapValueLabel.Caption := IntToStr(FLsBaseFpsCapTrackBar.Position) + ' FPS';
  end;
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.RefreshThresholdChange(Sender: TObject);
begin
  if Assigned(FLsRefreshThresholdValueLabel) and Assigned(FLsRefreshThresholdTrackBar) then
  begin
    if FLsRefreshThresholdTrackBar.Position = 0 then
      FLsRefreshThresholdValueLabel.Caption := 'Disabled'
    else
      FLsRefreshThresholdValueLabel.Caption := IntToStr(FLsRefreshThresholdTrackBar.Position) + ' Hz';
  end;
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.ScalingFactorChange(Sender: TObject);
begin
  if Assigned(FLsScalingFactorValueLabel) and Assigned(FLsScalingFactorTrackBar) then
    FLsScalingFactorValueLabel.Caption := FormatFloat('0.00', FLsScalingFactorTrackBar.Position / 100.0) + 'x';
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.ScalingSharpnessChange(Sender: TObject);
begin
  if Assigned(FLsScalingSharpnessValueLabel) and Assigned(FLsScalingSharpnessTrackBar) then
    FLsScalingSharpnessValueLabel.Caption := FormatFloat('0.00', FLsScalingSharpnessTrackBar.Position / 100.0);
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.UpdateControlsEnabled;
var
  FgActive, ScalingActive, AdaptiveActive: Boolean;
begin
  AdaptiveActive := Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1);
  FgActive := (Assigned(FLsMultiplierTrackBar) and (FLsMultiplierTrackBar.Position > 1)) or AdaptiveActive;
  ScalingActive := Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0);
  if Assigned(FLsScalingEnableCheckBox) then
    FLsScalingEnableCheckBox.Checked := ScalingActive;
  if Assigned(FLsScalingEnableToggle) then
    FLsScalingEnableToggle.Checked := ScalingActive;

  // Multiplier vs Target FPS
  if Assigned(FLsMultiplierTitleLbl) then
  begin
    FLsMultiplierTitleLbl.Enabled := not AdaptiveActive;
    FLsMultiplierTitleLbl.Visible := not AdaptiveActive;
  end;
  if Assigned(FLsMultiplierTrackBar) then
  begin
    FLsMultiplierTrackBar.Enabled := not AdaptiveActive;
    FLsMultiplierTrackBar.Visible := not AdaptiveActive;
    if not AdaptiveActive then
      FLsMultiplierTrackBar.BringToFront;
  end;
  if Assigned(FLsMultiplierValueLabel) then
  begin
    FLsMultiplierValueLabel.Enabled := not AdaptiveActive;
    FLsMultiplierValueLabel.Visible := not AdaptiveActive;
  end;

  if Assigned(FLsTargetFpsTitleLbl) then
  begin
    FLsTargetFpsTitleLbl.Enabled := AdaptiveActive;
    FLsTargetFpsTitleLbl.Visible := AdaptiveActive;
  end;
  if Assigned(FLsTargetFpsTrackBar) then
  begin
    FLsTargetFpsTrackBar.Enabled := AdaptiveActive;
    FLsTargetFpsTrackBar.Visible := AdaptiveActive;
    if AdaptiveActive then
      FLsTargetFpsTrackBar.BringToFront;
  end;
  if Assigned(FLsTargetFpsValueLabel) then
  begin
    FLsTargetFpsValueLabel.Enabled := AdaptiveActive;
    FLsTargetFpsValueLabel.Visible := AdaptiveActive;
  end;
  if Assigned(FLsAdaptiveMaxMultTitleLbl) then
  begin
    FLsAdaptiveMaxMultTitleLbl.Enabled := AdaptiveActive;
    FLsAdaptiveMaxMultTitleLbl.Visible := AdaptiveActive;
  end;
  if Assigned(FLsAdaptiveMaxMultComboBox) then
  begin
    FLsAdaptiveMaxMultComboBox.Enabled := AdaptiveActive;
    FLsAdaptiveMaxMultComboBox.Visible := AdaptiveActive;
  end;
  if Assigned(FLsSteady2xCapCheckBox) then
  begin
    FLsSteady2xCapCheckBox.Enabled := AdaptiveActive;
    FLsSteady2xCapCheckBox.Visible := False;
  end;
  if Assigned(FLsSteady2xCapToggle) then
  begin
    FLsSteady2xCapToggle.Enabled := AdaptiveActive;
    FLsSteady2xCapToggle.Visible := AdaptiveActive;
    FLsSteady2xCapToggle.SyncFromLinked;
  end;
  if Assigned(FLsSmoothCadenceCheckBox) then
  begin
    FLsSmoothCadenceCheckBox.Enabled := AdaptiveActive;
    FLsSmoothCadenceCheckBox.Visible := False;
  end;
  if Assigned(FLsSmoothCadenceToggle) then
  begin
    FLsSmoothCadenceToggle.Enabled := AdaptiveActive;
    FLsSmoothCadenceToggle.Visible := AdaptiveActive;
    FLsSmoothCadenceToggle.SyncFromLinked;
  end;

  // Shared FG Controls
  if Assigned(FLsFlowScaleTitleLbl) then FLsFlowScaleTitleLbl.Enabled := FgActive;
  if Assigned(FLsFlowScaleTrackBar) then FLsFlowScaleTrackBar.Enabled := FgActive;
  if Assigned(FLsFlowScaleValueLabel) then FLsFlowScaleValueLabel.Enabled := FgActive;
  if Assigned(FLsBaseFpsCapTitleLbl) then FLsBaseFpsCapTitleLbl.Enabled := FgActive;
  if Assigned(FLsBaseFpsCapTrackBar) then FLsBaseFpsCapTrackBar.Enabled := FgActive;
  if Assigned(FLsBaseFpsCapValueLabel) then FLsBaseFpsCapValueLabel.Enabled := FgActive;
  if Assigned(FLsRefreshThresholdTitleLbl) then FLsRefreshThresholdTitleLbl.Enabled := FgActive;
  if Assigned(FLsRefreshThresholdTrackBar) then FLsRefreshThresholdTrackBar.Enabled := FgActive;
  if Assigned(FLsRefreshThresholdValueLabel) then FLsRefreshThresholdValueLabel.Enabled := FgActive;

  if Assigned(FLsFgLiveCheckBox) then FLsFgLiveCheckBox.Enabled := FgActive;
  if Assigned(FLsFgLiveToggle) then
  begin
    FLsFgLiveToggle.Enabled := FgActive;
    FLsFgLiveToggle.SyncFromLinked;
  end;
  if Assigned(FLsAllowFp16CheckBox) then FLsAllowFp16CheckBox.Enabled := FgActive;
  if Assigned(FLsAllowFp16Toggle) then
  begin
    FLsAllowFp16Toggle.Enabled := FgActive;
    FLsAllowFp16Toggle.SyncFromLinked;
  end;
  if Assigned(FLsPerfModeCheckBox) then FLsPerfModeCheckBox.Enabled := FgActive;
  if Assigned(FLsPerfModeToggle) then
  begin
    FLsPerfModeToggle.Enabled := FgActive;
    FLsPerfModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsUltraPerfCheckBox) then FLsUltraPerfCheckBox.Enabled := FgActive;
  if Assigned(FLsUltraPerfToggle) then
  begin
    FLsUltraPerfToggle.Enabled := FgActive;
    FLsUltraPerfToggle.SyncFromLinked;
  end;
  if Assigned(FLsHdrModeCheckBox) then FLsHdrModeCheckBox.Enabled := FgActive;
  if Assigned(FLsHdrModeToggle) then
  begin
    FLsHdrModeToggle.Enabled := FgActive;
    FLsHdrModeToggle.Visible := False;
    FLsHdrModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsNoFp16CheckBox) then FLsNoFp16CheckBox.Enabled := FgActive;
  if Assigned(FLsNoFp16Toggle) then
  begin
    FLsNoFp16Toggle.Enabled := FgActive;
    FLsNoFp16Toggle.Visible := False;
    FLsNoFp16Toggle.SyncFromLinked;
  end;
  if Assigned(FLsPacingTitleLbl) then
  begin
    FLsPacingTitleLbl.Enabled := FgActive;
    FLsPacingTitleLbl.Visible := False;
  end;
  if Assigned(FLsPacingComboBox) then
  begin
    FLsPacingComboBox.Enabled := FgActive;
    FLsPacingComboBox.Visible := False;
  end;
  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Enabled := FgActive;
  if Assigned(FLsGpuComboBox) then FLsGpuComboBox.Enabled := FgActive;

  // Spatial Scaling Controls
  if Assigned(FLsScalingEnableCheckBox) then FLsScalingEnableCheckBox.Enabled := True;
  if Assigned(FLsScalingMethodTitleLbl) then FLsScalingMethodTitleLbl.Enabled := True;
  if Assigned(FLsScalingMethodComboBox) then FLsScalingMethodComboBox.Enabled := True;
  if Assigned(FLsScalingFactorTitleLbl) then FLsScalingFactorTitleLbl.Enabled := ScalingActive;
  if Assigned(FLsScalingFactorTrackBar) then FLsScalingFactorTrackBar.Enabled := ScalingActive;
  if Assigned(FLsScalingFactorValueLabel) then FLsScalingFactorValueLabel.Enabled := ScalingActive;
  if Assigned(FLsScalingSharpnessTitleLbl) then FLsScalingSharpnessTitleLbl.Enabled := ScalingActive;
  if Assigned(FLsScalingSharpnessTrackBar) then FLsScalingSharpnessTrackBar.Enabled := ScalingActive;
  if Assigned(FLsScalingSharpnessValueLabel) then FLsScalingSharpnessValueLabel.Enabled := ScalingActive;
  if Assigned(FLsScalingSupersamplingCheckBox) then FLsScalingSupersamplingCheckBox.Enabled := ScalingActive;
  if Assigned(FLsScalingSupersamplingToggle) then
  begin
    FLsScalingSupersamplingToggle.Enabled := ScalingActive;
    FLsScalingSupersamplingToggle.SyncFromLinked;
  end;
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
  // Sync NoFp16 and AllowFp16 compatibility
  if (Sender = FLsNoFp16CheckBox) or (Sender = FLsNoFp16Toggle) then
  begin
    if Assigned(FLsAllowFp16CheckBox) then
      FLsAllowFp16CheckBox.Checked := not FLsNoFp16CheckBox.Checked;
    if Assigned(FLsAllowFp16Toggle) then
      FLsAllowFp16Toggle.Checked := not FLsNoFp16CheckBox.Checked;
  end
  else if (Sender = FLsAllowFp16CheckBox) or (Sender = FLsAllowFp16Toggle) then
  begin
    if Assigned(FLsNoFp16CheckBox) then
      FLsNoFp16CheckBox.Checked := not FLsAllowFp16CheckBox.Checked;
    if Assigned(FLsNoFp16Toggle) then
      FLsNoFp16Toggle.Checked := not FLsAllowFp16CheckBox.Checked;
  end;

  if (Sender = FLsScalingMethodComboBox) then
  begin
    if Assigned(FLsScalingEnableCheckBox) then
      FLsScalingEnableCheckBox.Checked := (FLsScalingMethodComboBox.ItemIndex > 0);
    if Assigned(FLsScalingEnableToggle) then
      FLsScalingEnableToggle.Checked := (FLsScalingMethodComboBox.ItemIndex > 0);
  end;

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

function TLosslessScalingTabHelper.WriteMakoTomlConfig(const ATargetDir: string): string;
var
  Lines, LegacyLines: TStringList;
  OutDir, OutPath, LegacyOutPath, PacingStr, DllP, ExeName, ProfileName: string;
  ScalingMethodStr, FactorStr, SharpnessStr, FlowStr: string;
  MultVal, TargetFpsVal, MaxMultVal, RefreshVal, BaseCapVal: Integer;
  IsAdaptive, ScalingEn, ScalingSs, AllowFp16Val, PerfVal, UltraPerfVal, FgLiveVal, HdrVal: Boolean;
  AutoBaseCapVal: Boolean;
begin
  Result := '';
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

  OutPath := IncludeTrailingPathDelimiter(OutDir) + 'conf.toml';
  LegacyOutPath := IncludeTrailingPathDelimiter(OutDir) + 'lsfg.toml';

  IsAdaptive := Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1);
  MultVal := FLsMultiplierTrackBar.Position;
  if IsAdaptive then
    TargetFpsVal := FLsTargetFpsTrackBar.Position
  else
    TargetFpsVal := 90;

  if Assigned(FLsAdaptiveMaxMultComboBox) then
    MaxMultVal := FLsAdaptiveMaxMultComboBox.ItemIndex + 2
  else
    MaxMultVal := 3;

  AutoBaseCapVal := Assigned(FLsSteady2xCapCheckBox) and FLsSteady2xCapCheckBox.Checked;
  RefreshVal := FLsRefreshThresholdTrackBar.Position;
  BaseCapVal := FLsBaseFpsCapTrackBar.Position;
  FlowStr := StringReplace(FormatFloat('0.00', FLsFlowScaleTrackBar.Position / 100.0), ',', '.', [rfReplaceAll]);

  ScalingEn := Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0);
  case FLsScalingMethodComboBox.ItemIndex of
    1: ScalingMethodStr := 'ls1';
    2: ScalingMethodStr := 'ls1-performance';
    3: ScalingMethodStr := 'mako';
    4: ScalingMethodStr := 'native';
  else
    ScalingMethodStr := 'none';
  end;

  FactorStr := StringReplace(FormatFloat('0.00', FLsScalingFactorTrackBar.Position / 100.0), ',', '.', [rfReplaceAll]);
  SharpnessStr := StringReplace(FormatFloat('0.00', FLsScalingSharpnessTrackBar.Position / 100.0), ',', '.', [rfReplaceAll]);
  ScalingSs := Assigned(FLsScalingSupersamplingCheckBox) and FLsScalingSupersamplingCheckBox.Checked;

  if Assigned(FLsNoFp16CheckBox) and FLsNoFp16CheckBox.Checked then
    AllowFp16Val := False
  else if Assigned(FLsAllowFp16CheckBox) then
    AllowFp16Val := FLsAllowFp16CheckBox.Checked
  else
    AllowFp16Val := True;

  HdrVal := Assigned(FLsHdrModeCheckBox) and FLsHdrModeCheckBox.Checked;
  PerfVal := Assigned(FLsPerfModeCheckBox) and FLsPerfModeCheckBox.Checked;
  UltraPerfVal := Assigned(FLsUltraPerfCheckBox) and FLsUltraPerfCheckBox.Checked;
  FgLiveVal := Assigned(FLsFgLiveCheckBox) and FLsFgLiveCheckBox.Checked;

  case FLsPacingComboBox.ItemIndex of
    1: PacingStr := 'vsync';
    2: PacingStr := 'mailbox';
    3: PacingStr := 'immediate';
    4: PacingStr := 'none';
  else
    PacingStr := 'none';
  end;

  Lines := TStringList.Create;
  try
    Lines.Add('version = 2');
    Lines.Add('');
    Lines.Add('dll = "' + DllP + '"');
    if AllowFp16Val then
      Lines.Add('allow_fp16 = true')
    else
      Lines.Add('allow_fp16 = false');
    Lines.Add('');

    // Profile: pascube
    Lines.Add('[[profile]]');
    Lines.Add('name = "pascube"');
    Lines.Add('active_in = ["pascube"]');
    if ScalingEn then
    begin
      Lines.Add('scaling_enabled = true');
      Lines.Add('scaling_method = "' + ScalingMethodStr + '"');
      Lines.Add('scaling_factor = ' + FactorStr);
      if ScalingSs then Lines.Add('scaling_supersampling = true') else Lines.Add('scaling_supersampling = false');
      Lines.Add('scaling_sharpness = ' + SharpnessStr);
    end
    else
      Lines.Add('scaling_enabled = false');

    if IsAdaptive then
    begin
      Lines.Add('frame_generation_enabled = true');
      Lines.Add('adaptive = true');
      Lines.Add('target_fps = ' + IntToStr(TargetFpsVal));
      Lines.Add('adaptive_max_multiplier = ' + IntToStr(MaxMultVal));
      if AutoBaseCapVal then Lines.Add('adaptive_auto_base_fps_cap = true') else Lines.Add('adaptive_auto_base_fps_cap = false');
    end
    else if MultVal >= 2 then
    begin
      Lines.Add('multiplier = ' + IntToStr(MultVal));
      if FgLiveVal then Lines.Add('frame_generation_enabled = true') else Lines.Add('frame_generation_enabled = false');
      Lines.Add('adaptive = false');
    end
    else
    begin
      Lines.Add('frame_generation_enabled = false');
      Lines.Add('adaptive = false');
    end;

    Lines.Add('frame_generation_refresh_threshold = ' + IntToStr(RefreshVal));
    Lines.Add('base_fps_cap = ' + IntToStr(BaseCapVal));
    if PerfVal then Lines.Add('performance_mode = true') else Lines.Add('performance_mode = false');
    if UltraPerfVal then Lines.Add('ultra_performance = true') else Lines.Add('ultra_performance = false');
    if HdrVal then Lines.Add('hdr_mode = true') else Lines.Add('hdr_mode = false');
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('pacing = "none"');
    Lines.Add('');

    // Profile: vkcube
    Lines.Add('[[profile]]');
    Lines.Add('name = "vkcube"');
    Lines.Add('active_in = ["vkcube"]');
    if ScalingEn then
    begin
      Lines.Add('scaling_enabled = true');
      Lines.Add('scaling_method = "' + ScalingMethodStr + '"');
      Lines.Add('scaling_factor = ' + FactorStr);
      if ScalingSs then Lines.Add('scaling_supersampling = true') else Lines.Add('scaling_supersampling = false');
      Lines.Add('scaling_sharpness = ' + SharpnessStr);
    end
    else
      Lines.Add('scaling_enabled = false');

    if IsAdaptive then
    begin
      Lines.Add('frame_generation_enabled = true');
      Lines.Add('adaptive = true');
      Lines.Add('target_fps = ' + IntToStr(TargetFpsVal));
      Lines.Add('adaptive_max_multiplier = ' + IntToStr(MaxMultVal));
      if AutoBaseCapVal then Lines.Add('adaptive_auto_base_fps_cap = true') else Lines.Add('adaptive_auto_base_fps_cap = false');
    end
    else if MultVal >= 2 then
    begin
      Lines.Add('multiplier = ' + IntToStr(MultVal));
      if FgLiveVal then Lines.Add('frame_generation_enabled = true') else Lines.Add('frame_generation_enabled = false');
      Lines.Add('adaptive = false');
    end
    else
    begin
      Lines.Add('frame_generation_enabled = false');
      Lines.Add('adaptive = false');
    end;

    Lines.Add('frame_generation_refresh_threshold = ' + IntToStr(RefreshVal));
    Lines.Add('base_fps_cap = ' + IntToStr(BaseCapVal));
    if PerfVal then Lines.Add('performance_mode = true') else Lines.Add('performance_mode = false');
    if UltraPerfVal then Lines.Add('ultra_performance = true') else Lines.Add('ultra_performance = false');
    if HdrVal then Lines.Add('hdr_mode = true') else Lines.Add('hdr_mode = false');
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('pacing = "none"');

    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      ProfileName := ChangeFileExt(ExtractFileName(ExeName), '');
      if ProfileName = '' then ProfileName := ExeName;
      Lines.Add('');
      Lines.Add('[[profile]]');
      Lines.Add('name = "' + ProfileName + '"');
      Lines.Add('active_in = ["' + ExeName + '", "' + ProfileName + '", "' + ProfileName + '.exe", "' + ProfileName + '_dx12.exe", "' + ProfileName + '_dx11.exe", "' + LowerCase(ProfileName) + '_dx12.exe", "' + LowerCase(ProfileName) + '_dx11.exe", "wine64-preloader", "wine-preloader"]');
      if ScalingEn then
      begin
        Lines.Add('scaling_enabled = true');
        Lines.Add('scaling_method = "' + ScalingMethodStr + '"');
        Lines.Add('scaling_factor = ' + FactorStr);
        if ScalingSs then Lines.Add('scaling_supersampling = true') else Lines.Add('scaling_supersampling = false');
        Lines.Add('scaling_sharpness = ' + SharpnessStr);
      end
      else
        Lines.Add('scaling_enabled = false');

      if IsAdaptive then
      begin
        Lines.Add('frame_generation_enabled = true');
        Lines.Add('adaptive = true');
        Lines.Add('target_fps = ' + IntToStr(TargetFpsVal));
        Lines.Add('adaptive_max_multiplier = ' + IntToStr(MaxMultVal));
        if AutoBaseCapVal then Lines.Add('adaptive_auto_base_fps_cap = true') else Lines.Add('adaptive_auto_base_fps_cap = false');
      end
      else if MultVal >= 2 then
      begin
        Lines.Add('multiplier = ' + IntToStr(MultVal));
        if FgLiveVal then Lines.Add('frame_generation_enabled = true') else Lines.Add('frame_generation_enabled = false');
        Lines.Add('adaptive = false');
      end
      else
      begin
        Lines.Add('frame_generation_enabled = false');
        Lines.Add('adaptive = false');
      end;

      Lines.Add('frame_generation_refresh_threshold = ' + IntToStr(RefreshVal));
      Lines.Add('base_fps_cap = ' + IntToStr(BaseCapVal));
      if PerfVal then Lines.Add('performance_mode = true') else Lines.Add('performance_mode = false');
      if UltraPerfVal then Lines.Add('ultra_performance = true') else Lines.Add('ultra_performance = false');
      if HdrVal then Lines.Add('hdr_mode = true') else Lines.Add('hdr_mode = false');
      Lines.Add('flow_scale = ' + FlowStr);
      Lines.Add('pacing = "none"');
    end;

    Lines.SaveToFile(OutPath);

    // Write mirror to lsfg.toml with legacy v1 schema for backward compatibility with tools and tests
    LegacyLines := TStringList.Create;
    try
      LegacyLines.Add('version = 1');
      LegacyLines.Add('');
      LegacyLines.Add('[global]');
      LegacyLines.Add('dll = "' + DllP + '"');
      LegacyLines.Add('');
      LegacyLines.Add('[[game]]');
      LegacyLines.Add('exe = "pascube"');
      LegacyLines.Add('dll = "' + DllP + '"');
      LegacyLines.Add('multiplier = ' + IntToStr(MultVal));
      LegacyLines.Add('flow_scale = ' + FlowStr);
      if PerfVal then LegacyLines.Add('performance_mode = true') else LegacyLines.Add('performance_mode = false');
      if HdrVal then LegacyLines.Add('hdr_mode = true') else LegacyLines.Add('hdr_mode = false');
      if AllowFp16Val then LegacyLines.Add('legacy = false') else LegacyLines.Add('legacy = true');
      LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');
      LegacyLines.Add('');
      LegacyLines.Add('[[game]]');
      LegacyLines.Add('exe = "vkcube"');
      LegacyLines.Add('dll = "' + DllP + '"');
      LegacyLines.Add('multiplier = ' + IntToStr(MultVal));
      LegacyLines.Add('flow_scale = ' + FlowStr);
      if PerfVal then LegacyLines.Add('performance_mode = true') else LegacyLines.Add('performance_mode = false');
      if HdrVal then LegacyLines.Add('hdr_mode = true') else LegacyLines.Add('hdr_mode = false');
      if AllowFp16Val then LegacyLines.Add('legacy = false') else LegacyLines.Add('legacy = true');
      LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');

      if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
      begin
        LegacyLines.Add('');
        LegacyLines.Add('[[game]]');
        LegacyLines.Add('exe = "' + ExeName + '"');
        LegacyLines.Add('dll = "' + DllP + '"');
        LegacyLines.Add('multiplier = ' + IntToStr(MultVal));
        LegacyLines.Add('flow_scale = ' + FlowStr);
        if PerfVal then LegacyLines.Add('performance_mode = true') else LegacyLines.Add('performance_mode = false');
        if HdrVal then LegacyLines.Add('hdr_mode = true') else LegacyLines.Add('hdr_mode = false');
        if AllowFp16Val then LegacyLines.Add('legacy = false') else LegacyLines.Add('legacy = true');
        LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');
      end;
      LegacyLines.SaveToFile(LegacyOutPath);
    finally
      LegacyLines.Free;
    end;

    Result := OutPath;
  finally
    Lines.Free;
  end;
end;

function TLosslessScalingTabHelper.WriteLsfgTomlConfig(const ATargetDir: string): string;
begin
  Result := WriteMakoTomlConfig(ATargetDir);
end;

function TLosslessScalingTabHelper.WriteDefaultLsfgToml(const ATargetDir: string): string;
var
  Lines, LegacyLines: TStringList;
  OutDir, OutPath, LegacyOutPath, DllP, ExeName: string;
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

  OutPath := IncludeTrailingPathDelimiter(OutDir) + 'conf.toml';
  LegacyOutPath := IncludeTrailingPathDelimiter(OutDir) + 'lsfg.toml';

  DllP := Trim(FLsDllPathEdit.Text);
  if DllP = '' then
    DllP := DetectSteamLosslessDll;

  // 1. Write canonical conf.toml
  Lines := TStringList.Create;
  try
    Lines.Add('version = 2');
    Lines.Add('');
    if (DllP <> '') and FileExists(DllP) then
      Lines.Add('dll = "' + DllP + '"')
    else
      Lines.Add('# dll = "/path/to/Lossless.dll"');
    Lines.Add('allow_fp16 = true');
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "pascube"');
    Lines.Add('active_in = ["pascube"]');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('pacing = "none"');
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "vkcube"');
    Lines.Add('active_in = ["vkcube"]');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('pacing = "none"');
    Lines.SaveToFile(OutPath);
  finally
    Lines.Free;
  end;

  // 2. Write legacy lsfg.toml
  LegacyLines := TStringList.Create;
  try
    LegacyLines.Add('version = 1');
    LegacyLines.Add('');
    LegacyLines.Add('[global]');
    if (DllP <> '') and FileExists(DllP) then
      LegacyLines.Add('dll = "' + DllP + '"')
    else
      LegacyLines.Add('# dll = "/path/to/Lossless.dll"');
    LegacyLines.Add('');
    LegacyLines.Add('[[game]]');
    LegacyLines.Add('exe = "pascube"');
    if (DllP <> '') and FileExists(DllP) then
      LegacyLines.Add('dll = "' + DllP + '"');
    LegacyLines.Add('multiplier = 2');
    LegacyLines.Add('flow_scale = 1.00');
    LegacyLines.Add('performance_mode = false');
    LegacyLines.Add('hdr_mode = false');
    LegacyLines.Add('legacy = false');
    LegacyLines.Add('experimental_present_mode = "none"');
    LegacyLines.Add('');
    LegacyLines.Add('[[game]]');
    LegacyLines.Add('exe = "vkcube"');
    if (DllP <> '') and FileExists(DllP) then
      LegacyLines.Add('dll = "' + DllP + '"');
    LegacyLines.Add('multiplier = 2');
    LegacyLines.Add('flow_scale = 1.00');
    LegacyLines.Add('performance_mode = false');
    LegacyLines.Add('hdr_mode = false');
    LegacyLines.Add('legacy = false');
    LegacyLines.Add('experimental_present_mode = "none"');

    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      LegacyLines.Add('');
      LegacyLines.Add('[[game]]');
      LegacyLines.Add('exe = "' + ExeName + '"');
      if (DllP <> '') and FileExists(DllP) then
        LegacyLines.Add('dll = "' + DllP + '"');
      LegacyLines.Add('multiplier = 2');
      LegacyLines.Add('flow_scale = 1.00');
      LegacyLines.Add('performance_mode = false');
      LegacyLines.Add('hdr_mode = false');
      LegacyLines.Add('legacy = false');
      LegacyLines.Add('experimental_present_mode = "none"');
    end;

    LegacyLines.SaveToFile(LegacyOutPath);
    Result := LegacyOutPath;
  finally
    LegacyLines.Free;
  end;
end;

function TLosslessScalingTabHelper.GetActiveEnvVars: string;
var
  TomlP, DllP: string;
  IsActive: Boolean;
begin
  Result := '';
  IsActive := (FLsMultiplierTrackBar.Position > 1) or
              (Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1)) or
              (Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0));

  if not IsActive then
    Exit('');

  DllP := Trim(FLsDllPathEdit.Text);
  if (DllP = '') or not FileExists(DllP) then
    Exit('');

  TomlP := WriteMakoTomlConfig;
  if (TomlP <> '') and FileExists(TomlP) then
  begin
    Result := 'ENABLE_MAKO=1 MAKO_CONFIG="' + TomlP + '" MAKO_DISABLE_HDR_EXPOSURE=1 DISABLE_GAMESCOPE_WSI=1 DISABLE_LSFG=1 DISABLE_LSFGVK=1 LSFG_CONFIG="' + TomlP + '"';
    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
      Result := Result + ' MAKO_PROFILE="' + ChangeFileExt(ExtractFileName(Tgoverlayform(FForm).FActiveGameName), '') + '"';
    if Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0) then
      Result := Result + ' ENABLE_MAKO_SPATIAL_SCALING=1';
  end;
end;

procedure TLosslessScalingTabHelper.LoadLosslessConfig;
var
  Ini: TIniFile;
  CfgPath, CfgDir, TomlPath, LegacyTomlPath, DllVal, PacingVal, GpuVal, FlowVal, MultVal: string;
  FlowInt, MultInt, GpuIdx: Integer;
  IsLosslessOn, TomlFound: Boolean;
  MakoCfg, LegacyCfg: TMakoConfig;
begin
  if Assigned(FForm) and (FForm is Tgoverlayform) then
    Tgoverlayform(FForm).FLoadingConfig := True;
  try
    CfgPath := GetConfigFile;
    CfgDir := ExtractFilePath(CfgPath);
    TomlPath := IncludeTrailingPathDelimiter(CfgDir) + 'conf.toml';
    LegacyTomlPath := IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml';
    
    // Set defaults
    FLsDllPathEdit.Text := DetectSteamLosslessDll;
    FLsFgModeComboBox.ItemIndex := 0;
    FLsMultiplierTrackBar.Position := 1;
    if Assigned(FLsMultiplierValueLabel) then
      FLsMultiplierValueLabel.Caption := '1x (Disabled)';
    FLsTargetFpsTrackBar.Position := 90;
    if Assigned(FLsTargetFpsValueLabel) then
      FLsTargetFpsValueLabel.Caption := '90 FPS';
    FLsAdaptiveMaxMultComboBox.ItemIndex := 1;
    FLsSteady2xCapCheckBox.Checked := False;
    FLsSmoothCadenceCheckBox.Checked := False;

    FLsFlowScaleTrackBar.Position := 100;
    if Assigned(FLsFlowScaleValueLabel) then
      FLsFlowScaleValueLabel.Caption := '100%';
    FLsBaseFpsCapTrackBar.Position := 0;
    if Assigned(FLsBaseFpsCapValueLabel) then
      FLsBaseFpsCapValueLabel.Caption := 'Disabled';
    FLsRefreshThresholdTrackBar.Position := 0;
    if Assigned(FLsRefreshThresholdValueLabel) then
      FLsRefreshThresholdValueLabel.Caption := 'Disabled';

    FLsFgLiveCheckBox.Checked := True;
    FLsAllowFp16CheckBox.Checked := True;
    FLsPerfModeCheckBox.Checked := False;
    FLsUltraPerfCheckBox.Checked := False;
    FLsHdrModeCheckBox.Checked := False;
    FLsNoFp16CheckBox.Checked := False;

    FLsScalingEnableCheckBox.Checked := False;
    FLsScalingMethodComboBox.ItemIndex := 0;
    FLsScalingFactorTrackBar.Position := 150;
    if Assigned(FLsScalingFactorValueLabel) then
      FLsScalingFactorValueLabel.Caption := '1.50x';
    FLsScalingSharpnessTrackBar.Position := 80;
    if Assigned(FLsScalingSharpnessValueLabel) then
      FLsScalingSharpnessValueLabel.Caption := '0.80';
    FLsScalingSupersamplingCheckBox.Checked := False;

    FLsPacingComboBox.ItemIndex := 0;
    FLsGpuComboBox.ItemIndex := 0;

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
      ParseMakoToml(TomlPath, MakoCfg);
      TomlFound := True;
      if FileExists(LegacyTomlPath) then
      begin
        ParseMakoToml(LegacyTomlPath, LegacyCfg);
        if (LegacyCfg.Pacing <> '') and (LegacyCfg.Pacing <> 'none') then
          MakoCfg.Pacing := LegacyCfg.Pacing;
      end;
    end
    else if FileExists(LegacyTomlPath) then
    begin
      ParseMakoToml(LegacyTomlPath, MakoCfg);
      TomlFound := True;
    end;

    if TomlFound then
    begin
      if MakoCfg.Dll <> '' then
        FLsDllPathEdit.Text := MakoCfg.Dll;

      if MakoCfg.Adaptive then
        FLsFgModeComboBox.ItemIndex := 1
      else
        FLsFgModeComboBox.ItemIndex := 0;
        
      if IsLosslessOn or (MakoCfg.Multiplier >= 2) or MakoCfg.Adaptive then
      begin
        MultInt := MakoCfg.Multiplier;
        if MultInt < 1 then MultInt := 1;
        if MultInt > 5 then MultInt := 5;
        FLsMultiplierTrackBar.Position := MultInt;
        MultiplierChange(nil);
      end
      else
      begin
        FLsMultiplierTrackBar.Position := 1;
        MultiplierChange(nil);
      end;

      FLsTargetFpsTrackBar.Position := MakoCfg.TargetFps;
      if Assigned(FLsTargetFpsValueLabel) then
        FLsTargetFpsValueLabel.Caption := IntToStr(MakoCfg.TargetFps) + ' FPS';

      if (MakoCfg.AdaptiveMaxMultiplier >= 2) and (MakoCfg.AdaptiveMaxMultiplier <= 5) then
        FLsAdaptiveMaxMultComboBox.ItemIndex := MakoCfg.AdaptiveMaxMultiplier - 2;

      FLsSteady2xCapCheckBox.Checked := MakoCfg.AdaptiveAutoBaseFpsCap;
        
      FlowInt := Round(MakoCfg.FlowScale * 100);
      if FlowInt < 25 then FlowInt := 25;
      if FlowInt > 100 then FlowInt := 100;
      FLsFlowScaleTrackBar.Position := FlowInt;
      if Assigned(FLsFlowScaleValueLabel) then
        FLsFlowScaleValueLabel.Caption := IntToStr(FlowInt) + '%';

      FLsBaseFpsCapTrackBar.Position := MakoCfg.BaseFpsCap;
      BaseFpsCapChange(nil);

      FLsRefreshThresholdTrackBar.Position := MakoCfg.FrameGenRefreshThreshold;
      RefreshThresholdChange(nil);
        
      FLsFgLiveCheckBox.Checked := MakoCfg.FrameGenEnabled;
      FLsAllowFp16CheckBox.Checked := MakoCfg.AllowFp16;
      FLsNoFp16CheckBox.Checked := not MakoCfg.AllowFp16;
      FLsPerfModeCheckBox.Checked := MakoCfg.PerformanceMode;
      FLsUltraPerfCheckBox.Checked := MakoCfg.UltraPerformance;
      FLsHdrModeCheckBox.Checked := MakoCfg.HdrMode;

      if not MakoCfg.ScalingEnabled then
        FLsScalingMethodComboBox.ItemIndex := 0
      else if MakoCfg.ScalingMethod = 'ls1-performance' then
        FLsScalingMethodComboBox.ItemIndex := 2
      else if MakoCfg.ScalingMethod = 'mako' then
        FLsScalingMethodComboBox.ItemIndex := 3
      else if MakoCfg.ScalingMethod = 'native' then
        FLsScalingMethodComboBox.ItemIndex := 4
      else
        FLsScalingMethodComboBox.ItemIndex := 1;

      FLsScalingEnableCheckBox.Checked := (FLsScalingMethodComboBox.ItemIndex > 0);
      FLsScalingEnableToggle.Checked := (FLsScalingMethodComboBox.ItemIndex > 0);

      FLsScalingFactorTrackBar.Position := Round(MakoCfg.ScalingFactor * 100);
      ScalingFactorChange(nil);

      FLsScalingSharpnessTrackBar.Position := Round(MakoCfg.ScalingSharpness * 100);
      ScalingSharpnessChange(nil);

      FLsScalingSupersamplingCheckBox.Checked := MakoCfg.ScalingSupersampling;
      
      PacingVal := LowerCase(Trim(MakoCfg.Pacing));
      if PacingVal = 'vsync' then FLsPacingComboBox.ItemIndex := 1
      else if PacingVal = 'mailbox' then FLsPacingComboBox.ItemIndex := 2
      else if PacingVal = 'immediate' then FLsPacingComboBox.ItemIndex := 3
      else if PacingVal = 'none' then FLsPacingComboBox.ItemIndex := 0
      else FLsPacingComboBox.ItemIndex := 0;
    end;

    // Fallback migration: if toml not found, check legacy bgmod.conf keys
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
          if MultInt > 5 then MultInt := 5;
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
            FlowInt := Round(StrToFloatDef(StringReplace(FlowVal, '.', DecimalSeparator, []), 0.90) * 100)
          else
            FlowInt := StrToIntDef(FlowVal, 90);
          if FlowInt < 25 then FlowInt := 25;
          if FlowInt > 100 then FlowInt := 100;
          FLsFlowScaleTrackBar.Position := FlowInt;
          if Assigned(FLsFlowScaleValueLabel) then
            FLsFlowScaleValueLabel.Caption := IntToStr(FlowInt) + '%';
        end;
        
        FLsPerfModeCheckBox.Checked := (Ini.ReadString('Config', 'LS_PERFORMANCE_MODE', Ini.ReadString('Env', 'LSFG_PERFORMANCE_MODE', Ini.ReadString('Env', 'LSFGVK_PERFORMANCE_MODE', '0'))) = '1');
        FLsHdrModeCheckBox.Checked := (Ini.ReadString('Config', 'LS_HDR_MODE', Ini.ReadString('Env', 'LSFG_HDR_MODE', Ini.ReadString('Env', 'LSFGVK_HDR_MODE', '0'))) = '1');
        FLsNoFp16CheckBox.Checked := (Ini.ReadString('Config', 'LS_NO_FP16', Ini.ReadString('Env', 'LSFG_LEGACY', Ini.ReadString('Env', 'LSFGVK_NO_FP16', '0'))) = '1');
        FLsAllowFp16CheckBox.Checked := not FLsNoFp16CheckBox.Checked;
        
        PacingVal := LowerCase(Trim(Ini.ReadString('Config', 'LS_PACING', Ini.ReadString('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE', Ini.ReadString('Env', 'LSFGVK_PACING', 'none')))));
        if PacingVal = 'vsync' then FLsPacingComboBox.ItemIndex := 1
        else if PacingVal = 'mailbox' then FLsPacingComboBox.ItemIndex := 2
        else if PacingVal = 'immediate' then FLsPacingComboBox.ItemIndex := 3
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
  UpdateEngineStatus;
  if Assigned(FLsDllPathEdit) then
  begin
    FLsDllPathEdit.SelStart := 0;
    FLsDllPathEdit.SelLength := 0;
  end;
  ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
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
  IsEnabled := (DllPath <> '') and FileExists(DllPath) and
               ((FLsMultiplierTrackBar.Position > 1) or
                (Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1)) or
                (Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0)));
  
  Ini := TIniFile.Create(CfgPath);
  try
    if IsEnabled then
    begin
      Ini.WriteString('Config', 'GOVERLAY_LOSSLESS', '1');

      // Prune redundant LS_* keys from [Config]
      Ini.DeleteKey('Config', 'LS_DLL_PATH');
      Ini.DeleteKey('Config', 'LS_MULTIPLIER');
      Ini.DeleteKey('Config', 'LS_FLOW_SCALE');
      Ini.DeleteKey('Config', 'LS_PERFORMANCE_MODE');
      Ini.DeleteKey('Config', 'LS_HDR_MODE');
      Ini.DeleteKey('Config', 'LS_NO_FP16');
      Ini.DeleteKey('Config', 'LS_PACING');
      Ini.DeleteKey('Config', 'LS_GPU');

      // Prune legacy keys from [Env]
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

      WriteMakoTomlConfig(CfgDir);
    end
    else
    begin
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

      if FileExists(IncludeTrailingPathDelimiter(CfgDir) + 'conf.toml') then
        DeleteFile(IncludeTrailingPathDelimiter(CfgDir) + 'conf.toml');
      if FileExists(IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml') then
        DeleteFile(IncludeTrailingPathDelimiter(CfgDir) + 'lsfg.toml');
    end;
  finally
    Ini.Free;
  end;
end;

end.
