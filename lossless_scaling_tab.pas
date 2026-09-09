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
    OverridePresentMode: Boolean;
    PreserveSwapchainImageCount: Boolean;
    Gpu: string;
  end;

procedure InitDefaultMakoConfig(out ACfg: TMakoConfig);
procedure ParseMakoToml(const AFilePath: string; out ACfg: TMakoConfig);
procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string);
procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string;
  out AOverridePresentMode, APreserveSwapchain: Boolean);

type
  TInterpolationMethod = (imNone, imLsfg, imMako);

type
  { TLosslessScalingTabHelper }

  TLosslessScalingTabHelper = class
  private
    FForm: TForm;
    FLsScrollBox: TScrollBox;
    FLsBgPanel: TPanel;
    
    // Cards
    FLsMethodCard: TPanel;
    FLsGpuCard: TPanel;
    FLsFrameGenCard: TPanel;
    FLsSpatialCard: TPanel;
    FLsStatusCard: TPanel;
    FLsGeneralCard: TPanel;
    
    // Card 0a: Method
    FLsMethodTitleLbl: TLabel;
    FLsNoneRadio: TRadioButton;
    FLsLsfgRadio: TRadioButton;
    FLsMakoRadio: TRadioButton;
    FLsNoneImage: TImage;
    FLsLsfgImage: TImage;
    FLsMakoImage: TImage;
    FLsNoneLbl: TLabel;
    FLsLsfgLbl: TLabel;
    FLsMakoLbl: TLabel;
    FNonePngLogo: TPortableNetworkGraphic;
    FLsfgPngLogo: TPortableNetworkGraphic;
    FMakoPngLogo: TPortableNetworkGraphic;
    FInterpolationMethod: TInterpolationMethod;

    // Card 0b: Target GPU Device
    FLsGpuTitleLbl: TLabel;
    FLsGpuComboBox: TComboBox;

    // Card 3: Software Status (Anchored to Bottom)
    FLsStatusTitleLbl: TLabel;
    FLsDllTitleLbl: TLabel;
    FLsLogoImage: TImage;
    FLsDllPathEdit: TEdit;
    FLsBrowseDllBtn: TBitBtn;
    FLsDllStatusLabel: TLabel;
    
    FLsMakoLogoImage: TImage;
    FLsMakoPathEdit: TEdit;
    FLsEngineStatusLabel: TLabel;
    FLsMakoNoteLabel: TLabel;
    FLsCheckUpdatesBtn: TBitBtn;
    FLsInstallBtn: TBitBtn;
    FLsProgressBar: TProgressBar;
    FLsProgressLabel: TLabel;
    FLsLsfgStatusLabel: TLabel;
    FLsStatDots: array[0..2] of TShape;
    FLsStatNameLbls: array[0..2] of TLabel;
    
    // Migration Alert Card
    FLsMigrationAlertCard: TPanel;
    FLsMigrationAlertIconLbl: TLabel;
    FLsMigrationAlertTitleLbl: TLabel;
    FLsMigrationAlertDescLbl: TLabel;
    FLsMigrationAlertBtn: TBitBtn;

    // Card 1: Frame Generation
    FLsDisabledNoticeLbl: TLabel;
    FLsFgTitleLbl: TLabel;
    FLsFgModeTitleLbl: TLabel;
    FLsFgModeComboBox: TComboBox;
    
    // Mode: Fixed Multiplier
    FLsMultiplierTitleLbl: TLabel;
    FLsMultiplierTrackBar: TTrackBar;
    FLsMultiplierValueLabel: TLabel;
    
    // Mode: Adaptive Multiplier
    FLsTargetFpsTitleLbl: TLabel;
    FLsTargetFpsTrackBar: TTrackBar;
    FLsTargetFpsValueLabel: TLabel;
    FLsAdaptiveMaxMultTitleLbl: TLabel;
    FLsAdaptiveMaxMultComboBox: TComboBox;
    FLsSteady2xCapCheckBox: TCheckBox;
    FLsSteady2xCapToggle: TToggleSwitch;
    FLsSmoothCadenceCheckBox: TCheckBox;
    FLsSmoothCadenceToggle: TToggleSwitch;
    
    // Mode: Advanced Tuning
    FLsFlowScaleTitleLbl: TLabel;
    FLsFlowScaleTrackBar: TTrackBar;
    FLsFlowScaleValueLabel: TLabel;
    FLsBaseFpsCapTitleLbl: TLabel;
    FLsBaseFpsCapTrackBar: TTrackBar;
    FLsBaseFpsCapValueLabel: TLabel;
    FLsRefreshThresholdTitleLbl: TLabel;
    FLsRefreshThresholdTrackBar: TTrackBar;
    FLsRefreshThresholdValueLabel: TLabel;
    FLsFgLiveCheckBox: TCheckBox;
    FLsFgLiveToggle: TToggleSwitch;
    FLsAllowFp16CheckBox: TCheckBox;
    FLsAllowFp16Toggle: TToggleSwitch;
    FLsOverridePresentModeCheckBox: TCheckBox;
    FLsOverridePresentModeToggle: TToggleSwitch;
    FLsPreserveSwapchainCheckBox: TCheckBox;
    FLsPreserveSwapchainToggle: TToggleSwitch;
    FLsPerfModeCheckBox: TCheckBox;
    FLsPerfModeToggle: TToggleSwitch;
    FLsUltraPerfCheckBox: TCheckBox;
    FLsUltraPerfToggle: TToggleSwitch;
    FLsHdrModeCheckBox: TCheckBox;
    FLsHdrModeToggle: TToggleSwitch;
    FLsNoFp16CheckBox: TCheckBox;
    FLsNoFp16Toggle: TToggleSwitch;
    
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
    FLsLsfgInstallBtn: TBitBtn;
    
    // Controls
    FLsPacingTitleLbl: TLabel;
    FLsPacingComboBox: TComboBox;
    
    FCheckingUpdate: Boolean;
    FUpdateCheckedThisSession: Boolean;
    FMakoRemoteVer: string;
    FMakoUpdateAvailable: Boolean;
    FLsfgCheckingUpdate: Boolean;
    FLsfgUpdateCheckedThisSession: Boolean;
    FLsfgRemoteVer: string;
    FLsfgUpdateAvailable: Boolean;
    FLsfgVersionCached: string;
    FMakoVersionCached: string;
    FDetectedSteamDllCached: string;
    FDetectedSteamLsfgDllCached: string;
    FSteamDllDetectedThisSession: Boolean;
    FSteamLsfgDllDetectedThisSession: Boolean;
    
    procedure MethodNoneClick(Sender: TObject);
    procedure MethodLsfgClick(Sender: TObject);
    procedure MethodMakoClick(Sender: TObject);
    procedure UpdateMethodImageOpacity;
    procedure InstallLsfgClick(Sender: TObject);
    function CheckLsfgVkLayerInstalled(out APath: string): Boolean;
    procedure MigrationAlertPaint(Sender: TObject);
    procedure MigrationAlertBtnClick(Sender: TObject);
    
    procedure DllPathChange(Sender: TObject);
    procedure BrowseDllClick(Sender: TObject);
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
    procedure LsScrollBoxResize(Sender: TObject);
    
    procedure PopulateGpuList;
    function GetConfigFile: string;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;
    
    procedure InitLosslessScalingTab;
    procedure ReflowLosslessScalingTab(AContentW: Integer);
    procedure ApplyThemeStyles;
    procedure UpdateDllStatus;
    procedure UpdateStatusCard;
    procedure UpdateEngineStatus;
    procedure UpdateControlsEnabled;
    procedure ControlStateChange(Sender: TObject);
    procedure LoadLosslessConfig;
    procedure SaveLosslessConfig;
    procedure SetInterpolationMethod(AMethod: TInterpolationMethod);
    function GetInterpolationMethod: TInterpolationMethod;
    function GetActiveEnvVars: string;
    function BuildEnvLine: string;
    function WriteMakoTomlConfig(const ATargetDir: string = ''): string;
    function WriteLsfgTomlConfig(const ATargetDir: string = ''): string;
    function WriteDefaultLsfgToml(const ATargetDir: string = ''): string;
    function DetectSteamLosslessDll(ForLsfg: Boolean = False): string;
    function CheckSteamBetaDllHealth(out ADllPath: string): Boolean;
    function CheckLegacySystemLayersHealth(out AFoundFiles: TStringList): Boolean;
    function CheckUserConfigHealth(out AConfigPath: string): Boolean;
    function CheckMigrationHazards(out HasBetaIssue, HasLegacyFiles, HasConfigIssue: Boolean): Boolean;
    function ModernizeUserConfig(out ABackupPath: string): Boolean;
    procedure UpdateMigrationAlertState;
    function GetLsfgVkInstalledVersion(const ALayerJsonPath: string): string;
    function GetLsfgVkLibraryPath(const ALayerJsonPath: string): string;
    function GetStatNameLabel(Index: Integer): TLabel;
    procedure SetMakoUpdateState(const ARemoteVer: string; AAvailable: Boolean);
    procedure SetLsfgUpdateState(const ARemoteVer: string; AAvailable: Boolean);
    
    property InterpolationMethod: TInterpolationMethod read GetInterpolationMethod write SetInterpolationMethod;
    property MethodCard: TPanel read FLsMethodCard;
    property GpuCard: TPanel read FLsGpuCard;
    property FrameGenCard: TPanel read FLsFrameGenCard;
    property StatusCard: TPanel read FLsStatusCard;
    property MigrationAlertCard: TPanel read FLsMigrationAlertCard;
    property MigrationAlertBtn: TBitBtn read FLsMigrationAlertBtn;
    property MigrationAlertDescLbl: TLabel read FLsMigrationAlertDescLbl;
    property NoneRadio: TRadioButton read FLsNoneRadio;
    property LsfgRadio: TRadioButton read FLsLsfgRadio;
    property MakoRadio: TRadioButton read FLsMakoRadio;
    property DisabledNoticeLbl: TLabel read FLsDisabledNoticeLbl;

    property LogoImage: TImage read FLsLogoImage;
    property DllPathEdit: TEdit read FLsDllPathEdit;
    property BrowseDllBtn: TBitBtn read FLsBrowseDllBtn;
    property DllStatusLabel: TLabel read FLsDllStatusLabel;
    property MakoLogoImage: TImage read FLsMakoLogoImage;
    property MakoPathEdit: TEdit read FLsMakoPathEdit;
    property MakoStatusLabel: TLabel read FLsEngineStatusLabel;
    property MakoNoteLabel: TLabel read FLsMakoNoteLabel;
    property MakoRemoteVer: string read FMakoRemoteVer;
    property MakoUpdateAvailable: Boolean read FMakoUpdateAvailable;
    property LsfgRemoteVer: string read FLsfgRemoteVer;
    property LsfgUpdateAvailable: Boolean read FLsfgUpdateAvailable;
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
    property LsfgInstallBtn: TBitBtn read FLsLsfgInstallBtn;
    property OverridePresentModeCheckBox: TCheckBox read FLsOverridePresentModeCheckBox;
    property OverridePresentModeToggle: TToggleSwitch read FLsOverridePresentModeToggle;
    property PreserveSwapchainCheckBox: TCheckBox read FLsPreserveSwapchainCheckBox;
    property PreserveSwapchainToggle: TToggleSwitch read FLsPreserveSwapchainToggle;
    
    property MethodNoneRadio: TRadioButton read FLsNoneRadio;
    property MethodLsfgRadio: TRadioButton read FLsLsfgRadio;
    property MethodMakoRadio: TRadioButton read FLsMakoRadio;
    property MethodNoneImage: TImage read FLsNoneImage;
    property MethodLsfgImage: TImage read FLsLsfgImage;
    property MethodMakoImage: TImage read FLsMakoImage;
    property MethodNoneLabel: TLabel read FLsNoneLbl;
    property MethodLsfgLabel: TLabel read FLsLsfgLbl;
    property MethodMakoLabel: TLabel read FLsMakoLbl;
    property LsfgStatusLabel: TLabel read FLsLsfgStatusLabel;
    property StatNameLabel[Index: Integer]: TLabel read GetStatNameLabel;
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
  optiscaler_update,
  lsfg_migration_dialog,
  Process;

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
  ACfg.OverridePresentMode := True;
  ACfg.PreserveSwapchainImageCount := False;
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
          ACfg.Pacing := LowerCase(Val)
        else if Key = 'override_present_mode' then
          ACfg.OverridePresentMode := (LowerCase(Val) = 'true') or (Val = '1')
        else if Key = 'preserve_swapchain_image_count' then
          ACfg.PreserveSwapchainImageCount := (LowerCase(Val) = 'true') or (Val = '1');
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string);
var
  IgnoredOverride, IgnoredPreserve: Boolean;
begin
  ParseLsfgToml(AFilePath, ADll, AMultiplier, AFlowScale, APerfMode, AHdrMode, ANoFp16, APacing,
    IgnoredOverride, IgnoredPreserve);
end;

procedure ParseLsfgToml(const AFilePath: string; out ADll: string; out AMultiplier: Integer;
  out AFlowScale: Double; out APerfMode, AHdrMode, ANoFp16: Boolean; out APacing: string;
  out AOverridePresentMode, APreserveSwapchain: Boolean);
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
  AOverridePresentMode := Cfg.OverridePresentMode;
  APreserveSwapchain := Cfg.PreserveSwapchainImageCount;
end;

type
  TLsfgVkInstallThread = class(TThread)
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

  TLsfgVkCheckUpdateThread = class(TThread)
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
  FHelper.FMakoVersionCached := '';
  FHelper.FMakoUpdateAvailable := False;
  FHelper.FMakoRemoteVer := '';
  FHelper.UpdateEngineStatus;
  if Assigned(FHelper.FForm) and (FHelper.FForm is Tgoverlayform) then
    Tgoverlayform(FHelper.FForm).RefreshHomeMakoStatus;
  FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
end;

procedure TMakoInstallThread.Execute;
begin
  FSuccess := CheckAndInstallMako(True, @OnProgress);
  Synchronize(@SyncFinished);
end;

constructor TLsfgVkInstallThread.Create(AHelper: TLosslessScalingTabHelper);
begin
  inherited Create(True);
  FHelper := AHelper;
  FreeOnTerminate := True;
end;

procedure TLsfgVkInstallThread.OnProgress(Percentage: Integer; const Status: string);
begin
  FProgressPct := Percentage;
  FProgressStatus := Status;
  Synchronize(@SyncProgress);
end;

procedure TLsfgVkInstallThread.SyncProgress;
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

procedure TLsfgVkInstallThread.SyncFinished;
begin
  if not Assigned(FHelper) then Exit;
  if Assigned(FHelper.FLsProgressBar) then
    FHelper.FLsProgressBar.Visible := False;
  if Assigned(FHelper.FLsProgressLabel) then
    FHelper.FLsProgressLabel.Visible := False;
  if Assigned(FHelper.FLsLsfgInstallBtn) then
    FHelper.FLsLsfgInstallBtn.Enabled := True;
  FHelper.FLsfgVersionCached := '';
  FHelper.UpdateStatusCard;
  if Assigned(FHelper.FForm) and (FHelper.FForm is Tgoverlayform) then
  begin
    Tgoverlayform(FHelper.FForm).RefreshHomeMakoStatus;
    Tgoverlayform(FHelper.FForm).RefreshHomeModuleStatus;
  end;
  FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
end;

procedure TLsfgVkInstallThread.Execute;
begin
  FSuccess := CheckAndInstallLsfgVk(True, @OnProgress);
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
var
  CleanLocal, CleanRemote: string;
begin
  if not Assigned(FHelper) then Exit;
  FHelper.FCheckingUpdate := False;
  if (FRemoteVer <> '') and (FLocalVer <> '') and (FRemoteVer <> FLocalVer) then
  begin
    CleanLocal := FLocalVer;
    CleanRemote := FRemoteVer;
    while (CleanLocal <> '') and (CleanLocal[1] in ['v', 'V']) do
      Delete(CleanLocal, 1, 1);
    while (CleanRemote <> '') and (CleanRemote[1] in ['v', 'V']) do
      Delete(CleanRemote, 1, 1);

    if (CleanRemote <> '') and (CleanRemote <> CleanLocal) then
    begin
      FHelper.FMakoRemoteVer := CleanRemote;
      FHelper.FMakoUpdateAvailable := True;

      if Assigned(FHelper.FLsEngineStatusLabel) then
      begin
        FHelper.FLsEngineStatusLabel.Caption := CleanLocal + ' → ' + CleanRemote;
        FHelper.FLsEngineStatusLabel.Font.Color := $0044AAFF;
      end;
      if Assigned(FHelper.FLsInstallBtn) then
      begin
        FHelper.FLsInstallBtn.Caption := 'Install update';
        FHelper.FLsInstallBtn.Visible := True;
        FHelper.FLsInstallBtn.Enabled := True;
      end;
      FHelper.UpdateStatusCard;
      if Assigned(FHelper.FForm) and (FHelper.FForm is Tgoverlayform) then
        Tgoverlayform(FHelper.FForm).RefreshHomeMakoStatus;
      FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
    end;
  end;
end;

constructor TLsfgVkCheckUpdateThread.Create(AHelper: TLosslessScalingTabHelper);
begin
  inherited Create(True);
  FHelper := AHelper;
  FreeOnTerminate := True;
