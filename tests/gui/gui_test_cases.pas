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
    procedure TestOptiFsrVersionPinned;
    procedure TestOptiPreferredUpscalerSave;
    procedure TestOptiForceFsr4Int8Save;
    procedure TestOptiFilenameDllSave;
    procedure TestOptiChannelSave;
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
    procedure TestDlssEnablerTagMatchingNoFalseUpdate;
    procedure TestDlssEnablerUpdateStatusDisplay;
    procedure TestDlssEnablerChannelUpdateSuppressesDowngrades;
    procedure TestOptiscalerAndDlssEnablerToggleKeyDisplay;
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
    procedure TestTweaksCardLayoutAndClick;
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
    procedure TestVkBasaltRestoreDefaults;
    procedure TestVkBasaltPipelineCardVisibleAndBounds;
    procedure TestVkBasaltPipelineInteractions;
    procedure TestVkBasaltPipelineScrollOnManyEffects;
    procedure TestPerformanceFiltersLayoutOnResize;
    procedure TestMangoHudFrameTimingDetailed;
    procedure TestMangoHudMetricsCompactToggles;
    procedure TestMangoHudVisualCompactToggles;
    procedure TestMangoHudPerformanceCompactToggles;
    procedure TestMangoHudExtrasCompactToggles;
    procedure TestLosslessScalingCompactToggles;
    procedure TestMangoHudPresetsToggleSynchronization;
    procedure TestMangoHudMetricGraphs;
    procedure TestFinishConfigurationDialogModernSteamUI;
    procedure TestDockOpenConfigFileAction;
    procedure TestDynamicLaunchCommandGeneration;
  end;

implementation

uses
  overlayunit, games_tab, optiscaler_update, finish_dialog, ExtCtrls, ComCtrls, themeunit, IniFiles, FileUtil, test_isolation, Graphics, Forms, Controls, lossless_scaling_tab, vkbasalt_tab, toggle_switch, mangohud_ui;

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
  AssertTrue('Status label warns when DLL is missing', Pos('Install Lossless scaling on steam', Helper.DllStatusLabel.Caption) > 0);
  
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
    Helper.PacingComboBox.ItemIndex := 1; // vsync
    
    // Verify controls enabled when multiplier > 1
    AssertTrue('FlowScale enabled at 3x', Helper.FlowScaleTrackBar.Enabled);
    AssertTrue('PerfMode enabled at 3x', Helper.PerfModeCheckBox.Enabled);
    
    // Save configuration to bgmod.conf
    Helper.SaveLosslessConfig;
    
    TargetConfPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'bgmod.conf';
    TargetTomlPath := goverlayform.GetGameConfigDir(goverlayform.FActiveGameName) + 'lsfg.toml';
    AssertTrue('bgmod.conf was created', FileExists(TargetConfPath));
    AssertTrue('lsfg.toml was created', FileExists(TargetTomlPath));
    
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
    
    // Now test switching Multiplier to 1x (no framegen)
    Helper.MultiplierTrackBar.Position := 1;
    Helper.MultiplierTrackBar.OnChange(Helper.MultiplierTrackBar);
    AssertFalse('FlowScale disabled at 1x', Helper.FlowScaleTrackBar.Enabled);
    AssertFalse('PerfMode disabled at 1x', Helper.PerfModeCheckBox.Enabled);
    AssertFalse('HdrMode disabled at 1x', Helper.HdrModeCheckBox.Enabled);
    AssertFalse('Pacing disabled at 1x', Helper.PacingComboBox.Enabled);
    AssertFalse('Gpu disabled at 1x', Helper.GpuComboBox.Enabled);
    
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
      Helper.PacingComboBox.ItemIndex := 3; // immediate
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
      Helper.PacingComboBox.ItemIndex := 1; // vsync
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
    AssertEquals('Global restored Pacing is immediate (3)', 3, Helper.PacingComboBox.ItemIndex);

    // 5. Switch back to Game Profile and verify Game values remain intact
    goverlayform.FActiveGameName := 'TestGameIso';
    goverlayform.losslessScalingTabSheetShow(nil);

    AssertEquals('Game restored Multiplier is 2x', 2, Helper.MultiplierTrackBar.Position);
    AssertEquals('Game restored FlowScale is 60%', 60, Helper.FlowScaleTrackBar.Position);
    AssertFalse('Game restored PerfMode is False', Helper.PerfModeCheckBox.Checked);
    AssertFalse('Game restored HdrMode is False', Helper.HdrModeCheckBox.Checked);
    AssertEquals('Game restored Pacing is vsync (1)', 1, Helper.PacingComboBox.ItemIndex);

  finally
    goverlayform.FActiveGameName := '';
    if FileExists(DummyDll) then DeleteFile(DummyDll);
    if FileExists(GlobalToml) then DeleteFile(GlobalToml);
    if FileExists(GameToml) then DeleteFile(GameToml);
    if DirectoryExists(GameDir) then DeleteDirectory(GameDir, False);
  end;
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

