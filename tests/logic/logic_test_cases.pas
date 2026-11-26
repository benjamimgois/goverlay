unit logic_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, pe_utils;

type
  TDriverPreferenceTests = class(TTestCase)
  published
    procedure TestRoundTrip;
    procedure TestLowercasesValue;
  end;

  TOptiScalerIniTests = class(TTestCase)
  published
    procedure TestIniRoundTrip;
    procedure TestSectionBracketFlexibility;
    procedure TestDlssNrConfigRoundTrip;
    procedure TestDlssNrResolvedArchPersistence;
    procedure TestDlssNrIniGeneration;
    procedure TestDlssNrDirectFileDeploymentAndManifestCleanup;
    procedure TestDlssNr009CacheAndManifestLayout;
    procedure TestIsDlssNrInstalledFallbackArchitecture;
    procedure TestDlssNrArchitecturePathResolution;
    procedure TestParseDlssNr32Release;
    procedure TestExtractDlssNrModelTargetsRequestedArch;
    procedure TestMakeDlssNrDerivedNetworks;
    procedure TestHelixSrConfigRoundTrip;
    procedure TestHelixSrIniGeneration;
  end;

  TSandboxIsolationTests = class(TTestCase)
  published
    procedure TestIsSafeSandboxDirValid;
    procedure TestIsSafeSandboxDirRejectsUnsafePaths;
    procedure TestIsSafeSandboxDirRejectsTraversal;
    procedure TestIsSafeSandboxDirAcceptsDottedNames;
  end;

  TVkSumiLogicTests = class(TTestCase)
  published
    procedure TestIsVkSumiAtDefaults;
    procedure TestSaveVkSumiConfigDefaultsFlag;
    procedure TestSaveVkSumiConfigCustomizedFlag;
  end;

  TVkBasaltLogicTests = class(TTestCase)
  published
    procedure TestPipelineEffectsSerializationOrder;
    procedure TestPipelineEffectsLoadOrder;
    procedure TestFallbackWhenPipelineEffectsNil;
    procedure TestLutSerializationAndLoad;
    procedure TestVkBasaltManifestOptInStructure;
    procedure TestVkBasaltSanitizationCleansCorruptManifest;
  end;

  TGpuNameExtractionTests = class(TTestCase)
  published
    procedure TestAmdGpuExtraction;
    procedure TestNvidiaGpuExtraction;
    procedure TestIntelGpuExtraction;
    procedure TestIntelArcExtraction;
    procedure TestSteamDeckCustomGpuExtraction;
    procedure TestFullLspciPrefixHandling;
  end;

  TMangoHudGpuListTests = class(TTestCase)
  published
    procedure TestGpuListSinglePrimary;
    procedure TestGpuListSingleSecondary;
    procedure TestGpuListBothGpus;
  end;

  TMangoHudFlatpakIsolationTests = class(TTestCase)
  published
    procedure TestPerGameSaveDoesNotOverwriteSteamFlatpak;
    procedure TestPerGameFpsOnlyDoesNotOverwriteSteamFlatpak;
    procedure TestGlobalSaveMirrorsToSteamFlatpak;
  end;

  TMangoHudColorParsingTests = class(TTestCase)
  published
    procedure TestHexToColorParsing;
    procedure TestOptiForceReflexLoadingLogic;
  end;

  TClearConfigTests = class(TTestCase)
  published
    procedure TestPreserveNonEmptyBackups;
    procedure TestPruneEmptyBackupsAndDirectories;
    procedure TestMultipleGamesMixed;
  end;

  TMakoLogicTests = class(TTestCase)
  published
    procedure TestMakoInstalledCheck;
    procedure TestMakoVersionParsing;
    procedure TestMakoLibraryPathDetection;
    procedure TestMakoRemoteVersionUrlResolution;
  end;

  TLsfgVkManifestTests = class(TTestCase)
  published
    procedure TestPatchLsfgVkManifest;
  end;

  TBgmodSupervisorTests = class(TTestCase)
  public
    procedure EnsureBgmodBinary;
    procedure RunReShadeArchCase(const ACaseName, AExeKind, AExpectedDll, AUnexpectedDll: string);
  published
    procedure TestSupervisorExitCodeTrue;
    procedure TestSupervisorExitCodeFalse;
    procedure TestSupervisorStderrClosure;
    procedure TestBgmodLaunchSplashGameTitleAndReShade;
    procedure TestBgmodInjectsLaunchArguments;
    procedure TestBgmodProtonArgsInjection;
    procedure TestBgmodNativeLinuxResolution;
    procedure TestBgmodCentralToolLoggingSync;
    procedure TestBgmodDlssNrDeployment;
    procedure TestBgmodDlssNrResolvedArchDeployment;
    procedure TestBgmodVkNemuEnvironmentExport;
    procedure TestBgmodReShadeOnlyDoesNotDeleteVendorDlls;
    procedure TestBgmodReShadeProxyMatchesExeArchitecture;
    procedure TestDetectPEGraphicsApi;
    procedure TestDetectLegacyDirect3DApi;
    procedure TestBgmodDlssNr32BitDx8ReShadeRoute;
    procedure TestBgmodDlssNr32BitDx9ReplacesEarlierInstalls;
    procedure TestBgmodDlssNr32BitDerivedNetworks;
    procedure TestBgmodDlssNr32BitDx8FindsDxvkD3D8;
    procedure TestResolveRealGameExecutableHeuristics;
    procedure TestBgmodReShadeD3D9ExportsD3DCompilerOverride;
    procedure TestBgmodDisabledOptiscalerWithLeftoversPreservesGenuineDlls;
    procedure TestBgmodLauncherRuleSpacelessGameName;
    procedure TestBgmodLauncherRuleCaseInsensitive;
    procedure TestBgmodSmartLauncherResolutionAndCustomRulesMerge;
    procedure TestBgmodSensitiveArgRedaction;
    procedure TestBgmodWineDllOverridesSemicolonDelimiter;
    procedure TestBgmodDisabledOptiscalerPurgesHelixSRLeftovers;
    procedure TestBgmodFlatpakPathsAndLayerExport;
    procedure TestBgmodFlatpakLaunchSplashViaFlatpakRun;
  end;

  TReShadeLogicTests = class(TTestCase)
  published
    procedure TestUnixPathToWinePath;
    procedure TestGetGOverlayBaseDataPath;
    procedure TestReShadeDirectoryLayout;
    procedure TestReShadeIniPathFormatting;
    procedure TestReShadeInstalledVersionFallbackAndMetadata;
    procedure TestParseReShadeMeHtml;
    procedure TestReShadeCoreHeadersCheck;
  end;

  TSyncGameWrapperBinariesTests = class(TTestCase)
  published
    procedure TestSyncOutdatedWrappersPreservingConfigs;
    procedure TestSyncPreservesMultipleGameDirectories;
  end;

  TBgmodSelfUpdateTests = class(TTestCase)
  published
    procedure TestFindMasterBGModDir;
    procedure TestCheckBGModNeedsUpdate;
    procedure TestPerformAtomicBinaryUpdate;
    procedure TestPerformWrapperSelfUpdate;
    procedure TestBgmodExecutableSelfUpdate;
    procedure TestBgmodExecutableSelfUpdatePreservesMultiArgs;
  end;

  TRuntimeUpdateDowngradeTests = class(TTestCase)
  published
    procedure TestExtractReleaseTagFromAtomXmlLinkHref;
    procedure TestExtractReleaseTagFromAtomXmlIdTag;
    procedure TestExtractReleaseTagFromAtomXmlEmpty;
    procedure TestSemverComparisonSemantics;
    procedure TestDowngradeSuppressionLogic;
  end;

  TShellQuoteTests = class(TTestCase)
  published
    procedure TestEmptyString;
    procedure TestPlainPath;
    procedure TestPathWithSpaces;
    procedure TestPathWithApostrophe;
    procedure TestPathWithMultipleApostrophes;
    procedure TestSpecialShellCharacters;
  end;

  TRDNAArchitectureTests = class(TTestCase)
  published
    procedure TestDetectRDNAArchitectureActiveGpu;
    procedure TestDetectRDNAArchitectureFromTextRDNA4;
    procedure TestDetectRDNAArchitectureFromTextRDNA3;
    procedure TestDetectRDNAArchitectureFromTextUnsupported;
    procedure TestRDNAArchitectureToString;
    procedure TestGetBGModDlssNrPathArch;
  end;

  TMangoHudBlacklistSyncTests = class(TTestCase)
  published
    procedure TestBlacklistSyncCreatesDefaultAndSyncs;
    procedure TestBlacklistSyncExplicitList;
    procedure TestBlacklistSyncEmptyList;
  end;

  TGoverlayLogicTests = class(TTestCase)
  published
    procedure TestModuleConfigReadWrite;
    procedure TestModuleMigrationExistingAndFresh;
    procedure TestScopedHasMissingMandatoryLibraries;
    procedure TestUninstallUserModulesAndLayers;
    procedure TestCleanProfileDefaultsUpscalerToNone;
    procedure TestFlatpakLayerAndExtensionDetection;
  end;

implementation

uses
  themeunit, configfile, configkeys, test_isolation, overlay_config, overlay_utils, configmanager, IniFiles, optiscaler_update, apputils, bgmod_resources, Process, BaseUnix, systemdetector, mangohud_ui, Graphics, FileUtil, constants;

procedure TDriverPreferenceTests.TestRoundTrip;
begin
  SaveOptiScalerDriverPreference('mesa');
  AssertEquals('mesa round-trip', 'mesa', LoadOptiScalerDriverPreference);
  SaveOptiScalerDriverPreference('nvidia');
  AssertEquals('nvidia round-trip', 'nvidia', LoadOptiScalerDriverPreference);
end;

procedure TDriverPreferenceTests.TestLowercasesValue;
begin
  SaveOptiScalerDriverPreference('MESA');
  AssertEquals('stored value is lowercased', 'mesa', LoadOptiScalerDriverPreference);
end;

procedure TOptiScalerIniTests.TestIniRoundTrip;
var
  IniPath: string;
  Cfg: TConfigFile;
  F: TextFile;
begin
  // Seed an OptiScaler.ini-style file inside the isolated HOME
  IniPath := IsolatedHome + '/OptiScaler.ini';
  AssignFile(F, IniPath);
  Rewrite(F);
  WriteLn(F, '[Upscale]');
  WriteLn(F, 'ForceReflex=false');
  WriteLn(F, 'SpoofDLSS=false');
  CloseFile(F);

  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini loads', Cfg.Load(IniPath));
    AssertFalse('ForceReflex reads false', Cfg.GetBool('ForceReflex=', True));

    // TConfigFile contract (see configkeys.pas): key prefixes include '=',
    // section names include brackets.
    Cfg.SetBool('ForceReflex=', True, '[Upscale]');
    AssertTrue('ini saves', Cfg.Save);
  finally
    Cfg.Free;
  end;

  // Reload from disk and assert persistence
  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini reloads', Cfg.Load(IniPath));
    AssertTrue('ForceReflex persisted true', Cfg.GetBool('ForceReflex=', False));
    AssertFalse('SpoofDLSS untouched', Cfg.GetBool('SpoofDLSS=', True));
  finally
    Cfg.Free;
  end;
end;

procedure TOptiScalerIniTests.TestSectionBracketFlexibility;
var
  IniPath, TextContent: string;
  Cfg: TConfigFile;
  F: TextFile;
