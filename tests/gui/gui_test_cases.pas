unit gui_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Buttons, fpcunit, testregistry;

type
  TGoverlayGuiTests = class(TTestCase)
  private
    function ReadGpuDriver: string;
    function ReadFileText(const APath: string): string;
    procedure NavigateReshadeTab;
    procedure NavigateVkBasaltTab;
    procedure NavigateVkSumiTab;
    procedure NavigateOptiScalerTab;
    procedure NavigateTweaksTab;
    procedure SeedOptiScalerFiles;
    function OptiIniPath: string;
    function FakeIniPath: string;
    function BgmodConfPath: string;
    function ReadBgmodConf(const ASection, AKey: string): string;
    procedure SaveOpti;
    procedure NavigateMangoHud;
    function MangoConfPath: string;
    procedure SaveMango;
    procedure CycleBtnUntilImage(ABtn: TBitBtn; AImageIndex, AMaxClicks: Integer);
    procedure CycleBtnUntilTag(ABtn: TBitBtn; ATag, AMaxClicks: Integer);
  published
    procedure TestFormCreated;
    procedure TestDriverToggleRoundTrip;
    procedure TestNavigateOptiScalerTab;
    procedure TestNavigateLosslessScalingTab;
    procedure TestLosslessScalingEnvVarsGeneration;
    procedure TestLosslessScalingBgmodConfRoundtrip;
    procedure TestLosslessScalingPerGameContextIsolation;
    procedure TestLosslessScalingDynamicConfigFileAndLog;
    procedure TestLosslessScalingDynamicDllAndMigrationAssistant;
    procedure TestNavigateReshadeTab;
    procedure TestReShadeTabOrderingAndCardControls;
    procedure TestReShadeConfigSaveAndLoad;
    procedure TestNavigateVkBasaltTab;
    procedure TestVkBasaltCasToggleSave;
    procedure TestNavigateVkSumiTab;
    procedure TestVkSumiContrastSaveAndRestore;
    // OptiScaler tab - full control coverage
    procedure TestOptiMenuScaleSave;
    procedure TestOptiShortcutKeySave;
    procedure TestOptiSpoofToggleSave;
    procedure TestOptiOverrideNvapiSave;
    procedure TestOptiPatcherToggleSave;
    procedure TestOptiFsrVersionSelector;
    procedure TestOptiLogLevelSelector;
    procedure TestOptiPreferredUpscalerSave;
    procedure TestOptiForceFsr4Int8Save;
    procedure TestOptiFilenameDllSave;
    procedure TestOptiChannelSave;
    procedure TestUpscalerChannelPersistence;
    procedure TestCustomOptiScalerBuildSupport;
    procedure TestOptiEmuFp8Save;
    procedure TestOptiForceReflexSave;
    procedure TestOptiForceReflexSaveSeedingWhenMissing;
    procedure TestOptiForceReflexAutoSave;
    procedure TestOptiMethodRadioAutoSave;
    procedure TestMangoFilterRadioGroupAutoSave;
    procedure TestCustomEditAutoSave;
    procedure TestOptiLatencyFlexSave;
    procedure TestOptiTraceLogSave;
    procedure TestOptiUpdateButtonsGuarded;
    procedure TestOptiShortcutCaptureBound;
    procedure TestOptiScalerToggleNvidiaReEnableState;
    procedure TestGlobalOptiScalerToggleSync;
    procedure TestCommandPanelRightMarginConsistency;
    procedure TestFloatingActionDockAndFinishDialog;
    procedure TestPasCubeAutoLaunchHiddenAndLowercaseUpscalers;
    procedure TestLaunchSplashSettingsMenuItem;
    procedure TestDlssEnablerTagMatchingNoFalseUpdate;
    procedure TestDlssEnablerUpdateStatusDisplay;
    procedure TestDlssEnablerChannelUpdateSuppressesDowngrades;
    procedure TestDlssEnablerSyncSupportingFiles;
    procedure TestDlssEnablerStreamlineBackupAndCleanup;
    procedure TestSafeUninstallChangesRestoresStreamlineBackups;
    procedure TestThirdPartyProxyDllPreservedDuringLaunchAndUninstall;
    procedure TestOptiscalerAndDlssEnablerToggleKeyDisplay;
    procedure TestOptiScalerOptionsCardHeightAndNoScroll;
    // MangoHud tabs - full control coverage
    procedure TestMangoNavigateAndPreset;
    procedure TestMangoVisualTab;
    procedure TestMangoMetricsGpuTab;
    procedure TestMangoMetricsCpuTab;
    procedure TestMangoMetricsMemIoTab;
    procedure TestMangoMetricsOtherTab;
    procedure TestMangoPerformanceTab;
    procedure TestMangoExtrasTab;
    procedure TestMangoGlobalSideEffects;
    procedure TestMangoSettingsPersistence;
    procedure TestVkBasaltRoundTrip;
    procedure TestVkSumiRoundTrip;
    procedure TestTweaksTabRoundTrip;
    procedure TestProtonLocalShaderCacheTweak;
    procedure TestProtonDiscordBridgeTweak;
    procedure TestGamePerformanceTweak;
    procedure TestTweaksCardLayoutAndClick;
    procedure TestGlobalCustomVariablesReuseAndInheritance;
    procedure TestLaunchArgumentsCardAndInheritance;
    procedure TestTabSwitchingPersistence;
    procedure TestNonSteamRemoveFoldersMenu;
    procedure TestHomeTabHidesToggles;
    procedure TestHomeTabLibraries;
    procedure TestWindowResizabilityAndGeometry;
    procedure TestSidebarTabPathResetGlobalMode;
    procedure TestTweaksResetOnMissingConfig;
    procedure TestMangoPresetCardHighlightsResetOnProfileSwitch;
    procedure TestMissingConfigResetsControlsAllTabs;
    procedure TestGameCardClickSynchronizesAllToolPaths;
    procedure TestGameCardClickRestoresMangoHudTabVisibility;
    procedure TestVkBasaltRestoreDefaults;
    procedure TestVkBasaltPipelineCardVisibleAndBounds;
    procedure TestVkBasaltPipelineInteractions;
    procedure TestVkBasaltLutInteractions;
    procedure TestVkBasaltPipelineScrollOnManyEffects;
    procedure TestVkBasaltShadersListDeduplicationAndExclusions;
    procedure TestMissingDependencyWarningBanners;
    procedure TestPerformanceFiltersLayoutOnResize;
    procedure TestMangoHudFrameTimingDetailed;
    procedure TestMangoHudMetricsCompactToggles;
    procedure TestMangoHudVisualCompactToggles;
    procedure TestMangoHudPerformanceCompactToggles;
    procedure TestMangoHudExtrasCompactToggles;
    procedure TestLosslessScalingCompactToggles;
    procedure TestLosslessScalingMakoTogglesLayoutAndNoScroll;
    procedure TestLosslessScalingMethodSwitching;
    procedure TestMakoUpdateNotificationPersistenceAndHomeSync;
    procedure TestLsfgVkUpdateNotificationPersistenceAndHomeSync;
    procedure TestLsfgVkBuildsHtmlParsingIgnoresGitVersion;
    procedure TestMangoHudPresetsToggleSynchronization;
    procedure TestMangoHudMetricGraphs;
    procedure TestFinishConfigurationDialogModernSteamUI;
    procedure TestDockOpenConfigFileAction;
    procedure TestDynamicLaunchCommandGeneration;
    procedure TestToggleSwitchAutoSave;
    procedure TestOptiScalerTogglesLoadFromDisk;
    procedure TestGlobalToolTogglesPersistenceAcrossLaunches;
    procedure TestGameCardFallbackCoverGeneration;
    procedure TestToolToggleOffPreservesConfigFiles;
    procedure TestPerGameLaunchCommandImmediateUpdate;
    procedure TestPreviewLaunchEnvironmentHonorsToolToggles;
    procedure TestFastGamesTabReturnAndInPlaceBadgeUpdate;
    procedure TestDownloadProgressNoFloatingBanner;
    procedure TestLsfgSteamBetaNoticeDialog;
    procedure TestMethodLogoDimming;
    procedure TestCloneGlobalConfigsToGameCard;
    procedure TestCloneGlobalConfigsDockMenu;
    procedure TestGameCardsAlphabeticalSorting;
  end;

implementation

uses
  overlayunit, games_tab, configmanager, overlay_config, optiscaler_update, finish_dialog, ExtCtrls, ComCtrls, StdCtrls, themeunit, IniFiles, FileUtil, test_isolation, Graphics, Forms, Controls, lossless_scaling_tab, lsfg_migration_dialog, lsfg_steam_beta_dialog, vkbasalt_tab, toggle_switch, mangohud_ui, optiscaler_tab, bgmod_resources, reshade_tab, Process, BaseUnix, tweaks_md3;

const
  // State the MangoHud toggle buttons already carry: the click handlers switch
  // on ImageIndex (and on Tag for the frames/joule pair), the caption is only
  // the text drawn on top of it. Tests match on these so they keep working
  // when the interface is translated.
  IMG_FRAMETIME_HISTOGRAM = 7;
  IMG_CORELOAD_GRAPH      = 7;
  IMG_FPSAVG_1PCT_LOW     = 9;
  IMG_FPSAVG_01PCT_LOW    = 10;
  TAG_FRAMES_PER_JOULE    = 0;
  TAG_JOULES_PER_FRAME    = 1;

function TGoverlayGuiTests.ReadGpuDriver: string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetConfigFilePath);
  try
    Result := LowerCase(Trim(Ini.ReadString('OptiScaler', 'GpuDriver', '')));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.TestFormCreated;
begin
  AssertTrue('goverlayform is assigned', Assigned(goverlayform));
  AssertTrue('mesaRadioButton is assigned', Assigned(goverlayform.mesaRadioButton));
  AssertTrue('nvidiaRadioButton is assigned', Assigned(goverlayform.nvidiaRadioButton));
  AssertTrue('optiscalerLabel is assigned', Assigned(goverlayform.optiscalerLabel));
end;

procedure TGoverlayGuiTests.TestDriverToggleRoundTrip;
begin
  // Harness seeds GpuDriver=nvidia before the form is created. Both
  // transitions below are asserted, so the test is falsifiable.
  AssertEquals('seed state must be nvidia', 'nvidia', ReadGpuDriver);

  goverlayform.mesaRadioButton.Checked := True;
  AssertEquals('mesa persisted after checking mesa', 'mesa', ReadGpuDriver);
  AssertTrue('forcereflex enabled on mesa', goverlayform.forcereflexCheckBox.Enabled);
  AssertFalse('forcereflex unchecked by default on mesa', goverlayform.forcereflexCheckBox.Checked);

  goverlayform.nvidiaRadioButton.Checked := True;
  AssertEquals('nvidia persisted after checking nvidia', 'nvidia', ReadGpuDriver);
  AssertFalse('forcereflex disabled on nvidia', goverlayform.forcereflexCheckBox.Enabled);
  AssertFalse('spoof unchecked on nvidia', goverlayform.spoofCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestNavigateOptiScalerTab;
begin
  // TControl.Click is protected; invoking OnClick directly exercises the
  // exact .lfm binding -> handler chain, which is what this test verifies.
  AssertTrue('optiscalerLabel.OnClick is bound', Assigned(goverlayform.optiscalerLabel.OnClick));
  goverlayform.nvidiaRadioButton.Checked := True;
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  AssertTrue('optiscaler tab is active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.optiscalerTabSheet);
  AssertTrue('lossless scaling tab is visible alongside optiscaler',
    goverlayform.losslessScalingTabSheet.TabVisible);
  AssertFalse('forcereflex stays disabled on nvidia after tab click', goverlayform.forcereflexCheckBox.Enabled);
  AssertFalse('spoof stays disabled on nvidia after tab click', goverlayform.spoofCheckBox.Enabled);
end;

procedure TGoverlayGuiTests.TestNavigateLosslessScalingTab;
begin
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  AssertTrue('lossless scaling tab is visible', goverlayform.losslessScalingTabSheet.TabVisible);
  AssertFalse('preview pill is hidden on optiscaler tab initially', goverlayform.FFADock.PreviewVisible);

  // Switch to Lossless Scaling tab
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  AssertTrue('lossless scaling tab is active',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.losslessScalingTabSheet);
  AssertTrue('preview pill is visible in dock on lossless scaling tab',
    goverlayform.FFADock.PreviewVisible);

  // Switch back to OptiScaler tab
  goverlayform.goverlayPageControl.ActivePage := goverlayform.optiscalerTabSheet;
  AssertTrue('optiscaler tab is active',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.optiscalerTabSheet);
  AssertFalse('preview pill is hidden in dock on optiscaler tab after tab switch',
    goverlayform.FFADock.PreviewVisible);

  // Switch back to Lossless Scaling again
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  AssertTrue('preview pill is visible again on lossless scaling tab',
    goverlayform.FFADock.PreviewVisible);
end;

procedure TGoverlayGuiTests.TestLosslessScalingEnvVarsGeneration;
var
  Helper: TLosslessScalingTabHelper;
  EnvVars: string;
  DummyDll: string;
  DummyFile: TFileStream;
begin
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless helper is assigned', Assigned(Helper));
  
  DummyDll := IsolatedHome + '/.local/share/goverlay/test_lsfg_env.dll';
  ForceDirectories(ExtractFilePath(DummyDll));
  DummyFile := TFileStream.Create(DummyDll, fmCreate);
  DummyFile.Free;
  try
    Helper.DllPathEdit.Text := DummyDll;
    
    // Default 1x (no framegen) -> empty env vars
    Helper.MultiplierTrackBar.Position := 1;
    Helper.MultiplierTrackBar.OnChange(Helper.MultiplierTrackBar);
    EnvVars := Helper.GetActiveEnvVars;
    AssertEquals('1x yields empty env vars', '', EnvVars);
    
    // 2x enabled -> exports LSFG_CONFIG pointing to lsfg.toml
    Helper.MultiplierTrackBar.Position := 2;
    Helper.MultiplierTrackBar.OnChange(Helper.MultiplierTrackBar);
    EnvVars := Helper.GetActiveEnvVars;
    AssertTrue('LSFG_CONFIG is present', Pos('LSFG_CONFIG=', EnvVars) > 0);
  finally
    if FileExists(DummyDll) then DeleteFile(DummyDll);
  end;
end;

procedure TGoverlayGuiTests.TestLosslessScalingBgmodConfRoundtrip;
var
  Helper: TLosslessScalingTabHelper;
  DummyDll, TargetConfPath, TargetTomlPath: string;
  Ini: TIniFile;
  DummyFile: TFileStream;
begin
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless helper is assigned', Assigned(Helper));
  
  // Test invalid DLL path status label
  Helper.DllPathEdit.Text := '/nonexistent/path/Lossless.dll';
  AssertTrue('Status label warns when DLL is missing',
    (Pos('Switch Lossless Scaling to lsfg-vk beta branch', Helper.DllStatusLabel.Caption) > 0) or
    (Pos('Install Lossless scaling on steam', Helper.DllStatusLabel.Caption) > 0));
  
  // Create a temporary dummy DLL file to simulate valid Lossless.dll
  DummyDll := IsolatedHome + '/.local/share/goverlay/test_Lossless.dll';
  ForceDirectories(ExtractFilePath(DummyDll));
  DummyFile := TFileStream.Create(DummyDll, fmCreate);
  DummyFile.Free;
  try
    // Set UI values (Position 3 = 3x)
    Helper.DllPathEdit.Text := DummyDll;
    AssertTrue('Status label confirms DLL located', Pos('DLL file located', Helper.DllStatusLabel.Caption) > 0);
    
    Helper.MultiplierTrackBar.Position := 3; // 3x
    Helper.MultiplierTrackBar.OnChange(Helper.MultiplierTrackBar);
    Helper.FlowScaleTrackBar.Position := 85;
    Helper.PerfModeCheckBox.Checked := True;
    Helper.HdrModeCheckBox.Checked := True;
    Helper.NoFp16CheckBox.Checked := True;
    Helper.PacingComboBox.ItemIndex := 0; // vsync
    
    // Verify controls enabled when multiplier > 1
    AssertTrue('FlowScale enabled at 3x', Helper.FlowScaleTrackBar.Enabled);
    AssertTrue('PerfMode enabled at 3x', Helper.PerfModeCheckBox.Enabled);
    
    // Save configuration to bgmod.conf
    Helper.SaveLosslessConfig;
    
    TargetConfPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'bgmod.conf';
    TargetTomlPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'lsfg.toml';
    AssertTrue('bgmod.conf was created', FileExists(TargetConfPath));
    AssertTrue('lsfg.toml was created', FileExists(TargetTomlPath));

    with TStringList.Create do
    try
      LoadFromFile(TargetTomlPath);
      AssertTrue('lsfg.toml contains pascube entry', Pos('exe = "pascube"', Text) > 0);
      AssertTrue('lsfg.toml contains vkcube entry', Pos('exe = "vkcube"', Text) > 0);
      AssertTrue('lsfg.toml contains multiplier 3', Pos('multiplier = 3', Text) > 0);
    finally
      Free;
    end;

    Ini := TIniFile.Create(TargetConfPath);
    try
      AssertEquals('GOVERLAY_LOSSLESS is 1 in [Config]', '1', Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0'));
      // Verify [Config] and [Env] do NOT have duplicate LS_* or LSFG_* keys
      AssertEquals('LS_DLL_PATH is not in [Config]', '', Ini.ReadString('Config', 'LS_DLL_PATH', ''));
      AssertEquals('LS_MULTIPLIER is not in [Config]', '', Ini.ReadString('Config', 'LS_MULTIPLIER', ''));
      AssertEquals('LSFG_DLL_PATH is not in [Env]', '', Ini.ReadString('Env', 'LSFG_DLL_PATH', ''));
      AssertEquals('LSFG_MULTIPLIER is not in [Env]', '', Ini.ReadString('Env', 'LSFG_MULTIPLIER', ''));
    finally
      Ini.Free;
    end;
    
    // Test LoadLosslessConfig roundtrip from lsfg.toml
    goverlayform.FLoadingConfig := True;
    try
      Helper.MultiplierTrackBar.Position := 1;
      Helper.PerfModeCheckBox.Checked := False;
    finally
      goverlayform.FLoadingConfig := False;
    end;
    Helper.LoadLosslessConfig;
    AssertEquals('Loaded Multiplier is 3x (Position 3) from lsfg.toml', 3, Helper.MultiplierTrackBar.Position);
    AssertTrue('Loaded PerfMode is True from lsfg.toml', Helper.PerfModeCheckBox.Checked);
    AssertTrue('Loaded NoFp16 is True from lsfg.toml', Helper.NoFp16CheckBox.Checked);
    AssertTrue('NoFp16 hint contains AMD uplift description', Pos('giant performance uplift on AMD GPUs', Helper.NoFp16CheckBox.Hint) > 0);
    AssertTrue('Controls enabled after loading 3x', Helper.FlowScaleTrackBar.Enabled);
    
    // Now test switching Multiplier to 1x (controls remain enabled under imLsfg)
    Helper.MultiplierTrackBar.Position := 1;
    Helper.MultiplierTrackBar.OnChange(Helper.MultiplierTrackBar);
    AssertTrue('FlowScale remains enabled at 1x under imLsfg', Helper.FlowScaleTrackBar.Enabled);
    AssertTrue('PerfMode remains enabled at 1x under imLsfg', Helper.PerfModeCheckBox.Enabled);
    AssertTrue('HdrMode remains enabled at 1x under imLsfg', Helper.HdrModeCheckBox.Enabled);
    AssertTrue('Pacing remains enabled at 1x under imLsfg', Helper.PacingComboBox.Enabled);
    AssertTrue('Gpu remains enabled at 1x under imLsfg', Helper.GpuComboBox.Enabled);
    
    Helper.SaveLosslessConfig;
    
    Ini := TIniFile.Create(TargetConfPath);
    try
      AssertEquals('GOVERLAY_LOSSLESS is 0 in [Config]', '0', Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '1'));
      AssertEquals('LS_DLL_PATH key is removed from [Config]', '', Ini.ReadString('Config', 'LS_DLL_PATH', ''));
      AssertEquals('LS_MULTIPLIER key is removed from [Config]', '', Ini.ReadString('Config', 'LS_MULTIPLIER', ''));
    finally
      Ini.Free;
    end;
    AssertFalse('lsfg.toml is removed when disabled', FileExists(TargetTomlPath));

    // Test WriteDefaultLsfgToml creates complete template with pascube and vkcube
    Helper.WriteDefaultLsfgToml(goverlayform.GetGameConfigDir(goverlayform.FActiveGameName));
    AssertTrue('Default lsfg.toml created', FileExists(TargetTomlPath));
    with TStringList.Create do
    try
      LoadFromFile(TargetTomlPath);
      AssertTrue('Default lsfg.toml contains pascube entry', Pos('exe = "pascube"', Text) > 0);
      AssertTrue('Default lsfg.toml contains vkcube entry', Pos('exe = "vkcube"', Text) > 0);
    finally
      Free;
    end;
  finally
    if FileExists(DummyDll) then
      DeleteFile(DummyDll);
  end;
end;

procedure TGoverlayGuiTests.TestLosslessScalingPerGameContextIsolation;
var
  Helper: TLosslessScalingTabHelper;
  DummyDll, GlobalDir, GameDir, GlobalToml, GameToml, GlobalConf, GameConf: string;
  Ini: TIniFile;
  DummyFileSL: TStringList;
begin
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertNotNull('FLosslessScalingHelper is allocated', Helper);

  GlobalDir := goverlayform.GetGameConfigDir('');
  GameDir   := goverlayform.GetGameConfigDir('TestGameIso');
  if not DirectoryExists(GlobalDir) then ForceDirectories(GlobalDir);
  if not DirectoryExists(GameDir) then ForceDirectories(GameDir);

  DummyDll := IncludeTrailingPathDelimiter(GlobalDir) + 'LosslessIsoTest.dll';
  GlobalToml := IncludeTrailingPathDelimiter(GlobalDir) + 'lsfg.toml';
  GameToml   := IncludeTrailingPathDelimiter(GameDir) + 'lsfg.toml';
  GlobalConf := GlobalDir + 'bgmod.conf';
  GameConf   := GameDir + 'bgmod.conf';

  // Clean up any old test artifacts
  if FileExists(GlobalToml) then DeleteFile(GlobalToml);
  if FileExists(GameToml) then DeleteFile(GameToml);

  DummyFileSL := TStringList.Create;
  try
    DummyFileSL.Text := 'dummy dll content';
    DummyFileSL.SaveToFile(DummyDll);
  finally
    DummyFileSL.Free;
  end;
  try
    // 1. Configure Global Mode with 4x FPS, 80% Flow Scale, PerfMode=True, HdrMode=True
    goverlayform.FActiveGameName := '';
    goverlayform.FLoadingConfig := True;
    try
      Helper.DllPathEdit.Text := DummyDll;
      Helper.MultiplierTrackBar.Position := 4;
      Helper.FlowScaleTrackBar.Position := 80;
      Helper.PerfModeCheckBox.Checked := True;
      Helper.HdrModeCheckBox.Checked := True;
      Helper.NoFp16CheckBox.Checked := True;
      Helper.PacingComboBox.ItemIndex := 1; // none
    finally
      goverlayform.FLoadingConfig := False;
    end;

    Helper.SaveLosslessConfig;

    AssertTrue('Global lsfg.toml created', FileExists(GlobalToml));
    AssertFalse('Game lsfg.toml not created by global save', FileExists(GameToml));

    // 2. Switch to Game Profile and trigger tab show
    goverlayform.FActiveGameName := 'TestGameIso';
    goverlayform.losslessScalingTabSheetShow(nil);

    // Verify game's unconfigured state on screen is default (1x Disabled, 100% flow)
    AssertEquals('Game initial Multiplier is 1x (Disabled)', 1, Helper.MultiplierTrackBar.Position);
    AssertEquals('Game initial FlowScale is 100%', 100, Helper.FlowScaleTrackBar.Position);
    AssertFalse('Game initial PerfMode is False', Helper.PerfModeCheckBox.Checked);
    AssertFalse('Game lsfg.toml was not prematurely created on tab show', FileExists(GameToml));

    // 3. Configure Game Profile with 2x FPS, 60% Flow Scale, PerfMode=False, HdrMode=False
    goverlayform.FLoadingConfig := True;
    try
      Helper.DllPathEdit.Text := DummyDll;
      Helper.MultiplierTrackBar.Position := 2;
      Helper.FlowScaleTrackBar.Position := 60;
      Helper.PerfModeCheckBox.Checked := False;
      Helper.HdrModeCheckBox.Checked := False;
      Helper.NoFp16CheckBox.Checked := True;
      Helper.PacingComboBox.ItemIndex := 0; // vsync
    finally
      goverlayform.FLoadingConfig := False;
    end;

    Helper.SaveLosslessConfig;

    AssertTrue('Game lsfg.toml created after explicit game save', FileExists(GameToml));

    // 4. Switch back to Global mode and trigger tab show
    goverlayform.FActiveGameName := '';
    goverlayform.losslessScalingTabSheetShow(nil);

    // Verify Global values were restored intact
    AssertEquals('Global restored Multiplier is 4x', 4, Helper.MultiplierTrackBar.Position);
    AssertEquals('Global restored FlowScale is 80%', 80, Helper.FlowScaleTrackBar.Position);
    AssertTrue('Global restored PerfMode is True', Helper.PerfModeCheckBox.Checked);
    AssertTrue('Global restored HdrMode is True', Helper.HdrModeCheckBox.Checked);
    AssertEquals('Global restored Pacing is none (1)', 1, Helper.PacingComboBox.ItemIndex);

    // 5. Switch back to Game Profile and verify Game values remain intact
    goverlayform.FActiveGameName := 'TestGameIso';
    goverlayform.losslessScalingTabSheetShow(nil);

    AssertEquals('Game restored Multiplier is 2x', 2, Helper.MultiplierTrackBar.Position);
    AssertEquals('Game restored FlowScale is 60%', 60, Helper.FlowScaleTrackBar.Position);
    AssertFalse('Game restored PerfMode is False', Helper.PerfModeCheckBox.Checked);
    AssertFalse('Game restored HdrMode is False', Helper.HdrModeCheckBox.Checked);
    AssertEquals('Game restored Pacing is vsync (0)', 0, Helper.PacingComboBox.ItemIndex);

  finally
    goverlayform.FActiveGameName := '';
    if FileExists(DummyDll) then DeleteFile(DummyDll);
    if FileExists(GlobalToml) then DeleteFile(GlobalToml);
    if FileExists(GameToml) then DeleteFile(GameToml);
    if DirectoryExists(GameDir) then DeleteDirectory(GameDir, False);
  end;
end;

procedure TGoverlayGuiTests.TestLosslessScalingDynamicConfigFileAndLog;
var
  Helper: TLosslessScalingTabHelper;
  ConfigFile, LogFile: string;
begin
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless helper is assigned', Assigned(Helper));

  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;

  // 1. Test lsfg-vk method
  Helper.InterpolationMethod := imLsfg;
  ConfigFile := goverlayform.GetActiveTabConfigFile;
  AssertEquals('lsfg-vk selected opens conf.toml', 'conf.toml', ExtractFileName(ConfigFile));
  LogFile := goverlayform.GetActiveTabLogFile;
  AssertEquals('lsfg-vk selected opens lsfg.log', 'lsfg.log', ExtractFileName(LogFile));

  // 2. Test MAKO method
  Helper.InterpolationMethod := imMako;
  ConfigFile := goverlayform.GetActiveTabConfigFile;
  AssertEquals('MAKO selected opens conf.toml', 'conf.toml', ExtractFileName(ConfigFile));
  LogFile := goverlayform.GetActiveTabLogFile;
  AssertEquals('MAKO selected opens mako.log', 'mako.log', ExtractFileName(LogFile));

  // 3. Test MangoHud tab
  goverlayform.goverlayPageControl.ActivePage := goverlayform.presetTabSheet;
  LogFile := goverlayform.GetActiveTabLogFile;
  AssertEquals('MangoHud preset tab opens mangohud.log', 'mangohud.log', ExtractFileName(LogFile));

  // 4. Test OptiScaler tab with OptiScaler selected
  goverlayform.goverlayPageControl.ActivePage := goverlayform.optiscalerTabSheet;
  if Assigned(goverlayform.optiscalerRadioButton) then
    goverlayform.optiscalerRadioButton.Checked := True;
  if Assigned(goverlayform.dlssenablerRadioButton) then
    goverlayform.dlssenablerRadioButton.Checked := False;
  LogFile := goverlayform.GetActiveTabLogFile;
  AssertEquals('OptiScaler selected opens optiscaler.log', 'optiscaler.log', ExtractFileName(LogFile));

  // 5. Test OptiScaler tab with DLSS Enabler selected
  if Assigned(goverlayform.optiscalerRadioButton) then
    goverlayform.optiscalerRadioButton.Checked := False;
  if Assigned(goverlayform.dlssenablerRadioButton) then
    goverlayform.dlssenablerRadioButton.Checked := True;
  LogFile := goverlayform.GetActiveTabLogFile;
  AssertEquals('DLSS Enabler selected opens dlss-enabler.log', 'dlss-enabler.log', ExtractFileName(LogFile));
end;

procedure TGoverlayGuiTests.TestLosslessScalingDynamicDllAndMigrationAssistant;
var
  Helper: TLosslessScalingTabHelper;
  DummyDir, DummyLosslessDll, DummyLsfgDll: string;
  UserConfigFile, BackupFile: string;
  ConfigSL: TStringList;
  CfgPath: string;
  OrigUserConfig: string;
  HadOrigUserConfig: Boolean;
  Dialog: TLSFGVkMigrationDialog;
begin
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless helper is assigned', Assigned(Helper));

  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;

  DummyDir := IsolatedHome + '/.local/share/goverlay/test_steam_ls';
  ForceDirectories(DummyDir);
  DummyLosslessDll := IncludeTrailingPathDelimiter(DummyDir) + 'Lossless.dll';
  DummyLsfgDll := IncludeTrailingPathDelimiter(DummyDir) + 'lsfg-vk.dll';

  // 1. Dynamic DLL swapping between lsfg-vk and MAKO
  Helper.DllPathEdit.Text := DummyLosslessDll;
  Helper.InterpolationMethod := imLsfg;
  AssertEquals('Switching to lsfg-vk updates DLL path to lsfg-vk.dll',
    DummyLsfgDll, Helper.DllPathEdit.Text);
  AssertTrue('TextHint reflects lsfg-vk.dll',
    Pos('lsfg-vk.dll', Helper.DllPathEdit.TextHint) > 0);
  AssertTrue('Browse button hint reflects lsfg-vk.dll',
    Pos('lsfg-vk.dll', Helper.BrowseDllBtn.Hint) > 0);

  Helper.InterpolationMethod := imMako;
  AssertEquals('Switching to MAKO updates DLL path to Lossless.dll',
    DummyLosslessDll, Helper.DllPathEdit.Text);
  AssertTrue('TextHint reflects Lossless.dll',
    Pos('Lossless.dll', Helper.DllPathEdit.TextHint) > 0);
  AssertTrue('Browse button hint reflects Lossless.dll',
    Pos('Lossless.dll', Helper.BrowseDllBtn.Hint) > 0);

  // 2. Status label adaptation
  Helper.InterpolationMethod := imLsfg;
  Helper.DllPathEdit.Text := '/nonexistent/dir/lsfg-vk.dll';
  Helper.UpdateDllStatus;
  AssertTrue('Missing lsfg-vk.dll status warns to switch to lsfg-vk beta branch',
    Pos('Switch Lossless Scaling to lsfg-vk beta branch', Helper.DllStatusLabel.Caption) > 0);

  Helper.InterpolationMethod := imMako;
  Helper.DllPathEdit.Text := '/nonexistent/dir/Lossless.dll';
  Helper.UpdateDllStatus;
  AssertTrue('Missing Lossless.dll status warns to install Lossless scaling',
    Pos('Install Lossless scaling on steam', Helper.DllStatusLabel.Caption) > 0);

  // 3. User configuration health check and modernization
  UserConfigFile := IncludeTrailingPathDelimiter(GetUserDir) + '.config/lsfg-vk/conf.toml';
  ForceDirectories(ExtractFilePath(UserConfigFile));
  HadOrigUserConfig := FileExists(UserConfigFile);
  OrigUserConfig := '';
  if HadOrigUserConfig then
  begin
    ConfigSL := TStringList.Create;
    try
      ConfigSL.LoadFromFile(UserConfigFile);
      OrigUserConfig := ConfigSL.Text;
    finally
      ConfigSL.Free;
    end;
  end;

  BackupFile := '';
  try
    ConfigSL := TStringList.Create;
    try
      ConfigSL.Add('# Legacy v1 configuration test');
      ConfigSL.Add('version = 1');
      ConfigSL.Add('pacing = "immediate"');
      ConfigSL.Add('multiplier = 2');
      ConfigSL.SaveToFile(UserConfigFile);

      AssertTrue('CheckUserConfigHealth flags legacy config hazard',
        Helper.CheckUserConfigHealth(CfgPath));

      AssertTrue('ModernizeUserConfig succeeds',
        Helper.ModernizeUserConfig(BackupFile));
      AssertTrue('Backup file was created', FileExists(BackupFile));

      ConfigSL.Clear;
      ConfigSL.LoadFromFile(BackupFile);
      AssertTrue('Backup contains original legacy pacing', Pos('pacing = "immediate"', ConfigSL.Text) > 0);

      ConfigSL.Clear;
      ConfigSL.LoadFromFile(UserConfigFile);
      AssertTrue('Modernized config uses version = 2', Pos('version = 2', ConfigSL.Text) > 0);
      AssertTrue('Modernized config uses pacing = "vsync"', Pos('pacing = "vsync"', ConfigSL.Text) > 0);

      AssertFalse('CheckUserConfigHealth passes on modernized config',
        Helper.CheckUserConfigHealth(CfgPath));
    finally
      ConfigSL.Free;
    end;
  finally
    if (BackupFile <> '') and FileExists(BackupFile) then
      DeleteFile(BackupFile);
    if HadOrigUserConfig then
    begin
      ConfigSL := TStringList.Create;
      try
        ConfigSL.Text := OrigUserConfig;
        ConfigSL.SaveToFile(UserConfigFile);
      finally
        ConfigSL.Free;
      end;
    end
    else if FileExists(UserConfigFile) then
      DeleteFile(UserConfigFile);
  end;

  // 4. Migration Alert Card visibility
  Helper.InterpolationMethod := imMako;
  Helper.UpdateMigrationAlertState;
  AssertFalse('Migration alert card is hidden when MAKO is active', Helper.MigrationAlertCard.Visible);

  // 5. TLSFGVkMigrationDialog instantiation, checks refresh, and lifecycle
  Dialog := TLSFGVkMigrationDialog.Create(nil, Helper);
  try
    AssertNotNull('Dialog created successfully', Dialog);
    Dialog.RefreshAllChecks;
    AssertNotNull('Step1Dot is initialized', Dialog.Step1Dot);
    AssertNotNull('Step1GuideBtn is initialized', Dialog.Step1GuideBtn);
    AssertNotNull('Step1Thumbnail is initialized', Dialog.Step1Thumbnail);
    AssertNotNull('Step2CleanBtn is initialized', Dialog.Step2CleanBtn);
    AssertNotNull('Step4UpdateBtn is initialized', Dialog.Step4UpdateBtn);
  finally
    Dialog.Free;
  end;

  // 6. Test Hamburger Menu integration in popsaveMenu (lsfgMigrationMenuItem)
  AssertNotNull('Hamburger migration menu item is allocated', goverlayform.lsfgMigrationMenuItem);
  AssertEquals('lsfgMigrationMenuItem caption is correct', 'lsfg-vk Migration Assistant', goverlayform.lsfgMigrationMenuItem.Caption);

  // When on Lossless Scaling tab and lsfg-vk is selected -> visible below Open log file
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  Helper.InterpolationMethod := imLsfg;
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertTrue('Migration menu item is visible in hamburger menu when on Lossless tab and lsfg-vk selected',
    goverlayform.lsfgMigrationMenuItem.Visible);

  // When on Lossless Scaling tab and MAKO is selected -> hidden
  Helper.InterpolationMethod := imMako;
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertFalse('Migration menu item is hidden in hamburger menu when MAKO selected',
    goverlayform.lsfgMigrationMenuItem.Visible);

  // When on Lossless Scaling tab and None is selected -> hidden
  Helper.InterpolationMethod := imNone;
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertFalse('Migration menu item is hidden in hamburger menu when None selected',
    goverlayform.lsfgMigrationMenuItem.Visible);

  // When on another tab (e.g. OptiScaler tab) even if lsfg-vk selected -> hidden
  Helper.InterpolationMethod := imLsfg;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.optiscalerTabSheet;
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertFalse('Migration menu item is hidden in hamburger menu when on another tab',
    goverlayform.lsfgMigrationMenuItem.Visible);

  // 7. Test lsfg-vk Assistant button on the main interface (Software Status card)
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  AssertNotNull('LsfgAssistantBtn is allocated', Helper.LsfgAssistantBtn);
  AssertEquals('LsfgAssistantBtn caption is correct', 'lsfg-vk Assistant', Helper.LsfgAssistantBtn.Caption);
  AssertTrue('LsfgAssistantBtn is visible in Software Status card', Helper.LsfgAssistantBtn.Visible);
  AssertTrue('LsfgAssistantBtn OnClick is assigned', Assigned(Helper.LsfgAssistantBtn.OnClick));

  Helper.ReflowLosslessScalingTab(935);
  AssertTrue('LsfgAssistantBtn has valid width and height',
    (Helper.LsfgAssistantBtn.Width >= 120) and (Helper.LsfgAssistantBtn.Height > 0));
  AssertTrue('LsfgAssistantBtn is to the right of LsfgStatusLabel',
    Helper.LsfgAssistantBtn.Left >= Helper.LsfgStatusLabel.Left + Helper.LsfgStatusLabel.Width);
end;

function TGoverlayGuiTests.ReadFileText(const APath: string): string;
var
  Lines: TStringList;
begin
  Result := '';
  if not FileExists(APath) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(APath);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TGoverlayGuiTests.NavigateReshadeTab;
begin
  AssertTrue('vkbasaltLabel.OnClick is bound', Assigned(goverlayform.vkbasaltLabel.OnClick));
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.reshadeTabSheet;
end;

procedure TGoverlayGuiTests.TestNavigateReshadeTab;
begin
  NavigateReshadeTab;
  AssertTrue('reshade tab is active after navigation',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.reshadeTabSheet);
  AssertTrue('reshade tab is visible',
    goverlayform.reshadeTabSheet.TabVisible);
  AssertFalse('vkbasalt tab is hidden',
    goverlayform.vkbasaltTabSheet.TabVisible);
  AssertTrue('vksumi tab is visible alongside reshade',
    goverlayform.vksumiTabSheet.TabVisible);
end;

procedure TGoverlayGuiTests.TestReShadeTabOrderingAndCardControls;
var
  Helper: TReshadeTabHelper;
begin
  AssertTrue('vkbasaltLabel.OnClick is bound', Assigned(goverlayform.vkbasaltLabel.OnClick));
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);

  AssertTrue('Active page defaults to reshadeTabSheet on Post processing click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.reshadeTabSheet);
  AssertTrue('reshadeTabSheet is before vkbasaltTabSheet',
    goverlayform.reshadeTabSheet.PageIndex < goverlayform.vkbasaltTabSheet.PageIndex);
  AssertTrue('vkbasaltTabSheet is before vksumiTabSheet',
    goverlayform.vkbasaltTabSheet.PageIndex < goverlayform.vksumiTabSheet.PageIndex);

  AssertTrue('FReshadeHelper is assigned', Assigned(goverlayform.FReshadeHelper));
  Helper := TReshadeTabHelper(goverlayform.FReshadeHelper);

  // Method Card and controls
  AssertTrue('MethodCard is assigned', Assigned(Helper.MethodCard));
  AssertTrue('NoneRadio is assigned', Assigned(Helper.NoneRadio));
  AssertTrue('ReshadeRadio is assigned', Assigned(Helper.ReshadeRadio));
  AssertTrue('VkBasaltRadio is assigned', Assigned(Helper.VkBasaltRadio));
  AssertTrue('NoneLogoImg is assigned', Assigned(Helper.NoneLogoImg));
  AssertTrue('ReshadeLogoImg is assigned', Assigned(Helper.ReshadeLogoImg));
  AssertTrue('VkBasaltLogoImg is assigned', Assigned(Helper.VkBasaltLogoImg));

  // Verify None method hides effect cards but shows status card
  Helper.SelectMethod(rmNone);
  AssertFalse('ConfigCard is hidden for rmNone', Helper.ConfigCard.Visible);
  AssertFalse('ShadersCard is hidden for rmNone', Helper.ShadersCard.Visible);
  AssertTrue('StatusCard is visible for rmNone', Helper.StatusCard.Visible);

  // Select ReShade method to test ReShade card controls and ordering
  Helper.SelectMethod(rmReshade);
  AssertTrue('ConfigCard is visible for rmReshade', Helper.ConfigCard.Visible);
  AssertTrue('ShadersCard is visible for rmReshade', Helper.ShadersCard.Visible);
  AssertTrue('StatusCard is visible for rmReshade', Helper.StatusCard.Visible);

  // Effect cards
  AssertTrue('StatusCard is assigned', Assigned(Helper.StatusCard));
  AssertTrue('ShadersCard is assigned', Assigned(Helper.ShadersCard));
  AssertTrue('ConfigCard is assigned', Assigned(Helper.ConfigCard));
  AssertTrue('ConfigCard is positioned to the right of MethodCard', Helper.MethodCard.Left < Helper.ConfigCard.Left);
  AssertEquals('MethodCard and ConfigCard share top row', Helper.MethodCard.Top, Helper.ConfigCard.Top);
  AssertTrue('ConfigCard is positioned above ShadersCard', Helper.ConfigCard.Top < Helper.ShadersCard.Top);
  AssertTrue('ShadersCard is positioned above StatusCard', Helper.ShadersCard.Top < Helper.StatusCard.Top);
  AssertTrue('OpenShadersBtn is assigned', Assigned(Helper.OpenShadersBtn));
  AssertTrue('OpenShadersBtn is parented to ShadersCard', Helper.OpenShadersBtn.Parent = Helper.ShadersCard);
  AssertTrue('ProxyComboBox is assigned', Assigned(Helper.ProxyComboBox));
  AssertTrue('HotkeyComboBox is assigned', Assigned(Helper.HotkeyComboBox));
  AssertTrue('ToggleBtn is assigned', Assigned(Helper.ToggleBtn));
  AssertTrue('ToggleBtn parented to ConfigCard', Helper.ToggleBtn.Parent = Helper.ConfigCard);
  AssertEquals('ToggleBtn tag is 7', 7, Helper.ToggleBtn.Tag);

  // Dual software status indicators
  AssertTrue('StatDot is assigned', Assigned(Helper.StatDot));
  AssertTrue('StatDot parented to StatusCard', Helper.StatDot.Parent = Helper.StatusCard);
  AssertTrue('StatNameLbl is assigned', Assigned(Helper.StatNameLbl));
  AssertEquals('StatNameLbl caption is ReShade', 'ReShade', Helper.StatNameLbl.Caption);
  AssertTrue('StatVerLbl is assigned', Assigned(Helper.StatVerLbl));

  AssertTrue('VkStatDot is assigned', Assigned(Helper.VkStatDot));
  AssertTrue('VkStatDot parented to StatusCard', Helper.VkStatDot.Parent = Helper.StatusCard);
  AssertTrue('VkStatNameLbl is assigned', Assigned(Helper.VkStatNameLbl));
  AssertEquals('VkStatNameLbl caption is vkBasalt', 'vkBasalt', Helper.VkStatNameLbl.Caption);
  AssertTrue('VkStatVerLbl is assigned', Assigned(Helper.VkStatVerLbl));

  AssertTrue('UpdateBtn is assigned', Assigned(Helper.UpdateBtn));
  AssertEquals('UpdateBtn caption is Check updates', 'Check updates', Helper.UpdateBtn.Caption);
  AssertEquals('UpdateBtn aligned with ReShade row', 36, Helper.UpdateBtn.Top);
  AssertTrue('UpdateBtn positioned to the right of StatVerLbl', Helper.UpdateBtn.Left >= Helper.StatVerLbl.Left + Helper.StatVerLbl.Width);
  AssertFalse('VersionComboBox is removed', Assigned(Helper.VersionComboBox));
  AssertTrue('VkStatDot is below StatDot', Helper.VkStatDot.Top > Helper.StatDot.Top);

  AssertTrue('OptionsCard is assigned', Assigned(Helper.OptionsCard));

  AssertTrue('dxgi.dll in proxy list', Pos('dxgi.dll', Helper.ProxyComboBox.Items.Text) > 0);
  AssertTrue('d3d11.dll in proxy list', Pos('d3d11.dll', Helper.ProxyComboBox.Items.Text) > 0);
  AssertTrue('d3d12.dll in proxy list', Pos('d3d12.dll', Helper.ProxyComboBox.Items.Text) > 0);
  AssertTrue('d3d9.dll in proxy list', Pos('d3d9.dll', Helper.ProxyComboBox.Items.Text) > 0);
  AssertTrue('opengl32.dll in proxy list', Pos('opengl32.dll', Helper.ProxyComboBox.Items.Text) > 0);

  // Shader packs definition and check files
  AssertEquals('5 shader packs defined', 5, RESHADE_PACK_COUNT);
  AssertEquals('Pack 0 CheckFile is DisplayDepth.fx', 'DisplayDepth.fx', RESHADE_PACKS[0].CheckFile);
  AssertEquals('Pack 1 CheckFile is SweetFX/ASCII.fx', 'SweetFX/ASCII.fx', RESHADE_PACKS[1].CheckFile);
  AssertEquals('Pack 2 CheckFile is qUINT_bloom.fx', 'qUINT_bloom.fx', RESHADE_PACKS[2].CheckFile);
  AssertEquals('Pack 3 CheckFile is Depth_Cues.fx', 'Depth_Cues.fx', RESHADE_PACKS[3].CheckFile);
  AssertEquals('Pack 4 CheckFile is PD80_01B_RT_Correct_Color.fx', 'PD80_01B_RT_Correct_Color.fx', RESHADE_PACKS[4].CheckFile);
end;

procedure TGoverlayGuiTests.TestReShadeConfigSaveAndLoad;
var
  Helper: TReshadeTabHelper;
  ReShadeIni, Content, ActualConfPath: string;
  Ini: TIniFile;
begin
  NavigateReshadeTab;
  Helper := TReshadeTabHelper(goverlayform.FReshadeHelper);

  // Configure ReShade via BeginLoad to suppress auto-save triggers
  Helper.BeginLoad;
  Helper.SelectMethod(rmReshade);
  Helper.ProxyComboBox.ItemIndex := 1; // d3d11.dll
  Helper.HotkeyComboBox.ItemIndex := 1; // Shift+F2
  Helper.EndLoad;

  // Save explicitly
  Helper.SaveConfig;

  // Read the actual bgmod.conf path that SaveConfig uses
  ActualConfPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'bgmod.conf';
  AssertTrue('bgmod.conf was created by SaveConfig', FileExists(ActualConfPath));

  Ini := TIniFile.Create(ActualConfPath);
  try
    AssertEquals('GOVERLAY_RESHADE="1" in bgmod.conf', '1', Ini.ReadString('Config', 'GOVERLAY_RESHADE', ''));
    AssertEquals('GOVERLAY_VKBASALT="0" in bgmod.conf', '0', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', ''));
    AssertEquals('RESHADE_DLL="d3d11.dll" in bgmod.conf', 'd3d11.dll', Ini.ReadString('Config', 'RESHADE_DLL', ''));
  finally
    Ini.Free;
  end;

  ReShadeIni := IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'ReShade.ini';
  AssertTrue('ReShade.ini exists in base path', FileExists(ReShadeIni));
  Content := ReadFileText(ReShadeIni);
  AssertTrue('KeyOverlay=113,0,1,0 in ReShade.ini', Pos('113,0,1,0', Content) > 0);

  // Reset controls WITHOUT triggering auto-save, then verify LoadConfig restores saved state
  Helper.BeginLoad;
  Helper.SelectMethod(rmNone);
  Helper.ProxyComboBox.ItemIndex := 0;
  Helper.HotkeyComboBox.ItemIndex := 0;
  Helper.EndLoad;

  Helper.LoadConfig;
  AssertTrue('Method reloaded as ReShade', Helper.SelectedMethod = rmReshade);
  AssertTrue('ReshadeRadio reloaded as checked', Helper.ReshadeRadio.Checked);
  AssertEquals('ProxyComboBox item index restored to 1 (d3d11.dll)', 1, Helper.ProxyComboBox.ItemIndex);
  AssertEquals('HotkeyComboBox item index restored to 1 (Shift+F2)', 1, Helper.HotkeyComboBox.ItemIndex);
  AssertTrue('ToggleBtn caption restored with Shift+F2', Pos('Shift+F2', Helper.ToggleBtn.Caption) > 0);

  // Test capturing key via ApplyCapturedKey
  Helper.ApplyCapturedKey(36, []); // Home
  AssertTrue('ToggleBtn caption updated to Home', Pos('Home', Helper.ToggleBtn.Caption) > 0);
  AssertEquals('HotkeyComboBox synced to index 0 (Home)', 0, Helper.HotkeyComboBox.ItemIndex);

  // Select vkBasalt and verify mutual exclusion
  Helper.SelectMethod(rmVkBasalt);
  Helper.SaveConfig;

  Ini := TIniFile.Create(ActualConfPath);
  try
    AssertEquals('GOVERLAY_RESHADE="0" when vkBasalt active', '0', Ini.ReadString('Config', 'GOVERLAY_RESHADE', ''));
    AssertEquals('GOVERLAY_VKBASALT="1" when vkBasalt active', '1', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', ''));
  finally
    Ini.Free;
  end;

  // Toggle to None and verify
  Helper.SelectMethod(rmNone);
  Helper.SaveConfig;

  Ini := TIniFile.Create(ActualConfPath);
  try
    AssertEquals('GOVERLAY_RESHADE="0" after None', '0', Ini.ReadString('Config', 'GOVERLAY_RESHADE', ''));
    AssertEquals('GOVERLAY_VKBASALT="0" after None', '0', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', ''));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.NavigateVkBasaltTab;
begin
  // Pre-create reshade-shaders so vkbasaltTabSheetShow skips the git clone
  ForceDirectories(IsolatedHome + '/.config/vkBasalt/reshade-shaders');
  AssertTrue('vkbasaltLabel.OnClick is bound', Assigned(goverlayform.vkbasaltLabel.OnClick));
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  if Assigned(goverlayform.FReshadeHelper) then
    TReshadeTabHelper(goverlayform.FReshadeHelper).SelectMethod(rmVkBasalt);
end;

procedure TGoverlayGuiTests.NavigateVkSumiTab;
begin
  // vkSumi has no sidebar label; it is a sibling tab next to ReShade.
  // Switching pages fires vkSumiTabSheetShow -> LoadVkSumiConfig.
  NavigateReshadeTab;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.vksumiTabSheet;
  goverlayform.UpdateToolMissingDependencyBanners;
end;

procedure TGoverlayGuiTests.TestNavigateVkBasaltTab;
begin
  NavigateVkBasaltTab;
  AssertTrue('reshade tab is active after navigation',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.reshadeTabSheet);
  AssertTrue('reshade tab is visible',
    goverlayform.reshadeTabSheet.TabVisible);
  AssertFalse('vkbasalt tab is hidden from tab bar',
    goverlayform.vkbasaltTabSheet.TabVisible);
  AssertTrue('vksumi tab becomes visible alongside reshade',
    goverlayform.vksumiTabSheet.TabVisible);
  AssertTrue('FVkToggleCard assigned',
    Assigned(goverlayform.FVkToggleCard));
  AssertTrue('FVkToggleCard is visible when vkBasalt method selected',
    goverlayform.FVkToggleCard.Visible);
  AssertTrue('FVkToggleCard is to the right of MethodCard',
    goverlayform.FVkToggleCard.Left > TReshadeTabHelper(goverlayform.FReshadeHelper).MethodCard.Left);
  AssertEquals('FVkToggleCard shares top row with MethodCard',
    TReshadeTabHelper(goverlayform.FReshadeHelper).MethodCard.Top, goverlayform.FVkToggleCard.Top);
  AssertTrue('FVkToggleCard fully contained within parent container',
    goverlayform.FVkToggleCard.Top + goverlayform.FVkToggleCard.Height <= goverlayform.FVkToggleCard.Parent.Height);
  AssertTrue('FVkToggleCaptureBtn visible within toggle card',
    Assigned(goverlayform.FVkToggleCaptureBtn) and
    (goverlayform.FVkToggleCaptureBtn.Top + goverlayform.FVkToggleCaptureBtn.Height <= goverlayform.FVkToggleCard.Height));
  AssertTrue('FVkRestoreBtn visible within toggle card',
    Assigned(goverlayform.FVkRestoreBtn) and
    (goverlayform.FVkRestoreBtn.Top + goverlayform.FVkRestoreBtn.Height <= goverlayform.FVkToggleCard.Height));
  AssertFalse('FVkReshadeSyncBtn is removed',
    Assigned(goverlayform.FVkReshadeSyncBtn));
  AssertEquals('FVkToggleTitleLbl caption is Options', 'Options', goverlayform.FVkToggleTitleLbl.Caption);
  AssertTrue('FVkToggleLabel is assigned', Assigned(goverlayform.FVkToggleLabel));
  AssertEquals('FVkToggleLabel caption is Toggle:', 'Toggle:', goverlayform.FVkToggleLabel.Caption);
  AssertEquals('FVkToggleCaptureBtn and FVkRestoreBtn are left-aligned',
    goverlayform.FVkToggleCaptureBtn.Left, goverlayform.FVkRestoreBtn.Left);
  AssertTrue('FVkRestoreBtn is below FVkToggleCaptureBtn',
    goverlayform.FVkRestoreBtn.Top > goverlayform.FVkToggleCaptureBtn.Top);
end;

procedure TGoverlayGuiTests.TestVkBasaltCasToggleSave;
var
  ConfPath, Content: string;
begin
  NavigateVkBasaltTab;
  ConfPath := IsolatedHome + '/.config/vkBasalt/vkBasalt.conf';

  // CAS off -> save -> conf must not list cas in effects
  goverlayform.casTrackBar.Position := 0;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertFalse('cas absent from effects at position 0', Pos('effects = cas', Content) > 0);

  // CAS on -> save -> conf lists cas in effects exactly once, without path mapping
  goverlayform.casTrackBar.Position := 5;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('cas present in effects at position 5', Pos('effects = cas' + LineEnding, Content) > 0);
  AssertFalse('cas not duplicated as cas:cas', Pos('cas:cas', Content) > 0);
  AssertFalse('cas not mapped as reshade shader file', Pos('cas =', Content) > 0);
  AssertEquals('acteffectsListBox not populated with cas', 0, goverlayform.acteffectsListBox.Items.Count);
end;

procedure TGoverlayGuiTests.TestNavigateVkSumiTab;
begin
  NavigateVkSumiTab;
  AssertTrue('vksumi tab is active',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.vksumiTabSheet);
  AssertTrue('vksumi trackbars were built', Assigned(goverlayform.FVsTrackbars[0]));
  AssertEquals('vksumiTabSheet background matches dark tab color',
    RGBToColor(22, 26, 40), goverlayform.vksumiTabSheet.Color);
  AssertEquals('FVsScrollBox background matches dark tab color',
    RGBToColor(22, 26, 40), goverlayform.FVsScrollBox.Color);
  AssertEquals('FVsBgPanel background matches dark tab color',
    RGBToColor(22, 26, 40), goverlayform.FVsBgPanel.Color);
end;

procedure TGoverlayGuiTests.TestVkSumiContrastSaveAndRestore;
var
  ConfPath, Content: string;
begin
  NavigateVkSumiTab;
  ConfPath := IsolatedHome + '/.config/vkSumi/vkSumi.conf';

  // Contrast (index 1) to 150 -> 0.5 -> save via global Save button
  goverlayform.FVsTrackbars[1].Position := 150;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('contrast = 0.5 persisted', Pos('contrast = 0.5', Content) > 0);
  AssertEquals('GOVERLAY_VKSUMI is 1 when contrast is customized', '1', ReadBgmodConf('Config', 'GOVERLAY_VKSUMI'));

  // Restore defaults -> contrast back to 0.0 (falsifiable both directions)
  AssertTrue('restore button bound', Assigned(goverlayform.FVsRestoreBtn));
  AssertTrue('restore button OnClick bound', Assigned(goverlayform.FVsRestoreBtn.OnClick));
  goverlayform.FVsRestoreBtn.OnClick(goverlayform.FVsRestoreBtn);
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('contrast = 0.0 after restore', Pos('contrast = 0.0', Content) > 0);
  AssertEquals('GOVERLAY_VKSUMI is 0 after restoring defaults', '0', ReadBgmodConf('Config', 'GOVERLAY_VKSUMI'));
end;

// ────────────────────────── OptiScaler tab - full coverage ──────────────────────────

procedure TGoverlayGuiTests.NavigateOptiScalerTab;
begin
  AssertTrue('optiscalerLabel.OnClick is bound', Assigned(goverlayform.optiscalerLabel.OnClick));
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
end;

function TGoverlayGuiTests.OptiIniPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/OptiScaler.ini';
end;

function TGoverlayGuiTests.FakeIniPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/fakenvapi.ini';
end;

function TGoverlayGuiTests.BgmodConfPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/bgmod.conf';
end;

procedure TGoverlayGuiTests.SeedOptiScalerFiles;
var
  F: TextFile;
begin
  // SaveOptiScalerConfigCore only updates OptiScaler.ini / fakenvapi.ini when
  // they already exist (TConfigFile.Load gate) - seed realistic fixtures.
  ForceDirectories(ExtractFilePath(OptiIniPath));

  AssignFile(F, OptiIniPath);
  Rewrite(F);
  WriteLn(F, '[Menu]');
  WriteLn(F, 'ShortcutKey=auto');
  WriteLn(F, 'Scale=auto');
  WriteLn(F);
  WriteLn(F, '[Upscalers]');
  WriteLn(F, 'Dx11Upscaler=auto');
  WriteLn(F, 'Dx12Upscaler=auto');
  WriteLn(F, 'VulkanUpscaler=auto');
  WriteLn(F);
  WriteLn(F, '[Spoofing]');
  WriteLn(F, 'Dxgi=auto');
  WriteLn(F, 'OverrideNvapiDll=auto');
  WriteLn(F);
  WriteLn(F, '[Plugins]');
  WriteLn(F, 'LoadAsiPlugins=auto');
  WriteLn(F);
  WriteLn(F, '[FSR]');
  WriteLn(F, 'Fsr4Update=auto');
  WriteLn(F, 'FsrAgilitySDKUpgrade=auto');
  WriteLn(F, 'Fsr4ForceEnableInt8=false');
  CloseFile(F);

  AssignFile(F, FakeIniPath);
  Rewrite(F);
  WriteLn(F, 'force_reflex=0');
  WriteLn(F, 'force_latencyflex=0');
  WriteLn(F, 'latencyflex_mode=0');
  WriteLn(F, 'enable_trace_logs=0');
  CloseFile(F);

  // Also seed pristine cache template in optiscaler-stable
  ForceDirectories(IsolatedHome + '/.local/share/goverlay/optiscaler-stable');
  AssignFile(F, IsolatedHome + '/.local/share/goverlay/optiscaler-stable/OptiScaler.ini');
  Rewrite(F);
  WriteLn(F, '[Menu]');
  WriteLn(F, 'ShortcutKey=auto');
  CloseFile(F);

  AssignFile(F, IsolatedHome + '/.local/share/goverlay/optiscaler-stable/fakenvapi.ini');
  Rewrite(F);
  WriteLn(F, 'force_reflex=0');
  WriteLn(F, 'force_latencyflex=0');
  WriteLn(F, 'latencyflex_mode=0');
  WriteLn(F, 'enable_trace_logs=0');
  CloseFile(F);
end;

function TGoverlayGuiTests.ReadBgmodConf(const ASection, AKey: string): string;
var
  Ini: TIniFile;
begin
  Result := '';
  if not FileExists(BgmodConfPath) then Exit;
  Ini := TIniFile.Create(BgmodConfPath);
  try
    Result := Ini.ReadString(ASection, AKey, '');
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.SaveOpti;
begin
  // No navigation here: switching to the tab reloads config from disk and
  // would clobber the control state just set by the test. Tests navigate
  // once up front, then set controls, then save.
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
end;

procedure TGoverlayGuiTests.TestOptiMenuScaleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  AssertTrue('menuscaleComboBox assigned', Assigned(goverlayform.menuscaleComboBox));
  AssertEquals('menuscaleComboBox item 0 is auto', 'auto', goverlayform.menuscaleComboBox.Items[0]);
  AssertEquals('menuscaleComboBox item 1 is 1.0', '1.0', goverlayform.menuscaleComboBox.Items[1]);
  AssertEquals('menuscaleComboBox default is auto (index 0)', 0, goverlayform.menuscaleComboBox.ItemIndex);

  // Set to 1.5 (index 6)
  goverlayform.menuscaleComboBox.ItemIndex := 6;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Scale=1.5 persisted', Pos('Scale=1.5', Content) > 0);

  // Set to 1.0 (index 1)
  goverlayform.menuscaleComboBox.ItemIndex := 1;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Scale=1.0 persisted', Pos('Scale=1.0', Content) > 0);

  // Set back to auto (index 0)
  goverlayform.menuscaleComboBox.ItemIndex := 0;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Scale=auto persisted', Pos('Scale=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiShortcutKeySave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.shortcutkeyComboBox.Text := '0x2d';
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('ShortcutKey=0x2d persisted', Pos('ShortcutKey=0x2d', Content) > 0);

  goverlayform.shortcutkeyComboBox.Text := 'auto';
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('ShortcutKey=auto persisted', Pos('ShortcutKey=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiSpoofToggleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True; // spoof only enabled on mesa
  goverlayform.spoofCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=false persisted', Pos('Dxgi=false', Content) > 0);

  goverlayform.spoofCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=auto persisted', Pos('Dxgi=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiOverrideNvapiSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.overrideCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('OverrideNvapiDll=true persisted', Pos('OverrideNvapiDll=true', Content) > 0);

  goverlayform.overrideCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('OverrideNvapiDll=auto persisted', Pos('OverrideNvapiDll=auto', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiPatcherToggleSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  AssertTrue('optipatcher defaults to checked', goverlayform.optipatcherCheckBox.Checked);

  goverlayform.optipatcherCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=true persisted', Pos('LoadAsiPlugins=true', Content) > 0);

  goverlayform.optipatcherCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=false persisted', Pos('LoadAsiPlugins=false', Content) > 0);

  NavigateOptiScalerTab;
  AssertFalse('optipatcher explicit deactivation remembered', goverlayform.optipatcherCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestOptiLogLevelSelector;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;

  // 1. Controls existence, visibility, items, and hint
  AssertTrue('loglevelComboBox assigned', Assigned(goverlayform.loglevelComboBox));
  AssertTrue('loglevelLabel assigned', Assigned(goverlayform.loglevelLabel));
  AssertFalse('loglevelComboBox hidden', goverlayform.loglevelComboBox.Visible);
  AssertFalse('loglevelLabel hidden', goverlayform.loglevelLabel.Visible);
  AssertEquals('loglevelComboBox item count is 5', 5, goverlayform.loglevelComboBox.Items.Count);
  AssertEquals('item 0 is 0 - Trace', '0 - Trace', goverlayform.loglevelComboBox.Items[0]);
  AssertEquals('item 1 is 1 - Debug', '1 - Debug', goverlayform.loglevelComboBox.Items[1]);
  AssertEquals('item 2 is 2 - Info (Default)', '2 - Info (Default)', goverlayform.loglevelComboBox.Items[2]);
  AssertEquals('item 3 is 3 - Warning', '3 - Warning', goverlayform.loglevelComboBox.Items[3]);
  AssertEquals('item 4 is 4 - Error', '4 - Error', goverlayform.loglevelComboBox.Items[4]);
  AssertEquals('default item index is 2 (Info)', 2, goverlayform.loglevelComboBox.ItemIndex);
  AssertTrue('tooltip warning present', Pos('Trace', goverlayform.loglevelComboBox.Hint) > 0);

  // 2. Select 1 - Debug (index 1) and test auto-save
  goverlayform.loglevelComboBox.ItemIndex := 1;
  goverlayform.loglevelComboBoxChange(goverlayform.loglevelComboBox);
  AssertTrue('autoSaveTimer enabled after loglevelComboBox change', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;

  Content := ReadFileText(OptiIniPath);
  AssertTrue('LogLevel=1 persisted in OptiScaler.ini', Pos('LogLevel=1', Content) > 0);

  // Reload tab and verify index 1 restored
  NavigateOptiScalerTab;
  AssertEquals('reloaded item index is 1 (Debug)', 1, goverlayform.loglevelComboBox.ItemIndex);

  // 3. Select 4 - Error (index 4) and test auto-save
  goverlayform.loglevelComboBox.ItemIndex := 4;
  goverlayform.loglevelComboBoxChange(goverlayform.loglevelComboBox);
  AssertTrue('autoSaveTimer enabled after selecting 4 - Error', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;

  Content := ReadFileText(OptiIniPath);
  AssertTrue('LogLevel=4 persisted in OptiScaler.ini', Pos('LogLevel=4', Content) > 0);

  // Reload tab and verify index 4 restored
  NavigateOptiScalerTab;
  AssertEquals('reloaded item index is 4 (Error)', 4, goverlayform.loglevelComboBox.ItemIndex);

  // 4. Select 2 - Info (index 2) and Save
  goverlayform.loglevelComboBox.ItemIndex := 2;
  goverlayform.loglevelComboBoxChange(goverlayform.loglevelComboBox);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;

  Content := ReadFileText(OptiIniPath);
  AssertTrue('LogLevel=2 persisted in OptiScaler.ini', Pos('LogLevel=2', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiFsrVersionSelector;
var
  VarsPath, Content, IniContent: string;
  SL: TStringList;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;

  // 1. Controls existence, visibility, and items
  AssertTrue('fsrversionComboBox assigned', Assigned(goverlayform.fsrversionComboBox));
  AssertTrue('fsrversionLabel assigned', Assigned(goverlayform.fsrversionLabel));
  AssertTrue('fsrversionComboBox visible', goverlayform.fsrversionComboBox.Visible);
  AssertTrue('fsrversionLabel visible', goverlayform.fsrversionLabel.Visible);
  AssertEquals('fsrversionComboBox item count is 3', 3, goverlayform.fsrversionComboBox.Items.Count);
  AssertEquals('item 0 is Latest', 'Latest', goverlayform.fsrversionComboBox.Items[0]);
  AssertEquals('item 1 is 4.1.1b', '4.1.1b', goverlayform.fsrversionComboBox.Items[1]);
  AssertEquals('item 2 is 4.0.2c', '4.0.2c', goverlayform.fsrversionComboBox.Items[2]);
  AssertEquals('default item index is 0 (Latest)', 0, goverlayform.fsrversionComboBox.ItemIndex);

  // 2. Select 4.1.1b (index 1) and test auto-save
  goverlayform.fsrversionComboBox.ItemIndex := 1;
  goverlayform.fsrversionComboBoxChange(goverlayform.fsrversionComboBox);
  AssertTrue('autoSaveTimer enabled after fsrversionComboBox change', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;

  // Trigger channel change handler to verify combobox stays at index 1 and visible
  if Assigned(goverlayform.optversionComboBox.OnChange) then
    goverlayform.optversionComboBox.OnChange(goverlayform.optversionComboBox);
  AssertEquals('item index remains 1 after channel switch', 1, goverlayform.fsrversionComboBox.ItemIndex);
  AssertTrue('fsrversionComboBox remains visible after channel switch', goverlayform.fsrversionComboBox.Visible);

  VarsPath := IsolatedHome + '/.local/share/goverlay/gameconfig/global/goverlay.vars';
  if FileExists(VarsPath) then
  begin
    Content := ReadFileText(VarsPath);
    AssertTrue('fsrversion=4.1.1b persisted in goverlay.vars', Pos('fsrversion=4.1.1b', Content) > 0);
  end;

  // Reload tab and verify index 1 restored
  NavigateOptiScalerTab;
  AssertEquals('reloaded item index is 1 (4.1.1b)', 1, goverlayform.fsrversionComboBox.ItemIndex);

  // 3. Select 4.0.2c (index 2) and test auto-save
  goverlayform.fsrversionComboBox.ItemIndex := 2;
  goverlayform.fsrversionComboBoxChange(goverlayform.fsrversionComboBox);
  AssertTrue('autoSaveTimer enabled after selecting 4.0.2c', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;
  if FileExists(VarsPath) then
  begin
    Content := ReadFileText(VarsPath);
    AssertTrue('fsrversion=4.0.2c persisted in goverlay.vars', Pos('fsrversion=4.0.2c', Content) > 0);
  end;

  // Reload tab and verify index 2 restored
  NavigateOptiScalerTab;
  AssertEquals('reloaded item index is 2 (4.0.2c)', 2, goverlayform.fsrversionComboBox.ItemIndex);

  // 4. Select Latest (index 0) and Save
  goverlayform.fsrversionComboBox.ItemIndex := 0;
  SaveOpti;
  if FileExists(VarsPath) then
  begin
    Content := ReadFileText(VarsPath);
    AssertTrue('fsrversion=Latest persisted in goverlay.vars', Pos('fsrversion=Latest', Content) > 0);
  end;
  IniContent := ReadFileText(OptiIniPath);
  AssertTrue('FsrAgilitySDKUpgrade=true persisted for Latest', Pos('FsrAgilitySDKUpgrade=true', IniContent) > 0);

  // Reload tab and verify index 0 restored
  NavigateOptiScalerTab;
  AssertEquals('reloaded item index is 0 (Latest)', 0, goverlayform.fsrversionComboBox.ItemIndex);

  // 5. Test backwards compatibility with legacy "4.0.2c INT8"
  if FileExists(VarsPath) then
  begin
    SL := TStringList.Create;
    try
      SL.Add('fsrversion=4.0.2c INT8');
      SL.SaveToFile(VarsPath);
    finally
      SL.Free;
    end;
    NavigateOptiScalerTab;
    AssertEquals('legacy 4.0.2c INT8 maps to index 2', 2, goverlayform.fsrversionComboBox.ItemIndex);
  end;
end;

procedure TGoverlayGuiTests.TestOptiPreferredUpscalerSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.preferredUpscalerComboBox.ItemIndex := 1; // xess
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dx11Upscaler=xess persisted', Pos('Dx11Upscaler=xess', Content) > 0);
  AssertTrue('Dx12Upscaler=xess persisted', Pos('Dx12Upscaler=xess', Content) > 0);
  AssertTrue('VulkanUpscaler=xess persisted', Pos('VulkanUpscaler=xess', Content) > 0);

  goverlayform.preferredUpscalerComboBox.ItemIndex := 5; // dlss
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dx11Upscaler=dlss persisted', Pos('Dx11Upscaler=dlss', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiForceFsr4Int8Save;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.forceFsr4Int8CheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4ForceEnableInt8=true persisted', Pos('Fsr4ForceEnableInt8=true', Content) > 0);

  goverlayform.forceFsr4Int8CheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4ForceEnableInt8=false persisted', Pos('Fsr4ForceEnableInt8=false', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiFilenameDllSave;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.filenameComboBox.ItemIndex := 1; // version.dll
  SaveOpti;
  AssertEquals('DLL=version.dll persisted', 'version.dll', ReadBgmodConf('Config', 'DLL'));

  goverlayform.filenameComboBox.ItemIndex := 0; // dxgi.dll
  SaveOpti;
  AssertEquals('DLL=dxgi.dll persisted', 'dxgi.dll', ReadBgmodConf('Config', 'DLL'));
end;

procedure TGoverlayGuiTests.TestOptiChannelSave;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.optversionComboBox.ItemIndex := 1; // bleeding edge
  SaveOpti;
  AssertEquals('OPT_CHANNEL=1 persisted', '1', ReadBgmodConf('Config', 'OPT_CHANNEL'));

  goverlayform.optversionComboBox.ItemIndex := 0; // stable
  SaveOpti;
  AssertEquals('OPT_CHANNEL=0 persisted', '0', ReadBgmodConf('Config', 'OPT_CHANNEL'));
end;

procedure TGoverlayGuiTests.TestUpscalerChannelPersistence;
var
  StableVarsPath, EdgeVarsPath, GameCfgDir, GameConfPath, MarkerPath: string;
  StableVars, EdgeVars: TStringList;
  TestCard: TPanel;
  TestCardImg: TImage;
  Ini: TIniFile;
begin
  // 1. Seed stable and bleeding-edge goverlay.vars for DLSS Enabler
  StableVarsPath := IsolatedHome + '/.local/share/goverlay/dlssenabler-stable/goverlay.vars';
  EdgeVarsPath   := IsolatedHome + '/.local/share/goverlay/dlssenabler-edge/goverlay.vars';
  ForceDirectories(ExtractFilePath(StableVarsPath));
  ForceDirectories(ExtractFilePath(EdgeVarsPath));

  StableVars := TStringList.Create;
  try
    StableVars.Add('dlssenablerversion=4.9.0');
    StableVars.Add('optiScalerVersion=v0.9.4');
    StableVars.Add('dlssenablertag=4.9.0');
    StableVars.Add('upscalertype=1');
    StableVars.SaveToFile(StableVarsPath);
  finally
    StableVars.Free;
  end;

  EdgeVars := TStringList.Create;
  try
    EdgeVars.Add('dlssenablerversion=4.9.0.7');
    EdgeVars.Add('optiScalerVersion=v0.10.0-edge');
    EdgeVars.Add('dlssenablertag=4.9.0.7');
    EdgeVars.Add('upscalertype=1');
    EdgeVars.SaveToFile(EdgeVarsPath);
  finally
    EdgeVars.Free;
  end;

  // Seed a marker file in dlssenabler-edge to verify asset deployment
  MarkerPath := IsolatedHome + '/.local/share/goverlay/dlssenabler-edge/edge_marker.txt';
  FileClose(FileCreate(MarkerPath));

  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.dlssenablerRadioButton.Checked := True;
  goverlayform.dlssenablerRadioButtonClick(goverlayform.dlssenablerRadioButton);

  // 2. In Global mode, select Stable (index 0) and verify version display
  goverlayform.optversionComboBox.ItemIndex := 0;
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
  AssertEquals('Stable DLSS Enabler version displayed', '4.9.0', goverlayform.FOsStatVerLbls[2].Caption);

  // Switch to Bleeding-edge (index 1) and verify immediate version label update and auto-save trigger
  AssertTrue('autoSaveTimer was triggered by optversionComboBoxChange', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;
  AssertEquals('Global OPT_CHANNEL persisted as 0', '0', ReadBgmodConf('Config', 'OPT_CHANNEL'));

  goverlayform.optversionComboBox.ItemIndex := 1;
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
  AssertEquals('Bleeding-edge DLSS Enabler version displayed immediately', '4.9.0.7', goverlayform.FOsStatVerLbls[2].Caption);
  AssertTrue('autoSaveTimer enabled after changing to bleeding-edge', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;
  AssertEquals('Global OPT_CHANNEL persisted as 1', '1', ReadBgmodConf('Config', 'OPT_CHANNEL'));

  // Reset global back to Stable (0)
  goverlayform.optversionComboBox.ItemIndex := 0;
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
  goverlayform.autoSaveTimer.Enabled := False;
  goverlayform.TriggerAutoSave;
  AssertEquals('Global OPT_CHANNEL reset to 0', '0', ReadBgmodConf('Config', 'OPT_CHANNEL'));

  // 3. Test Per-Game Channel Persistence:
  GameCfgDir := goverlayform.GetGameConfigDir('ChannelTestGame');
  if DirectoryExists(GameCfgDir) then
    DeleteDirectory(GameCfgDir, False);
  ForceDirectories(GameCfgDir);

  // Write pre-existing bgmod.conf with OPT_CHANNEL=1 for ChannelTestGame
  GameConfPath := GameCfgDir + 'bgmod.conf';
  Ini := TIniFile.Create(GameConfPath);
  try
    Ini.WriteInteger('Config', 'UPSCALER_TYPE', 1); // DLSS Enabler
    Ini.WriteInteger('Config', 'OPT_CHANNEL', 1);   // Bleeding-edge
  finally
    Ini.Free;
  end;

  goverlayform.FGamesLoaded := True;
  if not Assigned(goverlayform.FCardPanels) then
    goverlayform.FCardPanels := TList.Create;

  TestCard := TPanel.Create(goverlayform.FGamesScrollBox);
  TestCard.Hint := '(888888) ChannelTestGame' + LineEnding + '/path/to/channelgame';
  TestCard.Tag := 0;
  TestCardImg := TImage.Create(TestCard);
  TestCardImg.Tag := 9995;
  TestCardImg.Parent := TestCard;
  TestCardImg.Hint := TestCard.Hint;
  goverlayform.FCardPanels.Add(TestCard);

  try
    // Click game card -> loads game profile
    goverlayform.GameCardClick(TestCard);
    AssertEquals('Active game is ChannelTestGame', 'ChannelTestGame', goverlayform.FActiveGameName);

    // Verify InitializeTab restored Bleeding-edge channel (index 1) for this game
    AssertEquals('Game profile restored optversionComboBox to 1 (Bleeding-edge)', 1, goverlayform.optversionComboBox.ItemIndex);
    AssertEquals('In-card DLSS Enabler version displays 4.9.0.7 for game', '4.9.0.7', goverlayform.FOsStatVerLbls[2].Caption);

    // Test asset deployment: CopyOptiScalerGameFiles with OPT_CHANNEL=1 must deploy from dlssenabler-edge
    goverlayform.CopyOptiScalerGameFiles(GameCfgDir);
    AssertTrue('Edge marker deployed to game directory from dlssenabler-edge', FileExists(GameCfgDir + 'edge_marker.txt'));

    // Return to Games tab (Global context)
    goverlayform.gamesLabelClick(nil);
    AssertEquals('Active game cleared after returning to games', '', goverlayform.FActiveGameName);
    AssertEquals('Global restored optversionComboBox to 0 (Stable)', 0, goverlayform.optversionComboBox.ItemIndex);
    AssertEquals('Global DLSS Enabler version displays 4.9.0', '4.9.0', goverlayform.FOsStatVerLbls[2].Caption);

    // Re-enter game card: must restore Bleeding-edge again
    goverlayform.GameCardClick(TestCard);
    AssertEquals('Re-entering game restores optversionComboBox to 1', 1, goverlayform.optversionComboBox.ItemIndex);
    AssertEquals('Re-entering game displays 4.9.0.7', '4.9.0.7', goverlayform.FOsStatVerLbls[2].Caption);

    // Navigate to OptiScaler tab for the game profile
    goverlayform.optiscalerLabelClick(nil);

    // In game context, switch to Stable (0) and verify auto-save updates game's bgmod.conf
    goverlayform.optversionComboBox.ItemIndex := 0;
    goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
    AssertTrue('autoSaveTimer enabled when changing game channel', goverlayform.autoSaveTimer.Enabled);
    goverlayform.autoSaveTimer.Enabled := False;
    goverlayform.TriggerAutoSave;

    Ini := TIniFile.Create(GameConfPath);
    try
      AssertEquals('Game bgmod.conf updated with OPT_CHANNEL=0', '0', Ini.ReadString('Config', 'OPT_CHANNEL', ''));
    finally
      Ini.Free;
    end;
    AssertEquals('Game DLSS Enabler version displays 4.9.0 after switch', '4.9.0', goverlayform.FOsStatVerLbls[2].Caption);

  finally
    goverlayform.gamesLabelClick(nil);
    goverlayform.FCardPanels.Remove(TestCard);
    TestCard.Free;
    if DirectoryExists(GameCfgDir) then
      DeleteDirectory(GameCfgDir, False);
    if FileExists(MarkerPath) then
      DeleteFile(MarkerPath);
    if FileExists(StableVarsPath) then
      DeleteFile(StableVarsPath);
    if FileExists(EdgeVarsPath) then
      DeleteFile(EdgeVarsPath);

    // Reset global upscaler state back to default OptiScaler stable
    NavigateOptiScalerTab;
    goverlayform.optiscalerRadioButton.Checked := True;
    goverlayform.optiscalerRadioButtonClick(goverlayform.optiscalerRadioButton);
    goverlayform.optversionComboBox.ItemIndex := 0;
    goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
    goverlayform.autoSaveTimer.Enabled := False;
    goverlayform.TriggerAutoSave;
  end;
end;

procedure TGoverlayGuiTests.TestCustomOptiScalerBuildSupport;
var
  CustomDir, StableDir, GameCfgDir, GameConfPath: string;
  ErrMsg: string;
  Ini: TIniFile;
  F: TextFile;
  IniContent: string;
  CustomTabHelper: TOptiScalerTabHelper;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  CustomTabHelper := TOptiScalerTabHelper(goverlayform.FOptiScalerHelper);

  // 1. Channel selection UI & Toggle visibility
  goverlayform.optversionComboBox.ItemIndex := 2; // Custom Build
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);

  AssertTrue('UnmanagedIniToggle should be visible for Custom Build', Assigned(CustomTabHelper.UnmanagedIniToggle) and CustomTabHelper.UnmanagedIniToggle.Visible);
  AssertTrue('OsCustomInfoLbl should be visible for Custom Build', Assigned(CustomTabHelper.OsCustomInfoLbl) and CustomTabHelper.OsCustomInfoLbl.Visible);
  AssertEquals('checkupdBitBtn caption should be Select Folder...', 'Select Folder...', goverlayform.checkupdBitBtn.Caption);

  // 2. Unmanaged mode serialization & OptiScaler.ini preservation
  goverlayform.unmanagedIniCheckBox.Checked := True;
  CustomTabHelper.UnmanagedIniToggleChange(nil);
  SaveOpti;

  AssertEquals('OPT_CHANNEL=2 persisted', '2', ReadBgmodConf('Config', 'OPT_CHANNEL'));
  AssertEquals('OPT_UNMANAGED_INI=1 persisted', '1', ReadBgmodConf('Config', 'OPT_UNMANAGED_INI'));

  // Append a custom section to OptiScaler.ini
  AssignFile(F, OptiIniPath);
  Append(F);
  WriteLn(F, '[CustomForkSection]');
  WriteLn(F, 'ExperimentalNeuralMode=true');
  CloseFile(F);

  // Save again in unmanaged mode: OptiScaler.ini must NOT overwrite custom settings
  SaveOpti;
  IniContent := ReadFileText(OptiIniPath);
  AssertTrue('Custom section in OptiScaler.ini preserved in unmanaged mode', Pos('ExperimentalNeuralMode=true', IniContent) > 0);

  // Disable unmanaged mode and verify serialization
  goverlayform.unmanagedIniCheckBox.Checked := False;
  CustomTabHelper.UnmanagedIniToggleChange(nil);
  SaveOpti;
  AssertEquals('OPT_UNMANAGED_INI=0 persisted', '0', ReadBgmodConf('Config', 'OPT_UNMANAGED_INI'));

  // 3. Switch back to Stable (0) and verify UI elements hide
  goverlayform.optversionComboBox.ItemIndex := 0;
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
  AssertFalse('UnmanagedIniToggle hidden for Stable channel', CustomTabHelper.UnmanagedIniToggle.Visible);
  AssertFalse('OsCustomInfoLbl hidden for Stable channel', CustomTabHelper.OsCustomInfoLbl.Visible);
  AssertEquals('checkupdBitBtn caption reverted to Check updates', 'Check updates', goverlayform.checkupdBitBtn.Caption);

  // 4. Test ImportCustomOptiScalerBuild validation & fallback inheritance
  CustomDir := IsolatedHome + '/dummy_custom_build';
  StableDir := IsolatedHome + '/.local/share/goverlay/optiscaler-stable';
  ForceDirectories(CustomDir);
  ForceDirectories(StableDir);

  // Missing OptiScaler.dll should fail validation
  AssertFalse('Import without OptiScaler.dll must fail', ImportCustomOptiScalerBuild(CustomDir, ErrMsg));
  AssertTrue('ErrMsg should mention OptiScaler.dll', Pos('OptiScaler.dll', ErrMsg) > 0);

  // Seed companion files in stable cache
  AssignFile(F, StableDir + '/amd_fidelityfx_dx12.dll'); Rewrite(F); WriteLn(F, 'stable_fsr'); CloseFile(F);
  AssignFile(F, StableDir + '/goverlay.vars'); Rewrite(F); WriteLn(F, 'fsrversion=Latest'); CloseFile(F);

  // Add OptiScaler.dll to custom dir and import
  AssignFile(F, CustomDir + '/OptiScaler.dll'); Rewrite(F); WriteLn(F, 'dummy_custom_optiscaler'); CloseFile(F);
  AssertTrue('Import with OptiScaler.dll must succeed', ImportCustomOptiScalerBuild(CustomDir, ErrMsg));

  // Verify files in optiscaler-custom/
  AssertTrue('Custom OptiScaler.dll copied', FileExists(IsolatedHome + '/.local/share/goverlay/optiscaler-custom/OptiScaler.dll'));
  AssertTrue('Companion amd_fidelityfx_dx12.dll inherited from stable', FileExists(IsolatedHome + '/.local/share/goverlay/optiscaler-custom/amd_fidelityfx_dx12.dll'));
  AssertTrue('goverlay.vars created in optiscaler-custom', FileExists(IsolatedHome + '/.local/share/goverlay/optiscaler-custom/goverlay.vars'));

  // 5. Test CopyOptiScalerGameFiles with OPT_CHANNEL=2
  GameCfgDir := goverlayform.GetGameConfigDir('CustomDeployGame');
  ForceDirectories(GameCfgDir);
  GameConfPath := GameCfgDir + 'bgmod.conf';
  Ini := TIniFile.Create(GameConfPath);
  try
    Ini.WriteInteger('Config', 'UPSCALER_TYPE', 0);
    Ini.WriteInteger('Config', 'OPT_CHANNEL', 2);
  finally
    Ini.Free;
  end;

  AssignFile(F, IsolatedHome + '/.local/share/goverlay/optiscaler-custom/custom_deploy_marker.txt');
  Rewrite(F);
  WriteLn(F, 'marker');
  CloseFile(F);

  goverlayform.CopyOptiScalerGameFiles(GameCfgDir);
  AssertTrue('Custom asset deployed from optiscaler-custom to game config dir', FileExists(GameCfgDir + 'custom_deploy_marker.txt'));

  // Cleanup
  DeleteDirectory(CustomDir, False);
  DeleteDirectory(GameCfgDir, False);
  DeleteDirectory(IsolatedHome + '/.local/share/goverlay/optiscaler-custom', False);
  DeleteDirectory(StableDir, False);

  // Reset to default
  goverlayform.optversionComboBox.ItemIndex := 0;
  goverlayform.optversionComboBoxChange(goverlayform.optversionComboBox);
  SaveOpti;
end;

procedure TGoverlayGuiTests.TestOptiEmuFp8Save;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.emufp8CheckBox.Checked := True;
  SaveOpti;
  AssertEquals('DXIL_SPIRV_CONFIG workaround persisted',
    'wmma_rdna3_workaround', ReadBgmodConf('Env', 'DXIL_SPIRV_CONFIG'));

  goverlayform.emufp8CheckBox.Checked := False;
  SaveOpti;
  AssertEquals('DXIL_SPIRV_CONFIG removed when unchecked',
    '', ReadBgmodConf('Env', 'DXIL_SPIRV_CONFIG'));
end;

procedure TGoverlayGuiTests.TestOptiForceReflexSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True; // reflex options only enabled on mesa
  goverlayform.forcereflexCheckBox.Checked := True;
  goverlayform.reflexComboBox.ItemIndex := 2;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex=2 persisted', Pos('force_reflex=2', Content) > 0);

  goverlayform.LoadOptiScalerConfig;
  AssertTrue('forcereflexCheckBox reloaded', goverlayform.forcereflexCheckBox.Checked);
  AssertEquals('reflexComboBox reloaded', 2, goverlayform.reflexComboBox.ItemIndex);

  goverlayform.forcereflexCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex key removed when unchecked', Pos('force_reflex', Content) = 0);
end;

procedure TGoverlayGuiTests.TestOptiForceReflexSaveSeedingWhenMissing;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  if FileExists(FakeIniPath) then
    DeleteFile(FakeIniPath);
  AssertFalse('fakenvapi.ini removed before save', FileExists(FakeIniPath));

  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True;
  goverlayform.forcereflexCheckBox.Checked := True;
  goverlayform.reflexComboBox.ItemIndex := 2;
  SaveOpti;

  AssertTrue('fakenvapi.ini seeded on save', FileExists(FakeIniPath));
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex=2 persisted in seeded ini', Pos('force_reflex=2', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiForceReflexAutoSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True;
  goverlayform.forcereflexCheckBox.Checked := True;
  goverlayform.reflexComboBox.ItemIndex := 2;
  goverlayform.TriggerAutoSave;

  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex=2 persisted via autosave', Pos('force_reflex=2', Content) > 0);

  goverlayform.forcereflexCheckBox.Checked := False;
  goverlayform.TriggerAutoSave;

  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_reflex removed via autosave when unchecked', Pos('force_reflex', Content) = 0);
end;

procedure TGoverlayGuiTests.TestOptiMethodRadioAutoSave;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;

  // Select None upscaler method
  goverlayform.noneUpscalerRadioButton.Checked := True;
  goverlayform.noneUpscalerRadioButtonClick(goverlayform.noneUpscalerRadioButton);
  AssertTrue('autoSaveTimer enabled after noneUpscaler click', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;

  // Select DLSS Enabler method
  goverlayform.dlssenablerRadioButton.Checked := True;
  goverlayform.dlssenablerRadioButtonClick(goverlayform.dlssenablerRadioButton);
  AssertTrue('autoSaveTimer enabled after dlssenabler click', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;

  // Select OptiScaler method
  goverlayform.optiscalerRadioButton.Checked := True;
  goverlayform.optiscalerRadioButtonClick(goverlayform.optiscalerRadioButton);
  AssertTrue('autoSaveTimer enabled after optiscaler click', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
end;

procedure TGoverlayGuiTests.TestMangoFilterRadioGroupAutoSave;
begin
  goverlayform.WireAutoSaveEvents;
  goverlayform.autoSaveTimer.Enabled := False;

  // Change filter radio group
  goverlayform.filterRadioGroup.ItemIndex := 1;
  goverlayform.filterRadioGroupClick(goverlayform.filterRadioGroup);
  AssertTrue('autoSaveTimer enabled after filterRadioGroup click', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;

  // Change af trackbar
  goverlayform.afTrackBar.Position := 8;
  goverlayform.afTrackBarChange(goverlayform.afTrackBar);
  AssertTrue('autoSaveTimer enabled after afTrackBar change', goverlayform.autoSaveTimer.Enabled);
  goverlayform.autoSaveTimer.Enabled := False;
end;

procedure TGoverlayGuiTests.TestCustomEditAutoSave;
begin
  goverlayform.WireAutoSaveEvents;
  AssertTrue('hudtitleEdit OnChange wired to autosave', Assigned(goverlayform.hudtitleEdit.OnChange));
  AssertTrue('cpunameEdit OnChange wired to autosave', Assigned(goverlayform.cpunameEdit.OnChange));
  AssertTrue('customenvEdit OnChange wired to autosave', Assigned(goverlayform.customenvEdit.OnChange));
end;

procedure TGoverlayGuiTests.TestToggleSwitchAutoSave;
var
  Helper: TOptiScalerTabHelper;
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.mesaRadioButton.Checked := True;
  goverlayform.WireAutoSaveEvents;

  Helper := TOptiScalerTabHelper(goverlayform.FOptiScalerHelper);
  AssertTrue('OptiScalerHelper assigned', Assigned(Helper));
  AssertTrue('SpoofToggle assigned', Assigned(Helper.SpoofToggle));
  AssertTrue('SpoofToggle OnChange wired to autosave', Assigned(Helper.SpoofToggle.OnChange));

  // Toggle switch to True and verify auto-save wrote to disk
  Helper.SpoofToggle.Checked := True;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=auto persisted via toggle autosave', Pos('Dxgi=auto', Content) > 0);

  // Toggle switch to False and verify auto-save wrote to disk
  Helper.SpoofToggle.Checked := False;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Dxgi=false persisted via toggle autosave', Pos('Dxgi=false', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiScalerTogglesLoadFromDisk;
var
  Helper: TOptiScalerTabHelper;
  OptiLines, FakeLines, BgLines: TStringList;
begin
  SeedOptiScalerFiles;
  goverlayform.mesaRadioButton.Checked := True;

  // Write all toggles as enabled into config files on disk
  OptiLines := TStringList.Create;
  try
    OptiLines.Add('[Upscalers]');
    OptiLines.Add('Dx12=auto');
    OptiLines.Add('[FSR]');
    OptiLines.Add('Fsr4ForceEnableInt8=true');
    OptiLines.Add('[Plugins]');
    OptiLines.Add('LoadAsiPlugins=true');
    OptiLines.Add('[Spoofing]');
    OptiLines.Add('Dxgi=auto');
    OptiLines.SaveToFile(OptiIniPath);
  finally
    OptiLines.Free;
  end;

  FakeLines := TStringList.Create;
  try
    FakeLines.Add('[fakenvapi]');
    FakeLines.Add('force_reflex=0');
    FakeLines.Add('force_latencyflex=1');
    FakeLines.Add('latencyflex_mode=1');
    FakeLines.SaveToFile(FakeIniPath);
  finally
    FakeLines.Free;
  end;

  BgLines := TStringList.Create;
  try
    BgLines.Add('[Config]');
    BgLines.Add('GOVERLAY_OPTISCALER=1');
    BgLines.Add('DLL=dxgi.dll');
    BgLines.Add('[Env]');
    BgLines.Add('DXIL_SPIRV_CONFIG=wmma_rdna3_workaround');
    BgLines.SaveToFile(BgmodConfPath);
  finally
    BgLines.Free;
  end;

  // Trigger loading of OptiScaler tab and config
  NavigateOptiScalerTab;
  goverlayform.optiscalerTabSheetShow(nil);

  Helper := TOptiScalerTabHelper(goverlayform.FOptiScalerHelper);
  AssertTrue('OptiScalerHelper assigned', Assigned(Helper));

  AssertTrue('optipatcherCheckBox is Checked', goverlayform.optipatcherCheckBox.Checked);
  AssertTrue('FOptiPatcherToggle is Checked', Helper.OptiPatcherToggle.Checked);

  AssertTrue('spoofCheckBox is Checked', goverlayform.spoofCheckBox.Checked);
  AssertTrue('FSpoofToggle is Checked', Helper.SpoofToggle.Checked);

  AssertTrue('forceFsr4Int8CheckBox is Checked', goverlayform.forceFsr4Int8CheckBox.Checked);
  AssertTrue('FForceFsr4Toggle is Checked', Helper.ForceFsr4Toggle.Checked);

  AssertTrue('emufp8CheckBox is Checked', goverlayform.emufp8CheckBox.Checked);
  AssertTrue('FForceMlfgToggle is Checked', Helper.ForceMlfgToggle.Checked);

  AssertTrue('forcereflexCheckBox is Checked', goverlayform.forcereflexCheckBox.Checked);
  AssertTrue('FForceReflexToggle is Checked', Helper.ForceReflexToggle.Checked);

  AssertTrue('forcelatencyflexCheckBox is Checked', goverlayform.forcelatencyflexCheckBox.Checked);
  AssertTrue('FForceLatencyFlexToggle is Checked', Helper.ForceLatencyFlexToggle.Checked);
end;

procedure TGoverlayGuiTests.TestGlobalToolTogglesPersistenceAcrossLaunches;
var
  GlobalConfPath: string;
  Ini: TIniFile;
  i: Integer;
begin
  // Set Global mode
  goverlayform.FActiveGameName := '';
  GlobalConfPath := goverlayform.GetGameConfigDir('') + 'bgmod.conf';

  // 1. Initial State: Toggle all tools ON first
  for i := 0 to 3 do
  begin
    goverlayform.FNavToolEnabled[i] := True;
    if Assigned(goverlayform.FNavToolBtns[i]) then
    begin
      goverlayform.FNavToolBtns[i].Tag := i;
      // Click to toggle OFF
      goverlayform.NavToolToggleClick(goverlayform.FNavToolBtns[i]);
    end;
  end;

  // Verify all tools are disabled in UI
  for i := 0 to 3 do
  begin
    AssertFalse(Format('Nav tool %d disabled in FNavToolEnabled', [i]), goverlayform.FNavToolEnabled[i]);
    if Assigned(goverlayform.FNavToolBtns[i]) then
      AssertEquals(Format('Nav tool %d button image index is 0 (OFF)', [i]), 0, goverlayform.FNavToolBtns[i].ImageIndex);
  end;

  // Verify written to disk in bgmod.conf
  AssertTrue('Global bgmod.conf exists', FileExists(GlobalConfPath));
  Ini := TIniFile.Create(GlobalConfPath);
  try
    AssertEquals('GOVERLAY_MANGOHUD is 0', '0', Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '1'));
    AssertEquals('GOVERLAY_VKBASALT is 0', '0', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', '1'));
    AssertEquals('GOVERLAY_OPTISCALER is 0', '0', Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '1'));
    AssertEquals('GOVERLAY_TWEAKS is 0', '0', Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '1'));
  finally
    Ini.Free;
  end;

  // 2. Simulate 2nd Launch (startup init and loading)
  InitializeGlobalConfigDirectory;
  goverlayform.LoadGameToggleStates;

  // Verify all tools remain disabled after 2nd launch
  for i := 0 to 3 do
  begin
    AssertFalse(Format('Nav tool %d remains disabled on 2nd launch', [i]), goverlayform.FNavToolEnabled[i]);
    if Assigned(goverlayform.FNavToolBtns[i]) then
      AssertEquals(Format('Nav tool %d button image index is 0 (OFF) on 2nd launch', [i]), 0, goverlayform.FNavToolBtns[i].ImageIndex);
  end;

  // Verify bgmod.conf was not overwritten with defaults
  Ini := TIniFile.Create(GlobalConfPath);
  try
    AssertEquals('GOVERLAY_MANGOHUD is still 0 on 2nd launch', '0', Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '1'));
    AssertEquals('GOVERLAY_VKBASALT is still 0 on 2nd launch', '0', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', '1'));
    AssertEquals('GOVERLAY_OPTISCALER is still 0 on 2nd launch', '0', Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '1'));
    AssertEquals('GOVERLAY_TWEAKS is still 0 on 2nd launch', '0', Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '1'));
  finally
    Ini.Free;
  end;

  // 3. Simulate 3rd Launch
  InitializeGlobalConfigDirectory;
  goverlayform.LoadGameToggleStates;

  // Verify all tools remain disabled after 3rd launch
  for i := 0 to 3 do
  begin
    AssertFalse(Format('Nav tool %d remains disabled on 3rd launch', [i]), goverlayform.FNavToolEnabled[i]);
    if Assigned(goverlayform.FNavToolBtns[i]) then
      AssertEquals(Format('Nav tool %d button image index is 0 (OFF) on 3rd launch', [i]), 0, goverlayform.FNavToolBtns[i].ImageIndex);
  end;

  // 4. Navigate to MangoHud tab and verify GOVERLAY_MANGOHUD is NOT reverted to 1
  goverlayform.mangohudLabelClick(nil);

  AssertFalse('MangoHud remains disabled in FNavToolEnabled after navigating to MangoHud tab', goverlayform.FNavToolEnabled[0]);
  if Assigned(goverlayform.FNavToolBtns[0]) then
    AssertEquals('MangoHud button image index is still 0 (OFF)', 0, goverlayform.FNavToolBtns[0].ImageIndex);

  Ini := TIniFile.Create(GlobalConfPath);
  try
    AssertEquals('GOVERLAY_MANGOHUD is still 0 after visiting MangoHud tab', '0', Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '1'));
  finally
    Ini.Free;
  end;

  // 5. Navigate to other tool tabs and verify all flags remain 0
  goverlayform.vkbasaltLabelClick(nil);
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.tweaksLabelClick(nil);

  Ini := TIniFile.Create(GlobalConfPath);
  try
    AssertEquals('GOVERLAY_MANGOHUD is still 0 after visiting all tabs', '0', Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '1'));
    AssertEquals('GOVERLAY_VKBASALT is still 0 after visiting all tabs', '0', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', '1'));
    AssertEquals('GOVERLAY_OPTISCALER is still 0 after visiting all tabs', '0', Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '1'));
    AssertEquals('GOVERLAY_TWEAKS is still 0 after visiting all tabs', '0', Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '1'));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.TestGameCardFallbackCoverGeneration;
var
  CoverPath: string;
  Jpg: TJPEGImage;
begin
  CoverPath := GetTempDir + 'test_cover_fallback_' + IntToStr(GetProcessID) + '.jpg';
  try
    if FileExists(CoverPath) then DeleteFile(CoverPath);
    if FileExists(CoverPath + '.fallback') then DeleteFile(CoverPath + '.fallback');

    GenerateFallbackCover(CoverPath, goverlayform);

    AssertTrue('Fallback cover JPEG was created', FileExists(CoverPath));
    AssertTrue('Fallback marker file was created', FileExists(CoverPath + '.fallback'));
    AssertTrue('Fallback cover file is not empty', FileSize(CoverPath) > 0);

    Jpg := TJPEGImage.Create;
    try
      Jpg.LoadFromFile(CoverPath);
      AssertEquals('Fallback cover width matches CARD_W (150)', 150, Jpg.Width);
      AssertEquals('Fallback cover height matches CARD_H (215)', 215, Jpg.Height);
    finally
      Jpg.Free;
    end;
  finally
    if FileExists(CoverPath) then DeleteFile(CoverPath);
    if FileExists(CoverPath + '.fallback') then DeleteFile(CoverPath + '.fallback');
  end;
end;

procedure TGoverlayGuiTests.TestToolToggleOffPreservesConfigFiles;
var
  GlobalConfDir, GlobalMangoPath, GlobalOptiPath, GlobalBgmodPath: string;
  Lines: TStringList;
  Ini: TIniFile;
  i: Integer;
begin
  goverlayform.FActiveGameName := '';
  GlobalConfDir := goverlayform.GetGameConfigDir('');
  ForceDirectories(GlobalConfDir);
  GlobalMangoPath := GlobalConfDir + 'MangoHud.conf';
  GlobalOptiPath  := GlobalConfDir + 'OptiScaler.ini';
  GlobalBgmodPath := GlobalConfDir + 'bgmod.conf';

  // Seed custom MangoHud config
  Lines := TStringList.Create;
  try
    Lines.Add('fps_limit=144');
    Lines.Add('cpu_temp=1');
    Lines.SaveToFile(GlobalMangoPath);
  finally
    Lines.Free;
  end;

  // Seed custom OptiScaler config
  Lines := TStringList.Create;
  try
    Lines.Add('[Upscalers]');
    Lines.Add('Dx12=xess');
    Lines.SaveToFile(GlobalOptiPath);
  finally
    Lines.Free;
  end;

  // Seed custom bgmod.conf with custom [Env] variable
  Lines := TStringList.Create;
  try
    Lines.Add('[Config]');
    Lines.Add('GOVERLAY_MANGOHUD=1');
    Lines.Add('GOVERLAY_OPTISCALER=1');
    Lines.Add('GOVERLAY_TWEAKS=1');
    Lines.Add('[Env]');
    Lines.Add('CUSTOM_TEST_VAR=special_value');
    Lines.SaveToFile(GlobalBgmodPath);
  finally
    Lines.Free;
  end;

  // Toggle OFF MangoHud, OptiScaler, and Tweaks
  for i := 0 to 3 do
  begin
    goverlayform.FNavToolEnabled[i] := True;
    if Assigned(goverlayform.FNavToolBtns[i]) then
    begin
      goverlayform.FNavToolBtns[i].Tag := i;
      goverlayform.NavToolToggleClick(goverlayform.FNavToolBtns[i]);
    end;
  end;

  // Verify bgmod.conf flags are 0
  Ini := TIniFile.Create(GlobalBgmodPath);
  try
    AssertEquals('GOVERLAY_MANGOHUD is 0', '0', Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '1'));
    AssertEquals('GOVERLAY_OPTISCALER is 0', '0', Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '1'));
    AssertEquals('GOVERLAY_TWEAKS is 0', '0', Ini.ReadString('Config', 'GOVERLAY_TWEAKS', '1'));
    // Verify [Env] was NOT wiped
    AssertEquals('CUSTOM_TEST_VAR is preserved', 'special_value', Ini.ReadString('Env', 'CUSTOM_TEST_VAR', ''));
  finally
    Ini.Free;
  end;

  // Verify MangoHud.conf and OptiScaler.ini were NOT deleted
  AssertTrue('MangoHud.conf preserved on toggle off', FileExists(GlobalMangoPath));
  AssertTrue('OptiScaler.ini preserved on toggle off', FileExists(GlobalOptiPath));
  AssertTrue('MangoHud.conf content intact', Pos('fps_limit=144', ReadFileText(GlobalMangoPath)) > 0);
  AssertTrue('OptiScaler.ini content intact', Pos('Dx12=xess', ReadFileText(GlobalOptiPath)) > 0);
end;

procedure TGoverlayGuiTests.TestPerGameLaunchCommandImmediateUpdate;
var
  DummyCard: TPanel;
  GlobalExpected, GameExpected: string;
begin
  goverlayform.FActiveGameName := '';
  GlobalExpected := goverlayform.GetLaunchCommand;
  AssertTrue('Global command references global dir', Pos('global', GlobalExpected) > 0);

  // Simulate clicking a game card
  DummyCard := TPanel.Create(goverlayform);
  try
    DummyCard.Parent := goverlayform;
    DummyCard.Hint := '(99999) CyberTestGame' + LineEnding + '/games/CyberTestGame';
    TGamesTabHelper(goverlayform.FGamesHelper).GameCardClick(DummyCard);

    AssertEquals('FActiveGameName set to game', 'CyberTestGame', goverlayform.FActiveGameName);
    GameExpected := goverlayform.GetLaunchCommand;
    AssertTrue('FLaunchCommand updated immediately to CyberTestGame', Pos('CyberTestGame', goverlayform.FLaunchCommand) > 0);
    AssertEquals('FLaunchCommand matches GetLaunchCommand', GameExpected, goverlayform.FLaunchCommand);

    // Simulate clicking empty space on games tab to return to global
    TGamesTabHelper(goverlayform.FGamesHelper).GamesEmptySpaceClick(nil);
    AssertEquals('FActiveGameName cleared to global', '', goverlayform.FActiveGameName);
    AssertTrue('FLaunchCommand reset immediately to global', Pos('global', goverlayform.FLaunchCommand) > 0);
  finally
    DummyCard.Free;
  end;
end;

procedure TGoverlayGuiTests.TestOptiLatencyFlexSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.forcelatencyflexCheckBox.Checked := True;
  goverlayform.latencyflexComboBox.ItemIndex := 1;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_latencyflex=1 persisted', Pos('force_latencyflex=1', Content) > 0);
  AssertTrue('latencyflex_mode=1 persisted', Pos('latencyflex_mode=1', Content) > 0);

  goverlayform.LoadOptiScalerConfig;
  AssertTrue('forcelatencyflexCheckBox reloaded', goverlayform.forcelatencyflexCheckBox.Checked);
  AssertEquals('latencyflexComboBox reloaded', 1, goverlayform.latencyflexComboBox.ItemIndex);

  goverlayform.forcelatencyflexCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('force_latencyflex=0 persisted', Pos('force_latencyflex=0', Content) > 0);
  AssertTrue('latencyflex_mode=0 persisted', Pos('latencyflex_mode=0', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiTraceLogSave;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.tracelogCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('enable_trace_logs=1 persisted', Pos('enable_trace_logs=1', Content) > 0);

  goverlayform.LoadOptiScalerConfig;
  AssertTrue('tracelogCheckBox reloaded', goverlayform.tracelogCheckBox.Checked);

  goverlayform.tracelogCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(FakeIniPath);
  AssertTrue('enable_trace_logs=0 persisted', Pos('enable_trace_logs=0', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiUpdateButtonsGuarded;
begin
  // Both buttons are wired, but in GOVERLAY_TEST mode their handlers exit
  // before any network activity - clicking must be a harmless no-op.
  NavigateOptiScalerTab;
  AssertTrue('checkupdBitbtn bound', Assigned(goverlayform.checkupdBitbtn.OnClick));
  goverlayform.checkupdBitbtn.OnClick(goverlayform.checkupdBitbtn);
  AssertTrue('updatebitBtn bound', Assigned(goverlayform.updatebitBtn.OnClick));
  goverlayform.updatebitBtn.OnClick(goverlayform.updatebitBtn);
  AssertFalse('no OptiScaler download appeared',
    FileExists(IsolatedHome + '/.local/share/goverlay/gameconfig/global/OptiScaler.dll'));
end;

procedure TGoverlayGuiTests.TestOptiShortcutCaptureBound;
begin
  // Capture button opens a modal key-capture form; verify wiring only.
  NavigateOptiScalerTab;
  AssertTrue('shortcut capture button exists', Assigned(goverlayform.FOsShortcutCaptureBtn));
  AssertTrue('shortcut capture button bound', Assigned(goverlayform.FOsShortcutCaptureBtn.OnClick));
end;

procedure TGoverlayGuiTests.TestOptiScalerToggleNvidiaReEnableState;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.nvidiaRadioButton.Checked := True;
  AssertFalse('spoofCheckBox disabled on nvidia', goverlayform.spoofCheckBox.Enabled);
  AssertFalse('forcereflexCheckBox disabled on nvidia', goverlayform.forcereflexCheckBox.Enabled);

  // Ensure tool is currently enabled
  goverlayform.FNavToolEnabled[2] := True;

  // Toggle OptiScaler OFF via sidebar button (tool index 2)
  goverlayform.FNavToolBtns[2].OnClick(goverlayform.FNavToolBtns[2]);
  AssertFalse('OptiScaler tool disabled', goverlayform.FNavToolEnabled[2]);

  // Toggle OptiScaler ON via sidebar button
  goverlayform.FNavToolBtns[2].OnClick(goverlayform.FNavToolBtns[2]);
  AssertTrue('OptiScaler tool re-enabled', goverlayform.FNavToolEnabled[2]);

  // Verify Nvidia restrictions remain enforced after re-enabling
  AssertFalse('spoofCheckBox stays disabled on nvidia after re-enable', goverlayform.spoofCheckBox.Enabled);
  AssertFalse('forcereflexCheckBox stays disabled on nvidia after re-enable', goverlayform.forcereflexCheckBox.Enabled);
end;

procedure TGoverlayGuiTests.TestGlobalOptiScalerToggleSync;
var
  GlobalDir: string;
begin
  SeedOptiScalerFiles;
  goverlayform.FActiveGameName := '';
  GlobalDir := IsolatedHome + '/.local/share/goverlay/gameconfig/global/';

  // Delete OptiScaler.ini in global profile to test population
  if FileExists(GlobalDir + 'OptiScaler.ini') then
    DeleteFile(GlobalDir + 'OptiScaler.ini');

  goverlayform.FNavToolEnabled[2] := False;

  // Toggle OptiScaler ON in global mode
  goverlayform.FNavToolBtns[2].OnClick(goverlayform.FNavToolBtns[2]);
  AssertTrue('OptiScaler tool enabled globally', goverlayform.FNavToolEnabled[2]);

  // Assert global profile OptiScaler.ini is created immediately
  AssertTrue('OptiScaler.ini created in global profile on toggle ON', FileExists(GlobalDir + 'OptiScaler.ini'));
end;

procedure TGoverlayGuiTests.TestCommandPanelRightMarginConsistency;
begin
  // Floating action dock and overlays must be instantiated
  AssertTrue('FFADock created', Assigned(goverlayform.FFADock));
  AssertTrue('FFloatingToast created', Assigned(goverlayform.FFloatingToast));
  AssertTrue('FFloatingProgress created', Assigned(goverlayform.FFloatingProgress));

  // Legacy bottom bar is hidden on all tabs
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  AssertFalse('goverlaybarPanel hidden on MangoHud tab', goverlayform.goverlaybarPanel.Visible);

  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  AssertFalse('goverlaybarPanel hidden on OptiScaler tab', goverlayform.goverlaybarPanel.Visible);

  goverlayform.tweaksLabel.OnClick(goverlayform.tweaksLabel);
  AssertFalse('goverlaybarPanel hidden on Tweaks tab', goverlayform.goverlaybarPanel.Visible);

  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  AssertFalse('goverlaybarPanel hidden on vkBasalt tab', goverlayform.goverlaybarPanel.Visible);

  // Test Auto-Save Floating Toast trigger
  goverlayform.ShowSavedStatus;
  AssertTrue('ShowSavedStatus executes cleanly without error', True);
end;

procedure TGoverlayGuiTests.TestFloatingActionDockAndFinishDialog;
var
  TestPanel: TPanel;
begin
  AssertTrue('FFADock is assigned', Assigned(goverlayform.FFADock));
  AssertEquals('goverlayPageControl BorderSpacing.Bottom is 0', 0, goverlayform.goverlayPageControl.BorderSpacing.Bottom);

  // Switch to MangoHud tab -> dock updated (Preview, Menu, Finish)
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  AssertFalse('Legacy goverlaybarPanel is not visible on MangoHud', goverlayform.goverlaybarPanel.Visible);
  AssertTrue('Dock is visible on MangoHud', goverlayform.FFADock.Visible);

  // Switch to Tweaks tab -> dock updated (Add, Finish)
  goverlayform.tweaksLabel.OnClick(goverlayform.tweaksLabel);
  AssertFalse('Legacy goverlaybarPanel is not visible on Tweaks', goverlayform.goverlaybarPanel.Visible);
  AssertTrue('Dock is visible on Tweaks', goverlayform.FFADock.Visible);

  // Switch to OptiScaler tab -> dock updated to solo Finish pill
  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  AssertFalse('Legacy goverlaybarPanel is not visible on OptiScaler', goverlayform.goverlaybarPanel.Visible);
  AssertTrue('Dock is visible on OptiScaler', goverlayform.FFADock.Visible);

  // Switch to Games tab -> dock visible with Menu and + Add Folder
  goverlayform.gamesLabelClick(nil);
  AssertTrue('Dock is visible on Games tab', goverlayform.FFADock.Visible);

  // Click a game card -> transitions to MangoHud, dock visible, legacy bar hidden
  TestPanel := TPanel.Create(nil);
  try
    TestPanel.Hint := 'TestGameDock';
    goverlayform.GameCardClick(TestPanel);
    AssertFalse('Legacy goverlaybarPanel is NOT visible after game card click', goverlayform.goverlaybarPanel.Visible);
    AssertTrue('Dock is visible after game card click', goverlayform.FFADock.Visible);
  finally
    TestPanel.Free;
    goverlayform.gamesLabelClick(nil);
  end;

  // Hover and press state tests for Finish pill
  AssertFalse('Finish button not hovered initially', goverlayform.FFADock.FinishHovered);
  AssertFalse('Finish button not pressed initially', goverlayform.FFADock.FinishPressed);

  goverlayform.FFADock.SimulateFinishHover(True);
  AssertTrue('Finish button is hovered', goverlayform.FFADock.FinishHovered);

  goverlayform.FFADock.SimulateFinishPress(True);
  AssertTrue('Finish button is pressed', goverlayform.FFADock.FinishPressed);

  goverlayform.FFADock.SimulateFinishPress(False);
  AssertFalse('Finish button is no longer pressed', goverlayform.FFADock.FinishPressed);

  goverlayform.FFADock.SimulateFinishHover(False);
  AssertFalse('Finish button is no longer hovered', goverlayform.FFADock.FinishHovered);

  // Hover and press state tests for secondary dock buttons
  AssertFalse('Menu button not hovered initially', goverlayform.FFADock.MenuHovered);
  goverlayform.FFADock.SimulateMenuHover(True);
  AssertTrue('Menu button is hovered', goverlayform.FFADock.MenuHovered);
  goverlayform.FFADock.SimulateMenuPress(True);
  AssertTrue('Menu button is pressed', goverlayform.FFADock.MenuPressed);
  goverlayform.FFADock.SimulateMenuPress(False);
  goverlayform.FFADock.SimulateMenuHover(False);
  AssertFalse('Menu button is no longer hovered', goverlayform.FFADock.MenuHovered);

  AssertFalse('Preview button not hovered initially', goverlayform.FFADock.PreviewHovered);
  goverlayform.FFADock.SimulatePreviewHover(True);
  AssertTrue('Preview button is hovered', goverlayform.FFADock.PreviewHovered);
  goverlayform.FFADock.SimulatePreviewPress(True);
  AssertTrue('Preview button is pressed', goverlayform.FFADock.PreviewPressed);
  goverlayform.FFADock.SimulatePreviewPress(False);
  goverlayform.FFADock.SimulatePreviewHover(False);
  AssertFalse('Preview button is no longer hovered', goverlayform.FFADock.PreviewHovered);

  AssertFalse('Add button not hovered initially', goverlayform.FFADock.AddHovered);
  goverlayform.FFADock.SimulateAddHover(True);
  AssertTrue('Add button is hovered', goverlayform.FFADock.AddHovered);
  goverlayform.FFADock.SimulateAddPress(True);
  AssertTrue('Add button is pressed', goverlayform.FFADock.AddPressed);
  goverlayform.FFADock.SimulateAddPress(False);
  goverlayform.FFADock.SimulateAddHover(False);
  AssertFalse('Add button is no longer hovered', goverlayform.FFADock.AddHovered);

  // Progress overlay test
  goverlayform.FFloatingProgress.ShowProgress('Testing progress...', 50);
  AssertTrue('Progress banner is visible', goverlayform.FFloatingProgress.Visible);
  goverlayform.FFloatingProgress.HideProgress;
  AssertFalse('Progress banner is hidden', goverlayform.FFloatingProgress.Visible);
end;

procedure TGoverlayGuiTests.TestPasCubeAutoLaunchHiddenAndLowercaseUpscalers;
begin
  AssertFalse('Auto launch PasCube menu item hidden in settings menu', goverlayform.FCubeAutoLaunchItem.Visible);
  AssertEquals('preferredUpscalerComboBox item 0 is lowercase auto', 'auto', goverlayform.preferredUpscalerComboBox.Items[0]);
  AssertEquals('preferredUpscalerComboBox item 1 is lowercase xess', 'xess', goverlayform.preferredUpscalerComboBox.Items[1]);
  AssertEquals('preferredUpscalerComboBox item 2 is lowercase fsr21', 'fsr21', goverlayform.preferredUpscalerComboBox.Items[2]);
  AssertEquals('preferredUpscalerComboBox item 3 is lowercase fsr22', 'fsr22', goverlayform.preferredUpscalerComboBox.Items[3]);
  AssertEquals('preferredUpscalerComboBox item 4 is lowercase fsr4', 'fsr4', goverlayform.preferredUpscalerComboBox.Items[4]);
  AssertEquals('preferredUpscalerComboBox item 5 is lowercase dlss', 'dlss', goverlayform.preferredUpscalerComboBox.Items[5]);
end;

procedure TGoverlayGuiTests.TestLaunchSplashSettingsMenuItem;
var
  IdxCreate, IdxSplash: Integer;
  ConfigPath, BgmodPath: string;
  Ini: TIniFile;
begin
  AssertNotNull('Launch splash menu item is assigned', goverlayform.FLaunchSplashItem);
  AssertEquals('Launch splash menu item caption is correct', 'Show launch splash screen', goverlayform.FLaunchSplashItem.Caption);
  AssertTrue('Launch splash menu item AutoCheck is True', goverlayform.FLaunchSplashItem.AutoCheck);
  AssertTrue('Launch splash menu item defaults to Checked', goverlayform.FLaunchSplashItem.Checked);
  AssertTrue('FShowLaunchSplash defaults to True', goverlayform.FShowLaunchSplash);

  // Position: directly beneath FCreateSteamShortcutItem
  IdxCreate := goverlayform.settingsMenu.Items.IndexOf(goverlayform.FCreateSteamShortcutItem);
  IdxSplash := goverlayform.settingsMenu.Items.IndexOf(goverlayform.FLaunchSplashItem);
  AssertTrue('FCreateSteamShortcutItem exists in settingsMenu', IdxCreate >= 0);
  AssertTrue('FLaunchSplashItem exists in settingsMenu', IdxSplash >= 0);
  AssertEquals('FLaunchSplashItem is directly beneath FCreateSteamShortcutItem', IdxCreate + 1, IdxSplash);

  // Test toggle: uncheck
  goverlayform.FLaunchSplashItem.Checked := False;
  goverlayform.LaunchSplashMenuItemClick(goverlayform.FLaunchSplashItem);
  AssertFalse('FShowLaunchSplash updated to False', goverlayform.FShowLaunchSplash);

  // Verify persistence in goverlay.conf
  ConfigPath := GetConfigFilePath;
  AssertTrue('goverlay.conf exists', FileExists(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    AssertFalse('ShowLaunchSplash saved as False in goverlay.conf', Ini.ReadBool('General', 'ShowLaunchSplash', True));
  finally
    Ini.Free;
  end;

  // Verify persistence in global bgmod.conf
  BgmodPath := goverlayform.GetGameConfigDir('') + 'bgmod.conf';
  if FileExists(BgmodPath) then
  begin
    Ini := TIniFile.Create(BgmodPath);
    try
      AssertEquals('SHOW_LAUNCH_SPLASH saved as 0 in bgmod.conf', '0', Ini.ReadString('Config', 'SHOW_LAUNCH_SPLASH', '1'));
    finally
      Ini.Free;
    end;
  end;

  // Test toggle: check again
  goverlayform.FLaunchSplashItem.Checked := True;
  goverlayform.LaunchSplashMenuItemClick(goverlayform.FLaunchSplashItem);
  AssertTrue('FShowLaunchSplash restored to True', goverlayform.FShowLaunchSplash);

  Ini := TIniFile.Create(ConfigPath);
  try
    AssertTrue('ShowLaunchSplash restored to True in goverlay.conf', Ini.ReadBool('General', 'ShowLaunchSplash', False));
  finally
    Ini.Free;
  end;

  if FileExists(BgmodPath) then
  begin
    Ini := TIniFile.Create(BgmodPath);
    try
      AssertEquals('SHOW_LAUNCH_SPLASH restored to 1 in bgmod.conf', '1', Ini.ReadString('Config', 'SHOW_LAUNCH_SPLASH', '0'));
    finally
      Ini.Free;
    end;
  end;
end;

procedure TGoverlayGuiTests.TestDlssEnablerTagMatchingNoFalseUpdate;
var
  VarsPath: string;
  VarsList: TStringList;
  UpdateThread: TOptiUpdateThread;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.dlssenablerRadioButton.Checked := True;

  VarsPath := IsolatedHome + '/.local/share/goverlay/dlssenabler-stable/goverlay.vars';
  ForceDirectories(ExtractFilePath(VarsPath));
  VarsList := TStringList.Create;
  try
    VarsList.Add('dlssenablerversion=4.8.10.11');
    VarsList.Add('optiScalerVersion=v0.10.0-pre1_7233fc0c');
    VarsList.Add('dlssenablertag=v0.10.0-pre1_7233fc0c');
    VarsList.SaveToFile(VarsPath);
  finally
    VarsList.Free;
  end;

  UpdateThread := TOptiUpdateThread.Create(goverlayform.FOptiscalerUpdate, True, False);
  try
    UpdateThread.FLatestOptiTag := 'v0.10.0-pre1_7233fc0c';
    UpdateThread.SyncUpdateUI;
  finally
    UpdateThread.Free;
  end;

  AssertFalse('OptiLabel2 hidden when DLSS Enabler tag matches latest remote tag', goverlayform.FOptiscalerUpdate.OptiLabel2.Visible);
end;

procedure TGoverlayGuiTests.TestDlssEnablerUpdateStatusDisplay;
var
  VarsPath: string;
  VarsList: TStringList;
  UpdateThread: TOptiUpdateThread;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.dlssenablerRadioButton.Checked := True;

  VarsPath := IsolatedHome + '/.local/share/goverlay/dlssenabler-stable/goverlay.vars';
  ForceDirectories(ExtractFilePath(VarsPath));
  VarsList := TStringList.Create;
  try
    VarsList.Add('dlssenablerversion=4.8.12');
    VarsList.Add('optiScalerVersion=stable-0.9.4');
    VarsList.Add('dlssenablertag=OptiScaler_v0.10.0-pre1_7233fc0c_4.8.12');
    VarsList.SaveToFile(VarsPath);
  finally
    VarsList.Free;
  end;

  goverlayform.FOptiscalerUpdate.LoadVersionsFromFile;
  goverlayform.RefreshOsStatusDots;

  UpdateThread := TOptiUpdateThread.Create(goverlayform.FOptiscalerUpdate, True, False);
  try
    UpdateThread.FLatestOptiTag := 'OptiScaler_v0.10.0-pre1_7233fc0c_4.8.13.19';
    UpdateThread.SyncUpdateUI;
  finally
    UpdateThread.Free;
  end;

  AssertTrue('OptiLabel2 is visible when update available', goverlayform.FOptiscalerUpdate.OptiLabel2.Visible);
  AssertEquals('OptiScaler status row remains stable version', 'stable-0.9.4', goverlayform.FOsStatVerLbls[0].Caption);
  AssertEquals('DLSS Enabler status row shows update arrow', '4.8.12 → v0.10.0-pre1_7233fc0c', goverlayform.FOsStatVerLbls[2].Caption);
  AssertEquals('DLSS Enabler status row font color is CLR_UPDATE', $0044AAFF, goverlayform.FOsStatVerLbls[2].Font.Color);
end;

procedure TGoverlayGuiTests.TestDlssEnablerChannelUpdateSuppressesDowngrades;
var
  VarsPath: string;
  VarsList: TStringList;
  UpdateThread: TOptiUpdateThread;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  goverlayform.dlssenablerRadioButton.Checked := True;
  goverlayform.optversionComboBox.ItemIndex := 1; // Bleeding-edge

  // 1. Seed installed bleeding-edge version 4.9.0.6
  VarsPath := IsolatedHome + '/.local/share/goverlay/dlssenabler-edge/goverlay.vars';
  ForceDirectories(ExtractFilePath(VarsPath));
  VarsList := TStringList.Create;
  try
    VarsList.Add('dlssenablerversion=4.9.0.6');
    VarsList.Add('dlssenablertag=4.9.0.6');
    VarsList.Add('upscalertype=1');
    VarsList.SaveToFile(VarsPath);
  finally
    VarsList.Free;
  end;

  goverlayform.FOptiscalerUpdate.LoadVersionsFromFile;
  goverlayform.RefreshOsStatusDots;

  // 2. Remote check returns older version 4.8.13.6 (e.g. cross-channel stable / older tag)
  UpdateThread := TOptiUpdateThread.Create(goverlayform.FOptiscalerUpdate, False, False);
  try
    UpdateThread.FLatestOptiTag := '4.8.13.6';
    UpdateThread.SyncUpdateUI;
  finally
    UpdateThread.Free;
  end;

  goverlayform.RefreshOsStatusDots;
  AssertFalse('OptiLabel2 is NOT visible on downgrade (4.8.13.6 < 4.9.0.6)', goverlayform.FOptiscalerUpdate.OptiLabel2.Visible);
  AssertEquals('DLSS Enabler status row shows installed 4.9.0.6 without update arrow', '4.9.0.6', goverlayform.FOsStatVerLbls[2].Caption);
  AssertEquals('DLSS Enabler status row color is PURPLE', $BB99FF, goverlayform.FOsStatVerLbls[2].Font.Color);

  // 3. Remote check returns strictly newer version 4.9.0.7
  UpdateThread := TOptiUpdateThread.Create(goverlayform.FOptiscalerUpdate, False, False);
  try
    UpdateThread.FLatestOptiTag := '4.9.0.7';
    UpdateThread.SyncUpdateUI;
  finally
    UpdateThread.Free;
  end;

  goverlayform.RefreshOsStatusDots;
  AssertTrue('OptiLabel2 is visible when newer version 4.9.0.7 is available', goverlayform.FOptiscalerUpdate.OptiLabel2.Visible);
  AssertEquals('DLSS Enabler status row shows update arrow for 4.9.0.7', '4.9.0.6 → 4.9.0.7', goverlayform.FOsStatVerLbls[2].Caption);
  AssertEquals('DLSS Enabler status row color is CLR_UPDATE', $0044AAFF, goverlayform.FOsStatVerLbls[2].Font.Color);
end;

procedure TGoverlayGuiTests.TestDlssEnablerSyncSupportingFiles;
var
  OptiStableDir, DlssStableDir, DlssEdgeDir: string;
  F: TextFile;
  VerContent: TStringList;
begin
  OptiStableDir := IsolatedHome + '/.local/share/goverlay/optiscaler-stable/';
  DlssStableDir := IsolatedHome + '/.local/share/goverlay/dlssenabler-stable/';
  DlssEdgeDir   := IsolatedHome + '/.local/share/goverlay/dlssenabler-edge/';

  // 1. Seed OptiScaler supporting libraries, scripts, and directories
  ForceDirectories(OptiStableDir + 'D3D12_Optiscaler');
  ForceDirectories(OptiStableDir + 'plugins');

  AssignFile(F, OptiStableDir + 'amd_fidelityfx_upscaler_dx12.dll'); Rewrite(F); WriteLn(F, 'fsr_upscaler'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'amd_fidelityfx_framegeneration_dx12.dll'); Rewrite(F); WriteLn(F, 'fsr_fg'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'libxess.dll'); Rewrite(F); WriteLn(F, 'xess'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'dlssg_to_fsr3_amd_is_better.dll'); Rewrite(F); WriteLn(F, 'nukem_bridge'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'fakenvapi.dll'); Rewrite(F); WriteLn(F, 'fakenvapi'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'D3D12_Optiscaler/sample.dll'); Rewrite(F); WriteLn(F, 'd3d12_sample'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'plugins/OptiPatcher.asi'); Rewrite(F); WriteLn(F, 'patcher'); CloseFile(F);
  AssignFile(F, OptiStableDir + 'bgmod'); Rewrite(F); WriteLn(F, '#!/bin/sh'); CloseFile(F);

  // 2. Seed DLSS Enabler native files in dlssenabler-stable
  ForceDirectories(DlssStableDir);
  AssignFile(F, DlssStableDir + 'version.dll'); Rewrite(F); WriteLn(F, 'DLSS_ENABLER_VERSION_DLL'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.interposer.dll'); Rewrite(F); WriteLn(F, 'streamline'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'goverlay.vars'); Rewrite(F);
  WriteLn(F, 'dlssenablerversion=4.9.0');
  WriteLn(F, 'upscalertype=1');
  CloseFile(F);

  // 3. Test self-healing sync on existing dlssenabler-stable
  CheckAndInstallDlssEnabler(True, False);

  // Assert supporting files and directories are synchronized
  AssertTrue('FSR upscaler copied to dlssenabler-stable', FileExists(DlssStableDir + 'amd_fidelityfx_upscaler_dx12.dll'));
  AssertTrue('FSR framegen copied to dlssenabler-stable', FileExists(DlssStableDir + 'amd_fidelityfx_framegeneration_dx12.dll'));
  AssertTrue('XeSS copied to dlssenabler-stable', FileExists(DlssStableDir + 'libxess.dll'));
  AssertTrue('Nukem bridge copied to dlssenabler-stable', FileExists(DlssStableDir + 'dlssg_to_fsr3_amd_is_better.dll'));
  AssertTrue('fakenvapi copied to dlssenabler-stable', FileExists(DlssStableDir + 'fakenvapi.dll'));
  AssertTrue('D3D12_Optiscaler directory copied to dlssenabler-stable', FileExists(DlssStableDir + 'D3D12_Optiscaler/sample.dll'));
  AssertTrue('plugins directory copied to dlssenabler-stable', FileExists(DlssStableDir + 'plugins/OptiPatcher.asi'));
  AssertTrue('bgmod copied to dlssenabler-stable', FileExists(DlssStableDir + 'bgmod'));

  // Assert DLSS Enabler native files are strictly preserved
  VerContent := TStringList.Create;
  try
    VerContent.LoadFromFile(DlssStableDir + 'version.dll');
    AssertEquals('version.dll preserved as DLSS Enabler binary', 'DLSS_ENABLER_VERSION_DLL', Trim(VerContent.Text));
    VerContent.LoadFromFile(DlssStableDir + 'goverlay.vars');
    AssertTrue('goverlay.vars preserved', Pos('dlssenablerversion=4.9.0', VerContent.Text) > 0);
  finally
    VerContent.Free;
  end;

  // 4. Test synchronization to dlssenabler-edge with fallback to stable optiscaler
  ForceDirectories(DlssEdgeDir);
  AssignFile(F, DlssEdgeDir + 'version.dll'); Rewrite(F); WriteLn(F, 'EDGE_VERSION_DLL'); CloseFile(F);
  SyncOptiScalerFilesToDlssEnabler(False);

  AssertTrue('FSR upscaler copied to dlssenabler-edge via fallback', FileExists(DlssEdgeDir + 'amd_fidelityfx_upscaler_dx12.dll'));
  AssertTrue('Nukem bridge copied to dlssenabler-edge via fallback', FileExists(DlssEdgeDir + 'dlssg_to_fsr3_amd_is_better.dll'));
  AssertTrue('fakenvapi copied to dlssenabler-edge via fallback', FileExists(DlssEdgeDir + 'fakenvapi.dll'));
  AssertTrue('plugins copied to dlssenabler-edge via fallback', FileExists(DlssEdgeDir + 'plugins/OptiPatcher.asi'));
end;

procedure TGoverlayGuiTests.TestDlssEnablerStreamlineBackupAndCleanup;
var
  GameDir, GameCfgDir, DlssStableDir, BackupsDir, BgmodBin, ExecCmd: string;
  F: TextFile;
  Proc: TProcess;
  FileContent: TStringList;
begin
  GameDir := IsolatedHome + '/games/StreamlineGame/';
  GameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/StreamlineGame/';
  DlssStableDir := IsolatedHome + '/.local/share/goverlay/dlssenabler-stable/';
  BackupsDir := GameCfgDir + 'backups/';

  ForceDirectories(GameDir);
  ForceDirectories(GameCfgDir);
  ForceDirectories(DlssStableDir);

  // 1. Seed native game files in GameDir
  AssignFile(F, GameDir + 'StreamlineGame.exe'); Rewrite(F); WriteLn(F, 'dummy_exe'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.common.dll'); Rewrite(F); WriteLn(F, 'NATIVE_SL_COMMON_2_4'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.pcl.dll'); Rewrite(F); WriteLn(F, 'NATIVE_SL_PCL_2_4'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.interposer.dll'); Rewrite(F); WriteLn(F, 'NATIVE_SL_INTERPOSER_2_4'); CloseFile(F);

  // 2. Seed DLSS Enabler 2.12 files in dlssenabler-stable
  AssignFile(F, DlssStableDir + 'version.dll'); Rewrite(F); WriteLn(F, 'DLSS_ENABLER_VERSION'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.common.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_COMMON_2_12'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.pcl.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_PCL_2_12'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.interposer.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_INTERPOSER_2_12'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.deepdvc.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_DEEPDVC'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.directsr.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_DIRECTSR'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.dlss.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_DLSS'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.dlss_d.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_DLSS_D'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.dlss_g.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_DLSS_G'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.imgui.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_IMGUI'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.nis.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_NIS'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.nvperf.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_NVPERF'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'sl.reflex.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_REFLEX'); CloseFile(F);
  AssignFile(F, DlssStableDir + 'goverlay.vars'); Rewrite(F);
  WriteLn(F, 'dlssenablerversion=4.9.0');
  WriteLn(F, 'upscalertype=1');
  CloseFile(F);

  // Locate bgmod binary
  BgmodBin := GetCurrentDir + '/bgmod';
  if not FileExists(BgmodBin) then
    BgmodBin := ExtractFilePath(ParamStr(0)) + '../../bgmod';
  if not FileExists(BgmodBin) then
    BgmodBin := ExtractFilePath(ParamStr(0)) + 'bgmod';

  AssertTrue('bgmod binary exists for testing', FileExists(BgmodBin));
  CopyFile(BgmodBin, GameCfgDir + 'bgmod');
  fpChmod(GameCfgDir + 'bgmod', &755);
  CopyFile(BgmodBin, DlssStableDir + 'bgmod');
  fpChmod(DlssStableDir + 'bgmod', &755);
  CopyFile(DlssStableDir + 'goverlay.vars', GameCfgDir + 'goverlay.vars');

  // 3. Write bgmod.conf with DLSS Enabler enabled
  AssignFile(F, GameCfgDir + 'bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_MANGOHUD=0');
  WriteLn(F, 'GOVERLAY_VKBASALT=0');
  WriteLn(F, 'GOVERLAY_VKSUMI=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'GOVERLAY_TWEAKS=0');
  WriteLn(F, 'GOVERLAY_LOSSLESS=0');
  WriteLn(F, 'UPSCALER_TYPE=1');
  WriteLn(F, 'OPT_CHANNEL=0');
  WriteLn(F, 'DLL=version.dll');
  WriteLn(F, 'PRESERVE_INI=false');
  CloseFile(F);

  // 4. Run bgmod to perform installation
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    ExecCmd := 'HOME="' + IsolatedHome + '" XDG_DATA_HOME="' + IsolatedHome + '/.local/share" "' +
      GameCfgDir + 'bgmod" /bin/true "' + GameDir + 'StreamlineGame.exe"';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 5. Verify original Streamline binaries backed up
  AssertTrue('sl.pcl.dll backed up to backups folder', FileExists(BackupsDir + 'sl.pcl.dll'));
  AssertTrue('sl.common.dll backed up to backups folder', FileExists(BackupsDir + 'sl.common.dll'));
  AssertTrue('sl.interposer.dll backed up to backups folder', FileExists(BackupsDir + 'sl.interposer.dll'));

  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(BackupsDir + 'sl.pcl.dll');
    AssertEquals('Backup sl.pcl.dll contains native content', 'NATIVE_SL_PCL_2_4', Trim(FileContent.Text));
    FileContent.LoadFromFile(BackupsDir + 'sl.common.dll');
    AssertEquals('Backup sl.common.dll contains native content', 'NATIVE_SL_COMMON_2_4', Trim(FileContent.Text));
    FileContent.LoadFromFile(BackupsDir + 'sl.interposer.dll');
    AssertEquals('Backup sl.interposer.dll contains native content', 'NATIVE_SL_INTERPOSER_2_4', Trim(FileContent.Text));

    // 6. Verify mod versions deployed to GameDir, including sl.pcl.dll and all plugins
    FileContent.LoadFromFile(GameDir + 'sl.pcl.dll');
    AssertEquals('Deployed sl.pcl.dll is updated to 2.12', 'MOD_SL_PCL_2_12', Trim(FileContent.Text));
    FileContent.LoadFromFile(GameDir + 'sl.common.dll');
    AssertEquals('Deployed sl.common.dll is updated to 2.12', 'MOD_SL_COMMON_2_12', Trim(FileContent.Text));

    AssertTrue('sl.deepdvc.dll deployed to GameDir', FileExists(GameDir + 'sl.deepdvc.dll'));
    AssertTrue('sl.directsr.dll deployed to GameDir', FileExists(GameDir + 'sl.directsr.dll'));
    AssertTrue('sl.dlss_d.dll deployed to GameDir', FileExists(GameDir + 'sl.dlss_d.dll'));
    AssertTrue('sl.imgui.dll deployed to GameDir', FileExists(GameDir + 'sl.imgui.dll'));
    AssertTrue('sl.nvperf.dll deployed to GameDir', FileExists(GameDir + 'sl.nvperf.dll'));
    AssertTrue('sl.dlss.dll deployed to GameDir', FileExists(GameDir + 'sl.dlss.dll'));
    AssertTrue('sl.dlss_g.dll deployed to GameDir', FileExists(GameDir + 'sl.dlss_g.dll'));
    AssertTrue('sl.reflex.dll deployed to GameDir', FileExists(GameDir + 'sl.reflex.dll'));
    AssertTrue('sl.nis.dll deployed to GameDir', FileExists(GameDir + 'sl.nis.dll'));
  finally
    FileContent.Free;
  end;

  // 7. Test uninstallation / disable: set GOVERLAY_OPTISCALER=0
  AssignFile(F, GameCfgDir + 'bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_MANGOHUD=0');
  WriteLn(F, 'GOVERLAY_VKBASALT=0');
  WriteLn(F, 'GOVERLAY_VKSUMI=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=0');
  WriteLn(F, 'GOVERLAY_TWEAKS=0');
  WriteLn(F, 'GOVERLAY_LOSSLESS=0');
  WriteLn(F, 'UPSCALER_TYPE=1');
  WriteLn(F, 'OPT_CHANNEL=0');
  WriteLn(F, 'DLL=version.dll');
  WriteLn(F, 'PRESERVE_INI=false');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod cleanup execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 8. Verify original Streamline files were restored and backups consumed
  AssertFalse('Backup sl.pcl.dll was consumed/removed', FileExists(BackupsDir + 'sl.pcl.dll'));
  AssertFalse('Backup sl.common.dll was consumed/removed', FileExists(BackupsDir + 'sl.common.dll'));
  AssertFalse('Backup sl.interposer.dll was consumed/removed', FileExists(BackupsDir + 'sl.interposer.dll'));

  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(GameDir + 'sl.pcl.dll');
    AssertEquals('Restored sl.pcl.dll has original native content', 'NATIVE_SL_PCL_2_4', Trim(FileContent.Text));
    FileContent.LoadFromFile(GameDir + 'sl.common.dll');
    AssertEquals('Restored sl.common.dll has original native content', 'NATIVE_SL_COMMON_2_4', Trim(FileContent.Text));
    FileContent.LoadFromFile(GameDir + 'sl.interposer.dll');
    AssertEquals('Restored sl.interposer.dll has original native content', 'NATIVE_SL_INTERPOSER_2_4', Trim(FileContent.Text));
  finally
    FileContent.Free;
  end;

  // 9. Verify non-native Streamline DLLs deployed by mod were cleaned up
  AssertFalse('sl.deepdvc.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.deepdvc.dll'));
  AssertFalse('sl.directsr.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.directsr.dll'));
  AssertFalse('sl.dlss_d.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.dlss_d.dll'));
  AssertFalse('sl.imgui.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.imgui.dll'));
  AssertFalse('sl.nvperf.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.nvperf.dll'));
  AssertFalse('sl.dlss.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.dlss.dll'));
  AssertFalse('sl.dlss_g.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.dlss_g.dll'));
  AssertFalse('sl.reflex.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.reflex.dll'));
  AssertFalse('sl.nis.dll deleted from GameDir on cleanup', FileExists(GameDir + 'sl.nis.dll'));
end;

procedure TGoverlayGuiTests.TestSafeUninstallChangesRestoresStreamlineBackups;
var
  GameDir, GameCfgDir, BackupsDir, UninstallerBin, ExecCmd: string;
  Proc: TProcess;
  FileContent: TStringList;
  F: TextFile;
begin
  GameDir := IsolatedHome + '/games/SafeUninstallGame/';
  GameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/SafeUninstallGame/';
  BackupsDir := GameCfgDir + 'backups/';
  ForceDirectories(GameDir);
  ForceDirectories(BackupsDir);

  // 1. Write original native game files into BackupsDir
  AssignFile(F, BackupsDir + 'sl.common.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_SL_COMMON'); CloseFile(F);
  AssignFile(F, BackupsDir + 'sl.interposer.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_SL_INTERPOSER'); CloseFile(F);
  AssignFile(F, BackupsDir + 'sl.pcl.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_SL_PCL'); CloseFile(F);

  // 2. Write modified / deployed mod files in GameDir
  AssignFile(F, GameDir + 'sl.common.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_COMMON_REPLACED'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.interposer.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_INTERPOSER_REPLACED'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.pcl.dll'); Rewrite(F); WriteLn(F, 'MOD_SL_PCL_REPLACED'); CloseFile(F);
  AssignFile(F, GameDir + 'sl.deepdvc.dll'); Rewrite(F); WriteLn(F, 'MOD_ONLY_PLUGIN'); CloseFile(F);
  AssignFile(F, GameDir + 'version.dll'); Rewrite(F); WriteLn(F, 'MOD_PROXY'); CloseFile(F);
  AssignFile(F, GameDir + 'goverlay.vars'); Rewrite(F);
  WriteLn(F, 'dlssenablerversion=4.9.0');
  WriteLn(F, 'proxydll=version.dll');
  CloseFile(F);

  // Locate bgmod-uninstaller binary
  UninstallerBin := GetCurrentDir + '/bgmod-uninstaller';
  if not FileExists(UninstallerBin) then
    UninstallerBin := ExtractFilePath(ParamStr(0)) + '../../bgmod-uninstaller';
  if not FileExists(UninstallerBin) then
    UninstallerBin := ExtractFilePath(ParamStr(0)) + 'bgmod-uninstaller';
  AssertTrue('bgmod-uninstaller binary exists for testing', FileExists(UninstallerBin));

  // 3. Execute uninstaller with BGMOD_CONFIG_DIR and BGMOD_BACKUPS_DIR (mirroring GameCardUninstallClick)
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    ExecCmd := 'HOME="' + IsolatedHome + '" XDG_DATA_HOME="' + IsolatedHome + '/.local/share" ' +
      'BGMOD_CONFIG_DIR="' + GameCfgDir + '" ' +
      'BGMOD_BACKUPS_DIR="' + BackupsDir + '" ' +
      'STEAM_COMPAT_INSTALL_PATH="' + GameDir + '" "' +
      UninstallerBin + '" -- 2>/dev/null';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod-uninstaller execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 4. Verify native files were restored to GameDir from BackupsDir
  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(GameDir + 'sl.common.dll');
    AssertEquals('sl.common.dll restored with native content', 'ORIGINAL_NATIVE_SL_COMMON', Trim(FileContent.Text));
    FileContent.LoadFromFile(GameDir + 'sl.interposer.dll');
    AssertEquals('sl.interposer.dll restored with native content', 'ORIGINAL_NATIVE_SL_INTERPOSER', Trim(FileContent.Text));
    FileContent.LoadFromFile(GameDir + 'sl.pcl.dll');
    AssertEquals('sl.pcl.dll restored with native content', 'ORIGINAL_NATIVE_SL_PCL', Trim(FileContent.Text));
  finally
    FileContent.Free;
  end;

  // 5. Verify mod-only files and proxies were removed
  AssertFalse('sl.deepdvc.dll removed on uninstallation', FileExists(GameDir + 'sl.deepdvc.dll'));
  AssertFalse('version.dll removed on uninstallation', FileExists(GameDir + 'version.dll'));
  AssertFalse('goverlay.vars removed on uninstallation', FileExists(GameDir + 'goverlay.vars'));

  // 6. Verify that deleting GameCfgDir after uninstallation completes cleanly
  if DirectoryExists(GameCfgDir) then
    DeleteDirectory(GameCfgDir, False);
  AssertFalse('GameCfgDir deleted after restore', DirectoryExists(GameCfgDir));

  // 7. Test fallback safety: if no backup exists, native host DLLs are NOT deleted
  AssignFile(F, GameDir + 'sl.common.dll'); Rewrite(F); WriteLn(F, 'NATIVE_WITHOUT_BACKUP'); CloseFile(F);
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    ExecCmd := 'HOME="' + IsolatedHome + '" XDG_DATA_HOME="' + IsolatedHome + '/.local/share" ' +
      'STEAM_COMPAT_INSTALL_PATH="' + GameDir + '" "' +
      UninstallerBin + '" -- 2>/dev/null';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod-uninstaller fallback execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  AssertTrue('sl.common.dll preserved even when backup is absent', FileExists(GameDir + 'sl.common.dll'));
end;

procedure TGoverlayGuiTests.TestThirdPartyProxyDllPreservedDuringLaunchAndUninstall;
var
  GameDir, GameCfgDir, OptiStableDir, BgmodBin, UninstallerBin, ExecCmd: string;
  Proc: TProcess;
  FileContent: TStringList;
  F: TextFile;
begin
  GameDir := IsolatedHome + '/games/ProxyPreserveGame/';
  GameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/ProxyPreserveGame/';
  OptiStableDir := IsolatedHome + '/.local/share/goverlay/optiscaler-stable/';
  ForceDirectories(GameDir);
  ForceDirectories(GameCfgDir);
  ForceDirectories(OptiStableDir);

  // 1. Simulate a pre-existing third-party ReShade dxgi.dll in the game folder
  AssignFile(F, GameDir + 'dxgi.dll'); Rewrite(F);
  WriteLn(F, 'RESHADE_6_3_0_DXGI_PAYLOAD_SIZE_123456789');
  CloseFile(F);

  // 2. Seed OptiScaler stable template files
  AssignFile(F, OptiStableDir + 'OptiScaler.dll'); Rewrite(F);
  WriteLn(F, 'OPTISCALER_DLL_ORIGINAL');
  CloseFile(F);
  AssignFile(F, OptiStableDir + 'OptiScaler.ini'); Rewrite(F);
  WriteLn(F, '[OptiScaler]');
  CloseFile(F);
  AssignFile(F, OptiStableDir + 'goverlay.vars'); Rewrite(F);
  WriteLn(F, 'optiscalerversion=0.7.9');
  CloseFile(F);

  // Locate bgmod binary
  BgmodBin := GetCurrentDir + '/bgmod';
  if not FileExists(BgmodBin) then
    BgmodBin := ExtractFilePath(ParamStr(0)) + '../../bgmod';
  if not FileExists(BgmodBin) then
    BgmodBin := ExtractFilePath(ParamStr(0)) + 'bgmod';
  AssertTrue('bgmod binary exists for testing', FileExists(BgmodBin));

  CopyFile(BgmodBin, GameCfgDir + 'bgmod');
  fpChmod(GameCfgDir + 'bgmod', &755);
  CopyFile(BgmodBin, OptiStableDir + 'bgmod');
  fpChmod(OptiStableDir + 'bgmod', &755);
  CopyFile(OptiStableDir + 'goverlay.vars', GameCfgDir + 'goverlay.vars');

  // Locate bgmod-uninstaller binary
  UninstallerBin := GetCurrentDir + '/bgmod-uninstaller';
  if not FileExists(UninstallerBin) then
    UninstallerBin := ExtractFilePath(ParamStr(0)) + '../../bgmod-uninstaller';
  if not FileExists(UninstallerBin) then
    UninstallerBin := ExtractFilePath(ParamStr(0)) + 'bgmod-uninstaller';
  AssertTrue('bgmod-uninstaller binary exists for testing', FileExists(UninstallerBin));
  CopyFile(UninstallerBin, OptiStableDir + 'bgmod-uninstaller');
  fpChmod(OptiStableDir + 'bgmod-uninstaller', &755);

  // 3. Write bgmod.conf with OptiScaler enabled, using d3d12.dll proxy
  AssignFile(F, GameCfgDir + 'bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_MANGOHUD=0');
  WriteLn(F, 'GOVERLAY_VKBASALT=0');
  WriteLn(F, 'GOVERLAY_VKSUMI=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'GOVERLAY_TWEAKS=0');
  WriteLn(F, 'GOVERLAY_LOSSLESS=0');
  WriteLn(F, 'UPSCALER_TYPE=0');
  WriteLn(F, 'OPT_CHANNEL=0');
  WriteLn(F, 'DLL=d3d12.dll');
  WriteLn(F, 'PRESERVE_INI=false');
  CloseFile(F);

  // 4. Run bgmod to perform installation
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    ExecCmd := 'HOME="' + IsolatedHome + '" XDG_DATA_HOME="' + IsolatedHome + '/.local/share" "' +
      GameCfgDir + 'bgmod" /bin/true "' + GameDir + 'Game.exe"';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 5. Verify d3d12.dll was deployed and proxydll=d3d12.dll recorded in goverlay.vars
  AssertTrue('d3d12.dll deployed to GameDir', FileExists(GameDir + 'd3d12.dll'));
  AssertTrue('goverlay.vars deployed to GameDir', FileExists(GameDir + 'goverlay.vars'));

  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(GameDir + 'goverlay.vars');
    AssertTrue('goverlay.vars contains proxydll=d3d12.dll', Pos('proxydll=d3d12.dll', FileContent.Text) > 0);

    // 6. Verify third-party dxgi.dll was NOT deleted and has its original content
    AssertTrue('Third-party dxgi.dll preserved in GameDir during launch', FileExists(GameDir + 'dxgi.dll'));
    FileContent.LoadFromFile(GameDir + 'dxgi.dll');
    AssertEquals('Third-party dxgi.dll content untouched', 'RESHADE_6_3_0_DXGI_PAYLOAD_SIZE_123456789', Trim(FileContent.Text));
  finally
    FileContent.Free;
  end;

  // 7. Run uninstaller to clean up OptiScaler
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := '/bin/sh';
    ExecCmd := 'HOME="' + IsolatedHome + '" XDG_DATA_HOME="' + IsolatedHome + '/.local/share" ' +
      'STEAM_COMPAT_INSTALL_PATH="' + GameDir + '" "' +
      UninstallerBin + '" -- 2>/dev/null';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add(ExecCmd);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod-uninstaller execution exited cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 8. Verify d3d12.dll was removed, but third-party dxgi.dll was preserved
  AssertFalse('d3d12.dll removed on uninstallation', FileExists(GameDir + 'd3d12.dll'));
  AssertTrue('Third-party dxgi.dll preserved after uninstallation', FileExists(GameDir + 'dxgi.dll'));
  FileContent := TStringList.Create;
  try
    FileContent.LoadFromFile(GameDir + 'dxgi.dll');
    AssertEquals('Third-party dxgi.dll content still untouched after uninstallation', 'RESHADE_6_3_0_DXGI_PAYLOAD_SIZE_123456789', Trim(FileContent.Text));
  finally
    FileContent.Free;
  end;
end;

procedure TGoverlayGuiTests.TestOptiscalerAndDlssEnablerToggleKeyDisplay;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;

  AssertEquals('shortcutkeyLabel caption is Optiscaler toggle', 'Optiscaler toggle', goverlayform.shortcutkeyLabel.Caption);
  AssertEquals('dlssenablerToggleLabel caption is DLSS-Enabler toggle', 'DLSS-Enabler toggle', goverlayform.dlssenablerToggleLabel.Caption);
  AssertEquals('dlssenablerToggleBtn caption is ⌨ `', '⌨ `', goverlayform.dlssenablerToggleBtn.Caption);
  AssertFalse('dlssenablerToggleBtn is disabled', goverlayform.dlssenablerToggleBtn.Enabled);

  // When OptiScaler radio button is checked (default)
  goverlayform.optiscalerRadioButton.Checked := True;
  goverlayform.optiscalerRadioButtonClick(nil);
  AssertFalse('dlssenablerToggleLabel hidden when OptiScaler is active', goverlayform.dlssenablerToggleLabel.Visible);
  AssertFalse('dlssenablerToggleBtn hidden when OptiScaler is active', goverlayform.dlssenablerToggleBtn.Visible);

  // When DLSS Enabler radio button is checked
  goverlayform.dlssenablerRadioButton.Checked := True;
  goverlayform.dlssenablerRadioButtonClick(nil);
  AssertTrue('dlssenablerToggleLabel visible when DLSS Enabler is active', goverlayform.dlssenablerToggleLabel.Visible);
  AssertTrue('dlssenablerToggleBtn visible when DLSS Enabler is active', goverlayform.dlssenablerToggleBtn.Visible);

  // When None radio button is checked
  goverlayform.noneUpscalerRadioButton.Checked := True;
  goverlayform.noneUpscalerRadioButtonClick(nil);
  AssertFalse('OptiScaler unchecked when None is selected', goverlayform.optiscalerRadioButton.Checked);
  AssertFalse('DLSS Enabler unchecked when None is selected', goverlayform.dlssenablerRadioButton.Checked);
  AssertTrue('None is checked', goverlayform.noneUpscalerRadioButton.Checked);
  AssertFalse('optversionComboBox disabled when None is selected', goverlayform.optversionComboBox.Enabled);
end;

procedure TGoverlayGuiTests.TestOptiScalerOptionsCardHeightAndNoScroll;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;

  // Exercise reflow with current scroll box width
  goverlayform.ReflowOptiScalerTabNew(goverlayform.FOsScrollBox.ClientWidth);

  // Options card height should be reduced from previous 410px and fit comfortably
  AssertTrue('FOsOptionsCard height is reduced (< 410)', goverlayform.FOsOptionsCard.Height < 410);
  AssertTrue('FOsOptionsCard height accommodates controls (>= 290)', goverlayform.FOsOptionsCard.Height >= 290);

  // Total background height should not exceed scroll box client height at standard size
  AssertTrue('FOsBgPanel height does not exceed FOsScrollBox client height',
    goverlayform.FOsBgPanel.Height <= goverlayform.FOsScrollBox.ClientHeight);

  // Software status card bottom must be fully within client height (no vertical scroll needed)
  AssertTrue('FOsStatusCard fits within FOsScrollBox client height without vertical scrolling',
    goverlayform.FOsStatusCard.Top + goverlayform.FOsStatusCard.Height <= goverlayform.FOsScrollBox.ClientHeight);
end;

// ────────────────────────── MangoHud tabs - full coverage ──────────────────────────

procedure TGoverlayGuiTests.NavigateMangoHud;
begin
  AssertTrue('mangohudLabel.OnClick is bound', Assigned(goverlayform.mangohudLabel.OnClick));
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
end;

function TGoverlayGuiTests.MangoConfPath: string;
begin
  Result := IsolatedHome + '/.local/share/goverlay/gameconfig/global/MangoHud.conf';
end;

procedure TGoverlayGuiTests.SaveMango;
begin
  // saveBitBtn routes by active page; sub-tab switches (visual/metrics/...)
  // only reflow, they never reload config, so no re-navigation is needed.
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
end;

procedure TGoverlayGuiTests.CycleBtnUntilImage(ABtn: TBitBtn; AImageIndex, AMaxClicks: Integer);
var
  i: Integer;
begin
  for i := 1 to AMaxClicks do
  begin
    if ABtn.ImageIndex = AImageIndex then Exit;
    AssertTrue('button bound: ' + ABtn.Name, Assigned(ABtn.OnClick));
    ABtn.OnClick(ABtn);
  end;
  AssertEquals(Format('button %s reached image index', [ABtn.Name]),
    AImageIndex, ABtn.ImageIndex);
end;

procedure TGoverlayGuiTests.CycleBtnUntilTag(ABtn: TBitBtn; ATag, AMaxClicks: Integer);
var
  i: Integer;
begin
  for i := 1 to AMaxClicks do
  begin
    if ABtn.Tag = ATag then Exit;
    AssertTrue('button bound: ' + ABtn.Name, Assigned(ABtn.OnClick));
    ABtn.OnClick(ABtn);
  end;
  AssertEquals(Format('button %s reached tag', [ABtn.Name]), ATag, ABtn.Tag);
end;

procedure TGoverlayGuiTests.TestMangoNavigateAndPreset;
begin
  NavigateMangoHud;
  AssertTrue('preset tab active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.presetTabSheet);
  AssertTrue('visual tab visible', goverlayform.visualTabSheet.TabVisible);
  AssertTrue('performance tab visible', goverlayform.performanceTabSheet.TabVisible);
  AssertTrue('metrics tab visible', goverlayform.metricsTabSheet.TabVisible);
  AssertTrue('extras tab visible', goverlayform.extrasTabSheet.TabVisible);

  // Full preset enables a broad set of metrics controls
  AssertTrue('fullBitBtn bound', Assigned(goverlayform.fullBitBtn.OnClick));
  goverlayform.fullBitBtn.OnClick(goverlayform.fullBitBtn);
  AssertTrue('full preset checks fps', goverlayform.fpsCheckBox.Checked);
  AssertTrue('full preset checks gpu load', goverlayform.gpuavgloadCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestMangoVisualTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.visualTabSheet;

  goverlayform.hudtitleEdit.Text := 'TestHUD';
  goverlayform.horizontalRadioButton.Checked := True;
  goverlayform.transpTrackBar.Position := 6;
  goverlayform.roundRadioButton.Checked := True;
  goverlayform.hudbackgroundColorButton.ButtonColor := $112233;
  goverlayform.fontsizeTrackBar.Position := 25;
  goverlayform.fontColorButton.ButtonColor := $00FF0000; // R=0,G=0,B=$FF
  goverlayform.toprightRadioButton.Checked := True;
  goverlayform.offsetxSpinEdit.Value := 12;
  goverlayform.offsetySpinEdit.Value := 7;
  goverlayform.hudonoffComboBox.Text := 'Shift_R+F12';
  goverlayform.hidehudCheckBox.Checked := True;
  goverlayform.hudcompactCheckBox.Checked := True;
  goverlayform.horizontalstrechCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('custom_text_center', Pos('custom_text_center=TestHUD', C) > 0);
  AssertTrue('horizontal', Pos('horizontal', C) > 0);
  AssertTrue('background_alpha=0.6', Pos('background_alpha=0.6', C) > 0);
  AssertTrue('round_corners=10', Pos('round_corners=10', C) > 0);
  AssertTrue('background_color hex', Pos('background_color=332211', C) > 0);
  AssertTrue('font_size=25', Pos('font_size=25', C) > 0);
  AssertTrue('text_color hex', Pos('text_color=0000FF', C) > 0);
  AssertTrue('position=top-right', Pos('position=top-right', C) > 0);
  AssertTrue('offset_x=12', Pos('offset_x=12', C) > 0);
  AssertTrue('offset_y=7', Pos('offset_y=7', C) > 0);
  AssertTrue('toggle_hud key', Pos('toggle_hud=Shift_R+F12', C) > 0);
  AssertTrue('no_display', Pos('no_display', C) > 0);
  AssertTrue('hud_compact', Pos('hud_compact', C) > 0);
  AssertTrue('horizontal_stretch=0', Pos('horizontal_stretch=0', C) > 0);
  AssertTrue('table_columns written', Pos('table_columns=', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertEquals('hudtitleEdit reloaded', 'TestHUD', goverlayform.hudtitleEdit.Text);
  AssertTrue('horizontalRadioButton reloaded', goverlayform.horizontalRadioButton.Checked);
  AssertEquals('transpTrackBar reloaded', 6, goverlayform.transpTrackBar.Position);
  AssertTrue('roundRadioButton reloaded', goverlayform.roundRadioButton.Checked);
  AssertEquals('hudbackgroundColorButton reloaded', TColor($112233), TColor(goverlayform.hudbackgroundColorButton.ButtonColor));
  AssertEquals('fontsizeTrackBar reloaded', 25, goverlayform.fontsizeTrackBar.Position);
  AssertEquals('fontColorButton reloaded', TColor($00FF0000), TColor(goverlayform.fontColorButton.ButtonColor));
  AssertTrue('toprightRadioButton reloaded', goverlayform.toprightRadioButton.Checked);
  AssertEquals('offsetxSpinEdit reloaded', 12, goverlayform.offsetxSpinEdit.Value);
  AssertEquals('offsetySpinEdit reloaded', 7, goverlayform.offsetySpinEdit.Value);
  AssertEquals('hudonoffComboBox reloaded', 'Shift_R+F12', goverlayform.hudonoffComboBox.Text);
  AssertTrue('hidehudCheckBox reloaded', goverlayform.hidehudCheckBox.Checked);
  AssertTrue('hudcompactCheckBox reloaded', goverlayform.hudcompactCheckBox.Checked);
  AssertTrue('horizontalstrechCheckBox reloaded', goverlayform.horizontalstrechCheckBox.Checked);
  AssertEquals('alphavalueLabel color', TColor(CLR_TEXT_ACCENT), TColor(goverlayform.alphavalueLabel.Font.Color));
  AssertTrue('alphavalueLabel bold', fsBold in goverlayform.alphavalueLabel.Font.Style);
  AssertEquals('fontsizevalueLabel color', TColor(CLR_TEXT_ACCENT), TColor(goverlayform.fontsizevalueLabel.Font.Color));
  AssertTrue('fontsizevalueLabel bold', fsBold in goverlayform.fontsizevalueLabel.Font.Style);

  // Reverse direction
  goverlayform.hudtitleEdit.Text := '';
  goverlayform.verticalRadioButton.Checked := True;
  goverlayform.squareRadioButton.Checked := True; // radio groups uncheck via the sibling
  goverlayform.offsetxSpinEdit.Value := 0;
  goverlayform.hidehudCheckBox.Checked := False;
  goverlayform.bottomleftRadioButton.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('custom_text_center gone', Pos('custom_text_center=', C) = 0);
  AssertTrue('horizontal gone', Pos(#10'horizontal'#10, C) = 0);
  AssertTrue('round_corners=0', Pos('round_corners=0', C) > 0);
  AssertTrue('offset_x gone', Pos('offset_x=', C) = 0);
  AssertTrue('no_display gone', Pos('no_display', C) = 0);
  AssertTrue('position=bottom-left', Pos('position=bottom-left', C) > 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsGpuTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.gpunameEdit.Text := 'MyGPU';
  goverlayform.gpuavgloadCheckBox.Checked := True;
  goverlayform.gpuColorButton.ButtonColor := $00112233;
  goverlayform.gpuloadcolorCheckBox.Checked := True;
  goverlayform.vramusageCheckBox.Checked := True;
  goverlayform.vramColorButton.ButtonColor := $00ABCDEF;
  goverlayform.gpufreqCheckBox.Checked := True;
  goverlayform.gpumemfreqCheckBox.Checked := True;
  goverlayform.gputempCheckBox.Checked := True;
  goverlayform.gpumemtempCheckBox.Checked := True;
  goverlayform.gpujunctempCheckBox.Checked := True;
  goverlayform.gpufanCheckBox.Checked := True;
  goverlayform.gpupowerCheckBox.Checked := True;
  goverlayform.gpupowerlimitCheckBox.Checked := True;
  goverlayform.gpuefficiencyCheckBox.Checked := True;
  goverlayform.gpuvoltageCheckBox.Checked := True;
  goverlayform.gputhrottlingCheckBox.Checked := True;
  goverlayform.gputhrottlinggraphCheckBox.Checked := True;
  goverlayform.gpumodelCheckBox.Checked := True;
  goverlayform.vulkandriverCheckBox.Checked := True;
  CycleBtnUntilTag(goverlayform.gpuframesjouleBitBtn, TAG_JOULES_PER_FRAME, 3);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('gpu_text', Pos('gpu_text=MyGPU', C) > 0);
  AssertTrue('gpu_stats', Pos('gpu_stats', C) > 0);
  AssertTrue('gpu_color hex', Pos('gpu_color=332211', C) > 0);
  AssertTrue('gpu_load_change', Pos('gpu_load_change', C) > 0);
  AssertTrue('gpu_load_color', Pos('gpu_load_color=', C) > 0);
  AssertTrue('vram', Pos('vram', C) > 0);
  AssertTrue('vram_color hex', Pos('vram_color=EFCDAB', C) > 0);
  AssertTrue('gpu_core_clock', Pos('gpu_core_clock', C) > 0);
  AssertTrue('gpu_mem_clock', Pos('gpu_mem_clock', C) > 0);
  AssertTrue('gpu_temp', Pos('gpu_temp', C) > 0);
  AssertTrue('gpu_mem_temp', Pos('gpu_mem_temp', C) > 0);
  AssertTrue('gpu_junction_temp', Pos('gpu_junction_temp', C) > 0);
  AssertTrue('gpu_fan', Pos('gpu_fan', C) > 0);
  AssertTrue('gpu_power', Pos('gpu_power', C) > 0);
  AssertTrue('gpu_power_limit', Pos('gpu_power_limit', C) > 0);
  AssertTrue('gpu_efficiency', Pos('gpu_efficiency', C) > 0);
  AssertTrue('gpu_voltage', Pos('gpu_voltage', C) > 0);
  AssertTrue('throttling_status', Pos('throttling_status', C) > 0);
  AssertTrue('throttling_status_graph', Pos('throttling_status_graph', C) > 0);
  AssertTrue('gpu_name', Pos('gpu_name', C) > 0);
  AssertTrue('vulkan_driver', Pos('vulkan_driver', C) > 0);
  AssertTrue('flip_efficiency (Joules/Frame state)', Pos('flip_efficiency', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertEquals('gpunameEdit reloaded', 'MyGPU', goverlayform.gpunameEdit.Text);
  AssertTrue('gpuavgloadCheckBox reloaded', goverlayform.gpuavgloadCheckBox.Checked);
  AssertEquals('gpuColorButton reloaded', TColor($00112233), TColor(goverlayform.gpuColorButton.ButtonColor));
  AssertTrue('gpuloadcolorCheckBox reloaded', goverlayform.gpuloadcolorCheckBox.Checked);
  AssertTrue('vramusageCheckBox reloaded', goverlayform.vramusageCheckBox.Checked);
  AssertEquals('vramColorButton reloaded', TColor($00ABCDEF), TColor(goverlayform.vramColorButton.ButtonColor));
  AssertTrue('gpufreqCheckBox reloaded', goverlayform.gpufreqCheckBox.Checked);
  AssertTrue('gpumemfreqCheckBox reloaded', goverlayform.gpumemfreqCheckBox.Checked);
  AssertTrue('gputempCheckBox reloaded', goverlayform.gputempCheckBox.Checked);
  AssertTrue('gpumemtempCheckBox reloaded', goverlayform.gpumemtempCheckBox.Checked);
  AssertTrue('gpujunctempCheckBox reloaded', goverlayform.gpujunctempCheckBox.Checked);
  AssertTrue('gpufanCheckBox reloaded', goverlayform.gpufanCheckBox.Checked);
  AssertTrue('gpupowerCheckBox reloaded', goverlayform.gpupowerCheckBox.Checked);
  AssertTrue('gpupowerlimitCheckBox reloaded', goverlayform.gpupowerlimitCheckBox.Checked);
  AssertTrue('gpuefficiencyCheckBox reloaded', goverlayform.gpuefficiencyCheckBox.Checked);
  AssertTrue('gpuvoltageCheckBox reloaded', goverlayform.gpuvoltageCheckBox.Checked);
  AssertTrue('gputhrottlingCheckBox reloaded', goverlayform.gputhrottlingCheckBox.Checked);
  AssertTrue('gputhrottlinggraphCheckBox reloaded', goverlayform.gputhrottlinggraphCheckBox.Checked);
  AssertTrue('gpumodelCheckBox reloaded', goverlayform.gpumodelCheckBox.Checked);
  AssertTrue('vulkandriverCheckBox reloaded', goverlayform.vulkandriverCheckBox.Checked);
  AssertEquals('gpuframesjouleBitBtn reloaded', TAG_JOULES_PER_FRAME, goverlayform.gpuframesjouleBitBtn.Tag);

  // Saving straight after the reload must still produce the same option: the
  // control being back in position is only half of it, the writer has to see
  // that position too.
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('flip_efficiency survives reload and save', Pos('flip_efficiency', C) > 0);

  // Reverse
  goverlayform.gpuavgloadCheckBox.Checked := False;
  goverlayform.vramusageCheckBox.Checked := False;
  goverlayform.gputempCheckBox.Checked := False;
  CycleBtnUntilTag(goverlayform.gpuframesjouleBitBtn, TAG_FRAMES_PER_JOULE, 3);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('gpu_stats gone', Pos('gpu_stats', C) = 0);
  AssertTrue('vram line gone', Pos(#10'vram'#10, C) = 0);
  AssertTrue('vram_color gone', Pos('vram_color', C) = 0);
  AssertTrue('gpu_temp gone', Pos('gpu_temp', C) = 0);
  AssertTrue('flip_efficiency gone', Pos('flip_efficiency', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsCpuTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.cpunameEdit.Text := 'MyCPU';
  goverlayform.cpuavgloadCheckBox.Checked := True;
  goverlayform.cpuColorButton.ButtonColor := $000000FF;
  goverlayform.cpuloadcoreCheckBox.Checked := True;
  CycleBtnUntilImage(goverlayform.coreloadtypeBitBtn, IMG_CORELOAD_GRAPH, 4);
  goverlayform.cpuloadcolorCheckBox.Checked := True;
  goverlayform.cpufreqCheckBox.Checked := True;
  goverlayform.cputempCheckBox.Checked := True;
  goverlayform.cpupowerCheckBox.Checked := True;
  goverlayform.cpuefficiencyCheckBox.Checked := True;
  goverlayform.cpucoretypeCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('cpu_text', Pos('cpu_text=MyCPU', C) > 0);
  AssertTrue('cpu_stats', Pos('cpu_stats', C) > 0);
  AssertTrue('cpu_color hex', Pos('cpu_color=FF0000', C) > 0);
  AssertTrue('core_load', Pos('core_load', C) > 0);
  AssertTrue('core_bars (Graph state)', Pos('core_bars', C) > 0);
  AssertTrue('cpu_load_change', Pos('cpu_load_change', C) > 0);
  AssertTrue('cpu_load_color', Pos('cpu_load_color=', C) > 0);
  AssertTrue('cpu_mhz', Pos('cpu_mhz', C) > 0);
  AssertTrue('cpu_temp', Pos('cpu_temp', C) > 0);
  AssertTrue('cpu_power', Pos('cpu_power', C) > 0);
  AssertTrue('cpu_efficiency', Pos('cpu_efficiency', C) > 0);
  AssertTrue('core_type', Pos('core_type', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertEquals('cpunameEdit reloaded', 'MyCPU', goverlayform.cpunameEdit.Text);
  AssertTrue('cpuavgloadCheckBox reloaded', goverlayform.cpuavgloadCheckBox.Checked);
  AssertEquals('cpuColorButton reloaded', TColor($000000FF), TColor(goverlayform.cpuColorButton.ButtonColor));
  AssertTrue('cpuloadcoreCheckBox reloaded', goverlayform.cpuloadcoreCheckBox.Checked);
  AssertEquals('coreloadtypeBitBtn reloaded', IMG_CORELOAD_GRAPH, goverlayform.coreloadtypeBitBtn.ImageIndex);
  AssertTrue('cpuloadcolorCheckBox reloaded', goverlayform.cpuloadcolorCheckBox.Checked);
  AssertTrue('cpufreqCheckBox reloaded', goverlayform.cpufreqCheckBox.Checked);
  AssertTrue('cputempCheckBox reloaded', goverlayform.cputempCheckBox.Checked);
  AssertTrue('cpupowerCheckBox reloaded', goverlayform.cpupowerCheckBox.Checked);
  AssertTrue('cpuefficiencyCheckBox reloaded', goverlayform.cpuefficiencyCheckBox.Checked);
  AssertTrue('cpucoretypeCheckBox reloaded', goverlayform.cpucoretypeCheckBox.Checked);

  // Saving straight after the reload must still produce the same option.
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('core_bars survives reload and save', Pos('core_bars', C) > 0);

  // Reverse
  goverlayform.cpuloadcoreCheckBox.Checked := False;
  goverlayform.cpufreqCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('core_load gone', Pos('core_load', C) = 0);
  AssertTrue('cpu_mhz gone', Pos('cpu_mhz', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsMemIoTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.diskioCheckBox.Checked := True;
  goverlayform.iordrwColorButton.ButtonColor := $0010FF10;
  goverlayform.swapusageCheckBox.Checked := True;
  goverlayform.ramusageCheckBox.Checked := True;
  goverlayform.ramColorButton.ButtonColor := $00FF10FF;
  goverlayform.ramtempCheckBox.Checked := True;
  goverlayform.procmemCheckBox.Checked := True;
  goverlayform.procvramCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('io_read', Pos('io_read', C) > 0);
  AssertTrue('io_write', Pos('io_write', C) > 0);
  AssertTrue('io_color hex', Pos('io_color=10FF10', C) > 0);
  AssertTrue('swap', Pos('swap', C) > 0);
  AssertTrue('ram', Pos('ram', C) > 0);
  AssertTrue('ram_color hex', Pos('ram_color=FF10FF', C) > 0);
  AssertTrue('ram_temp', Pos('ram_temp', C) > 0);
  AssertTrue('procmem', Pos('procmem', C) > 0);
  AssertTrue('proc_vram', Pos('proc_vram', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertTrue('diskioCheckBox reloaded', goverlayform.diskioCheckBox.Checked);
  AssertEquals('iordrwColorButton reloaded', TColor($0010FF10), TColor(goverlayform.iordrwColorButton.ButtonColor));
  AssertTrue('swapusageCheckBox reloaded', goverlayform.swapusageCheckBox.Checked);
  AssertTrue('ramusageCheckBox reloaded', goverlayform.ramusageCheckBox.Checked);
  AssertEquals('ramColorButton reloaded', TColor($00FF10FF), TColor(goverlayform.ramColorButton.ButtonColor));
  AssertTrue('ramtempCheckBox reloaded', goverlayform.ramtempCheckBox.Checked);
  AssertTrue('procmemCheckBox reloaded', goverlayform.procmemCheckBox.Checked);
  AssertTrue('procvramCheckBox reloaded', goverlayform.procvramCheckBox.Checked);

  // Reverse
  goverlayform.diskioCheckBox.Checked := False;
  goverlayform.ramusageCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('io_read gone', Pos('io_read', C) = 0);
  AssertTrue('ram line gone', Pos(#10'ram'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoMetricsOtherTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;

  goverlayform.batteryCheckBox.Checked := True;
  goverlayform.batteryColorButton.ButtonColor := $00333333;
  goverlayform.batterywattCheckBox.Checked := True;
  goverlayform.batterytimeCheckBox.Checked := True;
  goverlayform.deviceCheckBox.Checked := True;
  goverlayform.fpsCheckBox.Checked := True;
  goverlayform.fpsavgCheckBox.Checked := True;
  CycleBtnUntilImage(goverlayform.fpsavgBitBtn, IMG_FPSAVG_1PCT_LOW, 4);
  goverlayform.frametimegraphCheckBox.Checked := True;
  goverlayform.frametimegraphColorButton.ButtonColor := $00444444;
  CycleBtnUntilImage(goverlayform.frametimetypeBitBtn, IMG_FRAMETIME_HISTOGRAM, 4);
  goverlayform.framecountCheckBox.Checked := True;
  goverlayform.engineversionCheckBox.Checked := True;
  goverlayform.engineColorButton.ButtonColor := $00555555;
  goverlayform.engineshortCheckBox.Checked := True;
  goverlayform.archCheckBox.Checked := True;
  goverlayform.wineCheckBox.Checked := True;
  goverlayform.wineColorButton.ButtonColor := $00666666;
  goverlayform.winesyncCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('battery', Pos('battery', C) > 0);
  AssertTrue('battery_color hex', Pos('battery_color=333333', C) > 0);
  AssertTrue('battery_watt', Pos('battery_watt', C) > 0);
  AssertTrue('battery_time', Pos('battery_time', C) > 0);
  AssertTrue('device_battery=gamepad', Pos('device_battery=gamepad', C) > 0);
  AssertTrue('device_battery_icon', Pos('device_battery_icon', C) > 0);
  AssertTrue('fps', Pos('fps', C) > 0);
  AssertTrue('fps_metrics 1% low', Pos('fps_metrics=avg,0.01', C) > 0);
  AssertTrue('frame_timing', Pos('frame_timing', C) > 0);
  AssertTrue('frametime_color hex', Pos('frametime_color=444444', C) > 0);
  AssertTrue('histogram', Pos('histogram', C) > 0);
  AssertTrue('frame_count', Pos('frame_count', C) > 0);
  AssertTrue('engine_version', Pos('engine_version', C) > 0);
  AssertTrue('engine_color hex (always written)', Pos('engine_color=555555', C) > 0);
  AssertTrue('engine_short_names', Pos('engine_short_names', C) > 0);
  AssertTrue('arch', Pos('arch', C) > 0);
  AssertTrue('wine', Pos('wine', C) > 0);
  AssertTrue('wine_color hex', Pos('wine_color=666666', C) > 0);
  AssertTrue('winesync', Pos('winesync', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertTrue('batteryCheckBox reloaded', goverlayform.batteryCheckBox.Checked);
  AssertEquals('batteryColorButton reloaded', TColor($00333333), TColor(goverlayform.batteryColorButton.ButtonColor));
  AssertTrue('batterywattCheckBox reloaded', goverlayform.batterywattCheckBox.Checked);
  AssertTrue('batterytimeCheckBox reloaded', goverlayform.batterytimeCheckBox.Checked);
  AssertTrue('deviceCheckBox reloaded', goverlayform.deviceCheckBox.Checked);
  AssertTrue('fpsCheckBox reloaded', goverlayform.fpsCheckBox.Checked);
  AssertTrue('fpsavgCheckBox reloaded', goverlayform.fpsavgCheckBox.Checked);
  AssertTrue('frametimegraphCheckBox reloaded', goverlayform.frametimegraphCheckBox.Checked);
  AssertEquals('frametimegraphColorButton reloaded', TColor($00444444), TColor(goverlayform.frametimegraphColorButton.ButtonColor));
  AssertEquals('frametimetypeBitBtn reloaded', IMG_FRAMETIME_HISTOGRAM, goverlayform.frametimetypeBitBtn.ImageIndex);
  AssertTrue('framecountCheckBox reloaded', goverlayform.framecountCheckBox.Checked);
  AssertTrue('engineversionCheckBox reloaded', goverlayform.engineversionCheckBox.Checked);
  AssertEquals('engineColorButton reloaded', TColor($00555555), TColor(goverlayform.engineColorButton.ButtonColor));
  AssertTrue('engineshortCheckBox reloaded', goverlayform.engineshortCheckBox.Checked);
  AssertTrue('archCheckBox reloaded', goverlayform.archCheckBox.Checked);
  AssertTrue('wineCheckBox reloaded', goverlayform.wineCheckBox.Checked);
  AssertEquals('wineColorButton reloaded', TColor($00666666), TColor(goverlayform.wineColorButton.ButtonColor));
  AssertTrue('winesyncCheckBox reloaded', goverlayform.winesyncCheckBox.Checked);

  // Saving straight after the reload must still produce the same options.
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('fps_metrics 1% low survives reload and save', Pos('fps_metrics=avg,0.01', C) > 0);
  AssertTrue('histogram survives reload and save', Pos('histogram', C) > 0);

  // Reverse: 0.1% low variant writes the other fps_metrics form
  CycleBtnUntilImage(goverlayform.fpsavgBitBtn, IMG_FPSAVG_01PCT_LOW, 4);
  goverlayform.fpsCheckBox.Checked := False;
  goverlayform.wineCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('fps_metrics 0.1% low variant', Pos('fps_metrics=avg,0.001', C) > 0);
  AssertTrue('fps line gone', Pos(#10'fps'#10, C) = 0);
  AssertTrue('wine line gone', Pos(#10'wine'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoPerformanceTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.performanceTabSheet;

  goverlayform.showfpslimCheckBox.Checked := True;
  goverlayform.fpslimmetComboBox.ItemIndex := 1; // early
  goverlayform.fpslimtoggleComboBox.Text := 'Home';
  goverlayform.FFpsLimitEdit.Text := '120';
  goverlayform.resolutionCheckBox.Checked := True;
  goverlayform.refreshrateCheckBox.Checked := True;
  goverlayform.fcatCheckBox.Checked := True;
  goverlayform.fexstatsCheckBox.Checked := True;
  goverlayform.fsrCheckBox.Checked := True;
  goverlayform.hdrCheckBox.Checked := True;
  goverlayform.vpsCheckBox.Checked := True;
  goverlayform.fahrenheitCheckBox.Checked := True;
  goverlayform.gamemodestatusCheckBox.Checked := True;
  goverlayform.vkbasaltstatusCheckBox.Checked := True;
  goverlayform.vsyncComboBox.ItemIndex := 2;
  goverlayform.glvsyncComboBox.ItemIndex := 2; // literal 'n'
  goverlayform.filterRadioGroup.ItemIndex := 1; // bicubic
  goverlayform.afTrackBar.Position := 4;
  goverlayform.mipmapTrackBar.Position := 2;
  goverlayform.fpscolorCheckBox.Checked := True;
  goverlayform.fpscolor2SpinEdit.Value := 45;
  goverlayform.fpscolor3SpinEdit.Value := 90;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('show_fps_limit', Pos('show_fps_limit', C) > 0);
  AssertTrue('fps_limit_method=early', Pos('fps_limit_method=early', C) > 0);
  AssertTrue('toggle_fps_limit=Home', Pos('toggle_fps_limit=Home', C) > 0);
  AssertTrue('fps_limit=120', Pos('fps_limit=120', C) > 0);
  AssertTrue('resolution', Pos('resolution', C) > 0);
  AssertTrue('refresh_rate', Pos('refresh_rate', C) > 0);
  AssertTrue('fcat', Pos('fcat', C) > 0);
  AssertTrue('fex_stats', Pos('fex_stats', C) > 0);
  AssertTrue('fsr', Pos('fsr', C) > 0);
  AssertTrue('hdr', Pos('hdr', C) > 0);
  AssertTrue('present_mode', Pos('present_mode', C) > 0);
  AssertTrue('temp_fahrenheit', Pos('temp_fahrenheit', C) > 0);
  AssertTrue('gamemode', Pos('gamemode', C) > 0);
  AssertTrue('vkbasalt', Pos('vkbasalt', C) > 0);
  AssertTrue('vsync=2', Pos('vsync=2', C) > 0);
  AssertTrue('gl_vsync=n literal', Pos('gl_vsync=n', C) > 0);
  AssertTrue('bicubic', Pos('bicubic', C) > 0);
  AssertTrue('af=4', Pos('af=4', C) > 0);
  AssertTrue('picmip=2', Pos('picmip=2', C) > 0);
  AssertTrue('fps_color_change', Pos('fps_color_change', C) > 0);
  // Custom FPS color thresholds are preserved independently from fps limit edit
  AssertTrue('fps_value=45,90', Pos('fps_value=45,90', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertTrue('showfpslimCheckBox reloaded', goverlayform.showfpslimCheckBox.Checked);
  AssertEquals('fpslimmetComboBox reloaded', 1, goverlayform.fpslimmetComboBox.ItemIndex);
  AssertEquals('fpslimtoggleComboBox reloaded', 'Home', goverlayform.fpslimtoggleComboBox.Text);
  AssertEquals('FFpsLimitEdit reloaded', '120', goverlayform.FFpsLimitEdit.Text);
  AssertTrue('resolutionCheckBox reloaded', goverlayform.resolutionCheckBox.Checked);
  AssertTrue('refreshrateCheckBox reloaded', goverlayform.refreshrateCheckBox.Checked);
  AssertTrue('fcatCheckBox reloaded', goverlayform.fcatCheckBox.Checked);
  AssertTrue('fexstatsCheckBox reloaded', goverlayform.fexstatsCheckBox.Checked);
  AssertTrue('fsrCheckBox reloaded', goverlayform.fsrCheckBox.Checked);
  AssertTrue('hdrCheckBox reloaded', goverlayform.hdrCheckBox.Checked);
  AssertTrue('vpsCheckBox reloaded', goverlayform.vpsCheckBox.Checked);
  AssertTrue('fahrenheitCheckBox reloaded', goverlayform.fahrenheitCheckBox.Checked);
  AssertTrue('gamemodestatusCheckBox reloaded', goverlayform.gamemodestatusCheckBox.Checked);
  AssertTrue('vkbasaltstatusCheckBox reloaded', goverlayform.vkbasaltstatusCheckBox.Checked);
  AssertEquals('vsyncComboBox reloaded', 2, goverlayform.vsyncComboBox.ItemIndex);
  AssertEquals('glvsyncComboBox reloaded', 2, goverlayform.glvsyncComboBox.ItemIndex);
  AssertTrue('vsyncComboBox hint corrected 0=Adaptive', Pos('0 = Adaptive', goverlayform.vsyncComboBox.Hint) > 0);
  AssertTrue('vsyncComboBox hint corrected 1=Off', Pos('1 = Off', goverlayform.vsyncComboBox.Hint) > 0);
  AssertTrue('vsyncComboBox hint corrected 3=On', Pos('3 = On', goverlayform.vsyncComboBox.Hint) > 0);
  AssertEquals('filterRadioGroup reloaded', 1, goverlayform.filterRadioGroup.ItemIndex);
  AssertEquals('afTrackBar reloaded', 4, goverlayform.afTrackBar.Position);
  AssertEquals('mipmapTrackBar reloaded', 2, goverlayform.mipmapTrackBar.Position);
  AssertTrue('fpscolorCheckBox reloaded', goverlayform.fpscolorCheckBox.Checked);
  AssertEquals('fpscolor2SpinEdit reloaded', 45, goverlayform.fpscolor2SpinEdit.Value);
  AssertEquals('fpscolor3SpinEdit reloaded', 90, goverlayform.fpscolor3SpinEdit.Value);
  AssertEquals('fpscolor2SpinEdit Increment is 1', 1, goverlayform.fpscolor2SpinEdit.Increment);
  AssertEquals('fpscolor3SpinEdit Increment is 1', 1, goverlayform.fpscolor3SpinEdit.Increment);

  // Reverse
  goverlayform.fpslimmetComboBox.ItemIndex := 0; // late
  goverlayform.FFpsLimitEdit.Text := '';
  goverlayform.filterRadioGroup.ItemIndex := 3; // retro
  goverlayform.afTrackBar.Position := 0;
  goverlayform.fsrCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('fps_limit_method=late', Pos('fps_limit_method=late', C) > 0);
  AssertTrue('fps_limit=0 fallback', Pos('fps_limit=0', C) > 0);
  AssertTrue('retro', Pos('retro', C) > 0);
  AssertTrue('bicubic gone', Pos('bicubic', C) = 0);
  AssertTrue('af gone at 0', Pos('af=', C) = 0);
  AssertTrue('fsr line gone', Pos(#10'fsr'#10, C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoExtrasTab;
var
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.extrasTabSheet;

  goverlayform.distroinfoCheckBox.Checked := True;
  goverlayform.displayserverCheckBox.Checked := True;
  goverlayform.timeCheckBox.Checked := True;
  goverlayform.hudversionCheckBox.Checked := True;
  goverlayform.mediaCheckBox.Checked := True;
  goverlayform.mediaColorButton.ButtonColor := $00777777;
  goverlayform.networkCheckBox.Checked := True;
  if goverlayform.networkComboBox.Items.Count > 0 then
    goverlayform.networkComboBox.ItemIndex := 0;
  goverlayform.logfolderEdit.Text := '/tmp/testlogs';
  goverlayform.durationTrackBar.Position := 10;
  goverlayform.delayTrackBar.Position := 5;
  goverlayform.intervalTrackBar.Position := 100;
  goverlayform.logtoggleComboBox.Text := 'Shift_L+F10';
  goverlayform.versioningCheckBox.Checked := True;
  goverlayform.autouploadCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('distro custom_text', Pos('custom_text=-', C) > 0);
  AssertTrue('distro exec uname', Pos('exec=uname -r', C) > 0);
  AssertTrue('display_server', Pos('display_server', C) > 0);
  AssertTrue('time', Pos('time', C) > 0);
  AssertTrue('time_no_label', Pos('time_no_label', C) > 0);
  AssertTrue('version# literal', Pos('version#', C) > 0);
  AssertTrue('media_player', Pos('media_player', C) > 0);
  AssertTrue('media_player_color hex', Pos('media_player_color=777777', C) > 0);
  if goverlayform.networkComboBox.Items.Count > 0 then
    AssertTrue('network=<iface>', Pos('network=', C) > 0);
  AssertTrue('output_folder', Pos('output_folder=/tmp/testlogs', C) > 0);
  AssertTrue('log_duration=10', Pos('log_duration=10', C) > 0);
  AssertTrue('autostart_log=5', Pos('autostart_log=5', C) > 0);
  AssertTrue('log_interval=100', Pos('log_interval=100', C) > 0);
  AssertTrue('toggle_logging key', Pos('toggle_logging=Shift_L+F10', C) > 0);
  AssertTrue('log_versioning', Pos('log_versioning', C) > 0);
  AssertTrue('upload_logs', Pos('upload_logs', C) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadMangoHudConfig;
  AssertTrue('distroinfoCheckBox reloaded', goverlayform.distroinfoCheckBox.Checked);
  AssertTrue('displayserverCheckBox reloaded', goverlayform.displayserverCheckBox.Checked);
  AssertTrue('timeCheckBox reloaded', goverlayform.timeCheckBox.Checked);
  AssertTrue('hudversionCheckBox reloaded', goverlayform.hudversionCheckBox.Checked);
  AssertTrue('mediaCheckBox reloaded', goverlayform.mediaCheckBox.Checked);
  AssertEquals('mediaColorButton reloaded', TColor($00777777), TColor(goverlayform.mediaColorButton.ButtonColor));
  if goverlayform.networkComboBox.Items.Count > 0 then
    AssertTrue('networkCheckBox reloaded', goverlayform.networkCheckBox.Checked);
  AssertEquals('logfolderEdit reloaded', '/tmp/testlogs', goverlayform.logfolderEdit.Text);
  AssertEquals('durationTrackBar reloaded', 10, goverlayform.durationTrackBar.Position);
  AssertEquals('delayTrackBar reloaded', 5, goverlayform.delayTrackBar.Position);
  AssertEquals('intervalTrackBar reloaded', 100, goverlayform.intervalTrackBar.Position);
  AssertEquals('logtoggleComboBox reloaded', 'Shift_L+F10', goverlayform.logtoggleComboBox.Text);
  AssertEquals('logtoggleLabel caption is Logging toggle', 'Logging toggle', goverlayform.logtoggleLabel.Caption);
  AssertEquals('customcommandEdit left is aligned with card margin', 11, goverlayform.customcommandEdit.Left);
  AssertFalse('autouploadCheckBox is hidden', goverlayform.autouploadCheckBox.Visible);
  AssertFalse('versioningCheckBox is hidden', goverlayform.versioningCheckBox.Visible);
  AssertTrue('versioningCheckBox reloaded', goverlayform.versioningCheckBox.Checked);
  AssertTrue('autouploadCheckBox reloaded', goverlayform.autouploadCheckBox.Checked);

  // Reverse
  goverlayform.timeCheckBox.Checked := False;
  goverlayform.mediaCheckBox.Checked := False;
  goverlayform.durationTrackBar.Position := 0;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('time line gone', Pos(#10'time'#10, C) = 0);
  AssertTrue('media_player gone', Pos('media_player', C) = 0);
  AssertTrue('log_duration gone at 0', Pos('log_duration=', C) = 0);
end;

procedure TGoverlayGuiTests.TestMangoGlobalSideEffects;
var
  C: string;
begin
  NavigateMangoHud;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  // Blacklist line auto-created with defaults when missing
  AssertTrue('blacklist line present', Pos('blacklist=', C) > 0);
  AssertTrue('blacklist contains zenity default', Pos('zenity', C) > 0);
  // bgmod.conf side-effects (same writer)
  AssertEquals('GOVERLAY_MANGOHUD flag', '1', ReadBgmodConf('Config', 'GOVERLAY_MANGOHUD'));
  AssertTrue('MANGOHUD_CONFIGFILE env points at conf',
    Pos('MangoHud.conf', ReadBgmodConf('Env', 'MANGOHUD_CONFIGFILE')) > 0);
end;

procedure TGoverlayGuiTests.TestMangoSettingsPersistence;
var
  C: string;
begin
  NavigateMangoHud;

  // 1. Vulkan & OpenGL VSYNC = Unset (index 4)
  goverlayform.vsyncComboBox.ItemIndex := 4; // Unset
  goverlayform.glvsyncComboBox.ItemIndex := 4; // Unset

  // 2. FPS Colors
  goverlayform.fpscolorCheckBox.Checked := True;
  goverlayform.fpscolor1ColorButton.ButtonColor := $000000FF; // Red
  goverlayform.fpscolor2ColorButton.ButtonColor := $0000FFFF; // Yellow
  goverlayform.fpscolor3ColorButton.ButtonColor := $0000FF00; // Green
  goverlayform.fpscolor2SpinEdit.Value := 50;
  goverlayform.fpscolor3SpinEdit.Value := 100;

  // 3. GPU Load Colors
  goverlayform.gpuloadcolorCheckBox.Checked := True;
  goverlayform.gpuload1ColorButton.ButtonColor := $0000FF00; // Green
  goverlayform.gpuload2ColorButton.ButtonColor := $0000FFFF; // Yellow
  goverlayform.gpuload3ColorButton.ButtonColor := $000000FF; // Red

  // 4. CPU Load Colors
  goverlayform.cpuloadcolorCheckBox.Checked := True;
  goverlayform.cpuload1ColorButton.ButtonColor := $0000FF00; // Green
  goverlayform.cpuload2ColorButton.ButtonColor := $0000FFFF; // Yellow
  goverlayform.cpuload3ColorButton.ButtonColor := $000000FF; // Red

  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertEquals('gl_vsync omitted when Unset', 0, Pos('gl_vsync=', C));
  AssertEquals('vsync omitted when Unset', 0, Pos('vsync=', C));
  AssertTrue('fps_color written', Pos('fps_color=', C) > 0);
  AssertTrue('fps_value written', Pos('fps_value=50,100', C) > 0);
  AssertTrue('gpu_load_color written', Pos('gpu_load_color=', C) > 0);
  AssertTrue('cpu_load_color written', Pos('cpu_load_color=', C) > 0);

  // Reload config into UI and assert values are restored rather than resetting to defaults
  goverlayform.LoadMangoHudConfig;
  AssertEquals('glvsyncComboBox Unset index preserved', 4, goverlayform.glvsyncComboBox.ItemIndex);
  AssertEquals('fpscolor1 restored', TColor($000000FF), TColor(goverlayform.fpscolor1ColorButton.ButtonColor));
  AssertEquals('fpscolor2SpinEdit restored', 50, goverlayform.fpscolor2SpinEdit.Value);
  AssertEquals('fpscolor3SpinEdit restored', 100, goverlayform.fpscolor3SpinEdit.Value);
  AssertEquals('gpuload1 restored', TColor($0000FF00), TColor(goverlayform.gpuload1ColorButton.ButtonColor));
  AssertEquals('cpuload1 restored', TColor($0000FF00), TColor(goverlayform.cpuload1ColorButton.ButtonColor));
end;

procedure TGoverlayGuiTests.TestTabSwitchingPersistence;
begin
  NavigateMangoHud;

  // Set non-default custom settings in MangoHud
  goverlayform.hudtitleEdit.Text := 'TabSwitchTest';
  goverlayform.glvsyncComboBox.ItemIndex := 4; // Unset
  goverlayform.fpscolorCheckBox.Checked := True;
  goverlayform.fpscolor1ColorButton.ButtonColor := $00112233;
  SaveMango;

  // Navigate away to OptiScaler tab (triggers sidebar tab click)
  NavigateOptiScalerTab;
  AssertTrue('OptiScaler tab active', goverlayform.goverlayPageControl.ActivePage = goverlayform.optiscalerTabSheet);

  // Navigate back to MangoHud tab (triggers sidebar tab click which calls LoadMangoHudConfig)
  NavigateMangoHud;

  // Assert controls retained saved state after tab navigation
  AssertEquals('hudtitleEdit persisted across tab switch', 'TabSwitchTest', goverlayform.hudtitleEdit.Text);
  AssertEquals('glvsyncComboBox persisted across tab switch', 4, goverlayform.glvsyncComboBox.ItemIndex);
  AssertEquals('fpscolor1 persisted across tab switch', TColor($00112233), TColor(goverlayform.fpscolor1ColorButton.ButtonColor));
end;

procedure TGoverlayGuiTests.TestVkBasaltRoundTrip;
var
  ConfPath, Content: string;
begin
  NavigateVkBasaltTab;
  ConfPath := IsolatedHome + '/.config/vkBasalt/vkBasalt.conf';

  goverlayform.casTrackBar.Position := 8;
  goverlayform.fxaaTrackBar.Position := 4;
  goverlayform.smaaTrackBar.Position := 2;
  goverlayform.dlsTrackBar.Position := 6;
  goverlayform.vkbtogglekeyCombobox.Text := 'Home';

  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);

  // Assert single-instance effects line and absence of bogus path mappings
  AssertTrue('effects line contains all 4 built-in effects exactly once',
    Pos('effects = cas:fxaa:smaa:dls' + LineEnding, Content) > 0);
  AssertFalse('no cas path mapping', Pos('cas =', Content) > 0);
  AssertFalse('no dls path mapping', Pos('dls =', Content) > 0);
  AssertFalse('no fxaa path mapping', Pos('fxaa =', Content) > 0);
  AssertFalse('no smaa path mapping', Pos('smaa =', Content) > 0);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadVkBasaltConfig;
  AssertEquals('casTrackBar reloaded', 8, goverlayform.casTrackBar.Position);
  AssertEquals('dlsTrackBar reloaded', 6, goverlayform.dlsTrackBar.Position);
  AssertEquals('fxaaTrackBar reloaded', 4, goverlayform.fxaaTrackBar.Position);
  AssertEquals('smaaTrackBar reloaded', 2, goverlayform.smaaTrackBar.Position);
  AssertEquals('vkbtogglekeyCombobox reloaded', 'Home', goverlayform.vkbtogglekeyCombobox.Text);
end;

procedure TGoverlayGuiTests.TestVkSumiRoundTrip;
begin
  NavigateVkSumiTab;
  goverlayform.FVsTrackbars[0].Position := 80;
  goverlayform.FVsTrackbars[1].Position := 120;

  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  // Reload config into UI and assert trackbars retain state
  goverlayform.LoadVkSumiConfig;
  AssertEquals('FVsTrackbars[0] brightness reloaded', 80, goverlayform.FVsTrackbars[0].Position);
  AssertEquals('FVsTrackbars[1] contrast reloaded', 120, goverlayform.FVsTrackbars[1].Position);
end;

procedure TGoverlayGuiTests.NavigateTweaksTab;
begin
  AssertTrue('tweaksLabel.OnClick is bound', Assigned(goverlayform.tweaksLabel.OnClick));
  goverlayform.tweaksLabel.OnClick(goverlayform.tweaksLabel);
end;

procedure TGoverlayGuiTests.TestTweaksTabRoundTrip;
begin
  NavigateTweaksTab;
  AssertTrue('tweaks tab active after click', goverlayform.goverlayPageControl.ActivePage = goverlayform.tweakstabsheet);

  goverlayform.simdeckCheckBox.Checked := True;
  goverlayform.enhdrCheckBox.Checked := True;
  goverlayform.obs_vkcaptureCheckBox.Checked := True;

  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  // Reload config into UI and assert controls retain state
  goverlayform.LoadTweaksFromFGMod;
  AssertTrue('simdeckCheckBox reloaded', goverlayform.simdeckCheckBox.Checked);
  AssertTrue('enhdrCheckBox reloaded', goverlayform.enhdrCheckBox.Checked);
  AssertTrue('obs_vkcaptureCheckBox reloaded', goverlayform.obs_vkcaptureCheckBox.Checked);
end;

procedure TGoverlayGuiTests.TestProtonLocalShaderCacheTweak;
begin
  NavigateTweaksTab;
  AssertTrue('FProtonLocalShaderCacheCheckBox created', Assigned(goverlayform.FProtonLocalShaderCacheCheckBox));

  goverlayform.FProtonLocalShaderCacheCheckBox.Checked := True;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  AssertEquals('PROTON_LOCAL_SHADER_CACHE persisted in bgmod.conf', '1', ReadBgmodConf('Env', 'PROTON_LOCAL_SHADER_CACHE'));

  // Reload config from bgmod.conf into UI and assert state is loaded
  goverlayform.LoadTweaksFromFGMod;
  AssertTrue('FProtonLocalShaderCacheCheckBox reloaded as true', goverlayform.FProtonLocalShaderCacheCheckBox.Checked);

  goverlayform.FProtonLocalShaderCacheCheckBox.Checked := False;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  AssertEquals('PROTON_LOCAL_SHADER_CACHE removed when unchecked', '', ReadBgmodConf('Env', 'PROTON_LOCAL_SHADER_CACHE'));
end;

procedure TGoverlayGuiTests.TestProtonDiscordBridgeTweak;
begin
  NavigateTweaksTab;
  AssertTrue('FProtonDiscordBridgeCheckBox created', Assigned(goverlayform.FProtonDiscordBridgeCheckBox));

  goverlayform.FProtonDiscordBridgeCheckBox.Checked := True;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  AssertEquals('PROTON_DISCORD_BRIDGE persisted in bgmod.conf', '1', ReadBgmodConf('Env', 'PROTON_DISCORD_BRIDGE'));

  // Reload config from bgmod.conf into UI and assert state is loaded
  goverlayform.LoadTweaksFromFGMod;
  AssertTrue('FProtonDiscordBridgeCheckBox reloaded as true', goverlayform.FProtonDiscordBridgeCheckBox.Checked);

  goverlayform.FProtonDiscordBridgeCheckBox.Checked := False;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  AssertEquals('PROTON_DISCORD_BRIDGE removed when unchecked', '', ReadBgmodConf('Env', 'PROTON_DISCORD_BRIDGE'));
end;

procedure TGoverlayGuiTests.TestGamePerformanceTweak;
var
  ConfLines: TStringList;
  FoundLine, FoundEq: Boolean;
  i: Integer;
begin
  NavigateTweaksTab;
  AssertTrue('gameperfCheckBox created', Assigned(goverlayform.gameperfCheckBox));

  goverlayform.gameperfCheckBox.Checked := True;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  // Check that game-performance is written as a standalone line without '=1'
  ConfLines := TStringList.Create;
  try
    ConfLines.LoadFromFile(BgmodConfPath);
    FoundLine := False;
    FoundEq := False;
    for i := 0 to ConfLines.Count - 1 do
    begin
      if Trim(ConfLines[i]) = 'game-performance' then
        FoundLine := True;
      if Pos('game-performance=', Trim(ConfLines[i])) = 1 then
        FoundEq := True;
    end;
    AssertTrue('game-performance standalone wrapper line found in bgmod.conf', FoundLine);
    AssertFalse('game-performance=1 must not be present in bgmod.conf', FoundEq);
  finally
    ConfLines.Free;
  end;

  // Reload config from bgmod.conf into UI and assert state is loaded
  goverlayform.LoadTweaksFromFGMod;
  AssertTrue('gameperfCheckBox reloaded as true', goverlayform.gameperfCheckBox.Checked);

  goverlayform.gameperfCheckBox.Checked := False;
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);

  ConfLines := TStringList.Create;
  try
    ConfLines.LoadFromFile(BgmodConfPath);
    FoundLine := False;
    for i := 0 to ConfLines.Count - 1 do
    begin
      if Pos('game-performance', Trim(ConfLines[i])) > 0 then
        FoundLine := True;
    end;
    AssertFalse('game-performance removed when unchecked', FoundLine);
  finally
    ConfLines.Free;
  end;
end;

procedure TGoverlayGuiTests.TestTweaksCardLayoutAndClick;
begin
  NavigateTweaksTab;
  AssertTrue('FTweaksPaintBox is created', Assigned(goverlayform.FTweaksPaintBox));
  AssertEquals('Sidebar navigation item 4 caption is Tweaks', 'Tweaks', goverlayform.FNavLabels[4].Caption);

  // Verify that toggling via simulated mouse click updates checkbox state
  goverlayform.simdeckCheckBox.Checked := False;
  // Click first item (General card -> Simulate Steam Deck hardware)
  goverlayform.TweaksMD3MouseDown(goverlayform.FTweaksPaintBox, mbLeft, [], 30, 50);
  AssertTrue('simdeckCheckBox is checked after clicking item', goverlayform.simdeckCheckBox.Checked);

  // Click again to toggle off
  goverlayform.TweaksMD3MouseDown(goverlayform.FTweaksPaintBox, mbLeft, [], 30, 50);
  AssertFalse('simdeckCheckBox is unchecked after second click', goverlayform.simdeckCheckBox.Checked);

  // Trigger hover and paint in global mode
  goverlayform.FActiveGameName := '';
  goverlayform.TweaksMD3MouseMove(goverlayform.FTweaksPaintBox, [], 30, 50);
  goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);

  // Trigger hover and paint in per-game profile mode
  goverlayform.FActiveGameName := 'TestGame';
  goverlayform.TweaksMD3MouseMove(goverlayform.FTweaksPaintBox, [], 30, 50);
  goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);
  goverlayform.FActiveGameName := '';
end;

procedure TGoverlayGuiTests.TestGlobalCustomVariablesReuseAndInheritance;
var
  GlobalConf, GameConf: string;
  Ini: TIniFile;
  Row, i, CustomRow, LocalRow: Integer;
  Found: Boolean;
begin
  NavigateTweaksTab;
  goverlayform.FActiveGameName := '';

  // Ensure clean starting state
  goverlayform.LoadTweaksFromFGMod;

  // 1. Add a custom variable in Global mode
  Row := goverlayform.FTweaksGrid.RowCount;
  goverlayform.FTweaksGrid.RowCount := Row + 1;
  goverlayform.FTweaksGrid.Cells[0, Row] := '0'; // Set toggle OFF
  goverlayform.FTweaksGrid.Cells[1, Row] := TweakCategoryName(TWEAK_CAT_CUSTOM);
  goverlayform.FTweaksGrid.Cells[2, Row] := 'TEST_GLOBAL_CUSTOM=world';
  goverlayform.FTweaksGrid.Cells[3, Row] := 'Global';

  // Save global tweaks
  goverlayform.SaveTweaksConfig;

  // Verify global bgmod.conf has [CustomVariables] TEST_GLOBAL_CUSTOM=world, but NOT in [Env]
  GlobalConf := BgmodConfPath;
  Ini := TIniFile.Create(GlobalConf);
  try
    AssertEquals('Custom variable present in [CustomVariables] even when toggled OFF',
                 'world', Ini.ReadString('CustomVariables', 'TEST_GLOBAL_CUSTOM', ''));
    AssertEquals('Custom variable NOT present in [Env] when toggled OFF',
                 '', Ini.ReadString('Env', 'TEST_GLOBAL_CUSTOM', ''));
  finally
    Ini.Free;
  end;

  // Reload in global mode to verify round-trip
  goverlayform.LoadTweaksFromFGMod;
  Found := False;
  for i := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
  begin
    if goverlayform.FTweaksGrid.Cells[2, i] = 'TEST_GLOBAL_CUSTOM=world' then
    begin
      Found := True;
      AssertEquals('Loaded toggle state is 0 in global mode', '0', goverlayform.FTweaksGrid.Cells[0, i]);
      AssertEquals('Loaded origin is Global in global mode', 'Global', goverlayform.FTweaksGrid.Cells[3, i]);
    end;
  end;
  AssertTrue('TEST_GLOBAL_CUSTOM found after global reload', Found);

  // 2. Switch to game profile mode: should inherit global custom variable with toggle OFF
  goverlayform.FActiveGameName := 'TestGameCustomReuse';
  try
    goverlayform.LoadTweaksFromFGMod;

    Found := False;
    CustomRow := -1;
    for i := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
    begin
      if goverlayform.FTweaksGrid.Cells[2, i] = 'TEST_GLOBAL_CUSTOM=world' then
      begin
        Found := True;
        CustomRow := i;
        AssertEquals('Inherited global custom var toggle defaults to 0 in game profile', '0', goverlayform.FTweaksGrid.Cells[0, i]);
        AssertEquals('Inherited global custom var origin is Global in game profile', 'Global', goverlayform.FTweaksGrid.Cells[3, i]);
      end;
    end;
    AssertTrue('TEST_GLOBAL_CUSTOM found in game profile grid', Found);

    // Test Paint with inherited Global item (verifies [Global] badge rendering and no crash)
    goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);

    // 3. Test deletion guard: Deleting a Global custom var in a game profile must be blocked
    goverlayform.FTweaksGrid.Row := CustomRow;
    goverlayform.CustomEnvRemoveClick(nil);
    AssertEquals('Row preserved against CustomEnvRemoveClick in game profile',
                 'TEST_GLOBAL_CUSTOM=world', goverlayform.FTweaksGrid.Cells[2, CustomRow]);

    // Test MouseDown on the item delete area in MD3 mode - should toggle instead of deleting
    goverlayform.TweaksMD3MouseDown(goverlayform.FTweaksPaintBox, mbLeft, [], 20, 1050);
    AssertTrue('Row not deleted via delete zone in game profile',
               goverlayform.FTweaksGrid.RowCount > CustomRow);

    // 4. Activate the inherited global variable in the game profile
    goverlayform.FTweaksGrid.Cells[0, CustomRow] := '1';

    // Also add a game-specific local custom variable
    Row := goverlayform.FTweaksGrid.RowCount;
    goverlayform.FTweaksGrid.RowCount := Row + 1;
    goverlayform.FTweaksGrid.Cells[0, Row] := '1';
    goverlayform.FTweaksGrid.Cells[1, Row] := TweakCategoryName(TWEAK_CAT_CUSTOM);
    goverlayform.FTweaksGrid.Cells[2, Row] := 'GAME_LOCAL_VAR=123';
    goverlayform.FTweaksGrid.Cells[3, Row] := 'Local';
    LocalRow := Row;

    // Test Paint with both Global and Local items
    goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);

    // Save in game profile
    goverlayform.SaveTweaksConfig;

    // Check game's bgmod.conf
    GameConf := goverlayform.GetGameConfigDir('TestGameCustomReuse') + 'bgmod.conf';
    AssertTrue('Game bgmod.conf exists', FileExists(GameConf));
    Ini := TIniFile.Create(GameConf);
    try
      AssertEquals('Game [Env] contains active inherited variable', 'world', Ini.ReadString('Env', 'TEST_GLOBAL_CUSTOM', ''));
      AssertEquals('Game [Env] contains active local variable', '123', Ini.ReadString('Env', 'GAME_LOCAL_VAR', ''));
      AssertEquals('Game config does not have [CustomVariables] section', '', Ini.ReadString('CustomVariables', 'TEST_GLOBAL_CUSTOM', ''));
    finally
      Ini.Free;
    end;

    // Verify global config was not corrupted or modified by game profile save
    Ini := TIniFile.Create(GlobalConf);
    try
      AssertEquals('Global [Env] still does NOT have TEST_GLOBAL_CUSTOM', '', Ini.ReadString('Env', 'TEST_GLOBAL_CUSTOM', ''));
      AssertEquals('Global [CustomVariables] still has TEST_GLOBAL_CUSTOM', 'world', Ini.ReadString('CustomVariables', 'TEST_GLOBAL_CUSTOM', ''));
      AssertEquals('Global config does NOT have GAME_LOCAL_VAR', '', Ini.ReadString('Env', 'GAME_LOCAL_VAR', ''));
    finally
      Ini.Free;
    end;

    // 5. Reload in game profile mode and verify state
    goverlayform.LoadTweaksFromFGMod;
    Found := False;
    for i := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
    begin
      if goverlayform.FTweaksGrid.Cells[2, i] = 'TEST_GLOBAL_CUSTOM=world' then
      begin
        Found := True;
        AssertEquals('Active inherited variable reloaded as 1 in game profile', '1', goverlayform.FTweaksGrid.Cells[0, i]);
        AssertEquals('Inherited variable origin reloaded as Global', 'Global', goverlayform.FTweaksGrid.Cells[3, i]);
      end;
    end;
    AssertTrue('TEST_GLOBAL_CUSTOM found active in game profile reload', Found);

    // 6. Test that local variable can be deleted in game profile
    LocalRow := -1;
    for i := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
    begin
      if goverlayform.FTweaksGrid.Cells[2, i] = 'GAME_LOCAL_VAR=123' then
      begin
        LocalRow := i;
        AssertEquals('Local variable origin is Local', 'Local', goverlayform.FTweaksGrid.Cells[3, i]);
        Break;
      end;
    end;
    AssertTrue('GAME_LOCAL_VAR found before deletion', LocalRow > 0);

    goverlayform.FTweaksGrid.Row := LocalRow;
    goverlayform.CustomEnvRemoveClick(nil);

    Found := False;
    for i := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
      if goverlayform.FTweaksGrid.Cells[2, i] = 'GAME_LOCAL_VAR=123' then
        Found := True;
    AssertFalse('Local variable deleted successfully in game profile', Found);

  finally
    // Cleanup: Reset active game name back to global and reload
    goverlayform.FActiveGameName := '';
    goverlayform.LoadTweaksFromFGMod;
  end;
end;

procedure TGoverlayGuiTests.TestLaunchArgumentsCardAndInheritance;
var
  GlobalConf, GameConf: string;
  Ini: TIniFile;
  Row, CustomArgRow, LocalArgRow: Integer;

  function FindGridItem(const AKey: string): Integer;
  var
    idx: Integer;
  begin
    Result := -1;
    for idx := 1 + TWEAK_ROW_COUNT to goverlayform.FTweaksGrid.RowCount - 1 do
    begin
      if goverlayform.FTweaksGrid.Cells[2, idx] = AKey then
        Exit(idx);
    end;
  end;

begin
  // 1. Test IsLaunchArgument prefix classification helper
  AssertTrue('IsLaunchArgument detects - prefix', IsLaunchArgument('-novid'));
  AssertTrue('IsLaunchArgument detects -- prefix', IsLaunchArgument('--fullscreen'));
  AssertTrue('IsLaunchArgument detects + prefix', IsLaunchArgument('+fps_max 0'));
  AssertTrue('IsLaunchArgument trims whitespace', IsLaunchArgument('  -dx12  '));
  AssertFalse('IsLaunchArgument rejects normal env var', IsLaunchArgument('MANGOHUD=1'));
  AssertFalse('IsLaunchArgument rejects empty string', IsLaunchArgument(''));
  AssertFalse('IsLaunchArgument rejects plain variable name', IsLaunchArgument('ENABLE_FEATURE'));

  NavigateTweaksTab;
  goverlayform.FActiveGameName := '';

  // Ensure clean starting state
  goverlayform.LoadTweaksFromFGMod;

  // 2. Verify predefined launch arguments are loaded into FTweaksGrid
  AssertTrue('Predefined arg -novid found', FindGridItem('-novid') >= 0);
  AssertTrue('Predefined arg -vulkan found', FindGridItem('-vulkan') >= 0);
  AssertTrue('Predefined arg -dx11 found', FindGridItem('-dx11') >= 0);
  AssertTrue('Predefined arg -dx12 found', FindGridItem('-dx12') >= 0);
  AssertTrue('Predefined arg -nojoy found', FindGridItem('-nojoy') >= 0);

  // Verify predefined argument category name
  Row := FindGridItem('-novid');
  AssertEquals('Predefined arg category is Launch Arguments',
               TweakCategoryName(TWEAK_CAT_ARGS), goverlayform.FTweaksGrid.Cells[1, Row]);

  // 3. Toggle a predefined argument (-novid) to ON and save in Global mode
  goverlayform.FTweaksGrid.Cells[0, Row] := '1';

  // Add a custom launch argument in Global mode (+fps_max 144)
  Row := goverlayform.FTweaksGrid.RowCount;
  goverlayform.FTweaksGrid.RowCount := Row + 1;
  goverlayform.FTweaksGrid.Cells[0, Row] := '1';
  goverlayform.FTweaksGrid.Cells[1, Row] := TweakCategoryName(TWEAK_CAT_ARGS);
  goverlayform.FTweaksGrid.Cells[2, Row] := '+fps_max 144';
  goverlayform.FTweaksGrid.Cells[3, Row] := 'Global';

  // Add an inactive custom launch argument in Global mode (-custom-inactive)
  Row := goverlayform.FTweaksGrid.RowCount;
  goverlayform.FTweaksGrid.RowCount := Row + 1;
  goverlayform.FTweaksGrid.Cells[0, Row] := '0';
  goverlayform.FTweaksGrid.Cells[1, Row] := TweakCategoryName(TWEAK_CAT_ARGS);
  goverlayform.FTweaksGrid.Cells[2, Row] := '-custom-inactive';
  goverlayform.FTweaksGrid.Cells[3, Row] := 'Global';

  // Save global tweaks
  goverlayform.SaveTweaksConfig;

  // 4. Verify global bgmod.conf persistence
  GlobalConf := BgmodConfPath;
  Ini := TIniFile.Create(GlobalConf);
  try
    AssertEquals('Active predefined arg saved in [Args]', '1', Ini.ReadString('Args', '-novid', ''));
    AssertEquals('Active custom arg saved in [Args]', '1', Ini.ReadString('Args', '+fps_max 144', ''));
    AssertEquals('Inactive custom arg NOT saved in [Args]', '', Ini.ReadString('Args', '-custom-inactive', ''));
    AssertEquals('Active custom arg saved in [CustomArguments]', '1', Ini.ReadString('CustomArguments', '+fps_max 144', ''));
    AssertEquals('Inactive custom arg preserved in [CustomArguments]', '1', Ini.ReadString('CustomArguments', '-custom-inactive', ''));
    AssertEquals('Predefined arg NOT stored in [CustomArguments]', '', Ini.ReadString('CustomArguments', '-novid', ''));
  finally
    Ini.Free;
  end;

  // Test MD3 Paint in global mode (ensures both Card 5 and Card 6 render cleanly)
  goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);

  // 5. Reload in global mode to verify round-trip
  goverlayform.LoadTweaksFromFGMod;
  Row := FindGridItem('-novid');
  AssertTrue('-novid found after reload', Row >= 0);
  AssertEquals('-novid is toggled ON', '1', goverlayform.FTweaksGrid.Cells[0, Row]);

  Row := FindGridItem('+fps_max 144');
  AssertTrue('+fps_max 144 found after reload', Row >= 0);
  AssertEquals('+fps_max 144 is toggled ON', '1', goverlayform.FTweaksGrid.Cells[0, Row]);

  Row := FindGridItem('-custom-inactive');
  AssertTrue('-custom-inactive found after reload', Row >= 0);
  AssertEquals('-custom-inactive is toggled OFF', '0', goverlayform.FTweaksGrid.Cells[0, Row]);

  // 6. Switch to game profile mode: should inherit global custom arguments with toggle OFF by default
  goverlayform.FActiveGameName := 'TestGameArgsReuse';
  try
    goverlayform.LoadTweaksFromFGMod;

    // Verify predefined arguments are present and default to OFF in new profile
    Row := FindGridItem('-novid');
    AssertTrue('Predefined arg -novid present in game profile', Row >= 0);
    AssertEquals('Predefined arg defaults to OFF in new game profile', '0', goverlayform.FTweaksGrid.Cells[0, Row]);

    // Verify global custom arguments inherited with [Global] badge and toggle OFF
    CustomArgRow := FindGridItem('+fps_max 144');
    AssertTrue('+fps_max 144 found in game profile', CustomArgRow >= 0);
    AssertEquals('Inherited global arg toggle defaults to 0 in game profile', '0', goverlayform.FTweaksGrid.Cells[0, CustomArgRow]);
    AssertEquals('Inherited global arg origin is Global', 'Global', goverlayform.FTweaksGrid.Cells[3, CustomArgRow]);

    // 7. Test deletion guard: Deleting an inherited global argument in game profile must be blocked
    goverlayform.FTweaksGrid.Row := CustomArgRow;
    goverlayform.CustomEnvRemoveClick(nil);
    AssertEquals('Global argument preserved against CustomEnvRemoveClick in game profile',
                 '+fps_max 144', goverlayform.FTweaksGrid.Cells[2, CustomArgRow]);

    // 8. Activate the inherited argument in the game profile
    goverlayform.FTweaksGrid.Cells[0, CustomArgRow] := '1';

    // Add a game-specific local launch argument (-local-game-flag)
    Row := goverlayform.FTweaksGrid.RowCount;
    goverlayform.FTweaksGrid.RowCount := Row + 1;
    goverlayform.FTweaksGrid.Cells[0, Row] := '1';
    goverlayform.FTweaksGrid.Cells[1, Row] := TweakCategoryName(TWEAK_CAT_ARGS);
    goverlayform.FTweaksGrid.Cells[2, Row] := '-local-game-flag';
    goverlayform.FTweaksGrid.Cells[3, Row] := 'Local';
    LocalArgRow := Row;

    // Test Paint with both Global and Local argument chips
    goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);

    // Save game profile config
    goverlayform.SaveTweaksConfig;

    // Check game profile's bgmod.conf
    GameConf := goverlayform.GetGameConfigDir('TestGameArgsReuse') + 'bgmod.conf';
    AssertTrue('Game bgmod.conf exists', FileExists(GameConf));
    Ini := TIniFile.Create(GameConf);
    try
      AssertEquals('Game [Args] contains active inherited argument', '1', Ini.ReadString('Args', '+fps_max 144', ''));
      AssertEquals('Game [Args] contains active local argument', '1', Ini.ReadString('Args', '-local-game-flag', ''));
      AssertEquals('Game [Args] does NOT contain inactive predefined argument', '', Ini.ReadString('Args', '-novid', ''));
      AssertEquals('Game config does NOT create [CustomArguments]', '', Ini.ReadString('CustomArguments', '+fps_max 144', ''));
    finally
      Ini.Free;
    end;

    // Verify global config was not modified by game profile save
    Ini := TIniFile.Create(GlobalConf);
    try
      AssertEquals('Global [Args] still has -novid', '1', Ini.ReadString('Args', '-novid', ''));
      AssertEquals('Global [CustomArguments] still has +fps_max 144', '1', Ini.ReadString('CustomArguments', '+fps_max 144', ''));
      AssertEquals('Global config does NOT have -local-game-flag', '', Ini.ReadString('Args', '-local-game-flag', ''));
      AssertEquals('Global [CustomArguments] does NOT have -local-game-flag', '', Ini.ReadString('CustomArguments', '-local-game-flag', ''));
    finally
      Ini.Free;
    end;

    // 9. Reload in game profile mode and verify active state restored
    goverlayform.LoadTweaksFromFGMod;
    Row := FindGridItem('+fps_max 144');
    AssertTrue('+fps_max 144 found on reload', Row >= 0);
    AssertEquals('Inherited active argument restored as 1 in game profile', '1', goverlayform.FTweaksGrid.Cells[0, Row]);
    AssertEquals('Inherited argument origin restored as Global', 'Global', goverlayform.FTweaksGrid.Cells[3, Row]);

    Row := FindGridItem('-local-game-flag');
    AssertTrue('-local-game-flag found on reload', Row >= 0);
    AssertEquals('Local argument origin restored as Local', 'Local', goverlayform.FTweaksGrid.Cells[3, Row]);

    // 10. Test that local argument CAN be deleted in game profile
    goverlayform.FTweaksGrid.Row := Row;
    goverlayform.CustomEnvRemoveClick(nil);
    AssertEquals('Local argument deleted from grid', -1, FindGridItem('-local-game-flag'));

  finally
    // Cleanup: Reset active game name back to global and reload
    goverlayform.FActiveGameName := '';
    goverlayform.LoadTweaksFromFGMod;
  end;
end;

procedure TGoverlayGuiTests.TestNonSteamRemoveFoldersMenu;
var
  NonSteamFile, FakeFolder: string;
  Lines: TStringList;
begin
  NonSteamFile := IsolatedHome + '/.config/goverlay/nonsteam_folders.txt';
  FakeFolder := IsolatedHome + '/fake_nonsteam_game_folder';
  ForceDirectories(ExtractFilePath(NonSteamFile));

  // Write initial nonsteam_folders.txt with a fake folder path
  Lines := TStringList.Create;
  try
    Lines.Add(FakeFolder);
    Lines.SaveToFile(NonSteamFile);
  finally
    Lines.Free;
  end;

  // Execute ShowRemoveFoldersMenu multiple times to verify clearing and rebuilding runs without LCL double-free crashes
  goverlayform.ShowRemoveFoldersMenu(goverlayform, 0, 0);
  AssertTrue('FRemoveFoldersMenu created', Assigned(goverlayform.FRemoveFoldersMenu));
  AssertEquals('Top-level menu contains folder item', 1, goverlayform.FRemoveFoldersMenu.Items.Count);
  AssertEquals('MenuItem caption formatted directly', 'Remove: ' + FakeFolder, goverlayform.FRemoveFoldersMenu.Items[0].Caption);

  goverlayform.ShowRemoveFoldersMenu(goverlayform, 0, 0);
  AssertEquals('Second invocation clears and rebuilds without crash', 1, goverlayform.FRemoveFoldersMenu.Items.Count);

  // Test Games tab popup menu
  goverlayform.ShowGamesPopupMenu;
  AssertTrue('FGamesPopupMenu created', Assigned(goverlayform.FGamesPopupMenu));
  AssertTrue('Games popup menu has items', goverlayform.FGamesPopupMenu.Items.Count >= 4);
  AssertEquals('First item is Add game folder...', 'Add game folder...', goverlayform.FGamesPopupMenu.Items[0].Caption);
  AssertEquals('Second item is Remove game folder', 'Remove game folder', goverlayform.FGamesPopupMenu.Items[1].Caption);
  AssertEquals('Remove sub-item has folder', FakeFolder, goverlayform.FGamesPopupMenu.Items[1].Items[0].Caption);
  AssertEquals('Fourth item is Refresh game library', 'Refresh game library', goverlayform.FGamesPopupMenu.Items[3].Caption);
end;

procedure TGoverlayGuiTests.TestHomeTabHidesToggles;
var
  i: Integer;
begin
  goverlayform.ShowHomeTab(nil);
  for i := 0 to 3 do
    if Assigned(goverlayform.FNavToolBtns[i]) then
      AssertFalse(Format('Toggle %d hidden on Home tab', [i]), goverlayform.FNavToolBtns[i].Visible);
  AssertFalse('Dock is NOT visible on Home tab', goverlayform.FFADock.Visible);
end;

procedure TGoverlayGuiTests.TestHomeTabLibraries;
begin
  goverlayform.ShowHomeTab(nil);
  AssertTrue('Home tab is visible', goverlayform.FHomeTabSheet.TabVisible);
  AssertTrue('lsfg-vk status dot assigned', Assigned(goverlayform.FHomeModDots[5]));
  AssertTrue('lsfg-vk version label assigned', Assigned(goverlayform.FHomeModVerLbls[5]));
  AssertTrue('lsfg-vk version label text not empty', goverlayform.FHomeModVerLbls[5].Caption <> '');
  AssertTrue('MAKO status dot assigned', Assigned(goverlayform.FHomeModDots[6]));
  AssertTrue('MAKO version label assigned', Assigned(goverlayform.FHomeModVerLbls[6]));
  AssertTrue('MAKO version label text not empty', goverlayform.FHomeModVerLbls[6].Caption <> '');
  AssertTrue('ReShade status dot assigned', Assigned(goverlayform.FHomeModDots[7]));
  AssertTrue('ReShade version label assigned', Assigned(goverlayform.FHomeModVerLbls[7]));
  AssertTrue('ReShade version label text not empty', goverlayform.FHomeModVerLbls[7].Caption <> '');
end;

procedure TGoverlayGuiTests.TestWindowResizabilityAndGeometry;
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  AssertEquals('BorderStyle is bsSizeable', Ord(bsSizeable), Ord(goverlayform.BorderStyle));
  AssertEquals('Constraints.MinWidth is 1045', 1045, goverlayform.Constraints.MinWidth);
  AssertEquals('Constraints.MinHeight is 683', 683, goverlayform.Constraints.MinHeight);

  goverlayform.Width := 1150;
  goverlayform.Height := 750;
  goverlayform.SaveWindowGeometry;

  ConfigPath := GetConfigFilePath;
  AssertTrue('Config file exists after saving geometry', FileExists(ConfigPath));

  Ini := TIniFile.Create(ConfigPath);
  try
    AssertEquals('Width saved in INI', 1150, Ini.ReadInteger('Window', 'Width', 0));
    AssertEquals('Height saved in INI', 750, Ini.ReadInteger('Window', 'Height', 0));
    AssertFalse('Maximized false in INI', Ini.ReadBool('Window', 'Maximized', True));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayGuiTests.TestSidebarTabPathResetGlobalMode;
begin
  goverlayform.FActiveGameName := 'TestGame';
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  AssertTrue('MANGOHUDCFGFILE points to game dir when active', Pos('TestGame', MANGOHUDCFGFILE) > 0);

  goverlayform.FActiveGameName := '';
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  AssertFalse('MANGOHUDCFGFILE reset to global dir when FActiveGameName empty', Pos('TestGame', MANGOHUDCFGFILE) > 0);

  goverlayform.FActiveGameName := 'TestGame';
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  AssertTrue('VKBASALTCFGFILE points to game dir when active', Pos('TestGame', VKBASALTCFGFILE) > 0);

  goverlayform.FActiveGameName := '';
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  AssertFalse('VKBASALTCFGFILE reset to global dir when FActiveGameName empty', Pos('TestGame', VKBASALTCFGFILE) > 0);
end;

procedure TGoverlayGuiTests.TestTweaksResetOnMissingConfig;
begin
  goverlayform.simdeckCheckBox.Checked := True;
  goverlayform.FActiveGameName := 'NonExistentGameProfile123';
  goverlayform.LoadTweaksFromFGMod;
  AssertFalse('simdeckCheckBox reset to false on missing bgmod.conf', goverlayform.simdeckCheckBox.Checked);
  goverlayform.FActiveGameName := '';
end;

procedure TGoverlayGuiTests.TestMangoPresetCardHighlightsResetOnProfileSwitch;
begin
  goverlayform.FActiveLayoutCard := 0;
  goverlayform.FActiveColorCard := 2;

  goverlayform.FActiveGameName := 'SomeNewProfile';
  goverlayform.LoadMangoHudConfig;

  AssertEquals('FActiveLayoutCard reset on profile load', -1, goverlayform.FActiveLayoutCard);
  AssertEquals('FActiveColorCard reset on profile load', -1, goverlayform.FActiveColorCard);
  goverlayform.FActiveGameName := '';
end;

procedure TGoverlayGuiTests.TestMissingConfigResetsControlsAllTabs;
begin
  // Initialize vkBasalt/vkSumi controls
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);

  // 1. MangoHud: Set controls, switch to profile with no MangoHud.conf, verify controls reset
  goverlayform.fpsCheckBox.Checked := True;
  goverlayform.hudtitleEdit.Text := 'CustomTitle';
  goverlayform.FActiveGameName := 'MissingConfigGameProfile999';
  MANGOHUDCFGFILE := goverlayform.GetGameConfigDir('MissingConfigGameProfile999') + 'MangoHud.conf';
  goverlayform.LoadMangoHudConfig;
  AssertFalse('fpsCheckBox reset when MangoHud.conf missing', goverlayform.fpsCheckBox.Checked);
  AssertEquals('hudtitleEdit reset when MangoHud.conf missing', '', goverlayform.hudtitleEdit.Text);

  // 2. vkBasalt: Add active effect and trackbar position, switch to profile with no vkBasalt.conf, verify reset
  goverlayform.acteffectsListBox.Items.Add('cas');
  goverlayform.casTrackBar.Position := 8;
  VKBASALTCFGFILE := goverlayform.GetGameConfigDir('MissingConfigGameProfile999') + 'vkBasalt.conf';
  goverlayform.LoadVkBasaltConfig;
  AssertEquals('acteffectsListBox cleared when vkBasalt.conf missing', 0, goverlayform.acteffectsListBox.Items.Count);
  AssertEquals('casTrackBar position reset to 0 when vkBasalt.conf missing', 0, goverlayform.casTrackBar.Position);

  // 3. vkSumi: Set custom trackbar position, switch to missing config profile, verify default load
  if Assigned(goverlayform.FVsEnabledCB) then goverlayform.FVsEnabledCB.Checked := False;
  VKSUMICFGFILE := goverlayform.GetGameConfigDir('MissingConfigGameProfile999') + 'vkSumi.conf';
  goverlayform.LoadVkSumiConfig;
  if Assigned(goverlayform.FVsEnabledCB) then
    AssertTrue('FVsEnabledCB set to default true when vkSumi.conf missing', goverlayform.FVsEnabledCB.Checked);

  goverlayform.FActiveGameName := '';
end;

procedure TGoverlayGuiTests.TestGameCardClickSynchronizesAllToolPaths;
var
  Panel: TPanel;
  ExpectedDir: string;
begin
  Panel := TPanel.Create(nil);
  try
    Panel.Hint := 'PathSyncGameTest';
    goverlayform.GameCardClick(Panel);

    ExpectedDir := goverlayform.GetGameConfigDir('PathSyncGameTest');
    AssertEquals('MANGOHUDCFGFILE set on game card click', ExpectedDir + 'MangoHud.conf', MANGOHUDCFGFILE);
    AssertEquals('VKBASALTCFGFILE set on game card click', ExpectedDir + 'vkBasalt.conf', VKBASALTCFGFILE);
    AssertEquals('VKSUMICFGFILE set on game card click', ExpectedDir + 'vkSumi.conf', VKSUMICFGFILE);
    AssertFalse('goverlaybarPanel is hidden on game card click', goverlayform.goverlaybarPanel.Visible);
    AssertTrue('FFADock is visible on game card click', goverlayform.FFADock.Visible);
  finally
    Panel.Free;
    goverlayform.gamesLabelClick(nil);
  end;
end;

procedure TGoverlayGuiTests.TestGameCardClickRestoresMangoHudTabVisibility;
var
  Panel: TPanel;
begin
  // 1. Visit OptiScaler, which hides MangoHud tabs
  goverlayform.optiscalerLabelClick(nil);
  AssertFalse('presetTabSheet hidden on OptiScaler', goverlayform.presetTabSheet.TabVisible);
  AssertFalse('visualTabSheet hidden on OptiScaler', goverlayform.visualTabSheet.TabVisible);
  AssertFalse('performanceTabSheet hidden on OptiScaler', goverlayform.performanceTabSheet.TabVisible);
  AssertFalse('metricsTabSheet hidden on OptiScaler', goverlayform.metricsTabSheet.TabVisible);
  AssertFalse('extrasTabSheet hidden on OptiScaler', goverlayform.extrasTabSheet.TabVisible);

  // 2. Return to Games tab
  goverlayform.gamesLabelClick(nil);
  AssertFalse('presetTabSheet remains hidden on Games tab', goverlayform.presetTabSheet.TabVisible);

  // 3. Click a game card
  Panel := TPanel.Create(nil);
  try
    Panel.Hint := 'TabVisGameTest';
    goverlayform.GameCardClick(Panel);

    // Verify all 5 MangoHud tabs are restored
    AssertTrue('goverlayPageControl.ShowTabs is True after game card click', goverlayform.goverlayPageControl.ShowTabs);
    AssertTrue('presetTabSheet is visible after game card click', goverlayform.presetTabSheet.TabVisible);
    AssertTrue('visualTabSheet is visible after game card click', goverlayform.visualTabSheet.TabVisible);
    AssertTrue('performanceTabSheet is visible after game card click', goverlayform.performanceTabSheet.TabVisible);
    AssertTrue('metricsTabSheet is visible after game card click', goverlayform.metricsTabSheet.TabVisible);
    AssertTrue('extrasTabSheet is visible after game card click', goverlayform.extrasTabSheet.TabVisible);

    // Verify non-MangoHud tabs are hidden
    AssertFalse('gamesTabSheet is hidden after game card click', goverlayform.gamesTabSheet.TabVisible);
    AssertFalse('vkbasaltTabSheet is hidden after game card click', goverlayform.vkbasalttabsheet.TabVisible);
    AssertFalse('vksumiTabSheet is hidden after game card click', goverlayform.vksumiTabSheet.TabVisible);
    AssertFalse('optiscalertabsheet is hidden after game card click', goverlayform.optiscalertabsheet.TabVisible);
    AssertFalse('losslessScalingTabSheet is hidden after game card click', goverlayform.losslessScalingTabSheet.TabVisible);
    AssertFalse('tweakstabsheet is hidden after game card click', goverlayform.tweakstabsheet.TabVisible);
    AssertFalse('FHomeTabSheet is hidden after game card click', goverlayform.FHomeTabSheet.TabVisible);

    // Verify active page is presetTabSheet
    AssertTrue('presetTabSheet is active page after game card click', goverlayform.goverlayPageControl.ActivePage = goverlayform.presetTabSheet);
  finally
    Panel.Free;
    goverlayform.gamesLabelClick(nil);
  end;
end;

procedure TGoverlayGuiTests.TestVkBasaltRestoreDefaults;
begin
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
  goverlayform.acteffectsListBox.Items.Clear;
  goverlayform.acteffectsListBox.Items.Add('Shaders/ColorMatrix.fx');
  goverlayform.casTrackBar.Position := 8;

  AssertEquals('acteffectsListBox has item before restore', 1, goverlayform.acteffectsListBox.Items.Count);
  AssertEquals('casTrackBar is 8 before restore', 8, goverlayform.casTrackBar.Position);

  goverlayform.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);

  AssertEquals('acteffectsListBox cleared by restore defaults', 0, goverlayform.acteffectsListBox.Items.Count);
  AssertEquals('casTrackBar reset to 0 by restore defaults', 0, goverlayform.casTrackBar.Position);
  AssertEquals('fxaaTrackBar reset to 0 by restore defaults', 0, goverlayform.fxaaTrackBar.Position);
end;

procedure TGoverlayGuiTests.TestVkBasaltPipelineCardVisibleAndBounds;
begin
  NavigateVkBasaltTab;
  AssertTrue('FVkPipelineCard is assigned', Assigned(goverlayform.FVkPipelineCard));
  AssertTrue('FVkPipelineCard is visible', goverlayform.FVkPipelineCard.Visible);
  AssertTrue('FVkPipelinePB is assigned', Assigned(goverlayform.FVkPipelinePB));

  // Assert cards layout for vkBasalt method:
  // Toggle card is on the top row beside Method card
  AssertTrue('ToggleCard is to the right of MethodCard',
    goverlayform.FVkToggleCard.Left > TReshadeTabHelper(goverlayform.FReshadeHelper).MethodCard.Left);
  AssertEquals('ToggleCard shares top row with MethodCard',
    TReshadeTabHelper(goverlayform.FReshadeHelper).MethodCard.Top, goverlayform.FVkToggleCard.Top);
  // Pipeline card is below Builtin card
  AssertTrue('PipelineCard is below BuiltinCard',
    goverlayform.FVkPipelineCard.Top >= goverlayform.FVkBuiltinCard.Top + goverlayform.FVkBuiltinCard.Height);
  // StatusCard is hidden in vkBasalt mode
  AssertFalse('StatusCard is hidden in vkBasalt mode',
    TReshadeTabHelper(goverlayform.FReshadeHelper).StatusCard.Visible);
  // PipelineCard is at the bottom of the tab view
  AssertTrue('PipelineCard is at the bottom of the tab view',
    goverlayform.FVkPipelineCard.Top + goverlayform.FVkPipelineCard.Height <= goverlayform.FVkPipelineCard.Parent.Height);
  AssertTrue('BuiltinCard is compact (Height >= 148)',
    goverlayform.FVkBuiltinCard.Height >= 148);
  AssertTrue('ToggleCard is fully contained inside parent container',
    goverlayform.FVkToggleCard.Top + goverlayform.FVkToggleCard.Height <= goverlayform.FVkToggleCard.Parent.Height);
  AssertTrue('LUT controls assigned and visible',
    Assigned(goverlayform.FVkLutPathEdit) and Assigned(goverlayform.FVkLutBrowseBtn) and Assigned(goverlayform.FVkLutClearBtn));
  AssertTrue('LUT controls contained within BuiltinCard',
    goverlayform.FVkLutPathEdit.Top + goverlayform.FVkLutPathEdit.Height <= goverlayform.FVkBuiltinCard.Height);
end;

procedure TGoverlayGuiTests.TestVkBasaltPipelineInteractions;
var
  Helper: TVkBasaltTabHelper;
begin
  NavigateVkBasaltTab;
  Helper := TVkBasaltTabHelper(goverlayform.FBasaltHelper);
  AssertTrue('FBasaltHelper assigned', Assigned(Helper));

  // Start fresh
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);
  AssertEquals('Pipeline empty after restore', 0, goverlayform.FPipelineEffects.Count);

  // Enable CAS then FXAA then SMAA
  goverlayform.casTrackBar.Position := 5;
  goverlayform.fxaaTrackBar.Position := 7;
  goverlayform.smaaTrackBar.Position := 3;

  AssertEquals('Pipeline has 3 effects', 3, goverlayform.FPipelineEffects.Count);
  AssertEquals('Effect 0 is cas', 'cas', goverlayform.FPipelineEffects[0]);
  AssertEquals('Effect 1 is fxaa', 'fxaa', goverlayform.FPipelineEffects[1]);
  AssertEquals('Effect 2 is smaa', 'smaa', goverlayform.FPipelineEffects[2]);

  // Move smaa to index 0 (execution order: smaa -> cas -> fxaa)
  Helper.MovePipelineEffect(2, 0);
  AssertEquals('Effect 0 moved to smaa', 'smaa', goverlayform.FPipelineEffects[0]);
  AssertEquals('Effect 1 is now cas', 'cas', goverlayform.FPipelineEffects[1]);
  AssertEquals('Effect 2 is now fxaa', 'fxaa', goverlayform.FPipelineEffects[2]);

  // Disable cas via pipeline remove button / DisablePipelineEffect
  Helper.DisablePipelineEffect('cas');
  AssertEquals('Pipeline now has 2 effects', 2, goverlayform.FPipelineEffects.Count);
  AssertEquals('Effect 0 is smaa', 'smaa', goverlayform.FPipelineEffects[0]);
  AssertEquals('Effect 1 is fxaa', 'fxaa', goverlayform.FPipelineEffects[1]);
  AssertEquals('casTrackBar reset to 0 after disable', 0, goverlayform.casTrackBar.Position);

  // Restore defaults
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);
  AssertEquals('Pipeline cleared on restore defaults', 0, goverlayform.FPipelineEffects.Count);
end;

procedure TGoverlayGuiTests.TestVkBasaltLutInteractions;
var
  Helper: TVkBasaltTabHelper;
  ConfPath, Content: string;
begin
  NavigateVkBasaltTab;
  Helper := TVkBasaltTabHelper(goverlayform.FBasaltHelper);
  AssertTrue('FBasaltHelper assigned', Assigned(Helper));
  ConfPath := IsolatedHome + '/.config/vkBasalt/vkBasalt.conf';

  // Start fresh
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);
  AssertEquals('LUT path is empty after restore', '', goverlayform.FVkLutPathEdit.Text);
  AssertEquals('lut not in pipeline after restore', -1, goverlayform.FPipelineEffects.IndexOf('lut'));

  // Simulate setting a LUT file
  goverlayform.FVkLutPathEdit.Text := '/path/to/my_grade.cube';
  Helper.AddEffectToPipeline('lut');
  AssertTrue('lut is in pipeline', goverlayform.FPipelineEffects.IndexOf('lut') >= 0);

  // Verify pipeline chip painting renders 'LUT' without crashing
  Helper.VkPipelineCardPaint(goverlayform.FVkPipelinePB);

  // Save config and verify lutFile and effects = lut
  goverlayform.saveBitBtn.OnClick(goverlayform.saveBitBtn);
  Content := ReadFileText(ConfPath);
  AssertTrue('vkBasalt.conf contains lutFile', Pos('lutFile = "/path/to/my_grade.cube"', Content) > 0);
  AssertTrue('vkBasalt.conf contains lut effect', Pos('lut', Content) > 0);

  // Disable via pipeline close button
  Helper.DisablePipelineEffect('lut');
  AssertEquals('LUT path cleared after disable', '', goverlayform.FVkLutPathEdit.Text);
  AssertEquals('lut removed from pipeline after disable', -1, goverlayform.FPipelineEffects.IndexOf('lut'));

  // Re-add and test Clear button
  goverlayform.FVkLutPathEdit.Text := '/path/to/test.png';
  Helper.AddEffectToPipeline('lut');
  AssertEquals('lut in pipeline', 0, goverlayform.FPipelineEffects.IndexOf('lut'));
  Helper.VkLutClearBtnClick(goverlayform.FVkLutClearBtn);
  AssertEquals('LUT path cleared after ClearBtnClick', '', goverlayform.FVkLutPathEdit.Text);
  AssertEquals('lut removed from pipeline after ClearBtnClick', -1, goverlayform.FPipelineEffects.IndexOf('lut'));

  // Test Restore Defaults
  goverlayform.FVkLutPathEdit.Text := '/path/to/another.cube';
  Helper.AddEffectToPipeline('lut');
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);
  AssertEquals('LUT path cleared on restore defaults', '', goverlayform.FVkLutPathEdit.Text);
  AssertEquals('lut removed from pipeline on restore defaults', -1, goverlayform.FPipelineEffects.IndexOf('lut'));
end;

procedure TGoverlayGuiTests.TestVkBasaltPipelineScrollOnManyEffects;
var
  Helper: TVkBasaltTabHelper;
  i: Integer;
  Handled: Boolean;
begin
  NavigateVkBasaltTab;
  Helper := TVkBasaltTabHelper(goverlayform.FBasaltHelper);
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);

  // Add 10 effects so content overflows card width
  for i := 1 to 10 do
    Helper.AddEffectToPipeline('ShaderEffect' + IntToStr(i));

  // Trigger painting to compute dimensions and scrollbar status
  Helper.VkPipelineCardPaint(goverlayform.FVkPipelinePB);

  AssertTrue('FVkPipelineSB is assigned', Assigned(goverlayform.FVkPipelineSB));
  AssertTrue('FVkPipelineSB is visible when many effects overflow', goverlayform.FVkPipelineSB.Visible);
  AssertTrue('FVkPipelineSB.Max > 0', goverlayform.FVkPipelineSB.Max > 0);

  // Test mouse wheel horizontal scrolling
  Handled := False;
  goverlayform.FVkPipelineScrollPos := 0;
  Helper.VkPipelineCardMouseWheel(goverlayform.FVkPipelinePB, [], -120, Point(100, 10), Handled);

  AssertTrue('Wheel scrolling was handled', Handled);
  AssertTrue('Scroll position increased after wheel event', goverlayform.FVkPipelineScrollPos > 0);

  // Restore defaults cleans up scrollbar and list
  Helper.VkRestoreBtnClick(goverlayform.FVkRestoreBtn);
  AssertEquals('Pipeline scroll pos reset to 0', 0, goverlayform.FVkPipelineScrollPos);
  AssertFalse('FVkPipelineSB hidden after restore defaults', goverlayform.FVkPipelineSB.Visible);
end;

procedure TGoverlayGuiTests.TestVkBasaltShadersListDeduplicationAndExclusions;
var
  MockRepo: string;
  LB: TListBox;
  SL: TStringList;
  i, BloomCount, AsciiCount: Integer;
  ItemName: string;
begin
  MockRepo := IsolatedHome + '/mock_reshade_shaders';
  ForceDirectories(MockRepo + '/Shaders');
  ForceDirectories(MockRepo + '/Custom');

  SL := TStringList.Create;
  try
    SL.Text := '// test';
    SL.SaveToFile(MockRepo + '/Shaders/ASCII.fx');
    SL.SaveToFile(MockRepo + '/Shaders/Bloom.fx');
    SL.SaveToFile(MockRepo + '/Shaders/Bloom.fxh');
    SL.SaveToFile(MockRepo + '/Custom/Bloom.fx');
    SL.SaveToFile(MockRepo + '/Shaders/ReShade.fxh');
    SL.SaveToFile(MockRepo + '/Shaders/DrawText.fxh');
    SL.SaveToFile(MockRepo + '/Shaders/FXAA.fx');
    SL.SaveToFile(MockRepo + '/Shaders/FXAA.fxh');
    SL.SaveToFile(MockRepo + '/Shaders/SMAA.fx');
    SL.SaveToFile(MockRepo + '/Shaders/SMAA.fxh');
    SL.SaveToFile(MockRepo + '/Shaders/LUT.fx');
    SL.SaveToFile(MockRepo + '/Shaders/MultiLUT.fx');
  finally
    SL.Free;
  end;

  LB := TListBox.Create(nil);
  try
    ListFilesToListBox(MockRepo, LB, ['.fx', '.glsl']);

    BloomCount := 0;
    AsciiCount := 0;
    for i := 0 to LB.Items.Count - 1 do
    begin
      ItemName := ChangeFileExt(ExtractFileName(LB.Items[i]), '');
      AssertFalse('FXAA must be excluded from ReShade effects list', SameText(ItemName, 'fxaa'));
      AssertFalse('SMAA must be excluded from ReShade effects list', SameText(ItemName, 'smaa'));
      AssertFalse('LUT must be excluded from ReShade effects list', SameText(ItemName, 'lut'));
      AssertFalse('ReShade header must be excluded', SameText(ItemName, 'reshade'));
      AssertFalse('DrawText header must be excluded', SameText(ItemName, 'drawtext'));
      if SameText(ItemName, 'bloom') then Inc(BloomCount);
      if SameText(ItemName, 'ascii') then Inc(AsciiCount);
    end;

    AssertEquals('Bloom appears exactly once', 1, BloomCount);
    AssertEquals('ASCII appears exactly once', 1, AsciiCount);
    AssertTrue('MultiLUT is preserved', LB.Items.IndexOf('Shaders/MultiLUT.fx') >= 0);
  finally
    LB.Free;
  end;
end;

procedure TGoverlayGuiTests.TestMissingDependencyWarningBanners;
begin
  try
    // 1. Test MangoHud missing banner and control deactivation
    goverlayform.FMockMangoHudInstalled := 0; // force missing
    goverlayform.mangohudLabelClick(nil);

    AssertTrue('FMangoHudMissingBanner is assigned when MangoHud is missing',
      Assigned(goverlayform.FMangoHudMissingBanner));
    AssertTrue('FMangoHudMissingBanner is visible when MangoHud is missing',
      goverlayform.FMangoHudMissingBanner.Visible);
    AssertFalse('Save button is disabled when MangoHud is missing',
      goverlayform.saveBitBtn.Enabled);
    AssertFalse('presetTabSheet is disabled when MangoHud is missing',
      goverlayform.presetTabSheet.Enabled);
    AssertTrue('FMangoHudMissingBanner remains enabled',
      goverlayform.FMangoHudMissingBanner.Enabled);

    // 2. Test Re-check restores enabled state when MangoHud is installed
    goverlayform.FMockMangoHudInstalled := 1; // force installed
    goverlayform.RecheckDependenciesClick(nil);

    AssertFalse('FMangoHudMissingBanner is hidden after re-check detects MangoHud',
      goverlayform.FMangoHudMissingBanner.Visible);
    AssertTrue('Save button is re-enabled when MangoHud is installed',
      goverlayform.saveBitBtn.Enabled);
    AssertTrue('presetTabSheet is re-enabled when MangoHud is installed',
      goverlayform.presetTabSheet.Enabled);

    // 3. Test vkBasalt missing banner on Post processing rmVkBasalt method
    goverlayform.FMockVkBasaltInstalled := 0; // force missing
    goverlayform.vkbasaltLabelClick(nil);
    TReshadeTabHelper(goverlayform.FReshadeHelper).SelectMethod(rmVkBasalt);

    AssertTrue('FVkBasaltMissingBanner is assigned when vkBasalt is missing',
      Assigned(goverlayform.FVkBasaltMissingBanner));
    AssertTrue('FVkBasaltMissingBanner is visible when vkBasalt method is selected and missing',
      goverlayform.FVkBasaltMissingBanner.Visible);
    AssertFalse('Save button is disabled when vkBasalt is missing',
      goverlayform.saveBitBtn.Enabled);
    AssertFalse('FVkReshadeCard is disabled when vkBasalt is missing',
      goverlayform.FVkReshadeCard.Enabled);

    // 4. Test switching away to ReShade method hides vkBasalt banner
    TReshadeTabHelper(goverlayform.FReshadeHelper).SelectMethod(rmReshade);
    AssertFalse('FVkBasaltMissingBanner is hidden when switching to ReShade method',
      goverlayform.FVkBasaltMissingBanner.Visible);
    AssertTrue('Save button is enabled for ReShade method',
      goverlayform.saveBitBtn.Enabled);

    // 5. Test View Status navigation
    goverlayform.ViewStatusClick(nil);
    AssertTrue('ViewStatus navigates to HomeTabSheet',
      goverlayform.goverlayPageControl.ActivePage = goverlayform.FHomeTabSheet);

    // 6. Test vkSumi missing banner on Post processing vkSumi tab
    goverlayform.FMockVkSumiInstalled := 0; // force missing
    NavigateVkSumiTab;

    AssertTrue('FVkSumiMissingBanner is assigned when vkSumi is missing',
      Assigned(goverlayform.FVkSumiMissingBanner));
    AssertTrue('FVkSumiMissingBanner is visible when vkSumi is missing',
      goverlayform.FVkSumiMissingBanner.Visible);
    AssertFalse('Save button is disabled when vkSumi is missing',
      goverlayform.saveBitBtn.Enabled);

    // Recheck restores when vkSumi is installed
    goverlayform.FMockVkSumiInstalled := 1;
    goverlayform.RecheckDependenciesClick(nil);
    AssertFalse('FVkSumiMissingBanner is hidden after re-check detects vkSumi',
      goverlayform.FVkSumiMissingBanner.Visible);
    AssertTrue('Save button is re-enabled when vkSumi is installed',
      goverlayform.saveBitBtn.Enabled);

    // 7. Test Tweaks banner is hidden by default and only shows on hover over missing items
    goverlayform.FMockLowLatencyInstalled := 0; // force missing
    goverlayform.tweaksLabelClick(nil);

    // Initial state on Tweaks tab: banner is hidden
    if Assigned(goverlayform.FTweaksMissingBanner) then
      AssertFalse('FTweaksMissingBanner is hidden by default when navigating to Tweaks tab',
        goverlayform.FTweaksMissingBanner.Visible);

    // Simulate hovering over Korthos low latency item
    goverlayform.ShowTweaksMissingBanner('Korthos Low Latency is not installed', 'Test desc');
    AssertTrue('FTweaksMissingBanner is assigned when hover triggers banner',
      Assigned(goverlayform.FTweaksMissingBanner));
    AssertTrue('FTweaksMissingBanner is visible on hover',
      goverlayform.FTweaksMissingBanner.Visible);

    // Mouse leave / moving away hides banner
    goverlayform.TweaksMD3MouseLeave(nil);
    AssertFalse('FTweaksMissingBanner is hidden on mouse leave',
      goverlayform.FTweaksMissingBanner.Visible);
  finally
    goverlayform.FMockMangoHudInstalled := -1;
    goverlayform.FMockVkBasaltInstalled := -1;
    goverlayform.FMockVkSumiInstalled := -1;
    goverlayform.FMockLowLatencyInstalled := -1;
    goverlayform.UpdateToolMissingDependencyBanners;
  end;
end;

procedure TGoverlayGuiTests.TestPerformanceFiltersLayoutOnResize;
begin
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  goverlayform.performanceTabSheet.Show;

  AssertTrue('afTrackBar is horizontal', goverlayform.afTrackBar.Orientation = trHorizontal);
  AssertTrue('mipmapTrackBar is horizontal', goverlayform.mipmapTrackBar.Orientation = trHorizontal);

  // Validate original 2-card 2-row structure
  AssertTrue('FPerfCards[0] (Row 1: Information & VSYNC) is assigned', Assigned(goverlayform.FPerfCards[0]));
  AssertTrue('FPerfCards[1] (Row 2: Limiters & Filters) is assigned', Assigned(goverlayform.FPerfCards[1]));

  // Test at normal width (960x650)
  goverlayform.ReflowPerformanceTab(960, 650);
  AssertEquals('Row 1 Card Top is 0', 0, goverlayform.FPerfCards[0].Top);
  AssertEquals('Row 1 Card Height is 180', 180, goverlayform.FPerfCards[0].Height);
  AssertEquals('Row 2 Card Top is 185', 185, goverlayform.FPerfCards[1].Top);
  AssertTrue('Row 2 Card Height >= 389', goverlayform.FPerfCards[1].Height >= 389);

  AssertTrue('afTrackBar is above mipmapLabel at normal width',
    goverlayform.afTrackBar.Top + goverlayform.afTrackBar.Height < goverlayform.mipmapLabel.Top);
  AssertEquals('afTrackBar aligns with afLabel at normal width',
    goverlayform.afLabel.Left, goverlayform.afTrackBar.Left);
  AssertEquals('afLabel and mipmapLabel align at normal width',
    goverlayform.afLabel.Left, goverlayform.mipmapLabel.Left);
  AssertEquals('afTrackBar and mipmapTrackBar align at normal width',
    goverlayform.afTrackBar.Left, goverlayform.mipmapTrackBar.Left);
  AssertTrue('afvalueLabel is right of afTrackBar at normal width',
    goverlayform.afvalueLabel.Left >= goverlayform.afTrackBar.Left + goverlayform.afTrackBar.Width);
  AssertTrue('mipmapvalueLabel is right of mipmapTrackBar at normal width',
    goverlayform.mipmapvalueLabel.Left >= goverlayform.mipmapTrackBar.Left + goverlayform.mipmapTrackBar.Width);

  // Test at maximized width (1920x1080)
  goverlayform.ReflowPerformanceTab(1920, 1080);
  AssertTrue('Row 2 Card expands in maximized window', goverlayform.FPerfCards[1].Height > 700);
  AssertTrue('afTrackBar is above mipmapLabel at maximized width',
    goverlayform.afTrackBar.Top + goverlayform.afTrackBar.Height < goverlayform.mipmapLabel.Top);
  AssertEquals('afTrackBar aligns with afLabel at maximized width',
    goverlayform.afLabel.Left, goverlayform.afTrackBar.Left);
  AssertEquals('afLabel and mipmapLabel align at maximized width',
    goverlayform.afLabel.Left, goverlayform.mipmapLabel.Left);
  AssertEquals('afTrackBar and mipmapTrackBar align at maximized width',
    goverlayform.afTrackBar.Left, goverlayform.mipmapTrackBar.Left);
  AssertEquals('mipmapTrackBar aligns with mipmapLabel at maximized width',
    goverlayform.mipmapLabel.Left, goverlayform.mipmapTrackBar.Left);
  AssertTrue('afvalueLabel is right of afTrackBar at maximized width',
    goverlayform.afvalueLabel.Left >= goverlayform.afTrackBar.Left + goverlayform.afTrackBar.Width);
  AssertTrue('mipmapvalueLabel is right of mipmapTrackBar at maximized width',
    goverlayform.mipmapvalueLabel.Left >= goverlayform.mipmapTrackBar.Left + goverlayform.mipmapTrackBar.Width);
end;

procedure TGoverlayGuiTests.TestFinishConfigurationDialogModernSteamUI;
var
  Dlg, Dlg2, DlgNonSteam: TFinishDialogForm;
  Bmp: TBitmap;
begin
  Dlg := TFinishDialogForm.Create(goverlayform, 'MANGOHUD=1 %command%', 'Control Ultimate Edition');
  Bmp := TBitmap.Create;
  try
    AssertTrue('Dialog is borderless (bsNone)', Dlg.BorderStyle = bsNone);
    AssertTrue('Dialog has no native border icons', Dlg.BorderIcons = []);
    AssertTrue('Dialog height is optimized', Dlg.Height <= 500);
    AssertTrue('Dialog KeyPreview is enabled for Escape key', Dlg.KeyPreview);

    Bmp.SetSize(540, 180);
    // Exercise Steam painting and initial instructions
    Dlg.PaintAnimSteam(Bmp.Canvas, 540, 180);
    AssertTrue('Steam instructions contain Properties > General',
      Pos('Properties › General', Dlg.FStepsLabel.Caption) > 0);
    AssertTrue('Steam platform selected by default for regular games',
      Dlg.FPlatform = fpSteam);

    // Test non-steam game defaults to Heroic platform
    DlgNonSteam := TFinishDialogForm.Create(goverlayform, '/home/user/.local/share/goverlay/bgmod', 'Heroic Game', True);
    try
      AssertTrue('Non-steam game defaults to Heroic platform',
        DlgNonSteam.FPlatform = fpHeroic);
      AssertTrue('Non-steam dialog shows Heroic instructions initially',
        Pos('Settings › Advanced › scroll down to "Wrapper Command"', DlgNonSteam.FStepsLabel.Caption) > 0);
    finally
      DlgNonSteam.Free;
    end;

    // Switch to Heroic and exercise Heroic painting and modern Advanced tab instructions
    Dlg.HeroicBtnClick(nil);
    Dlg.PaintAnimHeroic(Bmp.Canvas, 540, 180);
    AssertTrue('Heroic instructions direct to Advanced tab',
      Pos('Settings › Advanced › scroll down to "Wrapper Command"', Dlg.FStepsLabel.Caption) > 0);
    AssertTrue('Heroic instructions direct to Wrapper field and plus button',
      Pos('Paste into the "Wrapper" field, click "+", and save', Dlg.FStepsLabel.Caption) > 0);

    // Verify BuildHeroicCommand strips quotes and %command%
    AssertEquals('Heroic command strips quotes and %command%',
      'MANGOHUD=1', Dlg.BuildHeroicCommand);

    Dlg2 := TFinishDialogForm.Create(goverlayform, '"/home/user/.local/share/goverlay/gameconfig/God of War/bgmod" %command%', 'God of War');
    try
      AssertEquals('Heroic command for custom game config strips quotes and %command%',
        '/home/user/.local/share/goverlay/gameconfig/God of War/bgmod', Dlg2.BuildHeroicCommand);
      AssertEquals('Lutris command for custom game config strips quotes and %command%',
        '/home/user/.local/share/goverlay/gameconfig/God of War/bgmod', Dlg2.BuildLutrisCommand);
    finally
      Dlg2.Free;
    end;

    // Switch to Lutris and exercise Lutris painting and System options instructions
    Dlg.LutrisBtnClick(nil);
    AssertTrue('Lutris platform selected', Dlg.FPlatform = fpLutris);
    Dlg.PaintAnimLutris(Bmp.Canvas, 540, 180);
    AssertTrue('Lutris instructions direct to System options tab',
      Pos('System options', Dlg.FStepsLabel.Caption) > 0);
    AssertTrue('Lutris instructions direct to Command prefix field',
      Pos('Command prefix', Dlg.FStepsLabel.Caption) > 0);

    // Verify BuildLutrisCommand strips quotes and %command%
    AssertEquals('Lutris command strips quotes and %command%',
      'MANGOHUD=1', Dlg.BuildLutrisCommand);

    // Switch back to Steam
    Dlg.SteamBtnClick(nil);
    Dlg.PaintAnimSteam(Bmp.Canvas, 540, 180);
    AssertTrue('Steam instructions restored after switching back',
      Pos('Properties › General', Dlg.FStepsLabel.Caption) > 0);

    AssertTrue('Modern Steam, Heroic, and Lutris finish dialogs painted successfully', True);
  finally
    Bmp.Free;
    Dlg.Free;
  end;
end;

procedure TGoverlayGuiTests.TestDockOpenConfigFileAction;
begin
  // 1. Verify openConfigFileMenuItem and openLogFileMenuItem exist and are configured in popsaveMenu
  AssertNotNull('openConfigFileMenuItem exists in goverlayform', goverlayform.openConfigFileMenuItem);
  AssertEquals('openConfigFileMenuItem caption', 'Open config folder', goverlayform.openConfigFileMenuItem.Caption);
  AssertEquals('openConfigFileMenuItem ImageIndex', 24, goverlayform.openConfigFileMenuItem.ImageIndex);
  AssertNotNull('openLogFileMenuItem exists in goverlayform', goverlayform.openLogFileMenuItem);
  AssertEquals('openLogFileMenuItem caption', 'Open log folder', goverlayform.openLogFileMenuItem.Caption);
  AssertEquals('openLogFileMenuItem ImageIndex', 24, goverlayform.openLogFileMenuItem.ImageIndex);

  // Verify order in popsaveMenu: Save options (0), Load config (1), Open config folder (2), Open log folder (3)
  AssertEquals('saveoptionsItem is at index 0', 0, goverlayform.popsaveMenu.Items.IndexOf(goverlayform.saveoptionsItem));
  AssertEquals('loadconfigMenuItem is at index 1', 1, goverlayform.popsaveMenu.Items.IndexOf(goverlayform.loadconfigMenuItem));
  AssertEquals('openConfigFileMenuItem is at index 2', 2, goverlayform.popsaveMenu.Items.IndexOf(goverlayform.openConfigFileMenuItem));
  AssertEquals('openLogFileMenuItem is at index 3', 3, goverlayform.popsaveMenu.Items.IndexOf(goverlayform.openLogFileMenuItem));

  // 2. MangoHud tab: verify floating dock shows Menu and popupBitBtnClick sets menu items Visible
  NavigateMangoHud;
  AssertTrue('FFADock visible on MangoHud tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on MangoHud tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on MangoHud', goverlayform.openConfigFileMenuItem.Visible);
  AssertTrue('openLogFileMenuItem visible on MangoHud', goverlayform.openLogFileMenuItem.Visible);

  // 3. vkBasalt tab: verify floating dock shows Menu and popupBitBtnClick sets menu items Visible
  NavigateVkBasaltTab;
  AssertTrue('FFADock visible on vkBasalt tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on vkBasalt tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on vkBasalt', goverlayform.openConfigFileMenuItem.Visible);
  AssertTrue('openLogFileMenuItem visible on vkBasalt', goverlayform.openLogFileMenuItem.Visible);

  // 4. OptiScaler tab: verify floating dock shows Menu and popupBitBtnClick sets menu items Visible
  NavigateOptiScalerTab;
  AssertTrue('FFADock visible on OptiScaler tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on OptiScaler tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on OptiScaler', goverlayform.openConfigFileMenuItem.Visible);
  AssertTrue('openLogFileMenuItem visible on OptiScaler', goverlayform.openLogFileMenuItem.Visible);

  // 5. Lossless Scaling tab: verify floating dock shows Menu and popupBitBtnClick sets menu items Visible
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);
  AssertTrue('FFADock visible on Lossless Scaling tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on Lossless Scaling tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on Lossless Scaling', goverlayform.openConfigFileMenuItem.Visible);
  AssertTrue('openLogFileMenuItem visible on Lossless Scaling', goverlayform.openLogFileMenuItem.Visible);

  // 6. Tweaks tab: verify floating dock shows Menu and popupBitBtnClick sets menu items Visible
  NavigateTweaksTab;
  AssertTrue('FFADock visible on Tweaks tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on Tweaks tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on Tweaks', goverlayform.openConfigFileMenuItem.Visible);
  AssertTrue('openLogFileMenuItem visible on Tweaks', goverlayform.openLogFileMenuItem.Visible);
end;

procedure TGoverlayGuiTests.TestDynamicLaunchCommandGeneration;
var
  TestPanel: TPanel;
  GlobalExpected, SteamExpected, NonSteamExpected: string;
begin
  // 1. In Global mode, launch command targets gameconfig/global/bgmod with quotes and %command%
  goverlayform.gamesLabelClick(nil);
  goverlayform.GetPerformanceCheckBox(0).Checked := False;
  if Assigned(goverlayform.FReEngineRTCheckBox) then
    goverlayform.FReEngineRTCheckBox.Checked := False;

  GlobalExpected := '"' + goverlayform.GetGameConfigDir('') + 'bgmod" %command%';
  AssertEquals('Global launch command targets gameconfig/global/bgmod',
    GlobalExpected, goverlayform.GetLaunchCommand);

  // 2. Select a Steam game card -> launch command dynamically resolves to game config path without manual save
  TestPanel := TPanel.Create(nil);
  try
    TestPanel.Hint := '(1091500) Cyberpunk 2077' + LineEnding + '/path/to/game';
    goverlayform.GameCardClick(TestPanel);

    AssertFalse('Steam game is not non-steam', goverlayform.FActiveGameIsNonSteam);
    AssertEquals('FActiveGameName matches', 'Cyberpunk 2077', goverlayform.FActiveGameName);

    SteamExpected := '"' + goverlayform.GetGameConfigDir('Cyberpunk 2077') + 'bgmod" %command%';
    AssertEquals('Steam game launch command resolves to game folder path',
      SteamExpected, goverlayform.GetLaunchCommand);

    // 3. Select a Non-Steam/Heroic game card -> launch command resolves to unquoted wrapper path without %command%
    TestPanel.Hint := 'BatmanArkhamKnight' + LineEnding + '/path/to/heroic';
    goverlayform.GameCardClick(TestPanel);

    AssertTrue('Heroic game is non-steam', goverlayform.FActiveGameIsNonSteam);
    AssertEquals('FActiveGameName matches', 'BatmanArkhamKnight', goverlayform.FActiveGameName);

    NonSteamExpected := goverlayform.GetGameConfigDir('BatmanArkhamKnight') + 'bgmod ';
    AssertEquals('Non-Steam game launch command resolves to unquoted wrapper path',
      NonSteamExpected, goverlayform.GetLaunchCommand);

    // 4. Test Gamemode integration
    goverlayform.GetPerformanceCheckBox(0).Checked := True;
    AssertTrue('Launch command contains gamemoderun when enabled',
      Pos('gamemoderun', goverlayform.GetLaunchCommand) > 0);
    goverlayform.GetPerformanceCheckBox(0).Checked := False;

    // 5. Returning to global mode restores global launch command
    goverlayform.gamesLabelClick(nil);
    AssertEquals('Returning to global mode restores global launch command',
      GlobalExpected, goverlayform.GetLaunchCommand);

    // 6. Test MangoHud Global Enable does NOT replace launch command with descriptive text
    goverlayform.globalenableMenuItem.Checked := True;
    goverlayform.saveBitBtnClick(nil);
    AssertEquals('Global launch command remains valid bgmod path when globalenableMenuItem is checked',
      GlobalExpected, goverlayform.FLaunchCommand);
    AssertEquals('GetLaunchCommand returns valid bgmod path when globalenableMenuItem is checked',
      GlobalExpected, goverlayform.GetLaunchCommand);
    AssertFalse('FLaunchCommand does not contain descriptive text',
      Pos('will be displayed', goverlayform.FLaunchCommand) > 0);
    goverlayform.globalenableMenuItem.Checked := False;
  finally
    TestPanel.Free;
    goverlayform.gamesLabelClick(nil);
  end;
end;

procedure TGoverlayGuiTests.TestMangoHudFrameTimingDetailed;
var
  C: string;
begin
  NavigateMangoHud;
  AssertTrue('frametimedetailedCheckBox assigned', Assigned(goverlayform.frametimedetailedCheckBox));
  AssertEquals('frametimedetailedCheckBox caption', 'Frame Time +', goverlayform.frametimedetailedCheckBox.Caption);

  // 1. Initial state: frametimegraph unchecked -> detailed is disabled & unchecked
  goverlayform.frametimegraphCheckBox.Checked := False;
  if Assigned(goverlayform.frametimegraphCheckBox.OnChange) then
    goverlayform.frametimegraphCheckBox.OnChange(goverlayform.frametimegraphCheckBox);
  AssertFalse('frametimedetailedCheckBox disabled when frametime is unchecked', goverlayform.frametimedetailedCheckBox.Enabled);
  AssertFalse('frametimedetailedCheckBox unchecked when frametime is unchecked', goverlayform.frametimedetailedCheckBox.Checked);

  // 2. Checking frametimegraphCheckBox enables frametimedetailedCheckBox
  goverlayform.frametimegraphCheckBox.Checked := True;
  if Assigned(goverlayform.frametimegraphCheckBox.OnChange) then
    goverlayform.frametimegraphCheckBox.OnChange(goverlayform.frametimegraphCheckBox);
  AssertTrue('frametimedetailedCheckBox enabled when frametime is checked', goverlayform.frametimedetailedCheckBox.Enabled);

  // 3. Check frametimedetailedCheckBox and save config
  goverlayform.frametimedetailedCheckBox.Checked := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains frame_timing', Pos('frame_timing', C) > 0);
  AssertTrue('MangoHud.conf contains frame_timing_detailed', Pos('frame_timing_detailed', C) > 0);

  // 4. Reload config and verify both remain checked & enabled
  goverlayform.LoadMangoHudConfig;
  AssertTrue('frametimegraphCheckBox reloaded as True', goverlayform.frametimegraphCheckBox.Checked);
  AssertTrue('frametimedetailedCheckBox reloaded as True', goverlayform.frametimedetailedCheckBox.Checked);
  AssertTrue('frametimedetailedCheckBox remains enabled after reload', goverlayform.frametimedetailedCheckBox.Enabled);

  // 5. Unchecking frametimegraph automatically unchecks and disables frametimedetailed
  goverlayform.frametimegraphCheckBox.Checked := False;
  if Assigned(goverlayform.frametimegraphCheckBox.OnChange) then
    goverlayform.frametimegraphCheckBox.OnChange(goverlayform.frametimegraphCheckBox);
  AssertFalse('frametimedetailedCheckBox unchecked on disabling frametime', goverlayform.frametimedetailedCheckBox.Checked);
  AssertFalse('frametimedetailedCheckBox disabled on disabling frametime', goverlayform.frametimedetailedCheckBox.Enabled);

  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertFalse('MangoHud.conf does not contain frame_timing_detailed when unchecked', Pos('frame_timing_detailed', C) > 0);

  // 6. Layout placement verification
  goverlayform.ReflowPerformanceTab(935, 650);
  AssertTrue('frametimedetailedCheckBox positioned to the right of frametimegraphCheckBox',
    goverlayform.frametimedetailedCheckBox.Left > goverlayform.frametimegraphCheckBox.Left);
  AssertEquals('frametimedetailedCheckBox vertically aligned on row with frametimegraphCheckBox',
    goverlayform.frametimegraphCheckBox.Top, goverlayform.frametimedetailedCheckBox.Top);
  AssertTrue('framecountCheckBox positioned below vpsCheckBox',
    goverlayform.framecountCheckBox.Top > goverlayform.vpsCheckBox.Top);
  AssertEquals('framecountCheckBox horizontally aligned in Column 3 with vpsCheckBox',
    goverlayform.vpsCheckBox.Left, goverlayform.framecountCheckBox.Left);
  AssertEquals('framecountCheckBox vertically aligned with ftraceCheckBox',
    goverlayform.ftraceCheckBox.Top, goverlayform.framecountCheckBox.Top);
  AssertTrue('frametimetypeBitBtn positioned below frametimegraphCheckBox',
    goverlayform.frametimetypeBitBtn.Top > goverlayform.frametimegraphCheckBox.Top);
end;

procedure TGoverlayGuiTests.TestMangoHudMetricsCompactToggles;
var
  Helper: TMangoHudUiHelper;
  C: string;
begin
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('Helper is assigned', Assigned(Helper));
  AssertTrue('FgpuavgloadToggle is assigned', Assigned(Helper.FgpuavgloadToggle));
  AssertTrue('FcpuavgloadToggle is assigned', Assigned(Helper.FcpuavgloadToggle));

  // 1. Toggling GPU toggle sets underlying CheckBox and persists in config
  Helper.FgpuavgloadToggle.Checked := True;
  AssertTrue('gpuavgloadCheckBox is synced as True', goverlayform.gpuavgloadCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains gpu_stats', Pos('gpu_stats', C) > 0);

  // 2. Unchecking GPU toggle sets underlying CheckBox and updates config
  Helper.FgpuavgloadToggle.Checked := False;
  AssertFalse('gpuavgloadCheckBox is synced as False', goverlayform.gpuavgloadCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertFalse('MangoHud.conf does not contain gpu_stats when unchecked', Pos('gpu_stats', C) > 0);

  // 3. Toggling CPU toggle sets underlying CheckBox and persists
  Helper.FcpuavgloadToggle.Checked := True;
  AssertTrue('cpuavgloadCheckBox is synced as True', goverlayform.cpuavgloadCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains cpu_stats', Pos('cpu_stats', C) > 0);

  // 4. Reload config and verify toggles reflect loaded state
  goverlayform.LoadMangoHudConfig;
  AssertTrue('FcpuavgloadToggle remains True after reload', Helper.FcpuavgloadToggle.Checked);
  AssertFalse('FgpuavgloadToggle remains False after reload', Helper.FgpuavgloadToggle.Checked);

  // 5. Reset to defaults resets toggles
  Helper.ResetMangoHudControls;
  AssertFalse('FcpuavgloadToggle is False after reset', Helper.FcpuavgloadToggle.Checked);
  AssertFalse('FgpuavgloadToggle is False after reset', Helper.FgpuavgloadToggle.Checked);

  // 6. Verify Reflow positioning
  goverlayform.ReflowMetricsTab(935);
  AssertTrue('FgpuavgloadToggle is positioned with positive coordinates',
    (Helper.FgpuavgloadToggle.Left > 0) and (Helper.FgpuavgloadToggle.Top > 0));
  AssertTrue('FcpuavgloadToggle is positioned with positive coordinates',
    (Helper.FcpuavgloadToggle.Left > 0) and (Helper.FcpuavgloadToggle.Top > 0));
end;

procedure TGoverlayGuiTests.TestMangoHudVisualCompactToggles;
var
  Helper: TMangoHudUiHelper;
  C: string;
begin
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('Helper is assigned', Assigned(Helper));
  AssertTrue('FhudcompactToggle is assigned', Assigned(Helper.FhudcompactToggle));
  AssertTrue('FhorizontalstrechToggle is assigned', Assigned(Helper.FhorizontalstrechToggle));
  AssertTrue('FhidehudToggle is assigned', Assigned(Helper.FhidehudToggle));

  // 1. Check hudcompactToggle and verify checkbox and config
  Helper.FhudcompactToggle.Checked := True;
  AssertTrue('hudcompactCheckBox synced True', goverlayform.hudcompactCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains compact', Pos('compact', C) > 0);

  // 2. Uncheck and verify
  Helper.FhudcompactToggle.Checked := False;
  AssertFalse('hudcompactCheckBox synced False', goverlayform.hudcompactCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertFalse('MangoHud.conf does not contain compact', Pos('compact', C) > 0);

  // 3. Check hidehudToggle and verify no_display
  Helper.FhidehudToggle.Checked := True;
  AssertTrue('hidehudCheckBox synced True', goverlayform.hidehudCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains no_display', Pos('no_display', C) > 0);

  // 4. Reload config and verify sync
  goverlayform.LoadMangoHudConfig;
  AssertTrue('FhidehudToggle is True after reload', Helper.FhidehudToggle.Checked);
  AssertFalse('FhudcompactToggle is False after reload', Helper.FhudcompactToggle.Checked);

  // 5. Reset MangoHud controls
  Helper.ResetMangoHudControls;
  AssertFalse('FhidehudToggle is False after reset', Helper.FhidehudToggle.Checked);
  AssertFalse('FhudcompactToggle is False after reset', Helper.FhudcompactToggle.Checked);

  // 6. Reflow positioning
  goverlayform.ReflowVisualTab(935, 650);
  AssertTrue('FhudcompactToggle has positive coordinates',
    (Helper.FhudcompactToggle.Left > 0) and (Helper.FhudcompactToggle.Top > 0));
end;

procedure TGoverlayGuiTests.TestMangoHudPerformanceCompactToggles;
var
  Helper: TMangoHudUiHelper;
  C: string;
begin
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('Helper is assigned', Assigned(Helper));
  AssertTrue('FfpsToggle is assigned', Assigned(Helper.FfpsToggle));
  AssertTrue('FframetimegraphToggle is assigned', Assigned(Helper.FframetimegraphToggle));
  AssertTrue('FframetimedetailedToggle is assigned', Assigned(Helper.FframetimedetailedToggle));
  AssertTrue('FfpsavgToggle is assigned', Assigned(Helper.FfpsavgToggle));
  AssertTrue('FframecountToggle is assigned', Assigned(Helper.FframecountToggle));
  AssertTrue('FftraceToggle is assigned', Assigned(Helper.FftraceToggle));
  AssertTrue('FshowfpslimToggle is assigned', Assigned(Helper.FshowfpslimToggle));
  AssertTrue('FvpsToggle is assigned', Assigned(Helper.FvpsToggle));
  AssertTrue('FfpscolorToggle is assigned', Assigned(Helper.FfpscolorToggle));

  // 1. Toggling FfpsToggle sets fpsCheckBox and saves fps to config
  Helper.FfpsToggle.Checked := True;
  AssertTrue('fpsCheckBox synced True', goverlayform.fpsCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains fps', Pos('fps', C) > 0);

  // 2. Toggling FframetimegraphToggle enables FframetimedetailedToggle
  Helper.FframetimegraphToggle.Checked := True;
  AssertTrue('frametimedetailedCheckBox enabled', goverlayform.frametimedetailedCheckBox.Enabled);
  AssertTrue('FframetimedetailedToggle enabled', Helper.FframetimedetailedToggle.Enabled);

  Helper.FframetimedetailedToggle.Checked := True;
  AssertTrue('frametimedetailedCheckBox synced True', goverlayform.frametimedetailedCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains frame_timing_detailed', Pos('frame_timing_detailed', C) > 0);

  // 3. Disabling FframetimegraphToggle disables and unchecks detailed toggle
  Helper.FframetimegraphToggle.Checked := False;
  AssertFalse('frametimedetailedCheckBox unchecked', goverlayform.frametimedetailedCheckBox.Checked);
  AssertFalse('FframetimedetailedToggle unchecked', Helper.FframetimedetailedToggle.Checked);
  AssertFalse('FframetimedetailedToggle disabled', Helper.FframetimedetailedToggle.Enabled);

  // 4. Test FfpscolorToggle
  Helper.FfpscolorToggle.Checked := True;
  AssertTrue('fpscolorCheckBox synced True', goverlayform.fpscolorCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains fps_color_change', Pos('fps_color_change', C) > 0);

  // 5. Reload config and verify
  goverlayform.LoadMangoHudConfig;
  AssertTrue('FfpscolorToggle is True after reload', Helper.FfpscolorToggle.Checked);

  // 6. Reset controls
  Helper.ResetMangoHudControls;
  AssertFalse('FfpscolorToggle is False after reset', Helper.FfpscolorToggle.Checked);

  // 7. Reflow positioning
  goverlayform.ReflowPerformanceTab(935, 650);
  AssertTrue('FfpsToggle has positive coordinates',
    (Helper.FfpsToggle.Left > 0) and (Helper.FfpsToggle.Top > 0));
  AssertTrue('FfpscolorToggle has positive coordinates',
    (Helper.FfpscolorToggle.Left > 0) and (Helper.FfpscolorToggle.Top > 0));
end;

procedure TGoverlayGuiTests.TestMangoHudExtrasCompactToggles;
var
  Helper: TMangoHudUiHelper;
  C: string;
begin
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('Helper is assigned', Assigned(Helper));
  AssertTrue('FdistroinfoToggle is assigned', Assigned(Helper.FdistroinfoToggle));
  AssertTrue('FwineToggle is assigned', Assigned(Helper.FwineToggle));
  AssertTrue('FhudversionToggle is assigned', Assigned(Helper.FhudversionToggle));
  AssertTrue('FbatteryToggle is assigned', Assigned(Helper.FbatteryToggle));
  AssertTrue('FmediaToggle is assigned', Assigned(Helper.FmediaToggle));

  // 1. Toggling distro info toggle
  Helper.FdistroinfoToggle.Checked := True;
  AssertTrue('distroinfoCheckBox synced True', goverlayform.distroinfoCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains distro', Pos('distro', C) > 0);

  // 2. Toggling wine toggle
  Helper.FwineToggle.Checked := True;
  AssertTrue('wineCheckBox synced True', goverlayform.wineCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains wine', Pos('wine', C) > 0);

  // 3. Toggling media toggle
  Helper.FmediaToggle.Checked := True;
  AssertTrue('mediaCheckBox synced True', goverlayform.mediaCheckBox.Checked);
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('MangoHud.conf contains media_player', Pos('media_player', C) > 0);

  // 4. Reload config and verify
  goverlayform.LoadMangoHudConfig;
  AssertTrue('FdistroinfoToggle is True after reload', Helper.FdistroinfoToggle.Checked);
  AssertTrue('FwineToggle is True after reload', Helper.FwineToggle.Checked);
  AssertTrue('FmediaToggle is True after reload', Helper.FmediaToggle.Checked);

  // 5. Reset controls
  Helper.ResetMangoHudControls;
  AssertFalse('FdistroinfoToggle is False after reset', Helper.FdistroinfoToggle.Checked);
  AssertFalse('FwineToggle is False after reset', Helper.FwineToggle.Checked);
  AssertFalse('FmediaToggle is False after reset', Helper.FmediaToggle.Checked);

  // 6. Reflow positioning
  goverlayform.ReflowExtrasTab(935);
  AssertTrue('FdistroinfoToggle has positive coordinates',
    (Helper.FdistroinfoToggle.Left > 0) and (Helper.FdistroinfoToggle.Top > 0));
  AssertTrue('FmediaToggle has positive coordinates',
    (Helper.FmediaToggle.Left > 0) and (Helper.FmediaToggle.Top > 0));
end;

procedure TGoverlayGuiTests.TestLosslessScalingCompactToggles;
var
  Helper: TLosslessScalingTabHelper;
begin
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);

  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless Scaling Helper is assigned', Assigned(Helper));
  AssertTrue('PerfModeToggle is assigned', Assigned(Helper.PerfModeToggle));
  AssertTrue('HdrModeToggle is assigned', Assigned(Helper.HdrModeToggle));
  AssertTrue('NoFp16Toggle is assigned', Assigned(Helper.NoFp16Toggle));

  // 1. When under LSFG method, controls remain enabled even at Multiplier 1
  Helper.SetInterpolationMethod(imLsfg);
  Helper.MultiplierTrackBar.Position := 1;
  Helper.UpdateControlsEnabled;
  AssertTrue('MultiplierTrackBar is enabled when multiplier is 1 under imLsfg', Helper.MultiplierTrackBar.Enabled);
  AssertTrue('FlowScaleTrackBar is enabled when multiplier is 1 under imLsfg', Helper.FlowScaleTrackBar.Enabled);
  AssertTrue('PerfModeToggle is enabled when multiplier is 1 under imLsfg', Helper.PerfModeToggle.Enabled);
  AssertTrue('HdrModeToggle is enabled when multiplier is 1 under imLsfg', Helper.HdrModeToggle.Enabled);
  AssertTrue('NoFp16Toggle is enabled when multiplier is 1 under imLsfg', Helper.NoFp16Toggle.Enabled);

  // 2. When Multiplier > 1 (active frame gen), controls remain enabled
  Helper.MultiplierTrackBar.Position := 2;
  Helper.UpdateControlsEnabled;
  AssertTrue('MultiplierTrackBar is enabled when multiplier is 2', Helper.MultiplierTrackBar.Enabled);
  AssertTrue('FlowScaleTrackBar is enabled when multiplier is 2', Helper.FlowScaleTrackBar.Enabled);
  AssertTrue('PerfModeToggle is enabled when multiplier is 2', Helper.PerfModeToggle.Enabled);
  AssertTrue('HdrModeToggle is enabled when multiplier is 2', Helper.HdrModeToggle.Enabled);
  AssertTrue('NoFp16Toggle is enabled when multiplier is 2', Helper.NoFp16Toggle.Enabled);

  // 3. When method is None, controls are disabled
  Helper.SetInterpolationMethod(imNone);
  Helper.UpdateControlsEnabled;
  AssertFalse('MultiplierTrackBar is disabled under imNone', Helper.MultiplierTrackBar.Enabled);
  AssertFalse('FlowScaleTrackBar is disabled under imNone', Helper.FlowScaleTrackBar.Enabled);
  AssertFalse('PerfModeToggle is disabled under imNone', Helper.PerfModeToggle.Enabled);
  AssertFalse('HdrModeToggle is disabled under imNone', Helper.HdrModeToggle.Enabled);
  AssertFalse('NoFp16Toggle is disabled under imNone', Helper.NoFp16Toggle.Enabled);

  // Restore LSFG for subsequent toggle sync tests
  Helper.SetInterpolationMethod(imLsfg);
  Helper.UpdateControlsEnabled;

  // 3. Toggling PerfModeToggle updates linked CheckBox
  Helper.PerfModeToggle.Checked := True;
  AssertTrue('PerfModeCheckBox is synced as True', Helper.PerfModeCheckBox.Checked);

  Helper.HdrModeToggle.Checked := True;
  AssertTrue('HdrModeCheckBox is synced as True', Helper.HdrModeCheckBox.Checked);

  Helper.NoFp16Toggle.Checked := True;
  AssertTrue('NoFp16CheckBox is synced as True', Helper.NoFp16CheckBox.Checked);

  // 4. Reflow positioning
  Helper.ReflowLosslessScalingTab(935);
  AssertTrue('PerfModeToggle has positive bounds',
    (Helper.PerfModeToggle.Left > 0) and (Helper.PerfModeToggle.Top > 0) and (Helper.PerfModeToggle.Width > 0));
  AssertTrue('HdrModeToggle is to the right of PerfModeToggle',
    Helper.HdrModeToggle.Left > Helper.PerfModeToggle.Left);
  AssertTrue('NoFp16Toggle is to the right of HdrModeToggle',
    Helper.NoFp16Toggle.Left > Helper.HdrModeToggle.Left);
end;

procedure TGoverlayGuiTests.TestLosslessScalingMakoTogglesLayoutAndNoScroll;
var
  Helper: TLosslessScalingTabHelper;
  PrevFgH, PrevSpatialH: Integer;
begin
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);

  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless Scaling Helper is assigned', Assigned(Helper));

  // Select MAKO method
  Helper.SetInterpolationMethod(imMako);
  Helper.FgModeComboBox.ItemIndex := 0; // Standard / non-adaptive mode
  Helper.ControlStateChange(Helper.FgModeComboBox);
  Helper.ReflowLosslessScalingTab(Helper.ScrollBox.ClientWidth);

  // Assert toggles are visible and placed in single row
  AssertTrue('PerfModeToggle is visible in MAKO', Helper.PerfModeToggle.Visible);
  AssertTrue('UltraPerfToggle is visible in MAKO', Helper.UltraPerfToggle.Visible);
  AssertTrue('AllowFp16Toggle is visible in MAKO', Helper.AllowFp16Toggle.Visible);
  AssertTrue('FgLiveToggle is visible in MAKO', Helper.FgLiveToggle.Visible);

  // Assert all 4 toggles share the same Y position
  AssertEquals('PerfModeToggle and UltraPerfToggle share same Y',
    Helper.PerfModeToggle.Top, Helper.UltraPerfToggle.Top);
  AssertEquals('PerfModeToggle and AllowFp16Toggle share same Y',
    Helper.PerfModeToggle.Top, Helper.AllowFp16Toggle.Top);
  AssertEquals('PerfModeToggle and FgLiveToggle share same Y',
    Helper.PerfModeToggle.Top, Helper.FgLiveToggle.Top);

  // Assert horizontal arrangement from left to right
  AssertTrue('UltraPerf is right of PerfMode',
    Helper.UltraPerfToggle.Left > Helper.PerfModeToggle.Left);
  AssertTrue('AllowFp16 is right of UltraPerf',
    Helper.AllowFp16Toggle.Left > Helper.UltraPerfToggle.Left);
  AssertTrue('FgLiveToggle is right of AllowFp16',
    Helper.FgLiveToggle.Left > Helper.AllowFp16Toggle.Left);

  // FrameGenCard height should be at least minimum compact height (>= 236px)
  AssertTrue('FrameGenCard height is at least compact minimum (>= 236) in non-adaptive MAKO',
    Helper.FrameGenCard.Height >= 236);

  // Total tab content height should fit within standard client height without vertical scroll
  AssertTrue('StatusCard bottom fits within ScrollBox ClientHeight',
    Helper.StatusCard.Top + Helper.StatusCard.Height <= Helper.ScrollBox.ClientHeight);
  AssertTrue('BgPanel height matches ScrollBox ClientHeight (no scroll required)',
    Helper.BgPanel.Height <= Helper.ScrollBox.ClientHeight);

  // Test dynamic height adaptation on interface resize
  PrevFgH := Helper.FrameGenCard.Height;
  PrevSpatialH := Helper.SpatialCard.Height;
  goverlayform.ClientHeight := 840;
  Helper.ReflowLosslessScalingTab(Helper.ScrollBox.ClientWidth);
  AssertTrue('FrameGenCard expands when window is taller', Helper.FrameGenCard.Height > PrevFgH);
  AssertTrue('SpatialCard expands when window is taller', Helper.SpatialCard.Height > PrevSpatialH);
  AssertTrue('StatusCard stays anchored to bottom on resize',
    Helper.StatusCard.Top + Helper.StatusCard.Height <= Helper.ScrollBox.ClientHeight);
  AssertTrue('BgPanel height matches ScrollBox ClientHeight after resize',
    Helper.BgPanel.Height <= Helper.ScrollBox.ClientHeight);

  // Restore standard window height
  goverlayform.ClientHeight := 680;
  Helper.ReflowLosslessScalingTab(Helper.ScrollBox.ClientWidth);
end;

procedure TGoverlayGuiTests.TestLosslessScalingMethodSwitching;
var
  Helper: TLosslessScalingTabHelper;
  DummyDll, TargetConfPath: string;
  Ini: TIniFile;
  DummyFile: TFileStream;
begin
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);

  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertTrue('Lossless helper is assigned', Assigned(Helper));
  AssertTrue('Method card is assigned', Assigned(Helper.MethodCard));
  AssertTrue('GPU card is assigned', Assigned(Helper.GpuCard));
  AssertTrue('Status card is assigned', Assigned(Helper.StatusCard));

  DummyDll := IsolatedHome + '/.local/share/goverlay/test_method_switching.dll';
  ForceDirectories(ExtractFilePath(DummyDll));
  DummyFile := TFileStream.Create(DummyDll, fmCreate);
  DummyFile.Free;
  try
    Helper.DllPathEdit.Text := DummyDll;

    // 1. None method
    Helper.SetInterpolationMethod(imNone);
    AssertEquals('Method is imNone', Ord(imNone), Ord(Helper.InterpolationMethod));
    AssertTrue('DisabledNoticeLbl is visible for imNone', Helper.DisabledNoticeLbl.Visible);
    AssertFalse('SpatialCard is hidden for imNone', Helper.SpatialCard.Visible);
    AssertFalse('MultiplierTrackBar is hidden for imNone', Helper.MultiplierTrackBar.Visible);
    AssertEquals('Multiplier is 1 for imNone', 1, Helper.MultiplierTrackBar.Position);
    AssertEquals('Active env vars empty for imNone', '', Helper.GetActiveEnvVars);

    // Save None and check bgmod.conf
    Helper.SaveLosslessConfig;
    TargetConfPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'bgmod.conf';
    Ini := TIniFile.Create(TargetConfPath);
    try
      AssertEquals('INTERPOLATION_METHOD is none in bgmod.conf', 'none', Ini.ReadString('Config', 'INTERPOLATION_METHOD', ''));
      AssertEquals('GOVERLAY_LOSSLESS is 0 for imNone', '0', Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '1'));
    finally
      Ini.Free;
    end;

    // 2. LSFG-VK method
    Helper.SetInterpolationMethod(imLsfg);
    AssertEquals('Method is imLsfg', Ord(imLsfg), Ord(Helper.InterpolationMethod));
    AssertFalse('DisabledNoticeLbl is hidden for imLsfg', Helper.DisabledNoticeLbl.Visible);
    AssertTrue('FrameGenCard is visible for imLsfg', Helper.FrameGenCard.Visible);
    AssertFalse('SpatialCard is hidden for imLsfg', Helper.SpatialCard.Visible);
    AssertFalse('HdrModeToggle is hidden for imLsfg', Helper.HdrModeToggle.Visible);
    AssertFalse('NoFp16Toggle is hidden for imLsfg', Helper.NoFp16Toggle.Visible);
    AssertTrue('OverridePresentModeToggle is visible for imLsfg', Helper.OverridePresentModeToggle.Visible);
    AssertTrue('PreserveSwapchainToggle is visible for imLsfg', Helper.PreserveSwapchainToggle.Visible);
    AssertTrue('AllowFp16Toggle is visible for imLsfg', Helper.AllowFp16Toggle.Visible);
    AssertTrue('PacingComboBox is visible for imLsfg', Helper.PacingComboBox.Visible);

    // Verify ControlStateChange preserves lsfg-vk toggle visibility
    Helper.ControlStateChange(nil);
    AssertFalse('HdrModeToggle remains hidden after ControlStateChange', Helper.HdrModeToggle.Visible);
    AssertFalse('NoFp16Toggle remains hidden after ControlStateChange', Helper.NoFp16Toggle.Visible);
    AssertTrue('OverridePresentModeToggle remains visible after ControlStateChange', Helper.OverridePresentModeToggle.Visible);
    AssertTrue('PreserveSwapchainToggle remains visible after ControlStateChange', Helper.PreserveSwapchainToggle.Visible);
    AssertTrue('AllowFp16Toggle remains visible after ControlStateChange', Helper.AllowFp16Toggle.Visible);
    AssertTrue('PacingComboBox remains visible after ControlStateChange', Helper.PacingComboBox.Visible);

    Helper.MultiplierTrackBar.Position := 2;
    AssertTrue('Active env vars contain LSFG_CONFIG for imLsfg', Pos('LSFG_CONFIG', Helper.GetActiveEnvVars) > 0);
    AssertEquals('Active env vars do not contain ENABLE_MAKO for imLsfg', 0, Pos('ENABLE_MAKO', Helper.GetActiveEnvVars));

    // 3. MAKO method
    Helper.SetInterpolationMethod(imMako);
    AssertEquals('Method is imMako', Ord(imMako), Ord(Helper.InterpolationMethod));
    AssertFalse('DisabledNoticeLbl is hidden for imMako', Helper.DisabledNoticeLbl.Visible);
    AssertTrue('SpatialCard is visible for imMako', Helper.SpatialCard.Visible);
    AssertTrue('Active env vars contain ENABLE_MAKO for imMako', Pos('ENABLE_MAKO=1', Helper.GetActiveEnvVars) > 0);

    // Save MAKO and check bgmod.conf
    Helper.SaveLosslessConfig;
    Ini := TIniFile.Create(TargetConfPath);
    try
      AssertEquals('INTERPOLATION_METHOD is mako in bgmod.conf', 'mako', Ini.ReadString('Config', 'INTERPOLATION_METHOD', ''));
      AssertEquals('GOVERLAY_LOSSLESS is 1 for imMako', '1', Ini.ReadString('Config', 'GOVERLAY_LOSSLESS', '0'));
    finally
      Ini.Free;
    end;

    // 4. Test LoadLosslessConfig restores imMako
    Helper.SetInterpolationMethod(imNone);
    AssertEquals('Method set to imNone before load', Ord(imNone), Ord(Helper.InterpolationMethod));
    Helper.LoadLosslessConfig;
    AssertEquals('LoadLosslessConfig restored imMako', Ord(imMako), Ord(Helper.InterpolationMethod));
    AssertTrue('SpatialCard restored visible after loading imMako', Helper.SpatialCard.Visible);

    // 5. Test Method icon size and label positioning (to the right of icon)
    AssertTrue('lsfg-vk image width is at least 30px', Helper.MethodLsfgImage.Width >= 30);
    AssertTrue('lsfg-vk image height is at least 30px', Helper.MethodLsfgImage.Height >= 30);
    AssertTrue('lsfg-vk label is to the right of icon', Helper.MethodLsfgLabel.Left > Helper.MethodLsfgImage.Left);
    AssertTrue('mako image width is at least 30px', Helper.MethodMakoImage.Width >= 30);
    AssertTrue('mako image height is at least 30px', Helper.MethodMakoImage.Height >= 30);
    AssertTrue('mako label is to the right of icon', Helper.MethodMakoLabel.Left > Helper.MethodMakoImage.Left);

    // 6. Test StatusCard labels formatting and color
    AssertEquals('Row 0 name is Lossless Scaling', 'Lossless Scaling', Helper.StatNameLabel[0].Caption);
    AssertEquals('Row 1 name is MAKO', 'MAKO', Helper.StatNameLabel[1].Caption);
    AssertEquals('Row 2 name is lsfg-vk', 'lsfg-vk', Helper.StatNameLabel[2].Caption);

    if (Helper.EngineStatusLabel.Caption <> '') and (Helper.EngineStatusLabel.Caption <> 'Not installed') then
    begin
      if Helper.MakoUpdateAvailable then
        AssertEquals('MAKO status label color is blue ($0044AAFF)', $0044AAFF, Helper.EngineStatusLabel.Font.Color)
      else
        AssertEquals('MAKO status label color is purple ($BB99FF)', $BB99FF, Helper.EngineStatusLabel.Font.Color);
      AssertFalse('MAKO status label does not repeat name', Pos('MAKO Renderer:', Helper.EngineStatusLabel.Caption) > 0);
      AssertFalse('MAKO status label does not contain (Found)', Pos('(Found)', Helper.EngineStatusLabel.Caption) > 0);
      AssertFalse('MAKO status label does not contain (found)', Pos('(found)', Helper.EngineStatusLabel.Caption) > 0);
      if (Helper.EngineStatusLabel.Caption <> 'Installed') and not Helper.MakoUpdateAvailable then
        AssertFalse('MAKO version does not start with v', (Helper.EngineStatusLabel.Caption[1] in ['v', 'V']));
    end;

    AssertTrue('MakoNoteLabel is assigned', Assigned(Helper.MakoNoteLabel));
    AssertEquals('MakoNoteLabel caption is (Incompatible with Wayland and HDR)',
      '(Incompatible with Wayland and HDR)', Helper.MakoNoteLabel.Caption);
    AssertTrue('MakoNoteLabel is visible', Helper.MakoNoteLabel.Visible);
    AssertTrue('MakoNoteLabel is to the right of EngineStatusLabel',
      Helper.MakoNoteLabel.Left > Helper.EngineStatusLabel.Left);

    if (Helper.LsfgStatusLabel.Caption <> '') and (Helper.LsfgStatusLabel.Caption <> 'Not installed') then
    begin
      if Helper.LsfgUpdateAvailable then
        AssertEquals('lsfg-vk status label color is blue ($0044AAFF)', $0044AAFF, Helper.LsfgStatusLabel.Font.Color)
      else
        AssertEquals('lsfg-vk status label color is purple ($BB99FF)', $BB99FF, Helper.LsfgStatusLabel.Font.Color);
      AssertFalse('lsfg-vk status label does not contain (Found)', Pos('(Found)', Helper.LsfgStatusLabel.Caption) > 0);
      AssertFalse('lsfg-vk status label does not contain (found)', Pos('(found)', Helper.LsfgStatusLabel.Caption) > 0);
      if (Helper.LsfgStatusLabel.Caption <> 'Installed') and not Helper.LsfgUpdateAvailable then
        AssertFalse('lsfg-vk version does not start with v', (Helper.LsfgStatusLabel.Caption[1] in ['v', 'V']));
    end;
  finally
    if FileExists(DummyDll) then
      DeleteFile(DummyDll);
  end;
end;

procedure TGoverlayGuiTests.TestMakoUpdateNotificationPersistenceAndHomeSync;
var
  Helper: TLosslessScalingTabHelper;
  StateDir, StateFile: string;
  SL: TStringList;
begin
  StateDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/mako-render';
  ForceDirectories(StateDir);
  StateFile := StateDir + '/active-renderer.json';
  SL := TStringList.Create;
  try
    SL.Add('{"version": "3.0.0", "prefix": "/home/test"}');
    SL.SaveToFile(StateFile);
  finally
    SL.Free;
  end;

  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertNotNull('Helper exists', Helper);

  try
    // Simulate detecting a newer version 3.1.0 (local is 3.0.0)
    Helper.SetMakoUpdateState('3.1.0', True);

    // 1. Check Lossless Scaling tab display
    AssertTrue('MakoUpdateAvailable is True', Helper.MakoUpdateAvailable);
    AssertEquals('MakoRemoteVer is 3.1.0', '3.1.0', Helper.MakoRemoteVer);
    AssertTrue('Engine status shows arrow indicator', Pos('→ 3.1.0', Helper.MakoStatusLabel.Caption) > 0);
    AssertEquals('Engine status has accent update color ($0044AAFF)', $0044AAFF, Helper.MakoStatusLabel.Font.Color);
    AssertTrue('Install update button is visible', Helper.InstallBtn.Visible);
    AssertEquals('Install button caption is Install update', 'Install update', Helper.InstallBtn.Caption);

    // 2. Check Home tab synchronization
    goverlayform.ShowHomeTab;
    goverlayform.RefreshHomeMakoStatus;
    AssertTrue('Home tab module 6 shows arrow indicator', Pos('→ 3.1.0', goverlayform.FHomeModVerLbls[6].Caption) > 0);
    AssertEquals('Home tab module 6 has accent update color ($0044AAFF)', $0044AAFF, goverlayform.FHomeModVerLbls[6].Font.Color);

    // 3. Switch back to Lossless Scaling tab and ensure update state is NOT wiped out
    goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
    AssertTrue('After switching back, update state persists on label', Pos('→ 3.1.0', Helper.MakoStatusLabel.Caption) > 0);
    AssertTrue('After switching back, install button remains visible', Helper.InstallBtn.Visible);
  finally
    // Reset state
    Helper.SetMakoUpdateState('', False);
    if FileExists(StateFile) then DeleteFile(StateFile);
  end;
end;

procedure TGoverlayGuiTests.TestLsfgVkUpdateNotificationPersistenceAndHomeSync;
var
  Helper: TLosslessScalingTabHelper;
  LayerDir, LayerFile: string;
  SL: TStringList;
begin
  LayerDir := IncludeTrailingPathDelimiter(GetUserDir) + '.local/share/vulkan/implicit_layer.d';
  ForceDirectories(LayerDir);
  LayerFile := LayerDir + '/VkLayer_LSFGVK_frame_generation.json';
  SL := TStringList.Create;
  try
    SL.Add('{"file_format_version": "1.0.0", "layer": {"name": "VK_LAYER_LSFGVK_frame_generation", "type": "GLOBAL", "library_path": "liblsfg-vk.so", "api_version": "1.3.0", "implementation_version": "1.0.0", "description": "LSFG-VK"}}');
    SL.SaveToFile(LayerFile);
  finally
    SL.Free;
  end;

  goverlayform.optiscalerLabel.OnClick(goverlayform.optiscalerLabel);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertNotNull('Helper exists', Helper);

  try
    // Simulate detecting a newer version 2.0.0 (local is 1.0.0)
    Helper.SetLsfgUpdateState('2.0.0', True);

    // 1. Check Lossless Scaling tab display
    AssertTrue('LsfgUpdateAvailable is True', Helper.LsfgUpdateAvailable);
    AssertEquals('LsfgRemoteVer is 2.0.0', '2.0.0', Helper.LsfgRemoteVer);
    AssertTrue('Lsfg status shows arrow indicator', Pos('→ 2.0.0', Helper.LsfgStatusLabel.Caption) > 0);
    AssertEquals('Lsfg status has accent update color ($0044AAFF)', $0044AAFF, Helper.LsfgStatusLabel.Font.Color);
    AssertTrue('Lsfg install update button is visible', Helper.LsfgInstallBtn.Visible);
    AssertEquals('Lsfg install button caption is Install update', 'Install update', Helper.LsfgInstallBtn.Caption);

    // 2. Check Home tab synchronization
    goverlayform.ShowHomeTab;
    goverlayform.RefreshHomeMakoStatus;
    AssertTrue('Home tab module 5 shows arrow indicator', Pos('→ 2.0.0', goverlayform.FHomeModVerLbls[5].Caption) > 0);
    AssertEquals('Home tab module 5 has accent update color ($0044AAFF)', $0044AAFF, goverlayform.FHomeModVerLbls[5].Font.Color);

    // 3. Switch back to Lossless Scaling tab and ensure update state is NOT wiped out
    goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
    AssertTrue('After switching back, update state persists on label', Pos('→ 2.0.0', Helper.LsfgStatusLabel.Caption) > 0);
    AssertTrue('After switching back, install button remains visible', Helper.LsfgInstallBtn.Visible);
  finally
    // Reset state
    Helper.SetLsfgUpdateState('', False);
    if FileExists(LayerFile) then DeleteFile(LayerFile);
  end;
end;

procedure TGoverlayGuiTests.TestLsfgVkBuildsHtmlParsingIgnoresGitVersion;
var
  SampleHtml, OutUrl, ExtractedVer: string;
begin
  // Upstream builds.lsfg-vk.dev HTML with git autobuild, release candidate, and stable release
  SampleHtml :=
    '<!DOCTYPE html>' + LineEnding +
    '<html><body>' + LineEnding +
    '<table>' + LineEnding +
    '<tr><td><a href="lsfg-vk-2.0.0.r1.g0e7a389.tar.xz">&gt;&gt; Latest git version (2.0.0.r1.g0e7a389) &lt;&lt;</a></td><td>08-Sep-2026 11:05</td></tr>' + LineEnding +
    '<tr><td><a href="lsfg-vk-2.0.0.tar.xz">&gt;&gt; Latest release candidate (2.0.0) &lt;&lt;</a></td><td>05-Sep-2026 16:57</td></tr>' + LineEnding +
    '<tr><td><a href="lsfg-vk-2.0.0.tar.xz">&gt;&gt; Latest release (2.0.0) &lt;&lt;</a></td><td>05-Sep-2026 16:57</td></tr>' + LineEnding +
    '</table>' + LineEnding +
    '</body></html>';

  ExtractedVer := ParseLsfgVkBuildsHtml(SampleHtml, OutUrl);
  AssertEquals('Must extract stable release version and ignore git version and RC', '2.0.0', ExtractedVer);
  AssertEquals('Must extract stable release download URL', 'https://builds.lsfg-vk.dev/lsfg-vk-2.0.0.tar.xz', OutUrl);

  // When only git autobuilds exist (no official release), Result must be empty
  SampleHtml :=
    '<tr><td><a href="lsfg-vk-2.0.0.r1.g0e7a389.tar.xz">&gt;&gt; Latest git version (2.0.0.r1.g0e7a389) &lt;&lt;</a></td></tr>';
  ExtractedVer := ParseLsfgVkBuildsHtml(SampleHtml, OutUrl);
  AssertEquals('Must return empty string when no official release is present', '', ExtractedVer);
  AssertEquals('Url must be empty string when no official release is present', '', OutUrl);
end;

procedure TGoverlayGuiTests.TestMangoHudPresetsToggleSynchronization;
var
  Helper: TMangoHudUiHelper;
begin
  goverlayform.mangohudLabel.OnClick(goverlayform.mangohudLabel);
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('MangoHud Helper is assigned', Assigned(Helper));

  // 1. Click "Full" preset (layout card 0)
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[0]);
  AssertTrue('Full preset: FhudcompactToggle is True', Helper.FhudcompactToggle.Checked);
  AssertTrue('Full preset: FgpuavgloadToggle is True', Helper.FgpuavgloadToggle.Checked);
  AssertTrue('Full preset: FfpsToggle is True', Helper.FfpsToggle.Checked);
  AssertTrue('Full preset: FdistroinfoToggle is True', Helper.FdistroinfoToggle.Checked);
  AssertFalse('Full preset: FhidehudToggle is False (excluded)', Helper.FhidehudToggle.Checked);
  AssertFalse('Full preset: FengineshortToggle is False (excluded)', Helper.FengineshortToggle.Checked);

  // 2. Click "Basic" preset (layout card 1)
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[1]);
  AssertTrue('Basic preset: FfpsToggle is True', Helper.FfpsToggle.Checked);
  AssertTrue('Basic preset: FframetimegraphToggle is True', Helper.FframetimegraphToggle.Checked);
  AssertTrue('Basic preset: FgpuavgloadToggle is True', Helper.FgpuavgloadToggle.Checked);
  AssertFalse('Basic preset: FhudcompactToggle is False', Helper.FhudcompactToggle.Checked);
  AssertFalse('Basic preset: FdistroinfoToggle is False', Helper.FdistroinfoToggle.Checked);
  AssertFalse('Basic preset: FwineToggle is False', Helper.FwineToggle.Checked);

  // 3. Click "FPS Only" preset (layout card 3)
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[3]);
  AssertFalse('FPS Only: FfpsToggle is False', Helper.FfpsToggle.Checked);
  AssertFalse('FPS Only: FgpuavgloadToggle is False', Helper.FgpuavgloadToggle.Checked);
  AssertFalse('FPS Only: FdistroinfoToggle is False', Helper.FdistroinfoToggle.Checked);

  // 4. Click "Basic Horizontal" preset (layout card 2)
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[2]);
  AssertTrue('Basic Horizontal: FfpsToggle is True', Helper.FfpsToggle.Checked);
  AssertTrue('Basic Horizontal: FengineversionToggle is True', Helper.FengineversionToggle.Checked);
  AssertFalse('Basic Horizontal: FdistroinfoToggle is False', Helper.FdistroinfoToggle.Checked);

  // 5. Test sub-tab show synchronization
  goverlayform.visualTabSheet.Show;
  goverlayform.performanceTabSheet.Show;
  goverlayform.metricsTabSheet.Show;
  goverlayform.extrasTabSheet.Show;
  AssertTrue('Toggles remain synced after sub-tab navigation', Helper.FfpsToggle.Checked);
end;

procedure TGoverlayGuiTests.TestMangoHudMetricGraphs;
var
  Helper: TMangoHudUiHelper;
  C: string;
begin
  NavigateMangoHud;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.metricsTabSheet;
  Helper := TMangoHudUiHelper(goverlayform.FMangoHelper);
  AssertTrue('MangoHud Helper assigned', Assigned(Helper));

  // 1. Verify the 8 metric toggles have HasGraphButton = True
  AssertTrue('FgpuavgloadToggle has graph button', Helper.FgpuavgloadToggle.HasGraphButton);
  AssertTrue('FvramusageToggle has graph button', Helper.FvramusageToggle.HasGraphButton);
  AssertTrue('FgpufreqToggle has graph button', Helper.FgpufreqToggle.HasGraphButton);
  AssertTrue('FgpumemfreqToggle has graph button', Helper.FgpumemfreqToggle.HasGraphButton);
  AssertTrue('FgputempToggle has graph button', Helper.FgputempToggle.HasGraphButton);
  AssertTrue('FcpuavgloadToggle has graph button', Helper.FcpuavgloadToggle.HasGraphButton);
  AssertTrue('FcputempToggle has graph button', Helper.FcputempToggle.HasGraphButton);
  AssertTrue('FramusageToggle has graph button', Helper.FramusageToggle.HasGraphButton);

  // 2. Turn on some metrics and activate graphs
  goverlayform.gpuavgloadCheckBox.Checked := True;
  Helper.FgpuavgloadToggle.GraphActive    := True;

  goverlayform.vramusageCheckBox.Checked  := True;
  Helper.FvramusageToggle.GraphActive     := True;

  goverlayform.cputempCheckBox.Checked    := True;
  Helper.FcputempToggle.GraphActive       := True;

  goverlayform.cpuavgloadCheckBox.Checked := True;
  Helper.FcpuavgloadToggle.GraphActive    := False;

  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('graphs= directive written', Pos('graphs=', C) > 0);
  AssertTrue('graphs contains gpu_load', Pos('gpu_load', C) > 0);
  AssertTrue('graphs contains vram', Pos('vram', C) > 0);
  AssertTrue('graphs contains cpu_temp', Pos('cpu_temp', C) > 0);
  AssertFalse('graphs does not contain cpu_load when graph not active', Pos('graphs=cpu_load', C) > 0);

  // 3. Test reload roundtrip
  goverlayform.LoadMangoHudConfig;
  AssertTrue('gpuavgload reloaded checked', goverlayform.gpuavgloadCheckBox.Checked);
  AssertTrue('FgpuavgloadToggle reloaded GraphActive', Helper.FgpuavgloadToggle.GraphActive);
  AssertTrue('vramusage reloaded checked', goverlayform.vramusageCheckBox.Checked);
  AssertTrue('FvramusageToggle reloaded GraphActive', Helper.FvramusageToggle.GraphActive);
  AssertTrue('cputemp reloaded checked', goverlayform.cputempCheckBox.Checked);
  AssertTrue('FcputempToggle reloaded GraphActive', Helper.FcputempToggle.GraphActive);
  AssertFalse('FcpuavgloadToggle reloaded GraphActive is False', Helper.FcpuavgloadToggle.GraphActive);

  // 4. Test disabling a metric disables its graph output
  goverlayform.gpuloadcolorCheckBox.Checked := False;
  goverlayform.gpuavgloadCheckBox.Checked := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('graphs= still present', Pos('graphs=', C) > 0);
  AssertTrue('graphs contains vram,cpu_temp', (Pos('graphs=vram,cpu_temp', C) > 0) or (Pos('graphs=cpu_temp,vram', C) > 0));
  AssertFalse('gpu_load omitted from graphs line', (Pos('graphs=gpu_load', C) > 0) or (Pos(',gpu_load', C) > 0) or (Pos('gpu_load,', C) > 0));

  // 5. Test turning off all graphs removes graphs= line
  Helper.FvramusageToggle.GraphActive := False;
  Helper.FcputempToggle.GraphActive := False;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertFalse('graphs= omitted when no graphs active', Pos('graphs=', C) > 0);

  // 6. Test preset activation always resets graphs
  goverlayform.gpuavgloadCheckBox.Checked := True;
  Helper.FgpuavgloadToggle.GraphActive := True;
  goverlayform.cputempCheckBox.Checked := True;
  Helper.FcputempToggle.GraphActive := True;
  SaveMango;
  C := ReadFileText(MangoConfPath);
  AssertTrue('graphs active before preset', Pos('graphs=', C) > 0);

  // Click Full preset
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[0]);
  AssertFalse('Full preset resets FgpuavgloadToggle graph', Helper.FgpuavgloadToggle.GraphActive);
  AssertFalse('Full preset resets FcputempToggle graph', Helper.FcputempToggle.GraphActive);
  C := ReadFileText(MangoConfPath);
  AssertFalse('Full preset writes no graphs=', Pos('graphs=', C) > 0);

  // Click Basic preset
  goverlayform.vramusageCheckBox.Checked := True;
  Helper.FvramusageToggle.GraphActive := True;
  SaveMango;
  Helper.PresetCardClick(goverlayform.FPresetLayoutCards[1]);
  AssertFalse('Basic preset resets FvramusageToggle graph', Helper.FvramusageToggle.GraphActive);
  C := ReadFileText(MangoConfPath);
  AssertFalse('Basic preset writes no graphs=', Pos('graphs=', C) > 0);
end;

procedure TGoverlayGuiTests.TestPreviewLaunchEnvironmentHonorsToolToggles;
var
  GlobalConfPath: string;
  Ini: TIniFile;
begin
  goverlayform.FActiveGameName := '';
  GlobalConfPath := goverlayform.GetGameConfigDir('') + 'bgmod.conf';
  ForceDirectories(ExtractFilePath(GlobalConfPath));

  Ini := TIniFile.Create(GlobalConfPath);
  try
    Ini.WriteString('Env', 'CUSTOM_PREVIEW_TEST', 'active_tweak');
  finally
    Ini.Free;
  end;

  // 1. When all tools are enabled in global mode
  goverlayform.FNavToolEnabled[0] := True;
  goverlayform.FNavToolEnabled[1] := True;
  goverlayform.FNavToolEnabled[2] := True;
  goverlayform.FNavToolEnabled[3] := True;

  AssertTrue('GetMangoHudLaunchEnv includes MANGOHUD=1 when enabled', Pos('MANGOHUD=1', goverlayform.GetMangoHudLaunchEnv) > 0);
  AssertTrue('GetVkBasaltLaunchEnv includes ENABLE_VKBASALT=1 when enabled', Pos('ENABLE_VKBASALT=1', goverlayform.GetVkBasaltLaunchEnv) > 0);
  AssertTrue('GetVkSumiLaunchEnv includes ENABLE_VKSUMI=1 when enabled', Pos('ENABLE_VKSUMI=1', goverlayform.GetVkSumiLaunchEnv) > 0);
  AssertTrue('GetTweaksLaunchEnv includes CUSTOM_PREVIEW_TEST when enabled', Pos('CUSTOM_PREVIEW_TEST="active_tweak"', goverlayform.GetTweaksLaunchEnv) > 0);

  // 2. When tools are disabled in global mode
  goverlayform.FNavToolEnabled[0] := False;
  goverlayform.FNavToolEnabled[1] := False;
  goverlayform.FNavToolEnabled[2] := False;
  goverlayform.FNavToolEnabled[3] := False;

  AssertTrue('GetMangoHudLaunchEnv suppresses MangoHud when disabled globally', Pos('MANGOHUD=0', goverlayform.GetMangoHudLaunchEnv) > 0);
  AssertTrue('GetMangoHudLaunchEnv sets DISABLE_MANGOHUD=1 when disabled globally', Pos('DISABLE_MANGOHUD=1', goverlayform.GetMangoHudLaunchEnv) > 0);
  AssertTrue('GetVkBasaltLaunchEnv sets ENABLE_VKBASALT=0 when disabled globally', Pos('ENABLE_VKBASALT=0', goverlayform.GetVkBasaltLaunchEnv) > 0);
  AssertTrue('GetVkSumiLaunchEnv sets ENABLE_VKSUMI=0 when disabled globally', Pos('ENABLE_VKSUMI=0', goverlayform.GetVkSumiLaunchEnv) > 0);
  AssertEquals('GetLosslessScalingLaunchEnv is empty when disabled globally', '', goverlayform.GetLosslessScalingLaunchEnv);
  AssertEquals('GetTweaksLaunchEnv is empty when disabled globally', '', goverlayform.GetTweaksLaunchEnv);

  // 3. When in game-specific mode
  goverlayform.FActiveGameName := 'TestGamePreview';
  goverlayform.FNavToolEnabled[0] := False;
  AssertTrue('GetMangoHudLaunchEnv suppresses MangoHud when disabled for game', Pos('MANGOHUD=0', goverlayform.GetMangoHudLaunchEnv) > 0);

  goverlayform.FNavToolEnabled[0] := True;
  AssertTrue('GetMangoHudLaunchEnv includes MANGOHUD=1 when enabled for game', Pos('MANGOHUD=1', goverlayform.GetMangoHudLaunchEnv) > 0);
  AssertTrue('GetMangoHudLaunchEnv includes config file prefix for game', Pos('MANGOHUD_CONFIGFILE=', goverlayform.GetMangoHudLaunchEnv) > 0);

  // Cleanup
  goverlayform.FActiveGameName := '';
  goverlayform.FNavToolEnabled[0] := True;
  goverlayform.FNavToolEnabled[1] := True;
  goverlayform.FNavToolEnabled[2] := True;
  goverlayform.FNavToolEnabled[3] := True;
  goverlayform.ApplyToolEnabledState(0, True);
  goverlayform.ApplyToolEnabledState(1, True);
  goverlayform.ApplyToolEnabledState(2, True);
  goverlayform.ApplyToolEnabledState(3, True);
end;

procedure TGoverlayGuiTests.TestFastGamesTabReturnAndInPlaceBadgeUpdate;
var
  TestCard: TPanel;
  TestCardImg: TImage;
  SavedCardRef: TPanel;
  CfgDir, BaseHintText: string;
  i: Integer;
  HasBadge2: Boolean;
begin
  goverlayform.FGamesLoaded := True;
  if not Assigned(goverlayform.FCardPanels) then
    goverlayform.FCardPanels := TList.Create;

  // Create a mock game card
  TestCard := TPanel.Create(goverlayform.FGamesScrollBox);
  BaseHintText := '(777777) FastNavTestGame' + LineEnding + '/path/to/fastnav';
  TestCard.Hint := BaseHintText;
  TestCard.Tag := 0;
  TestCardImg := TImage.Create(TestCard);
  TestCardImg.Tag := 9995;
  TestCardImg.Parent := TestCard;
  TestCardImg.Hint := BaseHintText;

  goverlayform.FCardPanels.Add(TestCard);
  SavedCardRef := TestCard;

  CfgDir := goverlayform.GetGameConfigDir('FastNavTestGame');
  if DirectoryExists(CfgDir) then
    DeleteDirectory(CfgDir, False);

  try
    // 1. Enter game configuration mode for the test game
    goverlayform.GameCardClick(TestCard);
    AssertEquals('Active game is FastNavTestGame', 'FastNavTestGame', goverlayform.FActiveGameName);

    // 2. Configure a tool by creating MangoHud.conf
    ForceDirectories(CfgDir);
    FileClose(FileCreate(CfgDir + 'MangoHud.conf'));

    // 3. Return to Games tab via gamesLabelClick
    goverlayform.gamesLabelClick(nil);

    // Verify mode is reset to global
    AssertEquals('Active game cleared after return', '', goverlayform.FActiveGameName);

    // Verify card panel reference is preserved in memory (instantaneous return, no rebuild)
    AssertTrue('TestCard pointer remains intact in FCardPanels',
      (goverlayform.FCardPanels.IndexOf(SavedCardRef) >= 0) and (SavedCardRef = TestCard));

    // Verify badge bitmask and tooltip
    AssertEquals('Card Tag updated with MangoHud bitmask (1)', 1, TestCard.Tag);
    AssertTrue('Card Hint contains MangoHud enabled line',
      Pos('• MangoHud: Enabled', TestCard.Hint) > 0);

    // Verify badge image (Tag = 2) was added
    HasBadge2 := False;
    for i := 0 to TestCard.ControlCount - 1 do
      if (TestCard.Controls[i] is TImage) and (TestCard.Controls[i].Tag = 2) then
      begin
        HasBadge2 := True;
        AssertTrue('Badge image hint matches panel hint',
          TImage(TestCard.Controls[i]).Hint = TestCard.Hint);
        Break;
      end;
    AssertTrue('Badge image with Tag 2 exists on card', HasBadge2);

    // 4. Update configuration: add OptiScaler
    FileClose(FileCreate(CfgDir + 'OptiScaler.ini'));
    goverlayform.GameCardClick(TestCard);
    goverlayform.gamesLabelClick(nil);

    AssertEquals('Card Tag updated with MangoHud + OptiScaler (1 + 4 = 5)', 5, TestCard.Tag);
    AssertTrue('Card Hint contains OptiScaler enabled line',
      Pos('• OptiScaler: Enabled', TestCard.Hint) > 0);

    // 5. Remove all tools: delete config files
    DeleteFile(CfgDir + 'MangoHud.conf');
    DeleteFile(CfgDir + 'OptiScaler.ini');
    goverlayform.GameCardClick(TestCard);
    goverlayform.gamesLabelClick(nil);

    // Verify badge bitmask is 0 and badge image is removed
    AssertEquals('Card Tag reset to 0', 0, TestCard.Tag);
    HasBadge2 := False;
    for i := 0 to TestCard.ControlCount - 1 do
      if (TestCard.Controls[i] is TImage) and (TestCard.Controls[i].Tag = 2) then
      begin
        HasBadge2 := True;
        Break;
      end;
    AssertFalse('Badge image with Tag 2 removed when no tools enabled', HasBadge2);
    AssertFalse('Badge header removed from hint',
      Pos('Enabled Goverlay Tools:', TestCard.Hint) > 0);
    AssertEquals('Card Hint restored to original base hint', BaseHintText, TestCard.Hint);

  finally
    goverlayform.FCardPanels.Remove(TestCard);
    TestCard.Free;
    if DirectoryExists(CfgDir) then
      DeleteDirectory(CfgDir, False);
    goverlayform.gamesLabelClick(nil);
  end;
end;

procedure TGoverlayGuiTests.TestDownloadProgressNoFloatingBanner;
begin
  goverlayform.FFloatingProgress.HideProgress;
  AssertFalse('FFloatingProgress initially hidden', goverlayform.FFloatingProgress.Visible);

  // 1. OptiScaler / DLSS-Enabler update button does not show floating progress banner
  goverlayform.updateBitBtnClick(nil);
  AssertFalse('FFloatingProgress not visible after updateBitBtnClick', goverlayform.FFloatingProgress.Visible);

  // 2. Navigate to vkBasalt tab to initialize its controls
  goverlayform.vkbasaltLabelClick(nil);

  // Reshade git progress updates in-card bar without showing floating banner
  goverlayform.ReshadeGitProgress('Downloading shaders', 50);
  AssertFalse('FFloatingProgress not visible during ReshadeGitProgress', goverlayform.FFloatingProgress.Visible);
  if Assigned(goverlayform.FReshadeProgressBar) then
    AssertEquals('FReshadeProgressBar updated in-card', 50, goverlayform.FReshadeProgressBar.Position);
end;

procedure TGoverlayGuiTests.TestLsfgSteamBetaNoticeDialog;
var
  Helper: TLosslessScalingTabHelper;
  NoticeDlg: TLSFGVkSteamBetaNoticeDialog;
  OriginalVal: Boolean;
begin
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertNotNull('Lossless helper assigned', Helper);

  // 1. Instantiation and component verification
  NoticeDlg := TLSFGVkSteamBetaNoticeDialog.Create(nil, Helper);
  try
    AssertNotNull('Notice dialog created', NoticeDlg);
    AssertNotNull('DoNotShowAgainCheck assigned', NoticeDlg.DoNotShowAgainCheck);
    AssertNotNull('OpenFolderBtn assigned', NoticeDlg.OpenFolderBtn);
    AssertNotNull('MigrationBtn assigned', NoticeDlg.MigrationBtn);
    AssertNotNull('CloseBtn assigned', NoticeDlg.CloseBtn);
    AssertNotNull('SteamImage assigned', NoticeDlg.SteamImage);
  finally
    NoticeDlg.Free;
  end;

  // 2. HideSteamBetaNotice round-trip persistence and suppression check
  OriginalVal := Helper.HideSteamBetaNotice;
  try
    Helper.HideSteamBetaNotice := True;
    AssertTrue('HideSteamBetaNotice is True after setting True', Helper.HideSteamBetaNotice);
    AssertFalse('ShouldShowSteamBetaNotice returns False when notice is suppressed', Helper.ShouldShowSteamBetaNotice);

    Helper.HideSteamBetaNotice := False;
    AssertFalse('HideSteamBetaNotice is False after setting False', Helper.HideSteamBetaNotice);
  finally
    Helper.HideSteamBetaNotice := OriginalVal;
  end;
end;

procedure TGoverlayGuiTests.TestMethodLogoDimming;
var
  Helper: TLosslessScalingTabHelper;
begin
  goverlayform.FNavToolEnabled[2] := True;
  goverlayform.ApplyToolEnabledState(2, True);

  // --- 1. OptiScaler Tab Method Logos ---
  NavigateOptiScalerTab;
  AssertNotNull('FOptiScalerPngLogo initialized', goverlayform.FOptiScalerPngLogo);
  AssertNotNull('FOptiScalerPngLogoDimmed initialized', goverlayform.FOptiScalerPngLogoDimmed);
  AssertNotNull('FDlssEnablerPngLogo initialized', goverlayform.FDlssEnablerPngLogo);
  AssertNotNull('FDlssEnablerPngLogoDimmed initialized', goverlayform.FDlssEnablerPngLogoDimmed);
  AssertNotNull('FNoneUpscalerPngLogo initialized', goverlayform.FNoneUpscalerPngLogo);
  AssertNotNull('FNoneUpscalerPngLogoDimmed initialized', goverlayform.FNoneUpscalerPngLogoDimmed);

  // When OptiScaler is selected:
  goverlayform.optiscalerLogoImageClick(goverlayform.optiscalerLogoImage);
  AssertTrue('OptiScaler radio checked', goverlayform.optiscalerRadioButton.Checked);
  AssertFalse('DLSS Enabler radio unchecked', goverlayform.dlssenablerRadioButton.Checked);
  AssertFalse('None upscaler radio unchecked', goverlayform.noneUpscalerRadioButton.Checked);
  // All images must remain clickable (Enabled := True)
  AssertTrue('optiscalerLogoImage is enabled', goverlayform.optiscalerLogoImage.Enabled);
  AssertTrue('dlssEnablerLogoImage is enabled', goverlayform.dlssEnablerLogoImage.Enabled);
  AssertTrue('noneUpscalerLogoImage is enabled', goverlayform.noneUpscalerLogoImage.Enabled);

  // When DLSS Enabler is clicked:
  goverlayform.dlssEnablerLogoImageClick(goverlayform.dlssEnablerLogoImage);
  AssertFalse('OptiScaler radio unchecked', goverlayform.optiscalerRadioButton.Checked);
  AssertTrue('DLSS Enabler radio checked', goverlayform.dlssenablerRadioButton.Checked);
  AssertFalse('None upscaler radio unchecked', goverlayform.noneUpscalerRadioButton.Checked);
  AssertTrue('optiscalerLogoImage is enabled', goverlayform.optiscalerLogoImage.Enabled);
  AssertTrue('dlssEnablerLogoImage is enabled', goverlayform.dlssEnablerLogoImage.Enabled);
  AssertTrue('noneUpscalerLogoImage is enabled', goverlayform.noneUpscalerLogoImage.Enabled);

  // When None is clicked:
  goverlayform.noneUpscalerLogoImageClick(goverlayform.noneUpscalerLogoImage);
  AssertFalse('OptiScaler radio unchecked', goverlayform.optiscalerRadioButton.Checked);
  AssertFalse('DLSS Enabler radio unchecked', goverlayform.dlssenablerRadioButton.Checked);
  AssertTrue('None upscaler radio checked', goverlayform.noneUpscalerRadioButton.Checked);
  AssertTrue('optiscalerLogoImage is enabled', goverlayform.optiscalerLogoImage.Enabled);
  AssertTrue('dlssEnablerLogoImage is enabled', goverlayform.dlssEnablerLogoImage.Enabled);
  AssertTrue('noneUpscalerLogoImage is enabled', goverlayform.noneUpscalerLogoImage.Enabled);

  // --- 2. Lossless Scaling Tab Method Logos ---
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  Helper := TLosslessScalingTabHelper(goverlayform.FLosslessScalingHelper);
  AssertNotNull('Lossless helper assigned', Helper);
  AssertNotNull('FNonePngLogo initialized', Helper.NonePngLogo);
  AssertNotNull('FNonePngDimmed initialized', Helper.NonePngDimmed);
  AssertNotNull('FLsfgPngLogo initialized', Helper.LsfgPngLogo);
  AssertNotNull('FLsfgPngDimmed initialized', Helper.LsfgPngDimmed);
  AssertNotNull('FMakoPngLogo initialized', Helper.MakoPngLogo);
  AssertNotNull('FMakoPngDimmed initialized', Helper.MakoPngDimmed);

  // Clicking None image
  Helper.NoneImage.OnClick(Helper.NoneImage);
  AssertEquals('InterpolationMethod is imNone', Ord(imNone), Ord(Helper.InterpolationMethod));
  AssertTrue('NoneRadio is checked', Helper.NoneRadio.Checked);
  AssertFalse('LsfgRadio is unchecked', Helper.LsfgRadio.Checked);
  AssertFalse('MakoRadio is unchecked', Helper.MakoRadio.Checked);
  AssertTrue('NoneImage is enabled', Helper.NoneImage.Enabled);
  AssertTrue('LsfgImage is enabled', Helper.LsfgImage.Enabled);
  AssertTrue('MakoImage is enabled', Helper.MakoImage.Enabled);

  // Clicking Lsfg image
  Helper.LsfgImage.OnClick(Helper.LsfgImage);
  AssertEquals('InterpolationMethod is imLsfg', Ord(imLsfg), Ord(Helper.InterpolationMethod));
  AssertFalse('NoneRadio is unchecked', Helper.NoneRadio.Checked);
  AssertTrue('LsfgRadio is checked', Helper.LsfgRadio.Checked);
  AssertFalse('MakoRadio is unchecked', Helper.MakoRadio.Checked);
  AssertTrue('NoneImage is enabled', Helper.NoneImage.Enabled);
  AssertTrue('LsfgImage is enabled', Helper.LsfgImage.Enabled);
  AssertTrue('MakoImage is enabled', Helper.MakoImage.Enabled);

  // Clicking Mako image
  Helper.MakoImage.OnClick(Helper.MakoImage);
  AssertEquals('InterpolationMethod is imMako', Ord(imMako), Ord(Helper.InterpolationMethod));
  AssertFalse('NoneRadio is unchecked', Helper.NoneRadio.Checked);
  AssertFalse('LsfgRadio is unchecked', Helper.LsfgRadio.Checked);
  AssertTrue('MakoRadio is checked', Helper.MakoRadio.Checked);
  AssertTrue('NoneImage is enabled', Helper.NoneImage.Enabled);
  AssertTrue('LsfgImage is enabled', Helper.LsfgImage.Enabled);
  AssertTrue('MakoImage is enabled', Helper.MakoImage.Enabled);
end;

procedure TGoverlayGuiTests.TestCloneGlobalConfigsToGameCard;
var
  GlobalConfDir, GameConfDir, GlobalMango, GlobalBgmod, BGTemplate: string;
  CardPanel: TPanel;
  Ini: TIniFile;
  Lines: TStringList;
  IdxPrefix, IdxClone: Integer;
begin
  GlobalConfDir := IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir(''));
  ForceDirectories(GlobalConfDir);

  // 1. Seed global MangoHud.conf and bgmod.conf
  GlobalMango := GlobalConfDir + 'MangoHud.conf';
  Lines := TStringList.Create;
  try
    Lines.Text := 'fps_limit=120' + LineEnding + 'hud_title=GlobalTitleTest';
    Lines.SaveToFile(GlobalMango);

    GlobalBgmod := GlobalConfDir + 'bgmod.conf';
    Lines.Clear;
    Lines.Add('[Config]');
    Lines.Add('GOVERLAY_MANGOHUD=1');
    Lines.Add('GOVERLAY_VKBASALT=0');
    Lines.Add('GOVERLAY_OPTISCALER=0');
    Lines.Add('GOVERLAY_TWEAKS=1');
    Lines.Add('[Env]');
    Lines.Add('MANGOHUD_CONFIGFILE=' + GlobalMango);
    Lines.SaveToFile(GlobalBgmod);

    // Seed bgmod template directory so wrappers can be copied
    BGTemplate := IncludeTrailingPathDelimiter(GetBGModPath);
    ForceDirectories(BGTemplate);
    Lines.Text := '#!/bin/sh' + LineEnding + 'exit 0';
    Lines.SaveToFile(BGTemplate + 'bgmod');
    Lines.SaveToFile(BGTemplate + 'bgmod-uninstaller');
  finally
    Lines.Free;
  end;

  // 2. Verify FCloneGlobalMenuItem exists in FGameCardMenu and order is below FOpenPrefixMenuItem
  AssertNotNull('FGameCardMenu is initialized', goverlayform.FGameCardMenu);
  AssertNotNull('FCloneGlobalMenuItem is initialized', goverlayform.FCloneGlobalMenuItem);
  AssertNotNull('FOpenPrefixMenuItem is initialized', goverlayform.FOpenPrefixMenuItem);

  IdxPrefix := goverlayform.FGameCardMenu.Items.IndexOf(goverlayform.FOpenPrefixMenuItem);
  IdxClone  := goverlayform.FGameCardMenu.Items.IndexOf(goverlayform.FCloneGlobalMenuItem);
  AssertTrue('FOpenPrefixMenuItem exists in menu', IdxPrefix >= 0);
  AssertTrue('FCloneGlobalMenuItem exists in menu', IdxClone >= 0);
  AssertEquals('FCloneGlobalMenuItem is immediately below FOpenPrefixMenuItem', IdxPrefix + 1, IdxClone);

  // 3. Test Clone to unconfigured game
  GameConfDir := IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir('CloneCardTestGame'));
  if DirectoryExists(GameConfDir) then
    DeleteDirectory(GameConfDir, False);

  CardPanel := TPanel.Create(nil);
  try
    CardPanel.Hint := '(99999) CloneCardTestGame' + LineEnding + '/fake/game/path';
    goverlayform.FRightClickedCard := CardPanel;

    goverlayform.GameCardCloneGlobalClick(nil);

    // Verify cloned files exist in target game dir
    AssertTrue('MangoHud.conf cloned to game dir', FileExists(GameConfDir + 'MangoHud.conf'));
    AssertTrue('bgmod.conf cloned to game dir', FileExists(GameConfDir + 'bgmod.conf'));
    AssertTrue('bgmod wrapper exists', FileExists(GameConfDir + 'bgmod'));
    AssertTrue('bgmod-uninstaller exists', FileExists(GameConfDir + 'bgmod-uninstaller'));

    // Verify MANGOHUD_CONFIGFILE was rewritten to target game dir
    Ini := TIniFile.Create(GameConfDir + 'bgmod.conf');
    try
      AssertEquals('MANGOHUD_CONFIGFILE rewritten to game dir',
                   GameConfDir + 'MangoHud.conf',
                   Ini.ReadString('Env', 'MANGOHUD_CONFIGFILE', ''));
      AssertEquals('GOVERLAY_MANGOHUD preserved as 1',
                   '1',
                   Ini.ReadString('Config', 'GOVERLAY_MANGOHUD', '0'));
    finally
      Ini.Free;
    end;
  finally
    CardPanel.Free;
    goverlayform.FRightClickedCard := nil;
  end;
end;

procedure TGoverlayGuiTests.TestCloneGlobalConfigsDockMenu;
var
  GlobalConfDir, GameConfDir, GlobalMango: string;
  Lines: TStringList;
begin
  // 1. Verify cloneGlobalDockMenuItem exists in popsaveMenu
  AssertNotNull('cloneGlobalDockMenuItem is created', goverlayform.cloneGlobalDockMenuItem);
  AssertTrue('cloneGlobalDockMenuItem is in popsaveMenu',
             goverlayform.popsaveMenu.Items.IndexOf(goverlayform.cloneGlobalDockMenuItem) >= 0);

  // 2. In global mode (FActiveGameName = ''), verify cloneGlobalDockMenuItem is hidden
  goverlayform.FActiveGameName := '';
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertFalse('cloneGlobalDockMenuItem hidden in global mode',
              goverlayform.cloneGlobalDockMenuItem.Visible);

  // 3. In game mode (FActiveGameName <> ''), verify cloneGlobalDockMenuItem is visible
  goverlayform.FActiveGameName := 'DockCloneGameTest';
  goverlayform.UpdateDockMenuItemsVisibility;
  AssertTrue('cloneGlobalDockMenuItem visible in game mode',
             goverlayform.cloneGlobalDockMenuItem.Visible);

  // 4. Test CloneGlobalConfigToGame directly and UI reloading
  GlobalConfDir := IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir(''));
  ForceDirectories(GlobalConfDir);
  GlobalMango := GlobalConfDir + 'MangoHud.conf';
  Lines := TStringList.Create;
  try
    Lines.Text := 'custom_text_center=ClonedDockHUD' + LineEnding + 'fps';
    Lines.SaveToFile(GlobalMango);
  finally
    Lines.Free;
  end;

  GameConfDir := IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir('DockCloneGameTest'));
  if DirectoryExists(GameConfDir) then
    DeleteDirectory(GameConfDir, False);

  AssertTrue('CloneGlobalConfigToGame succeeds',
             goverlayform.CloneGlobalConfigToGame('DockCloneGameTest'));
  AssertTrue('Cloned MangoHud.conf exists in game dir',
             FileExists(GameConfDir + 'MangoHud.conf'));

  // Switch to MangoHud tab and load config
  MANGOHUDCFGFILE := GameConfDir + 'MangoHud.conf';
  goverlayform.LoadMangoHudConfig;
  AssertEquals('hudtitleEdit has cloned title', 'ClonedDockHUD', goverlayform.hudtitleEdit.Text);
  AssertTrue('fpsCheckBox is checked', goverlayform.fpsCheckBox.Checked);

  // Reset state
  goverlayform.FActiveGameName := '';
end;

procedure TGoverlayGuiTests.TestGameCardsAlphabeticalSorting;
var
  SteamAppsDir, NonSteamDir, NonSteamFile, ConfDir: string;
  SteamCacheDir, NonSteamCacheDir: string;
  Lines: TStringList;
  GamesHelper: TGamesTabHelper;

  procedure CreateDummyCover(const APath: string);
  var
    Bmp: TBitmap;
  begin
    ForceDirectories(ExtractFilePath(APath));
    Bmp := TBitmap.Create;
    try
      Bmp.SetSize(16, 16);
      Bmp.Canvas.Brush.Color := clBlack;
      Bmp.Canvas.FillRect(Rect(0, 0, 16, 16));
      Bmp.SaveToFile(APath);
    finally
      Bmp.Free;
    end;
  end;

  function GetCardTitle(APanel: TPanel): string;
  var
    L1: string;
    p: Integer;
  begin
    L1 := APanel.Hint;
    p := Pos(#10, L1);
    if p > 0 then L1 := Copy(L1, 1, p - 1);
    p := Pos(#13, L1);
    if p > 0 then L1 := Copy(L1, 1, p - 1);
    L1 := Trim(L1);
    if (Length(L1) > 0) and (L1[1] = '(') then
    begin
      p := Pos(') ', L1);
      if p > 0 then
        Result := Copy(L1, p + 2, Length(L1))
      else
        Result := L1;
    end
    else
      Result := L1;
  end;

  procedure WriteManifest(const AAppID, AName: string);
  var
    M: TStringList;
  begin
    M := TStringList.Create;
    try
      M.Add('"AppState"');
      M.Add('{');
      M.Add('  "appid" "' + AAppID + '"');
      M.Add('  "name" "' + AName + '"');
      M.Add('  "installdir" "' + AName + '"');
      M.Add('}');
      M.SaveToFile(SteamAppsDir + '/appmanifest_' + AAppID + '.acf');
    finally
      M.Free;
    end;
  end;

begin
  // Set up mock Steam library
  SteamAppsDir := IsolatedHome + '/.local/share/Steam/steamapps';
  ForceDirectories(SteamAppsDir);

  // Set up mock non-Steam games directory
  NonSteamDir := IsolatedHome + '/MockNonSteamGames';
  ForceDirectories(NonSteamDir + '/Zelda');
  ForceDirectories(NonSteamDir + '/Baldur''s Gate 3');
  ForceDirectories(NonSteamDir + '/Ark');

  ConfDir := IncludeTrailingPathDelimiter(TConfigManager.GetGoverlayFolder);
  ForceDirectories(ConfDir);
  NonSteamFile := ConfDir + 'nonsteam_folders.txt';
  Lines := TStringList.Create;
  try
    Lines.Add(NonSteamDir);
    Lines.SaveToFile(NonSteamFile);
  finally
    Lines.Free;
  end;

  // Create Steam manifests with mixed casing, digits, and "The" prefix
  WriteManifest('292030', 'The Witcher 3');
  WriteManifest('620', 'Portal 2');
  WriteManifest('282800', '100% Orange Juice');
  WriteManifest('70', 'half-life');
  WriteManifest('1091500', 'Cyberpunk 2077');

  // Seed dummy cover files so no background download threads run
  SteamCacheDir := IsolatedHome + '/.cache/goverlay/covers/';
  NonSteamCacheDir := IsolatedHome + '/.cache/goverlay/nonsteam_covers/';
  CreateDummyCover(SteamCacheDir + '292030.jpg');
  CreateDummyCover(SteamCacheDir + '620.jpg');
  CreateDummyCover(SteamCacheDir + '282800.jpg');
  CreateDummyCover(SteamCacheDir + '70.jpg');
  CreateDummyCover(SteamCacheDir + '1091500.jpg');

  CreateDummyCover(NonSteamCacheDir + SanitizeFileName('Zelda') + '.jpg');
  CreateDummyCover(NonSteamCacheDir + SanitizeFileName('Baldur''s Gate 3') + '.jpg');
  CreateDummyCover(NonSteamCacheDir + SanitizeFileName('Ark') + '.jpg');

  GamesHelper := TGamesTabHelper(goverlayform.FGamesHelper);
  GamesHelper.RefreshGameCards;

  AssertEquals('8 game cards loaded', 8, goverlayform.FCardPanels.Count);

  // Verify unified alphabetical order:
  // 1: 100% Orange Juice (number first)
  // 2: Ark (A)
  // 3: Baldur's Gate 3 (B)
  // 4: Cyberpunk 2077 (C)
  // 5: half-life (case-insensitive H)
  // 6: Portal 2 (P)
  // 7: The Witcher 3 (T, "The" kept on T)
  // 8: Zelda (Z)
  AssertEquals('Card 0 is 100% Orange Juice', '100% Orange Juice', GetCardTitle(TPanel(goverlayform.FCardPanels[0])));
  AssertEquals('Card 1 is Ark', 'Ark', GetCardTitle(TPanel(goverlayform.FCardPanels[1])));
  AssertEquals('Card 2 is Baldur''s Gate 3', 'Baldur''s Gate 3', GetCardTitle(TPanel(goverlayform.FCardPanels[2])));
  AssertEquals('Card 3 is Cyberpunk 2077', 'Cyberpunk 2077', GetCardTitle(TPanel(goverlayform.FCardPanels[3])));
  AssertEquals('Card 4 is half-life', 'half-life', GetCardTitle(TPanel(goverlayform.FCardPanels[4])));
  AssertEquals('Card 5 is Portal 2', 'Portal 2', GetCardTitle(TPanel(goverlayform.FCardPanels[5])));
  AssertEquals('Card 6 is The Witcher 3', 'The Witcher 3', GetCardTitle(TPanel(goverlayform.FCardPanels[6])));
  AssertEquals('Card 7 is Zelda', 'Zelda', GetCardTitle(TPanel(goverlayform.FCardPanels[7])));

  // Cleanup files created by test
  DeleteFile(NonSteamFile);
  DeleteDirectory(NonSteamDir, False);
  DeleteDirectory(SteamAppsDir, False);
  DeleteDirectory(SteamCacheDir, False);
  DeleteDirectory(NonSteamCacheDir, False);
  GamesHelper.RefreshGameCards;
end;

initialization
  RegisterTest(TGoverlayGuiTests);

end.