procedure TGoverlayGuiTests.NavigateVkBasaltTab;
begin
  // Pre-create reshade-shaders so vkbasaltTabSheetShow skips the git clone
  ForceDirectories(IsolatedHome + '/.config/vkBasalt/reshade-shaders');
  AssertTrue('vkbasaltLabel.OnClick is bound', Assigned(goverlayform.vkbasaltLabel.OnClick));
  goverlayform.vkbasaltLabel.OnClick(goverlayform.vkbasaltLabel);
end;

procedure TGoverlayGuiTests.NavigateVkSumiTab;
begin
  // vkSumi has no sidebar label; it is a sibling tab next to vkBasalt.
  // Switching pages fires vkSumiTabSheetShow -> LoadVkSumiConfig.
  NavigateVkBasaltTab;
  goverlayform.goverlayPageControl.ActivePage := goverlayform.vksumiTabSheet;
end;

procedure TGoverlayGuiTests.TestNavigateVkBasaltTab;
begin
  NavigateVkBasaltTab;
  AssertTrue('vkbasalt tab is active after sidebar click',
    goverlayform.goverlayPageControl.ActivePage = goverlayform.vkbasaltTabSheet);
  AssertTrue('vksumi tab becomes visible alongside vkbasalt',
    goverlayform.vksumiTabSheet.TabVisible);
  AssertTrue('FVkToggleCard assigned',
    Assigned(goverlayform.FVkToggleCard));
  AssertTrue('FVkToggleCard fully contained within vkbasaltTabSheet',
    goverlayform.FVkToggleCard.Top + goverlayform.FVkToggleCard.Height <= goverlayform.vkbasaltTabSheet.ClientHeight);
  AssertTrue('FVkToggleCaptureBtn visible within toggle card',
    Assigned(goverlayform.FVkToggleCaptureBtn) and
    (goverlayform.FVkToggleCaptureBtn.Top + goverlayform.FVkToggleCaptureBtn.Height <= goverlayform.FVkToggleCard.Height));
  AssertTrue('FVkRestoreBtn visible within toggle card',
    Assigned(goverlayform.FVkRestoreBtn) and
    (goverlayform.FVkRestoreBtn.Top + goverlayform.FVkRestoreBtn.Height <= goverlayform.FVkToggleCard.Height));
  AssertTrue('FVkReshadeSyncBtn visible within toggle card',
    Assigned(goverlayform.FVkReshadeSyncBtn) and
    (goverlayform.FVkReshadeSyncBtn.Top + goverlayform.FVkReshadeSyncBtn.Height <= goverlayform.FVkToggleCard.Height));
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
  goverlayform.optipatcherCheckBox.Checked := True;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=true persisted', Pos('LoadAsiPlugins=true', Content) > 0);

  goverlayform.optipatcherCheckBox.Checked := False;
  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('LoadAsiPlugins=false persisted', Pos('LoadAsiPlugins=false', Content) > 0);
end;

procedure TGoverlayGuiTests.TestOptiFsrVersionPinned;
var
  Content: string;