end;

procedure TLsfgVkCheckUpdateThread.Execute;
var
  DummyUrl: string;
begin
  FLocalVer := GetLsfgVkInstalledVersion;
  FRemoteVer := GetLsfgVkLatestRemoteVersion(DummyUrl);
  Synchronize(@SyncResult);
end;

procedure TLsfgVkCheckUpdateThread.SyncResult;
var
  CleanLocal, CleanRemote: string;
begin
  if not Assigned(FHelper) then Exit;
  FHelper.FLsfgCheckingUpdate := False;
  if (FRemoteVer <> '') and (FLocalVer <> '') and (FRemoteVer <> FLocalVer) then
  begin
    CleanLocal := FLocalVer;
    CleanRemote := FRemoteVer;
    while (CleanLocal <> '') and (CleanLocal[1] in ['v', 'V']) do
      Delete(CleanLocal, 1, 1);
    while (CleanRemote <> '') and (CleanRemote[1] in ['v', 'V']) do
      Delete(CleanRemote, 1, 1);

    if (CleanRemote <> '') and (CleanRemote <> CleanLocal) then
    begin
      FHelper.FLsfgRemoteVer := CleanRemote;
      FHelper.FLsfgUpdateAvailable := True;

      if Assigned(FHelper.FLsLsfgStatusLabel) then
      begin
        FHelper.FLsLsfgStatusLabel.Caption := CleanLocal + ' → ' + CleanRemote;
        FHelper.FLsLsfgStatusLabel.Font.Color := $0044AAFF;
      end;
      if Assigned(FHelper.FLsLsfgInstallBtn) then
      begin
        FHelper.FLsLsfgInstallBtn.Caption := 'Install update';
        FHelper.FLsLsfgInstallBtn.Visible := not IsRunningInFlatpak;
        FHelper.FLsLsfgInstallBtn.Enabled := True;
      end;
      FHelper.UpdateStatusCard;
      if Assigned(FHelper.FForm) and (FHelper.FForm is Tgoverlayform) then
      begin
        Tgoverlayform(FHelper.FForm).RefreshHomeMakoStatus;
        Tgoverlayform(FHelper.FForm).RefreshHomeModuleStatus;
      end;
      FHelper.ReflowLosslessScalingTab(FHelper.FLsScrollBox.ClientWidth);
    end;
  end;
end;

function TLosslessScalingTabHelper.GetStatNameLabel(Index: Integer): TLabel;
begin
  if (Index >= 0) and (Index <= 2) then
    Result := FLsStatNameLbls[Index]
  else
    Result := nil;
end;

procedure TLosslessScalingTabHelper.SetMakoUpdateState(const ARemoteVer: string; AAvailable: Boolean);
begin
  FMakoRemoteVer := ARemoteVer;
  FMakoUpdateAvailable := AAvailable;
  if AAvailable then
  begin
    FLsfgUpdateAvailable := False;
    FInterpolationMethod := imMako;
  end;
  UpdateEngineStatus;
  UpdateStatusCard;
  if Assigned(FForm) and (FForm is Tgoverlayform) then
  begin
    Tgoverlayform(FForm).RefreshHomeMakoStatus;
    Tgoverlayform(FForm).RefreshHomeModuleStatus;
  end;
end;

procedure TLosslessScalingTabHelper.SetLsfgUpdateState(const ARemoteVer: string; AAvailable: Boolean);
begin
  FLsfgRemoteVer := ARemoteVer;
  FLsfgUpdateAvailable := AAvailable;
  if AAvailable then
  begin
    FMakoUpdateAvailable := False;
    FInterpolationMethod := imLsfg;
  end;
  UpdateStatusCard;
  if Assigned(FForm) and (FForm is Tgoverlayform) then
  begin
    Tgoverlayform(FForm).RefreshHomeMakoStatus;
    Tgoverlayform(FForm).RefreshHomeModuleStatus;
  end;
end;

constructor TLosslessScalingTabHelper.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
  FMakoRemoteVer := '';
  FMakoUpdateAvailable := False;
  FLsfgRemoteVer := '';
  FLsfgUpdateAvailable := False;
  FLsfgCheckingUpdate := False;
  FLsfgUpdateCheckedThisSession := False;
end;

destructor TLosslessScalingTabHelper.Destroy;
begin
  if Assigned(FNonePngLogo) then FNonePngLogo.Free;
  if Assigned(FLsfgPngLogo) then FLsfgPngLogo.Free;
  if Assigned(FMakoPngLogo) then FMakoPngLogo.Free;
  inherited Destroy;
end;

procedure TLosslessScalingTabHelper.MethodNoneClick(Sender: TObject);
begin
  SetInterpolationMethod(imNone);
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.MethodLsfgClick(Sender: TObject);
begin
  SetInterpolationMethod(imLsfg);
  if Assigned(FLsMultiplierTrackBar) and (FLsMultiplierTrackBar.Position <= 1) then
  begin
    FLsMultiplierTrackBar.Position := 2;
    if Assigned(FLsMultiplierValueLabel) then
      FLsMultiplierValueLabel.Caption := '2x';
  end;
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.MethodMakoClick(Sender: TObject);
begin
  SetInterpolationMethod(imMako);
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.SetInterpolationMethod(AMethod: TInterpolationMethod);
var
  CurDll: string;
begin
  FInterpolationMethod := AMethod;
  if Assigned(FLsNoneRadio) then FLsNoneRadio.Checked := (AMethod = imNone);
  if Assigned(FLsLsfgRadio) then FLsLsfgRadio.Checked := (AMethod = imLsfg);
  if Assigned(FLsMakoRadio) then FLsMakoRadio.Checked := (AMethod = imMako);

  if Assigned(FLsDllPathEdit) then
  begin
    CurDll := Trim(FLsDllPathEdit.Text);
    if AMethod = imLsfg then
    begin
      if CurDll <> '' then
      begin
        if SameText(ExtractFileName(CurDll), 'Lossless.dll') then
          FLsDllPathEdit.Text := ExtractFilePath(CurDll) + 'lsfg-vk.dll';
      end
      else
        FLsDllPathEdit.Text := DetectSteamLosslessDll(True);
      FLsDllPathEdit.TextHint := 'Path to lsfg-vk.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll)';
      if Assigned(FLsBrowseDllBtn) then
      begin
        FLsBrowseDllBtn.Hint := 'Browse for lsfg-vk.dll';
        FLsBrowseDllBtn.ShowHint := True;
      end;
    end
    else if AMethod = imMako then
    begin
      if CurDll <> '' then
      begin
        if SameText(ExtractFileName(CurDll), 'lsfg-vk.dll') then
          FLsDllPathEdit.Text := ExtractFilePath(CurDll) + 'Lossless.dll';
      end
      else
        FLsDllPathEdit.Text := DetectSteamLosslessDll(False);
      FLsDllPathEdit.TextHint := 'Path to Lossless.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll)';
      if Assigned(FLsBrowseDllBtn) then
      begin
        FLsBrowseDllBtn.Hint := 'Browse for Lossless.dll';
        FLsBrowseDllBtn.ShowHint := True;
      end;
    end;
  end;

  if not (Assigned(FForm) and (FForm is Tgoverlayform) and Tgoverlayform(FForm).FLoadingConfig) then
  begin
    if (AMethod in [imLsfg, imMako]) and Assigned(FLsMultiplierTrackBar) and (FLsMultiplierTrackBar.Position < 1) then
    begin
      FLsMultiplierTrackBar.Position := 2;
      if Assigned(FLsMultiplierValueLabel) then
        FLsMultiplierValueLabel.Caption := '2x';
    end
    else if (AMethod = imNone) and Assigned(FLsMultiplierTrackBar) then
    begin
      FLsMultiplierTrackBar.Position := 1;
      if Assigned(FLsMultiplierValueLabel) then
        FLsMultiplierValueLabel.Caption := '1x (Disabled)';
    end;
  end;

  if Assigned(FLsMultiplierTrackBar) and Assigned(FLsMultiplierValueLabel) then
  begin
    if (FLsMultiplierTrackBar.Position <= 1) and (AMethod = imLsfg) then
      FLsMultiplierValueLabel.Caption := '1x (Bypass)'
    else if (FLsMultiplierTrackBar.Position <= 1) then
      FLsMultiplierValueLabel.Caption := '1x (Disabled)'
    else
      FLsMultiplierValueLabel.Caption := IntToStr(FLsMultiplierTrackBar.Position) + 'x FPS';
  end;

  UpdateMethodImageOpacity;
  UpdateControlsEnabled;
  UpdateDllStatus;
  UpdateStatusCard;
  UpdateMigrationAlertState;
  if Assigned(FLsScrollBox) then
    ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
end;

function TLosslessScalingTabHelper.GetInterpolationMethod: TInterpolationMethod;
begin
  Result := FInterpolationMethod;
end;

procedure TLosslessScalingTabHelper.UpdateMethodImageOpacity;
begin
  if Assigned(FLsNoneImage) and Assigned(FLsNoneRadio) then
    FLsNoneImage.Enabled := FLsNoneRadio.Checked;
  if Assigned(FLsLsfgImage) and Assigned(FLsLsfgRadio) then
    FLsLsfgImage.Enabled := FLsLsfgRadio.Checked;
  if Assigned(FLsMakoImage) and Assigned(FLsMakoRadio) then
    FLsMakoImage.Enabled := FLsMakoRadio.Checked;

  if Assigned(FLsNoneLbl) then
  begin
    if Assigned(FLsNoneRadio) and FLsNoneRadio.Checked then
      FLsNoneLbl.Font.Color := clWhite
    else
      FLsNoneLbl.Font.Color := $00888888;
  end;
  if Assigned(FLsLsfgLbl) then
  begin
    if Assigned(FLsLsfgRadio) and FLsLsfgRadio.Checked then
      FLsLsfgLbl.Font.Color := clWhite
    else
      FLsLsfgLbl.Font.Color := $00888888;
  end;
  if Assigned(FLsMakoLbl) then
  begin
    if Assigned(FLsMakoRadio) and FLsMakoRadio.Checked then
      FLsMakoLbl.Font.Color := clWhite
    else
      FLsMakoLbl.Font.Color := $00888888;
  end;
end;

function TLosslessScalingTabHelper.CheckLsfgVkLayerInstalled(out APath: string): Boolean;
var
  HomeDir, UserLayerDir: string;
begin
  APath := '';
  HomeDir := GetUserDir;
  UserLayerDir := IncludeTrailingPathDelimiter(HomeDir) + '.local/share/vulkan/implicit_layer.d/';

  if FileExists(UserLayerDir + 'VkLayer_LSFGVK_frame_generation.json') then
    APath := UserLayerDir + 'VkLayer_LSFGVK_frame_generation.json'
  else if FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') then
    APath := '/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json'
  else if FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') then
    APath := '/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json'
  else if FileExists('/usr/local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') then
    APath := '/usr/local/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json'
  else if FileExists('/app/lib/extensions/vulkan/lsfgvk/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json') then
    APath := '/app/lib/extensions/vulkan/lsfgvk/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json'
  else if FileExists(UserLayerDir + 'VkLayer_LS_frame_generation.json') then
    APath := UserLayerDir + 'VkLayer_LS_frame_generation.json'
  else if FileExists(UserLayerDir + 'VkLayer_LSFGVK.json') then
    APath := UserLayerDir + 'VkLayer_LSFGVK.json'
  else if FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') then
    APath := '/usr/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json'
  else if FileExists('/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') then
    APath := '/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK.json'
  else if FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json') then
    APath := '/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json'
  else if FileExists('/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK.json') then
    APath := '/etc/vulkan/implicit_layer.d/VkLayer_LSFGVK.json';

  Result := APath <> '';
end;

function TLosslessScalingTabHelper.GetLsfgVkInstalledVersion(const ALayerJsonPath: string): string;
var
  RawVer: string;
begin
  if FLsfgVersionCached <> '' then
    Exit(FLsfgVersionCached);

  RawVer := optiscaler_update.GetLsfgVkInstalledVersion;
  if RawVer <> '' then
  begin
    FLsfgVersionCached := RawVer;
    Exit(RawVer);
  end;

  FLsfgVersionCached := 'Installed';
  Result := 'Installed';
end;

function TLosslessScalingTabHelper.GetLsfgVkLibraryPath(const ALayerJsonPath: string): string;
var
  Candidate: string;
begin
  Candidate := optiscaler_update.GetLsfgVkLibraryPath;
  if Candidate <> '' then Exit(Candidate);
  Result := ALayerJsonPath;
end;

procedure TLosslessScalingTabHelper.UpdateStatusCard;
var
  DllP, MakoVer, MakoLib, LsfgPath, LsfgVer, LsfgLib: string;
  HasLsfg: Boolean;
const
  CLR_OK   = $0044BB44;
  CLR_NONE = $00666666;
  PURPLE   = $BB99FF;
begin
  if not Assigned(FLsStatDots[0]) then Exit;

  // 0: Lossless Scaling library
  if Assigned(FLsDllPathEdit) then
    DllP := Trim(FLsDllPathEdit.Text)
  else
    DllP := '';

  if (DllP <> '') and FileExists(DllP) then
    FLsStatDots[0].Brush.Color := CLR_OK
  else
    FLsStatDots[0].Brush.Color := CLR_NONE;

  if Assigned(FLsStatNameLbls[0]) then
    FLsStatNameLbls[0].Caption := 'Lossless Scaling';

  // 1: MAKO
  if FMakoVersionCached <> '' then
    MakoVer := FMakoVersionCached
  else
  begin
    MakoVer := GetMakoInstalledVersion;
    while (MakoVer <> '') and (MakoVer[1] in ['v', 'V']) do
      Delete(MakoVer, 1, 1);
    FMakoVersionCached := MakoVer;
  end;
  MakoLib := GetMakoLibraryPath;

  if MakoVer <> '' then
  begin
    FLsStatDots[1].Brush.Color := CLR_OK;
    if Assigned(FLsEngineStatusLabel) then
    begin
      if FMakoUpdateAvailable and (FMakoRemoteVer <> '') and (FMakoRemoteVer <> MakoVer) then
      begin
        FLsEngineStatusLabel.Caption := MakoVer + ' → ' + FMakoRemoteVer;
        FLsEngineStatusLabel.Font.Color := $0044AAFF;
      end
      else
      begin
        FLsEngineStatusLabel.Caption := MakoVer;
        FLsEngineStatusLabel.Font.Color := PURPLE;
      end;
      FLsEngineStatusLabel.Hint := MakoLib;
      FLsEngineStatusLabel.ShowHint := (MakoLib <> '');
    end;
  end
  else if IsMakoInstalled then
  begin
    FLsStatDots[1].Brush.Color := CLR_OK;
    if Assigned(FLsEngineStatusLabel) then
    begin
      FLsEngineStatusLabel.Caption := 'Installed';
      FLsEngineStatusLabel.Font.Color := PURPLE;
      FLsEngineStatusLabel.Hint := MakoLib;
      FLsEngineStatusLabel.ShowHint := (MakoLib <> '');
    end;
  end
  else
  begin
    FLsStatDots[1].Brush.Color := CLR_NONE;
    if Assigned(FLsEngineStatusLabel) then
    begin
      FLsEngineStatusLabel.Caption := 'Not installed';
      FLsEngineStatusLabel.Font.Color := RGBToColor(255, 90, 95);
      FLsEngineStatusLabel.Hint := '';
      FLsEngineStatusLabel.ShowHint := False;
    end;
  end;

  if Assigned(FLsEngineStatusLabel) and Assigned(FLsMakoNoteLabel) then
  begin
    FLsEngineStatusLabel.AdjustSize;
    FLsMakoNoteLabel.AdjustSize;
    FLsMakoNoteLabel.Left := FLsEngineStatusLabel.Left + FLsEngineStatusLabel.Width + 8;
    FLsMakoNoteLabel.Top := FLsEngineStatusLabel.Top;
  end;

  // 2: lsfg-vk layer
  HasLsfg := CheckLsfgVkLayerInstalled(LsfgPath);
  if HasLsfg then
  begin
    if FLsfgVersionCached <> '' then
      LsfgVer := FLsfgVersionCached
    else
    begin
      LsfgVer := GetLsfgVkInstalledVersion(LsfgPath);
      while (LsfgVer <> '') and (LsfgVer[1] in ['v', 'V']) do
        Delete(LsfgVer, 1, 1);
      FLsfgVersionCached := LsfgVer;
    end;
    LsfgLib := GetLsfgVkLibraryPath(LsfgPath);
    FLsStatDots[2].Brush.Color := CLR_OK;
    if Assigned(FLsLsfgStatusLabel) then
    begin
      if FLsfgUpdateAvailable and (FLsfgRemoteVer <> '') and (FLsfgRemoteVer <> LsfgVer) then
      begin
        FLsLsfgStatusLabel.Caption := LsfgVer + ' → ' + FLsfgRemoteVer;
        FLsLsfgStatusLabel.Font.Color := $0044AAFF;
      end
      else
      begin
        if LsfgVer <> '' then
          FLsLsfgStatusLabel.Caption := LsfgVer
        else
          FLsLsfgStatusLabel.Caption := 'Installed';
        FLsLsfgStatusLabel.Font.Color := PURPLE;
      end;
      FLsLsfgStatusLabel.Hint := LsfgLib;
      FLsLsfgStatusLabel.ShowHint := (LsfgLib <> '');
    end;

    if FLsfgUpdateAvailable and (FLsfgRemoteVer <> '') and (FLsfgRemoteVer <> LsfgVer) then
    begin
      if Assigned(FLsLsfgInstallBtn) then
      begin
        FLsLsfgInstallBtn.Caption := 'Install update';
        FLsLsfgInstallBtn.Visible := not IsRunningInFlatpak;
        FLsLsfgInstallBtn.Enabled := True;
      end;
    end
    else
    begin
      if Assigned(FLsLsfgInstallBtn) then
        FLsLsfgInstallBtn.Visible := False;
    end;
  end
  else
  begin
    FLsStatDots[2].Brush.Color := CLR_NONE;
    if Assigned(FLsLsfgStatusLabel) then
    begin
      FLsLsfgStatusLabel.Caption := 'Not installed';
      FLsLsfgStatusLabel.Font.Color := RGBToColor(255, 90, 95);
      FLsLsfgStatusLabel.Hint := '';
      FLsLsfgStatusLabel.ShowHint := False;
    end;
    if Assigned(FLsLsfgInstallBtn) then
    begin
      FLsLsfgInstallBtn.Caption := 'Install runtime';
      FLsLsfgInstallBtn.Visible := not IsRunningInFlatpak;
      FLsLsfgInstallBtn.Enabled := True;
    end;
  end;
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

