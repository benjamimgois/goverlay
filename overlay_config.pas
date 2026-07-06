unit overlay_config;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, FileUtil, StrUtils, Types, Graphics, configfile, configmanager, overlay_utils, configkeys, bgmod_resources, optiscaler_update, systemdetector, apputils;

type
  TVkBasaltSettings = record
    BasaltFolder: string;
    BasaltCfgFile: string;
    Version: string;
    Channel: string;
    ToggleKey: string;
    CasPosition: Integer;
    FxaaPosition: Integer;
    SmaaPosition: Integer;
    DlsPosition: Integer;
    ReshadeEffects: TStrings;
    ActiveGameName: string;
  end;

  TVkSumiSettings = record
    SumiFolder: string;
    SumiCfgFile: string;
    Version: string;
    Channel: string;
    Enabled: Boolean;
    ToggleKeys: string;
    TrackbarPositions: array[0..14] of Integer;
    ActiveGameName: string;
  end;

  TOptiScalerSettings = record
    ActiveGameName: string;
    Version: string;
    Channel: string;
    FilenameItemIndex: Integer;
    EmuFp8Checked: Boolean;
    ShortcutKey: string;
    MenuScalePosition: Integer;
    OverrideChecked: Boolean;
    SpoofChecked: Boolean;
    FsrversionItemIndex: Integer;
    OptipatcherChecked: Boolean;
    OptVersionItemIndex: Integer;
    
    // FakeNvapi options
    ForceReflexChecked: Boolean;
    ReflexItemIndex: Integer;
    ForceLatencyFlexChecked: Boolean;
    LatencyFlexItemIndex: Integer;
    TraceLogChecked: Boolean;
  end;

  TMangoHudSettings = record
    MangoHudCfgFile: string;
    Version: string;
    Channel: string;
    ActiveGameName: string;

    // Visual Tab
    HudTitle: string;
    Horizontal: Boolean;
    TranspPosition: Integer;
    RoundCorners: Boolean;
    HudBackgroundColor: TColor;
    FontText: string;
    FontSize: Integer;
    FontColor: TColor;
    Position: string;
    OffsetX: Integer;
    OffsetY: Integer;
    ToggleHudKey: string;
    HideHud: Boolean;
    HudCompact: Boolean;
    HorizontalStretch: Boolean;
    PciDevIndex: Integer;
    PciDevCount: Integer;
    PciDevText: string;
    TableColumns: string;

    // Metrics Tab - GPU
    GpuText: string;
    GpuAvgLoad: Boolean;
    GpuLoadColorChecked: Boolean;
    GpuLoadColors: array[0..2] of TColor;
    VramUsage: Boolean;
    VramColor: TColor;
    GpuFreq: Boolean;
    GpuMemFreq: Boolean;
    GpuTemp: Boolean;
    GpuMemTemp: Boolean;
    GpuJuncTemp: Boolean;
    GpuFan: Boolean;
    GpuPower: Boolean;
    GpuPowerLimit: Boolean;
    GpuEfficiency: Boolean;
    GpuFramesJouleCaption: string;
    GpuVoltage: Boolean;
    GpuThrottling: Boolean;
    GpuThrottlingGraph: Boolean;
    GpuModel: Boolean;
    VulkanDriver: Boolean;
    GpuColor: TColor;

    // Metrics Tab - CPU
    CpuText: string;
    CpuAvgLoad: Boolean;
    CpuLoadCore: Boolean;
    CoreLoadTypeCaption: string;
    CpuLoadColorChecked: Boolean;
    CpuLoadColors: array[0..2] of TColor;
    CpuFreq: Boolean;
    CpuTemp: Boolean;
    CpuPower: Boolean;
    CpuEfficiency: Boolean;
    CpuCoreType: Boolean;
    CpuColor: TColor;

    // Metrics Tab - Memory/IO
    DiskIo: Boolean;
    IoColor: TColor;
    SwapUsage: Boolean;
    RamUsage: Boolean;
    RamColor: TColor;
    RamTemp: Boolean;
    ProcMem: Boolean;
    ProcVram: Boolean;

    // Metrics Tab - Other
    Battery: Boolean;
    BatteryColor: TColor;
    BatteryWatt: Boolean;
    BatteryTime: Boolean;
    Device: Boolean;
    Fps: Boolean;
    FpsAvg: Boolean;
    FpsAvgCaption: string;
    FrametimeGraph: Boolean;
    FrametimeGraphColor: TColor;
    FrametimeTypeCaption: string;
    FrameCount: Boolean;
    EngineVersion: Boolean;
    EngineColor: TColor;
    EngineShort: Boolean;
    Arch: Boolean;
    Wine: Boolean;
    WineColor: TColor;
    Winesync: Boolean;

    // Performance Tab
    ShowFpsLim: Boolean;
    FpsLimMetItemIndex: Integer;
    FpsLimToggleText: string;
    FpsLimitText: string;
    Resolution: Boolean;
    RefreshRate: Boolean;
    Fcat: Boolean;
    FexStats: Boolean;
    Fsr: Boolean;
    Hdr: Boolean;
    Vps: Boolean;
    Fahrenheit: Boolean;
    GamemodeStatus: Boolean;
    VkbasaltStatus: Boolean;
    VsyncItemIndex: Integer;
    GlvsyncItemIndex: Integer;
    FilterItemIndex: Integer;
    AfPosition: Integer;
    MipmapPosition: Integer;
    FpsColorChecked: Boolean;
    FpsColors: array[0..2] of TColor;
    FpsColorValues: array[0..1] of Integer;

    // Extras Tab
    DistroInfo: Boolean;
    DisplayServer: Boolean;
    Time: Boolean;
    HudVersion: Boolean;
    Media: Boolean;
    MediaColor: TColor;
    Network: Boolean;
    NetworkItemIndex: Integer;
    NetworkInterfaceText: string;
    LogFolder: string;
    Duration: Integer;
    Delay: Integer;
    Interval: Integer;
    LogToggleText: string;
    Versioning: Boolean;
    AutoUpload: Boolean;
  end;

function SanitizeFileName(const AName: string): string;
function GetGameConfigDir(const AGameName: string): string;

function SaveVkBasaltConfig(const Settings: TVkBasaltSettings; out ErrMsg: string): Boolean;
function SaveVkSumiConfig(const Settings: TVkSumiSettings; out ErrMsg: string): Boolean;
function SaveOptiScalerConfigCore(const Settings: TOptiScalerSettings; const EnvGamemodeRun, LaunchCommandSuffix: string; GeneralCheckbox1Checked, ActiveGameIsNonSteam, ActiveGameIsNonSteamLocal: Boolean; out ErrMsg: string; out LaunchCommand: string): Boolean;

function LoadVkBasaltConfig(const CfgFile: string; const AvEffectsList, ActEffectsList: TStrings; out Settings: TVkBasaltSettings): Boolean;
function LoadVkSumiConfig(const CfgFile: string; out Settings: TVkSumiSettings): Boolean;
function LoadOptiScalerConfig(const ActiveGameName: string; out Settings: TOptiScalerSettings): Boolean;

function SaveMangoHudConfigCore(const Settings: TMangoHudSettings; const AvFonts: TStrings; out ErrMsg: string): Boolean;
procedure EnsureDefaultConfigFiles(const GVersion, GChannel, VkbToggleKeyText: string);

implementation

function SanitizeFileName(const AName: string): string;
var
  i: Integer;