begin
  SeedOptiScalerFiles;
  NavigateOptiScalerTab;
  // fsrversionComboBox has no OnChange binding; the pin happens via the
  // channel selector (optversionComboBoxChange -> fsrversionComboBoxChange).
  // TComboBox.ItemIndex does not fire OnChange programmatically, so invoke
  // the bound handler exactly as a user dropdown selection would.
  goverlayform.fsrversionComboBox.ItemIndex := 1;
  AssertTrue('optversionComboBox.OnChange bound', Assigned(goverlayform.optversionComboBox.OnChange));
  goverlayform.optversionComboBox.OnChange(goverlayform.optversionComboBox);
  AssertEquals('fsr version pinned to Latest (0)', 0, goverlayform.fsrversionComboBox.ItemIndex);

  SaveOpti;
  Content := ReadFileText(OptiIniPath);
  AssertTrue('Fsr4Update=auto persisted', Pos('Fsr4Update=auto', Content) > 0);
  AssertTrue('FsrAgilitySDKUpgrade=true persisted', Pos('FsrAgilitySDKUpgrade=true', Content) > 0);
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
  // fps limit edit drives the two thresholds: 120 -> 60,120
  AssertTrue('fps_value=60,120', Pos('fps_value=60,120', C) > 0);

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
  AssertTrue('gpu_load_color written', Pos('gpu_load_color=', C) > 0);
  AssertTrue('cpu_load_color written', Pos('cpu_load_color=', C) > 0);

  // Reload config into UI and assert values are restored rather than resetting to defaults
  goverlayform.LoadMangoHudConfig;
  AssertEquals('glvsyncComboBox Unset index preserved', 4, goverlayform.glvsyncComboBox.ItemIndex);
  AssertEquals('fpscolor1 restored', TColor($000000FF), TColor(goverlayform.fpscolor1ColorButton.ButtonColor));
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

procedure TGoverlayGuiTests.TestTweaksCardLayoutAndClick;
begin
  NavigateTweaksTab;
  AssertTrue('FTweaksPaintBox is created', Assigned(goverlayform.FTweaksPaintBox));

  // Verify that toggling via simulated mouse click updates checkbox state
  goverlayform.simdeckCheckBox.Checked := False;
  // Click first item (General card -> Simulate Steam Deck hardware)
  goverlayform.TweaksMD3MouseDown(goverlayform.FTweaksPaintBox, mbLeft, [], 30, 50);
  AssertTrue('simdeckCheckBox is checked after clicking item', goverlayform.simdeckCheckBox.Checked);

  // Click again to toggle off
  goverlayform.TweaksMD3MouseDown(goverlayform.FTweaksPaintBox, mbLeft, [], 30, 50);
  AssertFalse('simdeckCheckBox is unchecked after second click', goverlayform.simdeckCheckBox.Checked);

  // Trigger hover and paint
  goverlayform.TweaksMD3MouseMove(goverlayform.FTweaksPaintBox, [], 30, 50);
  goverlayform.TweaksMD3Paint(goverlayform.FTweaksPaintBox);
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

  // Assert pipeline card is positioned between built-in card and toggle card
  AssertTrue('PipelineCard is below BuiltinCard',
    goverlayform.FVkPipelineCard.Top >= goverlayform.FVkBuiltinCard.Top + goverlayform.FVkBuiltinCard.Height);
  AssertTrue('ToggleCard is below PipelineCard',
    goverlayform.FVkToggleCard.Top >= goverlayform.FVkPipelineCard.Top + goverlayform.FVkPipelineCard.Height);
  AssertTrue('ToggleCard is fully contained inside vkbasaltTabSheet',
    goverlayform.FVkToggleCard.Top + goverlayform.FVkToggleCard.Height <= goverlayform.vkbasaltTabSheet.ClientHeight);
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
    finally
      Dlg2.Free;
    end;

    // Switch back to Steam
    Dlg.SteamBtnClick(nil);
    Dlg.PaintAnimSteam(Bmp.Canvas, 540, 180);
    AssertTrue('Steam instructions restored after switching back',
      Pos('Properties › General', Dlg.FStepsLabel.Caption) > 0);

    AssertTrue('Modern Steam and Heroic finish dialogs painted successfully', True);
  finally
    Bmp.Free;
    Dlg.Free;
  end;
end;