function TLosslessScalingTabHelper.DetectSteamLosslessDll(ForLsfg: Boolean): string;
const
  RelDllMako = 'common/Lossless Scaling/Lossless.dll';
  RelDllLsfg = 'common/Lossless Scaling/lsfg-vk.dll';
var
  Libs: TStringList;
  i: Integer;
  CandidateMako, CandidateLsfg, FallbackDir: string;
begin
  if ForLsfg and FSteamLsfgDllDetectedThisSession then
    Exit(FDetectedSteamLsfgDllCached);
  if (not ForLsfg) and FSteamDllDetectedThisSession then
    Exit(FDetectedSteamDllCached);

  Result := '';
  FallbackDir := '';
  Libs := TStringList.Create;
  try
    Tgoverlayform(FForm).GetSteamLibraries(Libs);
    for i := 0 to Libs.Count - 1 do
    begin
      CandidateMako := IncludeTrailingPathDelimiter(Libs[i]) + RelDllMako;
      CandidateLsfg := IncludeTrailingPathDelimiter(Libs[i]) + RelDllLsfg;
      if FileExists(CandidateLsfg) and ForLsfg then
      begin
        FDetectedSteamLsfgDllCached := CandidateLsfg;
        FSteamLsfgDllDetectedThisSession := True;
        Exit(CandidateLsfg);
      end;
      if FileExists(CandidateMako) then
      begin
        if FallbackDir = '' then FallbackDir := ExtractFilePath(CandidateMako);
        if not ForLsfg then
        begin
          FDetectedSteamDllCached := CandidateMako;
          FSteamDllDetectedThisSession := True;
          Exit(CandidateMako);
        end;
      end;
    end;
  finally
    Libs.Free;
  end;
  
  // Direct fallback checks
  CandidateMako := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/Steam/steamapps/' + RelDllMako;
  CandidateLsfg := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/Steam/steamapps/' + RelDllLsfg;
  if FileExists(CandidateLsfg) and ForLsfg then
  begin
    FDetectedSteamLsfgDllCached := CandidateLsfg;
    FSteamLsfgDllDetectedThisSession := True;
    Exit(CandidateLsfg);
  end;
  if FileExists(CandidateMako) then
  begin
    if FallbackDir = '' then FallbackDir := ExtractFilePath(CandidateMako);
    if not ForLsfg then
    begin
      FDetectedSteamDllCached := CandidateMako;
      FSteamDllDetectedThisSession := True;
      Exit(CandidateMako);
    end;
  end;
  
  CandidateMako := IncludeTrailingPathDelimiter(GetUserDir) + '.steam/steam/steamapps/' + RelDllMako;
  CandidateLsfg := IncludeTrailingPathDelimiter(GetUserDir) + '.steam/steam/steamapps/' + RelDllLsfg;
  if FileExists(CandidateLsfg) and ForLsfg then
  begin
    FDetectedSteamLsfgDllCached := CandidateLsfg;
    FSteamLsfgDllDetectedThisSession := True;
    Exit(CandidateLsfg);
  end;
  if FileExists(CandidateMako) then
  begin
    if FallbackDir = '' then FallbackDir := ExtractFilePath(CandidateMako);
    if not ForLsfg then
    begin
      FDetectedSteamDllCached := CandidateMako;
      FSteamDllDetectedThisSession := True;
      Exit(CandidateMako);
    end;
  end;
  
  CandidateMako := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/' + RelDllMako;
  CandidateLsfg := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/' + RelDllLsfg;
  if FileExists(CandidateLsfg) and ForLsfg then
  begin
    FDetectedSteamLsfgDllCached := CandidateLsfg;
    FSteamLsfgDllDetectedThisSession := True;
    Exit(CandidateLsfg);
  end;
  if FileExists(CandidateMako) then
  begin
    if FallbackDir = '' then FallbackDir := ExtractFilePath(CandidateMako);
    if not ForLsfg then
    begin
      FDetectedSteamDllCached := CandidateMako;
      FSteamDllDetectedThisSession := True;
      Exit(CandidateMako);
    end;
  end;

  if ForLsfg then
  begin
    if FallbackDir <> '' then
      Result := FallbackDir + 'lsfg-vk.dll'
    else
      Result := '';
    FDetectedSteamLsfgDllCached := Result;
    FSteamLsfgDllDetectedThisSession := True;
  end
  else
  begin
    if FallbackDir <> '' then
      Result := FallbackDir + 'Lossless.dll'
    else
      Result := '';
    FDetectedSteamDllCached := Result;
    FSteamDllDetectedThisSession := True;
  end;
end;

function TLosslessScalingTabHelper.CheckSteamBetaDllHealth(out ADllPath: string): Boolean;
var
  TargetDll, AltDll, BaseDir: string;
begin
  Result := False;
  ADllPath := '';
  TargetDll := Trim(FLsDllPathEdit.Text);
  if (TargetDll <> '') and SameText(ExtractFileName(TargetDll), 'lsfg-vk.dll') then
    BaseDir := ExtractFilePath(TargetDll)
  else
  begin
    AltDll := DetectSteamLosslessDll(False);
    if AltDll <> '' then
      BaseDir := ExtractFilePath(AltDll)
    else
      BaseDir := '';
  end;

  if BaseDir <> '' then
  begin
    ADllPath := BaseDir + 'lsfg-vk.dll';
    if FileExists(BaseDir + 'Lossless.dll') and not FileExists(ADllPath) then
      Result := True;
  end;
end;

function TLosslessScalingTabHelper.CheckLegacySystemLayersHealth(out AFoundFiles: TStringList): Boolean;
var
  CandidatePaths: array[0..5] of string;
  i: Integer;
  P: string;
begin
  Result := False;
  if not Assigned(AFoundFiles) then
    AFoundFiles := TStringList.Create;
  AFoundFiles.Clear;
  CandidatePaths[0] := '/etc/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json';
  CandidatePaths[1] := '/usr/lib/liblsfg-vk.so';
  CandidatePaths[2] := '/usr/lib64/liblsfg-vk.so';
  CandidatePaths[3] := '/usr/bin/lsfg-vk-ui';
  CandidatePaths[4] := '/usr/share/applications/lsfg-vk-ui.desktop';
  CandidatePaths[5] := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d/VkLayer_LS_frame_generation.json';

  for i := 0 to High(CandidatePaths) do
  begin
    P := CandidatePaths[i];
    if FileExists(P) then
    begin
      AFoundFiles.Add(P);
      Result := True;
    end;
  end;
end;

function TLosslessScalingTabHelper.CheckUserConfigHealth(out AConfigPath: string): Boolean;
var
  UserCfg: string;
  Lines: TStringList;
  Content: string;
begin
  Result := False;
  UserCfg := IncludeTrailingPathDelimiter(GetUserDir) + '.config/lsfg-vk/conf.toml';
  AConfigPath := UserCfg;
  if not FileExists(UserCfg) then Exit;

  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(UserCfg);
      Content := Lines.Text;
      if (Pos('version = 1', Content) > 0) or (Pos('[[game]]', Content) > 0) then
        Result := True
      else if (Pos('version = 2', Content) = 0) and (Pos('[[profile]]', Content) = 0) then
        Result := True;
    except
      Result := False;
    end;
  finally
    Lines.Free;
  end;
end;

function TLosslessScalingTabHelper.CheckMigrationHazards(out HasBetaIssue, HasLegacyFiles, HasConfigIssue: Boolean): Boolean;
var
  DllP, CfgP: string;
  FoundList: TStringList;
begin
  FoundList := TStringList.Create;
  try
    HasBetaIssue := CheckSteamBetaDllHealth(DllP);
    HasLegacyFiles := CheckLegacySystemLayersHealth(FoundList);
    HasConfigIssue := CheckUserConfigHealth(CfgP);
    Result := HasBetaIssue or HasLegacyFiles or HasConfigIssue;
  finally
    FoundList.Free;
  end;
end;

function TLosslessScalingTabHelper.ModernizeUserConfig(out ABackupPath: string): Boolean;
var
  UserCfg, BackupFile, DllP, CfgDir: string;
  Lines: TStringList;
begin
  Result := False;
  ABackupPath := '';
  CfgDir := IncludeTrailingPathDelimiter(GetUserDir) + '.config/lsfg-vk';
  if not DirectoryExists(CfgDir) then
    ForceDirectories(CfgDir);
  UserCfg := CfgDir + PathDelim + 'conf.toml';

  if FileExists(UserCfg) then
  begin
    BackupFile := UserCfg + '.v1.bak';
    if FileExists(BackupFile) then
      DeleteFile(BackupFile);
    if not RenameFile(UserCfg, BackupFile) then
    begin
      Lines := TStringList.Create;
      try
        Lines.LoadFromFile(UserCfg);
        Lines.SaveToFile(BackupFile);
        DeleteFile(UserCfg);
      finally
        Lines.Free;
      end;
    end;
    ABackupPath := BackupFile;
  end;

  DllP := Trim(FLsDllPathEdit.Text);
  if SameText(ExtractFileName(DllP), 'Lossless.dll') then
    DllP := ExtractFilePath(DllP) + 'lsfg-vk.dll';
  if (DllP = '') or not FileExists(DllP) then
    DllP := DetectSteamLosslessDll(True);

  Lines := TStringList.Create;
  try
    Lines.Add('version = 2');
    Lines.Add('');
    Lines.Add('[global]');
    if (DllP <> '') and FileExists(DllP) then
      Lines.Add('dll = "' + DllP + '"')
    else
      Lines.Add('# dll = "/path/to/lsfg-vk.dll"');
    Lines.Add('allow_fp16 = true');
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "pascube"');
    Lines.Add('active_in = ["pascube"]');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('pacing = "vsync"');
    Lines.Add('override_present_mode = true');
    Lines.Add('preserve_swapchain_image_count = false');
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "vkcube"');
    Lines.Add('active_in = ["vkcube"]');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('pacing = "vsync"');
    Lines.Add('override_present_mode = true');
    Lines.Add('preserve_swapchain_image_count = false');
    Lines.SaveToFile(UserCfg);
    Result := True;
  finally
    Lines.Free;
  end;
end;

procedure TLosslessScalingTabHelper.UpdateMigrationAlertState;
var
  HasBeta, HasLegacy, HasCfg, AnyHazard: Boolean;
  Reasons: string;
begin
  if not Assigned(FLsMigrationAlertCard) then Exit;

  if FInterpolationMethod <> imLsfg then
  begin
    if FLsMigrationAlertCard.Visible then
    begin
      FLsMigrationAlertCard.Visible := False;
      if Assigned(FLsScrollBox) then
        ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
    end;
    Exit;
  end;

  AnyHazard := CheckMigrationHazards(HasBeta, HasLegacy, HasCfg);
  if FLsMigrationAlertCard.Visible <> AnyHazard then
  begin
    FLsMigrationAlertCard.Visible := AnyHazard;
    if Assigned(FLsScrollBox) then
      ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
  end;

  if AnyHazard then
  begin
    Reasons := '';
    if HasBeta then
      Reasons := Reasons + 'Steam beta branch missing (lsfg-vk.dll). ';
    if HasLegacy then
      Reasons := Reasons + 'Conflicting 1.x layers detected. ';
    if HasCfg then
      Reasons := Reasons + 'Legacy user config detected.';

    if Assigned(FLsMigrationAlertDescLbl) then
      FLsMigrationAlertDescLbl.Caption := Trim(Reasons);
  end;
end;

procedure TLosslessScalingTabHelper.MigrationAlertPaint(Sender: TObject);
var
  P: TPanel;
begin
  if not (Sender is TPanel) then Exit;
  P := TPanel(Sender);
  P.Canvas.Brush.Color := P.Color;
  P.Canvas.Pen.Color := RGBToColor(245, 158, 11);
  P.Canvas.Pen.Width := 1;
  P.Canvas.RoundRect(0, 0, P.Width - 1, P.Height - 1, 8, 8);
end;

procedure TLosslessScalingTabHelper.MigrationAlertBtnClick(Sender: TObject);
begin
  ShowLsfgMigrationDialog(FForm, Self);
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
  SS, GbSS: WideString;
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
  if Assigned(FLsMethodCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsMethodCard);
  if Assigned(FLsGpuCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsGpuCard);
  if Assigned(FLsStatusCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsStatusCard);
  if Assigned(FLsGeneralCard) and (FLsGeneralCard <> FLsStatusCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsGeneralCard);
  if Assigned(FLsFrameGenCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsFrameGenCard);
  if Assigned(FLsSpatialCard) then
    Tgoverlayform(FForm).UpdateGenericCardTheme(FLsSpatialCard);

  if Assigned(FLsMethodCard) and FLsMethodCard.HandleAllocated then
  begin
    GbSS := '';
    QWidget_setStyleSheet(TQtWidget(FLsMethodCard.Handle).Widget, @GbSS);
  end;

  UpdateMethodImageOpacity;

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
  if Assigned(FLsMakoNoteLabel) then FLsMakoNoteLabel.Font.Color := HintColor;

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
  if Assigned(FLsCheckUpdatesBtn) and FLsCheckUpdatesBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsCheckUpdatesBtn.Handle).Widget, @SS);
  if Assigned(FLsInstallBtn) and FLsInstallBtn.HandleAllocated then
    QWidget_setStyleSheet(TQtWidget(FLsInstallBtn.Handle).Widget, @SS);
end;