begin
  Result := AName;
  for i := 1 to Length(Result) do
    if Result[i] in ['/', '\', ':', '*', '?', '"', '<', '>', '|', ''''] then
      Result[i] := '_';
end;

function GetGameConfigDir(const AGameName: string): string;
var
  GameDirName: string;
begin
  if AGameName = '' then
    GameDirName := 'global'
  else
    GameDirName := SanitizeFileName(AGameName);

  Result := IncludeTrailingPathDelimiter(TConfigManager.GetHostDataDir) +
            'goverlay/gameconfig/' + GameDirName + '/';
end;

function SaveVkBasaltConfig(const Settings: TVkBasaltSettings; out ErrMsg: string): Boolean;
var
  RepoDir, RelPath, EffectName, EffectKey, FullPath, EffectsLine: string;
  TexPath, IncPath: string;
  Lines: TStringList;
  Sharp: Double;
  FxaaQuality: Double;
  SmaaCorner: Double;
  DlsSharp: Double;
  FS: TFormatSettings;
  i: Integer;
  Ini: TIniFile;
  FGModFilePath: string;
begin
  Result := False;
  ErrMsg := '';

  if Settings.BasaltFolder = '' then
  begin
    ErrMsg := 'vkBasalt directory not found';
    Exit;
  end;

  RepoDir := IncludeTrailingPathDelimiter(Settings.BasaltFolder) + 'reshade-shaders';
  Lines := TStringList.Create;
  try
    Lines.Add('################### File Generated by Goverlay ' + Settings.Version + ' ' + Settings.Channel + ' ###################');
    Lines.Add('toggleKey = ' + Settings.ToggleKey);
    Lines.Add('enableOnLaunch = True');
    Lines.Add('');
    
    // --- create effects list" ---
    EffectsLine := '';
    // 1) CAS (if active)
    if Settings.CasPosition >= 1 then
      EffectsLine := EffectsLine + 'cas';
    // 2) FXAA (if active)
    if Settings.FxaaPosition >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'fxaa';
    end;
    // 3) SMAA (if active)
    if Settings.SmaaPosition >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'smaa';
    end;
    // 4) DLS (if active)
    if Settings.DlsPosition >= 1 then
    begin
      if EffectsLine <> '' then
        EffectsLine := EffectsLine + ':';
      EffectsLine := EffectsLine + 'dls';
    end;
    // 5) reshade effects on the list
    if Assigned(Settings.ReshadeEffects) then
    begin
      for i := 0 to Settings.ReshadeEffects.Count - 1 do
      begin
        RelPath := Settings.ReshadeEffects[i];
        EffectName := ChangeFileExt(ExtractFileName(RelPath), '');
        if EffectsLine <> '' then
          EffectsLine := EffectsLine + ':';
        EffectsLine := EffectsLine + EffectName;
      end;
    end;
    if EffectsLine <> '' then
      Lines.Add('effects = ' + EffectsLine);
    Lines.Add('');
    
    // --- CAS adjustment if active ---
    if Settings.CasPosition >= 1 then
    begin
      Sharp := Settings.CasPosition / 10.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('casSharpness = ' + FloatToStrF(Sharp, ffFixed, 3, 1, FS));
    end;
    // --- FXAA adjustment if active ---
    if Settings.FxaaPosition >= 1 then
    begin
      FxaaQuality := Settings.FxaaPosition / 10.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('fxaaQualitySubpix = ' + FloatToStrF(FxaaQuality, ffFixed, 3, 1, FS));
    end;
    // --- SMAA adjustment if active ---
    if Settings.SmaaPosition >= 1 then
    begin
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      SmaaCorner := 25.0 * (Settings.SmaaPosition - 1) / 9.0;
      Lines.Add('smaaCornerRounding = ' + FloatToStrF(SmaaCorner, ffFixed, 3, 1, FS));
      Lines.Add('smaaThreshold = ' + FloatToStrF(0.1 - 0.05 * (Settings.SmaaPosition - 1) / 9.0, ffFixed, 3, 2, FS));
      Lines.Add('smaaMaxSearchSteps = ' + IntToStr(Round(16 + 16 * (Settings.SmaaPosition - 1) / 9.0)));
      Lines.Add('smaaMaxSearchStepsDiag = ' + IntToStr(Round(8 + 8 * (Settings.SmaaPosition - 1) / 9.0)));
    end;
    // --- DLS adjustment if active ---
    if Settings.DlsPosition >= 1 then
    begin
      DlsSharp := (Settings.DlsPosition - 1) / 9.0;
      FS := DefaultFormatSettings;
      FS.DecimalSeparator := '.';
      Lines.Add('dlsSharpness = ' + FloatToStrF(DlsSharp, ffFixed, 3, 1, FS));
    end;
    // --- Map reshade effects ---
    if Assigned(Settings.ReshadeEffects) then
    begin
      for i := 0 to Settings.ReshadeEffects.Count - 1 do
      begin
        RelPath := Settings.ReshadeEffects[i];
        EffectName := ChangeFileExt(ExtractFileName(RelPath), '');
        EffectKey := EffectName;
        FullPath := IncludeTrailingPathDelimiter(RepoDir) + RelPath;
        Lines.Add(EffectKey + ' = ' + FullPath);
      end;
    end;
    Lines.Add('');
    TexPath := IncludeTrailingPathDelimiter(RepoDir) + 'Textures';
    IncPath := IncludeTrailingPathDelimiter(RepoDir) + 'Shaders';
    Lines.Add('reshadeTexturePath = ' + TexPath);
    Lines.Add('reshadeIncludePath = ' + IncPath);
    
    // --- Save ---
    if not DirectoryExists(ExtractFileDir(Settings.BasaltCfgFile)) then
      ForceDirectories(ExtractFileDir(Settings.BasaltCfgFile));
    if FileExists(Settings.BasaltCfgFile) then
      DeleteFile(Settings.BasaltCfgFile);
    Lines.SaveToFile(Settings.BasaltCfgFile);

    // Update bgmod.conf with GOVERLAY_VKBASALT=1
    FGModFilePath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';

    ForceDirectories(ExtractFilePath(FGModFilePath));
    Ini := TIniFile.Create(FGModFilePath);
    try
      Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '1');
    finally
      Ini.Free;
    end;

    Result := True;
  finally
    Lines.Free;
  end;
end;

function SaveVkSumiConfig(const Settings: TVkSumiSettings; out ErrMsg: string): Boolean;
const
  KEYS: array[0..14] of string = (
    'brightness', 'contrast', 'exposure', 'gamma',
    'saturation', 'vibrance', 'hue_deg', 'temperature', 'tint',
    'red_gain', 'green_gain', 'blue_gain',
    'shadows', 'midtones', 'highlights'
  );
var
  Lines: TStringList;
  FS: TFormatSettings;
  Val: Double;
  i: Integer;
  FGModFilePath: string;
  Ini: TIniFile;
begin
  Result := False;
  ErrMsg := '';
  
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Lines := TStringList.Create;
  try
    Lines.Add('################### File Generated by Goverlay ' + Settings.Version + ' ' + Settings.Channel + ' ###################');
    Lines.Add('# vkSumi color grading');
    Lines.Add('#');
    Lines.Add('# Lives at:');
    Lines.Add('#   ~/.config/vkSumi/vkSumi.conf              global default');
    Lines.Add('#   ~/.config/vkSumi/games/<exe>.conf         per-game overrides (auto-created)');
    Lines.Add('#');
    Lines.Add('# Per-game files merge on top of the global one, only set what you wanna change.');
    Lines.Add('# Save and the layer reloads via inotify, no game restart needed.');
    Lines.Add('#');
    Lines.Add('# 0 = no change for every knob.');
    Lines.Add('# + = more / brighter.');
    Lines.Add('# - = less / darker.');
    Lines.Add('');
    Lines.Add('PER_GAME_CONFIG_CREATION = false');
    Lines.Add('');
    
    Lines.Add('enabled     = ' + LowerCase(BoolToStr(Settings.Enabled, True)));
    if Settings.ToggleKeys <> '' then
      Lines.Add('toggle_keys = ' + Settings.ToggleKeys + '    # in-game hotkey, X11 + XWayland (Wine/Proton)')
    else
      Lines.Add('toggle_keys = Shift_R+F9    # in-game hotkey, X11 + XWayland (Wine/Proton)');
    Lines.Add('');
    
    Lines.Add('# tone');
    for i := 0 to 3 do
    begin
      if i = 2 then // exposure — -3..3
        Val := (Settings.TrackbarPositions[i] - 300) / 100
      else
        Val := (Settings.TrackbarPositions[i] - 100) / 100;
      Lines.Add(KEYS[i] + ' = ' + FormatFloat('0.0', Val, FS));
    end;
    Lines.Add('');
    
    Lines.Add('# color');
    for i := 4 to 8 do
    begin
      if i = 6 then // hue_deg — -180..180
        Val := Settings.TrackbarPositions[i] - 180
      else
        Val := (Settings.TrackbarPositions[i] - 100) / 100;
      Lines.Add(KEYS[i] + ' = ' + FormatFloat('0.0', Val, FS));
    end;
    Lines.Add('');
    
    Lines.Add('# per-channel gain');
    for i := 9 to 11 do
    begin
      Val := (Settings.TrackbarPositions[i] - 100) / 100;
      Lines.Add(KEYS[i] + ' = ' + FormatFloat('0.0', Val, FS));
    end;
    Lines.Add('');
    
    Lines.Add('# log-grading');
    for i := 12 to 14 do
    begin
      Val := (Settings.TrackbarPositions[i] - 100) / 100;
      Lines.Add(KEYS[i] + ' = ' + FormatFloat('0.0', Val, FS));
    end;

    if not DirectoryExists(ExtractFileDir(Settings.SumiCfgFile)) then
      ForceDirectories(ExtractFileDir(Settings.SumiCfgFile));
    if FileExists(Settings.SumiCfgFile) then
      DeleteFile(Settings.SumiCfgFile);
    Lines.SaveToFile(Settings.SumiCfgFile);

    // Update bgmod.conf with ENABLE_VKSUMI setting
    FGModFilePath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';

    ForceDirectories(ExtractFilePath(FGModFilePath));
    Ini := TIniFile.Create(FGModFilePath);
    try
      if Settings.Enabled then
      begin
        Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '1');
        Ini.WriteString('Config', 'ENABLE_VKSUMI', '1');
      end
      else
      begin
        Ini.WriteString('Config', 'GOVERLAY_VKBASALT', '0');
        Ini.WriteString('Config', 'ENABLE_VKSUMI', '0');
      end;
    finally
      Ini.Free;
    end;

    Result := True;
  finally
    Lines.Free;
  end;