begin
  IniPath := IsolatedHome + '/OptiScaler_SectionTest.ini';
  AssignFile(F, IniPath);
  Rewrite(F);
  WriteLn(F, '[FrameGen]');
  WriteLn(F, 'Enabled=auto');
  CloseFile(F);

  Cfg := TConfigFile.Create;
  try
    AssertTrue('ini loads', Cfg.Load(IniPath));
    // Test section matching without brackets
    Cfg.SetValue('FGInput=', 'fsrfg', 'FrameGen');
    // Test section matching with brackets
    Cfg.SetValue('FGOutput=', 'xefg', '[FrameGen]');
    // Test creating missing section without brackets
    Cfg.SetValue('NewKey=', 'val', 'NewSec');
    AssertTrue('ini saves', Cfg.Save);
  finally
    Cfg.Free;
  end;

  // Verify file content structure
  AssignFile(F, IniPath);
  Reset(F);
  TextContent := '';
  while not EOF(F) do
  begin
    ReadLn(F, IniPath); // reuse string var for line reading
    TextContent := TextContent + IniPath + #10;
  end;
  CloseFile(F);

  AssertTrue('FGInput in FrameGen', Pos('FGInput=fsrfg', TextContent) > 0);
  AssertTrue('FGOutput in FrameGen', Pos('FGOutput=xefg', TextContent) > 0);
  AssertTrue('NewSec section created with brackets', Pos('[newsec]', TextContent) > 0);
  AssertFalse('Unbracketed FrameGen section not created', Pos(#10'FrameGen'#10, TextContent) > 0);
end;

procedure TOptiScalerIniTests.TestDlssNrConfigRoundTrip;
var
  Settings, LoadedSettings: TOptiScalerSettings;
  ErrMsg, LaunchCommand: string;
begin
  Settings.ActiveGameName := 'TestDlssNrGame';
  Settings.Version := '1.0';
  Settings.Channel := 'stable';
  Settings.UpscalerTypeItemIndex := 4; // DLSS-NR
  Settings.DlssNrArchIndex := 2; // RDNA3
  Settings.DlssNrRouteIndex := 1; // ReShade Feeder
  Settings.DlssNrModelIndex := 1; // Old model
  Settings.DlssNrScaleIndex := 2; // 50%
  Settings.DlssNrInt4Checked := True;
  Settings.DlssNrRenoDxChecked := True;
  Settings.DlssNrPreprocessChecked := True;
  Settings.DlssNrPassesIndex := 1; // 2 passes
  Settings.DlssNrRunBeforeSrChecked := True;
  Settings.DlssNrFinishedPictureChecked := True;
  Settings.DlssNrSkinProtectionChecked := True;
  Settings.DlssNrModelDllPath := '/tmp/nvngx_dlssnr.dll';

  AssertTrue('SaveOptiScalerConfig succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));

  AssertTrue('LoadOptiScalerConfig succeeds', LoadOptiScalerConfig('TestDlssNrGame', LoadedSettings));
  AssertEquals('UpscalerTypeItemIndex = 4', 4, LoadedSettings.UpscalerTypeItemIndex);
  AssertEquals('DlssNrArchIndex = 2', 2, LoadedSettings.DlssNrArchIndex);
  AssertEquals('DlssNrResolvedArch = 2', 2, LoadedSettings.DlssNrResolvedArch);
  AssertEquals('DlssNrRouteIndex = 1', 1, LoadedSettings.DlssNrRouteIndex);
  AssertEquals('DlssNrModelIndex = 1', 1, LoadedSettings.DlssNrModelIndex);
  AssertEquals('DlssNrScaleIndex = 2', 2, LoadedSettings.DlssNrScaleIndex);
  AssertTrue('DlssNrInt4Checked is true', LoadedSettings.DlssNrInt4Checked);
  AssertTrue('DlssNrRenoDxChecked is true', LoadedSettings.DlssNrRenoDxChecked);
  AssertTrue('DlssNrPreprocessChecked is true', LoadedSettings.DlssNrPreprocessChecked);
  AssertEquals('DlssNrPassesIndex = 1', 1, LoadedSettings.DlssNrPassesIndex);
  AssertTrue('DlssNrRunBeforeSrChecked is true', LoadedSettings.DlssNrRunBeforeSrChecked);
  AssertTrue('DlssNrFinishedPictureChecked is true', LoadedSettings.DlssNrFinishedPictureChecked);
  AssertTrue('DlssNrSkinProtectionChecked is true', LoadedSettings.DlssNrSkinProtectionChecked);
  AssertEquals('DlssNrModelDllPath matches', '/tmp/nvngx_dlssnr.dll', LoadedSettings.DlssNrModelDllPath);
end;

procedure TOptiScalerIniTests.TestDlssNrResolvedArchPersistence;
var
  Settings, LoadedSettings: TOptiScalerSettings;
  ErrMsg, LaunchCommand, ConfPath: string;
  Ini: TIniFile;
  ResolvedArch: Integer;
begin
  Settings := Default(TOptiScalerSettings);
  Settings.ActiveGameName := 'TestDlssNrResolvedArch';
  Settings.Version := '1.0';
  Settings.Channel := 'stable';
  Settings.UpscalerTypeItemIndex := 4;
  ConfPath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';

  Settings.DlssNrArchIndex := 1;
  AssertTrue('Save RDNA4 override succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));
  AssertEquals('Resolved field is RDNA4', 1, Settings.DlssNrResolvedArch);
  Ini := TIniFile.Create(ConfPath);
  try
    AssertEquals('DLSSNR_RESOLVED_ARCH written as 1', 1,
      Ini.ReadInteger('Config', DLSSNR_KEY_RESOLVED_ARCH, 0));
  finally
    Ini.Free;
  end;
  AssertTrue('Load RDNA4 override succeeds', LoadOptiScalerConfig(Settings.ActiveGameName, LoadedSettings));
  AssertEquals('DLSSNR_RESOLVED_ARCH loaded as 1', 1, LoadedSettings.DlssNrResolvedArch);

  Settings.DlssNrArchIndex := 2;
  AssertTrue('Save RDNA3 override succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));
  AssertEquals('Resolved field is RDNA3', 2, Settings.DlssNrResolvedArch);
  Ini := TIniFile.Create(ConfPath);
  try
    AssertEquals('DLSSNR_RESOLVED_ARCH written as 2', 2,
      Ini.ReadInteger('Config', DLSSNR_KEY_RESOLVED_ARCH, 0));
  finally
    Ini.Free;
  end;
  AssertTrue('Load RDNA3 override succeeds', LoadOptiScalerConfig(Settings.ActiveGameName, LoadedSettings));
  AssertEquals('DLSSNR_RESOLVED_ARCH loaded as 2', 2, LoadedSettings.DlssNrResolvedArch);

  Settings.DlssNrArchIndex := 0;
  AssertTrue('Save auto detection succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));
  Ini := TIniFile.Create(ConfPath);
  try
    ResolvedArch := Ini.ReadInteger('Config', DLSSNR_KEY_RESOLVED_ARCH, 0);
  finally
    Ini.Free;
  end;
  AssertTrue('Auto detection writes a concrete architecture', (ResolvedArch = 1) or (ResolvedArch = 2));
  AssertEquals('Resolved field matches written auto value', ResolvedArch, Settings.DlssNrResolvedArch);
  AssertTrue('Load auto detection succeeds', LoadOptiScalerConfig(Settings.ActiveGameName, LoadedSettings));
  AssertEquals('DLSSNR_RESOLVED_ARCH loaded auto value', ResolvedArch, LoadedSettings.DlssNrResolvedArch);
end;

procedure TOptiScalerIniTests.TestDlssNrIniGeneration;
var
  Settings: TOptiScalerSettings;
  ErrMsg, IniPath, LaunchCommand: string;
  Lines: TStringList;
begin
  Settings.ActiveGameName := 'TestDlssNrIni';
  Settings.Version := '1.0';
  Settings.Channel := 'stable';
  Settings.UpscalerTypeItemIndex := 4; // DLSS-NR
  Settings.DlssNrArchIndex := 1; // RDNA4
  Settings.DlssNrRouteIndex := 0; // OptiScaler
  Settings.DlssNrModelIndex := 0; // New model
  Settings.DlssNrScaleIndex := 0; // 100%
  Settings.DlssNrInt4Checked := False;
  Settings.DlssNrRenoDxChecked := False;
  Settings.DlssNrPreprocessChecked := True;
  Settings.DlssNrPassesIndex := 2; // 3 passes
  Settings.DlssNrPassesModeIndex := 1; // fast (Interleaved)
  Settings.DlssNrOptimizedLayersIndex := 2; // Performance
  Settings.DlssNrRunBeforeSrChecked := True;
  Settings.DlssNrFinishedPictureChecked := False;
  Settings.DlssNrSkinProtectionChecked := True;

  AssertTrue('SaveOptiScalerConfig succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));

  IniPath := GetGameConfigDir('TestDlssNrIni') + 'dlssnr-amd.ini';
  AssertTrue('dlssnr-amd.ini was generated', FileExists(IniPath));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(IniPath);
    AssertTrue('Model = CC_SMALL_FP8 present', Pos('Model = CC_SMALL_FP8', Lines.Text) > 0);
    AssertTrue('OptimizedLayers = 2 present', Pos('OptimizedLayers = 2', Lines.Text) > 0);
    AssertTrue('NRResolutionScale = 1.00 present', Pos('NRResolutionScale = 1.00', Lines.Text) > 0);
    AssertTrue('Preprocess Enabled = 1 present', Pos('Enabled = 1', Lines.Text) > 0);
    AssertTrue('NRPasses = 3 present', Pos('NRPasses = 3', Lines.Text) > 0);
    AssertTrue('NRPassesMode = fast present', Pos('NRPassesMode = fast', Lines.Text) > 0);
    AssertTrue('NRHookPoint = 1 present', Pos('NRHookPoint = 1', Lines.Text) > 0);
    AssertTrue('NRAutoMask = 1 present', Pos('NRAutoMask = 1', Lines.Text) > 0);
    AssertTrue('RunBeforeSR = true present', Pos('RunBeforeSR = true', Lines.Text) > 0);
    AssertTrue('SkinProtection = true present', Pos('SkinProtection = true', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TOptiScalerIniTests.TestDlssNrDirectFileDeploymentAndManifestCleanup;
var
  GameDir, ManifestPath, FName: string;
  Manifest, DummyContent: TStringList;
  i: Integer;
begin
  GameDir := IncludeTrailingPathDelimiter(IsolatedHome) + 'mock_dlssnr_game' + PathDelim;
  ForceDirectories(GameDir);

  DummyContent := TStringList.Create;
  try
    DummyContent.Text := 'dummy binary payload';
    DummyContent.SaveToFile(GameDir + 'game.exe');
    DummyContent.SaveToFile(GameDir + 'dxgi.dll');
    DummyContent.SaveToFile(GameDir + 'dlssnr_amd.dll');
    DummyContent.SaveToFile(GameDir + 'dlssnr-small.bin');
    DummyContent.SaveToFile(GameDir + 'dlssnr-amd.ini');
  finally
    DummyContent.Free;
  end;

  Manifest := TStringList.Create;
  try
    Manifest.Add('dxgi.dll');
    Manifest.Add('dlssnr_amd.dll');
    Manifest.Add('dlssnr-small.bin');
    Manifest.Add('dlssnr-amd.ini');
    ManifestPath := GameDir + 'dlssnr-amd-install.txt';
    Manifest.SaveToFile(ManifestPath);
  finally
    Manifest.Free;
  end;

  AssertTrue('Game exe exists', FileExists(GameDir + 'game.exe'));
  AssertTrue('Proxy dll exists', FileExists(GameDir + 'dxgi.dll'));
  AssertTrue('DLSS-NR backend dll exists', FileExists(GameDir + 'dlssnr_amd.dll'));
  AssertTrue('DLSS-NR model exists', FileExists(GameDir + 'dlssnr-small.bin'));
  AssertTrue('DLSS-NR ini exists', FileExists(GameDir + 'dlssnr-amd.ini'));
  AssertTrue('Manifest exists', FileExists(ManifestPath));

  // Perform uninstallation cleanup reading manifest
  Manifest := TStringList.Create;
  try
    Manifest.LoadFromFile(ManifestPath);
    for i := 0 to Manifest.Count - 1 do
    begin
      FName := Trim(Manifest[i]);
      if (FName <> '') and FileExists(GameDir + FName) then
        DeleteFile(GameDir + FName);
    end;
    DeleteFile(ManifestPath);
  finally
    Manifest.Free;
  end;

  // Verify tracked files and manifest are removed
  AssertFalse('Proxy dll removed', FileExists(GameDir + 'dxgi.dll'));
  AssertFalse('DLSS-NR backend dll removed', FileExists(GameDir + 'dlssnr_amd.dll'));
  AssertFalse('DLSS-NR model removed', FileExists(GameDir + 'dlssnr-small.bin'));
  AssertFalse('DLSS-NR ini removed', FileExists(GameDir + 'dlssnr-amd.ini'));
  AssertFalse('Manifest removed', FileExists(ManifestPath));
  // Verify native game file is preserved untouched
  AssertTrue('Game exe preserved', FileExists(GameDir + 'game.exe'));
end;

procedure TOptiScalerIniTests.TestDlssNr009CacheAndManifestLayout;
var
  Rdna3Dir, GameDir, ManifestPath, FName: string;
  DummyContent, Manifest: TStringList;
  i: Integer;
begin
  // 1. Verify CheckAndInstallDlssNr recognizes 0.0.9 cache paths (optiscaler/release/OptiScaler.dll & optiscaler/asi/dlssnr-amd.asi)
  Rdna3Dir := IncludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3'));
  ForceDirectories(Rdna3Dir + 'optiscaler' + PathDelim + 'release');
  DummyContent := TStringList.Create;
  try
    DummyContent.Text := 'dummy';
    DummyContent.SaveToFile(Rdna3Dir + 'optiscaler' + PathDelim + 'release' + PathDelim + 'OptiScaler.dll');
    AssertTrue('CheckAndInstallDlssNr recognizes optiscaler/release/OptiScaler.dll',
      CheckAndInstallDlssNr('rdna3', False));
    DeleteFile(Rdna3Dir + 'optiscaler' + PathDelim + 'release' + PathDelim + 'OptiScaler.dll');

    ForceDirectories(Rdna3Dir + 'optiscaler' + PathDelim + 'asi');
    DummyContent.SaveToFile(Rdna3Dir + 'optiscaler' + PathDelim + 'asi' + PathDelim + 'dlssnr-amd.asi');
    AssertTrue('CheckAndInstallDlssNr recognizes optiscaler/asi/dlssnr-amd.asi',
      CheckAndInstallDlssNr('rdna3', False));
  finally
    DummyContent.Free;
    DeleteFile(Rdna3Dir + 'optiscaler' + PathDelim + 'asi' + PathDelim + 'dlssnr-amd.asi');
    RemoveDir(Rdna3Dir + 'optiscaler' + PathDelim + 'asi');
    RemoveDir(Rdna3Dir + 'optiscaler' + PathDelim + 'release');
    RemoveDir(Rdna3Dir + 'optiscaler');
    RemoveDir(ExcludeTrailingPathDelimiter(Rdna3Dir));
  end;

  // 2. Verify manifest cleanup removes nested 0.0.9 ASI plugin path
  GameDir := IncludeTrailingPathDelimiter(GetTempDir) + 'test_dlssnr_009_' + IntToStr(Random(100000)) + PathDelim;
  ForceDirectories(GameDir + 'OptiScaler' + PathDelim + 'plugins');
  DummyContent := TStringList.Create;
  try
    DummyContent.Text := 'dummy';
    DummyContent.SaveToFile(GameDir + 'OptiScaler.dll');
    DummyContent.SaveToFile(GameDir + 'OptiScaler' + PathDelim + 'plugins' + PathDelim + 'dlssnr-amd.asi');
  finally
    DummyContent.Free;
  end;

  Manifest := TStringList.Create;
  try
    Manifest.Add('OptiScaler.dll');
    Manifest.Add('OptiScaler/plugins/dlssnr-amd.asi');
    ManifestPath := GameDir + 'dlssnr-amd-install.txt';
    Manifest.SaveToFile(ManifestPath);
  finally
    Manifest.Free;
  end;

  Manifest := TStringList.Create;
  try
    Manifest.LoadFromFile(ManifestPath);
    for i := 0 to Manifest.Count - 1 do
    begin
      FName := Trim(Manifest[i]);
      if (FName <> '') and FileExists(GameDir + FName) then
        DeleteFile(GameDir + FName);
    end;
    DeleteFile(ManifestPath);
  finally
    Manifest.Free;
  end;

  AssertFalse('OptiScaler.dll removed', FileExists(GameDir + 'OptiScaler.dll'));
  AssertFalse('0.0.9 dlssnr-amd.asi removed', FileExists(GameDir + 'OptiScaler' + PathDelim + 'plugins' + PathDelim + 'dlssnr-amd.asi'));
  AssertFalse('Manifest removed', FileExists(ManifestPath));
  RemoveDir(GameDir + 'OptiScaler' + PathDelim + 'plugins');
  RemoveDir(GameDir + 'OptiScaler');
  RemoveDir(ExcludeTrailingPathDelimiter(GameDir));
end;

procedure TOptiScalerIniTests.TestIsDlssNrInstalledFallbackArchitecture;
var
  DlssNrDir: string;
  Vars: TStringList;
begin
  DlssNrDir := IncludeTrailingPathDelimiter(IsolatedHome) + '.local/share/goverlay/dlss-nr-rdna3' + PathDelim;
  ForceDirectories(DlssNrDir);

  Vars := TStringList.Create;
  try
    Vars.Add('OPTISCALER_DLSSNR_VERSION=1.0');
    Vars.SaveToFile(DlssNrDir + 'goverlay.vars');

    AssertTrue('default arch detects rdna3 installation', IsDlssNrInstalled(''));
    AssertTrue('explicit rdna3 detects installation', IsDlssNrInstalled('rdna3'));
  finally
    Vars.Free;
    if FileExists(DlssNrDir + 'goverlay.vars') then
      DeleteFile(DlssNrDir + 'goverlay.vars');
    if DirectoryExists(DlssNrDir) then
      RemoveDir(DlssNrDir);
  end;
end;

procedure TOptiScalerIniTests.TestParseDlssNr32Release;
const
  // Newest first, as the GitHub API lists them: a 64-bit-only release, then
  // the release with the 64-bit, i686 and checksum assets.
  GitHubJson =
    '[{"tag_name":"z1e.3","assets":[' +
    '{"browser_download_url":"https://github.com/o/r/releases/download/z1e.3/DLSSNR-AMD-Vulkan-Linux-z1e.3-x86_64-rdna3.tar.gz"}]},' +
    '{"tag_name":"v0.0.9-linux-rdna3","assets":[' +
    '{"browser_download_url":"https://github.com/o/r/releases/download/v0.0.9-linux-rdna3/DLSSNR-AMD-Vulkan-Linux-0.0.9-linux-rdna3-x86_64-rdna3.tar.gz"},' +
    '{"browser_download_url":"https://github.com/o/r/releases/download/v0.0.9-linux-rdna3/DLSSNR-AMD-Vulkan-Linux-0.0.9-linux-rdna3-i686-rdna3.tar.gz.sha256"},' +
    '{"browser_download_url":"https://github.com/o/r/releases/download/v0.0.9-linux-rdna3/DLSSNR-AMD-Vulkan-Linux-0.0.9-linux-rdna3-i686-rdna3.tar.gz"}]}]';
  GitLabJson =
    '[{"name":"0.0.9","tag_name":"v0.0.9","assets":{"sources":[{"format":"tar.gz","url":"https://gitlab.com/o/r/-/archive/v0.0.9/r-v0.0.9.tar.gz"}],"links":[' +
    '{"name":"x86_64","direct_asset_url":"https://gitlab.com/o/r/-/releases/v0.0.9/downloads/DLSSNR-AMD-Vulkan-Linux-0.0.9-x86_64.tar.gz"},' +
    '{"name":"i686","direct_asset_url":"https://gitlab.com/o/r/-/releases/v0.0.9/downloads/DLSSNR-AMD-Vulkan-Linux-0.0.9-i686.tar.gz"}]}}]';
var
  Tag, Url: string;
begin
  AssertTrue('RDNA3: an i686 package is found', ParseDlssNr32Release(GitHubJson, 'rdna3', Tag, Url));
  AssertEquals('RDNA3: the i686-rdna3 archive, not its checksum or the 64-bit one',
    'https://github.com/o/r/releases/download/v0.0.9-linux-rdna3/DLSSNR-AMD-Vulkan-Linux-0.0.9-linux-rdna3-i686-rdna3.tar.gz', Url);
  AssertEquals('RDNA3: tag of the release the archive belongs to', 'v0.0.9-linux-rdna3', Tag);

  AssertTrue('RDNA4: an i686 package is found', ParseDlssNr32Release(GitLabJson, 'rdna4', Tag, Url));
  AssertEquals('RDNA4: the i686 link',
    'https://gitlab.com/o/r/-/releases/v0.0.9/downloads/DLSSNR-AMD-Vulkan-Linux-0.0.9-i686.tar.gz', Url);
  AssertEquals('RDNA4: tag', 'v0.0.9', Tag);

  AssertFalse('RDNA4 does not take the RDNA3 port''s package', ParseDlssNr32Release(
    StringReplace(GitHubJson, 'browser_download_url', 'direct_asset_url', [rfReplaceAll]), 'rdna4', Tag, Url));
  AssertFalse('No i686 package: nothing', ParseDlssNr32Release(
    '[{"tag_name":"z1e.3","assets":[{"browser_download_url":"https://x/y-x86_64-rdna3.tar.gz"}]}]', 'rdna3', Tag, Url));
  AssertEquals('No i686 package: empty URL', '', Url);
end;

procedure TOptiScalerIniTests.TestDlssNrArchitecturePathResolution;
var
  Rdna3Path, Rdna4Path: string;
begin
  Rdna3Path := ExcludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna3'));
  Rdna4Path := ExcludeTrailingPathDelimiter(GetBGModDlssNrPath('rdna4'));

  AssertEquals('RDNA3 path suffix', 'dlss-nr-rdna3',
    Copy(Rdna3Path, Length(Rdna3Path) - Length('dlss-nr-rdna3') + 1, MaxInt));
  AssertEquals('RDNA4 path suffix', 'dlss-nr-rdna4',
    Copy(Rdna4Path, Length(Rdna4Path) - Length('dlss-nr-rdna4') + 1, MaxInt));
end;

procedure TOptiScalerIniTests.TestExtractDlssNrModelTargetsRequestedArch;
var
  DataRoot, Rdna3Dir, Rdna4Dir, ModelsDir: string;
  DllPath, ErrorMsg, UsedScript: string;
  ScriptLines, MarkerLines: TStringList;
  MarkerPath, Runtime32Dir: string;

  procedure WriteExtractScript(const AToolsDir: string);
  begin
    ForceDirectories(AToolsDir);
    ScriptLines := TStringList.Create;
    try
      ScriptLines.Add('#!/usr/bin/env bash');
      ScriptLines.Add('echo "$0" > "$2/used-script.txt"');
      ScriptLines.Add('printf ''fake model weights'' > "$2/dlssnr.bin"');
      ScriptLines.SaveToFile(AToolsDir + 'extract_model.sh');
    finally
      ScriptLines.Free;
    end;
  end;

begin
  DataRoot := IncludeTrailingPathDelimiter(IsolatedHome) + '.local/share/goverlay' + PathDelim;
  Rdna3Dir := IncludeTrailingPathDelimiter(DataRoot + 'dlss-nr-rdna3');
  Rdna4Dir := IncludeTrailingPathDelimiter(DataRoot + 'dlss-nr-rdna4');
  ModelsDir := IncludeTrailingPathDelimiter(DataRoot + 'dlss-nr-models');
  DllPath := IsolatedHome + PathDelim + 'nvngx_dlssnr_test.dll';
  MarkerPath := ModelsDir + 'used-script.txt';

  WriteExtractScript(Rdna3Dir + 'model-tools' + PathDelim);
  WriteExtractScript(Rdna4Dir + 'model-tools' + PathDelim);

  ScriptLines := TStringList.Create;
  try
    ScriptLines.Add('dummy dlss-nr model dll');
    ScriptLines.SaveToFile(DllPath);
  finally
    ScriptLines.Free;
  end;

  // ExtractDlssNrModel ends by downloading the 32-bit runtime when it is
  // missing: a stub keeps the test off the network and out of later tests' way
  Runtime32Dir := IncludeTrailingPathDelimiter(DataRoot + 'dlss-nr-rdna4-i686');
  ForceDirectories(Runtime32Dir + 'reshade');
  ScriptLines := TStringList.Create;
  try
    ScriptLines.Add('stub');
    ScriptLines.SaveToFile(Runtime32Dir + 'reshade' + PathDelim + 'dlssnr_amd.addon32');
  finally
    ScriptLines.Free;
  end;

  try
    AssertTrue('RDNA4 extraction succeeds', ExtractDlssNrModel(DllPath, ErrorMsg, nil, 'rdna4'));
    AssertEquals('No extraction error', '', ErrorMsg);
    AssertTrue('Model output created', FileExists(ModelsDir + 'dlssnr.bin'));

    UsedScript := '';
    if FileExists(MarkerPath) then
    begin
      MarkerLines := TStringList.Create;
      try
        MarkerLines.LoadFromFile(MarkerPath);
        UsedScript := Trim(MarkerLines.Text);
      finally
        MarkerLines.Free;
      end;
    end;
    AssertTrue('RDNA4 extractor script used', Pos('dlss-nr-rdna4', UsedScript) > 0);
  finally
    if FileExists(DllPath) then DeleteFile(DllPath);
    if FileExists(ModelsDir + 'dlssnr.bin') then DeleteFile(ModelsDir + 'dlssnr.bin');
    if FileExists(MarkerPath) then DeleteFile(MarkerPath);
    if FileExists(Rdna3Dir + 'model-tools' + PathDelim + 'extract_model.sh') then
      DeleteFile(Rdna3Dir + 'model-tools' + PathDelim + 'extract_model.sh');
    if FileExists(Rdna4Dir + 'model-tools' + PathDelim + 'extract_model.sh') then
      DeleteFile(Rdna4Dir + 'model-tools' + PathDelim + 'extract_model.sh');
    if DirectoryExists(Rdna3Dir + 'model-tools' + PathDelim) then RemoveDir(Rdna3Dir + 'model-tools' + PathDelim);
    if DirectoryExists(Rdna4Dir + 'model-tools' + PathDelim) then RemoveDir(Rdna4Dir + 'model-tools' + PathDelim);
    if DirectoryExists(Rdna3Dir) then RemoveDir(Rdna3Dir);
    if DirectoryExists(Rdna4Dir) then RemoveDir(Rdna4Dir);
    if DirectoryExists(ModelsDir) then RemoveDir(ModelsDir);
    DeleteFile(Runtime32Dir + 'reshade' + PathDelim + 'dlssnr_amd.addon32');
    RemoveDir(Runtime32Dir + 'reshade');
    RemoveDir(Runtime32Dir);
  end;
end;

procedure TOptiScalerIniTests.TestHelixSrConfigRoundTrip;
var
  Settings, LoadedSettings: TOptiScalerSettings;
  ErrMsg, LaunchCommand: string;
begin
  Settings.ActiveGameName := 'TestHelixSrGame';
  Settings.Version := '1.0';
  Settings.Channel := 'stable';
  Settings.UpscalerTypeItemIndex := 3; // HelixSR
  Settings.HelixSrNativeDlssChecked := True;
  Settings.HelixSrSharpenerIndex := 1; // FSR
  Settings.HelixSrSharpness := 45;
  Settings.HelixSrWaveSizeIndex := 2; // Wave64
  Settings.HelixSrNetworkResolutionIndex := 1; // 1440p
  Settings.HelixSrInt8Index := 1; // Enabled
  Settings.HelixSrFgPresetIndex := 1; // Full (DLSS FG 310.3)

  AssertTrue('SaveOptiScalerConfig succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));

  AssertTrue('LoadOptiScalerConfig succeeds', LoadOptiScalerConfig('TestHelixSrGame', LoadedSettings));
  AssertEquals('UpscalerTypeItemIndex = 3', 3, LoadedSettings.UpscalerTypeItemIndex);
  AssertTrue('HelixSrNativeDlssChecked is true', LoadedSettings.HelixSrNativeDlssChecked);
  AssertEquals('HelixSrSharpenerIndex = 1', 1, LoadedSettings.HelixSrSharpenerIndex);
  AssertEquals('HelixSrSharpness = 45', 45, LoadedSettings.HelixSrSharpness);
  AssertEquals('HelixSrWaveSizeIndex = 2', 2, LoadedSettings.HelixSrWaveSizeIndex);
  AssertEquals('HelixSrNetworkResolutionIndex = 1', 1, LoadedSettings.HelixSrNetworkResolutionIndex);
  AssertEquals('HelixSrInt8Index = 1', 1, LoadedSettings.HelixSrInt8Index);
  AssertEquals('HelixSrFgPresetIndex = 1', 1, LoadedSettings.HelixSrFgPresetIndex);
end;

procedure TOptiScalerIniTests.TestHelixSrIniGeneration;
var
  Settings: TOptiScalerSettings;
  ErrMsg, IniPath, LaunchCommand: string;
  Lines: TStringList;
begin
  Settings.ActiveGameName := 'TestHelixSrIni';
  Settings.Version := '1.0';
  Settings.Channel := 'stable';
  Settings.UpscalerTypeItemIndex := 3; // HelixSR
  Settings.HelixSrNativeDlssChecked := True;
  Settings.HelixSrSharpenerIndex := 1; // NVIDIA
  Settings.HelixSrSharpness := 45;
  Settings.HelixSrWaveSizeIndex := 2; // Wave64
  Settings.HelixSrNetworkResolutionIndex := 1; // Full
  Settings.HelixSrInt8Index := 1; // On
  Settings.HelixSrFgPresetIndex := 1; // Full

  AssertTrue('SaveOptiScalerConfig succeeds',
    SaveOptiScalerConfigCore(Settings, '', '', False, False, False, ErrMsg, LaunchCommand));

  IniPath := GetGameConfigDir('TestHelixSrIni') + 'helixsr.ini';
  AssertTrue('helixsr.ini was generated', FileExists(IniPath));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(IniPath);
    AssertTrue('Sharpener=nvidia present', Pos('Sharpener=nvidia', Lines.Text) > 0);
    AssertTrue('Sharpness=0.45 present', Pos('Sharpness=0.45', Lines.Text) > 0);
    AssertTrue('WaveSize=64 present', Pos('WaveSize=64', Lines.Text) > 0);
    AssertTrue('NetworkResolution=full present', Pos('NetworkResolution=full', Lines.Text) > 0);
    AssertTrue('Int8=on present', Pos('Int8=on', Lines.Text) > 0);
    AssertTrue('Preset=full present', Pos('Preset=full', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirValid;
var
  ValidSandbox: string;
begin
  ValidSandbox := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_12345678';
  AssertTrue('Valid sandbox path accepted', IsSafeSandboxDir(ValidSandbox));
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirRejectsUnsafePaths;
begin
  AssertFalse('Empty path rejected', IsSafeSandboxDir(''));
  AssertFalse('Root path rejected', IsSafeSandboxDir('/'));
  AssertFalse('Home path rejected', IsSafeSandboxDir('/home/testuser'));
  AssertFalse('Root home rejected', IsSafeSandboxDir('/root'));
  AssertFalse('Base temp directory rejected', IsSafeSandboxDir(GetTempDir(False)));
  AssertFalse('Temp prefix alone rejected', IsSafeSandboxDir(IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_'));
  AssertFalse('Arbitrary temp folder rejected', IsSafeSandboxDir(IncludeTrailingPathDelimiter(GetTempDir(False)) + 'other_folder'));
end;

// The paths below all start with the sandbox prefix, so a string comparison
// accepts every one of them - while the kernel resolves them outside the
// sandbox, which is where DeleteDirectory would then do its work.
procedure TSandboxIsolationTests.TestIsSafeSandboxDirRejectsTraversal;
var
  Prefix: string;
begin
  Prefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_x';

  AssertFalse('Escape to a home directory rejected',
    IsSafeSandboxDir(Prefix + '/../../home/testuser'));
  AssertFalse('Escape to filesystem root rejected',
    IsSafeSandboxDir(Prefix + '/../..'));
  AssertFalse('Escape to the temp root rejected',
    IsSafeSandboxDir(Prefix + '/..'));
  AssertFalse('Trailing traversal rejected',
    IsSafeSandboxDir(Prefix + '/subdir/../../'));
  AssertFalse('Traversal in the middle of a longer path rejected',
    IsSafeSandboxDir(Prefix + '/a/../../../etc/skel'));
  AssertFalse('Traversal that also leaves the temp root rejected',
    IsSafeSandboxDir(Prefix + '/../../../root'));

  // Landing back inside the sandbox is still refused: a directory about to be
  // deleted recursively is not the place to trust a path that needs resolving.
  AssertFalse('Traversal that resolves back inside is still rejected',
    IsSafeSandboxDir(Prefix + '/subdir/..'));
end;

procedure TSandboxIsolationTests.TestIsSafeSandboxDirAcceptsDottedNames;
var
  Prefix: string;
begin
  // Dots are only dangerous as a whole path component; they are legal in names.
  Prefix := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'goverlay_test_';
  AssertTrue('Name containing dots accepted', IsSafeSandboxDir(Prefix + '12345..678'));
  AssertTrue('Name ending in dots accepted', IsSafeSandboxDir(Prefix + '12345678..'));
  AssertTrue('Trailing slash accepted', IsSafeSandboxDir(Prefix + '12345678/'));
end;

procedure TVkSumiLogicTests.TestIsVkSumiAtDefaults;
var
  DefaultPositions, ModifiedPositions: array[0..14] of Integer;
  i: Integer;
begin
  for i := 0 to 14 do
    DefaultPositions[i] := VKSUMI_DEFAULTS[i];
  AssertTrue('Exact default positions return True', IsVkSumiAtDefaults(DefaultPositions));

  // Change exposure from 300 to 250
  for i := 0 to 14 do
    ModifiedPositions[i] := VKSUMI_DEFAULTS[i];
  ModifiedPositions[2] := 250;
  AssertFalse('Modified exposure returns False', IsVkSumiAtDefaults(ModifiedPositions));

  // Change brightness from 100 to 105
  for i := 0 to 14 do
    ModifiedPositions[i] := VKSUMI_DEFAULTS[i];
  ModifiedPositions[0] := 105;
  AssertFalse('Modified brightness returns False', IsVkSumiAtDefaults(ModifiedPositions));
end;

procedure TVkSumiLogicTests.TestSaveVkSumiConfigDefaultsFlag;
var
  Settings: TVkSumiSettings;
  ErrMsg, BgmodConfPath, SumiConfPath: string;
  Ini: TIniFile;
  Lines: TStringList;
  i: Integer;
begin
  Settings.SumiFolder := IsolatedHome + '/.config/vkSumi';
  Settings.SumiCfgFile := Settings.SumiFolder + '/vkSumi.conf';
  Settings.Version := '1.2.3';
  Settings.Channel := 'stable';
  Settings.Enabled := True;
  Settings.ToggleKeys := 'Shift_R+F9';
  for i := 0 to 14 do
    Settings.TrackbarPositions[i] := VKSUMI_DEFAULTS[i];
  Settings.ActiveGameName := 'TestGame';

  BgmodConfPath := GetGameConfigDir('TestGame') + 'bgmod.conf';
  ForceDirectories(ExtractFilePath(BgmodConfPath));

  // Seed bgmod.conf with GOVERLAY_VKBASALT=1
  Ini := TIniFile.Create(BgmodConfPath);
  try
    Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '1');
  finally
    Ini.Free;
  end;

  AssertTrue('SaveVkSumiConfig succeeds', SaveVkSumiConfig(Settings, ErrMsg));

  // Assert GOVERLAY_VKSUMI is 1 when enabled (even if sliders at defaults) and GOVERLAY_VKBASALT is preserved as 1
  Ini := TIniFile.Create(BgmodConfPath);
  try
    AssertEquals('GOVERLAY_VKSUMI is 1 when enabled even if sliders at default', '1', Ini.ReadString('Config', 'GOVERLAY_VKSUMI', ''));
    AssertEquals('GOVERLAY_VKBASALT remains untouched as 1', '1', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', ''));
  finally
    Ini.Free;
  end;

  // Assert vkSumi.conf has enabled = true
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Settings.SumiCfgFile);
    AssertTrue('enabled = true in vkSumi.conf when module enabled', Pos('enabled     = true', Lines.Text) > 0);
  finally
    Lines.Free;
  end;

  // Test when module is disabled
  Settings.Enabled := False;
  AssertTrue('SaveVkSumiConfig succeeds when disabled', SaveVkSumiConfig(Settings, ErrMsg));

  Ini := TIniFile.Create(BgmodConfPath);
  try
    AssertEquals('GOVERLAY_VKSUMI is 0 when disabled', '0', Ini.ReadString('Config', 'GOVERLAY_VKSUMI', ''));
  finally
    Ini.Free;
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Settings.SumiCfgFile);
    AssertTrue('enabled = false in vkSumi.conf when module disabled', Pos('enabled     = false', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TVkSumiLogicTests.TestSaveVkSumiConfigCustomizedFlag;
var
  Settings: TVkSumiSettings;
  ErrMsg, BgmodConfPath: string;
  Ini: TIniFile;
  Lines: TStringList;
  i: Integer;
begin
  Settings.SumiFolder := IsolatedHome + '/.config/vkSumi';
  Settings.SumiCfgFile := Settings.SumiFolder + '/vkSumi.conf';
  Settings.Version := '1.2.3';
  Settings.Channel := 'stable';
  Settings.Enabled := True;
  Settings.ToggleKeys := 'Shift_R+F9';
  for i := 0 to 14 do
    Settings.TrackbarPositions[i] := VKSUMI_DEFAULTS[i];
  // Customize contrast
  Settings.TrackbarPositions[1] := 130;
  Settings.ActiveGameName := 'TestGameCustom';

  BgmodConfPath := GetGameConfigDir('TestGameCustom') + 'bgmod.conf';
  AssertTrue('SaveVkSumiConfig succeeds', SaveVkSumiConfig(Settings, ErrMsg));

  // Assert GOVERLAY_VKSUMI is 1
  Ini := TIniFile.Create(BgmodConfPath);
  try
    AssertEquals('GOVERLAY_VKSUMI is 1 when customized', '1', Ini.ReadString('Config', 'GOVERLAY_VKSUMI', ''));
  finally
    Ini.Free;
  end;

  // Assert vkSumi.conf has enabled = true
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Settings.SumiCfgFile);
    AssertTrue('enabled = true in vkSumi.conf when customized', Pos('enabled     = true', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TVkBasaltLogicTests.TestPipelineEffectsSerializationOrder;
var
  Settings: TVkBasaltSettings;
  ErrMsg: string;
  Lines: TStringList;
  EffectsLine: string;
  i: Integer;
begin
  Settings.BasaltFolder := IsolatedHome + '/.config/vkBasalt';
  Settings.BasaltCfgFile := Settings.BasaltFolder + '/vkBasalt.conf';
  Settings.Version := '1.2.3';
  Settings.Channel := 'stable';
  Settings.ToggleKey := 'Home';
  Settings.CasPosition := 5;
  Settings.FxaaPosition := 0;
  Settings.SmaaPosition := 4;
  Settings.DlsPosition := 0;
  Settings.ReshadeEffects := TStringList.Create;
  Settings.ReshadeEffects.Add('Shaders/Bloom.fx');

  Settings.PipelineEffects := TStringList.Create;
  try
    // User configured order: SMAA -> Bloom -> CAS
    Settings.PipelineEffects.Add('smaa');
    Settings.PipelineEffects.Add('Bloom');
    Settings.PipelineEffects.Add('cas');

    AssertTrue('SaveVkBasaltConfig succeeds', SaveVkBasaltConfig(Settings, ErrMsg));

    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(Settings.BasaltCfgFile);
      EffectsLine := '';
      for i := 0 to Lines.Count - 1 do
      begin
        if Pos('effects =', Lines[i]) = 1 then
        begin
          EffectsLine := Lines[i];
          Break;
        end;
      end;
      AssertEquals('effects line serialized in exact pipeline order', 'effects = smaa:Bloom:cas', EffectsLine);
      AssertTrue('Bloom path mapped', Pos('Bloom = ' + Settings.BasaltFolder + '/reshade-shaders/Shaders/Bloom.fx', Lines.Text) > 0);
    finally
      Lines.Free;
    end;
  finally
    Settings.PipelineEffects.Free;
    Settings.ReshadeEffects.Free;
  end;
end;

procedure TVkBasaltLogicTests.TestPipelineEffectsLoadOrder;
var
  CfgFile: string;
  Lines, AvEffects, ActEffects, PipelineList: TStringList;
  Settings: TVkBasaltSettings;
begin
  CfgFile := IsolatedHome + '/.config/vkBasalt/custom_load.conf';
  ForceDirectories(ExtractFileDir(CfgFile));

  Lines := TStringList.Create;
  try
    Lines.Add('effects = dls:Colourfulness:smaa:cas');
    Lines.Add('casSharpness = 0.8');
    Lines.Add('smaaCornerRounding = 25.0');
    Lines.SaveToFile(CfgFile);
  finally
    Lines.Free;
  end;

  AvEffects := TStringList.Create;
  ActEffects := TStringList.Create;
  PipelineList := TStringList.Create;
  try
    AvEffects.Add('Shaders/Colourfulness.fx');
    AssertTrue('LoadVkBasaltConfig succeeds', LoadVkBasaltConfig(CfgFile, AvEffects, ActEffects, Settings, PipelineList));

    AssertEquals('Pipeline has 4 effects', 4, PipelineList.Count);
    AssertEquals('Effect 0 is dls', 'dls', PipelineList[0]);
    AssertEquals('Effect 1 is Colourfulness', 'Colourfulness', PipelineList[1]);
    AssertEquals('Effect 2 is smaa', 'smaa', PipelineList[2]);
    AssertEquals('Effect 3 is cas', 'cas', PipelineList[3]);

    AssertEquals('ActEffects contains Colourfulness.fx', 1, ActEffects.Count);
    AssertEquals('CasPosition is 8', 8, Settings.CasPosition);
    AssertEquals('SmaaPosition is 10', 10, Settings.SmaaPosition);
  finally
    AvEffects.Free;
    ActEffects.Free;
    PipelineList.Free;
  end;
end;

procedure TVkBasaltLogicTests.TestFallbackWhenPipelineEffectsNil;
var
  Settings: TVkBasaltSettings;
  ErrMsg: string;
  Lines: TStringList;
  EffectsLine: string;
  i: Integer;
begin
  Settings.BasaltFolder := IsolatedHome + '/.config/vkBasalt';
  Settings.BasaltCfgFile := Settings.BasaltFolder + '/vkBasalt_fallback.conf';
  Settings.Version := '1.2.3';
  Settings.Channel := 'stable';
  Settings.ToggleKey := 'Home';
  Settings.CasPosition := 5;
  Settings.FxaaPosition := 0;
  Settings.SmaaPosition := 4;
  Settings.DlsPosition := 6;
  Settings.ReshadeEffects := nil;
  Settings.PipelineEffects := nil; // nil to test fallback

  AssertTrue('SaveVkBasaltConfig succeeds with nil pipeline', SaveVkBasaltConfig(Settings, ErrMsg));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Settings.BasaltCfgFile);
    EffectsLine := '';
    for i := 0 to Lines.Count - 1 do
    begin
      if Pos('effects =', Lines[i]) = 1 then
      begin
        EffectsLine := Lines[i];
        Break;
      end;
    end;
    AssertEquals('Fallback serializes in default order cas:smaa:dls', 'effects = cas:smaa:dls', EffectsLine);
  finally
    Lines.Free;
  end;
end;

procedure TVkBasaltLogicTests.TestLutSerializationAndLoad;
var
  Settings: TVkBasaltSettings;
  LoadedSettings: TVkBasaltSettings;
  ErrMsg: string;
  Lines, AvEffects, ActEffects, PipelineList: TStringList;
  EffectsLine, LutFileLine: string;
  i: Integer;
begin
  Settings.BasaltFolder := IsolatedHome + '/.config/vkBasalt';
  Settings.BasaltCfgFile := Settings.BasaltFolder + '/vkBasalt_lut.conf';
  Settings.Version := '1.2.3';
  Settings.Channel := 'stable';
  Settings.ToggleKey := 'Home';
  Settings.CasPosition := 4;
  Settings.FxaaPosition := 0;
  Settings.SmaaPosition := 0;
  Settings.DlsPosition := 0;
  Settings.LutEnabled := True;
  Settings.LutFile := '/path/to/my custom lut.cube';
  Settings.ReshadeEffects := nil;
  Settings.PipelineEffects := TStringList.Create;
  try
    Settings.PipelineEffects.Add('cas');
    Settings.PipelineEffects.Add('lut');

    AssertTrue('SaveVkBasaltConfig succeeds with lut', SaveVkBasaltConfig(Settings, ErrMsg));

    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(Settings.BasaltCfgFile);
      EffectsLine := '';
      LutFileLine := '';
      for i := 0 to Lines.Count - 1 do
      begin
        if Pos('effects =', Lines[i]) = 1 then
          EffectsLine := Lines[i]
        else if Pos('lutFile =', Lines[i]) = 1 then
          LutFileLine := Lines[i];
      end;
      AssertEquals('effects line includes lut', 'effects = cas:lut', EffectsLine);
      AssertEquals('lutFile line has quotes', 'lutFile = "/path/to/my custom lut.cube"', LutFileLine);
      AssertFalse('lut is not treated as a reshade shader file', Pos('lut = ', Lines.Text) > 0);
    finally
      Lines.Free;
    end;

    // Test loading
    AvEffects := TStringList.Create;
    ActEffects := TStringList.Create;
    PipelineList := TStringList.Create;
    try
      AssertTrue('LoadVkBasaltConfig succeeds', LoadVkBasaltConfig(Settings.BasaltCfgFile, AvEffects, ActEffects, LoadedSettings, PipelineList));
      AssertTrue('LutEnabled is true', LoadedSettings.LutEnabled);
      AssertEquals('LutFile unquoted path loaded correctly', '/path/to/my custom lut.cube', LoadedSettings.LutFile);
      AssertEquals('Pipeline has 2 effects', 2, PipelineList.Count);
      AssertEquals('Effect 0 is cas', 'cas', PipelineList[0]);
      AssertEquals('Effect 1 is lut', 'lut', PipelineList[1]);
      AssertEquals('ActEffects does not contain lut', 0, ActEffects.Count);
    finally
      AvEffects.Free;
      ActEffects.Free;
      PipelineList.Free;
    end;
  finally
    Settings.PipelineEffects.Free;
  end;
end;

procedure TVkBasaltLogicTests.TestVkBasaltManifestOptInStructure;
var
  LayerDir, JsonPath64, JsonPath32, Content: string;
  Lines: TStringList;
begin
  LayerDir := IncludeTrailingPathDelimiter(IsolatedHome) + '.local/share/vulkan/implicit_layer.d/';
  ForceDirectories(LayerDir);
  JsonPath64 := LayerDir + 'vkBasalt.json';
  JsonPath32 := LayerDir + 'vkBasalt.x86.json';

  Lines := TStringList.Create;
  try
    Lines.Add('{');
    Lines.Add('  "file_format_version": "1.0.0",');
    Lines.Add('  "layer": {');
    Lines.Add('    "name": "VK_LAYER_VKBASALT_post_processing",');
    Lines.Add('    "type": "GLOBAL",');
    Lines.Add('    "library_path": "/home/user/.local/lib/vkbasalt/libvkbasalt.so",');
    Lines.Add('    "functions": {');
    Lines.Add('      "vkGetInstanceProcAddr": "vkBasalt_GetInstanceProcAddr",');
    Lines.Add('      "vkGetDeviceProcAddr": "vkBasalt_GetDeviceProcAddr"');
    Lines.Add('    },');
    Lines.Add('    "enable_environment": {');
    Lines.Add('      "ENABLE_VKBASALT": "1"');
    Lines.Add('    },');
    Lines.Add('    "disable_environment": {');
    Lines.Add('      "DISABLE_VKBASALT": "1"');
    Lines.Add('    }');
    Lines.Add('  }');
    Lines.Add('}');
    Lines.SaveToFile(JsonPath64);

    Lines.Clear;
    Lines.Add('{');
    Lines.Add('  "file_format_version": "1.0.0",');
    Lines.Add('  "layer": {');
    Lines.Add('    "name": "VK_LAYER_VKBASALT_post_processing",');
    Lines.Add('    "type": "GLOBAL",');
    Lines.Add('    "library_path": "/home/user/.local/lib32/vkbasalt/libvkbasalt.so",');
    Lines.Add('    "functions": {');
    Lines.Add('      "vkGetInstanceProcAddr": "vkBasalt_GetInstanceProcAddr",');
    Lines.Add('      "vkGetDeviceProcAddr": "vkBasalt_GetDeviceProcAddr"');
    Lines.Add('    },');
    Lines.Add('    "enable_environment": {');
    Lines.Add('      "ENABLE_VKBASALT": "1"');
    Lines.Add('    },');
    Lines.Add('    "disable_environment": {');
    Lines.Add('      "DISABLE_VKBASALT": "1"');
    Lines.Add('    }');
    Lines.Add('  }');
    Lines.Add('}');
    Lines.SaveToFile(JsonPath32);
  finally
    Lines.Free;
  end;

  try
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(JsonPath64);
      Content := Lines.Text;
      AssertTrue('64-bit manifest contains functions', Pos('"vkGetInstanceProcAddr": "vkBasalt_GetInstanceProcAddr"', Content) > 0);
      AssertTrue('64-bit manifest contains enable_environment', Pos('"enable_environment"', Content) > 0);
      AssertTrue('64-bit manifest contains ENABLE_VKBASALT', Pos('"ENABLE_VKBASALT": "1"', Content) > 0);

      Lines.LoadFromFile(JsonPath32);
      Content := Lines.Text;
      AssertTrue('32-bit manifest contains functions', Pos('"vkGetInstanceProcAddr": "vkBasalt_GetInstanceProcAddr"', Content) > 0);
      AssertTrue('32-bit manifest contains enable_environment', Pos('"enable_environment"', Content) > 0);
      AssertTrue('32-bit manifest contains ENABLE_VKBASALT', Pos('"ENABLE_VKBASALT": "1"', Content) > 0);
    finally
      Lines.Free;
    end;
  finally
    if FileExists(JsonPath64) then DeleteFile(JsonPath64);
    if FileExists(JsonPath32) then DeleteFile(JsonPath32);
  end;
end;

procedure TVkBasaltLogicTests.TestVkBasaltSanitizationCleansCorruptManifest;
var
  LayerDir, CorruptJson: string;
  Lines: TStringList;
begin
  LayerDir := IncludeTrailingPathDelimiter(IsolatedHome) + '.local/share/vulkan/implicit_layer.d/';
  ForceDirectories(LayerDir);
  CorruptJson := LayerDir + 'vkBasalt.json';

  Lines := TStringList.Create;
  try
    Lines.Add('{');
    Lines.Add('  "file_format_version": "1.0.0",');
    Lines.Add('  "layer": {');
    Lines.Add('    "name": "VK_LAYER_VKBASALT_post_processing",');
    Lines.Add('    "library_path": "/nonexistent/corrupt/libvkbasalt.so"');
    Lines.Add('  }');
    Lines.Add('}');
    Lines.SaveToFile(CorruptJson);
  finally
    Lines.Free;
  end;

  AssertTrue('corrupt manifest exists before sanitization', FileExists(CorruptJson));
  SanitizeImplicitVulkanLayers;
  AssertFalse('corrupt manifest removed after sanitization', FileExists(CorruptJson));
end;

procedure TGpuNameExtractionTests.TestAmdGpuExtraction;
var
  InputStr: string;
begin
  InputStr := 'Advanced Micro Devices, Inc. [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M] (rev c8)';
  AssertEquals('Extract AMD 7900', 'AMD Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M', ExtractGpuMarketName(InputStr));

  InputStr := 'Advanced Micro Devices, Inc. [AMD/ATI] Cezanne [Radeon Vega Series / Radeon Vega Mobile Series] (rev c5)';
  AssertEquals('Extract AMD Vega', 'AMD Radeon Vega Series / Radeon Vega Mobile Series', ExtractGpuMarketName(InputStr));
end;

procedure TGpuNameExtractionTests.TestNvidiaGpuExtraction;
var
  InputStr: string;
begin
  InputStr := 'NVIDIA Corporation AD104 [GeForce RTX 4070] (rev a1)';
  AssertEquals('Extract NVIDIA RTX 4070', 'NVIDIA GeForce RTX 4070', ExtractGpuMarketName(InputStr));

  InputStr := 'NVIDIA Corporation GA106 [GeForce RTX 3060 Lite Hash Rate] (rev a1)';
  AssertEquals('Extract NVIDIA RTX 3060', 'NVIDIA GeForce RTX 3060 Lite Hash Rate', ExtractGpuMarketName(InputStr));
end;

procedure TGpuNameExtractionTests.TestIntelGpuExtraction;
var
  InputStr: string;
begin
  InputStr := 'Intel Corporation Raptor Lake-S GT1 [UHD Graphics 770] (rev 04)';
  AssertEquals('Extract Intel UHD 770', 'Intel UHD Graphics 770', ExtractGpuMarketName(InputStr));

  InputStr := 'Intel Corporation Iris Plus Graphics G7 (rev 07)';
  AssertEquals('Extract Intel Iris', 'Intel Iris Plus Graphics G7', ExtractGpuMarketName(InputStr));
end;

procedure TGpuNameExtractionTests.TestIntelArcExtraction;
var
  InputStr: string;
begin
  InputStr := 'Intel Corporation DG2 [Arc A770] (rev 08)';
  AssertEquals('Extract Intel Arc A770', 'Intel Arc A770', ExtractGpuMarketName(InputStr));
end;

procedure TGpuNameExtractionTests.TestSteamDeckCustomGpuExtraction;
var
  InputStr: string;
begin
  InputStr := 'Advanced Micro Devices, Inc. [AMD/ATI] VanGogh [AMD Custom GPU 0405] (rev c1)';
  AssertEquals('Extract Steam Deck APU', 'AMD Custom GPU 0405', ExtractGpuMarketName(InputStr));
end;

procedure TGpuNameExtractionTests.TestFullLspciPrefixHandling;
var
  InputStr: string;
begin
  InputStr := '03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 31 [Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M] (rev c8)';
  AssertEquals('Handle full lspci line', 'AMD Radeon RX 7900 XT/7900 XTX/7900 GRE/7900M', ExtractGpuMarketName(InputStr));
end;

procedure TMangoHudGpuListTests.TestGpuListSinglePrimary;
var
  Settings: TMangoHudSettings;
  ErrMsg: string;
  Lines: TStringList;
  CfgPath: string;
begin
  FillChar(Settings, SizeOf(Settings), 0);
  Settings.Version := 'TEST';
  Settings.Channel := 'stable';
  Settings.PciDevIndex := 0;
  Settings.PciDevText := 'GPU 0: AMD Radeon RX 7900 XTX';
  CfgPath := IsolatedHome + '/.config/MangoHud/MangoHud_test0.conf';
  Settings.MangoHudCfgFile := CfgPath;

  AssertTrue('Save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(CfgPath);
    AssertTrue('gpu_list=0 present', Lines.IndexOf('gpu_list=0') >= 0);
  finally
    Lines.Free;
  end;
end;

procedure TMangoHudGpuListTests.TestGpuListSingleSecondary;
var
  Settings: TMangoHudSettings;
  ErrMsg: string;
  Lines: TStringList;
  CfgPath: string;
begin
  FillChar(Settings, SizeOf(Settings), 0);
  Settings.Version := 'TEST';
  Settings.Channel := 'stable';
  Settings.PciDevIndex := 1;
  Settings.PciDevText := 'GPU 1: Intel UHD Graphics 770';
  CfgPath := IsolatedHome + '/.config/MangoHud/MangoHud_test1.conf';
  Settings.MangoHudCfgFile := CfgPath;

  AssertTrue('Save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(CfgPath);
    AssertTrue('gpu_list=1 present', Lines.IndexOf('gpu_list=1') >= 0);
  finally
    Lines.Free;
  end;
end;

procedure TMangoHudGpuListTests.TestGpuListBothGpus;
var
  Settings: TMangoHudSettings;
  ErrMsg: string;
  Lines: TStringList;
  CfgPath: string;
begin
  FillChar(Settings, SizeOf(Settings), 0);
  Settings.Version := 'TEST';
  Settings.Channel := 'stable';
  Settings.PciDevIndex := 2;
  Settings.PciDevText := MANGO_PCIDEV_BOTH_GPUS;
  CfgPath := IsolatedHome + '/.config/MangoHud/MangoHud_testboth.conf';
  Settings.MangoHudCfgFile := CfgPath;

  AssertTrue('Save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(CfgPath);
    AssertTrue('gpu_list=0,1 present', Lines.IndexOf('gpu_list=0,1') >= 0);
  finally
    Lines.Free;
  end;
end;

procedure TClearConfigTests.TestPreserveNonEmptyBackups;
var
  BaseDir, GameDir, BackupDir: string;
  F: TextFile;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay_test_preserve';
  GameDir := BaseDir + '/gameconfig/Cyberpunk2077';
  BackupDir := GameDir + '/backups';

  ForceDirectories(BackupDir);
  ForceDirectories(BaseDir + '/bgmod');
  ForceDirectories(BaseDir + '/logs');

  // Create backup dll file
  AssignFile(F, BackupDir + '/amd_fidelityfx_dx12.dll');
  Rewrite(F);
  WriteLn(F, 'ORIGINAL_DLL_CONTENT');
  CloseFile(F);

  // Create config files inside game dir
  AssignFile(F, GameDir + '/MangoHud.conf');
  Rewrite(F);
  WriteLn(F, 'fps=1');
  CloseFile(F);

  AssignFile(F, GameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, 'mod=1');
  CloseFile(F);

  // Create other root files
  AssignFile(F, BaseDir + '/bgmod/bgmod');
  Rewrite(F);
  WriteLn(F, 'BINARY');
  CloseFile(F);

  AssignFile(F, BaseDir + '/logs/app.log');
  Rewrite(F);
  WriteLn(F, 'LOG');
  CloseFile(F);

  AssertTrue('CleanDirectoryPreservingBackups succeeds', CleanDirectoryPreservingBackups(BaseDir));

  // Backup DLL and its path must still exist
  AssertTrue('Backup DLL preserved', FileExists(BackupDir + '/amd_fidelityfx_dx12.dll'));
  AssertTrue('Game directory preserved', DirectoryExists(GameDir));
  AssertTrue('Base directory preserved', DirectoryExists(BaseDir));

  // Config files and other non-backup folders must be deleted
  AssertFalse('MangoHud.conf deleted', FileExists(GameDir + '/MangoHud.conf'));
  AssertFalse('bgmod.conf deleted', FileExists(GameDir + '/bgmod.conf'));
  AssertFalse('bgmod dir removed', DirectoryExists(BaseDir + '/bgmod'));
  AssertFalse('logs dir removed', DirectoryExists(BaseDir + '/logs'));
end;

procedure TClearConfigTests.TestPruneEmptyBackupsAndDirectories;
var
  BaseDir, GameDir, BackupDir: string;
  F: TextFile;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay_test_empty';
  GameDir := BaseDir + '/gameconfig/DoomEternal';
  BackupDir := GameDir + '/backups';

  ForceDirectories(BackupDir); // Empty backups folder

  AssignFile(F, GameDir + '/MangoHud.conf');
  Rewrite(F);
  WriteLn(F, 'fps=1');
  CloseFile(F);

  AssertTrue('CleanDirectoryPreservingBackups succeeds', CleanDirectoryPreservingBackups(BaseDir));

  // Everything should be pruned since there are no non-empty backups
  AssertFalse('Empty backups folder removed', DirectoryExists(BackupDir));
  AssertFalse('Game folder removed', DirectoryExists(GameDir));
  AssertFalse('Base folder removed', DirectoryExists(BaseDir));
end;

procedure TClearConfigTests.TestMultipleGamesMixed;
var
  BaseDir, GameWithBackup, GameEmptyBackup, GameNoBackup: string;
  F: TextFile;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay_test_mixed';
  GameWithBackup := BaseDir + '/gameconfig/Game1';
  GameEmptyBackup := BaseDir + '/gameconfig/Game2';
  GameNoBackup := BaseDir + '/gameconfig/Game3';

  ForceDirectories(GameWithBackup + '/backups');
  ForceDirectories(GameEmptyBackup + '/backups');
  ForceDirectories(GameNoBackup);

  AssignFile(F, GameWithBackup + '/backups/nvngx.dll');
  Rewrite(F);
  WriteLn(F, 'DLL');
  CloseFile(F);

  AssignFile(F, GameWithBackup + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, 'CFG');
  CloseFile(F);

  AssignFile(F, GameEmptyBackup + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, 'CFG');
  CloseFile(F);

  AssignFile(F, GameNoBackup + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, 'CFG');
  CloseFile(F);

  AssertTrue('CleanDirectoryPreservingBackups succeeds', CleanDirectoryPreservingBackups(BaseDir));

  // Game1 backup is preserved, its config is deleted
  AssertTrue('Game1 backup DLL preserved', FileExists(GameWithBackup + '/backups/nvngx.dll'));
  AssertFalse('Game1 config deleted', FileExists(GameWithBackup + '/bgmod.conf'));

  // Game2 and Game3 are completely removed
  AssertFalse('Game2 removed', DirectoryExists(GameEmptyBackup));
  AssertFalse('Game3 removed', DirectoryExists(GameNoBackup));
end;

procedure TMakoLogicTests.TestMakoInstalledCheck;
var
  LayerDir, LayerFile: string;
begin
  LayerDir := IsolatedHome + '/.local/share/vulkan/implicit_layer.d';
  ForceDirectories(LayerDir);
  LayerFile := LayerDir + '/VkLayer_MAKO_render.json';
  FileClose(FileCreate(LayerFile));
  AssertTrue('IsMakoInstalled returns True when layer JSON exists', IsMakoInstalled);
  DeleteFile(LayerFile);
end;

procedure TMakoLogicTests.TestMakoVersionParsing;
var
  StateDir, StateFile: string;
  SL: TStringList;
begin
  StateDir := IsolatedHome + '/.local/share/mako-render';
  ForceDirectories(StateDir);
  StateFile := StateDir + '/active-renderer.json';
  SL := TStringList.Create;
  try
    SL.Add('{"version": "3.0.0", "prefix": "/home/test"}');
    SL.SaveToFile(StateFile);
  finally
    SL.Free;
  end;

  AssertEquals('Parsed version includes leading v', 'v3.0.0', GetMakoInstalledVersion);
  DeleteFile(StateFile);
end;

procedure TMakoLogicTests.TestMakoLibraryPathDetection;
var
  LibDir, LibFile: string;
begin
  LibDir := IsolatedHome + '/.local/lib';
  ForceDirectories(LibDir);
  LibFile := LibDir + '/libmako-render.so';
  FileClose(FileCreate(LibFile));
  AssertEquals('Detects user-space libmako-render.so', LibFile, GetMakoLibraryPath);
  DeleteFile(LibFile);
end;

procedure TMakoLogicTests.TestMakoRemoteVersionUrlResolution;
var
  Url, Ver: string;
begin
  Url := '';
  Ver := GetMakoLatestRemoteVersion(Url);
  if Ver <> '' then
  begin
    AssertTrue('Remote version is v3.x or higher', (Pos('3.', Ver) > 0) or (Pos('4.', Ver) > 0) or (Pos('5.', Ver) > 0));
    AssertTrue('Download URL targets native linux archive', Pos('-linux.tar.xz', Url) > 0);
    AssertFalse('Download URL strictly excludes flatpaks', Pos('flatpak', LowerCase(Url)) > 0);
  end;
end;

procedure TLsfgVkManifestTests.TestPatchLsfgVkManifest;
var
  DummyPath, Content: string;
  Lines: TStringList;
begin
  DummyPath := IncludeTrailingPathDelimiter(IsolatedHome) + 'lsfgvk_manifest_test.json';
  ForceDirectories(ExtractFileDir(DummyPath));

  Lines := TStringList.Create;
  try
    Lines.Add('{');
    Lines.Add('  "file_format_version": "1.0.0",');
    Lines.Add('  "layer": {');
    Lines.Add('    "name": "VK_LAYER_LSFGVK_frame_generation",');
    Lines.Add('    "disable_environment": {');
    Lines.Add('      "DISABLE_LSFGVK": "1"');
    Lines.Add('    }');
    Lines.Add('  }');
    Lines.Add('}');
    Lines.SaveToFile(DummyPath);
  finally
    Lines.Free;
  end;

  try
    AssertTrue('first patch modifies manifest', PatchLsfgVkManifest(DummyPath));

    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(DummyPath);
      Content := Lines.Text;
    finally
      Lines.Free;
    end;

    AssertTrue('manifest contains enable_environment', Pos('"enable_environment"', Content) > 0);
    AssertTrue('manifest contains ENABLE_LSFGVK', Pos('"ENABLE_LSFGVK"', Content) > 0);
    AssertFalse('second patch is idempotent', PatchLsfgVkManifest(DummyPath));
  finally
    if FileExists(DummyPath) then DeleteFile(DummyPath);
  end;
end;

function GetBgmodBinaryPath: string;
var
  Proc: TProcess;
  SourceDir, CompileTarget: string;

  function ExistingBinaryPath: string;
  begin
    if FileExists('./bgmod') then
      Result := './bgmod'
    else if FileExists('../../bgmod') then
      Result := '../../bgmod'
    else if FileExists('data/bgmod/bgmod') then
      Result := 'data/bgmod/bgmod'
    else if FileExists('../../data/bgmod/bgmod') then
      Result := '../../data/bgmod/bgmod'
    else
      Result := '';
  end;
begin
  Result := ExistingBinaryPath;
  if Result <> '' then
    Exit;

  if FileExists('bgmod.lpr') then
  begin
    SourceDir := '.';
    CompileTarget := 'bgmod.lpr';
  end
  else if FileExists('../../bgmod.lpr') then
  begin
    SourceDir := '../..';
    CompileTarget := 'bgmod.lpr';
  end
  else
  begin
    SourceDir := '';
    CompileTarget := '';
  end;

  if SourceDir <> '' then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := FindTestHelperExecutable('fpc');
      Proc.CurrentDirectory := SourceDir;
      Proc.Parameters.Add('-O3');
      Proc.Parameters.Add(CompileTarget);
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;

    Result := ExistingBinaryPath;
    if Result <> '' then
      Exit;
  end;

  Result := FindTestHelperExecutable('bgmod');
end;

procedure TBgmodSupervisorTests.EnsureBgmodBinary;
var
  BinPath: string;
begin
  BinPath := GetBgmodBinaryPath;
  if not FileExists(BinPath) then
    Fail('bgmod binary not found at "' + BinPath + '". Please compile with "fpc -O3 bgmod.lpr" or run "make test-logic".');
end;

procedure TBgmodSupervisorTests.TestSupervisorExitCodeTrue;
var
  Proc: TProcess;
begin
  EnsureBgmodBinary;
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := GetBgmodBinaryPath;
    Proc.Parameters.Add(FindTestHelperExecutable('true'));
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod true should return exit code 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestSupervisorExitCodeFalse;
var
  Proc: TProcess;
begin
  EnsureBgmodBinary;
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := GetBgmodBinaryPath;
    Proc.Parameters.Add(FindTestHelperExecutable('false'));
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod false should return exit code 1', 1, Proc.ExitStatus);
  finally
    Proc.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestSupervisorStderrClosure;
var
  Proc: TProcess;
begin
  EnsureBgmodBinary;
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := GetBgmodBinaryPath;
    Proc.Parameters.Add(FindTestHelperExecutable('sh'));
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('echo "testing stderr output" >&2; exit 0');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod running command with stderr output should return exit code 0 without hanging', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;
end;

function setenv(name: PChar; value: PChar; overwrite: Integer): Integer; cdecl; external 'c' name 'setenv';

procedure TBgmodSupervisorTests.TestBgmodLaunchSplashGameTitleAndReShade;
var
  Proc: TProcess;
  TestGameDir, MockSplashFile, OutFile: string;
  F: TextFile;
  Lines: TStringList;
  Content: string;
  WaitCount, EnvIndex: Integer;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Control Ultimate Edition';
  ForceDirectories(TestGameDir);

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Create mock bgmod-splash in TestGameDir that writes its arguments to a file
  MockSplashFile := TestGameDir + '/bgmod-splash';
  OutFile := TestGameDir + '/splash_args.txt';
  if FileExists(OutFile) then DeleteFile(OutFile);

  AssignFile(F, MockSplashFile);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'echo "$*" > "' + OutFile + '"');
  CloseFile(F);
  fpChmod(PChar(MockSplashFile), &755);

  // Write bgmod.conf with ReShade enabled and envvars including VKSUMI_CONFIG_FILE
  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=1');
  WriteLn(F, '[Env]');
  WriteLn(F, 'MANGOHUD_CONFIGFILE=' + TestGameDir + '/MangoHud.conf');
  WriteLn(F, 'VKSUMI_CONFIG_FILE=' + TestGameDir + '/vkSumi.conf');
  CloseFile(F);

  // Run bgmod true
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(FindTestHelperExecutable('true'));
    Proc.Options := [poWaitOnExit];
    for EnvIndex := 1 to GetEnvironmentVariableCount do
      Proc.Environment.Add(GetEnvironmentString(EnvIndex));
    // Ensure DISPLAY is set so SpawnLaunchSplashAsync does not exit early
    if (GetEnvironmentVariable('DISPLAY') = '') and (GetEnvironmentVariable('WAYLAND_DISPLAY') = '') then
      Proc.Environment.Add('DISPLAY=:99');
    Proc.Execute;
    AssertEquals('bgmod should return 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Wait for background grandchild to write args file (up to 3 seconds)
  WaitCount := 0;
  while not FileExists(OutFile) and (WaitCount < 30) do
  begin
    Sleep(100);
    Inc(WaitCount);
  end;

  AssertTrue('Mock splash args file should exist', FileExists(OutFile));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutFile);
    Content := Lines.Text;

    AssertTrue('Splash args must include game title Control Ultimate Edition',
      Pos('--game=Control Ultimate Edition', Content) > 0);
    AssertFalse('Splash args must not be corrupted by VKSUMI_CONFIG_FILE',
      Pos('--game=VKSUMI_CONFIG_FILE', Content) > 0);
    AssertTrue('Splash args must include ReShade item',
      Pos('--item=ReShade', Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodInjectsLaunchArguments;
var
  Proc: TProcess;
  TestGameDir, MockGameFile, OutFile: string;
  F: TextFile;
  Lines: TStringList;
  Content: string;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/ArgsTestGame';
  ForceDirectories(TestGameDir);

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Create mock game runner script in TestGameDir that writes each received argument on a new line
  MockGameFile := TestGameDir + '/mockgame.sh';
  OutFile := TestGameDir + '/received_args.txt';
  if FileExists(OutFile) then DeleteFile(OutFile);

  AssignFile(F, MockGameFile);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'for arg in "$@"; do echo "$arg" >> "' + OutFile + '"; done');
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockGameFile), &755);

  // Write bgmod.conf with [Args] containing active, multi-word, and disabled arguments
  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, '[Args]');
  WriteLn(F, '-novid=1');
  WriteLn(F, '+fps_max 0=1');
  WriteLn(F, '-dx12=1');
  WriteLn(F, '-disabled_arg=0');
  CloseFile(F);

  // Run bgmod with MockGameFile and an existing command-line argument
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockGameFile);
    Proc.Parameters.Add('--existing-steam-flag');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Verify that arguments were properly injected and tokenized
  AssertTrue('received_args.txt should be created', FileExists(OutFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutFile);
    Content := Lines.Text;

    AssertTrue('Should contain -novid', Pos('-novid', Content) > 0);
    AssertTrue('Should contain +fps_max token', Pos('+fps_max', Content) > 0);
    AssertTrue('Should contain 0 token from +fps_max 0', Pos(#10'0'#10, #10 + Content) > 0);
    AssertTrue('Should contain -dx12', Pos('-dx12', Content) > 0);
    AssertTrue('Should contain --existing-steam-flag', Pos('--existing-steam-flag', Content) > 0);
    AssertFalse('Should not contain disabled argument', Pos('-disabled_arg', Content) > 0);

    // Verify ordering: injected arguments appear before --existing-steam-flag
    AssertTrue('Injected arguments appear before existing parameter',
               Pos('-novid', Content) < Pos('--existing-steam-flag', Content));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodProtonArgsInjection;
var
  Proc: TProcess;
  TestGameDir, MockRunner, MockExe, OutFile: string;
  F: TextFile;
  Lines: TStringList;
  Content: string;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/ProtonArgsTestGame';
  ForceDirectories(TestGameDir);

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Create mock runner script (simulating umu-run or proton wrapper)
  MockRunner := TestGameDir + '/mock_runner.sh';
  OutFile := TestGameDir + '/received_args.txt';
  if FileExists(OutFile) then DeleteFile(OutFile);

  AssignFile(F, MockRunner);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'for arg in "$@"; do echo "$arg" >> "' + OutFile + '"; done');
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRunner), &755);

  MockExe := TestGameDir + '/game.exe';

  // Write bgmod.conf with [Args] containing custom launch arguments (including key-value with '=')
  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, '[Args]');
  WriteLn(F, '-NoLauncher=1');
  WriteLn(F, '-FPS=144=1');
  CloseFile(F);

  // Run bgmod with:
  // 1. MockRunner (the wrapper, e.g. umu-run)
  // 2. --runner-opt=dummy.exe (flag starting with '-' ending in .exe: must NOT be treated as executable)
  // 3. MockExe (game.exe: actual target executable)
  // 4. -epicapp=Dodo (trailing game argument)
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockRunner);
    Proc.Parameters.Add('--runner-opt=dummy.exe');
    Proc.Parameters.Add(MockExe);
    Proc.Parameters.Add('-epicapp=Dodo');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Verify that arguments were injected after game.exe and before game options
  AssertTrue('received_args.txt should be created', FileExists(OutFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutFile);
    Content := Lines.Text;

    AssertTrue('Runner should receive --runner-opt=dummy.exe', Pos('--runner-opt=dummy.exe', Content) > 0);
    AssertTrue('Runner should receive MockExe', Pos(MockExe, Content) > 0);
    AssertTrue('Runner should receive injected -NoLauncher', Pos('-NoLauncher', Content) > 0);
    AssertTrue('Runner should receive injected -FPS=144', Pos('-FPS=144', Content) > 0);
    AssertTrue('Runner should receive trailing -epicapp=Dodo', Pos('-epicapp=Dodo', Content) > 0);

    // Verify ordering: runner opt < game.exe < injected args < trailing game args
    AssertTrue('Runner opt comes before game.exe',
               Pos('--runner-opt=dummy.exe', Content) < Pos(MockExe, Content));
    AssertTrue('Injected arguments appear AFTER game.exe',
               Pos(MockExe, Content) < Pos('-NoLauncher', Content));
    AssertTrue('Injected arguments appear BEFORE trailing game argument',
               Pos('-FPS=144', Content) < Pos('-epicapp=Dodo', Content));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodNativeLinuxResolution;
var
  Proc: TProcess;
  TestGameDir, MockBinDir, MockExe, ConfFile, TomlFile, LogFile, Content, DummySrc: string;
  F: TextFile;
  Lines: TStringList;
  Ini: TIniFile;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/EuroTruckNativeTest';
  MockBinDir := IsolatedHome + '/games/ets2/bin/linux_x64';
  ForceDirectories(TestGameDir);
  ForceDirectories(MockBinDir);

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Create mock native Linux executable with a valid ELF binary (compile a dummy)
  MockExe := MockBinDir + '/eurotrucks2';
  DummySrc := IsolatedHome + '/dummy_game.pas';
  AssignFile(F, DummySrc);
  Rewrite(F);
  WriteLn(F, 'program DummyGame; begin Halt(0); end.');
  CloseFile(F);
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('fpc');
    Proc.Parameters.Add(DummySrc);
    Proc.Parameters.Add('-O3');
    Proc.Parameters.Add('-o' + MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('fpc should compile mock native executable', 0, Proc.ExitStatus);
    fpChmod(PChar(MockExe), &755);
  finally
    Proc.Free;
  end;

  // Create mock container runtime entry point
  ForceDirectories(IsolatedHome + '/runtime');
  AssignFile(F, IsolatedHome + '/runtime/_v2-entry-point');
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'shift 1'); // skip --verb
  WriteLn(F, 'shift 1'); // skip --
  WriteLn(F, '"$@"');    // execute remaining args
  CloseFile(F);
  fpChmod(PChar(IsolatedHome + '/runtime/_v2-entry-point'), &755);

  // Setup bgmod.conf enabling OptiScaler and Lossless Scaling (lsfg)
  ConfFile := TestGameDir + '/bgmod.conf';
  AssignFile(F, ConfFile);
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'GOVERLAY_LOSSLESS=1');
  WriteLn(F, 'INTERPOLATION_METHOD=lsfg');
  WriteLn(F, 'LS_MULTIPLIER=2');
  CloseFile(F);

  // Launch bgmod simulating Steam Linux Runtime container:
  // bgmod .../_v2-entry-point --verb=waitforexitandrun -- /path/to/MockExe -rdevice vk
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(IsolatedHome + '/runtime/_v2-entry-point');
    Proc.Parameters.Add('--verb=waitforexitandrun');
    Proc.Parameters.Add('--');
    Proc.Parameters.Add(MockExe);
    Proc.Parameters.Add('-rdevice');
    Proc.Parameters.Add('vk');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('bgmod should exit 0 running mock native binary', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 1. Verify bgmod.conf cached TARGET_EXE and GAME_DIR
  Ini := TIniFile.Create(ConfFile);
  try
    AssertEquals('Cached TARGET_EXE should be eurotrucks2', 'eurotrucks2', Ini.ReadString('Config', 'TARGET_EXE', ''));
    AssertEquals('Cached GAME_DIR should match mock game dir', MockBinDir, ExcludeTrailingPathDelimiter(Ini.ReadString('Config', 'GAME_DIR', '')));
  finally
    Ini.Free;
  end;

  // 2. Verify conf.toml contains eurotrucks2 in active_in
  TomlFile := TestGameDir + '/conf.toml';
  AssertTrue('conf.toml should be generated for lsfg', FileExists(TomlFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(TomlFile);
    Content := Lines.Text;
    AssertTrue('conf.toml active_in must include eurotrucks2', Pos('"eurotrucks2"', Content) > 0);
    AssertFalse('conf.toml should not include wine64-preloader for native games', Pos('wine64-preloader', Content) > 0);
  finally
    Lines.Free;
  end;

  // 3. Verify log recorded native detection and Windows DLL bypass
  LogFile := IsolatedHome + '/.local/share/goverlay/logs/EuroTruckNativeTest/bgmod.log';
  AssertTrue('bgmod.log should exist in central logs', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    Content := Lines.Text;
    AssertTrue('Log must record native Linux executable detection',
      Pos('Native Linux executable detected (eurotrucks2). Skipping OptiScaler Windows DLL deployment.', Content) > 0);
    AssertTrue('Log must record ReShade Windows DLL skip',
      Pos('Native Linux executable detected (eurotrucks2). Skipping ReShade Windows DLL deployment.', Content) > 0);
  finally
    Lines.Free;
  end;

  // 4. Verify no Windows DLLs were copied to MockBinDir
  AssertFalse('dxgi.dll should NOT be copied to native game dir', FileExists(MockBinDir + '/dxgi.dll'));
  AssertFalse('OptiScaler.dll should NOT be copied to native game dir', FileExists(MockBinDir + '/OptiScaler.dll'));
  AssertFalse('ReShade64.dll should NOT be copied to native game dir', FileExists(MockBinDir + '/ReShade64.dll'));
end;

procedure TBgmodSupervisorTests.TestBgmodCentralToolLoggingSync;
var
  Proc: TProcess;
  TestGameDir, MockGameDir, CentralLogDir: string;
  F: TextFile;
  EnvIndex: Integer;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/LoggingTestGame';
  ForceDirectories(TestGameDir);
  MockGameDir := IsolatedHome + '/.local/share/goverlay/mock_game_logging';
  ForceDirectories(MockGameDir);
  ForceDirectories(MockGameDir + '/HelixSR');
  ForceDirectories(MockGameDir + '/HelixSR/helixsr-fg');

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Write dummy log files in the root game dir and HelixSR subfolders
  AssignFile(F, MockGameDir + '/afmf.log');
  Rewrite(F);
  WriteLn(F, 'afmf log');
  CloseFile(F);

  AssignFile(F, MockGameDir + '/reshade.log');
  Rewrite(F);
  WriteLn(F, 'reshade log');
  CloseFile(F);

  AssignFile(F, MockGameDir + '/HelixSR/helixsr.log');
  Rewrite(F);
  WriteLn(F, 'helixsr log');
  CloseFile(F);

  AssignFile(F, MockGameDir + '/HelixSR/helixsr_loader.log');
  Rewrite(F);
  WriteLn(F, 'helixsr loader log');
  CloseFile(F);

  AssignFile(F, MockGameDir + '/HelixSR/helixsr-fg/nvexec.log');
  Rewrite(F);
  WriteLn(F, 'nvexec log');
  CloseFile(F);

  // Write dummy mock runner script
  AssignFile(F, MockGameDir + '/mockgame.sh');
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockGameDir + '/mockgame.sh'), &755);

  // Write bgmod.conf with splash disabled
  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  CloseFile(F);

  // Execute bgmod with STEAM_COMPAT_INSTALL_PATH=MockGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockGameDir + '/mockgame.sh');
    Proc.Options := [poWaitOnExit];
    for EnvIndex := 1 to GetEnvironmentVariableCount do
      Proc.Environment.Add(GetEnvironmentString(EnvIndex));
    Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + MockGameDir);
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Verify all 5 files were synchronized into the central log directory
  CentralLogDir := IsolatedHome + '/.local/share/goverlay/logs/LoggingTestGame';
  AssertTrue('afmf.log synced to central log dir', FileExists(CentralLogDir + '/afmf.log'));
  AssertTrue('reshade.log synced to central log dir', FileExists(CentralLogDir + '/reshade.log'));
  AssertTrue('helixsr.log synced from HelixSR subdir', FileExists(CentralLogDir + '/helixsr.log'));
  AssertTrue('helixsr_loader.log synced from HelixSR subdir', FileExists(CentralLogDir + '/helixsr_loader.log'));
  AssertTrue('nvexec.log synced from HelixSR/helixsr-fg subdir', FileExists(CentralLogDir + '/nvexec.log'));
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNrDeployment;
var
  Proc: TProcess;
  TestGameDir, MockGameDir, RuntimeDir, ModelsDir, OptiIniPath, MockExe, MockRunner: string;
  F: TextFile;
  EnvIndex: Integer;
  Ini: TIniFile;

  procedure WriteMockFile(const APath: string);
  begin
    AssignFile(F, APath);
    Rewrite(F);
    WriteLn(F, 'mock ', ExtractFileName(APath));
    CloseFile(F);
  end;

begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/DlssNrTestGame';
  ForceDirectories(TestGameDir);
  MockGameDir := IsolatedHome + '/.local/share/goverlay/mock_game_dlssnr';
  ForceDirectories(MockGameDir);
  RuntimeDir := IsolatedHome + '/.local/share/goverlay/dlss-nr-rdna3';
  ForceDirectories(RuntimeDir + '/optiscaler');
  ForceDirectories(RuntimeDir + '/optiscaler/control/layer');
  ForceDirectories(RuntimeDir + '/dlssnr-amd/shaders');
  ForceDirectories(RuntimeDir + '/ini');
  ModelsDir := IsolatedHome + '/.local/share/goverlay/dlss-nr-models';
  ForceDirectories(ModelsDir);

  // Create mock runtime binaries
  AssignFile(F, RuntimeDir + '/optiscaler/OptiScaler.dll');
  Rewrite(F);
  WriteLn(F, 'mock optiscaler-nr dll');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/optiscaler/OptiScaler.ini');
  Rewrite(F);
  WriteLn(F, '[General]');
  WriteLn(F, 'Logging=true');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/optiscaler/dlssnr_core.dll');
  Rewrite(F);
  WriteLn(F, 'mock dlssnr core dll');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/optiscaler/nvngx.dll_dlssnr.dll');
  Rewrite(F);
  WriteLn(F, 'mock nvngx shim');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/optiscaler/control/layer/libVkLayer_dlssnr_control.so');
  Rewrite(F);
  WriteLn(F, 'mock control layer so');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/dlssnr-amd/shaders/test.spv');
  Rewrite(F);
  WriteLn(F, 'mock shader');
  CloseFile(F);

  AssignFile(F, RuntimeDir + '/ini/dlssnr-amd-optiscaler.ini');
  Rewrite(F);
  WriteLn(F, '[General]');
  WriteLn(F, 'Enabled=1');
  CloseFile(F);

  AssignFile(F, ModelsDir + '/dlssnr.bin');
  Rewrite(F);
  WriteLn(F, 'mock model bin');
  CloseFile(F);

  // Networks GOverlay made from the models, and the runtime's int4 layers
  ForceDirectories(RuntimeDir + '/int4/dlssnr-amd/int4/swin');
  WriteMockFile(ModelsDir + '/CC_SMALL_FP8_EXPERIMENTAL.bin');
  WriteMockFile(ModelsDir + '/CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin');
  WriteMockFile(RuntimeDir + '/int4/dlssnr-amd/int4/settings.txt');
  WriteMockFile(RuntimeDir + '/int4/dlssnr-amd/int4/swin/q.fix.bin');

  // Copy bgmod binary to TestGameDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Write mock runner and mock game executable
  MockExe := MockGameDir + '/game.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, 'mock windows pe binary');
  CloseFile(F);

  MockRunner := TestGameDir + '/mock_runner.sh';
  AssignFile(F, MockRunner);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRunner), &755);

  // Write bgmod.conf with UPSCALER_TYPE=4 (DLSS-NR)
  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'UPSCALER_TYPE=4');
  WriteLn(F, 'DLSSNR_ARCH=0');
  WriteLn(F, 'DLL=dxgi.dll');
  WriteLn(F, 'PRESERVE_INI=true');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'TARGET_EXE=game.exe');
  CloseFile(F);

  // Execute bgmod
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockRunner);
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    for EnvIndex := 1 to GetEnvironmentVariableCount do
      Proc.Environment.Add(GetEnvironmentString(EnvIndex));
    Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + MockGameDir);
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Verify DLSS-NR files were correctly deployed to MockGameDir
  AssertTrue('dxgi.dll (OptiScaler-NR) deployed to game dir', FileExists(MockGameDir + '/dxgi.dll'));
  AssertTrue('OptiScaler.dll deployed to game dir', FileExists(MockGameDir + '/OptiScaler.dll'));
  AssertTrue('dlssnr_core.dll deployed to game dir', FileExists(MockGameDir + '/dlssnr_core.dll'));
  AssertTrue('nvngx.dll_dlssnr.dll deployed to game dir', FileExists(MockGameDir + '/nvngx.dll_dlssnr.dll'));
  AssertTrue('dlssnr-amd folder deployed', DirectoryExists(MockGameDir + '/dlssnr-amd'));
  AssertTrue('dlssnr-amd/shaders/test.spv deployed', FileExists(MockGameDir + '/dlssnr-amd/shaders/test.spv'));
  AssertTrue('dlssnr.bin model deployed into dlssnr-amd/', FileExists(MockGameDir + '/dlssnr-amd/dlssnr.bin'));
  AssertTrue('dlssnr-amd.ini deployed', FileExists(MockGameDir + '/dlssnr-amd.ini'));
  AssertTrue('control layer deployed', FileExists(MockGameDir + '/dlssnr-amd/control/layer/libVkLayer_dlssnr_control.so'));
  AssertTrue('Derived network deployed', FileExists(MockGameDir + '/dlssnr-amd/CC_SMALL_FP8_EXPERIMENTAL.bin'));
  AssertTrue('int4 weights deployed', FileExists(MockGameDir + '/dlssnr-amd/CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin'));
  AssertTrue('int4 level deployed', FileExists(MockGameDir + '/dlssnr-amd/int4/settings.txt'));
  AssertFalse('int4 restore tables stay in the runtime', FileExists(MockGameDir + '/dlssnr-amd/int4/swin/q.fix.bin'));
  // Shared test HOME: later tests start without them
  DeleteFile(ModelsDir + '/CC_SMALL_FP8_EXPERIMENTAL.bin');
  DeleteFile(ModelsDir + '/CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin');
  DeleteDirectory(RuntimeDir + '/int4', False);

  // Verify OptiScaler.ini was generated/patched with DLSS-NR configuration
  OptiIniPath := MockGameDir + '/OptiScaler.ini';
  AssertTrue('OptiScaler.ini exists', FileExists(OptiIniPath));
  Ini := TIniFile.Create(OptiIniPath);
  try
    AssertEquals('[DlssNr] Enabled=true', 'true', Ini.ReadString('DlssNr', 'Enabled', ''));
    AssertEquals('[DlssNr] WhitePointSource=1', '1', Ini.ReadString('DlssNr', 'WhitePointSource', ''));
    AssertTrue('[Libraries] NvngxPath configured', Pos('dlssnr_core.dll', Ini.ReadString('Libraries', 'NvngxPath', '')) > 0);
  finally
    Ini.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNrResolvedArchDeployment;
var
  Proc: TProcess;
  TestGameDir, MockGameDir, Runtime4Dir, Runtime3Dir, ModelsDir, MockExe, MockRunner: string;
  F: TextFile;
  EnvIndex: Integer;
  Lines: TStringList;
  DeployedContent: string;

  procedure WriteMockRuntime(const RuntimeDir, Marker: string);
  begin
    ForceDirectories(RuntimeDir + '/optiscaler/control/layer');
    ForceDirectories(RuntimeDir + '/dlssnr-amd/shaders');
    ForceDirectories(RuntimeDir + '/ini');

    AssignFile(F, RuntimeDir + '/optiscaler/OptiScaler.dll');
    Rewrite(F);
    WriteLn(F, Marker);
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/optiscaler/OptiScaler.ini');
    Rewrite(F);
    WriteLn(F, '[General]');
    WriteLn(F, 'Logging=true');
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/optiscaler/dlssnr_core.dll');
    Rewrite(F);
    WriteLn(F, Marker);
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/optiscaler/nvngx.dll_dlssnr.dll');
    Rewrite(F);
    WriteLn(F, Marker);
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/optiscaler/control/layer/libVkLayer_dlssnr_control.so');
    Rewrite(F);
    WriteLn(F, Marker);
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/dlssnr-amd/shaders/test.spv');
    Rewrite(F);
    WriteLn(F, Marker);
    CloseFile(F);

    AssignFile(F, RuntimeDir + '/ini/dlssnr-amd-optiscaler.ini');
    Rewrite(F);
    WriteLn(F, '[General]');
    WriteLn(F, 'Enabled=1');
    CloseFile(F);
  end;

begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/DlssNrResolvedArchTestGame';
  ForceDirectories(TestGameDir);
  MockGameDir := IsolatedHome + '/.local/share/goverlay/mock_game_dlssnr_resolved';
  ForceDirectories(MockGameDir);
  Runtime4Dir := IsolatedHome + '/.local/share/goverlay/dlss-nr-rdna4';
  Runtime3Dir := IsolatedHome + '/.local/share/goverlay/dlss-nr-rdna3';
  ModelsDir := IsolatedHome + '/.local/share/goverlay/dlss-nr-models';

  WriteMockRuntime(Runtime4Dir, 'rdna4-runtime');
  ForceDirectories(Runtime3Dir);
  ForceDirectories(ModelsDir);

  AssignFile(F, ModelsDir + '/dlssnr.bin');
  Rewrite(F);
  WriteLn(F, 'mock model bin');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockExe := MockGameDir + '/game.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, 'mock windows pe binary');
  CloseFile(F);

  MockRunner := TestGameDir + '/mock_runner.sh';
  AssignFile(F, MockRunner);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRunner), &755);

  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'UPSCALER_TYPE=4');
  WriteLn(F, 'DLSSNR_ARCH=0');
  WriteLn(F, 'DLSSNR_RESOLVED_ARCH=1');
  WriteLn(F, 'DLL=dxgi.dll');
  WriteLn(F, 'PRESERVE_INI=true');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'TARGET_EXE=game.exe');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockRunner);
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    for EnvIndex := 1 to GetEnvironmentVariableCount do
      Proc.Environment.Add(GetEnvironmentString(EnvIndex));
    Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + MockGameDir);
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  DeployedContent := '';
  if FileExists(MockGameDir + '/OptiScaler.dll') then
  begin
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(MockGameDir + '/OptiScaler.dll');
      DeployedContent := Lines.Text;
    finally
      Lines.Free;
    end;
  end;

  AssertTrue('RDNA4 runtime OptiScaler.dll deployed', FileExists(MockGameDir + '/OptiScaler.dll'));
  AssertTrue('DLSSNR_RESOLVED_ARCH=1 selected dlss-nr-rdna4', Pos('rdna4-runtime', DeployedContent) > 0);
  AssertFalse('RDNA3 runtime was not selected', Pos('rdna3-runtime', DeployedContent) > 0);