procedure TLosslessScalingTabHelper.InitLosslessScalingTab;
var
  Tab: TTabSheet;
  IconPath: string;
  i: Integer;
  Dot: TShape;
  NLbl: TLabel;
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
  
  // ── Migration Alert Banner Card ──────────────────────────────────────────
  FLsMigrationAlertCard := TPanel.Create(FForm);
  FLsMigrationAlertCard.Parent := FLsBgPanel;
  FLsMigrationAlertCard.Caption := '';
  FLsMigrationAlertCard.BevelOuter := bvNone;
  FLsMigrationAlertCard.Color := RGBToColor(42, 28, 14);
  FLsMigrationAlertCard.Visible := False;
  FLsMigrationAlertCard.OnPaint := @MigrationAlertPaint;

  FLsMigrationAlertIconLbl := TLabel.Create(FLsMigrationAlertCard);
  FLsMigrationAlertIconLbl.Parent := FLsMigrationAlertCard;
  FLsMigrationAlertIconLbl.Caption := '⚠';
  FLsMigrationAlertIconLbl.Font.Size := 14;
  FLsMigrationAlertIconLbl.Font.Style := [fsBold];
  FLsMigrationAlertIconLbl.Font.Color := RGBToColor(245, 158, 11);
  FLsMigrationAlertIconLbl.AutoSize := True;

  FLsMigrationAlertTitleLbl := TLabel.Create(FLsMigrationAlertCard);
  FLsMigrationAlertTitleLbl.Parent := FLsMigrationAlertCard;
  FLsMigrationAlertTitleLbl.Caption := 'lsfg-vk 2.0 Migration Hazards Detected';
  FLsMigrationAlertTitleLbl.Font.Size := 9;
  FLsMigrationAlertTitleLbl.Font.Style := [fsBold];
  FLsMigrationAlertTitleLbl.Font.Color := clWhite;
  FLsMigrationAlertTitleLbl.AutoSize := True;

  FLsMigrationAlertDescLbl := TLabel.Create(FLsMigrationAlertCard);
  FLsMigrationAlertDescLbl.Parent := FLsMigrationAlertCard;
  FLsMigrationAlertDescLbl.Caption := 'Steam beta branch missing (lsfg-vk.dll) or legacy 1.x files found.';
  FLsMigrationAlertDescLbl.Font.Size := 8;
  FLsMigrationAlertDescLbl.Font.Color := RGBToColor(220, 205, 190);
  FLsMigrationAlertDescLbl.AutoSize := True;

  FLsMigrationAlertBtn := TBitBtn.Create(FLsMigrationAlertCard);
  FLsMigrationAlertBtn.Parent := FLsMigrationAlertCard;
  FLsMigrationAlertBtn.Caption := 'Migration Assistant';
  FLsMigrationAlertBtn.Cursor := crHandPoint;
  FLsMigrationAlertBtn.OnClick := @MigrationAlertBtnClick;
  StyleActionButton(FLsMigrationAlertBtn);

  // ── Card 0a: Method (Top Left 50%) ────────────────────────────────────────
  FLsMethodCard := TPanel.Create(FForm);
  FLsMethodCard.Parent := FLsBgPanel;
  FLsMethodCard.Caption := '';
  FLsMethodCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsMethodTitleLbl := TLabel.Create(FLsMethodCard);
  FLsMethodTitleLbl.Parent := FLsMethodCard;
  FLsMethodTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsMethodCard, FLsMethodTitleLbl, 'Method');

  // Method Option 1: None
  FLsNoneRadio := TRadioButton.Create(FForm);
  FLsNoneRadio.Parent := FLsMethodCard;
  FLsNoneRadio.Caption := '';
  FLsNoneRadio.Checked := False;
  FLsNoneRadio.OnClick := @MethodNoneClick;
  StyleToggleControl(FLsNoneRadio);

  FLsNoneImage := TImage.Create(FForm);
  FLsNoneImage.Parent := FLsMethodCard;
  FLsNoneImage.AntialiasingMode := amOn;
  FLsNoneImage.StretchInEnabled := True;
  FLsNoneImage.StretchOutEnabled := True;
  FLsNoneImage.Transparent := True;
  FLsNoneImage.Center := True;
  FLsNoneImage.Proportional := True;
  FLsNoneImage.Stretch := True;
  FLsNoneImage.Cursor := crHandPoint;
  FLsNoneImage.OnClick := @MethodNoneClick;

  FLsNoneLbl := TLabel.Create(FForm);
  FLsNoneLbl.Parent := FLsMethodCard;
  FLsNoneLbl.Caption := 'None';
  FLsNoneLbl.Font.Style := [fsBold];
  FLsNoneLbl.Font.Size := 9;
  FLsNoneLbl.Cursor := crHandPoint;
  FLsNoneLbl.OnClick := @MethodNoneClick;
  FLsNoneLbl.Visible := False;

  // Method Option 2: lsfg-vk
  FLsLsfgRadio := TRadioButton.Create(FForm);
  FLsLsfgRadio.Parent := FLsMethodCard;
  FLsLsfgRadio.Caption := '';
  FLsLsfgRadio.Checked := False;
  FLsLsfgRadio.OnClick := @MethodLsfgClick;
  StyleToggleControl(FLsLsfgRadio);

  FLsLsfgImage := TImage.Create(FForm);
  FLsLsfgImage.Parent := FLsMethodCard;
  FLsLsfgImage.AntialiasingMode := amOn;
  FLsLsfgImage.StretchInEnabled := True;
  FLsLsfgImage.StretchOutEnabled := True;
  FLsLsfgImage.Transparent := True;
  FLsLsfgImage.Center := True;
  FLsLsfgImage.Proportional := True;
  FLsLsfgImage.Stretch := True;
  FLsLsfgImage.Cursor := crHandPoint;
  FLsLsfgImage.OnClick := @MethodLsfgClick;

  FLsLsfgLbl := TLabel.Create(FForm);
  FLsLsfgLbl.Parent := FLsMethodCard;
  FLsLsfgLbl.Caption := 'lsfg-vk';
  FLsLsfgLbl.Font.Style := [fsBold];
  FLsLsfgLbl.Font.Size := 9;
  FLsLsfgLbl.Alignment := taLeftJustify;
  FLsLsfgLbl.AutoSize := True;
  FLsLsfgLbl.Cursor := crHandPoint;
  FLsLsfgLbl.OnClick := @MethodLsfgClick;

  // Method Option 3: MAKO
  FLsMakoRadio := TRadioButton.Create(FForm);
  FLsMakoRadio.Parent := FLsMethodCard;
  FLsMakoRadio.Caption := '';
  FLsMakoRadio.Checked := False;
  FLsMakoRadio.OnClick := @MethodMakoClick;
  StyleToggleControl(FLsMakoRadio);

  FLsMakoImage := TImage.Create(FForm);
  FLsMakoImage.Parent := FLsMethodCard;
  FLsMakoImage.AntialiasingMode := amOn;
  FLsMakoImage.StretchInEnabled := True;
  FLsMakoImage.StretchOutEnabled := True;
  FLsMakoImage.Transparent := True;
  FLsMakoImage.Center := True;
  FLsMakoImage.Proportional := True;
  FLsMakoImage.Stretch := True;
  FLsMakoImage.Cursor := crHandPoint;
  FLsMakoImage.OnClick := @MethodMakoClick;

  FLsMakoLbl := TLabel.Create(FForm);
  FLsMakoLbl.Parent := FLsMethodCard;
  FLsMakoLbl.Caption := 'MAKO';
  FLsMakoLbl.Font.Style := [fsBold];
  FLsMakoLbl.Font.Size := 9;
  FLsMakoLbl.Alignment := taLeftJustify;
  FLsMakoLbl.AutoSize := True;
  FLsMakoLbl.Cursor := crHandPoint;
  FLsMakoLbl.OnClick := @MethodMakoClick;

  FNonePngLogo := TPortableNetworkGraphic.Create;
  FLsfgPngLogo := TPortableNetworkGraphic.Create;
  FMakoPngLogo := TPortableNetworkGraphic.Create;

  IconPath := Tgoverlayform(FForm).GetAppBaseDir + 'assets/icons/upscaler_none.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/upscaler_none.png';
  if FileExists(IconPath) then FNonePngLogo.LoadFromFile(IconPath);

  IconPath := Tgoverlayform(FForm).GetAppBaseDir + 'assets/icons/lossless_scaling.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/lossless_scaling.png';
  if FileExists(IconPath) then FLsfgPngLogo.LoadFromFile(IconPath);

  IconPath := Tgoverlayform(FForm).GetAppBaseDir + 'assets/icons/mako_renderer.png';
  if not FileExists(IconPath) then IconPath := 'assets/icons/mako_renderer.png';
  if FileExists(IconPath) then FMakoPngLogo.LoadFromFile(IconPath);

  FLsNoneImage.Picture.Assign(FNonePngLogo);
  FLsLsfgImage.Picture.Assign(FLsfgPngLogo);
  FLsMakoImage.Picture.Assign(FMakoPngLogo);

  FLsLogoImage := FLsLsfgImage;
  FLsMakoLogoImage := FLsMakoImage;

  // ── Card 0b: Target GPU Device (Top Right 50%) ────────────────────────────
  FLsGpuCard := TPanel.Create(FForm);
  FLsGpuCard.Parent := FLsBgPanel;
  FLsGpuCard.Caption := '';
  FLsGpuCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsGpuTitleLbl := TLabel.Create(FLsGpuCard);
  FLsGpuTitleLbl.Parent := FLsGpuCard;
  FLsGpuTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsGpuCard, FLsGpuTitleLbl, 'Target GPU Device');

  FLsGpuComboBox := TComboBox.Create(FLsGpuCard);
  FLsGpuComboBox.Parent := FLsGpuCard;
  FLsGpuComboBox.Style := csDropDownList;
  FLsGpuComboBox.Hint := 'Target GPU device to use for frame generation and upscaling';
  FLsGpuComboBox.ShowHint := True;
  FLsGpuComboBox.OnChange := @ControlStateChange;
  StyleInputControl(FLsGpuComboBox);
  PopulateGpuList;

  // ── Card 1: Frame Generation ──────────────────────────────────────────────
  FLsFrameGenCard := TPanel.Create(FForm);
  FLsFrameGenCard.Parent := FLsBgPanel;
  FLsFrameGenCard.Caption := '';
  FLsFrameGenCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsFgTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgTitleLbl.Parent := FLsFrameGenCard;
  FLsFgTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsFrameGenCard, FLsFgTitleLbl, 'Frame Generation');

  FLsDisabledNoticeLbl := TLabel.Create(FLsFrameGenCard);
  FLsDisabledNoticeLbl.Parent := FLsFrameGenCard;
  FLsDisabledNoticeLbl.Caption := 'Frame generation is disabled. Select an interpolation engine above (lsfg-vk or MAKO) to enable and configure settings.';
  FLsDisabledNoticeLbl.Font.Color := CLR_TEXT_MUTED;
  FLsDisabledNoticeLbl.Font.Size := 9;
  FLsDisabledNoticeLbl.Visible := False;

  // Mode Selection
  FLsFgModeTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsFgModeTitleLbl.Parent := FLsFrameGenCard;
  FLsFgModeTitleLbl.Caption := 'Frame Generation Mode';
  FLsFgModeTitleLbl.Hint := 'Choose between Fixed Multiplier (2x-5x) or Adaptive Frame Generation';
  FLsFgModeTitleLbl.ShowHint := True;
  FLsFgModeTitleLbl.Visible := False;
  StyleLabel(FLsFgModeTitleLbl, lrControlLabel);

  FLsFgModeComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsFgModeComboBox.Parent := FLsFrameGenCard;
  FLsFgModeComboBox.Style := csDropDownList;
  FLsFgModeComboBox.Items.Add('Fixed Multiplier (Standard)');
  FLsFgModeComboBox.Items.Add('Adaptive Frame Generation (Dynamic Multiplier)');
  FLsFgModeComboBox.ItemIndex := 0;
  FLsFgModeComboBox.OnChange := @FgModeChange;
  FLsFgModeComboBox.Visible := False;
  StyleInputControl(FLsFgModeComboBox);
  
  // Fixed Multiplier Sliders
  FLsMultiplierTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierTitleLbl.Parent := FLsFrameGenCard;
  FLsMultiplierTitleLbl.Caption := 'Multiplier';
  FLsMultiplierTitleLbl.Hint := 'Frame generation multiplier: 1x (disabled), 2x, 3x, 4x, 5x';
  FLsMultiplierTitleLbl.ShowHint := True;
  FLsMultiplierTitleLbl.Visible := False;
  StyleLabel(FLsMultiplierTitleLbl, lrControlLabel);
  
  FLsMultiplierTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsMultiplierTrackBar.Parent := FLsFrameGenCard;
  FLsMultiplierTrackBar.Min := 1;
  FLsMultiplierTrackBar.Max := 5;
  FLsMultiplierTrackBar.Position := 1;
  FLsMultiplierTrackBar.TickStyle := tsNone;
  FLsMultiplierTrackBar.Hint := 'Frame generation multiplier: 1x (disabled), 2x, 3x, 4x, 5x';
  FLsMultiplierTrackBar.ShowHint := True;
  FLsMultiplierTrackBar.Visible := False;
  FLsMultiplierTrackBar.OnChange := @MultiplierChange;
  
  FLsMultiplierValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsMultiplierValueLabel.Parent := FLsFrameGenCard;
  FLsMultiplierValueLabel.Caption := '1x (Disabled)';
  FLsMultiplierValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsMultiplierValueLabel.Font.Style := [fsBold];
  FLsMultiplierValueLabel.Visible := False;

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
  FLsFlowScaleTitleLbl.Visible := False;
  StyleLabel(FLsFlowScaleTitleLbl, lrControlLabel);
  
  FLsFlowScaleTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsFlowScaleTrackBar.Parent := FLsFrameGenCard;
  FLsFlowScaleTrackBar.Min := 25;
  FLsFlowScaleTrackBar.Max := 100;
  FLsFlowScaleTrackBar.Position := 100;
  FLsFlowScaleTrackBar.TickStyle := tsNone;
  FLsFlowScaleTrackBar.Hint := 'Motion estimation resolution scale';
  FLsFlowScaleTrackBar.ShowHint := True;
  FLsFlowScaleTrackBar.Visible := False;
  FLsFlowScaleTrackBar.OnChange := @FlowScaleChange;
  
  FLsFlowScaleValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsFlowScaleValueLabel.Parent := FLsFrameGenCard;
  FLsFlowScaleValueLabel.Caption := '100%';
  FLsFlowScaleValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsFlowScaleValueLabel.Font.Style := [fsBold];
  FLsFlowScaleValueLabel.Visible := False;

  // Base FPS Cap
  FLsBaseFpsCapTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsBaseFpsCapTitleLbl.Parent := FLsFrameGenCard;
  FLsBaseFpsCapTitleLbl.Caption := 'Base FPS Cap';
  FLsBaseFpsCapTitleLbl.Hint := 'Limits the game''s native base framerate before interpolation to maintain steady pacing and GPU headroom (0 = Disabled / Uncapped)';
  FLsBaseFpsCapTitleLbl.ShowHint := True;
  FLsBaseFpsCapTitleLbl.Visible := False;
  StyleLabel(FLsBaseFpsCapTitleLbl, lrControlLabel);

  FLsBaseFpsCapTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsBaseFpsCapTrackBar.Parent := FLsFrameGenCard;
  FLsBaseFpsCapTrackBar.Min := 0;
  FLsBaseFpsCapTrackBar.Max := 240;
  FLsBaseFpsCapTrackBar.Position := 0;
  FLsBaseFpsCapTrackBar.TickStyle := tsNone;
  FLsBaseFpsCapTrackBar.Hint := 'Limits the game''s native base framerate before interpolation to maintain steady pacing and GPU headroom (0 = Disabled / Uncapped)';
  FLsBaseFpsCapTrackBar.ShowHint := True;
  FLsBaseFpsCapTrackBar.Visible := False;
  FLsBaseFpsCapTrackBar.OnChange := @BaseFpsCapChange;

  FLsBaseFpsCapValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsBaseFpsCapValueLabel.Parent := FLsFrameGenCard;
  FLsBaseFpsCapValueLabel.Caption := 'Disabled';
  FLsBaseFpsCapValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsBaseFpsCapValueLabel.Font.Style := [fsBold];
  FLsBaseFpsCapValueLabel.Visible := False;

  // Refresh Threshold
  FLsRefreshThresholdTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsRefreshThresholdTitleLbl.Parent := FLsFrameGenCard;
  FLsRefreshThresholdTitleLbl.Caption := 'Refresh Threshold';
  FLsRefreshThresholdTitleLbl.Hint := 'Minimum display refresh rate (Hz) required to engage frame generation. Automatically bypasses frame generation if your monitor refresh rate is below this threshold (0 = Disabled / Always active)';
  FLsRefreshThresholdTitleLbl.ShowHint := True;
  FLsRefreshThresholdTitleLbl.Visible := False;
  StyleLabel(FLsRefreshThresholdTitleLbl, lrControlLabel);

  FLsRefreshThresholdTrackBar := TTrackBar.Create(FLsFrameGenCard);
  FLsRefreshThresholdTrackBar.Parent := FLsFrameGenCard;
  FLsRefreshThresholdTrackBar.Min := 0;
  FLsRefreshThresholdTrackBar.Max := 240;
  FLsRefreshThresholdTrackBar.Position := 0;
  FLsRefreshThresholdTrackBar.TickStyle := tsNone;
  FLsRefreshThresholdTrackBar.Hint := 'Minimum display refresh rate (Hz) required to engage frame generation. Automatically bypasses frame generation if your monitor refresh rate is below this threshold (0 = Disabled / Always active)';
  FLsRefreshThresholdTrackBar.ShowHint := True;
  FLsRefreshThresholdTrackBar.Visible := False;
  FLsRefreshThresholdTrackBar.OnChange := @RefreshThresholdChange;

  FLsRefreshThresholdValueLabel := TLabel.Create(FLsFrameGenCard);
  FLsRefreshThresholdValueLabel.Parent := FLsFrameGenCard;
  FLsRefreshThresholdValueLabel.Caption := 'Disabled';
  FLsRefreshThresholdValueLabel.Font.Color := CLR_TEXT_ACCENT;
  FLsRefreshThresholdValueLabel.Font.Style := [fsBold];
  FLsRefreshThresholdValueLabel.Visible := False;
  
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
  FLsFgLiveToggle.Visible := False;

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
  FLsAllowFp16Toggle.Visible := False;

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
  FLsPerfModeToggle.Visible := False;

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
  FLsUltraPerfToggle.Visible := False;

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

  // Quirks for lsfg-vk 2.0
  FLsOverridePresentModeCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsOverridePresentModeCheckBox.Parent := FLsFrameGenCard;
  FLsOverridePresentModeCheckBox.ParentColor := True;
  FLsOverridePresentModeCheckBox.Caption := 'Override Present Mode';
  FLsOverridePresentModeCheckBox.Hint := 'Forces the presentation engine to use the selected pacing mode. Recommended: On (upstream default).';
  FLsOverridePresentModeCheckBox.ShowHint := True;
  FLsOverridePresentModeCheckBox.Checked := True;
  FLsOverridePresentModeCheckBox.OnChange := @ControlStateChange;
  FLsOverridePresentModeCheckBox.Visible := False;

  FLsOverridePresentModeToggle := TToggleSwitch.Create(FForm);
  FLsOverridePresentModeToggle.Parent := FLsFrameGenCard;
  FLsOverridePresentModeToggle.LinkToCheckBox(FLsOverridePresentModeCheckBox);
  FLsOverridePresentModeToggle.Height := 20;
  FLsOverridePresentModeToggle.Width := FLsOverridePresentModeToggle.GetOptimalWidth;
  FLsOverridePresentModeToggle.Visible := False;

  FLsPreserveSwapchainCheckBox := TCheckBox.Create(FLsFrameGenCard);
  FLsPreserveSwapchainCheckBox.Parent := FLsFrameGenCard;
  FLsPreserveSwapchainCheckBox.ParentColor := True;
  FLsPreserveSwapchainCheckBox.Caption := 'Preserve Swapchain Count';
  FLsPreserveSwapchainCheckBox.Hint := 'Preserves the application swapchain image count. May resolve issues with games sensitive to swapchain resizing. Recommended: Off (upstream default).';
  FLsPreserveSwapchainCheckBox.ShowHint := True;
  FLsPreserveSwapchainCheckBox.Checked := False;
  FLsPreserveSwapchainCheckBox.OnChange := @ControlStateChange;
  FLsPreserveSwapchainCheckBox.Visible := False;

  FLsPreserveSwapchainToggle := TToggleSwitch.Create(FForm);
  FLsPreserveSwapchainToggle.Parent := FLsFrameGenCard;
  FLsPreserveSwapchainToggle.LinkToCheckBox(FLsPreserveSwapchainCheckBox);
  FLsPreserveSwapchainToggle.Height := 20;
  FLsPreserveSwapchainToggle.Width := FLsPreserveSwapchainToggle.GetOptimalWidth;
  FLsPreserveSwapchainToggle.Visible := False;

  // Dropdowns (Pacing)
  FLsPacingTitleLbl := TLabel.Create(FLsFrameGenCard);
  FLsPacingTitleLbl.Parent := FLsFrameGenCard;
  FLsPacingTitleLbl.Caption := 'Pacing Mode';
  FLsPacingTitleLbl.Hint := 'Frame pacing mode to use';
  FLsPacingTitleLbl.ShowHint := True;
  FLsPacingTitleLbl.Visible := False;
  StyleLabel(FLsPacingTitleLbl, lrControlLabel);
  
  FLsPacingComboBox := TComboBox.Create(FLsFrameGenCard);
  FLsPacingComboBox.Parent := FLsFrameGenCard;
  FLsPacingComboBox.Style := csDropDownList;
  FLsPacingComboBox.Items.Add('vsync (Default / Recommended)');
  FLsPacingComboBox.Items.Add('none (No Frame Pacing)');
  FLsPacingComboBox.ItemIndex := 0;
  FLsPacingComboBox.Hint := 'Frame pacing synchronization mode (vsync or none)';
  FLsPacingComboBox.ShowHint := True;
  FLsPacingComboBox.OnChange := @ControlStateChange;
  FLsPacingComboBox.Visible := False;
  StyleInputControl(FLsPacingComboBox);

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
  FLsScalingSupersamplingToggle.Visible := False;

  // ── Card 3: Software Status (Anchored to Bottom) ─────────────────────────
  FLsStatusCard := TPanel.Create(FForm);
  FLsStatusCard.Parent := FLsBgPanel;
  FLsStatusCard.Caption := '';
  FLsStatusCard.OnPaint := @Tgoverlayform(FForm).SubCardPaint;
  FLsStatusTitleLbl := TLabel.Create(FLsStatusCard);
  FLsStatusTitleLbl.Parent := FLsStatusCard;
  FLsStatusTitleLbl.ShowAccelChar := False;
  StyleMainCard(FLsStatusCard, FLsStatusTitleLbl, 'Software Status');
  FLsGeneralCard := FLsStatusCard;
  FLsDllTitleLbl := FLsStatusTitleLbl;

  for i := 0 to 2 do
  begin
    Dot := TShape.Create(FForm);
    Dot.Parent := FLsStatusCard;
    Dot.Shape := stEllipse;
    Dot.Brush.Color := $00888888;
    Dot.Pen.Style := psClear;
    FLsStatDots[i] := Dot;

    NLbl := TLabel.Create(FForm);
    NLbl.Parent := FLsStatusCard;
    case i of
      0: NLbl.Caption := 'Lossless Scaling';
      1: NLbl.Caption := 'MAKO';
      2: NLbl.Caption := 'lsfg-vk';
    end;
    NLbl.Font.Color := clWhite;
    NLbl.Font.Style := [fsBold];
    NLbl.Font.Size := 9;
    NLbl.AutoSize := True;
    FLsStatNameLbls[i] := NLbl;
  end;

  // Row 0: Lossless.dll
  FLsDllPathEdit := TEdit.Create(FLsStatusCard);
  FLsDllPathEdit.Parent := FLsStatusCard;
  FLsDllPathEdit.Font.Name := 'DejaVu Sans Mono';
  FLsDllPathEdit.Font.Height := -13;
  FLsDllPathEdit.Font.Quality := fqAntialiased;
  FLsDllPathEdit.ReadOnly := True;
  FLsDllPathEdit.AutoSelect := False;
  FLsDllPathEdit.TabStop := False;
  FLsDllPathEdit.TextHint := 'Path to Lossless.dll (e.g. ~/.local/share/Steam/steamapps/common/Lossless Scaling/Lossless.dll)';
  FLsDllPathEdit.OnChange := @DllPathChange;
  StyleInputControl(FLsDllPathEdit);

  FLsBrowseDllBtn := TBitBtn.Create(FLsStatusCard);
  FLsBrowseDllBtn.Parent := FLsStatusCard;
  FLsBrowseDllBtn.Caption := '';
  FLsBrowseDllBtn.Images := Tgoverlayform(FForm).iconsImageList;
  FLsBrowseDllBtn.ImageIndex := 24;
  FLsBrowseDllBtn.Cursor := crHandPoint;
  FLsBrowseDllBtn.OnClick := @BrowseDllClick;
  FLsBrowseDllBtn.Hint := 'Browse for Lossless.dll';
  FLsBrowseDllBtn.ShowHint := True;
  StyleActionButton(FLsBrowseDllBtn);

  FLsDllStatusLabel := TLabel.Create(FLsStatusCard);
  FLsDllStatusLabel.Parent := FLsStatusCard;
  FLsDllStatusLabel.Caption := '● DLL file located';
  FLsDllStatusLabel.Font.Style := [fsBold];
  FLsDllStatusLabel.Font.Size := 9;
  FLsDllStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
  FLsDllStatusLabel.Visible := False;

  // Row 1: MAKO
  FLsMakoPathEdit := TEdit.Create(FLsStatusCard);
  FLsMakoPathEdit.Parent := FLsStatusCard;
  FLsMakoPathEdit.Font.Name := 'DejaVu Sans Mono';
  FLsMakoPathEdit.Font.Height := -13;
  FLsMakoPathEdit.Font.Quality := fqAntialiased;
  FLsMakoPathEdit.ReadOnly := True;
  FLsMakoPathEdit.AutoSelect := False;
  FLsMakoPathEdit.TabStop := False;
  FLsMakoPathEdit.Visible := False;

  FLsEngineStatusLabel := TLabel.Create(FLsStatusCard);
  FLsEngineStatusLabel.Parent := FLsStatusCard;
  FLsEngineStatusLabel.Caption := '● Checking MAKO...';
  FLsEngineStatusLabel.Font.Style := [fsBold];
  FLsEngineStatusLabel.Font.Size := 9;
  FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;

  FLsMakoNoteLabel := TLabel.Create(FLsStatusCard);
  FLsMakoNoteLabel.Parent := FLsStatusCard;
  FLsMakoNoteLabel.Caption := '(Incompatible with Wayland and HDR)';
  FLsMakoNoteLabel.Font.Style := [];
  FLsMakoNoteLabel.Font.Size := 9;
  FLsMakoNoteLabel.Font.Color := CLR_TEXT_MUTED;
  FLsMakoNoteLabel.ShowAccelChar := False;
  FLsMakoNoteLabel.AutoSize := True;

  FLsCheckUpdatesBtn := TBitBtn.Create(FLsStatusCard);
  FLsCheckUpdatesBtn.Parent := FLsStatusCard;
  FLsCheckUpdatesBtn.Caption := 'Check Updates';
  FLsCheckUpdatesBtn.Cursor := crHandPoint;
  FLsCheckUpdatesBtn.OnClick := @CheckUpdatesClick;
  FLsCheckUpdatesBtn.Visible := False;
  StyleActionButton(FLsCheckUpdatesBtn);

  FLsInstallBtn := TBitBtn.Create(FLsStatusCard);
  FLsInstallBtn.Parent := FLsStatusCard;
  FLsInstallBtn.Caption := 'Install MAKO';
  FLsInstallBtn.Cursor := crHandPoint;
  FLsInstallBtn.OnClick := @InstallMakoClick;
  FLsInstallBtn.Visible := False;
  StyleActionButton(FLsInstallBtn);

  // Row 2: lsfg-vk
  FLsLsfgStatusLabel := TLabel.Create(FLsStatusCard);
  FLsLsfgStatusLabel.Parent := FLsStatusCard;
  FLsLsfgStatusLabel.Caption := '● Checking lsfg-vk layer...';
  FLsLsfgStatusLabel.Font.Style := [fsBold];
  FLsLsfgStatusLabel.Font.Size := 9;
  FLsLsfgStatusLabel.Font.Color := CLR_TEXT_ACCENT;

  FLsLsfgInstallBtn := TBitBtn.Create(FLsStatusCard);
  FLsLsfgInstallBtn.Parent := FLsStatusCard;
  FLsLsfgInstallBtn.Caption := 'Install runtime';
  FLsLsfgInstallBtn.Cursor := crHandPoint;
  FLsLsfgInstallBtn.OnClick := @InstallLsfgClick;
  FLsLsfgInstallBtn.Visible := False;
  StyleActionButton(FLsLsfgInstallBtn);

  // Progress Bar for installation
  FLsProgressBar := TProgressBar.Create(FLsStatusCard);
  FLsProgressBar.Parent := FLsStatusCard;
  FLsProgressBar.Min := 0;
  FLsProgressBar.Max := 100;
  FLsProgressBar.Position := 0;
  FLsProgressBar.Visible := False;

  FLsProgressLabel := TLabel.Create(FLsStatusCard);
  FLsProgressLabel.Parent := FLsStatusCard;
  FLsProgressLabel.Caption := '';
  FLsProgressLabel.Font.Size := 9;
  FLsProgressLabel.Font.Color := CLR_TEXT_MUTED;
  FLsProgressLabel.Visible := False;
  
  // Load configuration
  LoadLosslessConfig;
  ApplyThemeStyles;