end;

function SaveOptiScalerConfigCore(const Settings: TOptiScalerSettings; const EnvGamemodeRun, LaunchCommandSuffix: string; GeneralCheckbox1Checked, ActiveGameIsNonSteam, ActiveGameIsNonSteamLocal: Boolean; out ErrMsg: string; out LaunchCommand: string): Boolean;
var
  SelectedDllName, DllNameWithoutExt: string;
  OptiScalerIniPath: string;
  OptiCfg: TConfigFile;
  SelectedShortcutKey, ScaleValue: string;
  ScaleFloat: Double;
  FS: TFormatSettings;
  OverrideNvapiDllValue: string;
  DxgiValue: string;
  LoadAsiPluginsValue: string;
  Fsr4UpdateValue: string;
  FakeNvapiIniPath: string;
  FakeCfg: TConfigFile;
  ForceReflexValue: string;
  ForceLatencyFlexValue, LatencyFlexModeValue: string;
  EnableTraceLogsValue: string;
  FGModPath, FGModDestPath: string;
  Ini: TIniFile;
  FGModFilePath: string;
  IsStable: Boolean;
  ConfigConf: string;
  VarsPath, CacheVarsPath, TargetFsrVersion: string;
  VarsList, CacheList: TStringList;
  VarsIdx, SepPos: Integer;
  Key, Value: string;
  Found: Boolean;


begin
  Result := False;
  ErrMsg := '';
  LaunchCommand := '';

  // Get the bgmod.conf path
  FGModFilePath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';

  // Get selected DLL name from index
  case Settings.FilenameItemIndex of
    0: SelectedDllName := OPTI_DLL_DXGI;
    1: SelectedDllName := OPTI_DLL_VERSION;
    2: SelectedDllName := OPTI_DLL_DBGHELP;
    3: SelectedDllName := OPTI_DLL_D3D12;
    4: SelectedDllName := OPTI_DLL_WININET;
    5: SelectedDllName := OPTI_DLL_WINHTTP;
    6: SelectedDllName := OPTI_DLL_WINMM;
    7: SelectedDllName := OPTI_DLL_ASI;
  else
    SelectedDllName := OPTI_DLL_DXGI;
  end;

  DllNameWithoutExt := ChangeFileExt(SelectedDllName, '');

  ForceDirectories(ExtractFilePath(FGModFilePath));
  Ini := TIniFile.Create(FGModFilePath);
  try
    Ini.WriteString('Config', 'GOVERLAY_OPTISCALER', '1');
    Ini.WriteString('Config', 'DLL', SelectedDllName);
    Ini.WriteString('Config', 'PRESERVE_INI', 'true');
    Ini.WriteInteger('Config', 'OPT_CHANNEL', Settings.OptVersionItemIndex);

    if Settings.EmuFp8Checked then
      Ini.WriteString('Env', 'DXIL_SPIRV_CONFIG', 'wmma_rdna3_workaround')
    else
      Ini.DeleteKey('Env', 'DXIL_SPIRV_CONFIG');
  finally
    Ini.Free;
  end;



  // Get OptiScaler.ini file path
  OptiScalerIniPath := GetGameConfigDir(Settings.ActiveGameName) + 'OptiScaler.ini';

  SelectedShortcutKey := Trim(Settings.ShortcutKey);
  if SelectedShortcutKey = '' then
    SelectedShortcutKey := 'auto';

  // Calculate Scale value (divide by 10)
  ScaleFloat := Settings.MenuScalePosition / 10.0;
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  ScaleValue := FloatToStrF(ScaleFloat, ffFixed, 3, 1, FS);

  if Settings.OverrideChecked then
    OverrideNvapiDllValue := 'true'
  else
    OverrideNvapiDllValue := 'auto';

  if Settings.SpoofChecked then
    DxgiValue := 'auto'
  else
    DxgiValue := 'false';

  if Settings.FsrversionItemIndex = 0 then
    Fsr4UpdateValue := 'true'
  else
    Fsr4UpdateValue := 'auto';

  if Settings.OptipatcherChecked then
    LoadAsiPluginsValue := 'true'
  else
    LoadAsiPluginsValue := 'auto';

  // Update OptiScaler.ini using TConfigFile wrapper
  OptiCfg := TConfigFile.Create;
  try
    if OptiCfg.Load(OptiScalerIniPath) then
    begin
      OptiCfg.SetValue(OPTI_KEY_SHORTCUT, SelectedShortcutKey, OPTI_INI_SECTION_MENU);
      OptiCfg.SetValue(OPTI_KEY_SCALE, ScaleValue, OPTI_INI_SECTION_MENU);
      OptiCfg.SetValue(OPTI_KEY_OVERRIDE_NVAPI, OverrideNvapiDllValue);
      OptiCfg.SetValue(OPTI_KEY_DXGI, DxgiValue);
      OptiCfg.SetValue(OPTI_KEY_LOAD_ASI, LoadAsiPluginsValue);
      OptiCfg.SetValue(OPTI_KEY_FSR4_UPDATE, Fsr4UpdateValue);
      if Settings.FsrversionItemIndex = 0 then
        OptiCfg.SetValue('FsrAgilitySDKUpgrade=', 'true')
      else
        OptiCfg.SetValue('FsrAgilitySDKUpgrade=', 'auto');
      OptiCfg.Save;
    end;
  finally
    OptiCfg.Free;
  end;



  // ##### Now modify fakenvapi.ini file #####
  begin
    FakeNvapiIniPath := GetGameConfigDir(Settings.ActiveGameName) + 'fakenvapi.ini';

    if Settings.ForceReflexChecked then
    begin
      case Settings.ReflexItemIndex of
        0: ForceReflexValue := '0';
        1: ForceReflexValue := '1';
        2: ForceReflexValue := '2';
      end;
    end
    else
      ForceReflexValue := '0';

    if Settings.ForceLatencyFlexChecked then
    begin
      ForceLatencyFlexValue := '1';
      case Settings.LatencyFlexItemIndex of
        0: LatencyFlexModeValue := '0';
        1: LatencyFlexModeValue := '1';
        2: LatencyFlexModeValue := '2';
      else
        LatencyFlexModeValue := '0';
      end;
    end
    else
    begin
      ForceLatencyFlexValue := '0';
      LatencyFlexModeValue := '0';
    end;

    if Settings.TraceLogChecked then
      EnableTraceLogsValue := '1'
    else
      EnableTraceLogsValue := '0';

    FakeCfg := TConfigFile.Create;
    try
      if FakeCfg.Load(FakeNvapiIniPath) then
      begin
        if Settings.ForceReflexChecked then
          FakeCfg.SetValue(FAKE_KEY_FORCE_REFLEX, ForceReflexValue)
        else
          FakeCfg.DeleteKey(FAKE_KEY_FORCE_REFLEX);
        FakeCfg.SetValue(FAKE_KEY_FORCE_LATENCY, ForceLatencyFlexValue);
        FakeCfg.SetValue(FAKE_KEY_LATENCY_MODE, LatencyFlexModeValue);
        FakeCfg.SetValue(FAKE_KEY_TRACE_LOGS, EnableTraceLogsValue);
        
        if (not Settings.ForceReflexChecked or FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX)) and
           (not Settings.ForceLatencyFlexChecked or (FakeCfg.HasKey(FAKE_KEY_FORCE_LATENCY) and FakeCfg.HasKey(FAKE_KEY_LATENCY_MODE))) then
          FakeCfg.Save
        else
        begin
          if Settings.ForceReflexChecked and not FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX) then
            ErrMsg := ErrMsg + 'Warning: Could not find force_reflex line in fakenvapi.ini file' + LineEnding;
          if Settings.ForceLatencyFlexChecked and not FakeCfg.HasKey(FAKE_KEY_FORCE_LATENCY) then
            ErrMsg := ErrMsg + 'Warning: Could not find force_latencyflex line in fakenvapi.ini file' + LineEnding;
          if Settings.ForceLatencyFlexChecked and not FakeCfg.HasKey(FAKE_KEY_LATENCY_MODE) then
            ErrMsg := ErrMsg + 'Warning: Could not find latencyflex_mode line in fakenvapi.ini file' + LineEnding;
        end;
      end;
    finally
      FakeCfg.Free;
    end;


  end;

  // ##### Copy FSR4 DLL based on fsrversion selection #####
  // NOTE: the FSR library version (4.1 / 4.1.1) is written to goverlay.vars by
  // the OptiScaler install/update flow (UpdateButtonClick) using the value
  // fetched from vars.txt (fsrstable/fsredge). The FP8-vs-INT8 DLL choice is
  // persisted separately in OptiScaler.ini (FsrAgilitySDKUpgrade), so this
  // routine MUST NOT overwrite the fsrversion key in goverlay.vars — doing so
  // would clobber the real library version with "Latest"/"4.0.2c (INT8)" and
  // make the Software status card show the wrong value after a channel install.
  try
    FGModDestPath := ExcludeTrailingPathDelimiter(GetGameConfigDir(Settings.ActiveGameName));

    // Resolve correct cache directory based on OPT_CHANNEL of the game config
    IsStable := True;
    ConfigConf := IncludeTrailingPathDelimiter(FGModDestPath) + 'bgmod.conf';
    if FileExists(ConfigConf) then
    begin
      Ini := TIniFile.Create(ConfigConf);
      try
        IsStable := Ini.ReadInteger('Config', 'OPT_CHANNEL', 0) <> 1;
      finally
        Ini.Free;
      end;
    end;

    if IsStable then
      FGModPath := GetBGModOriginalPath
    else
      FGModPath := GetBGModOriginalEdgePath;

    case Settings.FsrversionItemIndex of
      0: // Latest (FP8)
        begin
          if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
            CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_LATEST' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                     IncludeTrailingPathDelimiter(FGModDestPath) + 'amd_fidelityfx_upscaler_dx12.dll');
        end;

      1: // 4.0.2c (INT8)
        begin
          if FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll') then
            CopyFile(IncludeTrailingPathDelimiter(FGModPath) + 'FSR4_INT8' + PathDelim + 'amd_fidelityfx_upscaler_dx12.dll',
                     IncludeTrailingPathDelimiter(FGModDestPath) + 'amd_fidelityfx_upscaler_dx12.dll');
        end;
    end;
  except
    on E: Exception do
      ErrMsg := ErrMsg + 'Warning: Could not copy FSR4 DLL: ' + E.Message + LineEnding;
  end;

  // Update fsrversion in goverlay.vars in the game configuration directory
  VarsPath := IncludeTrailingPathDelimiter(FGModDestPath) + 'goverlay.vars';
  VarsList := TStringList.Create;
  try
    // Try to load existing vars; if absent, copy/load from cache path
    if FileExists(VarsPath) then
      VarsList.LoadFromFile(VarsPath)
    else
    begin
      CacheVarsPath := IncludeTrailingPathDelimiter(FGModPath) + 'goverlay.vars';
      if FileExists(CacheVarsPath) then
        VarsList.LoadFromFile(CacheVarsPath);
    end;

    // Determine correct FSR version string to save
    if Settings.FsrversionItemIndex = 1 then
      TargetFsrVersion := '4.0.2c INT8'
    else
    begin
      // Read actual version from cache goverlay.vars
      TargetFsrVersion := '4.1'; // default fallback
      CacheVarsPath := IncludeTrailingPathDelimiter(FGModPath) + 'goverlay.vars';
      if FileExists(CacheVarsPath) then
      begin
        CacheList := TStringList.Create;
        try
          CacheList.LoadFromFile(CacheVarsPath);
          for VarsIdx := 0 to CacheList.Count - 1 do
          begin
            SepPos := Pos('=', CacheList[VarsIdx]);
            if SepPos > 0 then
            begin
              Key := Trim(Copy(CacheList[VarsIdx], 1, SepPos - 1));
              if SameText(Key, 'fsrversion') then
              begin
                TargetFsrVersion := Trim(Copy(CacheList[VarsIdx], SepPos + 1, Length(CacheList[VarsIdx])));
                Break;
              end;
            end;
          end;
        finally
          CacheList.Free;
        end;
      end;
    end;

    // Update fsrversion in the list
    Found := False;
    for VarsIdx := 0 to VarsList.Count - 1 do
    begin
      SepPos := Pos('=', VarsList[VarsIdx]);
      if SepPos > 0 then
      begin
        Key := Trim(Copy(VarsList[VarsIdx], 1, SepPos - 1));
        if SameText(Key, 'fsrversion') then
        begin
          VarsList[VarsIdx] := 'fsrversion=' + TargetFsrVersion;
          Found := True;
          Break;
        end;
      end;
    end;

    if not Found then
      VarsList.Add('fsrversion=' + TargetFsrVersion);

    ForceDirectories(FGModDestPath);
    VarsList.SaveToFile(VarsPath);
  finally
    VarsList.Free;
  end;

  // Build launch command
  if Settings.ActiveGameName <> '' then
  begin
    if ActiveGameIsNonSteam then
      LaunchCommand := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod '
    else
      LaunchCommand := '"' + GetGameConfigDir(Settings.ActiveGameName) + 'bgmod" ';
  end
  else
    LaunchCommand := '"' + GetGameConfigDir('') + 'bgmod" ';

  if GeneralCheckbox1Checked then
    LaunchCommand := LaunchCommand + EnvGamemodeRun + ' ';

  if not ( (Settings.ActiveGameName <> '') and ActiveGameIsNonSteamLocal ) then
    LaunchCommand := LaunchCommand + LaunchCommandSuffix;

  Result := True;
