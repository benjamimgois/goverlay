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

implementation

uses
  themeunit, configfile, test_isolation, overlay_config, IniFiles, optiscaler_update;

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
    AssertTrue('Remote version is v3.x or higher', Pos('3.', Ver) > 0);
    AssertTrue('Download URL targets native linux archive', Pos('-linux.tar.xz', Url) > 0);
    AssertFalse('Download URL strictly excludes flatpaks', Pos('flatpak', LowerCase(Url)) > 0);
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
  RegisterTest(TClearConfigTests);
  RegisterTest(TMakoLogicTests);

end.