end;

procedure TLosslessScalingTabHelper.LsScrollBoxResize(Sender: TObject);
begin
  if Assigned(FLsScrollBox) then
    ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
end;

procedure TLosslessScalingTabHelper.ReflowLosslessScalingTab(AContentW: Integer);
var
  W, CW, CurY, Col2W, RightColX, Col3W, Col4W: Integer;
  CardW, InnerW, HDR, GPU_H, GPU_GH: Integer;
  LogoW_None, IconSize, TextW_Lsfg, TextW_Mako: Integer;
  GroupW_None, GroupW_Lsfg, GroupW_Mako, TotalGroupW, GapBetween: Integer;
  X1, X2, X3: Integer;
  EditLeft, EditW, BrowseW: Integer;
  Y0, Y1, Y2, Y3, StatusCardH: Integer;
  IsAdaptive: Boolean;
begin
  if not Assigned(FLsScrollBox) or not Assigned(FLsMethodCard) then Exit;
  
  W := FLsScrollBox.ClientWidth;
  if AContentW > 100 then
    W := AContentW
  else if W < 500 then
    W := 500;
  
  CW := W - (MARGIN * 2);
  CurY := MARGIN;
  
  Col2W := (CW - (PAD * 2) - 20) div 2;
  RightColX := PAD + Col2W + 20;
  Col3W := (CW - (PAD * 2) - 24) div 3;
  Col4W := (CW - (PAD * 2) - 36) div 4;

  GPU_H := 102;
  HDR := 28;
  GPU_GH := GPU_H - HDR;

  CardW := (CW - GAP) div 2;

  // ── Card 0a: Method (Left 50%) ──────────────────────────────────────────
  FLsMethodCard.SetBounds(MARGIN, CurY, CardW, GPU_H);
  InnerW := CardW - 2 * PAD;

  LogoW_None := 48;
  IconSize   := 34;
  TextW_Lsfg := 54;
  TextW_Mako := 48;

  GroupW_None := 22 + LogoW_None;
  GroupW_Lsfg := 22 + IconSize + 8 + TextW_Lsfg;
  GroupW_Mako := 22 + IconSize + 8 + TextW_Mako;
  TotalGroupW := GroupW_None + GroupW_Lsfg + GroupW_Mako;

  if InnerW > TotalGroupW then
    GapBetween := (InnerW - TotalGroupW) div 2
  else
    GapBetween := 4;

  X1 := PAD;
  X2 := X1 + GroupW_None + GapBetween;
  X3 := CardW - PAD - GroupW_Mako;
  if X3 < X2 + GroupW_Lsfg + 4 then
    X3 := X2 + GroupW_Lsfg + 4;

  // Column 0: None (leftmost)
  if Assigned(FLsNoneRadio) then
    FLsNoneRadio.SetBounds(X1, HDR + (GPU_GH - 20) div 2, 20, 20);
  if Assigned(FLsNoneImage) then
    FLsNoneImage.SetBounds(X1 + 22, HDR + (GPU_GH - 20) div 2, LogoW_None, 20);

  // Column 1: lsfg-vk (middle)
  if Assigned(FLsLsfgRadio) then
    FLsLsfgRadio.SetBounds(X2, HDR + (GPU_GH - 20) div 2, 20, 20);
  if Assigned(FLsLsfgImage) then
    FLsLsfgImage.SetBounds(X2 + 22, HDR + (GPU_GH - IconSize) div 2, IconSize, IconSize);
  if Assigned(FLsLsfgLbl) then
    FLsLsfgLbl.SetBounds(X2 + 22 + IconSize + 8, HDR + (GPU_GH - 18) div 2, TextW_Lsfg, 18);

  // Column 2: MAKO (rightmost)
  if Assigned(FLsMakoRadio) then
    FLsMakoRadio.SetBounds(X3, HDR + (GPU_GH - 20) div 2, 20, 20);
  if Assigned(FLsMakoImage) then
    FLsMakoImage.SetBounds(X3 + 22, HDR + (GPU_GH - IconSize) div 2, IconSize, IconSize);
  if Assigned(FLsMakoLbl) then
    FLsMakoLbl.SetBounds(X3 + 22 + IconSize + 8, HDR + (GPU_GH - 18) div 2, TextW_Mako, 18);

  // ── Card 0b: Target GPU Device (Right 50%) ──────────────────────────────
  FLsGpuCard.SetBounds(MARGIN + CardW + GAP, CurY, CW - CardW - GAP, GPU_H);
  if Assigned(FLsGpuComboBox) then
    FLsGpuComboBox.SetBounds(PAD, HDR + (GPU_GH - ROW_H) div 2, (CW - CardW - GAP) - 2 * PAD, ROW_H);

  CurY := CurY + GPU_H + GAP;

  // ── Migration Alert Card (if visible) ───────────────────────────────────
  if Assigned(FLsMigrationAlertCard) and FLsMigrationAlertCard.Visible then
  begin
    FLsMigrationAlertCard.SetBounds(MARGIN, CurY, CW, 50);
    if Assigned(FLsMigrationAlertIconLbl) then
      FLsMigrationAlertIconLbl.SetBounds(PAD, 14, 20, 20);
    if Assigned(FLsMigrationAlertBtn) then
      FLsMigrationAlertBtn.SetBounds(CW - PAD - 160, (50 - 28) div 2, 160, 28);
    if Assigned(FLsMigrationAlertTitleLbl) then
      FLsMigrationAlertTitleLbl.SetBounds(PAD + 28, 8, CW - 2 * PAD - 200, 16);
    if Assigned(FLsMigrationAlertDescLbl) then
      FLsMigrationAlertDescLbl.SetBounds(PAD + 28, 26, CW - 2 * PAD - 200, 16);

    CurY := CurY + 50 + GAP;
  end;

  // ── Middle Area: Dynamic Configuration Cards ─────────────────────────────
  if FInterpolationMethod = imNone then
  begin
    FLsFrameGenCard.Visible := True;
    FLsSpatialCard.Visible := False;

    // Hide other Frame Gen controls
    FLsFgModeTitleLbl.Visible := False;
    FLsFgModeComboBox.Visible := False;
    FLsMultiplierTitleLbl.Visible := False;
    FLsMultiplierTrackBar.Visible := False;
    FLsMultiplierValueLabel.Visible := False;
    FLsTargetFpsTitleLbl.Visible := False;
    FLsTargetFpsTrackBar.Visible := False;
    FLsTargetFpsValueLabel.Visible := False;
    FLsAdaptiveMaxMultTitleLbl.Visible := False;
    FLsAdaptiveMaxMultComboBox.Visible := False;
    FLsSteady2xCapToggle.Visible := False;
    FLsSmoothCadenceToggle.Visible := False;
    FLsFlowScaleTitleLbl.Visible := False;
    FLsFlowScaleTrackBar.Visible := False;
    FLsFlowScaleValueLabel.Visible := False;
    FLsBaseFpsCapTitleLbl.Visible := False;
    FLsBaseFpsCapTrackBar.Visible := False;
    FLsBaseFpsCapValueLabel.Visible := False;
    FLsRefreshThresholdTitleLbl.Visible := False;
    FLsRefreshThresholdTrackBar.Visible := False;
    FLsRefreshThresholdValueLabel.Visible := False;
    FLsFgLiveToggle.Visible := False;
    FLsAllowFp16Toggle.Visible := False;
    FLsOverridePresentModeToggle.Visible := False;
    FLsPreserveSwapchainToggle.Visible := False;
    FLsPerfModeToggle.Visible := False;
    FLsUltraPerfToggle.Visible := False;
    FLsHdrModeToggle.Visible := False;
    FLsNoFp16Toggle.Visible := False;
    FLsPacingTitleLbl.Visible := False;
    FLsPacingComboBox.Visible := False;

    if Assigned(FLsPerfModeToggle) then FLsPerfModeToggle.SetBounds(PAD, 106, Col3W, 24);
    if Assigned(FLsHdrModeToggle) then FLsHdrModeToggle.SetBounds(PAD + Col3W + 12, 106, Col3W, 24);
    if Assigned(FLsNoFp16Toggle) then FLsNoFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 106, Col3W, 24);

    FLsDisabledNoticeLbl.Visible := True;
    FLsDisabledNoticeLbl.SetBounds(PAD, HDR + 14, CW - 2 * PAD, 20);

    FLsFrameGenCard.SetBounds(MARGIN, CurY, CW, 84);
    CurY := CurY + 84 + GAP;
  end
  else if FInterpolationMethod = imLsfg then
  begin
    FLsDisabledNoticeLbl.Visible := False;
    FLsSpatialCard.Visible := False;
    FLsFrameGenCard.Visible := True;

    // Hide MAKO-only controls
    FLsFgModeTitleLbl.Visible := False;
    FLsFgModeComboBox.Visible := False;
    FLsTargetFpsTitleLbl.Visible := False;
    FLsTargetFpsTrackBar.Visible := False;
    FLsTargetFpsValueLabel.Visible := False;
    FLsAdaptiveMaxMultTitleLbl.Visible := False;
    FLsAdaptiveMaxMultComboBox.Visible := False;
    FLsSteady2xCapToggle.Visible := False;
    FLsSmoothCadenceToggle.Visible := False;
    FLsBaseFpsCapTitleLbl.Visible := False;
    FLsBaseFpsCapTrackBar.Visible := False;
    FLsBaseFpsCapValueLabel.Visible := False;
    FLsRefreshThresholdTitleLbl.Visible := False;
    FLsRefreshThresholdTrackBar.Visible := False;
    FLsRefreshThresholdValueLabel.Visible := False;
    FLsFgLiveToggle.Visible := False;
    FLsUltraPerfToggle.Visible := False;

    // Row 1: Sliders
    FLsMultiplierTitleLbl.Visible := True;
    FLsMultiplierTitleLbl.SetBounds(PAD, 38, Col2W, 18);
    FLsMultiplierTrackBar.Visible := True;
    FLsMultiplierTrackBar.SetBounds(PAD, 58, Col2W - 85, ROW_H);
    FLsMultiplierValueLabel.Visible := True;
    FLsMultiplierValueLabel.SetBounds(PAD + Col2W - 80, 62, 80, 20);

    FLsFlowScaleTitleLbl.Visible := True;
    FLsFlowScaleTitleLbl.SetBounds(RightColX, 38, Col2W, 18);
    FLsFlowScaleTrackBar.Visible := True;
    FLsFlowScaleTrackBar.SetBounds(RightColX, 58, Col2W - 55, ROW_H);
    FLsFlowScaleValueLabel.Visible := True;
    FLsFlowScaleValueLabel.SetBounds(RightColX + Col2W - 50, 62, 50, 20);

    // Row 2: Frame Gen Toggles (2 columns)
    if Assigned(FLsPerfModeToggle) then
    begin
      FLsPerfModeToggle.Visible := True;
      FLsPerfModeToggle.SetBounds(PAD, 102, Col2W, 24);
    end;
    if Assigned(FLsAllowFp16Toggle) then
    begin
      FLsAllowFp16Toggle.Visible := True;
      FLsAllowFp16Toggle.SetBounds(RightColX, 102, Col2W, 24);
    end;

    // Row 3: Quirks Toggles (2 columns)
    if Assigned(FLsOverridePresentModeToggle) then
    begin
      FLsOverridePresentModeToggle.Visible := True;
      FLsOverridePresentModeToggle.SetBounds(PAD, 136, Col2W, 24);
    end;
    if Assigned(FLsPreserveSwapchainToggle) then
    begin
      FLsPreserveSwapchainToggle.Visible := True;
      FLsPreserveSwapchainToggle.SetBounds(RightColX, 136, Col2W, 24);
    end;

    if Assigned(FLsHdrModeToggle) then FLsHdrModeToggle.Visible := False;
    if Assigned(FLsNoFp16Toggle) then FLsNoFp16Toggle.Visible := False;

    // Row 4: Pacing dropdown
    FLsPacingTitleLbl.Visible := True;
    FLsPacingTitleLbl.SetBounds(PAD, 172, Col2W, 18);
    FLsPacingComboBox.Visible := True;
    FLsPacingComboBox.SetBounds(PAD, 192, Col2W, ROW_H);

    FLsFrameGenCard.SetBounds(MARGIN, CurY, CW, 240);
    CurY := CurY + 240 + GAP;
  end
  else // imMako
  begin
    FLsDisabledNoticeLbl.Visible := False;
    FLsSpatialCard.Visible := True;
    FLsFrameGenCard.Visible := True;

    IsAdaptive := Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1);

    FLsFgModeTitleLbl.Visible := True;
    FLsFgModeTitleLbl.SetBounds(PAD, 36, Col2W, 18);
    FLsFgModeComboBox.Visible := True;
    FLsFgModeComboBox.SetBounds(PAD, 56, Col2W, ROW_H);

    FLsAdaptiveMaxMultTitleLbl.Visible := IsAdaptive;
    FLsAdaptiveMaxMultComboBox.Visible := IsAdaptive;
    if IsAdaptive then
    begin
      FLsAdaptiveMaxMultTitleLbl.SetBounds(RightColX, 36, Col2W, 18);
      FLsAdaptiveMaxMultComboBox.SetBounds(RightColX, 56, Col2W, ROW_H);
    end;

    FLsMultiplierTitleLbl.Visible := not IsAdaptive;
    FLsMultiplierTrackBar.Visible := not IsAdaptive;
    FLsMultiplierValueLabel.Visible := not IsAdaptive;
    FLsMultiplierTitleLbl.SetBounds(PAD, 92, Col2W, 18);
    FLsMultiplierTrackBar.SetBounds(PAD, 112, Col2W - 85, ROW_H);
    FLsMultiplierValueLabel.SetBounds(PAD + Col2W - 80, 116, 80, 20);
    if not IsAdaptive then FLsMultiplierTrackBar.BringToFront;

    FLsTargetFpsTitleLbl.Visible := IsAdaptive;
    FLsTargetFpsTrackBar.Visible := IsAdaptive;
    FLsTargetFpsValueLabel.Visible := IsAdaptive;
    FLsTargetFpsTitleLbl.SetBounds(PAD, 92, Col2W, 18);
    FLsTargetFpsTrackBar.SetBounds(PAD, 112, Col2W - 85, ROW_H);
    FLsTargetFpsValueLabel.SetBounds(PAD + Col2W - 80, 116, 80, 20);
    if IsAdaptive then FLsTargetFpsTrackBar.BringToFront;

    FLsFlowScaleTitleLbl.Visible := True;
    FLsFlowScaleTitleLbl.SetBounds(RightColX, 92, Col2W, 18);
    FLsFlowScaleTrackBar.Visible := True;
    FLsFlowScaleTrackBar.SetBounds(RightColX, 112, Col2W - 85, ROW_H);
    FLsFlowScaleValueLabel.Visible := True;
    FLsFlowScaleValueLabel.SetBounds(RightColX + Col2W - 80, 116, 80, 20);

    FLsBaseFpsCapTitleLbl.Visible := True;
    FLsBaseFpsCapTitleLbl.SetBounds(PAD, 148, Col2W, 18);
    FLsBaseFpsCapTrackBar.Visible := True;
    FLsBaseFpsCapTrackBar.SetBounds(PAD, 168, Col2W - 85, ROW_H);
    FLsBaseFpsCapValueLabel.Visible := True;
    FLsBaseFpsCapValueLabel.SetBounds(PAD + Col2W - 80, 172, 80, 20);

    FLsRefreshThresholdTitleLbl.Visible := True;
    FLsRefreshThresholdTitleLbl.SetBounds(RightColX, 148, Col2W, 18);
    FLsRefreshThresholdTrackBar.Visible := True;
    FLsRefreshThresholdTrackBar.SetBounds(RightColX, 168, Col2W - 85, ROW_H);
    FLsRefreshThresholdValueLabel.Visible := True;
    FLsRefreshThresholdValueLabel.SetBounds(RightColX + Col2W - 80, 172, 80, 20);

    if Assigned(FLsPerfModeToggle) then
    begin
      FLsPerfModeToggle.Visible := True;
      FLsPerfModeToggle.SetBounds(PAD, 206, Col3W, 24);
    end;
    if Assigned(FLsUltraPerfToggle) then
    begin
      FLsUltraPerfToggle.Visible := True;
      FLsUltraPerfToggle.SetBounds(PAD + Col3W + 12, 206, Col3W, 24);
    end;
    if Assigned(FLsAllowFp16Toggle) then
    begin
      FLsAllowFp16Toggle.Visible := True;
      FLsAllowFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 206, Col3W, 24);
    end;

    // Keep hidden compatibility toggles valid for test assertion compatibility
    if Assigned(FLsHdrModeToggle) then
    begin
      FLsHdrModeToggle.SetBounds(PAD + Col3W + 12, 206, Col3W, 24);
      FLsHdrModeToggle.Visible := False;
    end;
    if Assigned(FLsNoFp16Toggle) then
    begin
      FLsNoFp16Toggle.SetBounds(PAD + (Col3W + 12) * 2, 206, Col3W, 24);
      FLsNoFp16Toggle.Visible := False;
    end;

    if Assigned(FLsFgLiveToggle) then
    begin
      FLsFgLiveToggle.Visible := True;
      FLsFgLiveToggle.SetBounds(PAD, 238, Col3W, 24);
    end;
    FLsSteady2xCapToggle.Visible := IsAdaptive;
    if IsAdaptive then
      FLsSteady2xCapToggle.SetBounds(PAD + Col3W + 12, 238, Col3W, 24);
    FLsSmoothCadenceToggle.Visible := IsAdaptive;
    if IsAdaptive then
      FLsSmoothCadenceToggle.SetBounds(PAD + (Col3W + 12) * 2, 238, Col3W, 24);

    if Assigned(FLsOverridePresentModeToggle) then FLsOverridePresentModeToggle.Visible := False;
    if Assigned(FLsPreserveSwapchainToggle) then FLsPreserveSwapchainToggle.Visible := False;
    if Assigned(FLsPacingTitleLbl) then FLsPacingTitleLbl.Visible := False;
    if Assigned(FLsPacingComboBox) then FLsPacingComboBox.Visible := False;

    FLsFrameGenCard.SetBounds(MARGIN, CurY, CW, 276);
    CurY := CurY + 276 + GAP;

    // Spatial Scaling Card
    FLsSpatialCard.SetBounds(MARGIN, CurY, CW, 154);
    if Assigned(FLsScalingEnableToggle) then FLsScalingEnableToggle.Visible := False;
    FLsScalingMethodTitleLbl.SetBounds(PAD, 36, Col2W, 18);
    FLsScalingMethodComboBox.SetBounds(PAD, 56, Col2W, ROW_H);
    if Assigned(FLsScalingSupersamplingToggle) then
      FLsScalingSupersamplingToggle.SetBounds(RightColX, 58, Col2W, 24);

    FLsScalingFactorTitleLbl.SetBounds(PAD, 94, Col2W, 18);
    FLsScalingFactorTrackBar.SetBounds(PAD, 114, Col2W - 65, ROW_H);
    FLsScalingFactorValueLabel.SetBounds(PAD + Col2W - 60, 118, 60, 20);

    FLsScalingSharpnessTitleLbl.SetBounds(RightColX, 94, Col2W, 18);
    FLsScalingSharpnessTrackBar.SetBounds(RightColX, 114, Col2W - 65, ROW_H);
    FLsScalingSharpnessValueLabel.SetBounds(RightColX + Col2W - 60, 118, 60, 20);

    CurY := CurY + 154 + GAP;
  end;

  // ── Card 3: Software Status (Anchored to Bottom) ─────────────────────────
  Y0 := 36;
  EditLeft := PAD + 10 + 6 + 160;
  BrowseW := 32;
  EditW := CW - EditLeft - PAD - BrowseW - 6;
  if EditW < 100 then EditW := 100;

  // Row 0: Lossless Scaling
  if Assigned(FLsStatDots[0]) then
    FLsStatDots[0].SetBounds(PAD, Y0 + (ROW_H - 10) div 2, 10, 10);
  if Assigned(FLsStatNameLbls[0]) then
    FLsStatNameLbls[0].SetBounds(PAD + 16, Y0 + (ROW_H - 16) div 2, 160, 16);
  if Assigned(FLsDllPathEdit) then
    FLsDllPathEdit.SetBounds(EditLeft, Y0, EditW, ROW_H);
  if Assigned(FLsBrowseDllBtn) then
    FLsBrowseDllBtn.SetBounds(EditLeft + EditW + 6, Y0, BrowseW, ROW_H);

  // Row 1: MAKO Renderer
  Y1 := Y0 + ROW_H + 8;
  if Assigned(FLsStatDots[1]) then
    FLsStatDots[1].SetBounds(PAD, Y1 + (ROW_H - 10) div 2, 10, 10);
  if Assigned(FLsStatNameLbls[1]) then
    FLsStatNameLbls[1].SetBounds(PAD + 16, Y1 + (ROW_H - 16) div 2, 160, 16);

  if Assigned(FLsInstallBtn) and FLsInstallBtn.Visible then
    FLsInstallBtn.SetBounds(CW - PAD - 120, Y1, 120, ROW_H);

  if Assigned(FLsEngineStatusLabel) then
  begin
    FLsEngineStatusLabel.AutoSize := True;
    FLsEngineStatusLabel.AdjustSize;
    FLsEngineStatusLabel.SetBounds(EditLeft, Y1 + (ROW_H - 18) div 2, FLsEngineStatusLabel.Width, 18);
  end;

  if Assigned(FLsMakoNoteLabel) and Assigned(FLsEngineStatusLabel) then
  begin
    FLsMakoNoteLabel.AutoSize := True;
    FLsMakoNoteLabel.AdjustSize;
    FLsMakoNoteLabel.SetBounds(EditLeft + FLsEngineStatusLabel.Width + 8, Y1 + (ROW_H - 18) div 2, FLsMakoNoteLabel.Width, 18);
  end;

  // Row 2: lsfg-vk Vulkan Layer
  Y2 := Y1 + ROW_H + 8;
  if Assigned(FLsStatDots[2]) then
    FLsStatDots[2].SetBounds(PAD, Y2 + (ROW_H - 10) div 2, 10, 10);
  if Assigned(FLsStatNameLbls[2]) then
    FLsStatNameLbls[2].SetBounds(PAD + 16, Y2 + (ROW_H - 16) div 2, 160, 16);

  if Assigned(FLsLsfgInstallBtn) and FLsLsfgInstallBtn.Visible then
    FLsLsfgInstallBtn.SetBounds(CW - PAD - 120, Y2, 120, ROW_H);

  if Assigned(FLsLsfgStatusLabel) then
  begin
    if Assigned(FLsLsfgInstallBtn) and FLsLsfgInstallBtn.Visible then
      FLsLsfgStatusLabel.SetBounds(EditLeft, Y2 + (ROW_H - 18) div 2, CW - EditLeft - PAD - 128, 18)
    else
      FLsLsfgStatusLabel.SetBounds(EditLeft, Y2 + (ROW_H - 18) div 2, CW - EditLeft - PAD, 18);
  end;

  // Row 3 (Optional): Progress bar during installation
  if Assigned(FLsProgressBar) and FLsProgressBar.Visible then
  begin
    Y3 := Y2 + ROW_H + 6;
    FLsProgressBar.SetBounds(PAD, Y3, CW - 2 * PAD, 10);
    FLsProgressLabel.SetBounds(PAD, Y3 + 14, CW - 2 * PAD, 18);
    StatusCardH := Y3 + 36;
  end
  else
    StatusCardH := Y2 + ROW_H + 12;

  FLsStatusCard.SetBounds(MARGIN, CurY, CW, StatusCardH);
  CurY := CurY + StatusCardH + MARGIN;

  FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY));
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
      if FInterpolationMethod = imLsfg then
        FLsDllStatusLabel.Caption := '● Switch Lossless Scaling to lsfg-vk beta branch in Steam'
      else
        FLsDllStatusLabel.Caption := '● Install Lossless scaling on steam or point the correct file path';
      FLsDllStatusLabel.Font.Color := RGBToColor(255, 90, 95);
    end;
  end;
  QWidget_setStyleSheet(TQtWidget(FLsDllPathEdit.Handle).Widget, @SS);
  FLsDllPathEdit.SelStart := 0;
  FLsDllPathEdit.SelLength := 0;
  UpdateStatusCard;