end;

function LoadVkBasaltConfig(const CfgFile: string; const AvEffectsList, ActEffectsList: TStrings; out Settings: TVkBasaltSettings): Boolean;
var
  Value, EffectsStr, FullEffectPath: string;
  EffectsList: TStringArray;
  j, k: Integer;
  FloatValue: Double;
  FS: TFormatSettings;
  Cfg: TConfigFile;
begin
  Result := False;
  FillChar(Settings, SizeOf(Settings), 0);
  
  if not FileExists(CfgFile) then
    Exit;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Cfg := TConfigFile.Create;
  try
    if not Cfg.Load(CfgFile) then Exit;

    Settings.BasaltCfgFile := CfgFile;
    ActEffectsList.Clear;

    EffectsStr := Cfg.GetValue('effects =', '');
    if EffectsStr <> '' then
    begin
      EffectsList := SplitString(EffectsStr, ':');
      for j := Low(EffectsList) to High(EffectsList) do
      begin
        EffectsList[j] := Trim(EffectsList[j]);
        if SameText(EffectsList[j], 'cas') then
        begin
          if Settings.CasPosition = 0 then
            Settings.CasPosition := 5;
        end
        else if SameText(EffectsList[j], 'fxaa') then
        begin
          if Settings.FxaaPosition = 0 then
            Settings.FxaaPosition := 5;
        end
        else if SameText(EffectsList[j], 'smaa') then
        begin
          if Settings.SmaaPosition = 0 then
            Settings.SmaaPosition := 5;
        end
        else if SameText(EffectsList[j], 'dls') then
        begin
          if Settings.DlsPosition = 0 then
            Settings.DlsPosition := 5;
        end
        else if EffectsList[j] <> '' then
        begin
          FullEffectPath := '';
          for k := 0 to AvEffectsList.Count - 1 do
          begin
            if SameText(ChangeFileExt(ExtractFileName(AvEffectsList[k]), ''), EffectsList[j]) then
            begin
              FullEffectPath := AvEffectsList[k];
              Break;
            end;
          end;
          if FullEffectPath = '' then
            FullEffectPath := EffectsList[j];
          if ActEffectsList.IndexOf(FullEffectPath) = -1 then
            ActEffectsList.Add(FullEffectPath);
        end;
      end;
    end;

    Value := Cfg.GetValue('casSharpness =', '');
    if TryStrToFloat(Value, FloatValue, FS) then
      Settings.CasPosition := Round(FloatValue * 10);

    Value := Cfg.GetValue('fxaaQualitySubpix =', '');
    if TryStrToFloat(Value, FloatValue, FS) then
      Settings.FxaaPosition := Round(FloatValue * 10);

    Value := Cfg.GetValue('smaaCornerRounding =', '');
    if TryStrToFloat(Value, FloatValue, FS) then
      Settings.SmaaPosition := Round(FloatValue / 25 * 9) + 1;

    Value := Cfg.GetValue('dlsSharpness =', '');
    if TryStrToFloat(Value, FloatValue, FS) then
      Settings.DlsPosition := Round(FloatValue * 9) + 1;

    Value := Cfg.GetValue('toggleKey =', '');
    if Value <> '' then
      Settings.ToggleKey := Value;

    Result := True;
  finally
    Cfg.Free;
  end;
end;

function LoadVkSumiConfig(const CfgFile: string; out Settings: TVkSumiSettings): Boolean;
const
  KEYS: array[0..14] of string = (
    'brightness', 'contrast', 'exposure', 'gamma',
    'saturation', 'vibrance', 'hue_deg', 'temperature', 'tint',
    'red_gain', 'green_gain', 'blue_gain',
    'shadows', 'midtones', 'highlights'
  );
  DEFAULTS: array[0..14] of Integer = (
    100, 100, 300, 100,
    100, 100, 180, 100, 100,
    100, 100, 100,
    100, 100, 100
  );
var
  Cfg: TConfigFile;
  i: Integer;
  FS: TFormatSettings;
  ValStr: string;
  Val: Double;
  PosVal: Integer;
