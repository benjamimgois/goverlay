unit logic_test_cases;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry;

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
    procedure TestIsDlssNrInstalledFallbackArchitecture;
    procedure TestDlssNrArchitecturePathResolution;
    procedure TestExtractDlssNrModelTargetsRequestedArch;
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

  TBgmodSupervisorTests = class(TTestCase)
  public
    procedure EnsureBgmodBinary;
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
  end;

  TReShadeLogicTests = class(TTestCase)
  published
    procedure TestUnixPathToWinePath;
    procedure TestReShadeDirectoryLayout;
    procedure TestReShadeIniPathFormatting;
    procedure TestReShadeInstalledVersionFallbackAndMetadata;
    procedure TestParseReShadeMeHtml;
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

implementation

uses
  themeunit, configfile, configkeys, test_isolation, overlay_config, IniFiles, optiscaler_update, apputils, bgmod_resources, Process, BaseUnix, systemdetector;

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
    AssertTrue('Model = small present', Pos('Model = small', Lines.Text) > 0);
    AssertTrue('model_scale = 1.0 present', Pos('model_scale = 1.0', Lines.Text) > 0);
    AssertTrue('Preprocess Enabled = 1 present', Pos('Enabled = 1', Lines.Text) > 0);
    AssertTrue('passes = 3 present', Pos('passes = 3', Lines.Text) > 0);
    AssertTrue('run_before_sr = 1 present', Pos('run_before_sr = 1', Lines.Text) > 0);
    AssertTrue('skin_protection = 1 present', Pos('skin_protection = 1', Lines.Text) > 0);
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
  MarkerPath: string;

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

  // Assert GOVERLAY_VKSUMI is 0 and GOVERLAY_VKBASALT is preserved as 1
  Ini := TIniFile.Create(BgmodConfPath);
  try
    AssertEquals('GOVERLAY_VKSUMI is 0 when all sliders at default', '0', Ini.ReadString('Config', 'GOVERLAY_VKSUMI', ''));
    AssertEquals('GOVERLAY_VKBASALT remains untouched as 1', '1', Ini.ReadString('Config', 'GOVERLAY_VKBASALT', ''));
  finally
    Ini.Free;
  end;

  // Assert vkSumi.conf has enabled = false
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(Settings.SumiCfgFile);
    AssertTrue('enabled = false in vkSumi.conf when default', Pos('enabled     = false', Lines.Text) > 0);
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

procedure TReShadeLogicTests.TestUnixPathToWinePath;
begin
  AssertEquals('Empty path', '', UnixPathToWinePath(''));
  AssertEquals('Root path', 'Z:\', UnixPathToWinePath('/'));
  AssertEquals('Standard path', 'Z:\home\user\.local\share\goverlay\reshade\Shaders',
    UnixPathToWinePath('/home/user/.local/share/goverlay/reshade/Shaders'));
  AssertEquals('Trailing slash preserved as backslash', 'Z:\opt\games\',
    UnixPathToWinePath('/opt/games/'));
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
  ShadersDir, WineShaders, EffectPaths, TexturePaths: string;
begin
  ShadersDir := '/home/user/.local/share/goverlay/reshade/Shaders';
  WineShaders := UnixPathToWinePath(ShadersDir);
  EffectPaths := '.\,' + WineShaders + '\**';
  TexturePaths := '.\,' + WineShaders + '\**';

  AssertEquals('EffectSearchPaths format', '.\,Z:\home\user\.local\share\goverlay\reshade\Shaders\**', EffectPaths);
  AssertEquals('TextureSearchPaths format', '.\,Z:\home\user\.local\share\goverlay\reshade\Shaders\**', TexturePaths);
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
end;

initialization
  RegisterTest(TDriverPreferenceTests);
  RegisterTest(TOptiScalerIniTests);
  RegisterTest(TSandboxIsolationTests);
  RegisterTest(TVkSumiLogicTests);
  RegisterTest(TVkBasaltLogicTests);
  RegisterTest(TGpuNameExtractionTests);
  RegisterTest(TMangoHudGpuListTests);
  RegisterTest(TClearConfigTests);
  RegisterTest(TMakoLogicTests);
  RegisterTest(TBgmodSupervisorTests);
  RegisterTest(TReShadeLogicTests);
  RegisterTest(TSyncGameWrapperBinariesTests);
  RegisterTest(TBgmodSelfUpdateTests);
  RegisterTest(TRuntimeUpdateDowngradeTests);
  RegisterTest(TShellQuoteTests);
  RegisterTest(TRDNAArchitectureTests);

end.