end;

procedure TBgmodSupervisorTests.TestBgmodVkNemuEnvironmentExport;
var
  Proc: TProcess;
  TestGameDir, MockGameFile, OutFile: string;
  F: TextFile;
  Lines: TStringList;
  Content: string;
begin
  EnsureBgmodBinary;
  TestGameDir := IsolatedHome + '/.local/share/goverlay/gameconfig/VkNemuTestGame';
  ForceDirectories(TestGameDir);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockGameFile := TestGameDir + '/mockgame.sh';
  OutFile := TestGameDir + '/env_output.txt';
  if FileExists(OutFile) then DeleteFile(OutFile);

  AssignFile(F, MockGameFile);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'env > env_output.txt');
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockGameFile), &755);

  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_VKNEMU=1');
  WriteLn(F, 'VKNEMU_IDLE_FPS=42');
  WriteLn(F, 'VKNEMU_TIMEOUT=7');
  WriteLn(F, 'VKNEMU_UNFOCUSED=1');
  WriteLn(F, 'VKNEMU_INPUT=keyboard');
  WriteLn(F, 'VKNEMU_DELAY=4');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockGameFile);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := TestGameDir;
    Proc.Execute;
    AssertEquals('bgmod should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  AssertTrue('env_output.txt should be created', FileExists(OutFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutFile);
    Content := Lines.Text;

    AssertTrue('Should export VKNEMU=1', Pos('VKNEMU=1', Content) > 0);
    AssertTrue('Should export VKNEMU_IDLE_FPS=42', Pos('VKNEMU_IDLE_FPS=42', Content) > 0);
    AssertTrue('Should export VKNEMU_TIMEOUT=7', Pos('VKNEMU_TIMEOUT=7', Content) > 0);
    AssertTrue('Should export VKNEMU_UNFOCUSED=1', Pos('VKNEMU_UNFOCUSED=1', Content) > 0);
    AssertTrue('Should export VKNEMU_INPUT=keyboard', Pos('VKNEMU_INPUT=keyboard', Content) > 0);
    AssertTrue('Should export VKNEMU_DELAY=4', Pos('VKNEMU_DELAY=4', Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodReShadeOnlyDoesNotDeleteVendorDlls;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockExe, VortexDir: string;
  F: TextFile;
  Lines: TStringList;
begin
  EnsureBgmodBinary;
  MockGameDir := IsolatedHome + '/games/Cyberpunk2077/bin/x64';
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Cyberpunk 2077';
  ForceDirectories(MockGameDir);
  ForceDirectories(TestGameCfgDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Mock game executable (script with .exe name that runs true)
  MockExe := MockGameDir + '/Cyberpunk2077.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockExe), &755);

  // Create genuine native game files and third-party mod files
  AssignFile(F, MockGameDir + '/nvngx_dlss.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_DLSS'); CloseFile(F);
  AssignFile(F, MockGameDir + '/sl.dlss.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_STREAMLINE'); CloseFile(F);
  AssignFile(F, MockGameDir + '/version.dll'); Rewrite(F); WriteLn(F, 'CET_CYBER_ENGINE_TWEAKS_THIRD_PARTY'); CloseFile(F);

  // Create OptiScaler folder managed by Vortex
  VortexDir := MockGameDir + '/OptiScaler';
  ForceDirectories(VortexDir);
  AssignFile(F, VortexDir + '/__folder_managed_by_vortex'); Rewrite(F); WriteLn(F, 'VORTEX_MARKER'); CloseFile(F);

  // goverlay.vars in GameDir created by a previous ReShade run (contains ONLY reshadeproxy)
  AssignFile(F, MockGameDir + '/goverlay.vars'); Rewrite(F);
  WriteLn(F, 'reshadeproxy=dxgi.dll');
  CloseFile(F);

  // Configure bgmod.conf with ReShade enabled, OptiScaler disabled, DLL=version.dll (conflict dialog saved), RESHADE_DLL=dxgi.dll
  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'GOVERLAY_OPTISCALER=0');
  WriteLn(F, 'DLL=version.dll');
  WriteLn(F, 'RESHADE_DLL=dxgi.dll');
  CloseFile(F);

  // Seed ReShade data dir so ReShade deployment succeeds without error
  ForceDirectories(IsolatedHome + '/.local/share/goverlay/reshade/bin');
  AssignFile(F, IsolatedHome + '/.local/share/goverlay/reshade/bin/ReShade64.dll'); Rewrite(F);
  WriteLn(F, 'MOCK_RESHADE_64_PAYLOAD');
  CloseFile(F);

  // Run bgmod launching MockExe
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly with 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Verify that vendor DLLs, CET version.dll, and Vortex OptiScaler directory are PRESERVED!
  AssertTrue('nvngx_dlss.dll must not be deleted', FileExists(MockGameDir + '/nvngx_dlss.dll'));
  AssertTrue('sl.dlss.dll must not be deleted', FileExists(MockGameDir + '/sl.dlss.dll'));
  AssertTrue('version.dll must not be deleted', FileExists(MockGameDir + '/version.dll'));
  AssertTrue('OptiScaler directory must not be deleted', DirectoryExists(VortexDir));
  AssertTrue('Vortex marker must not be deleted', FileExists(VortexDir + '/__folder_managed_by_vortex'));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(MockGameDir + '/version.dll');
    AssertEquals('version.dll content must be untouched CET', 'CET_CYBER_ENGINE_TWEAKS_THIRD_PARTY', Trim(Lines.Text));
    Lines.LoadFromFile(MockGameDir + '/nvngx_dlss.dll');
    AssertEquals('nvngx_dlss.dll content must be untouched native', 'ORIGINAL_NATIVE_DLSS', Trim(Lines.Text));
  finally
    Lines.Free;
  end;
end;

// Writes a stub that is both a runnable "#!" script (so bgmod can launch it
// and exit 0) and carries a PE header after the script body: e_lfanew at
// 0x3C points to "PE\0\0" followed by the Machine field.
procedure WritePEStub(const APath: string; AMachine: Word; AWithSignature: Boolean);
var
  Hdr: array[0..$5F] of Byte;
  Script: string;
  Stream: TFileStream;
begin
  FillChar(Hdr, SizeOf(Hdr), 0);
  Script := '#!' + FindTestHelperExecutable('sh') + #10 + 'exit 0' + #10;
  if Length(Script) >= $38 then
    raise Exception.Create('test shell path too long for PE stub');
  Move(Script[1], Hdr[0], Length(Script));
  Hdr[$3C] := $40;
  if AWithSignature then
  begin
    Hdr[$40] := $50; // 'P'
    Hdr[$41] := $45; // 'E'
  end;
  Hdr[$44] := Lo(AMachine);
  Hdr[$45] := Hi(AMachine);
  Stream := TFileStream.Create(APath, fmCreate);
  try
    Stream.WriteBuffer(Hdr, SizeOf(Hdr));
  finally
    Stream.Free;
  end;
  fpChmod(PChar(APath), &755);
end;

procedure TBgmodSupervisorTests.RunReShadeArchCase(const ACaseName, AExeKind,
  AExpectedDll, AUnexpectedDll: string);
var
  Proc: TProcess;
  CfgDir, GameDir, MockExe, LogFile, Content: string;
  F: TextFile;
  Lines: TStringList;
begin
  GameDir := IsolatedHome + '/games/' + ACaseName + '/System';
  CfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/' + ACaseName;
  ForceDirectories(GameDir);
  ForceDirectories(CfgDir);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(CfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(CfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockExe := GameDir + '/Game.exe';
  if AExeKind = 'i386' then
    WritePEStub(MockExe, $014C, True)
  else if AExeKind = 'amd64' then
    WritePEStub(MockExe, $8664, True)
  else if AExeKind = 'invalid' then
    WritePEStub(MockExe, $014C, False); // no PE signature: must not be trusted
  // AExeKind = 'missing': the exe is intentionally not created

  AssignFile(F, CfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'GOVERLAY_OPTISCALER=0');
  WriteLn(F, 'RESHADE_DLL=d3d9.dll');
  CloseFile(F);

  // Distinct payloads (different sizes) for each architecture
  ForceDirectories(IsolatedHome + '/.local/share/goverlay/reshade/bin');
  AssignFile(F, IsolatedHome + '/.local/share/goverlay/reshade/bin/ReShade64.dll'); Rewrite(F);
  WriteLn(F, 'MOCK_RESHADE_64_PAYLOAD');
  CloseFile(F);
  AssignFile(F, IsolatedHome + '/.local/share/goverlay/reshade/bin/ReShade32.dll'); Rewrite(F);
  WriteLn(F, 'MOCK_RESHADE_32_PAYLOAD_WITH_A_DIFFERENT_SIZE');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := CfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := GameDir;
    Proc.Execute;
  finally
    Proc.Free;
  end;

  AssertTrue(ACaseName + ': proxy d3d9.dll must be deployed', FileExists(GameDir + '/d3d9.dll'));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(GameDir + '/d3d9.dll');
    AssertEquals(ACaseName + ': deployed ReShade payload', AExpectedDll, Trim(Lines.Text));

    LogFile := IsolatedHome + '/.local/share/goverlay/logs/' + ACaseName + '/bgmod.log';
    AssertTrue(ACaseName + ': bgmod.log should exist', FileExists(LogFile));
    Lines.LoadFromFile(LogFile);
    Content := Lines.Text;
    if AExeKind = 'i386' then
      AssertTrue(ACaseName + ': log records 32-bit detection',
        Pos('Detected 32-bit (i386) game executable', Content) > 0)
    else if AExeKind = 'amd64' then
      AssertTrue(ACaseName + ': log records 64-bit detection',
        Pos('Detected 64-bit (x86-64) game executable', Content) > 0)
    else
      AssertTrue(ACaseName + ': log warns about undetermined architecture',
        Pos('Warning: Could not determine game executable architecture', Content) > 0);
    AssertTrue(ACaseName + ': log must not select the other architecture DLL',
      Pos('Using ' + AUnexpectedDll, Content) = 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodReShadeProxyMatchesExeArchitecture;
var
  BinDir: string;
begin
  EnsureBgmodBinary;
  BinDir := IsolatedHome + '/.local/share/goverlay/reshade/bin';
  try
    // Regression for #455: a 32-bit game needs the 32-bit ReShade runtime
    RunReShadeArchCase('ReShadeArch32', 'i386', 'MOCK_RESHADE_32_PAYLOAD_WITH_A_DIFFERENT_SIZE', 'ReShade64.dll');
    RunReShadeArchCase('ReShadeArch64', 'amd64', 'MOCK_RESHADE_64_PAYLOAD', 'ReShade32.dll');
    // Unreadable or invalid executables keep the previous ReShade64.dll behaviour
    RunReShadeArchCase('ReShadeArchMissing', 'missing', 'MOCK_RESHADE_64_PAYLOAD', 'ReShade32.dll');
    RunReShadeArchCase('ReShadeArchInvalid', 'invalid', 'MOCK_RESHADE_64_PAYLOAD', 'ReShade32.dll');
  finally
    // The mock HOME is shared by the whole suite: do not leave payloads that
    // would make later "ReShade not installed" checks see a runtime.
    if FileExists(BinDir + '/ReShade32.dll') then DeleteFile(BinDir + '/ReShade32.dll');
    if FileExists(BinDir + '/ReShade64.dll') then DeleteFile(BinDir + '/ReShade64.dll');
  end;
end;

procedure WritePEImportTestStub(const APath: string; AIs64Bit: Boolean; const AImportDll: string);
var
  Buf: array[0..$2FF] of Byte;
  PeOff, OptOff, DataDirOff, SecOff, ImpOff, NameOff: Integer;
  OptSize: Word;
  ImportRVA, NameRVA, SecRVA, SecSize, SecRaw: LongWord;
  Stream: TFileStream;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  PeOff := $40;
  Buf[$3C] := Lo(PeOff);
  Buf[$40] := $50; // 'P'
  Buf[$41] := $45; // 'E'
  // Machine
  if AIs64Bit then
  begin
    Buf[PeOff + 4] := $64;
    Buf[PeOff + 5] := $86;
    OptSize := 240;
  end
  else
  begin
    Buf[PeOff + 4] := $4C;
    Buf[PeOff + 5] := $01;
    OptSize := 224;
  end;
  // NumberOfSections = 1
  Buf[PeOff + 6] := 1;
  // SizeOfOptionalHeader
  Buf[PeOff + 20] := Lo(OptSize);
  Buf[PeOff + 21] := Hi(OptSize);

  OptOff := PeOff + 24;
  if AIs64Bit then
  begin
    Buf[OptOff] := $0B;
    Buf[OptOff + 1] := $02; // PE32+
    DataDirOff := OptOff + 112;
  end
  else
  begin
    Buf[OptOff] := $0B;
    Buf[OptOff + 1] := $01; // PE32
    DataDirOff := OptOff + 96;
  end;

  SecOff := OptOff + OptSize;
  SecRVA := $1000;
  SecRaw := $200;
  SecSize := $100;
  ImportRVA := SecRVA;
  NameRVA := SecRVA + 40;

  // DataDirectory[1].VirtualAddress = ImportRVA
  Move(ImportRVA, Buf[DataDirOff + 8], 4);

  // Section[0]: VirtualSize, VirtualAddress, SizeOfRawData, PointerToRawData
  Move(SecSize, Buf[SecOff + 8], 4);
  Move(SecRVA, Buf[SecOff + 12], 4);
  Move(SecSize, Buf[SecOff + 16], 4);
  Move(SecRaw, Buf[SecOff + 20], 4);

  // Import descriptor at SecRaw ($200): NameRVA at +12
  ImpOff := SecRaw;
  Move(NameRVA, Buf[ImpOff + 12], 4);

  // DLL name string at SecRaw + 40
  NameOff := SecRaw + 40;
  if Length(AImportDll) > 0 then
    Move(AImportDll[1], Buf[NameOff], Length(AImportDll));

  Stream := TFileStream.Create(APath, fmCreate);
  try
    Stream.WriteBuffer(Buf, SizeOf(Buf));
  finally
    Stream.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestDetectPEGraphicsApi;
var
  Dir, ExePath: string;
begin
  Dir := IsolatedHome + '/pe_api_test';
  ForceDirectories(Dir);

  ExePath := Dir + '/dx9_32.exe';
  WritePEImportTestStub(ExePath, False, 'd3d9.dll');
  AssertEquals('PE32 importing d3d9.dll -> gapiDX9', Ord(gapiDX9), Ord(DetectPEGraphicsApi(ExePath)));
  AssertEquals('DX9 recommended proxy', 'd3d9.dll', RecommendedProxyForApi(gapiDX9));

  ExePath := Dir + '/dx11_64.exe';
  WritePEImportTestStub(ExePath, True, 'd3d11.dll');
  AssertEquals('PE32+ importing d3d11.dll -> gapiDX11', Ord(gapiDX11), Ord(DetectPEGraphicsApi(ExePath)));
  AssertEquals('DX11 recommended proxy', 'dxgi.dll', RecommendedProxyForApi(gapiDX11));

  ExePath := Dir + '/gl_32.exe';
  WritePEImportTestStub(ExePath, False, 'opengl32.dll');
  AssertEquals('PE32 importing opengl32.dll -> gapiOpenGL', Ord(gapiOpenGL), Ord(DetectPEGraphicsApi(ExePath)));
  AssertEquals('OpenGL recommended proxy', 'opengl32.dll', RecommendedProxyForApi(gapiOpenGL));

  AssertEquals('Missing exe -> gapiUnknown', Ord(gapiUnknown), Ord(DetectPEGraphicsApi(Dir + '/nonexistent.exe')));
end;

procedure TBgmodSupervisorTests.TestDetectLegacyDirect3DApi;
var
  Dir: string;

  procedure Fresh(const AName: string);
  begin
    Dir := IsolatedHome + '/legacy_d3d/' + AName;
    ForceDirectories(Dir);
  end;

  // Strings a module carries without importing them (LoadLibrary/GetProcAddress)
  procedure AppendStrings(const APath: string; const AData: AnsiString);
  var
    Stream: TFileStream;
  begin
    Stream := TFileStream.Create(APath, fmOpenReadWrite);
    try
      Stream.Seek(0, soEnd);
      Stream.WriteBuffer(AData[1], Length(AData));
    finally
      Stream.Free;
    end;
  end;

  function Utf16(const AText: AnsiString): AnsiString;
  var
    i: Integer;
  begin
    SetLength(Result, Length(AText) * 2);
    for i := 1 to Length(AText) do
    begin
      Result[2 * i - 1] := AText[i];
      Result[2 * i] := #0;
    end;
  end;

begin
  Fresh('dx8_import');
  WritePEImportTestStub(Dir + '/game.exe', False, 'd3d8.dll');
  AssertEquals('PE32 importing d3d8.dll -> gapiDX8', Ord(gapiDX8), Ord(DetectPEGraphicsApi(Dir + '/game.exe')));
  AssertEquals('DX8 display name', 'DirectX 8', GraphicsApiDisplayName(gapiDX8));
  AssertEquals('Exe importing d3d8.dll', Ord(gapiDX8), Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  Fresh('dx9_import');
  WritePEImportTestStub(Dir + '/game.exe', False, 'd3d9.dll');
  AssertEquals('Exe importing d3d9.dll', Ord(gapiDX9), Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  // Max Payne: neither the exe nor its renderer module imports Direct3D; the
  // module loads D3D8.DLL and Direct3DCreate8 at run time
  Fresh('dx8_runtime_loaded_module');
  WritePEImportTestStub(Dir + '/maxpayne.exe', False, 'kernel32.dll');
  ForceDirectories(Dir + '/e2driver');
  WritePEImportTestStub(Dir + '/e2driver/e2_d3d8_driver_mfc.dll', False, 'kernel32.dll');
  AppendStrings(Dir + '/e2driver/e2_d3d8_driver_mfc.dll', 'D3D8.DLL'#0'Direct3DCreate8'#0'd3d8.dll'#0);
  AssertEquals('d3d8.dll loaded at run time by a module one folder down', Ord(gapiDX8),
    Ord(DetectLegacyDirect3DApi(Dir + '/maxpayne.exe')));

  Fresh('dx9_runtime_loaded_utf16');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  WritePEImportTestStub(Dir + '/render.dll', False, 'kernel32.dll');
  AppendStrings(Dir + '/render.dll', Utf16('d3d9.dll') + #0#0'Direct3DCreate9'#0);
  AssertEquals('d3d9.dll loaded through LoadLibraryW', Ord(gapiDX9),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  // Hooking tools (DxWnd in Command & Conquer Red Alert II) name every runtime
  Fresh('hook_tool_module');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  WritePEImportTestStub(Dir + '/dxwnd.dll', False, 'kernel32.dll');
  AppendStrings(Dir + '/dxwnd.dll', 'd3d8.dll'#0'Direct3DCreate8'#0'd3d9.dll'#0'Direct3DCreate9'#0 +
    'ddraw.dll'#0'opengl32.dll'#0'd3d11.dll'#0);
  AssertEquals('A module naming several graphics runtimes is not a renderer', Ord(gapiUnknown),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  // DXVK's d3d8.dll (copied by the D3D8 route) imports d3d9.dll
  Fresh('dxvk_d3d8_copy');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  WritePEImportTestStub(Dir + '/d3d8.dll', False, 'd3d9.dll');
  AssertEquals('A Direct3D runtime in the game folder is not the renderer', Ord(gapiUnknown),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  Fresh('dx8_renderer_module');
  WritePEImportTestStub(Dir + '/maxpayne.exe', False, 'kernel32.dll');
  ForceDirectories(Dir + '/e2driver');
  WritePEImportTestStub(Dir + '/e2driver/e2_d3d8_driver_mfc.dll', False, 'd3d8.dll');
  WritePEImportTestStub(Dir + '/sound.dll', False, 'dsound.dll');
  AssertEquals('d3d8.dll imported by a module one folder down', Ord(gapiDX8),
    Ord(DetectLegacyDirect3DApi(Dir + '/maxpayne.exe')));

  Fresh('dx9_module_next_to_exe');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  WritePEImportTestStub(Dir + '/renderer.dll', False, 'd3d9.dll');
  AssertEquals('d3d9.dll imported by a module next to the exe', Ord(gapiDX9),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  Fresh('dx11_exe');
  WritePEImportTestStub(Dir + '/game.exe', False, 'd3d11.dll');
  WritePEImportTestStub(Dir + '/legacy.dll', False, 'd3d9.dll');
  AssertEquals('An exe importing a newer API is not a legacy Direct3D game', Ord(gapiUnknown),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  // Modules GOverlay and DLSS-NR install are not the game's renderer
  Fresh('own_modules');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  WritePEImportTestStub(Dir + '/ReShade32.dll', False, 'd3d9.dll');
  ForceDirectories(Dir + '/dlssnr-amd');
  WritePEImportTestStub(Dir + '/dlssnr-amd/helper.dll', False, 'd3d9.dll');
  AssertEquals('ReShade32.dll and dlssnr-amd/ are not scanned', Ord(gapiUnknown),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  Fresh('deep_module');
  WritePEImportTestStub(Dir + '/game.exe', False, 'kernel32.dll');
  ForceDirectories(Dir + '/a/b');
  WritePEImportTestStub(Dir + '/a/b/deep.dll', False, 'd3d9.dll');
  AssertEquals('Only one folder level is scanned', Ord(gapiUnknown),
    Ord(DetectLegacyDirect3DApi(Dir + '/game.exe')));

  AssertEquals('Missing exe', Ord(gapiUnknown), Ord(DetectLegacyDirect3DApi(IsolatedHome + '/legacy_d3d/none.exe')));
end;

procedure WriteDlssNr32TestText(const APath, AText: string);
var
  SL: TStringList;
begin
  ForceDirectories(ExtractFileDir(APath));
  SL := TStringList.Create;
  try
    SL.Text := AText;
    SL.SaveToFile(APath);
  finally
    SL.Free;
  end;
end;

function ReadDlssNr32TestText(const APath: string): string;
var
  SL: TStringList;
begin
  Result := '';
  if not FileExists(APath) then Exit;
  SL := TStringList.Create;
  try
    SL.LoadFromFile(APath);
    Result := Trim(SL.Text);
  finally
    SL.Free;
  end;
end;

// A minimal DLSSNR-AMD i686 package (dlss-nr-rdna3-i686) and extracted models
procedure SetupDlssNr32TestRuntime;
var
  Base, Rt: string;
begin
  Base := IsolatedHome + '/.local/share/goverlay/';
  Rt := Base + 'dlss-nr-rdna3-i686/';
  WriteDlssNr32TestText(Rt + 'goverlay.vars', 'OPTISCALER_DLSSNR_VERSION=v0.0.9-linux-rdna3');
  WriteDlssNr32TestText(Rt + 'reshade/ReShade.ini', '[GENERAL]' + LineEnding + 'EffectSearchPaths=.\reshade-shaders\Shaders');
  WriteDlssNr32TestText(Rt + 'reshade/ReShadePreset.ini', 'GENERIC_PRESET');
  WriteDlssNr32TestText(Rt + 'reshade/ReShade-LICENSE.md', 'license');
  WriteDlssNr32TestText(Rt + 'reshade/dlssnr_amd.addon32', 'ADDON32_FP');
  WriteDlssNr32TestText(Rt + 'reshade/dxgi.dll', 'RESHADE_FEEDER_DXGI');
  WriteDlssNr32TestText(Rt + 'reshade/reshade-shaders/Shaders/test.fx', 'shader');
  WriteDlssNr32TestText(Rt + 'vulkan/ReShade32.dll', 'RESHADE32_LAYER');
  WriteDlssNr32TestText(Rt + 'vulkan/vulkan-1.dll', 'VULKAN_LOADER');
  WriteDlssNr32TestText(Rt + 'vulkan/winevulkan.dll', 'WINEVULKAN');
  WriteDlssNr32TestText(Rt + 'vulkan/ReShadePreset-d3d9.ini', 'D3D9_PRESET');
  WriteDlssNr32TestText(Rt + 'vulkan/vk-override/implicit_layer/ReShade32.json', '{}');
  WriteDlssNr32TestText(Rt + 'int4/reshade/dlssnr_amd.addon32', 'ADDON32_INT4');
  WriteDlssNr32TestText(Rt + 'dlssnr-amd/shaders/nr.spv', 'spirv');
  WriteDlssNr32TestText(Rt + 'ini/dlssnr-amd-addon.ini',
    '; add-on settings' + LineEnding +
    '[DlssNr]' + LineEnding +
    'Enabled=true' + LineEnding +
    'Passes=1' + LineEnding +
    'WorkingScale=1.000' + LineEnding +
    'SkinProtection=false' + LineEnding +
    '' + LineEnding +
    '[Network]' + LineEnding +
    '; which network NR runs' + LineEnding +
    'Model = CC_SMALL_FP8' + LineEnding +
    'OptimizedLayers = 3' + LineEnding +
    '' + LineEnding +
    '[Preprocess]' + LineEnding +
    'Enabled = 0' + LineEnding +
    '' + LineEnding +
    '[RenoDX]' + LineEnding +
    'Enabled = 0' + LineEnding +
    'NRHookPoint = 2' + LineEnding +
    'NRPasses = 1');
  WriteDlssNr32TestText(Base + 'dlss-nr-models/CC_SILVER_AARDWOLD.bin', 'SILVER_WEIGHTS');
  WriteDlssNr32TestText(Base + 'dlss-nr-models/CC_SMALL_FP8.bin', 'SMALL_WEIGHTS');
end;

function SameDlssNr32TestFile(const AFirst, ASecond: string): Boolean;
var
  A, B: TMemoryStream;
begin
  Result := False;
  if not (FileExists(AFirst) and FileExists(ASecond)) then Exit;
  A := TMemoryStream.Create;
  B := TMemoryStream.Create;
  try
    A.LoadFromFile(AFirst);
    B.LoadFromFile(ASecond);
    Result := (A.Size = B.Size) and CompareMem(A.Memory, B.Memory, A.Size);
  finally
    B.Free;
    A.Free;
  end;
end;

// A 32-bit PE standing in for a DXVK d3d8.dll; ATag makes builds tell apart
procedure WriteDxvkD3D8TestStub(const APath, ATag: string; AIs64Bit: Boolean = False);
begin
  ForceDirectories(ExtractFileDir(APath));
  WritePEImportTestStub(APath, AIs64Bit, ATag + '.dll');
end;

procedure CopyBgmodForDlssNr32Test(const ACfgDir: string);
var
  Proc: TProcess;
begin
  ForceDirectories(ACfgDir);
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(ACfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(ACfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;
  WriteDlssNr32TestText(ACfgDir + '/mock_runner.sh',
    '#!' + FindTestHelperExecutable('sh') + LineEnding +
    'env > "' + ACfgDir + '/env.txt"' + LineEnding +
    'exit 0');
  fpChmod(PChar(ACfgDir + '/mock_runner.sh'), &755);
end;

// Runs bgmod as Steam would (runner, then its arguments) without inherited
// Wine overrides; AExtraEnv entries are added to the environment.
function RunBgmodForDlssNr32Test(const ACfgDir, AGameDir: string;
  const AArgs: array of string; const AExtraEnv: array of string): Integer;
var
  Proc: TProcess;
  EnvStr: string;
  i: Integer;
begin
  if FileExists(ACfgDir + '/env.txt') then
    DeleteFile(ACfgDir + '/env.txt');
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := ACfgDir + '/bgmod';
    Proc.Parameters.Add(ACfgDir + '/mock_runner.sh');
    for i := 0 to High(AArgs) do
      Proc.Parameters.Add(AArgs[i]);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := AGameDir;
    for i := 1 to GetEnvironmentVariableCount do
    begin
      EnvStr := GetEnvironmentString(i);
      // Wine settings and Proton/DXVK lookups come only from the test itself
      if (Pos('WINEDLLOVERRIDES=', UpperCase(EnvStr)) <> 1) and
         (Pos('WINE_D3D_CONFIG=', UpperCase(EnvStr)) <> 1) and
         (Pos('PROTONPATH=', UpperCase(EnvStr)) <> 1) and
         (Pos('STEAM_COMPAT_TOOL_PATHS=', UpperCase(EnvStr)) <> 1) and
         (Pos('PROTON_USE_WINED3D=', UpperCase(EnvStr)) <> 1) and
         (Pos('XDG_DATA_HOME=', UpperCase(EnvStr)) <> 1) then
        Proc.Environment.Add(EnvStr);
    end;
    Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + AGameDir);
    for i := 0 to High(AExtraEnv) do
      Proc.Environment.Add(AExtraEnv[i]);
    Proc.Execute;
    Result := Proc.ExitStatus;
  finally
    Proc.Free;
  end;
end;

function DlssNr32TestEnvValue(const ACfgDir, AKey: string): string;
var
  SL: TStringList;
  i: Integer;
begin
  Result := '';
  if not FileExists(ACfgDir + '/env.txt') then Exit;
  SL := TStringList.Create;
  try
    SL.LoadFromFile(ACfgDir + '/env.txt');
    for i := 0 to SL.Count - 1 do
      if Pos(AKey + '=', SL[i]) = 1 then
        Exit(Copy(SL[i], Length(AKey) + 2, MaxInt));
  finally
    SL.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNr32BitDx8ReShadeRoute;
const
  RouteFiles: array[0..12] of string = ('ReShade32.dll', 'vulkan-1.dll', 'winevulkan.dll',
    'vk-override', 'reshade-shaders', 'ReShade.ini', 'ReShadePreset.ini', 'ReShade-LICENSE.md',
    'dlssnr_amd.addon32', 'dlssnr-amd', 'dlssnr-amd.ini', 'd3d8.dll', 'dlssnr-amd-install.txt');
var
  CfgDir, GameDir, ProtonDir, Exe, VarsFile, LogFile, Overrides: string;
  Ini: TIniFile;
  i: Integer;
begin
  EnsureBgmodBinary;
  SetupDlssNr32TestRuntime;
  CfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/DlssNr32Dx8Game';
  GameDir := IsolatedHome + '/games/Max Payne';
  CopyBgmodForDlssNr32Test(CfgDir);

  // Max Payne layout: Direct3D 8 comes from the renderer module in e2driver/
  Exe := GameDir + '/maxpayne.exe';
  ForceDirectories(GameDir + '/e2driver');
  WritePEImportTestStub(Exe, False, 'kernel32.dll');
  WritePEImportTestStub(GameDir + '/e2driver/e2_d3d8_driver_mfc.dll', False, 'd3d8.dll');
  WriteDlssNr32TestText(GameDir + '/savegame.txt', 'user data');

  // The Proton build launching the game, with DXVK's 32-bit d3d8.dll
  ProtonDir := IsolatedHome + '/compatibilitytools.d/proton-cachyos';
  WriteDlssNr32TestText(ProtonDir + '/proton', '#!/bin/sh');
  WriteDxvkD3D8TestStub(ProtonDir + '/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'dxvk_launch');

  WriteDlssNr32TestText(CfgDir + '/bgmod.conf',
    '[Config]' + LineEnding +
    'SHOW_LAUNCH_SPLASH=0' + LineEnding +
    'GOVERLAY_OPTISCALER=1' + LineEnding +
    'UPSCALER_TYPE=4' + LineEnding +
    'DLSSNR_ARCH=2' + LineEnding +
    'DLL=dxgi.dll' + LineEnding +
    'TARGET_EXE=maxpayne.exe');
  // DLSS-NR settings saved in GOverlay
  WriteDlssNr32TestText(CfgDir + '/dlssnr-amd.ini',
    '[Network]' + LineEnding + 'Model = CC_SILVER_AARDWOLD' + LineEnding + 'OptimizedLayers = 3' + LineEnding +
    '[Preprocess]' + LineEnding + 'Enabled = 1' + LineEnding +
    '[RenoDX]' + LineEnding + 'Enabled = 1' + LineEnding + 'NRHookPoint = 0' + LineEnding +
    'NRResolutionScale = 0.75' + LineEnding + 'NRPasses = 2' + LineEnding +
    '[wilsjo2]' + LineEnding + 'RunBeforeSR = false' + LineEnding + 'Passes = 2' + LineEnding +
    'WorkingScale = 0.75' + LineEnding + 'SkinProtection = true');

  // 1. Install
  AssertEquals('bgmod exits cleanly', 0,
    RunBgmodForDlssNr32Test(CfgDir, GameDir, [ProtonDir + '/proton', 'waitforexitandrun', Exe], []));

  AssertEquals('ReShade32.dll from vulkan/', 'RESHADE32_LAYER', ReadDlssNr32TestText(GameDir + '/ReShade32.dll'));
  AssertEquals('Vulkan loader', 'VULKAN_LOADER', ReadDlssNr32TestText(GameDir + '/vulkan-1.dll'));
  AssertEquals('winevulkan', 'WINEVULKAN', ReadDlssNr32TestText(GameDir + '/winevulkan.dll'));
  AssertTrue('ReShade layer manifest', FileExists(GameDir + '/vk-override/implicit_layer/ReShade32.json'));
  AssertTrue('ReShade shaders', FileExists(GameDir + '/reshade-shaders/Shaders/test.fx'));
  AssertEquals('The D3D9 preset is the ReShadePreset.ini', 'D3D9_PRESET', ReadDlssNr32TestText(GameDir + '/ReShadePreset.ini'));
  AssertFalse('ReShadePreset-d3d9.ini is not copied as itself', FileExists(GameDir + '/ReShadePreset-d3d9.ini'));
  AssertEquals('The int4 add-on replaces the default one', 'ADDON32_INT4', ReadDlssNr32TestText(GameDir + '/dlssnr_amd.addon32'));
  AssertFalse('The reshade-feeder dxgi.dll is not part of this route', FileExists(GameDir + '/dxgi.dll'));
  AssertFalse('No OptiScaler in a 32-bit game', FileExists(GameDir + '/OptiScaler.dll'));
  AssertTrue('Runtime folder', FileExists(GameDir + '/dlssnr-amd/shaders/nr.spv'));
  AssertEquals('Models copied', 'SILVER_WEIGHTS', ReadDlssNr32TestText(GameDir + '/dlssnr-amd/CC_SILVER_AARDWOLD.bin'));
  AssertTrue('DXVK d3d8.dll from the launching Proton',
    SameDlssNr32TestFile(ProtonDir + '/files/lib/wine/dxvk/i386-windows/d3d8.dll', GameDir + '/d3d8.dll'));
  AssertTrue('Default ini copy for NR', FileExists(GameDir + '/dlssnr-amd/dlssnr-amd.default.ini'));

  Overrides := ReadDlssNr32TestText(GameDir + '/dlssnr-amd-install.txt');
  AssertTrue('Manifest lists files', Pos('ReShade32.dll', Overrides) > 0);
  AssertTrue('Manifest lists folders with /', Pos('vk-override/', Overrides) > 0);
  AssertTrue('Manifest lists d3d8.dll', Pos('d3d8.dll', Overrides) > 0);
  AssertTrue('Manifest lists the ReShade log', Pos('ReShade.log', Overrides) > 0);

  VarsFile := GameDir + '/goverlay.vars';
  Ini := TIniFile.Create(GameDir + '/dlssnr-amd.ini');
  try
    AssertEquals('Model from GOverlay', 'CC_SILVER_AARDWOLD', Ini.ReadString('Network', 'Model', ''));
    AssertEquals('Preprocess from GOverlay', '1', Ini.ReadString('Preprocess', 'Enabled', ''));
    AssertEquals('RenoDX from GOverlay', '1', Ini.ReadString('RenoDX', 'Enabled', ''));
    AssertEquals('NRPasses from GOverlay', '2', Ini.ReadString('RenoDX', 'NRPasses', ''));
    AssertEquals('New key added to its section', '0.75', Ini.ReadString('RenoDX', 'NRResolutionScale', ''));
    AssertEquals('NRHookPoint is OptiScaler-only: the add-on keeps its own', '2', Ini.ReadString('RenoDX', 'NRHookPoint', ''));
    AssertEquals('[wilsjo2] Passes -> [DlssNr]', '2', Ini.ReadString('DlssNr', 'Passes', ''));
    AssertEquals('[wilsjo2] WorkingScale -> [DlssNr]', '0.75', Ini.ReadString('DlssNr', 'WorkingScale', ''));
    AssertEquals('[wilsjo2] SkinProtection -> [DlssNr]', 'true', Ini.ReadString('DlssNr', 'SkinProtection', ''));
    AssertEquals('RunBeforeSR has no ReShade-route key', '', Ini.ReadString('DlssNr', 'RunBeforeSR', ''));
  finally
    Ini.Free;
  end;
  AssertTrue('Add-on ini comments kept', Pos('; which network NR runs', ReadDlssNr32TestText(GameDir + '/dlssnr-amd.ini')) > 0);

  Overrides := ReadDlssNr32TestText(VarsFile);
  AssertTrue('Route recorded', Pos('dlssnrroute=reshade-dx9', Overrides) > 0);
  AssertTrue('Runtime version recorded', Pos('dlssnrruntime=v0.0.9-linux-rdna3', Overrides) > 0);
  AssertTrue('Direct3D version recorded', Pos('dlssnrapi=DirectX 8', Overrides) > 0);
  AssertTrue('Upscaler type recorded', Pos('upscalertype=4', Overrides) > 0);

  Overrides := DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES');
  AssertTrue('winevulkan override', Pos('winevulkan=n,b', Overrides) > 0);
  AssertTrue('vulkan-1 override', Pos('vulkan-1=n,b', Overrides) > 0);
  AssertTrue('d3d8 override for DXVK''s d3d8.dll', Pos('d3d8=n,b', Overrides) > 0);
  AssertTrue('No OptiScaler proxy override', Pos('dxgi=', Overrides) = 0);
  AssertEquals('wined3d without 3D', 'renderer=gdi', DlssNr32TestEnvValue(CfgDir, 'WINE_D3D_CONFIG'));
  AssertEquals('No int4 Vulkan layer without the int4 weights', 0,
    Pos('VK_LAYER_DLSSNR_int4', DlssNr32TestEnvValue(CfgDir, 'VK_INSTANCE_LAYERS')));

  // 2. Up to date: nothing is copied again, changes made in game are kept
  WriteDlssNr32TestText(GameDir + '/ReShade.ini', 'CHANGED_IN_GAME');
  Ini := TIniFile.Create(GameDir + '/dlssnr-amd.ini');
  try
    Ini.WriteString('DlssNr', 'Intensity', '0.500');
  finally
    Ini.Free;
  end;
  FileSetDate(CfgDir + '/dlssnr-amd.ini', DateTimeToFileDate(Now - 1));
  // Proton updated: its DXVK d3d8.dll changed
  WriteDxvkD3D8TestStub(ProtonDir + '/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'dxvk_launch_updated_build');
  AssertEquals('second run exits cleanly', 0,
    RunBgmodForDlssNr32Test(CfgDir, GameDir, [ProtonDir + '/proton', 'waitforexitandrun', Exe], []));
  LogFile := IsolatedHome + '/.local/share/goverlay/logs/DlssNr32Dx8Game/bgmod.log';
  AssertTrue('Log says the route is up to date',
    Pos('DLSS-NR ReShade route in game directory is already up to date', ReadDlssNr32TestText(LogFile)) > 0);
  AssertEquals('Files are not copied again', 'CHANGED_IN_GAME', ReadDlssNr32TestText(GameDir + '/ReShade.ini'));
  AssertTrue('d3d8.dll follows the updated Proton build',
    SameDlssNr32TestFile(ProtonDir + '/files/lib/wine/dxvk/i386-windows/d3d8.dll', GameDir + '/d3d8.dll'));
  AssertTrue('Overrides still exported', Pos('vulkan-1=n,b', DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES')) > 0);

  // 3. Settings saved in GOverlay after that are applied, in-game changes kept
  WriteDlssNr32TestText(CfgDir + '/dlssnr-amd.ini',
    '[Network]' + LineEnding + 'Model = CC_SMALL_FP8' + LineEnding +
    '[wilsjo2]' + LineEnding + 'Passes = 3');
  FileSetDate(CfgDir + '/dlssnr-amd.ini', DateTimeToFileDate(Now + 1));
  AssertEquals('third run exits cleanly', 0,
    RunBgmodForDlssNr32Test(CfgDir, GameDir, [ProtonDir + '/proton', 'waitforexitandrun', Exe], []));
  Ini := TIniFile.Create(GameDir + '/dlssnr-amd.ini');
  try
    AssertEquals('Newer GOverlay model applied', 'CC_SMALL_FP8', Ini.ReadString('Network', 'Model', ''));
    AssertEquals('Newer GOverlay passes applied', '3', Ini.ReadString('DlssNr', 'Passes', ''));
    AssertEquals('In-game change kept', '0.500', Ini.ReadString('DlssNr', 'Intensity', ''));
  finally
    Ini.Free;
  end;

  // 4. DLSS-NR turned off in GOverlay: the route is removed, the game is not touched
  WriteDlssNr32TestText(CfgDir + '/bgmod.conf',
    '[Config]' + LineEnding +
    'SHOW_LAUNCH_SPLASH=0' + LineEnding +
    'GOVERLAY_OPTISCALER=0' + LineEnding +
    'UPSCALER_TYPE=4' + LineEnding +
    'TARGET_EXE=maxpayne.exe');
  AssertEquals('fourth run exits cleanly', 0,
    RunBgmodForDlssNr32Test(CfgDir, GameDir, [ProtonDir + '/proton', 'waitforexitandrun', Exe], []));
  for i := 0 to High(RouteFiles) do
    AssertFalse('Removed: ' + RouteFiles[i],
      FileExists(GameDir + '/' + RouteFiles[i]) or DirectoryExists(GameDir + '/' + RouteFiles[i]));
  AssertTrue('Game exe kept', FileExists(Exe));
  AssertTrue('Renderer module kept', FileExists(GameDir + '/e2driver/e2_d3d8_driver_mfc.dll'));
  AssertTrue('User files kept', FileExists(GameDir + '/savegame.txt'));
  AssertFalse('Route marker removed', Pos('dlssnrroute', ReadDlssNr32TestText(VarsFile)) > 0);
  AssertEquals('No overrides once removed', '', DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES'));
  AssertEquals('No wined3d setting once removed', '', DlssNr32TestEnvValue(CfgDir, 'WINE_D3D_CONFIG'));
end;

// Raw bytes, without the line ending TStringList adds (checksum fixtures)
procedure WriteDerivedNetworkTestBytes(const APath: string; const AData: AnsiString);
var
  Stream: TFileStream;
begin
  ForceDirectories(ExtractFileDir(APath));
  Stream := TFileStream.Create(APath, fmCreate);
  try
    if AData <> '' then
      Stream.WriteBuffer(AData[1], Length(AData));
  finally
    Stream.Free;
  end;
end;

function ReadDerivedNetworkTestBytes(const APath: string): AnsiString;
var
  Stream: TFileStream;
begin
  Result := '';
  if not FileExists(APath) then Exit;
  Stream := TFileStream.Create(APath, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, Stream.Size);
    if Stream.Size > 0 then
      Stream.ReadBuffer(Result[1], Stream.Size);
  finally
    Stream.Free;
  end;
end;

procedure TOptiScalerIniTests.TestMakeDlssNrDerivedNetworks;
const
  SHA_EXP = 'f4f1e1400d3ed6cf5041275a0e48d274374b4bd410a74c7304e16ca023a207e7';   // 'SMALL+EXP'
  SHA_OPT = '700dda2c388780d57d16df0aea9793a639493a3f1a3e8b7939d4079a6ec29404';   // 'SILVER+OPT'
  SHA_INT4 = '7d8b105d5c3861f4e4d073748adc894fe28b91c33e0bc96ce3d899f8f7d286b9';  // 'SILVER+OPT+INT4'
  // experimental_weights.py "apply PACK DELTA OUT", reduced to OUT = PACK + '+' + DELTA
  APPLY_STUB = 'import sys' + LineEnding +
    '_, mode, pack, delta, out = sys.argv' + LineEnding +
    'open(out, "wb").write(open(pack, "rb").read() + b"+" + open(delta, "rb").read())';
var
  Base, Models, Rt, Marker: string;
begin
  Base := IsolatedHome + '/derived_networks/';
  Models := Base + 'models/';
  Rt := Base + 'runtime/';
  WriteDerivedNetworkTestBytes(Models + 'CC_SMALL_FP8.bin', 'SMALL');
  WriteDerivedNetworkTestBytes(Models + 'CC_SILVER_AARDWOLD.bin', 'SILVER');
  WriteDlssNr32TestText(Rt + 'experimental/experimental_weights.py', APPLY_STUB);
  WriteDerivedNetworkTestBytes(Rt + 'experimental/dlssnr-small-experimental.delta', 'EXP');
  WriteDlssNr32TestText(Rt + 'experimental/CC_SMALL_FP8_EXPERIMENTAL.bin.sha256',
    SHA_EXP + '  CC_SMALL_FP8_EXPERIMENTAL.bin');
  WriteDlssNr32TestText(Rt + 'optimized/experimental_weights.py', APPLY_STUB);
  WriteDerivedNetworkTestBytes(Rt + 'optimized/dlssnr-optimized.delta', 'OPT');
  WriteDlssNr32TestText(Rt + 'optimized/CC_SILVER_AARDWOLD_OPTIMIZED.bin.sha256',
    SHA_OPT + '  CC_SILVER_AARDWOLD_OPTIMIZED.bin');
  // dlssnr-int4-weights OPTIMIZED TABLES OUT, reduced to OUT = OPTIMIZED + '+INT4'
  WriteDlssNr32TestText(Rt + 'int4/dlssnr-int4-weights',
    '#!' + FindTestHelperExecutable('sh') + LineEnding + 'cat "$1" > "$3" && printf "+INT4" >> "$3"');
  fpChmod(PChar(Rt + 'int4/dlssnr-int4-weights'), &755);
  WriteDerivedNetworkTestBytes(Rt + 'int4/dlssnr-amd/int4-ultra/table.fix.bin', 'T');
  WriteDlssNr32TestText(Rt + 'int4/CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin.sha256',
    SHA_INT4 + '  CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin');

  // A runtime without the package files is passed over
  AssertTrue('Every network is made', MakeDlssNrDerivedNetworks(Models, [Base + 'no-runtime', Rt]));
  AssertEquals('CC_SMALL_FP8_EXPERIMENTAL from CC_SMALL_FP8', 'SMALL+EXP',
    ReadDerivedNetworkTestBytes(Models + 'CC_SMALL_FP8_EXPERIMENTAL.bin'));
  AssertEquals('CC_SILVER_AARDWOLD_OPTIMIZED from CC_SILVER_AARDWOLD', 'SILVER+OPT',
    ReadDerivedNetworkTestBytes(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED.bin'));
  AssertEquals('The int4 weights from CC_SILVER_AARDWOLD_OPTIMIZED', 'SILVER+OPT+INT4',
    ReadDerivedNetworkTestBytes(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin'));
  AssertFalse('No part file left', FileExists(Models + 'CC_SMALL_FP8_EXPERIMENTAL.bin.part'));
  Marker := ReadDlssNr32TestText(Models + 'derived-networks.vars');
  AssertTrue('Checksums recorded', (Pos('CC_SMALL_FP8_EXPERIMENTAL=' + SHA_EXP, Marker) > 0) and
    (Pos('CC_SILVER_AARDWOLD_OPTIMIZED_INT4=' + SHA_INT4, Marker) > 0));

  // Made once: a later call does not run the tools again
  WriteDlssNr32TestText(Rt + 'experimental/experimental_weights.py', 'import sys' + LineEnding + 'sys.exit(1)');
  WriteDlssNr32TestText(Rt + 'int4/dlssnr-int4-weights', '#!' + FindTestHelperExecutable('sh') + LineEnding + 'exit 1');
  AssertTrue('Networks made before are kept', MakeDlssNrDerivedNetworks(Models, [Rt]));
  AssertEquals('Experimental network kept', 'SMALL+EXP',
    ReadDerivedNetworkTestBytes(Models + 'CC_SMALL_FP8_EXPERIMENTAL.bin'));
  AssertEquals('Int4 weights kept', 'SILVER+OPT+INT4',
    ReadDerivedNetworkTestBytes(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin'));

  // A newer package names another checksum: made again, and removed when the
  // result does not match, so the game greys it out instead of running it
  WriteDlssNr32TestText(Rt + 'experimental/experimental_weights.py', APPLY_STUB);
  WriteDlssNr32TestText(Rt + 'experimental/CC_SMALL_FP8_EXPERIMENTAL.bin.sha256',
    StringOfChar('0', 64) + '  CC_SMALL_FP8_EXPERIMENTAL.bin');
  AssertFalse('A network with the wrong checksum is reported', MakeDlssNrDerivedNetworks(Models, [Rt]));
  AssertFalse('A network with the wrong checksum is not kept', FileExists(Models + 'CC_SMALL_FP8_EXPERIMENTAL.bin'));
  AssertEquals('Its record goes with it', 0,
    Pos('CC_SMALL_FP8_EXPERIMENTAL=', ReadDlssNr32TestText(Models + 'derived-networks.vars')));
  AssertTrue('The other networks stay', FileExists(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin'));

  // CC_SILVER_AARDWOLD_OPTIMIZED cannot be made for a newer package: its int4
  // weights, made from it, go too
  WriteDlssNr32TestText(Rt + 'optimized/CC_SILVER_AARDWOLD_OPTIMIZED.bin.sha256',
    StringOfChar('1', 64) + '  CC_SILVER_AARDWOLD_OPTIMIZED.bin');
  MakeDlssNrDerivedNetworks(Models, [Rt]);
  AssertFalse('Optimized network removed', FileExists(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED.bin'));
  AssertFalse('Its int4 weights removed', FileExists(Models + 'CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin'));

  // Without CC_SMALL_FP8 (the 310.8.0 DLL has only CC_SILVER_AARDWOLD) there
  // is nothing to make CC_SMALL_FP8_EXPERIMENTAL from, which is no failure
  DeleteFile(Models + 'CC_SMALL_FP8.bin');
  DeleteFile(Models + 'CC_SILVER_AARDWOLD.bin');
  AssertTrue('Nothing to make without the models', MakeDlssNrDerivedNetworks(Models, [Rt]));
  AssertFalse('No experimental network without CC_SMALL_FP8', FileExists(Models + 'CC_SMALL_FP8_EXPERIMENTAL.bin'));
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNr32BitDerivedNetworks;
const
  Derived: array[0..2] of string = ('CC_SMALL_FP8_EXPERIMENTAL.bin', 'CC_SILVER_AARDWOLD_OPTIMIZED.bin',
    'CC_SILVER_AARDWOLD_OPTIMIZED_INT4.bin');
var
  Base, Rt, CfgDir, GameDir, Exe: string;
  Ini: TIniFile;
  d: Integer;
begin
  EnsureBgmodBinary;
  SetupDlssNr32TestRuntime;
  Base := IsolatedHome + '/.local/share/goverlay/';
  Rt := Base + 'dlss-nr-rdna3-i686/';
  CfgDir := Base + 'gameconfig/DlssNr32Derived';
  GameDir := IsolatedHome + '/games/Derived Networks';
  CopyBgmodForDlssNr32Test(CfgDir);
  Exe := GameDir + '/game.exe';
  ForceDirectories(GameDir);
  WritePEImportTestStub(Exe, False, 'd3d9.dll');
  WriteDlssNr32TestText(CfgDir + '/bgmod.conf',
    '[Config]' + LineEnding +
    'SHOW_LAUNCH_SPLASH=0' + LineEnding +
    'GOVERLAY_OPTISCALER=1' + LineEnding +
    'UPSCALER_TYPE=4' + LineEnding +
    'DLSSNR_ARCH=2' + LineEnding +
    'DLL=dxgi.dll' + LineEnding +
    'TARGET_EXE=game.exe');
  WriteDlssNr32TestText(CfgDir + '/dlssnr-amd.ini', '[Network]' + LineEnding + 'Model = CC_SILVER_AARDWOLD_OPTIMIZED');

  try
    // Networks GOverlay made, and the runtime's int4 layers
    for d := 0 to High(Derived) do
      WriteDlssNr32TestText(Base + 'dlss-nr-models/' + Derived[d], 'MADE_' + Derived[d]);
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4/layer/VkLayer_dlssnr_int4_32.json', '{}');
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4/settings.txt', 'balanced');
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4/swin/q.fix.bin', 'restore table');
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4-performance/settings.txt', 'performance');
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4-ultra/settings.txt', 'ultra performance');
    WriteDlssNr32TestText(Rt + 'int4/dlssnr-amd/int4-ultra/vit/m.mu.bin', 'restore table');

    AssertEquals('bgmod exits cleanly', 0,
      RunBgmodForDlssNr32Test(CfgDir, GameDir, [Exe], ['VK_INSTANCE_LAYERS=VK_LAYER_user']));
    for d := 0 to High(Derived) do
      AssertEquals(Derived[d] + ' installed', 'MADE_' + Derived[d],
        ReadDlssNr32TestText(GameDir + '/dlssnr-amd/' + Derived[d]));
    AssertEquals('Balanced int4 level', 'balanced', ReadDlssNr32TestText(GameDir + '/dlssnr-amd/int4/settings.txt'));
    AssertEquals('Performance int4 level', 'performance',
      ReadDlssNr32TestText(GameDir + '/dlssnr-amd/int4-performance/settings.txt'));
    AssertEquals('Ultra Performance int4 level', 'ultra performance',
      ReadDlssNr32TestText(GameDir + '/dlssnr-amd/int4-ultra/settings.txt'));
    AssertTrue('int4 Vulkan layer', FileExists(GameDir + '/dlssnr-amd/int4/layer/VkLayer_dlssnr_int4_32.json'));
    AssertFalse('Restore tables stay in the package',
      FileExists(GameDir + '/dlssnr-amd/int4/swin/q.fix.bin') or FileExists(GameDir + '/dlssnr-amd/int4-ultra/vit/m.mu.bin'));
    Ini := TIniFile.Create(GameDir + '/dlssnr-amd.ini');
    try
      AssertEquals('The chosen derived network is kept', 'CC_SILVER_AARDWOLD_OPTIMIZED',
        Ini.ReadString('Network', 'Model', ''));
    finally
      Ini.Free;
    end;
    AssertTrue('int4 layer folder on the layer path',
      Pos(GameDir + '/dlssnr-amd/int4/layer', DlssNr32TestEnvValue(CfgDir, 'VK_ADD_LAYER_PATH')) > 0);
    AssertEquals('int4 layer added to the user''s layers', 'VK_LAYER_user:VK_LAYER_DLSSNR_int4',
      DlssNr32TestEnvValue(CfgDir, 'VK_INSTANCE_LAYERS'));

    // A network GOverlay makes later reaches the installed route at the next launch
    DeleteFile(GameDir + '/dlssnr-amd/CC_SMALL_FP8_EXPERIMENTAL.bin');
    AssertEquals('bgmod exits cleanly again', 0, RunBgmodForDlssNr32Test(CfgDir, GameDir, [Exe], []));
    AssertTrue('The route is not reinstalled',
      Pos('already up to date', ReadDlssNr32TestText(Base + 'logs/DlssNr32Derived/bgmod.log')) > 0);
    AssertEquals('The network is copied in', 'MADE_CC_SMALL_FP8_EXPERIMENTAL.bin',
      ReadDlssNr32TestText(GameDir + '/dlssnr-amd/CC_SMALL_FP8_EXPERIMENTAL.bin'));
  finally
    for d := 0 to High(Derived) do
      DeleteFile(Base + 'dlss-nr-models/' + Derived[d]);
    DeleteDirectory(Rt + 'int4/dlssnr-amd', False);
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNr32BitDx8FindsDxvkD3D8;
var
  Base, Steam, CfgDir, LogText, Chosen, Lib: string;
  SR: TSearchRec;
  SystemHasOne: Boolean;

  // A fresh Max Payne-like game; returns its folder
  function NewDx8Game(const AName: string): string;
  begin
    Result := IsolatedHome + '/games/dx8-' + AName;
    ForceDirectories(Result + '/e2driver');
    WritePEImportTestStub(Result + '/maxpayne.exe', False, 'kernel32.dll');
    WritePEImportTestStub(Result + '/e2driver/e2_d3d8_driver_mfc.dll', False, 'd3d8.dll');
  end;

  procedure Launch(const AGame: string; const AArgs: array of string; const AEnv: array of string);
  begin
    AssertEquals('bgmod exits cleanly', 0, RunBgmodForDlssNr32Test(CfgDir, AGame, AArgs, AEnv));
    LogText := ReadDlssNr32TestText(Base + 'logs/DlssNr32Dx8Lookup/bgmod.log');
  end;

  procedure SetAge(const APath: string; ADaysAgo: Double);
  begin
    FileSetDate(APath, DateTimeToFileDate(Now - ADaysAgo));
  end;

var
  Game: string;
begin
  EnsureBgmodBinary;
  SetupDlssNr32TestRuntime;
  Base := IsolatedHome + '/.local/share/goverlay/';
  Steam := IsolatedHome + '/.local/share/Steam/';
  CfgDir := Base + 'gameconfig/DlssNr32Dx8Lookup';
  CopyBgmodForDlssNr32Test(CfgDir);
  WriteDlssNr32TestText(CfgDir + '/bgmod.conf',
    '[Config]' + LineEnding +
    'SHOW_LAUNCH_SPLASH=0' + LineEnding +
    'GOVERLAY_OPTISCALER=1' + LineEnding +
    'UPSCALER_TYPE=4' + LineEnding +
    'DLSSNR_ARCH=2' + LineEnding +
    'DLL=dxgi.dll' + LineEnding +
    'TARGET_EXE=maxpayne.exe');

  // 1. No DXVK d3d8.dll anywhere: nothing installed, the game keeps Wine's own
  //    Direct3D 8 (renderer=gdi without DXVK would leave it without 3D). A
  //    system-wide Proton (a distribution package) would be found, so this
  //    part only runs without one.
  SystemHasOne := False;
  if FindFirst('/usr/share/steam/compatibilitytools.d/*', faDirectory, SR) = 0 then
  begin
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') and
         FileExists('/usr/share/steam/compatibilitytools.d/' + SR.Name + '/files/lib/wine/dxvk/i386-windows/d3d8.dll') then
        SystemHasOne := True;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
  if not SystemHasOne then
  begin
    Game := NewDx8Game('nodxvk');
    Launch(Game, [Game + '/maxpayne.exe'], []);
    AssertFalse('No route without DXVK''s d3d8.dll', FileExists(Game + '/ReShade32.dll'));
    AssertFalse('No d3d8.dll', FileExists(Game + '/d3d8.dll'));
    AssertEquals('No wined3d setting', '', DlssNr32TestEnvValue(CfgDir, 'WINE_D3D_CONFIG'));
    AssertEquals('No overrides', '', DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES'));
    AssertTrue('Log says why', Pos('no DXVK d3d8.dll found', LogText) > 0);
  end;

  // 2. PROTONPATH (umu-launcher: Heroic, Lutris)
  WriteDxvkD3D8TestStub(IsolatedHome + '/umu/GE-Proton-umu/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'dxvk_umu');
  Game := NewDx8Game('protonpath');
  Launch(Game, [Game + '/maxpayne.exe'], ['PROTONPATH=' + IsolatedHome + '/umu/GE-Proton-umu']);
  AssertTrue('d3d8.dll from PROTONPATH',
    SameDlssNr32TestFile(IsolatedHome + '/umu/GE-Proton-umu/files/lib/wine/dxvk/i386-windows/d3d8.dll', Game + '/d3d8.dll'));
  AssertTrue('Route installed', FileExists(Game + '/ReShade32.dll'));
  AssertTrue('Log names the source', Pos('(PROTONPATH)', LogText) > 0);

  // 3. Nothing in the launch: the newest installed build. Valve's Proton in a
  //    second Steam library is the newest; a newer d3d8.dll in a game folder,
  //    an older GE-Proton and a 64-bit DXVK build are not taken.
  Lib := IsolatedHome + '/library2';
  WriteDlssNr32TestText(Steam + 'steamapps/libraryfolders.vdf',
    '"libraryfolders"' + LineEnding + '{' + LineEnding +
    '  "0"' + LineEnding + '  {' + LineEnding + '    "path"    "' + IsolatedHome + '/.local/share/Steam"' + LineEnding + '  }' + LineEnding +
    '  "1"' + LineEnding + '  {' + LineEnding + '    "path"    "' + Lib + '"' + LineEnding + '  }' + LineEnding + '}');
  WriteDxvkD3D8TestStub(Steam + 'compatibilitytools.d/GE-Proton9-1/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'dxvk_ge9');
  SetAge(Steam + 'compatibilitytools.d/GE-Proton9-1/files/lib/wine/dxvk/i386-windows/d3d8.dll', 30);
  WriteDxvkD3D8TestStub(Lib + '/steamapps/common/Proton - Experimental/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'dxvk_experimental');
  SetAge(Lib + '/steamapps/common/Proton - Experimental/files/lib/wine/dxvk/i386-windows/d3d8.dll', 2);
  WriteDxvkD3D8TestStub(Lib + '/steamapps/common/Some Game/files/lib/wine/dxvk/i386-windows/d3d8.dll', 'not_proton');
  SetAge(Lib + '/steamapps/common/Some Game/files/lib/wine/dxvk/i386-windows/d3d8.dll', 0);
  WriteDxvkD3D8TestStub(IsolatedHome + '/.local/share/lutris/runtime/dxvk/dxvk-2.5/x32/d3d8.dll', 'dxvk_lutris_x64', True);
  SetAge(IsolatedHome + '/.local/share/lutris/runtime/dxvk/dxvk-2.5/x32/d3d8.dll', 0);
  Game := NewDx8Game('installed');
  Launch(Game, [Game + '/maxpayne.exe'], []);
  Chosen := Lib + '/steamapps/common/Proton - Experimental/files/lib/wine/dxvk/i386-windows/d3d8.dll';
  AssertTrue('Newest installed Proton''s d3d8.dll', SameDlssNr32TestFile(Chosen, Game + '/d3d8.dll'));
  AssertTrue('Log names the source', Pos('(the newest installed DXVK)', LogText) > 0);
  AssertTrue('d3d8 override', Pos('d3d8=n,b', DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES')) > 0);

  // A newer DXVK build in Lutris becomes the newest
  WriteDxvkD3D8TestStub(IsolatedHome + '/.local/share/lutris/runtime/dxvk/dxvk-2.6/x32/d3d8.dll', 'dxvk_lutris_26');
  Game := NewDx8Game('lutris');
  Launch(Game, [Game + '/maxpayne.exe'], []);
  AssertTrue('Newest DXVK release from Lutris',
    SameDlssNr32TestFile(IsolatedHome + '/.local/share/lutris/runtime/dxvk/dxvk-2.6/x32/d3d8.dll', Game + '/d3d8.dll'));

  // 4. PROTON_USE_WINED3D=1: the game never reaches Vulkan, nothing installed,
  //    and an earlier install is removed
  Launch(Game, [Game + '/maxpayne.exe'], ['PROTON_USE_WINED3D=1']);
  AssertFalse('Route removed under PROTON_USE_WINED3D', FileExists(Game + '/ReShade32.dll'));
  AssertFalse('Its d3d8.dll removed too', FileExists(Game + '/d3d8.dll'));
  AssertEquals('No wined3d setting', '', DlssNr32TestEnvValue(CfgDir, 'WINE_D3D_CONFIG'));
  AssertTrue('Log says why', Pos('PROTON_USE_WINED3D=1', LogText) > 0);
end;

procedure TBgmodSupervisorTests.TestBgmodDlssNr32BitDx9ReplacesEarlierInstalls;
var
  CfgDir, GameDir, Exe, Base, VarsText, Uninstaller: string;
  Proc: TProcess;
  EnvIndex: Integer;
begin
  EnsureBgmodBinary;
  SetupDlssNr32TestRuntime;
  Base := IsolatedHome + '/.local/share/goverlay/';
  CfgDir := Base + 'gameconfig/DlssNr32Dx9Game';
  GameDir := IsolatedHome + '/games/Space Marine';
  CopyBgmodForDlssNr32Test(CfgDir);
  Exe := GameDir + '/SpaceMarine.exe';
  ForceDirectories(GameDir);
  WritePEImportTestStub(Exe, False, 'd3d9.dll');

  WriteDlssNr32TestText(CfgDir + '/bgmod.conf',
    '[Config]' + LineEnding +
    'SHOW_LAUNCH_SPLASH=0' + LineEnding +
    'GOVERLAY_OPTISCALER=1' + LineEnding +
    'GOVERLAY_RESHADE=1' + LineEnding +
    'RESHADE_DLL=d3d9.dll' + LineEnding +
    'UPSCALER_TYPE=4' + LineEnding +
    'DLSSNR_ARCH=2' + LineEnding +
    'DLL=dxgi.dll' + LineEnding +
    'TARGET_EXE=SpaceMarine.exe');

  // Without the 32-bit runtime nothing is installed, not even the 64-bit
  // OptiScaler route (it cannot load into a 32-bit game)
  // bgmod falls back to the other architecture's runtime: hide both
  RenameFile(Base + 'dlss-nr-rdna3-i686', Base + 'dlss-nr-rdna3-i686.hidden');
  RenameFile(Base + 'dlss-nr-rdna4-i686', Base + 'dlss-nr-rdna4-i686.hidden');
  try
    WriteDlssNr32TestText(Base + 'dlss-nr-rdna3/optiscaler/OptiScaler.dll', 'OPTISCALER_NR_64');
    AssertEquals('run without runtime exits cleanly', 0, RunBgmodForDlssNr32Test(CfgDir, GameDir, [Exe], []));
    AssertFalse('No route without its runtime', FileExists(GameDir + '/ReShade32.dll'));
    AssertFalse('No 64-bit OptiScaler route either', FileExists(GameDir + '/OptiScaler.dll'));
    AssertTrue('Log names the missing runtime', Pos('32-bit DLSS-NR runtime',
      ReadDlssNr32TestText(Base + 'logs/DlssNr32Dx9Game/bgmod.log')) > 0);
  finally
    RenameFile(Base + 'dlss-nr-rdna3-i686.hidden', Base + 'dlss-nr-rdna3-i686');
    RenameFile(Base + 'dlss-nr-rdna4-i686.hidden', Base + 'dlss-nr-rdna4-i686');
  end;

  // Earlier installs: DLSSNR-AMD's own installer, GOverlay's 64-bit OptiScaler
  // route (from before GOverlay knew the game is 32-bit), GOverlay's ReShade
  WriteDlssNr32TestText(GameDir + '/dlssnr-amd-install.txt',
    'dlssnr-amd-install.txt' + LineEnding + 'ReShade32.dll' + LineEnding +
    'installer-only.txt' + LineEnding + 'dlssnr-amd/' + LineEnding + '../outside.txt' + LineEnding +
    'linked-shaders/');
  WriteDlssNr32TestText(GameDir + '/ReShade32.dll', 'FROM_INSTALLER');
  WriteDlssNr32TestText(GameDir + '/installer-only.txt', 'x');
  WriteDlssNr32TestText(GameDir + '/dlssnr-amd/old.bin', 'x');
  WriteDlssNr32TestText(IsolatedHome + '/games/outside.txt', 'must survive');
  // A folder in the manifest that the user turned into a link to shared files
  WriteDlssNr32TestText(IsolatedHome + '/shared-shaders/Shaders/keep.fx', 'shared');
  fpSymlink(PChar(IsolatedHome + '/shared-shaders'), PChar(GameDir + '/linked-shaders'));
  WriteDlssNr32TestText(GameDir + '/goverlay.vars',
    'upscalertype=4' + LineEnding + 'proxydll=dxgi.dll' + LineEnding + 'reshadeproxy=d3d9.dll');
  WriteDlssNr32TestText(GameDir + '/dxgi.dll', 'OPTISCALER_PROXY');
  WriteDlssNr32TestText(GameDir + '/OptiScaler.dll', 'x');
  WriteDlssNr32TestText(GameDir + '/OptiScaler.ini', 'x');
  WriteDlssNr32TestText(GameDir + '/d3d9.dll', 'GOVERLAY_RESHADE_PROXY');

  AssertEquals('bgmod exits cleanly', 0,
    RunBgmodForDlssNr32Test(CfgDir, GameDir, [Exe], ['WINE_D3D_CONFIG=csmt=0x1']));

  AssertFalse('Installer files removed by its manifest', FileExists(GameDir + '/installer-only.txt'));
  AssertFalse('Installer runtime folder replaced', FileExists(GameDir + '/dlssnr-amd/old.bin'));
  AssertTrue('Manifest entries outside the game folder are ignored', FileExists(IsolatedHome + '/games/outside.txt'));
  AssertFalse('A linked folder in the manifest is unlinked', FileExists(GameDir + '/linked-shaders/Shaders/keep.fx'));
  AssertTrue('What the link pointed to is kept', FileExists(IsolatedHome + '/shared-shaders/Shaders/keep.fx'));
  AssertFalse('OptiScaler route purged', FileExists(GameDir + '/OptiScaler.dll') or FileExists(GameDir + '/OptiScaler.ini'));
  AssertFalse('OptiScaler proxy purged', FileExists(GameDir + '/dxgi.dll'));
  AssertFalse('GOverlay ReShade proxy removed (the route has its own ReShade)', FileExists(GameDir + '/d3d9.dll'));
  AssertEquals('Route installed', 'RESHADE32_LAYER', ReadDlssNr32TestText(GameDir + '/ReShade32.dll'));
  AssertFalse('No d3d8.dll for a Direct3D 9 game', FileExists(GameDir + '/d3d8.dll'));
  VarsText := ReadDlssNr32TestText(GameDir + '/goverlay.vars');
  AssertTrue('Direct3D 9 recorded', Pos('dlssnrapi=DirectX 9', VarsText) > 0);
  AssertTrue('ReShade proxy marker removed', Pos('reshadeproxy', VarsText) = 0);
  AssertTrue('OptiScaler proxy marker removed', Pos('proxydll', VarsText) = 0);

  AssertEquals('Only the route''s overrides', 'winevulkan=n,b;vulkan-1=n,b',
    DlssNr32TestEnvValue(CfgDir, 'WINEDLLOVERRIDES'));
  AssertEquals('The user''s wined3d settings are kept', 'csmt=0x1;renderer=gdi',
    DlssNr32TestEnvValue(CfgDir, 'WINE_D3D_CONFIG'));

  // bgmod-uninstaller removes the route by its manifest
  Uninstaller := ExpandFileName(ExtractFilePath(GetBgmodBinaryPath) + 'bgmod-uninstaller');
  if FileExists(Uninstaller) then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := Uninstaller;
      // Launched like bgmod: it removes the mods, then runs the game
      Proc.Parameters.Add(CfgDir + '/mock_runner.sh');
      Proc.Parameters.Add(Exe);
      Proc.Options := [poWaitOnExit];
      Proc.CurrentDirectory := GameDir;
      for EnvIndex := 1 to GetEnvironmentVariableCount do
        Proc.Environment.Add(GetEnvironmentString(EnvIndex));
      Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + GameDir);
      Proc.Execute;
      AssertEquals('bgmod-uninstaller exits cleanly', 0, Proc.ExitStatus);
    finally
      Proc.Free;
    end;
    AssertFalse('Uninstaller removed ReShade32.dll', FileExists(GameDir + '/ReShade32.dll'));
    AssertFalse('Uninstaller removed the Vulkan loader', FileExists(GameDir + '/vulkan-1.dll'));
    AssertFalse('Uninstaller removed vk-override/', DirectoryExists(GameDir + '/vk-override'));
    AssertFalse('Uninstaller removed the manifest', FileExists(GameDir + '/dlssnr-amd-install.txt'));
    AssertTrue('Uninstaller kept the game', FileExists(Exe));
  end;
end;

procedure TBgmodSupervisorTests.TestResolveRealGameExecutableHeuristics;
var
  BaseDir, GameRoot, LauncherExe, RealExe, ExternalLauncher: string;
  F: TextFile;
begin
  BaseDir := IsolatedHome + '/smart_exe_heuristics';

  // 1. Unity + Paradox Launcher (Cities: Skylines II layout)
  GameRoot := BaseDir + '/Cities Skylines II';
  ForceDirectories(GameRoot + '/Launcher');
  ForceDirectories(GameRoot + '/Cities2_Data');
  LauncherExe := GameRoot + '/Launcher/dowser.exe';
  RealExe := GameRoot + '/Cities2.exe';
  WritePEStub(LauncherExe, $8664, True);
  WritePEStub(RealExe, $8664, True);
  AssignFile(F, GameRoot + '/UnityPlayer.dll'); Rewrite(F); WriteLn(F, 'UNITY'); CloseFile(F);
  AssignFile(F, GameRoot + '/Launcher/libcef.dll'); Rewrite(F); WriteLn(F, 'CEF'); CloseFile(F);

  AssertEquals('Unity game with Launcher/dowser.exe resolves to Cities2.exe',
    RealExe, ResolveRealGameExecutable(LauncherExe, ''));
  AssertEquals('FindMainGameExecutable on Unity game root resolves to Cities2.exe',
    RealExe, FindMainGameExecutable(GameRoot));

  // External Paradox Launcher inside Proton prefix with STEAM_COMPAT_INSTALL_PATH
  ForceDirectories(BaseDir + '/pfx/Paradox Interactive/launcher');
  ExternalLauncher := BaseDir + '/pfx/Paradox Interactive/launcher/Paradox Launcher.exe';
  WritePEStub(ExternalLauncher, $8664, True);
  AssertEquals('External Paradox Launcher with STEAM_COMPAT_INSTALL_PATH resolves to Cities2.exe',
    RealExe, ResolveRealGameExecutable(ExternalLauncher, GameRoot));

  // 2. Unreal Engine game with Launcher/ subdirectory
  GameRoot := BaseDir + '/UnrealWithLauncher';
  ForceDirectories(GameRoot + '/Launcher');
  ForceDirectories(GameRoot + '/Engine/Binaries');
  ForceDirectories(GameRoot + '/MyProject/Binaries/Win64');
  LauncherExe := GameRoot + '/Launcher/StudioLauncher.exe';
  RealExe := GameRoot + '/MyProject/Binaries/Win64/MyProject-Win64-Shipping.exe';
  WritePEStub(LauncherExe, $8664, True);
  WritePEImportTestStub(RealExe, True, 'd3d12.dll');

  AssertEquals('Unreal Engine game launched from Launcher/ resolves to Binaries/Win64 shipping exe',
    RealExe, ResolveRealGameExecutable(LauncherExe, ''));

  // 3. CEF/Qt root wrapper vs 3D PE executable with native upscaler DLL
  GameRoot := BaseDir + '/CefRootWrapperGame';
  ForceDirectories(GameRoot + '/bin/x64');
  LauncherExe := GameRoot + '/PlayGame.exe';
  RealExe := GameRoot + '/bin/x64/ActualGame.exe';
  WritePEStub(LauncherExe, $8664, True);
  AssignFile(F, GameRoot + '/libcef.dll'); Rewrite(F); WriteLn(F, 'CEF'); CloseFile(F);
  WritePEImportTestStub(RealExe, True, 'd3d12.dll');
  AssignFile(F, GameRoot + '/bin/x64/nvngx_dlss.dll'); Rewrite(F); WriteLn(F, 'DLSS'); CloseFile(F);

  AssertTrue('CEF root wrapper receives negative score',
    ScoreGameExecutableCandidate(LauncherExe, GameRoot) < 0);
  AssertTrue('3D PE executable with nvngx_dlss.dll receives high positive score',
    ScoreGameExecutableCandidate(RealExe, GameRoot) >= 150);
  AssertEquals('CEF root wrapper resolves to bin/x64/ActualGame.exe',
    RealExe, ResolveRealGameExecutable(LauncherExe, GameRoot));

  // 4. Direct game executable without launcher remains unchanged
  GameRoot := BaseDir + '/DirectGame';
  ForceDirectories(GameRoot);
  RealExe := GameRoot + '/DirectGame.exe';
  WritePEImportTestStub(RealExe, True, 'd3d11.dll');
  AssertEquals('Direct game executable is preserved unchanged',
    RealExe, ResolveRealGameExecutable(RealExe, GameRoot));
end;

procedure TBgmodSupervisorTests.TestBgmodReShadeD3D9ExportsD3DCompilerOverride;
var
  Proc: TProcess;
  CfgDir, GameDir, MockExe, LogFile, Content, BinDir: string;
  F: TextFile;
  Lines: TStringList;
begin
  EnsureBgmodBinary;
  BinDir := IsolatedHome + '/.local/share/goverlay/reshade/bin';
  ForceDirectories(BinDir);
  try
    AssignFile(F, BinDir + '/ReShade32.dll'); Rewrite(F);
    WriteLn(F, 'MOCK_RESHADE_32');
    CloseFile(F);
    AssignFile(F, BinDir + '/ReShade64.dll'); Rewrite(F);
    WriteLn(F, 'MOCK_RESHADE_64');
    CloseFile(F);

    // Case 1: d3d9.dll proxy must append d3dcompiler_47=n,b
    GameDir := IsolatedHome + '/games/ReShadeD3D9Override';
    CfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/ReShadeD3D9Override';
    ForceDirectories(GameDir);
    ForceDirectories(CfgDir);

    Proc := TProcess.Create(nil);
    try
      Proc.Executable := FindTestHelperExecutable('cp');
      Proc.Parameters.Add('-f');
      Proc.Parameters.Add(GetBgmodBinaryPath);
      Proc.Parameters.Add(CfgDir + '/bgmod');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
      fpChmod(PChar(CfgDir + '/bgmod'), &755);
    finally
      Proc.Free;
    end;

    MockExe := GameDir + '/Game.exe';
    WritePEStub(MockExe, $014C, True);

    AssignFile(F, CfgDir + '/bgmod.conf'); Rewrite(F);
    WriteLn(F, '[Config]');
    WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
    WriteLn(F, 'GOVERLAY_RESHADE=1');
    WriteLn(F, 'GOVERLAY_OPTISCALER=0');
    WriteLn(F, 'RESHADE_DLL=d3d9.dll');
    CloseFile(F);

    Proc := TProcess.Create(nil);
    try
      Proc.Executable := CfgDir + '/bgmod';
      Proc.Parameters.Add(MockExe);
      Proc.Options := [poWaitOnExit];
      Proc.CurrentDirectory := GameDir;
      Proc.Execute;
    finally
      Proc.Free;
    end;

    LogFile := IsolatedHome + '/.local/share/goverlay/logs/ReShadeD3D9Override/bgmod.log';
    AssertTrue('bgmod.log should exist', FileExists(LogFile));
    Lines := TStringList.Create;
    try
      Lines.LoadFromFile(LogFile);
      Content := Lines.Text;
      AssertTrue('d3d9.dll ReShade must export d3dcompiler_47=n,b',
        Pos('Export WINEDLLOVERRIDES=d3d9=n,b;d3dcompiler_47=n,b', Content) > 0);
    finally
      Lines.Free;
    end;
  finally
    if FileExists(BinDir + '/ReShade32.dll') then DeleteFile(BinDir + '/ReShade32.dll');
    if FileExists(BinDir + '/ReShade64.dll') then DeleteFile(BinDir + '/ReShade64.dll');
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodDisabledOptiscalerWithLeftoversPreservesGenuineDlls;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockExe, CacheDir: string;
  F: TextFile;
  Lines: TStringList;
begin
  EnsureBgmodBinary;
  MockGameDir := IsolatedHome + '/games/Cyberpunk2077/bin/x64';
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Cyberpunk 2077';
  ForceDirectories(MockGameDir);
  ForceDirectories(TestGameCfgDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Mock game executable (script with .exe name that runs true)
  MockExe := MockGameDir + '/Cyberpunk2077.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockExe), &755);

  // Genuine game files that must survive cleanup
  AssignFile(F, MockGameDir + '/nvngx_dlss.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_DLSS'); CloseFile(F);
  AssignFile(F, MockGameDir + '/sl.dlss.dll'); Rewrite(F); WriteLn(F, 'ORIGINAL_NATIVE_STREAMLINE'); CloseFile(F);
  AssignFile(F, MockGameDir + '/version.dll'); Rewrite(F); WriteLn(F, 'CET_CYBER_ENGINE_TWEAKS_THIRD_PARTY'); CloseFile(F);

  // Seed the standard central cache with GOverlay payloads
  CacheDir := IsolatedHome + '/.local/share/goverlay/optiscaler-stable';
  ForceDirectories(CacheDir);
  AssignFile(F, CacheDir + '/nvngx_dlss.dll'); Rewrite(F); WriteLn(F, 'DIFFERENT_GOverlay_OPTISCALER_DLSS_PAYLOAD_SIZE'); CloseFile(F);
  AssignFile(F, CacheDir + '/fakenvapi.dll'); Rewrite(F); WriteLn(F, 'MOCK_FAKENVAPI_PAYLOAD'); CloseFile(F);

  // Actual leftovers from a previous OptiScaler install
  AssignFile(F, MockGameDir + '/OptiScaler.ini'); Rewrite(F); WriteLn(F, '[Config]'); CloseFile(F);
  AssignFile(F, MockGameDir + '/fakenvapi.dll'); Rewrite(F); WriteLn(F, 'MOCK_FAKENVAPI_PAYLOAD'); CloseFile(F);
  AssignFile(F, MockGameDir + '/goverlay.vars'); Rewrite(F); WriteLn(F, 'optiscalerversion=0.7.2'); CloseFile(F);

  // Configure bgmod.conf with OptiScaler disabled
  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=0');
  WriteLn(F, 'DLL=version.dll');
  CloseFile(F);

  // Run bgmod launching MockExe
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly with 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // GOverlay leftovers must be removed, genuine game DLLs must be preserved
  AssertFalse('OptiScaler.ini must be deleted', FileExists(MockGameDir + '/OptiScaler.ini'));
  AssertFalse('fakenvapi.dll must be deleted', FileExists(MockGameDir + '/fakenvapi.dll'));
  AssertTrue('nvngx_dlss.dll must not be deleted', FileExists(MockGameDir + '/nvngx_dlss.dll'));
  AssertTrue('sl.dlss.dll must not be deleted', FileExists(MockGameDir + '/sl.dlss.dll'));
  AssertTrue('version.dll must not be deleted', FileExists(MockGameDir + '/version.dll'));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(MockGameDir + '/nvngx_dlss.dll');
    AssertEquals('nvngx_dlss.dll content must be untouched native', 'ORIGINAL_NATIVE_DLSS', Trim(Lines.Text));
    Lines.LoadFromFile(MockGameDir + '/version.dll');
    AssertEquals('version.dll content must be untouched CET', 'CET_CYBER_ENGINE_TWEAKS_THIRD_PARTY', Trim(Lines.Text));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodDisabledOptiscalerPurgesHelixSRLeftovers;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockExe: string;
  F: TextFile;
begin
  EnsureBgmodBinary;
  MockGameDir := IsolatedHome + '/games/HelixSRGame/bin';
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/HelixSRGame';
  ForceDirectories(MockGameDir);
  ForceDirectories(TestGameCfgDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Mock game executable (script with .exe name that runs true)
  MockExe := MockGameDir + '/Game.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockExe), &755);

  // Seed HelixSR leftovers
  ForceDirectories(MockGameDir + '/HelixSR');
  AssignFile(F, MockGameDir + '/HelixSR/helixsr.dll'); Rewrite(F); WriteLn(F, 'HELIXSR_MOCK_DLL'); CloseFile(F);
  ForceDirectories(MockGameDir + '/helixsr-fg');
  AssignFile(F, MockGameDir + '/helixsr-fg/dummy.txt'); Rewrite(F); WriteLn(F, 'FG_DUMMY'); CloseFile(F);
  AssignFile(F, MockGameDir + '/helixsr.ini'); Rewrite(F); WriteLn(F, '[Upscaling]'); CloseFile(F);

  // Configure bgmod.conf with OptiScaler disabled (GOVERLAY_OPTISCALER=0)
  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=0');
  WriteLn(F, 'DLL=dxgi.dll');
  CloseFile(F);

  // Run bgmod launching MockExe
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly with 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // HelixSR leftovers must be purged
  AssertFalse('HelixSR directory must be deleted', DirectoryExists(MockGameDir + '/HelixSR'));
  AssertFalse('helixsr-fg directory must be deleted', DirectoryExists(MockGameDir + '/helixsr-fg'));
  AssertFalse('helixsr.ini must be deleted', FileExists(MockGameDir + '/helixsr.ini'));
end;

procedure TBgmodSupervisorTests.TestBgmodFlatpakPathsAndLayerExport;
var
  Proc: TProcess;
  FlatpakBase, TestGameDir, MockGameDir, MockRunner, MockExe, OutFile: string;
  FlatpakVulkanDir, FlatpakReshadeDir: string;
  F: TextFile;
  Lines: TStringList;
  Content: string;
  EnvIndex: Integer;
begin
  EnsureBgmodBinary;
  FlatpakBase := IsolatedHome + '/.var/app/io.github.benjamimgois.goverlay';
  TestGameDir := FlatpakBase + '/data/goverlay/gameconfig/FlatpakTestGame';
  ForceDirectories(TestGameDir);

  MockGameDir := IsolatedHome + '/mock_flatpak_game';
  ForceDirectories(MockGameDir);

  // Set up mock Flatpak Vulkan implicit layers
  FlatpakVulkanDir := FlatpakBase + '/data/vulkan/implicit_layer.d';
  ForceDirectories(FlatpakVulkanDir);
  AssignFile(F, FlatpakVulkanDir + '/vksumi.json');
  Rewrite(F);
  WriteLn(F, '{"file_format_version": "1.0.0"}');
  CloseFile(F);

  // Set up mock Flatpak ReShade binaries and shaders
  FlatpakReshadeDir := FlatpakBase + '/data/goverlay/reshade';
  ForceDirectories(FlatpakReshadeDir + '/bin');
  ForceDirectories(FlatpakReshadeDir + '/shaders/Shaders');
  ForceDirectories(FlatpakReshadeDir + '/shaders/Textures');
  AssignFile(F, FlatpakReshadeDir + '/bin/ReShade64.dll');
  Rewrite(F);
  WriteLn(F, 'mock flatpak reshade64 dll');
  CloseFile(F);
  AssignFile(F, FlatpakReshadeDir + '/shaders/Shaders/mock_shader.fx');
  Rewrite(F);
  WriteLn(F, '// mock fx');
  CloseFile(F);

  // Copy bgmod binary to Flatpak gameconfig
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockExe := MockGameDir + '/game.exe';
  AssignFile(F, MockExe);
  Rewrite(F);
  WriteLn(F, 'mock windows pe binary');
  CloseFile(F);

  OutFile := MockGameDir + '/env_output.txt';
  if FileExists(OutFile) then DeleteFile(OutFile);

  MockRunner := TestGameDir + '/mock_runner.sh';
  AssignFile(F, MockRunner);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'env > "' + OutFile + '"');
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRunner), &755);

  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'RESHADE_DLL=dxgi.dll');
  WriteLn(F, 'TARGET_EXE=game.exe');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(MockRunner);
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := TestGameDir;
    for EnvIndex := 1 to GetEnvironmentVariableCount do
      Proc.Environment.Add(GetEnvironmentString(EnvIndex));
    Proc.Environment.Add('STEAM_COMPAT_INSTALL_PATH=' + MockGameDir);
    Proc.Execute;
    AssertEquals('bgmod in Flatpak path should return exit status 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 1. Verify ReShade DLL deployed from Flatpak data dir
  AssertTrue('dxgi.dll should be deployed from Flatpak reshade bin', FileExists(MockGameDir + '/dxgi.dll'));

  // 2. Verify ReShade.ini generated with Flatpak Wine paths
  AssertTrue('ReShade.ini should be generated in game dir', FileExists(MockGameDir + '/ReShade.ini'));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(MockGameDir + '/ReShade.ini');
    Content := Lines.Text;
    AssertTrue('EffectSearchPaths should point to Flatpak reshade shaders',
      Pos('io.github.benjamimgois.goverlay\data\goverlay\reshade\shaders\Shaders', Content) > 0);
  finally
    Lines.Free;
  end;

  // 3. Verify VK_ADD_IMPLICIT_LAYER_PATH exported in runner environment with Flatpak vulkan implicit layers
  AssertTrue('env_output.txt should be created', FileExists(OutFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutFile);
    Content := Lines.Text;
    AssertTrue('VK_ADD_IMPLICIT_LAYER_PATH should include Flatpak implicit layer path',
      Pos('VK_ADD_IMPLICIT_LAYER_PATH=' + FlatpakVulkanDir, Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodFlatpakLaunchSplashViaFlatpakRun;
var
  Proc: TProcess;
  FlatpakBase, TestGameDir, MockBinDir, MockFlatpak, OutArgsFile, OutEnvFile: string;
  F: TextFile;
  Lines: TStringList;
  Content, OldPath, EnvLine: string;
  EnvIndex, WaitCount: Integer;
begin
  EnsureBgmodBinary;
  FlatpakBase := IsolatedHome + '/.var/app/io.github.benjamimgois.goverlay';
  TestGameDir := FlatpakBase + '/data/goverlay/gameconfig/FlatpakSplashGame';
  ForceDirectories(TestGameDir);

  MockBinDir := IsolatedHome + '/mock_flatpak_bin';
  ForceDirectories(MockBinDir);
  OutArgsFile := TestGameDir + '/flatpak_splash_args.txt';
  OutEnvFile := TestGameDir + '/flatpak_splash_env.txt';
  if FileExists(OutArgsFile) then DeleteFile(OutArgsFile);
  if FileExists(OutEnvFile) then DeleteFile(OutEnvFile);

  MockFlatpak := MockBinDir + '/flatpak';
  AssignFile(F, MockFlatpak);
  Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'echo "$*" > "' + OutArgsFile + '"');
  WriteLn(F, 'env > "' + OutEnvFile + '"');
  CloseFile(F);
  fpChmod(PChar(MockFlatpak), &755);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  AssignFile(F, TestGameDir + '/bgmod.conf');
  Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=1');
  WriteLn(F, 'GOVERLAY_MANGOHUD=1');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameDir + '/bgmod';
    Proc.Parameters.Add(FindTestHelperExecutable('true'));
    Proc.Options := [poWaitOnExit];
    OldPath := GetEnvironmentVariable('PATH');
    for EnvIndex := 1 to GetEnvironmentVariableCount do
    begin
      EnvLine := GetEnvironmentString(EnvIndex);
      if (Pos('PATH=', EnvLine) <> 1) and (Pos('LD_LIBRARY_PATH=', EnvLine) <> 1) then
        Proc.Environment.Add(EnvLine);
    end;
    Proc.Environment.Add('PATH=' + MockBinDir + ':' + OldPath);
    Proc.Environment.Add('LD_LIBRARY_PATH=/fake/steam/runtime/lib');
    if (GetEnvironmentVariable('DISPLAY') = '') and (GetEnvironmentVariable('WAYLAND_DISPLAY') = '') then
      Proc.Environment.Add('DISPLAY=:99');
    Proc.Execute;
    AssertEquals('bgmod should return 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  WaitCount := 0;
  while (not FileExists(OutArgsFile)) and (WaitCount < 30) do
  begin
    Sleep(100);
    Inc(WaitCount);
  end;

  AssertTrue('Mock flatpak splash args file should exist', FileExists(OutArgsFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutArgsFile);
    Content := Lines.Text;
    AssertTrue('Should invoke flatpak run --command=sh io.github.benjamimgois.goverlay',
      Pos('run --command=sh io.github.benjamimgois.goverlay', Content) > 0);
    AssertTrue('Should search /app/bin, /app/libexec, and fallback path for bgmod-splash',
      Pos('/app/libexec/bgmod-splash', Content) > 0);
    AssertTrue('Should pass --game=FlatpakSplashGame',
      Pos('--game=FlatpakSplashGame', Content) > 0);
    AssertTrue('Should pass --item=MangoHud',
      Pos('--item=MangoHud', Content) > 0);
  finally
    Lines.Free;
  end;

  AssertTrue('Mock flatpak splash env file should exist', FileExists(OutEnvFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(OutEnvFile);
    Content := Lines.Text;
    AssertFalse('LD_LIBRARY_PATH must be stripped when spawning Flatpak splash',
      Pos('LD_LIBRARY_PATH=/fake/steam/runtime/lib', Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodLauncherRuleSpacelessGameName;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockPrelauncher, MockRealExe, LogFile: string;
  F: TextFile;
  Lines: TStringList;
begin
  EnsureBgmodBinary;
  // Heroic/GOG uses "Cyberpunk2077" without a space
  MockGameDir := IsolatedHome + '/games/Cyberpunk2077';
  ForceDirectories(MockGameDir + '/bin/x64');
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Cyberpunk 2077';
  ForceDirectories(TestGameCfgDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockPrelauncher := MockGameDir + '/REDprelauncher.exe';
  AssignFile(F, MockPrelauncher); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockPrelauncher), &755);

  MockRealExe := MockGameDir + '/bin/x64/Cyberpunk2077.exe';
  AssignFile(F, MockRealExe); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRealExe), &755);

  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'CENTRAL_LOGS=1');
  CloseFile(F);

  // Run bgmod passing the launcher executable
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockPrelauncher);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // Check central bgmod.log to verify GameDir was resolved to bin/x64/
  LogFile := IsolatedHome + '/.local/share/goverlay/logs/Cyberpunk 2077/bgmod.log';
  AssertTrue('bgmod.log should exist', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Resolved GameDir should point to bin/x64/', Pos('bin/x64', Lines.Text) > 0);
    AssertTrue('Resolved TargetExeName should be Cyberpunk2077.exe', Pos('exe: Cyberpunk2077.exe', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodLauncherRuleCaseInsensitive;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockPrelauncher, MockRealExe, LogFile: string;
  F: TextFile;
  Lines: TStringList;
begin
  EnsureBgmodBinary;
  MockGameDir := IsolatedHome + '/games/Cyberpunk2077CaseInsensitive';
  ForceDirectories(MockGameDir + '/bin/x64');
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Cyberpunk 2077 CaseInsensitive';
  ForceDirectories(TestGameCfgDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  // Use a lowercase launcher name to exercise case-insensitive rule matching
  MockPrelauncher := MockGameDir + '/redprelauncher.exe';
  AssignFile(F, MockPrelauncher); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockPrelauncher), &755);

  MockRealExe := MockGameDir + '/bin/x64/Cyberpunk2077.exe';
  AssignFile(F, MockRealExe); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRealExe), &755);

  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'CENTRAL_LOGS=1');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockPrelauncher);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  LogFile := IsolatedHome + '/.local/share/goverlay/logs/Cyberpunk 2077 CaseInsensitive/bgmod.log';
  AssertTrue('bgmod.log should exist', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Resolved GameDir should point to bin/x64/', Pos('bin/x64', Lines.Text) > 0);
    AssertTrue('Lowercase launcher should resolve to Cyberpunk2077.exe',
      Pos('exe: Cyberpunk2077.exe', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodSmartLauncherResolutionAndCustomRulesMerge;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockLauncher, MockRealExe, LogFile, UninstallerSrc: string;
  F: TextFile;
  Lines: TStringList;
  Ini: TIniFile;
begin
  EnsureBgmodBinary;

  // Part 1: Cities: Skylines II unlisted launcher resolved heuristically by bgmod & bgmod-uninstaller
  MockGameDir := IsolatedHome + '/games/Cities Skylines II';
  ForceDirectories(MockGameDir + '/Launcher');
  ForceDirectories(MockGameDir + '/Cities2_Data');
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/Cities Skylines II';
  ForceDirectories(TestGameCfgDir);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockLauncher := MockGameDir + '/Launcher/dowser.exe';
  AssignFile(F, MockLauncher); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockLauncher), &755);

  MockRealExe := MockGameDir + '/Cities2.exe';
  WritePEImportTestStub(MockRealExe, True, 'd3d11.dll');
  AssignFile(F, MockGameDir + '/UnityPlayer.dll'); Rewrite(F);
  WriteLn(F, 'UNITY_PLAYER');
  CloseFile(F);

  // Also include a custom [Launchers] entry in bgmod.conf to verify custom + default + heuristic coexistence
  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'CENTRAL_LOGS=1');
  WriteLn(F, '[Launchers]');
  WriteLn(F, 'SomeOtherGame = CustomLauncher.exe|bin/OtherGame.exe');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockLauncher);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly for Cities Skylines II launcher', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  LogFile := IsolatedHome + '/.local/share/goverlay/logs/Cities Skylines II/bgmod.log';
  AssertTrue('Cities Skylines II bgmod.log should exist', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Heuristic redirection logged',
      Pos('Heuristic executable detector redirected launcher', Lines.Text) > 0);
    AssertTrue('Resolved TargetExeName is Cities2.exe',
      Pos('exe: Cities2.exe', Lines.Text) > 0);
    AssertFalse('GameDir must not remain in Launcher subfolder',
      Pos('Game directory: ' + MockGameDir + '/Launcher', Lines.Text) > 0);
  finally
    Lines.Free;
  end;

  Ini := TIniFile.Create(TestGameCfgDir + '/bgmod.conf');
  try
    AssertEquals('Cached TARGET_EXE in bgmod.conf is Cities2.exe',
      'Cities2.exe', Ini.ReadString('Config', 'TARGET_EXE', ''));
  finally
    Ini.Free;
  end;

  // Verify bgmod-uninstaller also resolves Launcher/dowser.exe to MockGameDir (not Launcher/)
  UninstallerSrc := ExpandFileName(ExtractFilePath(GetBgmodBinaryPath) + 'bgmod-uninstaller');
  if FileExists(UninstallerSrc) then
  begin
    AssignFile(F, MockGameDir + '/goverlay.vars'); Rewrite(F);
    WriteLn(F, 'GOVERLAY_OPTISCALER=1');
    CloseFile(F);

    Proc := TProcess.Create(nil);
    try
      Proc.Executable := UninstallerSrc;
      Proc.Parameters.Add(MockLauncher);
      Proc.Options := [poWaitOnExit];
      Proc.CurrentDirectory := MockGameDir;
      Proc.Execute;
      AssertEquals('bgmod-uninstaller should exit cleanly', 0, Proc.ExitStatus);
    finally
      Proc.Free;
    end;
    AssertFalse('bgmod-uninstaller cleaned goverlay.vars from real game root',
      FileExists(MockGameDir + '/goverlay.vars'));
  end;

  // Part 2: Verify built-in [Launchers] rule still works when bgmod.conf has a custom [Launchers] entry
  MockGameDir := IsolatedHome + '/games/Cyberpunk2077MergedRules';
  ForceDirectories(MockGameDir + '/bin/x64');
  MockLauncher := MockGameDir + '/REDprelauncher.exe';
  AssignFile(F, MockLauncher); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockLauncher), &755);

  MockRealExe := MockGameDir + '/bin/x64/Cyberpunk2077.exe';
  AssignFile(F, MockRealExe); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockRealExe), &755);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockLauncher);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly for built-in rule with custom [Launchers] present', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Built-in Cyberpunk2077 rule still matched alongside custom [Launchers] rule',
      Pos('exe: Cyberpunk2077.exe', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodSensitiveArgRedaction;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockExe, LogFile, Content: string;
  SecretPassword, SecretUser, SecretToken: string;
  F: TextFile;
  Lines: TStringList;
  i: Integer;
  LoginTokenRedacted: Boolean;
begin
  EnsureBgmodBinary;
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/RedactionTestGame';
  MockGameDir := IsolatedHome + '/.local/share/goverlay/mock_game_redaction';
  ForceDirectories(TestGameCfgDir);
  ForceDirectories(MockGameDir);

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockExe := MockGameDir + '/game.exe';
  AssignFile(F, MockExe); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockExe), &755);

  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  CloseFile(F);

  SecretPassword := 'PasswordSecretValue123';
  SecretUser := 'EpicUserSecretValue456';
  SecretToken := 'AuthLoginTokenSecret789';

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Parameters.Add('-AUTH_PASSWORD=' + SecretPassword);
    Proc.Parameters.Add('-epicuserid=' + SecretUser);
    Proc.Parameters.Add('-AUTH_LOGIN');
    Proc.Parameters.Add(SecretToken);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  LogFile := IsolatedHome + '/.local/share/goverlay/logs/RedactionTestGame/bgmod.log';
  AssertTrue('bgmod.log should exist', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    Content := Lines.Text;

    AssertTrue('AUTH_PASSWORD value must be redacted',
      Pos('-AUTH_PASSWORD=[REDACTED]', Content) > 0);
    AssertTrue('epicuserid value must be redacted',
      Pos('-epicuserid=[REDACTED]', Content) > 0);
    LoginTokenRedacted := False;
    for i := 0 to Lines.Count - 2 do
      if (Pos('-AUTH_LOGIN', Lines[i]) > 0) and
         (Pos('[REDACTED]', Lines[i + 1]) > 0) then
        LoginTokenRedacted := True;
    AssertTrue('AUTH_LOGIN token must be redacted as the next log value', LoginTokenRedacted);
    AssertFalse('Password secret must not leak into bgmod.log',
      Pos(SecretPassword, Content) > 0);
    AssertFalse('Epic user id secret must not leak into bgmod.log',
      Pos(SecretUser, Content) > 0);
    AssertFalse('Auth login token secret must not leak into bgmod.log',
      Pos(SecretToken, Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSupervisorTests.TestBgmodWineDllOverridesSemicolonDelimiter;
var
  Proc: TProcess;
  TestGameCfgDir, MockGameDir, MockExe, LogFile, Content, EnvStr: string;
  F: TextFile;
  Lines: TStringList;
  EnvIndex: Integer;
begin
  EnsureBgmodBinary;
  TestGameCfgDir := IsolatedHome + '/.local/share/goverlay/gameconfig/WineDllOverridesTestGame';
  MockGameDir := IsolatedHome + '/.local/share/goverlay/mock_game_winedlloverrides';
  ForceDirectories(TestGameCfgDir);
  ForceDirectories(MockGameDir);
  ForceDirectories(IsolatedHome + '/.local/share/goverlay/optiscaler-stable');
  ForceDirectories(IsolatedHome + '/.local/share/goverlay/reshade/bin');

  // Copy bgmod binary to TestGameCfgDir
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := FindTestHelperExecutable('cp');
    Proc.Parameters.Add('-f');
    Proc.Parameters.Add(GetBgmodBinaryPath);
    Proc.Parameters.Add(TestGameCfgDir + '/bgmod');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    fpChmod(PChar(TestGameCfgDir + '/bgmod'), &755);
  finally
    Proc.Free;
  end;

  MockExe := MockGameDir + '/game.exe';
  AssignFile(F, MockExe); Rewrite(F);
  WriteLn(F, '#!' + FindTestHelperExecutable('sh'));
  WriteLn(F, 'exit 0');
  CloseFile(F);
  fpChmod(PChar(MockExe), &755);

  // Seed OptiScaler and ReShade payloads so both proxies are deployed
  AssignFile(F, IsolatedHome + '/.local/share/goverlay/optiscaler-stable/OptiScaler.dll');
  Rewrite(F);
  WriteLn(F, 'MOCK_OPTISCALER_DLL');
  CloseFile(F);

  AssignFile(F, IsolatedHome + '/.local/share/goverlay/reshade/bin/ReShade64.dll');
  Rewrite(F);
  WriteLn(F, 'MOCK_RESHADE_64_PAYLOAD');
  CloseFile(F);

  AssignFile(F, TestGameCfgDir + '/bgmod.conf'); Rewrite(F);
  WriteLn(F, '[Config]');
  WriteLn(F, 'SHOW_LAUNCH_SPLASH=0');
  WriteLn(F, 'GOVERLAY_OPTISCALER=1');
  WriteLn(F, 'GOVERLAY_RESHADE=1');
  WriteLn(F, 'DLL=version.dll');
  WriteLn(F, 'RESHADE_DLL=dxgi.dll');
  CloseFile(F);

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := TestGameCfgDir + '/bgmod';
    Proc.Parameters.Add(MockExe);
    Proc.Options := [poWaitOnExit];
    Proc.CurrentDirectory := MockGameDir;
    // Preserve the environment but drop any inherited override list so the
    // expected value starts empty.
    for EnvIndex := 1 to GetEnvironmentVariableCount do
    begin
      EnvStr := GetEnvironmentString(EnvIndex);
      if Pos('WINEDLLOVERRIDES=', UpperCase(EnvStr)) <> 1 then
        Proc.Environment.Add(EnvStr);
    end;
    Proc.Execute;
    AssertEquals('bgmod should exit cleanly', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  LogFile := IsolatedHome + '/.local/share/goverlay/logs/WineDllOverridesTestGame/bgmod.log';
  AssertTrue('bgmod.log should exist', FileExists(LogFile));
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    Content := Lines.Text;
    AssertTrue('WINEDLLOVERRIDES should join OptiScaler and ReShade with a semicolon',
      Pos('Export WINEDLLOVERRIDES=version=n,b;dxgi=n,b', Content) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TReShadeLogicTests.TestUnixPathToWinePath;
begin
  AssertEquals('Empty path', '', UnixPathToWinePath(''));
  AssertEquals('Root path', 'Z:\', UnixPathToWinePath('/'));
  AssertEquals('Standard path', 'Z:\home\user\.local\share\goverlay\reshade\Shaders',
    UnixPathToWinePath('/home/user/.local/share/goverlay/reshade/Shaders'));
  AssertEquals('Trailing slash preserved as backslash', 'Z:\opt\games\',
    UnixPathToWinePath('/opt/games/'));
end;

procedure TReShadeLogicTests.TestGetGOverlayBaseDataPath;
var
  FlatpakSample, NativeSample, Resolved: string;
begin
  FlatpakSample := '/var/home/bazzite/.var/app/io.github.benjamimgois.goverlay/data/goverlay/gameconfig/Control Ultimate Edition/bgmod';
  Resolved := GetGOverlayBaseDataPath(FlatpakSample);
  AssertEquals('Flatpak base data path correctly extracted',
    '/var/home/bazzite/.var/app/io.github.benjamimgois.goverlay/data/goverlay/', Resolved);

  NativeSample := '/home/benjamim/.local/share/goverlay/gameconfig/Control/bgmod';
  Resolved := GetGOverlayBaseDataPath(NativeSample);
  AssertTrue('Native base data path ends with goverlay/',
    Pos('goverlay/', Resolved) > 0);
end;

procedure TReShadeLogicTests.TestReShadeDirectoryLayout;
var
  BaseDir, BinDir, ShadersDir, PresetsDir: string;
begin
  BaseDir := GetReShadeBasePath;
  BinDir := GetReShadeBinPath;
  ShadersDir := GetReShadeShadersPath;
  PresetsDir := GetReShadePresetsPath;

  AssertTrue('BaseDir contains reshade', Pos('reshade', BaseDir) > 0);
  AssertTrue('BinDir is under BaseDir', Pos(BaseDir, BinDir) = 1);
  AssertTrue('ShadersDir is under BaseDir', Pos(BaseDir, ShadersDir) = 1);
  AssertTrue('PresetsDir is under BaseDir', Pos(BaseDir, PresetsDir) = 1);

  EnsureReShadeDirectories;
  AssertTrue('BaseDir exists after ensure', DirectoryExists(BaseDir));
  AssertTrue('BinDir exists after ensure', DirectoryExists(BinDir));
  AssertTrue('ShadersDir exists after ensure', DirectoryExists(ShadersDir));
  AssertTrue('PresetsDir exists after ensure', DirectoryExists(PresetsDir));
end;

procedure TReShadeLogicTests.TestReShadeIniPathFormatting;
var
  ShadersDir, WineShaders, EffectPaths, TexturePaths, FlatpakShaders, DualSearchPaths: string;
begin
  ShadersDir := '/home/user/.local/share/goverlay/reshade/Shaders';
  WineShaders := UnixPathToWinePath(ShadersDir);
  EffectPaths := '.\,' + WineShaders + '\**';
  TexturePaths := '.\,' + WineShaders + '\**';

  AssertEquals('EffectSearchPaths format', '.\,Z:\home\user\.local\share\goverlay\reshade\Shaders\**', EffectPaths);
  AssertEquals('TextureSearchPaths format', '.\,Z:\home\user\.local\share\goverlay\reshade\Shaders\**', TexturePaths);

  // Test dual-path search path builder with Flatpak /var/home path
  FlatpakShaders := '/var/home/bazzite/.var/app/io.github.benjamimgois.goverlay/data/goverlay/reshade/shaders/Shaders';
  DualSearchPaths := BuildReShadeSearchPath(FlatpakShaders);

  AssertTrue('Dual path includes primary Z:\var\home path',
    Pos('Z:\var\home\bazzite\.var\app\io.github.benjamimgois.goverlay\data\goverlay\reshade\shaders\Shaders', DualSearchPaths) > 0);
  AssertTrue('Dual path includes primary recursive path',
    Pos('Z:\var\home\bazzite\.var\app\io.github.benjamimgois.goverlay\data\goverlay\reshade\shaders\Shaders\**', DualSearchPaths) > 0);
  AssertTrue('Dual path includes alternate Z:\home path',
    Pos('Z:\home\bazzite\.var\app\io.github.benjamimgois.goverlay\data\goverlay\reshade\shaders\Shaders', DualSearchPaths) > 0);
  AssertTrue('Dual path includes alternate recursive path',
    Pos('Z:\home\bazzite\.var\app\io.github.benjamimgois.goverlay\data\goverlay\reshade\shaders\Shaders\**', DualSearchPaths) > 0);
end;

procedure TReShadeLogicTests.TestReShadeInstalledVersionFallbackAndMetadata;
var
  BaseDir, BinDir, VerFile: string;
  SL: TStringList;
begin
  BaseDir := GetReShadeBasePath;
  BinDir := GetReShadeBinPath;
  VerFile := IncludeTrailingPathDelimiter(BaseDir) + 'version.txt';

  // 1. Initially nothing exists -> empty string
  if FileExists(VerFile) then DeleteFile(VerFile);
  if FileExists(BinDir + '/ReShade64.dll') then DeleteFile(BinDir + '/ReShade64.dll');
  AssertEquals('Not installed returns empty', '', GetReShadeInstalledVersion);

  // 2. DLL exists but no version.txt -> fallback to 6.4.0
  EnsureReShadeDirectories;
  SL := TStringList.Create;
  try
    SL.SaveToFile(BinDir + '/ReShade64.dll');
  finally
    SL.Free;
  end;
  AssertEquals('Fallback to 6.4.0 when DLL present without version.txt', '6.4.0', GetReShadeInstalledVersion);

  // 3. version.txt exists -> returns version.txt content
  SL := TStringList.Create;
  try
    SL.Add('6.8.0');
    SL.SaveToFile(VerFile);
  finally
    SL.Free;
  end;
  AssertEquals('Returns version from version.txt', '6.8.0', GetReShadeInstalledVersion);

  // 4. version.txt with leading v -> stripped
  SL := TStringList.Create;
  try
    SL.Add('v6.8.0');
    SL.SaveToFile(VerFile);
  finally
    SL.Free;
  end;
  AssertEquals('Leading v stripped from version.txt', '6.8.0', GetReShadeInstalledVersion);

  // Cleanup
  if FileExists(VerFile) then DeleteFile(VerFile);
  if FileExists(BinDir + '/ReShade64.dll') then DeleteFile(BinDir + '/ReShade64.dll');
end;

procedure TReShadeLogicTests.TestParseReShadeMeHtml;
var
  Html, Url, Ver: string;
begin
  // Valid link in HTML
  Html := '<p><a href="/downloads/ReShade_Setup_6.8.0_Addon.exe" class="button">Download ReShade 6.8.0</a></p>';
  Ver := ParseReShadeMeHtml(Html, Url);
  AssertEquals('Parsed version', '6.8.0', Ver);
  AssertEquals('Generated Addon URL', 'https://reshade.me/downloads/ReShade_Setup_6.8.0_Addon.exe', Url);

  // No match
  Html := '<html><body>No downloads here</body></html>';
  Ver := ParseReShadeMeHtml(Html, Url);
  AssertEquals('Empty on no match', '', Ver);
  AssertEquals('Empty URL on no match', '', Url);
end;

procedure TReShadeLogicTests.TestReShadeCoreHeadersCheck;
var
  ShadersDir: string;
  F: TextFile;
begin
  ShadersDir := IsolatedHome + '/.local/share/goverlay/reshade/shaders';
  ForceDirectories(ShadersDir + '/Shaders/SweetFX');

  // Shaders/ exists from an optional pack, but ReShade.fxh and ReShadeUI.fxh are missing
  AssertFalse('AreReShadeCoreHeadersPresent must be False when headers are missing',
    AreReShadeCoreHeadersPresent(ShadersDir));

  // Only ReShade.fxh present -> still False
  AssignFile(F, ShadersDir + '/Shaders/ReShade.fxh');
  Rewrite(F); WriteLn(F, '// header'); CloseFile(F);
  AssertFalse('AreReShadeCoreHeadersPresent must be False when ReShadeUI.fxh is missing',
    AreReShadeCoreHeadersPresent(ShadersDir));

  // Both ReShade.fxh and ReShadeUI.fxh present -> True
  AssignFile(F, ShadersDir + '/Shaders/ReShadeUI.fxh');
  Rewrite(F); WriteLn(F, '// ui header'); CloseFile(F);
  AssertTrue('AreReShadeCoreHeadersPresent must be True when both headers exist',
    AreReShadeCoreHeadersPresent(ShadersDir));
end;

procedure TSyncGameWrapperBinariesTests.TestSyncOutdatedWrappersPreservingConfigs;
var
  BaseDir, BgmodTemplateDir, GameDir: string;
  F: TextFile;
  Lines: TStringList;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay';
  BgmodTemplateDir := BaseDir + '/bgmod';
  GameDir := BaseDir + '/gameconfig/DyingLight2';

  ForceDirectories(BgmodTemplateDir);
  ForceDirectories(GameDir);

  // 1. Create fresh template files
  AssignFile(F, BgmodTemplateDir + '/bgmod'); Rewrite(F); WriteLn(F, 'NEW_BGMOD_BINARY_CONTENT'); CloseFile(F);
  AssignFile(F, BgmodTemplateDir + '/bgmod-uninstaller'); Rewrite(F); WriteLn(F, 'NEW_UNINSTALLER_CONTENT'); CloseFile(F);
  AssignFile(F, BgmodTemplateDir + '/bgmod-splash'); Rewrite(F); WriteLn(F, 'NEW_SPLASH_CONTENT'); CloseFile(F);

  // 2. Create outdated wrapper in game folder, alongside user configs
  AssignFile(F, GameDir + '/bgmod'); Rewrite(F); WriteLn(F, 'OLD_OUTDATED_BGMOD'); CloseFile(F);
  AssignFile(F, GameDir + '/bgmod.conf'); Rewrite(F); WriteLn(F, 'USER_CUSTOM_CONFIG=1'); CloseFile(F);
  AssignFile(F, GameDir + '/MangoHud.conf'); Rewrite(F); WriteLn(F, 'fps_limit=60'); CloseFile(F);

  // Run the sync
  SyncAllGameConfigBinaries;

  // 3. Verify bgmod, uninstaller and splash were updated to the new content
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(GameDir + '/bgmod');
    AssertEquals('bgmod should be updated to match template', 'NEW_BGMOD_BINARY_CONTENT', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/bgmod-uninstaller');
    AssertEquals('bgmod-uninstaller should be updated to match template', 'NEW_UNINSTALLER_CONTENT', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/bgmod-splash');
    AssertEquals('bgmod-splash should be copied from template', 'NEW_SPLASH_CONTENT', Trim(Lines.Text));

    // 4. Verify user configs are preserved
    Lines.LoadFromFile(GameDir + '/bgmod.conf');
    AssertEquals('bgmod.conf user config must be preserved', 'USER_CUSTOM_CONFIG=1', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/MangoHud.conf');
    AssertEquals('MangoHud.conf user config must be preserved', 'fps_limit=60', Trim(Lines.Text));

    // 5. Verify fgmod symlink exists
    AssertTrue('fgmod symlink must exist', FileExists(GameDir + '/fgmod'));
  finally
    Lines.Free;
  end;
end;

procedure TSyncGameWrapperBinariesTests.TestSyncPreservesMultipleGameDirectories;
var
  BaseDir, BgmodTemplateDir, GameA, GameB: string;
  F: TextFile;
  Lines: TStringList;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay';
  BgmodTemplateDir := BaseDir + '/bgmod';
  GameA := BaseDir + '/gameconfig/GameA';
  GameB := BaseDir + '/gameconfig/GameB';

  ForceDirectories(BgmodTemplateDir);
  ForceDirectories(GameA);
  ForceDirectories(GameB);

  // 1. Create fresh template files
  AssignFile(F, BgmodTemplateDir + '/bgmod'); Rewrite(F); WriteLn(F, 'MASTER_BGMOD'); CloseFile(F);
  AssignFile(F, BgmodTemplateDir + '/bgmod-uninstaller'); Rewrite(F); WriteLn(F, 'MASTER_UNINSTALLER'); CloseFile(F);

  // 2. Set up two existing games with stale binaries
  AssignFile(F, GameA + '/bgmod'); Rewrite(F); WriteLn(F, 'STALE_A'); CloseFile(F);
  AssignFile(F, GameA + '/bgmod.conf'); Rewrite(F); WriteLn(F, 'GAME_A_CONFIG=1'); CloseFile(F);

  AssignFile(F, GameB + '/bgmod'); Rewrite(F); WriteLn(F, 'STALE_B'); CloseFile(F);
  AssignFile(F, GameB + '/bgmod.conf'); Rewrite(F); WriteLn(F, 'GAME_B_CONFIG=2'); CloseFile(F);

  SyncAllGameConfigBinaries;

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(GameA + '/bgmod');
    AssertEquals('GameA bgmod must be updated', 'MASTER_BGMOD', Trim(Lines.Text));
    Lines.LoadFromFile(GameA + '/bgmod.conf');
    AssertEquals('GameA config must be preserved', 'GAME_A_CONFIG=1', Trim(Lines.Text));

    Lines.LoadFromFile(GameB + '/bgmod');
    AssertEquals('GameB bgmod must be updated', 'MASTER_BGMOD', Trim(Lines.Text));
    Lines.LoadFromFile(GameB + '/bgmod.conf');
    AssertEquals('GameB config must be preserved', 'GAME_B_CONFIG=2', Trim(Lines.Text));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSelfUpdateTests.TestFindMasterBGModDir;
var
  BaseDir, BgmodTemplateDir, GameDir, FoundMaster: string;
  F: TextFile;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay';
  BgmodTemplateDir := BaseDir + '/bgmod';
  GameDir := BaseDir + '/gameconfig/GameTest';
  ForceDirectories(BgmodTemplateDir);
  ForceDirectories(GameDir);

  AssignFile(F, BgmodTemplateDir + '/bgmod'); Rewrite(F); WriteLn(F, 'MASTER_BIN'); CloseFile(F);

  FoundMaster := FindMasterBGModDir(GameDir);
  AssertTrue('Master directory should be found', FoundMaster <> '');
  AssertEquals('Master directory should match template dir',
    IncludeTrailingPathDelimiter(ExpandFileName(BgmodTemplateDir)),
    IncludeTrailingPathDelimiter(ExpandFileName(FoundMaster)));

  // If running dir IS the master dir, it should not pick itself
  FoundMaster := FindMasterBGModDir(BgmodTemplateDir);
  AssertFalse('Master resolution should not pick running dir itself',
    IncludeTrailingPathDelimiter(ExpandFileName(FoundMaster)) =
    IncludeTrailingPathDelimiter(ExpandFileName(BgmodTemplateDir)));
end;

procedure TBgmodSelfUpdateTests.TestCheckBGModNeedsUpdate;
var
  FileA, FileB: string;
  F: TextFile;
begin
  FileA := IsolatedHome + '/test_bgmod_running';
  FileB := IsolatedHome + '/test_bgmod_master';

  // 1. Different sizes
  AssignFile(F, FileA); Rewrite(F); WriteLn(F, 'SHORT'); CloseFile(F);
  AssignFile(F, FileB); Rewrite(F); WriteLn(F, 'MUCH_LONGER_CONTENT_IN_MASTER'); CloseFile(F);
  AssertTrue('Different file sizes must require update', CheckBGModNeedsUpdate(FileA, FileB));

  // 2. Same content and size
  AssignFile(F, FileA); Rewrite(F); WriteLn(F, 'IDENTICAL_CONTENT'); CloseFile(F);
  AssignFile(F, FileB); Rewrite(F); WriteLn(F, 'IDENTICAL_CONTENT'); CloseFile(F);
  AssertFalse('Identical content and stat should not require update', CheckBGModNeedsUpdate(FileA, FileB));

  // 3. Same path
  AssertFalse('Same file path should not require update', CheckBGModNeedsUpdate(FileA, FileA));
end;

procedure TBgmodSelfUpdateTests.TestPerformAtomicBinaryUpdate;
var
  SrcFile, DstFile: string;
  F: TextFile;
  Lines: TStringList;
begin
  SrcFile := IsolatedHome + '/test_src_binary';
  DstFile := IsolatedHome + '/test_dst_binary';

  AssignFile(F, SrcFile); Rewrite(F); WriteLn(F, 'NEW_BINARY_CONTENT'); CloseFile(F);
  AssignFile(F, DstFile); Rewrite(F); WriteLn(F, 'OLD_BINARY_CONTENT'); CloseFile(F);

  AssertTrue('PerformAtomicBinaryUpdate should succeed', PerformAtomicBinaryUpdate(SrcFile, DstFile));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(DstFile);
    AssertEquals('Destination binary must have updated content', 'NEW_BINARY_CONTENT', Trim(Lines.Text));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSelfUpdateTests.TestPerformWrapperSelfUpdate;
var
  BaseDir, MasterDir, GameDir: string;
  F: TextFile;
  Lines: TStringList;
begin
  BaseDir := IsolatedHome + '/.local/share/goverlay';
  MasterDir := BaseDir + '/bgmod';
  GameDir := BaseDir + '/gameconfig/SelfUpdateGame';

  ForceDirectories(MasterDir);
  ForceDirectories(GameDir);

  // 1. Create master binaries
  AssignFile(F, MasterDir + '/bgmod'); Rewrite(F); WriteLn(F, 'MASTER_BGMOD_BIN'); CloseFile(F);
  AssignFile(F, MasterDir + '/bgmod-uninstaller'); Rewrite(F); WriteLn(F, 'MASTER_UNINSTALLER_BIN'); CloseFile(F);
  AssignFile(F, MasterDir + '/bgmod-splash'); Rewrite(F); WriteLn(F, 'MASTER_SPLASH_BIN'); CloseFile(F);

  // 2. Create old game binaries and user config
  AssignFile(F, GameDir + '/bgmod'); Rewrite(F); WriteLn(F, 'OLD_BGMOD'); CloseFile(F);
  AssignFile(F, GameDir + '/bgmod-uninstaller'); Rewrite(F); WriteLn(F, 'OLD_UNINSTALLER'); CloseFile(F);
  AssignFile(F, GameDir + '/bgmod-splash'); Rewrite(F); WriteLn(F, 'OLD_SPLASH'); CloseFile(F);
  AssignFile(F, GameDir + '/bgmod.conf'); Rewrite(F); WriteLn(F, 'KEEP_MY_CONFIG=1'); CloseFile(F);

  AssertTrue('PerformWrapperSelfUpdate should succeed', PerformWrapperSelfUpdate(GameDir, MasterDir));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(GameDir + '/bgmod');
    AssertEquals('Game bgmod must be updated', 'MASTER_BGMOD_BIN', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/bgmod-uninstaller');
    AssertEquals('Game bgmod-uninstaller must be updated', 'MASTER_UNINSTALLER_BIN', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/bgmod-splash');
    AssertEquals('Game bgmod-splash must be updated', 'MASTER_SPLASH_BIN', Trim(Lines.Text));

    Lines.LoadFromFile(GameDir + '/bgmod.conf');
    AssertEquals('Game bgmod.conf must be preserved', 'KEEP_MY_CONFIG=1', Trim(Lines.Text));

    AssertTrue('fgmod symlink must exist and point to bgmod', FileExists(GameDir + '/fgmod'));
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSelfUpdateTests.TestBgmodExecutableSelfUpdate;
var
  BaseDir, MasterDir, GameDir, RepoBgmod, LogFile: string;
  Proc: TProcess;
  Lines: TStringList;
begin
  RepoBgmod := ExpandFileName('bgmod');
  if not FileExists(RepoBgmod) then Exit;

  BaseDir := IsolatedHome + '/.local/share/goverlay';
  MasterDir := BaseDir + '/bgmod';
  GameDir := BaseDir + '/gameconfig/SelfUpdateExecGame';

  ForceDirectories(MasterDir);
  ForceDirectories(GameDir);

  // 1. Copy repo bgmod to master directory
  PerformAtomicBinaryUpdate(RepoBgmod, MasterDir + '/bgmod');

  // 2. Copy to game directory, but modify size/stat
  PerformAtomicBinaryUpdate(RepoBgmod, GameDir + '/bgmod');
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('echo "X" >> ' + QuotedStr(GameDir + '/bgmod'));
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // 3. Execute the game wrapper with true
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := GameDir + '/bgmod';
    Proc.Parameters.Add(FindTestHelperExecutable('true'));
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
    AssertEquals('Self-updating bgmod process should exit with code 0', 0, Proc.ExitStatus);
  finally
    Proc.Free;
  end;

  // 4. Verify the log recorded self-update
  LogFile := BaseDir + '/logs/SelfUpdateExecGame/bgmod.log';
  AssertTrue('Central bgmod log should exist', FileExists(LogFile));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Log must record self-update trigger', Pos('Performing atomic self-update', Lines.Text) > 0);
    AssertTrue('Log must record successful re-exec', Pos('BGMod active after wrapper self-update', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TBgmodSelfUpdateTests.TestBgmodExecutableSelfUpdatePreservesMultiArgs;
var
  BaseDir, MasterDir, GameDir, RepoBgmod, LogFile, OutStr: string;
  Proc: TProcess;
  Lines, OutLines: TStringList;
begin
  RepoBgmod := ExpandFileName('bgmod');
  if not FileExists(RepoBgmod) then Exit;

  BaseDir := IsolatedHome + '/.local/share/goverlay';
  MasterDir := BaseDir + '/bgmod';
  GameDir := BaseDir + '/gameconfig/SelfUpdateMultiArgGame';

  ForceDirectories(MasterDir);
  ForceDirectories(GameDir);

  PerformAtomicBinaryUpdate(RepoBgmod, MasterDir + '/bgmod');
  PerformAtomicBinaryUpdate(RepoBgmod, GameDir + '/bgmod');

  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('echo "X" >> ' + QuotedStr(GameDir + '/bgmod'));
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  Proc := TProcess.Create(nil);
  OutLines := TStringList.Create;
  try
    Proc.Executable := GameDir + '/bgmod';
    Proc.Parameters.Add('echo');
    Proc.Parameters.Add('first_arg');
    Proc.Parameters.Add('second_arg');
    Proc.Parameters.Add('Game.exe');
    Proc.Options := [poWaitOnExit, poUsePipes];
    Proc.Execute;
    OutLines.LoadFromStream(Proc.Output);
    OutStr := Trim(OutLines.Text);
    AssertEquals('Self-updating bgmod with echo should exit 0', 0, Proc.ExitStatus);
    AssertTrue('echo subprocess should receive all arguments intact', Pos('first_arg second_arg Game.exe', OutStr) > 0);
  finally
    OutLines.Free;
    Proc.Free;
  end;

  LogFile := BaseDir + '/logs/SelfUpdateMultiArgGame/bgmod.log';
  AssertTrue('Central bgmod log should exist', FileExists(LogFile));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(LogFile);
    AssertTrue('Log must record BGMod active after self-update', Pos('BGMod active after wrapper self-update', Lines.Text) > 0);
    AssertTrue('Log must preserve Arg 0: echo', Pos('Arg 0: echo', Lines.Text) > 0);
    AssertTrue('Log must preserve Arg 1: first_arg', Pos('Arg 1: first_arg', Lines.Text) > 0);
    AssertTrue('Log must preserve Arg 2: second_arg', Pos('Arg 2: second_arg', Lines.Text) > 0);
    AssertTrue('Log must preserve Arg 3: Game.exe', Pos('Arg 3: Game.exe', Lines.Text) > 0);
    AssertTrue('Log must launch echo, not Game.exe', Pos('Launching subprocess: echo', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TRuntimeUpdateDowngradeTests.TestExtractReleaseTagFromAtomXmlLinkHref;
var
  Xml: string;
begin
  Xml := '<entry><link rel="alternate" type="text/html" href="https://github.com/eugeniosegala/MAKO/releases/tag/render-v4.5.0"/><title>MAKO v4.5.0</title></entry>';
  AssertEquals('Extract release tag from link href', 'render-v4.5.0', ExtractReleaseTagFromAtomXml(Xml));
end;

procedure TRuntimeUpdateDowngradeTests.TestExtractReleaseTagFromAtomXmlIdTag;
var
  Xml: string;
begin
  Xml := '<entry><id>tag:github.com,2008:Repository/1405556861/v1.9.0</id><title>v1.9.0</title></entry>';
  AssertEquals('Extract release tag from id tag fallback', 'v1.9.0', ExtractReleaseTagFromAtomXml(Xml));
end;

procedure TRuntimeUpdateDowngradeTests.TestExtractReleaseTagFromAtomXmlEmpty;
begin
  AssertEquals('Empty Atom XML yields empty tag', '', ExtractReleaseTagFromAtomXml(''));
  AssertEquals('Feed without entries yields empty tag', '',
    ExtractReleaseTagFromAtomXml('<feed><title>No entries</title></feed>'));
end;

procedure TRuntimeUpdateDowngradeTests.TestSemverComparisonSemantics;
begin
  AssertTrue('4.5.0 > 4.0.0', CompareVersions('4.5.0', '4.0.0') > 0);
  AssertTrue('4.0.0 = 4.0.0', CompareVersions('4.0.0', '4.0.0') = 0);
  AssertTrue('3.0.0 < 4.0.0', CompareVersions('3.0.0', '4.0.0') < 0);
  AssertTrue('1.9.0 > 1.8.1', CompareVersions('1.9.0', '1.8.1') > 0);
  AssertTrue('1.3.1 = 1.3.1', CompareVersions('1.3.1', '1.3.1') = 0);
end;

procedure TRuntimeUpdateDowngradeTests.TestDowngradeSuppressionLogic;
begin
  AssertFalse('Downgrade 3.0.0 over 4.0.0 must not trigger update condition',
    CompareVersions('3.0.0', '4.0.0') > 0);
  AssertTrue('Upgrade 4.5.0 over 4.0.0 triggers update condition',
    CompareVersions('4.5.0', '4.0.0') > 0);
end;

procedure TShellQuoteTests.TestEmptyString;
begin
  AssertEquals('Empty string quoted', '''''', ShellQuote(''));
end;

procedure TShellQuoteTests.TestPlainPath;
begin
  AssertEquals('Plain path wrapped', '''/usr/bin/game''', ShellQuote('/usr/bin/game'));
end;

procedure TShellQuoteTests.TestPathWithSpaces;
begin
  AssertEquals('Path with spaces', '''/home/user/My Games/Foo''', ShellQuote('/home/user/My Games/Foo'));
end;

procedure TShellQuoteTests.TestPathWithApostrophe;
begin
  AssertEquals('Path with single apostrophe escaped', '''/home/user/No Man''\''''s Sky''', ShellQuote('/home/user/No Man''s Sky'));
end;

procedure TShellQuoteTests.TestPathWithMultipleApostrophes;
begin
  AssertEquals('Path with multiple apostrophes', '''''\''''''\''''''\''''''', ShellQuote(''''''''));
end;

procedure TShellQuoteTests.TestSpecialShellCharacters;
begin
  AssertEquals('Special characters preserved', '''$HOME/`evil`/foo*bar"baz''', ShellQuote('$HOME/`evil`/foo*bar"baz'));
end;

procedure TRDNAArchitectureTests.TestDetectRDNAArchitectureActiveGpu;
var
  Arch: TRDNAArchitecture;
begin
  Arch := DetectRDNAArchitecture;
  // If run on an AMD RDNA3 host (like RX 7900 XTX)
  if DetectGPUVendor = gpuAMD then
  begin
    // Check that it detects RDNA3 or RDNA4, or unsupported
    AssertTrue('DetectRDNAArchitecture returns a valid enum', Arch in [rdnaUnsupported, rdna3, rdna4]);
    if Pos('7900', GetSysGPUModel) > 0 then
      AssertEquals('RX 7900 detected as RDNA3', Ord(rdna3), Ord(Arch));
  end
  else
    AssertEquals('Non-AMD GPU returns rdnaUnsupported', Ord(rdnaUnsupported), Ord(Arch));
end;

procedure TRDNAArchitectureTests.TestDetectRDNAArchitectureFromTextRDNA4;
begin
  AssertEquals('Navi 44 PCI id', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('1002:7590')));
  AssertEquals('Navi 44 sysfs id', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('0x7590')));
  AssertEquals('RX 9060 XT', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('AMD Radeon RX 9060 XT')));
  AssertEquals('Navi 48 PCI id', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('1002:7500')));
  AssertEquals('Navi 48 name', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('Navi 48')));
  AssertEquals('gfx1200', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('gfx1200')));
  AssertEquals('RX 9070', Ord(rdna4), Ord(DetectRDNAArchitectureFromText('rx 9070')));
end;

procedure TRDNAArchitectureTests.TestDetectRDNAArchitectureFromTextRDNA3;
begin
  AssertEquals('RX 7900', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('AMD Radeon RX 7900 XTX')));
  AssertEquals('gfx1100', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('gfx1100')));
  AssertEquals('RX 7800', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('RX 7800 XT')));
  AssertEquals('Radeon 780M', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('Radeon 780M')));
  AssertEquals('Phoenix', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('Phoenix APU')));
  AssertEquals('Strix', Ord(rdna3), Ord(DetectRDNAArchitectureFromText('Strix Point')));
end;

procedure TRDNAArchitectureTests.TestDetectRDNAArchitectureFromTextUnsupported;
begin
  AssertEquals('RX 6800', Ord(rdnaUnsupported), Ord(DetectRDNAArchitectureFromText('AMD Radeon RX 6800 XT')));
  AssertEquals('gfx1030', Ord(rdnaUnsupported), Ord(DetectRDNAArchitectureFromText('gfx1030')));
  AssertEquals('Navi 21 PCI id', Ord(rdnaUnsupported), Ord(DetectRDNAArchitectureFromText('1002:73bf')));
  AssertEquals('Empty string', Ord(rdnaUnsupported), Ord(DetectRDNAArchitectureFromText('')));
end;

procedure TRDNAArchitectureTests.TestRDNAArchitectureToString;
begin
  AssertEquals('RDNA4 string', 'RDNA4', RDNAArchitectureToString(rdna4));
  AssertEquals('RDNA3 string', 'RDNA3', RDNAArchitectureToString(rdna3));
  AssertEquals('Unsupported string', 'Unsupported', RDNAArchitectureToString(rdnaUnsupported));
end;

procedure TRDNAArchitectureTests.TestGetBGModDlssNrPathArch;
begin
  AssertTrue('RDNA4 path ends with dlss-nr-rdna4', Pos('dlss-nr-rdna4', GetBGModDlssNrPath('rdna4')) > 0);
  AssertTrue('RDNA3 path ends with dlss-nr-rdna3', Pos('dlss-nr-rdna3', GetBGModDlssNrPath('rdna3')) > 0);
  AssertTrue('Default path ends with dlss-nr', Pos('dlss-nr', GetBGModDlssNrPath('')) > 0);
  AssertEquals('RDNA3 32-bit runtime sits next to the 64-bit one',
    GetBGModDlssNrPath('rdna3') + '-i686', GetBGModDlssNr32Path('rdna3'));
  AssertEquals('RDNA4 32-bit runtime sits next to the 64-bit one',
    GetBGModDlssNrPath('rdna4') + '-i686', GetBGModDlssNr32Path('rdna4'));
end;

procedure TMangoHudBlacklistSyncTests.TestBlacklistSyncCreatesDefaultAndSyncs;
var
  BlacklistFile, MangoHudFile, GlobalProfileFile: string;
  Lines: TStringList;
begin
  BlacklistFile := TConfigManager.GetBlacklistFile;
  if FileExists(BlacklistFile) then
    DeleteFile(BlacklistFile);

  MangoHudFile := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  if FileExists(MangoHudFile) then
    DeleteFile(MangoHudFile);

  GlobalProfileFile := GetGameConfigDir('') + 'MangoHud.conf';
  ForceDirectories(ExtractFilePath(GlobalProfileFile));
  if FileExists(GlobalProfileFile) then
    DeleteFile(GlobalProfileFile);

  AssertTrue('SyncBlacklistToMangoHud succeeds', SyncBlacklistToMangoHud);
  AssertTrue('BlacklistFile created', FileExists(BlacklistFile));
  AssertTrue('MangoHudFile created', FileExists(MangoHudFile));
  AssertTrue('Global profile MangoHudFile created', FileExists(GlobalProfileFile));

  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(MangoHudFile);
    AssertTrue('blacklist line present in MangoHud.conf', Pos('blacklist=', Lines.Text) > 0);
    AssertTrue('zenity present in blacklist', Pos('zenity', Lines.Text) > 0);
    AssertTrue('lsfg-vk-ui present in blacklist', Pos('lsfg-vk-ui', Lines.Text) > 0);

    Lines.LoadFromFile(GlobalProfileFile);
    AssertTrue('blacklist line present in global profile MangoHud.conf', Pos('blacklist=', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TMangoHudBlacklistSyncTests.TestBlacklistSyncExplicitList;
var
  CustomList, Lines: TStringList;
  MangoHudFile: string;
begin
  MangoHudFile := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  CustomList := TStringList.Create;
  Lines := TStringList.Create;
  try
    CustomList.Add('custom-game-bin');
    CustomList.Add('discord');
    AssertTrue('Sync succeeds with custom list', SyncBlacklistToMangoHud(CustomList));

    Lines.LoadFromFile(MangoHudFile);
    AssertTrue('Custom blacklist line present', Pos('blacklist=custom-game-bin,discord', Lines.Text) > 0);
  finally
    CustomList.Free;
    Lines.Free;
  end;
end;

procedure TMangoHudBlacklistSyncTests.TestBlacklistSyncEmptyList;
var
  EmptyList, Lines: TStringList;
  MangoHudFile: string;
begin
  MangoHudFile := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  EmptyList := TStringList.Create;
  Lines := TStringList.Create;
  try
    AssertTrue('Sync succeeds with empty list', SyncBlacklistToMangoHud(EmptyList));

    if FileExists(MangoHudFile) then
    begin
      Lines.LoadFromFile(MangoHudFile);
      AssertFalse('blacklist= should be deleted when list is empty', Pos('blacklist=', Lines.Text) > 0);
    end;
  finally
    EmptyList.Free;
    Lines.Free;
  end;
end;

procedure TMangoHudColorParsingTests.TestHexToColorParsing;
begin
  AssertEquals('Red with hash', clRed, HexToColor('#FF0000'));
  AssertEquals('Lime with hash', clLime, HexToColor('#00FF00'));
  AssertEquals('Blue with hash', clBlue, HexToColor('#0000FF'));
  AssertEquals('Hex without hash', clLime, HexToColor('00FF00'));
  AssertEquals('Short 3-character hex', clLime, HexToColor('#0F0'));
  AssertEquals('Hex with spaces', clLime, HexToColor('  #00FF00  '));
  AssertEquals('Empty hex fallback', clWhite, HexToColor(''));
  AssertEquals('Invalid string fallback', clWhite, HexToColor('not_a_color'));
end;

procedure TMangoHudColorParsingTests.TestOptiForceReflexLoadingLogic;
var
  GameName, IniPath: string;
  Settings: TOptiScalerSettings;

  procedure WriteFakeIni(const AContent: string);
  var
    F: TextFile;
  begin
    AssignFile(F, IniPath);
    Rewrite(F);
    if AContent <> '' then
      WriteLn(F, AContent);
    CloseFile(F);
  end;

begin
  GameName := 'TestForceReflexLoadingLogic';
  IniPath := GetGameConfigDir(GameName) + 'fakenvapi.ini';
  ForceDirectories(ExtractFilePath(IniPath));
  try
    WriteFakeIni('force_reflex=0');
    AssertTrue('LoadOptiScalerConfig succeeds with force_reflex=0',
      LoadOptiScalerConfig(GameName, Settings));
    AssertFalse('force_reflex=0 is unchecked', Settings.ForceReflexChecked);
    AssertEquals('force_reflex=0 sets item index 0', 0, Settings.ReflexItemIndex);

    WriteFakeIni('force_reflex=1');
    AssertTrue('LoadOptiScalerConfig succeeds with force_reflex=1',
      LoadOptiScalerConfig(GameName, Settings));
    AssertTrue('force_reflex=1 is checked', Settings.ForceReflexChecked);
    AssertEquals('force_reflex=1 sets item index 1', 1, Settings.ReflexItemIndex);

    WriteFakeIni('force_reflex=2');
    AssertTrue('LoadOptiScalerConfig succeeds with force_reflex=2',
      LoadOptiScalerConfig(GameName, Settings));
    AssertTrue('force_reflex=2 is checked', Settings.ForceReflexChecked);
    AssertEquals('force_reflex=2 sets item index 2', 2, Settings.ReflexItemIndex);

    WriteFakeIni('force_latencyflex=0');
    AssertTrue('LoadOptiScalerConfig succeeds without force_reflex',
      LoadOptiScalerConfig(GameName, Settings));
    AssertFalse('Missing force_reflex is unchecked', Settings.ForceReflexChecked);
    AssertEquals('Missing force_reflex sets item index 0', 0, Settings.ReflexItemIndex);
  finally
    DeleteFile(IniPath);
  end;
end;

procedure TGoverlayLogicTests.TestModuleConfigReadWrite;
var
  ConfigPath: string;
  Ini: TIniFile;
begin
  ConfigPath := TConfigManager.GetConfigFilePath;
  AssertTrue('config path is inside isolated HOME',
    Pos(IncludeTrailingPathDelimiter(IsolatedHome), ConfigPath) = 1);

  if FileExists(ConfigPath) then
    AssertTrue('old goverlay.conf removed', DeleteFile(ConfigPath));
  ForceDirectories(ExtractFileDir(ConfigPath));
  AssertFalse('goverlay.conf starts absent', FileExists(ConfigPath));

  TConfigManager.SetFirstRunWizardCompleted(False);
  AssertFalse('FirstRunWizardCompleted false round-trip',
    TConfigManager.IsFirstRunWizardCompleted);

  TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, False);
  TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, False);
  TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, False);
  AssertFalse('PostProcessing false round-trip',
    TConfigManager.IsModuleEnabled(MODULE_POSTPROCESSING));
  AssertFalse('Upscalers false round-trip',
    TConfigManager.IsModuleEnabled(MODULE_UPSCALERS));
  AssertFalse('FrameGeneration false round-trip',
    TConfigManager.IsModuleEnabled(MODULE_FRAMEGENERATION));

  AssertTrue('goverlay.conf created', FileExists(ConfigPath));
  Ini := TIniFile.Create(ConfigPath);
  try
    AssertTrue('General section has FirstRunWizardCompleted',
      Ini.ValueExists('General', KEY_FIRST_RUN_WIZARD));
    AssertEquals('FirstRunWizardCompleted persisted false', '0',
      Ini.ReadString('General', KEY_FIRST_RUN_WIZARD, ''));
    AssertEquals('PostProcessing persisted false', '0',
      Ini.ReadString(SECTION_MODULES, MODULE_POSTPROCESSING, ''));
    AssertEquals('Upscalers persisted false', '0',
      Ini.ReadString(SECTION_MODULES, MODULE_UPSCALERS, ''));
    AssertEquals('FrameGeneration persisted false', '0',
      Ini.ReadString(SECTION_MODULES, MODULE_FRAMEGENERATION, ''));
  finally
    Ini.Free;
  end;

  TConfigManager.SetFirstRunWizardCompleted(True);
  AssertTrue('FirstRunWizardCompleted true round-trip',
    TConfigManager.IsFirstRunWizardCompleted);

  TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, True);
  TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, True);
  TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, True);
  AssertTrue('PostProcessing true round-trip',
    TConfigManager.IsModuleEnabled(MODULE_POSTPROCESSING));
  AssertTrue('Upscalers true round-trip',
    TConfigManager.IsModuleEnabled(MODULE_UPSCALERS));
  AssertTrue('FrameGeneration true round-trip',
    TConfigManager.IsModuleEnabled(MODULE_FRAMEGENERATION));

  Ini := TIniFile.Create(ConfigPath);
  try
    AssertEquals('FirstRunWizardCompleted persisted true', '1',
      Ini.ReadString('General', KEY_FIRST_RUN_WIZARD, ''));
    AssertEquals('PostProcessing persisted true', '1',
      Ini.ReadString(SECTION_MODULES, MODULE_POSTPROCESSING, ''));
    AssertEquals('Upscalers persisted true', '1',
      Ini.ReadString(SECTION_MODULES, MODULE_UPSCALERS, ''));
    AssertEquals('FrameGeneration persisted true', '1',
      Ini.ReadString(SECTION_MODULES, MODULE_FRAMEGENERATION, ''));
  finally
    Ini.Free;
  end;
end;

procedure TGoverlayLogicTests.TestModuleMigrationExistingAndFresh;
var
  ConfigPath, DataDir, TempIniPath: string;
  Ini: TIniFile;

  procedure RemoveSandboxDir(const APath: string);
  begin
    if APath = '' then Exit;
    if Pos(IncludeTrailingPathDelimiter(IsolatedHome),
      IncludeTrailingPathDelimiter(ExpandFileName(APath))) <> 1 then Exit;
    if DirectoryExists(APath) then
      DeleteDirectory(APath, False);
  end;

begin
  ConfigPath := TConfigManager.GetConfigFilePath;
  AssertTrue('config path is inside isolated HOME',
    Pos(IncludeTrailingPathDelimiter(IsolatedHome), ConfigPath) = 1);

  DataDir := IncludeTrailingPathDelimiter(TConfigManager.GetHostDataDir) +
    GOVERLAY_FOLDER_NAME + PathDelim;

  // Fresh install: no config file and no leftover module artifacts.
  if FileExists(ConfigPath) then
    AssertTrue('old goverlay.conf removed', DeleteFile(ConfigPath));
  if FileExists(TConfigManager.GetOptiScalerIniFile) then
    AssertTrue('old OptiScaler.ini removed',
      DeleteFile(TConfigManager.GetOptiScalerIniFile));
  RemoveSandboxDir(TConfigManager.GetFgmodFolder);
  RemoveSandboxDir(TConfigManager.GetReshadeFolder);
  RemoveSandboxDir(IncludeTrailingPathDelimiter(
    TConfigManager.GetGoverlayFolder) + FGMOD_FOLDER_NAME);
  RemoveSandboxDir(DataDir + FGMOD_FOLDER_NAME);
  RemoveSandboxDir(DataDir + 'optiscaler');
  RemoveSandboxDir(DataDir + 'optiscaler-stable');
  RemoveSandboxDir(DataDir + 'optiscaler-edge');
  RemoveSandboxDir(DataDir + 'optiscaler-helixsr');
  RemoveSandboxDir(DataDir + 'reshade');
  RemoveSandboxDir(DataDir + 'lsfg-vk');
  RemoveSandboxDir(DataDir + 'mako');
  RemoveSandboxDir(DataDir + 'afmf');
  AssertFalse('fresh scenario has no goverlay.conf', FileExists(ConfigPath));

  Ini := TIniFile.Create(ConfigPath);
  try
    TConfigManager.MigrateExistingInstallation(Ini);
    AssertFalse('fresh migration leaves wizard incomplete',
      Ini.ReadBool('General', KEY_FIRST_RUN_WIZARD, True));
    AssertFalse('fresh migration disables PostProcessing',
      Ini.ReadBool(SECTION_MODULES, MODULE_POSTPROCESSING, True));
    AssertFalse('fresh migration disables Upscalers',
      Ini.ReadBool(SECTION_MODULES, MODULE_UPSCALERS, True));
    AssertFalse('fresh migration disables FrameGeneration',
      Ini.ReadBool(SECTION_MODULES, MODULE_FRAMEGENERATION, True));
  finally
    Ini.Free;
  end;

  // Template bgmod folder alone must not be treated as an existing install.
  TempIniPath := IsolatedHome + PathDelim + 'migration_bgmod_only.conf';
  if FileExists(TempIniPath) then DeleteFile(TempIniPath);
  ForceDirectories(DataDir + FGMOD_FOLDER_NAME);
  Ini := TIniFile.Create(TempIniPath);
  try
    TConfigManager.MigrateExistingInstallation(Ini);
    AssertFalse('bgmod template alone leaves wizard incomplete',
      Ini.ReadBool('General', KEY_FIRST_RUN_WIZARD, True));
    AssertFalse('bgmod template alone disables PostProcessing',
      Ini.ReadBool(SECTION_MODULES, MODULE_POSTPROCESSING, True));
    AssertFalse('bgmod template alone disables Upscalers',
      Ini.ReadBool(SECTION_MODULES, MODULE_UPSCALERS, True));
    AssertFalse('bgmod template alone disables FrameGeneration',
      Ini.ReadBool(SECTION_MODULES, MODULE_FRAMEGENERATION, True));
  finally
    Ini.Free;
    if FileExists(TempIniPath) then DeleteFile(TempIniPath);
    RemoveSandboxDir(DataDir + FGMOD_FOLDER_NAME);
  end;

  // Existing installation: previous Version present, no wizard key yet.
  TempIniPath := IsolatedHome + PathDelim + 'migration_existing.conf';
  if FileExists(TempIniPath) then DeleteFile(TempIniPath);
  Ini := TIniFile.Create(TempIniPath);
  try
    Ini.WriteString('General', 'Version', '1.8.9');
    Ini.UpdateFile;
    TConfigManager.MigrateExistingInstallation(Ini);
    AssertTrue('existing migration marks wizard complete',
      Ini.ReadBool('General', KEY_FIRST_RUN_WIZARD, False));
    AssertTrue('existing migration enables PostProcessing',
      Ini.ReadBool(SECTION_MODULES, MODULE_POSTPROCESSING, False));
    AssertTrue('existing migration enables Upscalers',
      Ini.ReadBool(SECTION_MODULES, MODULE_UPSCALERS, False));
    AssertTrue('existing migration enables FrameGeneration',
      Ini.ReadBool(SECTION_MODULES, MODULE_FRAMEGENERATION, False));
  finally
    Ini.Free;
    if FileExists(TempIniPath) then DeleteFile(TempIniPath);
  end;
end;

procedure TGoverlayLogicTests.TestScopedHasMissingMandatoryLibraries;
var
  Missing: TStringList;
begin
  // 1. When all optional modules/libraries are disabled, HasMissingMandatoryLibraries returns False
  TConfigManager.SetModuleEnabled(MODULE_VKBASALT, False);
  TConfigManager.SetModuleEnabled(MODULE_RESHADE, False);
  TConfigManager.SetModuleEnabled(MODULE_VKSUMI, False);
  TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, False);
  TConfigManager.SetModuleEnabled(MODULE_DLSSENABLER, False);
  TConfigManager.SetModuleEnabled(MODULE_HELIXSR, False);
  TConfigManager.SetModuleEnabled(MODULE_LSFGVK, False);
  TConfigManager.SetModuleEnabled(MODULE_MAKO, False);
  TConfigManager.SetModuleEnabled(MODULE_AFMF, False);
  TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, False);
  TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, False);
  TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, False);

  Missing := nil;
  try
    AssertFalse('HasMissingMandatoryLibraries returns False when modules disabled',
      HasMissingMandatoryLibraries(Missing));
    AssertEquals('No missing libraries when modules disabled', 0, Missing.Count);
  finally
    Missing.Free;
  end;

  // 2. When only OptiScaler is enabled (files missing), HasMissingMandatoryLibraries returns True and reports OptiScaler
  TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, True);
  Missing := nil;
  try
    AssertTrue('HasMissingMandatoryLibraries returns True when OptiScaler enabled and files missing',
      HasMissingMandatoryLibraries(Missing));
    AssertTrue('OptiScaler missing reported', Missing.IndexOf('OptiScaler.dll') >= 0);
    AssertFalse('ReShade not reported when ReShade disabled', Missing.IndexOf('ReShade64.dll') >= 0);
    AssertFalse('Optional DLSS-NR not reported as mandatory missing library', Missing.IndexOf('DLSS-NR models') >= 0);
  finally
    Missing.Free;
  end;

  // 3. When only vkBasalt is enabled, vkBasalt shaders are reported but OptiScaler is not
  TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, False);
  TConfigManager.SetModuleEnabled(MODULE_VKBASALT, True);
  Missing := nil;
  try
    AssertTrue('HasMissingMandatoryLibraries returns True when vkBasalt enabled',
      HasMissingMandatoryLibraries(Missing));
    AssertTrue('vkBasalt shaders reported', Missing.IndexOf('vkBasalt ReShade Shaders') >= 0);
    AssertFalse('OptiScaler not reported', Missing.IndexOf('OptiScaler.dll') >= 0);
  finally
    Missing.Free;
  end;

  // 4. Reset module states for test isolation
  TConfigManager.SetModuleEnabled(MODULE_VKBASALT, True);
  TConfigManager.SetModuleEnabled(MODULE_RESHADE, True);
  TConfigManager.SetModuleEnabled(MODULE_VKSUMI, True);
  TConfigManager.SetModuleEnabled(MODULE_OPTISCALER, True);
  TConfigManager.SetModuleEnabled(MODULE_DLSSENABLER, True);
  TConfigManager.SetModuleEnabled(MODULE_HELIXSR, True);
  TConfigManager.SetModuleEnabled(MODULE_LSFGVK, True);
  TConfigManager.SetModuleEnabled(MODULE_MAKO, True);
  TConfigManager.SetModuleEnabled(MODULE_AFMF, True);
  TConfigManager.SetModuleEnabled(MODULE_UPSCALERS, True);
  TConfigManager.SetModuleEnabled(MODULE_POSTPROCESSING, True);
  TConfigManager.SetModuleEnabled(MODULE_FRAMEGENERATION, True);
end;

procedure TGoverlayLogicTests.TestUninstallUserModulesAndLayers;
var
  HomeDir, LayerDir, LibDir, ShareDir: string;

  procedure CreateDummyFile(const APath: string);
  var
    F: TextFile;
  begin
    ForceDirectories(ExtractFileDir(APath));
    AssignFile(F, APath);
    Rewrite(F);
    WriteLn(F, '{"dummy": 1}');
    CloseFile(F);
  end;

begin
  HomeDir := IncludeTrailingPathDelimiter(IsolatedHome);
  LayerDir := HomeDir + '.local/share/vulkan/implicit_layer.d/';
  LibDir := HomeDir + '.local/lib/';
  ShareDir := HomeDir + '.local/share/goverlay/';

  // 1. Create mock user layer manifests and binaries
  CreateDummyFile(LayerDir + 'vksumi.json');
  CreateDummyFile(LayerDir + 'afmf-linux.json');
  CreateDummyFile(LayerDir + 'VkLayer_LSFGVK_frame_generation.json');
  CreateDummyFile(LayerDir + 'VkLayer_MAKO_render.json');
  CreateDummyFile(LayerDir + 'vknemu.json');
  CreateDummyFile(LayerDir + 'vkBasalt.json');
  CreateDummyFile(LayerDir + 'vkBasalt.x86.json');
  CreateDummyFile(LibDir + 'liblsfg-vk-layer.so');
  CreateDummyFile(LibDir + 'libmako-render.so');
  CreateDummyFile(LibDir + 'vkbasalt/libvkbasalt.so');
  CreateDummyFile(HomeDir + '.local/lib32/vkbasalt/libvkbasalt.so');
  CreateDummyFile(LibDir + 'afmf-linux/libafmf-linux.so');
  CreateDummyFile(ShareDir + 'optiscaler/version.txt');
  CreateDummyFile(ShareDir + 'reshade/ReShade64.dll');

  AssertTrue('vksumi layer created', FileExists(LayerDir + 'vksumi.json'));
  AssertTrue('afmf layer created', FileExists(LayerDir + 'afmf-linux.json'));
  AssertTrue('optiscaler created', FileExists(ShareDir + 'optiscaler/version.txt'));
  AssertTrue('vkBasalt.x86 created', FileExists(LayerDir + 'vkBasalt.x86.json'));
  AssertTrue('vkbasalt 64-bit lib created', FileExists(LibDir + 'vkbasalt/libvkbasalt.so'));
  AssertTrue('vkbasalt 32-bit lib created', FileExists(HomeDir + '.local/lib32/vkbasalt/libvkbasalt.so'));

  // 2. Test selective module uninstall (vkSumi)
  UninstallUserModule(MODULE_VKSUMI);
  AssertFalse('vksumi.json deleted after UninstallUserModule', FileExists(LayerDir + 'vksumi.json'));
  AssertTrue('afmf-linux.json still intact', FileExists(LayerDir + 'afmf-linux.json'));
  AssertTrue('optiscaler still intact', FileExists(ShareDir + 'optiscaler/version.txt'));

  // 3. Test uninstall all user modules
  UninstallAllUserModules;
  AssertFalse('afmf-linux.json deleted', FileExists(LayerDir + 'afmf-linux.json'));
  AssertFalse('VkLayer_LSFGVK deleted', FileExists(LayerDir + 'VkLayer_LSFGVK_frame_generation.json'));
  AssertFalse('VkLayer_MAKO deleted', FileExists(LayerDir + 'VkLayer_MAKO_render.json'));
  AssertFalse('vknemu.json deleted', FileExists(LayerDir + 'vknemu.json'));
  AssertFalse('vkBasalt.json deleted', FileExists(LayerDir + 'vkBasalt.json'));
  AssertFalse('vkBasalt.x86.json deleted', FileExists(LayerDir + 'vkBasalt.x86.json'));
  AssertFalse('liblsfg-vk-layer.so deleted', FileExists(LibDir + 'liblsfg-vk-layer.so'));
  AssertFalse('libmako-render.so deleted', FileExists(LibDir + 'libmako-render.so'));
  AssertFalse('vkbasalt lib dir deleted', DirectoryExists(LibDir + 'vkbasalt'));
  AssertFalse('vkbasalt lib32 dir deleted', DirectoryExists(HomeDir + '.local/lib32/vkbasalt'));
  AssertFalse('afmf-linux dir deleted', DirectoryExists(LibDir + 'afmf-linux'));
  AssertFalse('optiscaler dir deleted', DirectoryExists(ShareDir + 'optiscaler'));
  AssertFalse('reshade dir deleted', DirectoryExists(ShareDir + 'reshade'));
end;

procedure TGoverlayLogicTests.TestCleanProfileDefaultsUpscalerToNone;
var
  Settings: TOptiScalerSettings;
begin
  AssertTrue('LoadOptiScalerConfig succeeds for nonexistent profile',
    LoadOptiScalerConfig('NonExistentCleanProfile999', Settings));
  AssertEquals('Clean profile defaults to None (UpscalerTypeItemIndex = 2)',
    2, Settings.UpscalerTypeItemIndex);
end;

procedure TGoverlayLogicTests.TestFlatpakLayerAndExtensionDetection;
var
  DataPath, LayerDir, SoFile, JsonFile: string;
  F: TextFile;
begin
  DataPath := IncludeTrailingPathDelimiter(GetGOverlayDataPath);
  LayerDir := GetUserVulkanImplicitDir;

  // 1. Verify sandboxed vkSumi detection
  ForceDirectories(DataPath + 'layers' + PathDelim + 'vksumi');
  ForceDirectories(LayerDir);
  SoFile := DataPath + 'layers' + PathDelim + 'vksumi' + PathDelim + 'libVkLayer_vksumi.so';
  JsonFile := LayerDir + 'vksumi.json';

  AssignFile(F, SoFile);
  Rewrite(F);
  // Write minimal ELF magic and pad past minimum size (65536 bytes) so IsValidSharedLibrary passes
  Write(F, #$7F + 'ELF' + StringOfChar(#0, 65540));
  CloseFile(F);

  AssignFile(F, JsonFile);
  Rewrite(F);
  WriteLn(F, '{"file_format_version": "1.0.0"}');
  CloseFile(F);

  AssertTrue('vkSumi detected via sandboxed data path', IsVkSumiInstalled);

  // 2. Verify sandboxed MAKO detection
  ForceDirectories(DataPath + 'layers' + PathDelim + 'mako');
  SoFile := DataPath + 'layers' + PathDelim + 'mako' + PathDelim + 'libmako-render.so';
  AssignFile(F, SoFile);
  Rewrite(F);
  Write(F, #$7F + 'ELF');
  CloseFile(F);

  AssertTrue('MAKO detected via sandboxed data path', IsMakoInstalled);

  // 3. Verify sandboxed AFMF detection
  ForceDirectories(DataPath + 'layers' + PathDelim + 'afmf');
  SoFile := DataPath + 'layers' + PathDelim + 'afmf' + PathDelim + 'libafmf-linux.so';
  AssignFile(F, SoFile);
  Rewrite(F);
  Write(F, #$7F + 'ELF');
  CloseFile(F);

  AssertTrue('AFMF detected via sandboxed data path', IsAfmfInstalled);

  // Clean up
  DeleteFile(SoFile);
  DeleteFile(JsonFile);
end;

procedure TMangoHudFlatpakIsolationTests.TestPerGameSaveDoesNotOverwriteSteamFlatpak;
var
  Settings: TMangoHudSettings;
  ErrMsg, FlatpakDir, FlatpakFile, GameCfgFile: string;
  Lines: TStringList;
begin
  FlatpakDir := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/config/MangoHud';
  ForceDirectories(FlatpakDir);
  FlatpakFile := FlatpakDir + '/MangoHud.conf';

  Lines := TStringList.Create;
  try
    Lines.Add('fps');
    Lines.Add('output_folder=/tmp/global_logs_sentinel');
    Lines.SaveToFile(FlatpakFile);

    FillChar(Settings, SizeOf(Settings), 0);
    Settings.Version := 'TEST';
    Settings.Channel := 'stable';
    Settings.ActiveGameName := 'Fatekeeper';
    Settings.LogFolder := IsolatedHome + '/.local/share/goverlay/logs/Fatekeeper';
    GameCfgFile := GetGameConfigDir('Fatekeeper') + 'MangoHud.conf';
    ForceDirectories(ExtractFilePath(GameCfgFile));
    Settings.MangoHudCfgFile := GameCfgFile;

    AssertTrue('Per-game save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));

    Lines.LoadFromFile(GameCfgFile);
    AssertTrue('Game config has game output_folder', Pos('/logs/Fatekeeper', Lines.Text) > 0);

    Lines.LoadFromFile(FlatpakFile);
    AssertTrue('Steam Flatpak global config preserved', Pos('output_folder=/tmp/global_logs_sentinel', Lines.Text) > 0);
    AssertFalse('Steam Flatpak global config not polluted by game log path', Pos('Fatekeeper', Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

procedure TMangoHudFlatpakIsolationTests.TestPerGameFpsOnlyDoesNotOverwriteSteamFlatpak;
var
  Settings: TMangoHudSettings;
  ErrMsg, FlatpakDir, FlatpakFile, GameCfgFile: string;
  Lines: TStringList;
begin
  FlatpakDir := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/config/MangoHud';
  ForceDirectories(FlatpakDir);
  FlatpakFile := FlatpakDir + '/MangoHud.conf';

  Lines := TStringList.Create;
  try
    Lines.Add('fps_limit=144');
    Lines.SaveToFile(FlatpakFile);

    FillChar(Settings, SizeOf(Settings), 0);
    Settings.Version := 'TEST';
    Settings.Channel := 'stable';
    Settings.ActiveGameName := 'Fatekeeper';
    Settings.FpsOnly := True;
    GameCfgFile := GetGameConfigDir('Fatekeeper') + 'MangoHud.conf';
    ForceDirectories(ExtractFilePath(GameCfgFile));
    Settings.MangoHudCfgFile := GameCfgFile;

    AssertTrue('Per-game fps_only save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));

    Lines.LoadFromFile(GameCfgFile);
    AssertTrue('Game config has fps_only', Lines.IndexOf('fps_only') >= 0);

    Lines.LoadFromFile(FlatpakFile);
    AssertTrue('Steam Flatpak global config preserved', Lines.IndexOf('fps_limit=144') >= 0);
    AssertFalse('Steam Flatpak global config not overwritten with fps_only', Lines.IndexOf('fps_only') >= 0);
  finally
    Lines.Free;
  end;
end;

procedure TMangoHudFlatpakIsolationTests.TestGlobalSaveMirrorsToSteamFlatpak;
var
  Settings: TMangoHudSettings;
  ErrMsg, FlatpakDir, FlatpakFile, GlobalCfgFile: string;
  Lines: TStringList;
begin
  FlatpakDir := IncludeTrailingPathDelimiter(GetUserDir) + '.var/app/com.valvesoftware.Steam/config/MangoHud';
  ForceDirectories(FlatpakDir);
  FlatpakFile := FlatpakDir + '/MangoHud.conf';

  Lines := TStringList.Create;
  try
    FillChar(Settings, SizeOf(Settings), 0);
    Settings.Version := 'TEST';
    Settings.Channel := 'stable';
    Settings.ActiveGameName := '';
    Settings.LogFolder := IsolatedHome + '/.local/share/goverlay/logs/global';
    GlobalCfgFile := GetGameConfigDir('') + 'MangoHud.conf';
    ForceDirectories(ExtractFilePath(GlobalCfgFile));
    Settings.MangoHudCfgFile := GlobalCfgFile;

    AssertTrue('Global save succeeds', SaveMangoHudConfigCore(Settings, nil, ErrMsg));

    Lines.LoadFromFile(FlatpakFile);
    AssertTrue('Steam Flatpak global config updated with global output_folder',
      Pos('output_folder=' + Settings.LogFolder, Lines.Text) > 0);
  finally
    Lines.Free;
  end;
end;

initialization
  RegisterTest(TDriverPreferenceTests);
  RegisterTest(TOptiScalerIniTests);
  RegisterTest(TSandboxIsolationTests);
  RegisterTest(TVkSumiLogicTests);
  RegisterTest(TVkBasaltLogicTests);
  RegisterTest(TGpuNameExtractionTests);
  RegisterTest(TMangoHudGpuListTests);
  RegisterTest(TMangoHudFlatpakIsolationTests);
  RegisterTest(TMangoHudColorParsingTests);
  RegisterTest(TClearConfigTests);
  RegisterTest(TMakoLogicTests);
  RegisterTest(TLsfgVkManifestTests);
  RegisterTest(TBgmodSupervisorTests);
  RegisterTest(TReShadeLogicTests);
  RegisterTest(TSyncGameWrapperBinariesTests);
  RegisterTest(TBgmodSelfUpdateTests);
  RegisterTest(TRuntimeUpdateDowngradeTests);
  RegisterTest(TShellQuoteTests);
  RegisterTest(TRDNAArchitectureTests);
  RegisterTest(TMangoHudBlacklistSyncTests);
  RegisterTest(TGoverlayLogicTests);

end.