begin
  Result := False;
  FillChar(Settings, SizeOf(Settings), 0);
  Settings.SumiCfgFile := CfgFile;
  
  // Set default values first
  Settings.Enabled := True;
  Settings.ToggleKeys := 'Shift_R+F9';
  for i := 0 to 14 do
    Settings.TrackbarPositions[i] := DEFAULTS[i];

  if not FileExists(CfgFile) then
  begin
    Result := True;
    Exit;
  end;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  Cfg := TConfigFile.Create;
  try
    if Cfg.Load(CfgFile) then
    begin
      Settings.Enabled := Cfg.GetBool('enabled =', True);
      
      ValStr := Cfg.GetValue('toggle_keys =', 'Shift_R+F9');
      i := Pos('#', ValStr);
      if i > 0 then ValStr := Copy(ValStr, 1, i - 1);
      i := Pos(';', ValStr);
      if i > 0 then ValStr := Copy(ValStr, 1, i - 1);
      Settings.ToggleKeys := Trim(ValStr);

      for i := 0 to 14 do
      begin
        ValStr := Cfg.GetValue(KEYS[i] + ' =', '');
        if ValStr <> '' then
        begin
          if TryStrToFloat(ValStr, Val, FS) then
          begin
            if i = 2 then
              PosVal := Round(Val * 100) + 300
            else if i = 6 then
              PosVal := Round(Val) + 180
            else
              PosVal := Round(Val * 100) + 100;

            // Clamp to Min/Max
            if i = 2 then // Exposure: 0..600
            begin
              if PosVal < 0 then PosVal := 0;
              if PosVal > 600 then PosVal := 600;
            end
            else if i = 6 then // Hue: 0..360
            begin
              if PosVal < 0 then PosVal := 0;
              if PosVal > 360 then PosVal := 360;
            end
            else // Others: 0..200
            begin
              if PosVal < 0 then PosVal := 0;
              if PosVal > 200 then PosVal := 200;
            end;

            Settings.TrackbarPositions[i] := PosVal;
          end;
        end;
      end;
      Result := True;
    end;
  finally
    Cfg.Free;
  end;
end;

function LoadOptiScalerConfig(const ActiveGameName: string; out Settings: TOptiScalerSettings): Boolean;
var
  OptiCfg, FakeCfg: TConfigFile;
  OptiScalerIniPath, FakeNvapiIniPath, ConfigPath, VarsPath: string;
  Value, DllName, FsrVer, TrimmedLine, Key, ValStr: string;
  FloatValue: Double;
  FS: TFormatSettings;
  Ini: TIniFile;
  i, SepPos: Integer;
  ConfigLines: TStringList;
begin
  Result := False;
  FillChar(Settings, SizeOf(Settings), 0);
  Settings.ActiveGameName := ActiveGameName;

  // Defaults
  Settings.FilenameItemIndex := 0;
  Settings.EmuFp8Checked := False;
  Settings.ShortcutKey := '0x2d';
  Settings.MenuScalePosition := 10;
  Settings.OverrideChecked := False;
  Settings.SpoofChecked := False;
  Settings.FsrversionItemIndex := 0;
  Settings.OptipatcherChecked := False;
  Settings.ForceReflexChecked := False;
  Settings.ReflexItemIndex := 0;
  Settings.ForceLatencyFlexChecked := False;
  Settings.LatencyFlexItemIndex := 0;
  Settings.TraceLogChecked := False;

  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';

  // 1. Load OptiScaler.ini
  OptiScalerIniPath := GetGameConfigDir(ActiveGameName) + 'OptiScaler.ini';

  if FileExists(OptiScalerIniPath) then
  begin
    OptiCfg := TConfigFile.Create;
    try
      if OptiCfg.Load(OptiScalerIniPath) then
      begin
        Value := OptiCfg.GetValue(OPTI_KEY_SHORTCUT, '', OPTI_INI_SECTION_MENU);
        if SameText(Value, 'auto') or (Value = '') then
          Settings.ShortcutKey := '0x2d'
        else
          Settings.ShortcutKey := Value;

        Value := OptiCfg.GetValue(OPTI_KEY_SCALE, '', OPTI_INI_SECTION_MENU);
        if TryStrToFloat(Value, FloatValue, FS) then
          Settings.MenuScalePosition := Round(FloatValue * 10);

        Settings.OverrideChecked := SameText(OptiCfg.GetValue(OPTI_KEY_OVERRIDE_NVAPI, ''), 'true');
        Settings.OptipatcherChecked := SameText(OptiCfg.GetValue(OPTI_KEY_LOAD_ASI, ''), 'true');

        if SameText(OptiCfg.GetValue(OPTI_KEY_FSR4_UPDATE, ''), 'true') then
          Settings.FsrversionItemIndex := 0;

        Settings.SpoofChecked := SameText(OptiCfg.GetValue(OPTI_KEY_DXGI, ''), 'auto');
      end;
    finally
      OptiCfg.Free;
    end;
  end;

  // 2. Load fakenvapi.ini
  FakeNvapiIniPath := GetGameConfigDir(ActiveGameName) + 'fakenvapi.ini';

  if FileExists(FakeNvapiIniPath) then
  begin
    FakeCfg := TConfigFile.Create;
    try
      if FakeCfg.Load(FakeNvapiIniPath) then
      begin
        if FakeCfg.HasKey(FAKE_KEY_FORCE_REFLEX) then
        begin
          Settings.ForceReflexChecked := True;
          Value := FakeCfg.GetValue(FAKE_KEY_FORCE_REFLEX, '0');
          case Value of
            '0': Settings.ReflexItemIndex := 0;
            '1': Settings.ReflexItemIndex := 1;
            '2': Settings.ReflexItemIndex := 2;
          else
            Settings.ReflexItemIndex := 0;
          end;
        end
        else
        begin
          Settings.ForceReflexChecked := False;
          Settings.ReflexItemIndex := 0;
        end;

        Settings.ForceLatencyFlexChecked := (FakeCfg.GetValue(FAKE_KEY_FORCE_LATENCY, '0') = '1');
        if Settings.ForceLatencyFlexChecked then
        begin
          case FakeCfg.GetValue(FAKE_KEY_LATENCY_MODE, '0') of
            '0': Settings.LatencyFlexItemIndex := 0;
            '1': Settings.LatencyFlexItemIndex := 1;
            '2': Settings.LatencyFlexItemIndex := 2;
          else
            Settings.LatencyFlexItemIndex := 0;
          end;
        end;

        Settings.TraceLogChecked := (FakeCfg.GetValue(FAKE_KEY_TRACE_LOGS, '0') = '1');
      end;
    finally
      FakeCfg.Free;
    end;
  end;

  // 3. Load bgmod.conf and goverlay.vars
  ConfigPath := GetGameConfigDir(ActiveGameName) + 'bgmod.conf';

  if not FileExists(ConfigPath) then
  begin
    Settings.FilenameItemIndex := 0;
    Settings.EmuFp8Checked := False;
  end
  else
  begin
    Ini := TIniFile.Create(ConfigPath);
    try
      DllName := Ini.ReadString('Config', 'DLL', 'dxgi.dll');
      if SameText(DllName, 'dxgi.dll') then
        Settings.FilenameItemIndex := 0
      else if SameText(DllName, 'version.dll') then
        Settings.FilenameItemIndex := 1
      else if SameText(DllName, 'dbghelp.dll') then
        Settings.FilenameItemIndex := 2
      else if SameText(DllName, 'd3d12.dll') then
        Settings.FilenameItemIndex := 3
      else if SameText(DllName, 'wininet.dll') then
        Settings.FilenameItemIndex := 4
      else if SameText(DllName, 'winhttp.dll') then
        Settings.FilenameItemIndex := 5
      else if SameText(DllName, 'winmm.dll') then
        Settings.FilenameItemIndex := 6
      else if SameText(DllName, 'OptiScaler.asi') then
        Settings.FilenameItemIndex := 7
      else
        Settings.FilenameItemIndex := 0;

      Settings.EmuFp8Checked := Ini.ReadString('Env', 'DXIL_SPIRV_CONFIG', '') <> '';
      Settings.OptVersionItemIndex := Ini.ReadInteger('Config', 'OPT_CHANNEL', -1);
    finally
      Ini.Free;
    end;
  end;

  VarsPath := IncludeTrailingPathDelimiter(GetGameConfigDir(ActiveGameName)) + 'goverlay.vars';

  if FileExists(VarsPath) then
  begin
    ConfigLines := TStringList.Create;
    try
      ConfigLines.LoadFromFile(VarsPath);
      FsrVer := '';
      for i := 0 to ConfigLines.Count - 1 do
      begin
        TrimmedLine := Trim(ConfigLines[i]);
        SepPos := Pos('=', TrimmedLine);
        if SepPos > 0 then
        begin
          Key   := Copy(TrimmedLine, 1, SepPos - 1);
          Value := Copy(TrimmedLine, SepPos + 1, Length(TrimmedLine));
          if SameText(Key, 'fsrversion') then
          begin
            FsrVer := Value;
            Break;
          end;
        end;
      end;
      if (FsrVer = '4.0.2c (INT8)') or (FsrVer = '4.0.2c INT8') then
        Settings.FsrversionItemIndex := 1
      else
        Settings.FsrversionItemIndex := 0;
    finally
      ConfigLines.Free;
    end;
  end;

  Result := True;