procedure TGoverlayGuiTests.TestDockOpenConfigFileAction;
begin
  // 1. Verify openConfigFileMenuItem exists and is configured in popsaveMenu
  AssertNotNull('openConfigFileMenuItem exists in goverlayform', goverlayform.openConfigFileMenuItem);
  AssertEquals('openConfigFileMenuItem caption', 'Open config file', goverlayform.openConfigFileMenuItem.Caption);
  AssertEquals('openConfigFileMenuItem ImageIndex', 39, goverlayform.openConfigFileMenuItem.ImageIndex);

  // 2. MangoHud tab: verify floating dock shows Menu and popupBitBtnClick sets openConfigFileMenuItem.Visible
  NavigateMangoHud;
  AssertTrue('FFADock visible on MangoHud tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on MangoHud tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on MangoHud', goverlayform.openConfigFileMenuItem.Visible);

  // 3. vkBasalt tab: verify floating dock shows Menu and popupBitBtnClick sets openConfigFileMenuItem.Visible
  NavigateVkBasaltTab;
  AssertTrue('FFADock visible on vkBasalt tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on vkBasalt tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on vkBasalt', goverlayform.openConfigFileMenuItem.Visible);

  // 4. OptiScaler tab: verify floating dock shows Menu and popupBitBtnClick sets openConfigFileMenuItem.Visible
  NavigateOptiScalerTab;
  AssertTrue('FFADock visible on OptiScaler tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on OptiScaler tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on OptiScaler', goverlayform.openConfigFileMenuItem.Visible);

  // 5. Lossless Scaling tab: verify floating dock shows Menu and popupBitBtnClick sets openConfigFileMenuItem.Visible
  goverlayform.optiscalerLabelClick(nil);
  goverlayform.goverlayPageControl.ActivePage := goverlayform.losslessScalingTabSheet;
  goverlayform.losslessScalingTabSheetShow(nil);
  AssertTrue('FFADock visible on Lossless Scaling tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on Lossless Scaling tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on Lossless Scaling', goverlayform.openConfigFileMenuItem.Visible);

  // 6. Tweaks tab: verify floating dock shows Menu and popupBitBtnClick sets openConfigFileMenuItem.Visible
  NavigateTweaksTab;
  AssertTrue('FFADock visible on Tweaks tab', Assigned(goverlayform.FFADock) and goverlayform.FFADock.Visible);
  AssertTrue('FFADock menu button visible on Tweaks tab', goverlayform.FFADock.MenuVisible);
  goverlayform.popupBitBtnClick(nil);
  AssertTrue('openConfigFileMenuItem visible on Tweaks', goverlayform.openConfigFileMenuItem.Visible);
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
  AssertTrue('frametimedetailedCheckBox assigned', Assigned(goverlayform.frametimedetailedCheckBox));
  AssertEquals('frametimedetailedCheckBox caption', 'Frame Time +', goverlayform.frametimedetailedCheckBox.Caption);

  // 1. Initial state: frametimegraph unchecked -> detailed is disabled & unchecked
  goverlayform.frametimegraphCheckBox.Checked := False;
  AssertFalse('frametimedetailedCheckBox disabled when frametime is unchecked', goverlayform.frametimedetailedCheckBox.Enabled);
  AssertFalse('frametimedetailedCheckBox unchecked when frametime is unchecked', goverlayform.frametimedetailedCheckBox.Checked);

  // 2. Checking frametimegraphCheckBox enables frametimedetailedCheckBox
  goverlayform.frametimegraphCheckBox.Checked := True;
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

  // 1. When Multiplier is 1 (inactive frame gen), toggles are disabled
  Helper.MultiplierTrackBar.Position := 1;
  Helper.UpdateControlsEnabled;
  AssertFalse('PerfModeToggle is disabled when multiplier is 1', Helper.PerfModeToggle.Enabled);
  AssertFalse('HdrModeToggle is disabled when multiplier is 1', Helper.HdrModeToggle.Enabled);
  AssertFalse('NoFp16Toggle is disabled when multiplier is 1', Helper.NoFp16Toggle.Enabled);

  // 2. When Multiplier > 1 (active frame gen), toggles are enabled
  Helper.MultiplierTrackBar.Position := 2;
  Helper.UpdateControlsEnabled;
  AssertTrue('PerfModeToggle is enabled when multiplier is 2', Helper.PerfModeToggle.Enabled);
  AssertTrue('HdrModeToggle is enabled when multiplier is 2', Helper.HdrModeToggle.Enabled);
  AssertTrue('NoFp16Toggle is enabled when multiplier is 2', Helper.NoFp16Toggle.Enabled);

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
end;

initialization
  RegisterTest(TGoverlayGuiTests);

end.