end;

procedure TLosslessScalingTabHelper.UpdateEngineStatus;
var
  InstalledVer, MakoLib, SS: string;
  HasLib, IsDark: Boolean;
begin
  if not Assigned(FLsEngineStatusLabel) then Exit;
  if Assigned(FLsCheckUpdatesBtn) then FLsCheckUpdatesBtn.Visible := False;

  MakoLib := GetMakoLibraryPath;
  HasLib := (MakoLib <> '') and FileExists(MakoLib);
  IsDark := (CurrentTheme = tmDark);

  if Assigned(FLsMakoPathEdit) then
  begin
    if HasLib then
      FLsMakoPathEdit.Text := MakoLib
    else
      FLsMakoPathEdit.Text := '';
    if FLsMakoPathEdit.HandleAllocated then
    begin
      if IsDark then
        SS := 'QLineEdit { background-color: rgb(35, 30, 42); color: rgb(240, 240, 240); border: 1px solid rgb(60, 52, 75); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; }'
      else
        SS := 'QLineEdit { background-color: rgb(255, 235, 235); color: rgb(180, 20, 20); border: 1px solid rgb(200, 60, 60); border-radius: 4px; padding: 2px 6px; font-family: "DejaVu Sans Mono", monospace; font-size: 13px; }';
      QWidget_setStyleSheet(TQtWidget(FLsMakoPathEdit.Handle).Widget, @SS);
      FLsMakoPathEdit.SelStart := 0;
      FLsMakoPathEdit.SelLength := 0;
    end;
  end;

  InstalledVer := GetMakoInstalledVersion;
  while (InstalledVer <> '') and (InstalledVer[1] in ['v', 'V']) do
    Delete(InstalledVer, 1, 1);

  if InstalledVer <> '' then
  begin
    if FMakoUpdateAvailable and (FMakoRemoteVer <> '') and (FMakoRemoteVer <> InstalledVer) then
    begin
      FLsEngineStatusLabel.Caption := InstalledVer + ' → ' + FMakoRemoteVer;
      FLsEngineStatusLabel.Font.Color := $0044AAFF;
      FLsEngineStatusLabel.Hint := MakoLib;
      FLsEngineStatusLabel.ShowHint := (MakoLib <> '');
      if Assigned(FLsInstallBtn) then
      begin
        FLsInstallBtn.Caption := 'Install update';
        FLsInstallBtn.Visible := True;
        FLsInstallBtn.Enabled := True;
      end;
    end
    else
    begin
      if FMakoUpdateAvailable and (FMakoRemoteVer = InstalledVer) then
        FMakoUpdateAvailable := False;
      FLsEngineStatusLabel.Caption := InstalledVer;
      FLsEngineStatusLabel.Font.Color := $BB99FF;
      FLsEngineStatusLabel.Hint := MakoLib;
      FLsEngineStatusLabel.ShowHint := (MakoLib <> '');
      if Assigned(FLsInstallBtn) then FLsInstallBtn.Visible := False;
    end;

    // Check in background if an update is available so 'Install update' can appear
    if not FCheckingUpdate and not FUpdateCheckedThisSession then
    begin
      FCheckingUpdate := True;
      FUpdateCheckedThisSession := True;
      TMakoCheckUpdateThread.Create(Self).Start;
    end;
  end
  else if IsMakoInstalled then
  begin
    FLsEngineStatusLabel.Caption := 'Installed';
    FLsEngineStatusLabel.Font.Color := $BB99FF;
    FLsEngineStatusLabel.Hint := MakoLib;
    FLsEngineStatusLabel.ShowHint := (MakoLib <> '');
    if Assigned(FLsInstallBtn) then FLsInstallBtn.Visible := False;
  end
  else
  begin
    FLsEngineStatusLabel.Caption := 'Not installed';
    FLsEngineStatusLabel.Font.Color := RGBToColor(255, 90, 95);
    FLsEngineStatusLabel.Hint := '';
    FLsEngineStatusLabel.ShowHint := False;
    if Assigned(FLsInstallBtn) then
    begin
      FLsInstallBtn.Caption := 'Install MAKO';
      FLsInstallBtn.Visible := True;
      FLsInstallBtn.Enabled := True;
    end;
  end;

  if not FLsfgCheckingUpdate and not FLsfgUpdateCheckedThisSession and not IsRunningInFlatpak then
  begin
    FLsfgCheckingUpdate := True;
    FLsfgUpdateCheckedThisSession := True;
    TLsfgVkCheckUpdateThread.Create(Self).Start;
  end;

  UpdateStatusCard;
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

  while (LocalVer <> '') and (LocalVer[1] in ['v', 'V']) do
    Delete(LocalVer, 1, 1);
  while (RemoteVer <> '') and (RemoteVer[1] in ['v', 'V']) do
    Delete(RemoteVer, 1, 1);

  if (LocalVer <> '') and (LocalVer = RemoteVer) then
  begin
    FMakoUpdateAvailable := False;
    FMakoRemoteVer := RemoteVer;
    FLsEngineStatusLabel.Caption := '● MAKO ' + LocalVer + ' is up to date';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_SUCCESS;
    if Assigned(FLsInstallBtn) then FLsInstallBtn.Visible := False;
    UpdateStatusCard;
    if Assigned(FForm) and (FForm is Tgoverlayform) then
      Tgoverlayform(FForm).RefreshHomeMakoStatus;
  end
  else if (LocalVer <> '') then
  begin
    FMakoUpdateAvailable := True;
    FMakoRemoteVer := RemoteVer;
    FLsEngineStatusLabel.Caption := LocalVer + ' → ' + RemoteVer;
    FLsEngineStatusLabel.Font.Color := $0044AAFF;
    if Assigned(FLsInstallBtn) then
    begin
      FLsInstallBtn.Caption := 'Install update';
      FLsInstallBtn.Visible := True;
      FLsInstallBtn.Enabled := True;
    end;
    UpdateStatusCard;
    if Assigned(FForm) and (FForm is Tgoverlayform) then
      Tgoverlayform(FForm).RefreshHomeMakoStatus;
    ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
  end
  else
  begin
    FLsEngineStatusLabel.Caption := '● Latest release is ' + RemoteVer + ' (Click Install)';
    FLsEngineStatusLabel.Font.Color := CLR_TEXT_ACCENT;
    if Assigned(FLsInstallBtn) then
    begin
      FLsInstallBtn.Caption := 'Install MAKO';
      FLsInstallBtn.Visible := True;
      FLsInstallBtn.Enabled := True;
    end;
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