end;

function ColorToHTMLColor(const AColor: TColor): string;
var
  Red, Green, Blue: Byte;
begin
  Red := Byte(AColor); // Red component
  Green := Byte(AColor shr 8); // green component
  Blue := Byte(AColor shr 16); // blue component

  Result := Format('%.2x%.2x%.2x', [Red, Green, Blue]); // Formata a string no formato HTML (#RRGGBB)
end;

function SaveMangoHudConfigCore(const Settings: TMangoHudSettings; const AvFonts: TStrings; out ErrMsg: string): Boolean;
var
  ConfigLines: TStringList;
  ConfigDir, FontPath, FontDir: string;
  FlatpakSteamConfigDir, FlatpakMangoHudFile: string;
  i: Integer;
  TempFiles, FontDirs: TStringList;
  Ini, Ini2: TIniFile;
  FGModFilePath, FGModConfPath: string;

  procedure AddIfTrue(ABool: Boolean; const ALine: string);
  begin
    if ABool then
      ConfigLines.Add(ALine);
  end;

begin
  Result := False;
  ErrMsg := '';

  if Settings.ActiveGameName <> '' then
    ConfigDir := ExtractFilePath(Settings.MangoHudCfgFile)
  else
    ConfigDir := TConfigManager.GetMangoHudFolder();

  // Create directory if it doesn't exist
  if not DirectoryExists(ConfigDir) then
  begin
    if Settings.ActiveGameName <> '' then
      ForceDirectories(ConfigDir)
    else
      CreateHostDirectory(ConfigDir);
  end;

  ConfigLines := TStringList.Create;
  try
    ConfigLines.Add('################### File Generated by Goverlay ' + Settings.Version + ' ' + Settings.Channel + ' ###################');
    ConfigLines.Add('legacy_layout=0');
    ConfigLines.Add('');

    // ============= VISUAL TAB =============

    // HUD Title
    if Settings.HudTitle <> '' then
      ConfigLines.Add('custom_text_center=' + Settings.HudTitle);

    // Orientation
    if Settings.Horizontal then
      ConfigLines.Add('horizontal');

    // Background alpha
    ConfigLines.Add('background_alpha=' + FormatFloat('0.0', Settings.TranspPosition / 10));

    // Border type (round corners)
    if Settings.RoundCorners then
      ConfigLines.Add('round_corners=10')
    else
      ConfigLines.Add('round_corners=0');

    // Background color
    ConfigLines.Add('background_color=' + ColorToHTMLColor(Settings.HudBackgroundColor));

    // Font file
    if Settings.FontText <> '' then
    begin
      // Search in all standard font directories (including Flatpak)
      FontDirs := GetStandardFontDirectories;
      try
        for FontDir in FontDirs do
        begin
          if DirectoryExists(FontDir) then
          begin
            TempFiles := FindAllFiles(FontDir, Settings.FontText, True);
            try
              if TempFiles.Count > 0 then
              begin
                FontPath := TempFiles[0];
                ConfigLines.Add('font_file=' + FontPath);
                Break; // Found the font, stop searching
              end;
            finally
              TempFiles.Free;
            end;
          end;
        end;
      finally
        FontDirs.Free;
      end;
    end;

    // Font size
    ConfigLines.Add('font_size=' + IntToStr(Settings.FontSize));

    // Font color
    ConfigLines.Add('text_color=' + ColorToHTMLColor(Settings.FontColor));

    // Position
    if Settings.Position <> '' then
      ConfigLines.Add('position=' + Settings.Position);

    // Offset X / Y
    if Settings.OffsetX <> 0 then
      ConfigLines.Add('offset_x=' + IntToStr(Settings.OffsetX));
    if Settings.OffsetY <> 0 then
      ConfigLines.Add('offset_y=' + IntToStr(Settings.OffsetY));

    if Settings.ToggleHudKey <> '' then
      ConfigLines.Add('toggle_hud=' + Settings.ToggleHudKey);

    // Hide HUD
    AddIfTrue(Settings.HideHud, 'no_display');

    // HUD compact
    AddIfTrue(Settings.HudCompact, 'hud_compact');

    // Horizontal Stretch
    if Settings.HorizontalStretch then
      ConfigLines.Add(MANGO_KEY_HORIZONTAL_STRETCH + '=0');

    // PCI device and GPU List logic
    if Settings.PciDevIndex <> -1 then
    begin
      if Settings.PciDevText = 'Use both GPUs' then
      begin
        ConfigLines.Add('gpu_list=0,1');
      end
      else
      begin
        if Settings.PciDevIndex = 0 then
             ConfigLines.Add('gpu_list=0')
        else if Settings.PciDevIndex = 1 then
             ConfigLines.Add('gpu_list=1')
        else
             ConfigLines.Add('gpu_list=' + IntToStr(Settings.PciDevIndex));
      end;
    end;

    // Table columns
    ConfigLines.Add('table_columns=' + Settings.TableColumns);

    // ============= METRICS TAB - GPU =============

    // GPU text
    if Settings.GpuText <> '' then
      ConfigLines.Add('gpu_text=' + Settings.GpuText);

    // GPU stats
    AddIfTrue(Settings.GpuAvgLoad, 'gpu_stats');

    // GPU load color change
    if Settings.GpuLoadColorChecked then
    begin
      ConfigLines.Add('gpu_load_change');
      ConfigLines.Add('gpu_load_value=50,90');
      ConfigLines.Add('gpu_load_color=' + ColorToHTMLColor(Settings.GpuLoadColors[0]) + ',' +
                      ColorToHTMLColor(Settings.GpuLoadColors[1]) + ',' +
                      ColorToHTMLColor(Settings.GpuLoadColors[2]));
    end;

    // VRAM
    AddIfTrue(Settings.VramUsage, 'vram');
    if Settings.VramUsage then
      ConfigLines.Add('vram_color=' + ColorToHTMLColor(Settings.VramColor));

    // GPU frequency
    AddIfTrue(Settings.GpuFreq, 'gpu_core_clock');

    // GPU memory frequency
    AddIfTrue(Settings.GpuMemFreq, 'gpu_mem_clock');

    // GPU temperatures
    AddIfTrue(Settings.GpuTemp, 'gpu_temp');
    AddIfTrue(Settings.GpuMemTemp, 'gpu_mem_temp');
    AddIfTrue(Settings.GpuJuncTemp, 'gpu_junction_temp');

    // GPU fan
    AddIfTrue(Settings.GpuFan, 'gpu_fan');

    // GPU power
    AddIfTrue(Settings.GpuPower, 'gpu_power');

    // GPU power limit
    AddIfTrue(Settings.GpuPowerLimit, 'gpu_power_limit');

    // GPU efficiency
    AddIfTrue(Settings.GpuEfficiency, 'gpu_efficiency');

    // Flip efficiency (Joules / Frame mode)
    if Settings.GpuFramesJouleCaption = 'Joules / Frame' then
      ConfigLines.Add('flip_efficiency');

    // GPU voltage
    AddIfTrue(Settings.GpuVoltage, 'gpu_voltage');

    // GPU throttling
    AddIfTrue(Settings.GpuThrottling, 'throttling_status');
    AddIfTrue(Settings.GpuThrottlingGraph, 'throttling_status_graph');

    // GPU model
    AddIfTrue(Settings.GpuModel, 'gpu_name');

    // Vulkan driver
    AddIfTrue(Settings.VulkanDriver, 'vulkan_driver');

    // GPU color
    if Settings.GpuAvgLoad then
      ConfigLines.Add('gpu_color=' + ColorToHTMLColor(Settings.GpuColor));

    // ============= METRICS TAB - CPU =============

    // CPU text
    if Settings.CpuText <> '' then
      ConfigLines.Add('cpu_text=' + Settings.CpuText);

    // CPU stats
    AddIfTrue(Settings.CpuAvgLoad, 'cpu_stats');

    // CPU core load
    AddIfTrue(Settings.CpuLoadCore, 'core_load');

    // Core load type (bars)
    if Settings.CoreLoadTypeCaption = 'Graph' then
      ConfigLines.Add('core_bars');

    // CPU load color change
    if Settings.CpuLoadColorChecked then
    begin
      ConfigLines.Add('cpu_load_change');
      ConfigLines.Add('cpu_load_value=50,90');
      ConfigLines.Add('cpu_load_color=' + ColorToHTMLColor(Settings.CpuLoadColors[0]) + ',' +
                      ColorToHTMLColor(Settings.CpuLoadColors[1]) + ',' +
                      ColorToHTMLColor(Settings.CpuLoadColors[2]));
    end;

    // CPU frequency
    AddIfTrue(Settings.CpuFreq, 'cpu_mhz');

    // CPU temperature
    AddIfTrue(Settings.CpuTemp, 'cpu_temp');

    // CPU power
    AddIfTrue(Settings.CpuPower, 'cpu_power');

    // CPU efficiency
    AddIfTrue(Settings.CpuEfficiency, 'cpu_efficiency');

    // CPU core type
    AddIfTrue(Settings.CpuCoreType, 'core_type');

    // CPU color
    if Settings.CpuAvgLoad then
      ConfigLines.Add('cpu_color=' + ColorToHTMLColor(Settings.CpuColor));

    // ============= METRICS TAB - MEMORY/IO =============

    // I/O stats
    if Settings.DiskIo then
    begin
      ConfigLines.Add('io_read');
      ConfigLines.Add('io_write');
      ConfigLines.Add('io_color=' + ColorToHTMLColor(Settings.IoColor));
    end;

    // Swap
    AddIfTrue(Settings.SwapUsage, 'swap');

    // RAM
    if Settings.RamUsage then
    begin
      ConfigLines.Add('ram');
      ConfigLines.Add('ram_color=' + ColorToHTMLColor(Settings.RamColor));
    end;

    // RAM temperature
    AddIfTrue(Settings.RamTemp, 'ram_temp');

    // Process memory
    AddIfTrue(Settings.ProcMem, 'procmem');

    // Process VRAM
    AddIfTrue(Settings.ProcVram, 'proc_vram');

    // ============= METRICS TAB - OTHER =============

    // Battery
    if Settings.Battery then
    begin
      ConfigLines.Add('battery');
      ConfigLines.Add('battery_color=' + ColorToHTMLColor(Settings.BatteryColor));
    end;
    AddIfTrue(Settings.BatteryWatt, 'battery_watt');
    AddIfTrue(Settings.BatteryTime, 'battery_time');

    // Device battery
    if Settings.Device then
    begin
      ConfigLines.Add('device_battery=gamepad');
      ConfigLines.Add('device_battery_icon');
    end;

    // FPS
    AddIfTrue(Settings.Fps, 'fps');

    // FPS metrics (avg)
    if Settings.FpsAvg then
    begin
      if Settings.FpsAvgCaption = '1% low' then
        ConfigLines.Add('fps_metrics=avg,0.01')
      else
        ConfigLines.Add('fps_metrics=avg,0.001');
    end;

    // Frame timing
    if Settings.FrametimeGraph then
    begin
      ConfigLines.Add('frame_timing');
      ConfigLines.Add('frametime_color=' + ColorToHTMLColor(Settings.FrametimeGraphColor));
    end;

    // Histogram
    if Settings.FrametimeTypeCaption = 'Histogram' then
      ConfigLines.Add('histogram');

    // Frame count
    AddIfTrue(Settings.FrameCount, 'frame_count');

    // Engine
    if Settings.EngineVersion then
      ConfigLines.Add('engine_version');
    ConfigLines.Add('engine_color=' + ColorToHTMLColor(Settings.EngineColor));
    AddIfTrue(Settings.EngineShort, 'engine_short_names');

    // Arch
    AddIfTrue(Settings.Arch, 'arch');

    // Wine
    if Settings.Wine then
    begin
      ConfigLines.Add('wine');
      ConfigLines.Add('wine_color=' + ColorToHTMLColor(Settings.WineColor));
    end;

    // Winesync
    AddIfTrue(Settings.Winesync, 'winesync');

    // ============= PERFORMANCE TAB =============

    // Show FPS limit
    AddIfTrue(Settings.ShowFpsLim, 'show_fps_limit');

    // FPS limit method
    case Settings.FpsLimMetItemIndex of
      0: ConfigLines.Add('fps_limit_method=late');
      1: ConfigLines.Add('fps_limit_method=early');
    end;

    if Settings.FpsLimToggleText <> '' then
      ConfigLines.Add('toggle_fps_limit=' + Settings.FpsLimToggleText);

    // FPS limits (from edit field)
    if Settings.FpsLimitText <> '' then
      ConfigLines.Add('fps_limit=' + Settings.FpsLimitText)
    else
      ConfigLines.Add('fps_limit=0');

    // Resolution
    AddIfTrue(Settings.Resolution, 'resolution');

    // Refresh rate
    AddIfTrue(Settings.RefreshRate, 'refresh_rate');

    // FCAT
    AddIfTrue(Settings.Fcat, 'fcat');

    // FEX Stats
    AddIfTrue(Settings.FexStats, 'fex_stats');

    // FSR
    AddIfTrue(Settings.Fsr, 'fsr');

    // HDR
    AddIfTrue(Settings.Hdr, 'hdr');

    // VPS (present mode)
    AddIfTrue(Settings.Vps, 'present_mode');

    // Fahrenheit
    AddIfTrue(Settings.Fahrenheit, 'temp_fahrenheit');

    // Gamemode
    AddIfTrue(Settings.GamemodeStatus, 'gamemode');

    // vkBasalt status
    AddIfTrue(Settings.VkbasaltStatus, 'vkbasalt');

    // VSync
    case Settings.VsyncItemIndex of
      0: ConfigLines.Add('vsync=0');
      1: ConfigLines.Add('vsync=1');
      2: ConfigLines.Add('vsync=2');
      3: ConfigLines.Add('vsync=3');
      4: ConfigLines.Add('vsync=4');
    end;

    // GL VSync
    case Settings.GlvsyncItemIndex of
      0: ConfigLines.Add('gl_vsync=-1');
      1: ConfigLines.Add('gl_vsync=0');
      2: ConfigLines.Add('gl_vsync=1');
      3: ConfigLines.Add('gl_vsync=n');
    end;

    // Filters
    case Settings.FilterItemIndex of
      1: ConfigLines.Add('bicubic');
      2: ConfigLines.Add('trilinear');
      3: ConfigLines.Add('retro');
    end;

    // AF filter
    if Settings.AfPosition > 0 then
      ConfigLines.Add('af=' + IntToStr(Settings.AfPosition));

    // Mipmap filter
    if Settings.MipmapPosition > 0 then
      ConfigLines.Add('picmip=' + IntToStr(Settings.MipmapPosition));

    // FPS color change
    if Settings.FpsColorChecked then
    begin
      ConfigLines.Add('fps_color_change');
      ConfigLines.Add('fps_color=' + ColorToHTMLColor(Settings.FpsColors[0]) + ',' +
                      ColorToHTMLColor(Settings.FpsColors[1]) + ',' +
                      ColorToHTMLColor(Settings.FpsColors[2]));
      ConfigLines.Add('fps_value=' + IntToStr(Settings.FpsColorValues[0]) + ',' + IntToStr(Settings.FpsColorValues[1]));
    end;

    // ============= EXTRAS TAB =============

    // Distro info
    if Settings.DistroInfo then
    begin
      ConfigLines.Add('custom_text=-');
      ConfigLines.Add('exec=cat ' + TConfigManager.GetDistroFile);
      ConfigLines.Add('custom_text=-');
      ConfigLines.Add('exec=uname -r');
    end;

    // Display server
    AddIfTrue(Settings.DisplayServer, 'display_server');

    // Time
    if Settings.Time then
    begin
      ConfigLines.Add('time');
      ConfigLines.Add('time_no_label');
    end;

    // HUD version
    AddIfTrue(Settings.HudVersion, 'version#');

    // Media player
    if Settings.Media then
    begin
      ConfigLines.Add('media_player');
      ConfigLines.Add('media_player_color=' + ColorToHTMLColor(Settings.MediaColor));
    end;

    // Network
    if Settings.Network and (Settings.NetworkInterfaceText <> '') then
      ConfigLines.Add('network=' + Settings.NetworkInterfaceText);

    // Log folder (XDG-compliant data directory)
    if Settings.LogFolder <> '' then
      ConfigLines.Add('output_folder=' + Settings.LogFolder);

    // Log duration
    if Settings.Duration > 0 then
      ConfigLines.Add('log_duration=' + IntToStr(Settings.Duration));

    // Log delay (autostart)
    if Settings.Delay > 0 then
      ConfigLines.Add('autostart_log=' + IntToStr(Settings.Delay));

    // Log interval
    if Settings.Interval > 0 then
      ConfigLines.Add('log_interval=' + IntToStr(Settings.Interval));

    if Settings.LogToggleText <> '' then
      ConfigLines.Add('toggle_logging=' + Settings.LogToggleText);

    // Log versioning
    AddIfTrue(Settings.Versioning, 'log_versioning');

    // Auto upload
    AddIfTrue(Settings.AutoUpload, 'upload_logs');

    // Save to active config file (game-specific or global)
    ConfigLines.SaveToFile(Settings.MangoHudCfgFile);

    // Update bgmod.conf with GOVERLAY_MANGOHUD=1
    FGModFilePath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';

    ForceDirectories(ExtractFilePath(FGModFilePath));
    Ini := TIniFile.Create(FGModFilePath);
    try
      Ini.WriteString('Config', 'GOVERLAY_MANGOHUD', '1');
    finally
      Ini.Free;
    end;

    // In game-specific mode: inject MANGOHUD_CONFIGFILE into the game bgmod
    // so Steam picks up the per-game config at launch.
    if Settings.ActiveGameName <> '' then
    begin
      FGModConfPath := GetGameConfigDir(Settings.ActiveGameName) + 'bgmod.conf';
      ForceDirectories(ExtractFilePath(FGModConfPath));
      Ini2 := TIniFile.Create(FGModConfPath);
      try
        Ini2.WriteString('Env', 'MANGOHUD_CONFIGFILE', Settings.MangoHudCfgFile);
      finally
        Ini2.Free;
      end;
      Result := True;
      Exit;
    end;

    try
      FlatpakSteamConfigDir := GetUserDir + '.var/app/com.valvesoftware.Steam/config/MangoHud';
      FlatpakMangoHudFile := FlatpakSteamConfigDir + '/MangoHud.conf';

      // Create Flatpak directory if it doesn't exist
      if not DirectoryExists(FlatpakSteamConfigDir) and DirectoryExists(GetUserDir + '.var') then
        ForceDirectories(FlatpakSteamConfigDir)
      else
        WriteLn('[WARN] SaveMangoHudConfigCore: ~/.var does not exist, skipping saving config for Steam Flatpak');

      if DirectoryExists(FlatpakSteamConfigDir) then
      begin
        // Save the same configuration to Flatpak location
        ConfigLines.SaveToFile(FlatpakMangoHudFile);
        WriteLn('[DEBUG] SaveMangoHudConfigCore: Configuration also saved to Steam Flatpak location: ', FlatpakMangoHudFile);
      end
    except
      on E: Exception do
        WriteLn('[WARN] SaveMangoHudConfigCore: Could not save to Steam Flatpak location: ', E.Message);
    end;

    Result := True;
  finally
    ConfigLines.Free;
  end;