procedure TLosslessScalingTabHelper.InstallLsfgClick(Sender: TObject);
begin
  if Assigned(FLsLsfgInstallBtn) then
    FLsLsfgInstallBtn.Enabled := False;
  if Assigned(FLsProgressBar) then
  begin
    FLsProgressBar.Position := 0;
    FLsProgressBar.Visible := True;
  end;
  if Assigned(FLsProgressLabel) then
  begin
    FLsProgressLabel.Caption := 'Starting lsfg-vk installation...';
    FLsProgressLabel.Visible := True;
  end;
  ReflowLosslessScalingTab(FLsScrollBox.ClientWidth);
  TLsfgVkInstallThread.Create(Self).Start;
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
  AdaptiveActive := (FInterpolationMethod = imMako) and Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1);
  FgActive := (FInterpolationMethod in [imLsfg, imMako]);
  ScalingActive := Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0);
  if Assigned(FLsScalingEnableCheckBox) then
    FLsScalingEnableCheckBox.Checked := ScalingActive;
  if Assigned(FLsScalingEnableToggle) then
    FLsScalingEnableToggle.Checked := ScalingActive;

  // Frame Gen Mode (MAKO only)
  if Assigned(FLsFgModeTitleLbl) then
  begin
    FLsFgModeTitleLbl.Enabled := FgActive;
    FLsFgModeTitleLbl.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsFgModeComboBox) then
  begin
    FLsFgModeComboBox.Enabled := FgActive;
    FLsFgModeComboBox.Visible := (FInterpolationMethod = imMako);
  end;

  // Multiplier vs Target FPS
  if Assigned(FLsMultiplierTitleLbl) then
  begin
    FLsMultiplierTitleLbl.Enabled := FgActive and not AdaptiveActive;
    FLsMultiplierTitleLbl.Visible := (FInterpolationMethod = imLsfg) or ((FInterpolationMethod = imMako) and not AdaptiveActive);
  end;
  if Assigned(FLsMultiplierTrackBar) then
  begin
    FLsMultiplierTrackBar.Enabled := FgActive and not AdaptiveActive;
    FLsMultiplierTrackBar.Visible := (FInterpolationMethod = imLsfg) or ((FInterpolationMethod = imMako) and not AdaptiveActive);
    if FgActive and not AdaptiveActive then
      FLsMultiplierTrackBar.BringToFront;
  end;
  if Assigned(FLsMultiplierValueLabel) then
  begin
    FLsMultiplierValueLabel.Enabled := FgActive and not AdaptiveActive;
    FLsMultiplierValueLabel.Visible := (FInterpolationMethod = imLsfg) or ((FInterpolationMethod = imMako) and not AdaptiveActive);
  end;

  if Assigned(FLsTargetFpsTitleLbl) then
  begin
    FLsTargetFpsTitleLbl.Enabled := AdaptiveActive;
    FLsTargetFpsTitleLbl.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
  end;
  if Assigned(FLsTargetFpsTrackBar) then
  begin
    FLsTargetFpsTrackBar.Enabled := AdaptiveActive;
    FLsTargetFpsTrackBar.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
    if AdaptiveActive then
      FLsTargetFpsTrackBar.BringToFront;
  end;
  if Assigned(FLsTargetFpsValueLabel) then
  begin
    FLsTargetFpsValueLabel.Enabled := AdaptiveActive;
    FLsTargetFpsValueLabel.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
  end;
  if Assigned(FLsAdaptiveMaxMultTitleLbl) then
  begin
    FLsAdaptiveMaxMultTitleLbl.Enabled := AdaptiveActive;
    FLsAdaptiveMaxMultTitleLbl.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
  end;
  if Assigned(FLsAdaptiveMaxMultComboBox) then
  begin
    FLsAdaptiveMaxMultComboBox.Enabled := AdaptiveActive;
    FLsAdaptiveMaxMultComboBox.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
  end;
  if Assigned(FLsSteady2xCapCheckBox) then
  begin
    FLsSteady2xCapCheckBox.Enabled := AdaptiveActive;
    FLsSteady2xCapCheckBox.Visible := False;
  end;
  if Assigned(FLsSteady2xCapToggle) then
  begin
    FLsSteady2xCapToggle.Enabled := AdaptiveActive;
    FLsSteady2xCapToggle.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
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
    FLsSmoothCadenceToggle.Visible := (FInterpolationMethod = imMako) and AdaptiveActive;
    FLsSmoothCadenceToggle.SyncFromLinked;
  end;

  // Shared FG Controls
  if Assigned(FLsFlowScaleTitleLbl) then
  begin
    FLsFlowScaleTitleLbl.Enabled := FgActive;
    FLsFlowScaleTitleLbl.Visible := (FInterpolationMethod in [imLsfg, imMako]);
  end;
  if Assigned(FLsFlowScaleTrackBar) then
  begin
    FLsFlowScaleTrackBar.Enabled := FgActive;
    FLsFlowScaleTrackBar.Visible := (FInterpolationMethod in [imLsfg, imMako]);
  end;
  if Assigned(FLsFlowScaleValueLabel) then
  begin
    FLsFlowScaleValueLabel.Enabled := FgActive;
    FLsFlowScaleValueLabel.Visible := (FInterpolationMethod in [imLsfg, imMako]);
  end;

  // MAKO-only FG Controls
  if Assigned(FLsBaseFpsCapTitleLbl) then
  begin
    FLsBaseFpsCapTitleLbl.Enabled := FgActive;
    FLsBaseFpsCapTitleLbl.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsBaseFpsCapTrackBar) then
  begin
    FLsBaseFpsCapTrackBar.Enabled := FgActive;
    FLsBaseFpsCapTrackBar.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsBaseFpsCapValueLabel) then
  begin
    FLsBaseFpsCapValueLabel.Enabled := FgActive;
    FLsBaseFpsCapValueLabel.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsRefreshThresholdTitleLbl) then
  begin
    FLsRefreshThresholdTitleLbl.Enabled := FgActive;
    FLsRefreshThresholdTitleLbl.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsRefreshThresholdTrackBar) then
  begin
    FLsRefreshThresholdTrackBar.Enabled := FgActive;
    FLsRefreshThresholdTrackBar.Visible := (FInterpolationMethod = imMako);
  end;
  if Assigned(FLsRefreshThresholdValueLabel) then
  begin
    FLsRefreshThresholdValueLabel.Enabled := FgActive;
    FLsRefreshThresholdValueLabel.Visible := (FInterpolationMethod = imMako);
  end;

  if Assigned(FLsFgLiveCheckBox) then FLsFgLiveCheckBox.Enabled := FgActive;
  if Assigned(FLsFgLiveToggle) then
  begin
    FLsFgLiveToggle.Enabled := FgActive;
    FLsFgLiveToggle.Visible := (FInterpolationMethod = imMako);
    FLsFgLiveToggle.SyncFromLinked;
  end;
  if Assigned(FLsAllowFp16CheckBox) then FLsAllowFp16CheckBox.Enabled := FgActive;
  if Assigned(FLsAllowFp16Toggle) then
  begin
    FLsAllowFp16Toggle.Enabled := FgActive;
    FLsAllowFp16Toggle.Visible := (FInterpolationMethod in [imLsfg, imMako]);
    FLsAllowFp16Toggle.SyncFromLinked;
  end;
  if Assigned(FLsPerfModeCheckBox) then FLsPerfModeCheckBox.Enabled := FgActive;
  if Assigned(FLsPerfModeToggle) then
  begin
    FLsPerfModeToggle.Enabled := FgActive;
    FLsPerfModeToggle.Visible := (FInterpolationMethod in [imLsfg, imMako]);
    FLsPerfModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsUltraPerfCheckBox) then FLsUltraPerfCheckBox.Enabled := FgActive;
  if Assigned(FLsUltraPerfToggle) then
  begin
    FLsUltraPerfToggle.Enabled := FgActive;
    FLsUltraPerfToggle.Visible := (FInterpolationMethod = imMako);
    FLsUltraPerfToggle.SyncFromLinked;
  end;

  // lsfg-vk Quirks
  if Assigned(FLsOverridePresentModeCheckBox) then FLsOverridePresentModeCheckBox.Enabled := FgActive;
  if Assigned(FLsOverridePresentModeToggle) then
  begin
    FLsOverridePresentModeToggle.Enabled := FgActive;
    FLsOverridePresentModeToggle.Visible := (FInterpolationMethod = imLsfg);
    FLsOverridePresentModeToggle.SyncFromLinked;
  end;
  if Assigned(FLsPreserveSwapchainCheckBox) then FLsPreserveSwapchainCheckBox.Enabled := FgActive;
  if Assigned(FLsPreserveSwapchainToggle) then
  begin
    FLsPreserveSwapchainToggle.Enabled := FgActive;
    FLsPreserveSwapchainToggle.Visible := (FInterpolationMethod = imLsfg);
    FLsPreserveSwapchainToggle.SyncFromLinked;
  end;

  // Deprecated lsfg-vk controls (hidden in 2.0, state kept synced for compatibility)
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
    FLsPacingTitleLbl.Visible := (FInterpolationMethod = imLsfg);
  end;
  if Assigned(FLsPacingComboBox) then
  begin
    FLsPacingComboBox.Enabled := FgActive;
    FLsPacingComboBox.Visible := (FInterpolationMethod = imLsfg);
  end;

  if Assigned(FLsGpuTitleLbl) then FLsGpuTitleLbl.Enabled := FgActive;
  if Assigned(FLsGpuComboBox) then FLsGpuComboBox.Enabled := FgActive;

  // None notice
  if Assigned(FLsDisabledNoticeLbl) then
    FLsDisabledNoticeLbl.Visible := (FInterpolationMethod = imNone);

  // Spatial Scaling Controls (MAKO only)
  if Assigned(FLsSpatialCard) then
    FLsSpatialCard.Visible := (FInterpolationMethod = imMako);
  if Assigned(FLsScalingEnableCheckBox) then FLsScalingEnableCheckBox.Enabled := (FInterpolationMethod = imMako);
  if Assigned(FLsScalingMethodTitleLbl) then FLsScalingMethodTitleLbl.Enabled := (FInterpolationMethod = imMako);
  if Assigned(FLsScalingMethodComboBox) then FLsScalingMethodComboBox.Enabled := (FInterpolationMethod = imMako);
  if Assigned(FLsScalingFactorTitleLbl) then FLsScalingFactorTitleLbl.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingFactorTrackBar) then FLsScalingFactorTrackBar.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingFactorValueLabel) then FLsScalingFactorValueLabel.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingSharpnessTitleLbl) then FLsScalingSharpnessTitleLbl.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingSharpnessTrackBar) then FLsScalingSharpnessTrackBar.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingSharpnessValueLabel) then FLsScalingSharpnessValueLabel.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingSupersamplingCheckBox) then FLsScalingSupersamplingCheckBox.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
  if Assigned(FLsScalingSupersamplingToggle) then
  begin
    FLsScalingSupersamplingToggle.Enabled := (FInterpolationMethod = imMako) and ScalingActive;
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
    if (PosVal <= 1) and (FInterpolationMethod = imLsfg) then
      FLsMultiplierValueLabel.Caption := '1x (Bypass)'
    else if PosVal <= 1 then
      FLsMultiplierValueLabel.Caption := '1x (Disabled)'
    else
      FLsMultiplierValueLabel.Caption := IntToStr(PosVal) + 'x FPS';
  end;
  if (PosVal > 1) and (FInterpolationMethod = imNone) then
    SetInterpolationMethod(imLsfg);
  ControlStateChange(Sender);