end;

procedure EnsureDefaultConfigFiles(const GVersion, GChannel, VkbToggleKeyText: string);
var
  ConfigFilePath, ConfigDir: string;
  BlacklistFile: string;
  VkBasaltCfgFile: string;
  VkSumiFolder, VkSumiCfgFile: string;
  DefaultConfigContent: TStringList;
  FileLines: TStringList;
begin
  ConfigFilePath := IncludeTrailingPathDelimiter(GetMangoHudConfigDir()) + 'MangoHud.conf';
  ConfigDir := ExtractFilePath(ConfigFilePath);

  // check if directory exists (use CreateHostDirectory for Flatpak compatibility)
  if not DirectoryExists(ConfigDir) then
    CreateHostDirectory(ConfigDir);

  // check if files exists
  if not FileExists(ConfigFilePath) then
  begin
    // show notification
    SendNotification('Goverlay', 'No configuration files located, creating files and folders.', GetIconFile);

    // Create stock mangohud config
    DefaultConfigContent := TStringList.Create;
    try
      DefaultConfigContent.Text :=
        '################### File Generated by Goverlay ###################' + LineEnding +
        '' + LineEnding +
        'legacy_layout=0' + LineEnding +
        'background_alpha=0.6' + LineEnding +
        'round_corners=0' + LineEnding +
        'background_color=000000' + LineEnding +
        'font_size=24' + LineEnding +
        'text_color=FFFFFF' + LineEnding +
        'position=top-left' + LineEnding +
        'table_columns=3' + LineEnding +
        'gpu_text=GPU' + LineEnding +
        'gpu_stats' + LineEnding +
        'gpu_core_clock' + LineEnding +
        'gpu_mem_clock' + LineEnding +
        'gpu_temp' + LineEnding +
        'gpu_power' + LineEnding +
        'gpu_color=2E9762' + LineEnding +
        'cpu_text=CPU' + LineEnding +
        'cpu_stats' + LineEnding +
        'cpu_mhz' + LineEnding +
        'cpu_temp' + LineEnding +
        'cpu_power' + LineEnding +
        'cpu_color=2E97CB' + LineEnding +
        'vram' + LineEnding +
        'vram_color=AD64C1' + LineEnding +
        'ram' + LineEnding +
        'ram_color=C26693' + LineEnding +
        'battery' + LineEnding +
        'battery_color=00FF00' + LineEnding +
        'fps' + LineEnding +
        'frame_timing' + LineEnding +
        'frametime_color=00FF00' + LineEnding +
        'fps_limit_method=late' + LineEnding +
        'fps_limit=0' + LineEnding +
        'log_duration=30' + LineEnding +
        'autostart_log=0' + LineEnding +
        'log_interval=100';

      // save file content
      DefaultConfigContent.SaveToFile(ConfigFilePath);
    finally
      DefaultConfigContent.Free;
    end;
  end;

  // Check directory  -  BLACKLIST
  BlacklistFile := GetUserConfigDir + '/goverlay/blacklist.conf';

  // make sure directory exists -  BLACKLIST
  ForceDirectories(ExtractFilePath(BlacklistFile));

  // Check if file exists and create default - BLACKLIST
  if not FileExists(BlacklistFile) then
  begin
    FileLines := TStringList.Create;
    try
      FileLines.Add('zenity');
      FileLines.Add('protonplus');
      FileLines.Add('lsfg-vk-ui');
      FileLines.Add('bazzar');
      FileLines.Add('gnome-calculator');
      FileLines.Add('pamac-manager');
      FileLines.Add('lact');
      FileLines.Add('ghb');
      FileLines.Add('bitwig-studio');
      FileLines.Add('ptyxis');
      FileLines.Add('yumex');
      FileLines.SaveToFile(BlacklistFile);
    finally
      FileLines.Free;
    end;
  end;

  // Check vkbasalt directory with proper XDG and Flatpak support
  VkBasaltCfgFile := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf';

  // make sure directory exists - VKBASALT (use CreateHostDirectory for Flatpak compatibility)
  CreateHostDirectory(ExtractFilePath(VkBasaltCfgFile));

  // Check if file exists and create default - VKBASALT
  if not FileExists(VkBasaltCfgFile) then
  begin
    SendNotification('Goverlay', 'No configuration files located for vkbasalt, creating files and folders.', GetIconFile);
    FileLines := TStringList.Create;
    try
      FileLines.Add('################### File Generated by Goverlay ###################');
      FileLines.Add('toggleKey = ' + VkbToggleKeyText);
      FileLines.Add('enableOnLaunch = True');

      FileLines.SaveToFile(VkBasaltCfgFile);
    finally
      FileLines.Free;
    end;
  end;

  // Check vkSumi directory with proper XDG and Flatpak support
  VkSumiFolder := IncludeTrailingPathDelimiter(GetVkSumiConfigDir());
  VkSumiCfgFile := VkSumiFolder + 'vkSumi.conf';

  // make sure directory exists - VKSUMI
  CreateHostDirectory(VkSumiFolder);

  // Check if file exists and create default - VKSUMI
  if not FileExists(VkSumiCfgFile) then
  begin
    FileLines := TStringList.Create;
    try
      FileLines.Add('################### File Generated by Goverlay ' + GVersion + ' ' + GChannel + ' ###################');
      FileLines.Add('# vkSumi color grading');
      FileLines.Add('#');
      FileLines.Add('enabled     = true');
      FileLines.Add('toggle_keys = Shift_R+F9    # in-game hotkey, X11 + XWayland (Wine/Proton)');
      FileLines.Add('');
      FileLines.Add('PER_GAME_CONFIG_CREATION = false');
      FileLines.Add('');
      FileLines.Add('# tone');
      FileLines.Add('brightness = 0.0');
      FileLines.Add('contrast   = 0.0');
      FileLines.Add('exposure   = 0.0');
      FileLines.Add('gamma      = 0.0');
      FileLines.Add('');
      FileLines.Add('# color');
      FileLines.Add('saturation = 0.0');
      FileLines.Add('vibrance   = 0.0');
      FileLines.Add('hue_deg    = 0.0');
      FileLines.Add('temperature = 0.0');
      FileLines.Add('tint       = 0.0');
      FileLines.Add('');
      FileLines.Add('# per-channel gain');
      FileLines.Add('red_gain   = 0.0');
      FileLines.Add('green_gain = 0.0');
      FileLines.Add('blue_gain  = 0.0');
      FileLines.Add('');
      FileLines.Add('# 3-band');
      FileLines.Add('shadows    = 0.0');
      FileLines.Add('midtones   = 0.0');
      FileLines.Add('highlights = 0.0');
      FileLines.SaveToFile(VkSumiCfgFile);
    finally
      FileLines.Free;
    end;
  end;
end;

end.