end;

procedure TLosslessScalingTabHelper.DllPathChange(Sender: TObject);
begin
  UpdateDllStatus;
  UpdateMigrationAlertState;
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
    if FInterpolationMethod = imLsfg then
    begin
      OD.Title := 'Select lsfg-vk.dll';
      OD.Filter := 'Lossless Scaling Vulkan DLL (lsfg-vk.dll)|lsfg-vk.dll|Dynamic Libraries (*.dll)|*.dll|All Files (*)|*';
    end
    else
    begin
      OD.Title := 'Select Lossless.dll';
      OD.Filter := 'Lossless Scaling DLL (Lossless.dll)|Lossless.dll|Dynamic Libraries (*.dll)|*.dll|All Files (*)|*';
    end;
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
  if SameText(ExtractFileName(DllP), 'lsfg-vk.dll') then
    DllP := ExtractFilePath(DllP) + 'Lossless.dll';
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
    1: PacingStr := 'none';
  else
    PacingStr := 'vsync';
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
var
  Lines, LegacyLines: TStringList;
  OutDir, OutPath, LegacyOutPath, PacingStr, DllP, ExeName, ProfileName: string;
  MultVal: Integer;
  FlowStr, PerfStr, HdrStr, AllowFp16Str, OverridePresentStr, PreserveSwapchainStr: string;
begin
  Result := '';
  if FLsMultiplierTrackBar.Position <= 1 then Exit;
  
  DllP := Trim(FLsDllPathEdit.Text);
  if SameText(ExtractFileName(DllP), 'Lossless.dll') then
    DllP := ExtractFilePath(DllP) + 'lsfg-vk.dll';
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
  
  MultVal := FLsMultiplierTrackBar.Position;
  FlowStr := StringReplace(FormatFloat('0.00', FLsFlowScaleTrackBar.Position / 100.0), ',', '.', [rfReplaceAll]);
  if FLsPerfModeCheckBox.Checked then PerfStr := 'true' else PerfStr := 'false';
  if FLsHdrModeCheckBox.Checked then HdrStr := 'true' else HdrStr := 'false';
  if Assigned(FLsAllowFp16CheckBox) and FLsAllowFp16CheckBox.Checked then AllowFp16Str := 'true' else AllowFp16Str := 'false';
  if Assigned(FLsOverridePresentModeCheckBox) and FLsOverridePresentModeCheckBox.Checked then OverridePresentStr := 'true' else OverridePresentStr := 'false';
  if Assigned(FLsPreserveSwapchainCheckBox) and FLsPreserveSwapchainCheckBox.Checked then PreserveSwapchainStr := 'true' else PreserveSwapchainStr := 'false';

  case FLsPacingComboBox.ItemIndex of
    1: PacingStr := 'none';
  else
    PacingStr := 'vsync';
  end;
  
  // 1. Write canonical conf.toml adhering strictly to lsfg-vk 2.0 schema
  Lines := TStringList.Create;
  try
    Lines.Add('version = 2');
    Lines.Add('');
    Lines.Add('[global]');
    Lines.Add('dll = "' + DllP + '"');
    Lines.Add('allow_fp16 = ' + AllowFp16Str);
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "pascube"');
    Lines.Add('active_in = ["pascube"]');
    Lines.Add('multiplier = ' + IntToStr(MultVal));
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('performance_mode = ' + PerfStr);
    Lines.Add('pacing = "' + PacingStr + '"');
    Lines.Add('override_present_mode = ' + OverridePresentStr);
    Lines.Add('preserve_swapchain_image_count = ' + PreserveSwapchainStr);
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "vkcube"');
    Lines.Add('active_in = ["vkcube"]');
    Lines.Add('multiplier = ' + IntToStr(MultVal));
    Lines.Add('flow_scale = ' + FlowStr);
    Lines.Add('performance_mode = ' + PerfStr);
    Lines.Add('pacing = "' + PacingStr + '"');
    Lines.Add('override_present_mode = ' + OverridePresentStr);
    Lines.Add('preserve_swapchain_image_count = ' + PreserveSwapchainStr);
    
    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      ProfileName := ChangeFileExt(ExtractFileName(ExeName), '');
      if ProfileName = '' then ProfileName := ExeName;
      Lines.Add('');
      Lines.Add('[[profile]]');
      Lines.Add('name = "' + ProfileName + '"');
      Lines.Add('active_in = ["' + ExeName + '", "' + ProfileName + '", "' + ProfileName + '.exe", "' + ProfileName + '_dx12.exe", "' + ProfileName + '_dx11.exe", "' + LowerCase(ProfileName) + '_dx12.exe", "' + LowerCase(ProfileName) + '_dx11.exe", "wine64-preloader", "wine-preloader"]');
      Lines.Add('multiplier = ' + IntToStr(MultVal));
      Lines.Add('flow_scale = ' + FlowStr);
      Lines.Add('performance_mode = ' + PerfStr);
      Lines.Add('pacing = "' + PacingStr + '"');
      Lines.Add('override_present_mode = ' + OverridePresentStr);
      Lines.Add('preserve_swapchain_image_count = ' + PreserveSwapchainStr);
    end;
    
    Lines.SaveToFile(OutPath);
    Result := OutPath;
  finally
    Lines.Free;
  end;

  // 2. Write mirror to lsfg.toml with legacy v1 schema for backward compatibility with tools and tests
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
    LegacyLines.Add('performance_mode = ' + PerfStr);
    LegacyLines.Add('hdr_mode = ' + HdrStr);
    if AllowFp16Str = 'true' then
      LegacyLines.Add('legacy = false')
    else
      LegacyLines.Add('legacy = true');
    LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');
    LegacyLines.Add('');
    LegacyLines.Add('[[game]]');
    LegacyLines.Add('exe = "vkcube"');
    LegacyLines.Add('dll = "' + DllP + '"');
    LegacyLines.Add('multiplier = ' + IntToStr(MultVal));
    LegacyLines.Add('flow_scale = ' + FlowStr);
    LegacyLines.Add('performance_mode = ' + PerfStr);
    LegacyLines.Add('hdr_mode = ' + HdrStr);
    if AllowFp16Str = 'true' then
      LegacyLines.Add('legacy = false')
    else
      LegacyLines.Add('legacy = true');
    LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');
    
    if Assigned(FForm) and (FForm is Tgoverlayform) and (Tgoverlayform(FForm).FActiveGameName <> '') then
    begin
      ExeName := Tgoverlayform(FForm).FActiveGameName;
      LegacyLines.Add('');
      LegacyLines.Add('[[game]]');
      LegacyLines.Add('exe = "' + ExeName + '"');
      LegacyLines.Add('dll = "' + DllP + '"');
      LegacyLines.Add('multiplier = ' + IntToStr(MultVal));
      LegacyLines.Add('flow_scale = ' + FlowStr);
      LegacyLines.Add('performance_mode = ' + PerfStr);
      LegacyLines.Add('hdr_mode = ' + HdrStr);
      if AllowFp16Str = 'true' then
        LegacyLines.Add('legacy = false')
      else
        LegacyLines.Add('legacy = true');
      LegacyLines.Add('experimental_present_mode = "' + PacingStr + '"');
    end;
    
    LegacyLines.SaveToFile(LegacyOutPath);
  finally
    LegacyLines.Free;
  end;
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
    Lines.Add('pacing = "vsync"');
    Lines.Add('override_present_mode = true');
    Lines.Add('preserve_swapchain_image_count = false');
    Lines.Add('');
    Lines.Add('[[profile]]');
    Lines.Add('name = "vkcube"');
    Lines.Add('active_in = ["vkcube"]');
    Lines.Add('multiplier = 2');
    Lines.Add('flow_scale = 1.00');
    Lines.Add('performance_mode = false');
    Lines.Add('pacing = "vsync"');
    Lines.Add('override_present_mode = true');
    Lines.Add('preserve_swapchain_image_count = false');
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
  EffectiveMethod: TInterpolationMethod;
begin
  Result := '';
  EffectiveMethod := FInterpolationMethod;
  if EffectiveMethod = imNone then
  begin
    if FLsMultiplierTrackBar.Position > 1 then
      EffectiveMethod := imLsfg
    else
      Exit('');
  end;

  DllP := Trim(FLsDllPathEdit.Text);
  if EffectiveMethod = imLsfg then
  begin
    if SameText(ExtractFileName(DllP), 'Lossless.dll') then
      DllP := ExtractFilePath(DllP) + 'lsfg-vk.dll';
  end
  else if EffectiveMethod = imMako then
  begin
    if SameText(ExtractFileName(DllP), 'lsfg-vk.dll') then
      DllP := ExtractFilePath(DllP) + 'Lossless.dll';
  end;
  if (DllP = '') or not FileExists(DllP) then
    Exit('');

  if EffectiveMethod = imLsfg then
  begin
    if FLsMultiplierTrackBar.Position <= 1 then
      Exit('');
    TomlP := WriteLsfgTomlConfig;
    if (TomlP <> '') and FileExists(TomlP) then
      Result := 'LSFGVK_CONFIG="' + TomlP + '" LSFG_CONFIG="' + TomlP + '"'
    else
      Result := '';
  end
  else if EffectiveMethod = imMako then
  begin
    if (FLsMultiplierTrackBar.Position <= 1) and
       (not Assigned(FLsFgModeComboBox) or (FLsFgModeComboBox.ItemIndex <> 1)) and
       (not Assigned(FLsScalingMethodComboBox) or (FLsScalingMethodComboBox.ItemIndex <= 0)) then
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
end;

procedure TLosslessScalingTabHelper.LoadLosslessConfig;
var
  Ini: TIniFile;
  CfgPath, CfgDir, TomlPath, LegacyTomlPath, DllVal, PacingVal, GpuVal, FlowVal, MultVal, MethodStr: string;
  FlowInt, MultInt, GpuIdx: Integer;
  IsLosslessOn, TomlFound: Boolean;
  LoadedMethod: TInterpolationMethod;
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
    FLsDllPathEdit.Text := '';
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
    if Assigned(FLsOverridePresentModeCheckBox) then
      FLsOverridePresentModeCheckBox.Checked := True;
    if Assigned(FLsPreserveSwapchainCheckBox) then
      FLsPreserveSwapchainCheckBox.Checked := False;

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

    // Check if GOVERLAY_LOSSLESS and INTERPOLATION_METHOD are enabled in bgmod.conf
    IsLosslessOn := False;
    MethodStr := '';
    if FileExists(CfgPath) then
    begin
      Ini := TIniFile.Create(CfgPath);
      try
        IsLosslessOn := Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0') = '1';
        MethodStr := LowerCase(Trim(Ini.ReadString('Config', 'INTERPOLATION_METHOD', '')));
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

    if MethodStr = 'lsfg' then
      LoadedMethod := imLsfg
    else if MethodStr = 'mako' then
      LoadedMethod := imMako
    else if MethodStr = 'none' then
      LoadedMethod := imNone
    else
    begin
      if IsLosslessOn then
      begin
        if FileExists(TomlPath) then
          LoadedMethod := imMako
        else if FileExists(LegacyTomlPath) then
          LoadedMethod := imLsfg
        else
          LoadedMethod := imMako;
      end
      else
        LoadedMethod := imNone;
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
        if LoadedMethod in [imLsfg, imNone] then
          MakoCfg.HdrMode := LegacyCfg.HdrMode;
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
      if Assigned(FLsOverridePresentModeCheckBox) then
        FLsOverridePresentModeCheckBox.Checked := MakoCfg.OverridePresentMode;
      if Assigned(FLsPreserveSwapchainCheckBox) then
        FLsPreserveSwapchainCheckBox.Checked := MakoCfg.PreserveSwapchainImageCount;

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
      if PacingVal = 'none' then FLsPacingComboBox.ItemIndex := 1
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
        if Assigned(FLsOverridePresentModeCheckBox) then
          FLsOverridePresentModeCheckBox.Checked := (Ini.ReadString('Config', 'LS_OVERRIDE_PRESENT_MODE', Ini.ReadString('Env', 'LS_OVERRIDE_PRESENT_MODE', '1')) = '1');
        if Assigned(FLsPreserveSwapchainCheckBox) then
          FLsPreserveSwapchainCheckBox.Checked := (Ini.ReadString('Config', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT', Ini.ReadString('Env', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT', '0')) = '1');
        
        PacingVal := LowerCase(Trim(Ini.ReadString('Config', 'LS_PACING', Ini.ReadString('Env', 'LSFG_EXPERIMENTAL_PRESENT_MODE', Ini.ReadString('Env', 'LSFGVK_PACING', 'vsync')))));
        if PacingVal = 'none' then FLsPacingComboBox.ItemIndex := 1
        else FLsPacingComboBox.ItemIndex := 0;
      finally
        Ini.Free;
      end;
    end;

    // Fallback: detect DLL from Steam if not already configured
    if Trim(FLsDllPathEdit.Text) = '' then
      FLsDllPathEdit.Text := DetectSteamLosslessDll(LoadedMethod = imLsfg)
    else
    begin
      if (LoadedMethod = imLsfg) and SameText(ExtractFileName(FLsDllPathEdit.Text), 'Lossless.dll') then
        FLsDllPathEdit.Text := ExtractFilePath(FLsDllPathEdit.Text) + 'lsfg-vk.dll'
      else if (LoadedMethod = imMako) and SameText(ExtractFileName(FLsDllPathEdit.Text), 'lsfg-vk.dll') then
        FLsDllPathEdit.Text := ExtractFilePath(FLsDllPathEdit.Text) + 'Lossless.dll';
    end;

    SetInterpolationMethod(LoadedMethod);
  finally
    if Assigned(FForm) and (FForm is Tgoverlayform) then
      Tgoverlayform(FForm).FLoadingConfig := False;
  end;
  
  UpdateControlsEnabled;
  UpdateDllStatus;
  UpdateEngineStatus;
  UpdateMigrationAlertState;
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
  CfgPath, CfgDir, DllPath, MethodStr: string;
  IsEnabled: Boolean;
begin
  UpdateControlsEnabled;
  CfgPath := GetConfigFile;
  CfgDir := ExtractFilePath(CfgPath);
  if not DirectoryExists(CfgDir) then
    ForceDirectories(CfgDir);
    
  DllPath := Trim(FLsDllPathEdit.Text);
  IsEnabled := (FInterpolationMethod <> imNone) and (DllPath <> '') and FileExists(DllPath) and
               ((FLsMultiplierTrackBar.Position > 1) or
                (Assigned(FLsFgModeComboBox) and (FLsFgModeComboBox.ItemIndex = 1)) or
                (Assigned(FLsScalingMethodComboBox) and (FLsScalingMethodComboBox.ItemIndex > 0)));
  
  Ini := TIniFile.Create(CfgPath);
  try
    case FInterpolationMethod of
      imLsfg: MethodStr := 'lsfg';
      imMako: MethodStr := 'mako';
    else
      MethodStr := 'none';
    end;
    Ini.WriteString('Config', 'INTERPOLATION_METHOD', MethodStr);

    if Assigned(FLsGpuComboBox) and (FLsGpuComboBox.ItemIndex > 0) then
      Ini.WriteString('Config', 'LS_GPU', IntToStr(FLsGpuComboBox.ItemIndex - 1))
    else
      Ini.DeleteKey('Config', 'LS_GPU');

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
      Ini.DeleteKey('Config', 'LS_OVERRIDE_PRESENT_MODE');
      Ini.DeleteKey('Config', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT');

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
      Ini.DeleteKey('Env', 'LS_OVERRIDE_PRESENT_MODE');
      Ini.DeleteKey('Env', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT');

      if FInterpolationMethod = imLsfg then
      begin
        WriteLsfgTomlConfig(CfgDir);
      end
      else if FInterpolationMethod = imMako then
      begin
        WriteMakoTomlConfig(CfgDir);
      end;
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
      Ini.DeleteKey('Config', 'LS_OVERRIDE_PRESENT_MODE');
      Ini.DeleteKey('Config', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT');

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
      Ini.DeleteKey('Env', 'LS_OVERRIDE_PRESENT_MODE');
      Ini.DeleteKey('Env', 'LS_PRESERVE_SWAPCHAIN_IMAGE_COUNT');

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
