unit configmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IniFiles, constants;

const
  MODULE_MANGOHUD = 'MangoHud';
  MODULE_VKBASALT = 'vkBasalt';
  MODULE_RESHADE = 'ReShade';
  MODULE_VKSUMI = 'vkSumi';
  MODULE_OPTISCALER = 'OptiScaler';
  MODULE_DLSSENABLER = 'DlssEnabler';
  MODULE_HELIXSR = 'HelixSR';
  MODULE_LSFGVK = 'LsfgVk';
  MODULE_MAKO = 'Mako';
  MODULE_AFMF = 'Afmf';
  MODULE_POSTPROCESSING = 'PostProcessing';
  MODULE_UPSCALERS = 'Upscalers';
  MODULE_FRAMEGENERATION = 'FrameGeneration';
  SECTION_MODULES = 'Modules';
  KEY_FIRST_RUN_WIZARD = 'FirstRunWizardCompleted';

type
  /// <summary>
  /// Configuration manager for GOverlay and related tools
  /// Centralizes path management and configuration file operations
  /// </summary>
  TConfigManager = class
  private
    class function GetUserConfigDir: string;
    class function GetUserHomeDir: string;
  public
    // ============================================================================
    // PATH GETTERS - MangoHud
    // ============================================================================

    /// <summary>
    /// Gets the MangoHud configuration folder path
    /// </summary>
    /// <returns>Full path to MangoHud config folder</returns>
    class function GetMangoHudFolder: string;

    /// <summary>
    /// Gets the MangoHud configuration file path
    /// </summary>
    /// <returns>Full path to MangoHud.conf</returns>
    class function GetMangoHudConfigFile: string;

    /// <summary>
    /// Gets the MangoHud custom preset file path
    /// </summary>
    /// <returns>Full path to custom.conf</returns>
    class function GetMangoHudCustomFile: string;

    // ============================================================================
    // PATH GETTERS - vkBasalt
    // ============================================================================

    /// <summary>
    /// Gets the vkBasalt configuration folder path
    /// </summary>
    /// <returns>Full path to vkBasalt config folder</returns>
    class function GetVkBasaltFolder: string;

    /// <summary>
    /// Gets the vkBasalt configuration file path
    /// </summary>
    /// <returns>Full path to vkBasalt.conf</returns>
    class function GetVkBasaltConfigFile: string;

    /// <summary>
    /// Gets the ReShade shaders repository folder path
    /// </summary>
    /// <returns>Full path to reshade-shaders folder</returns>
    class function GetReshadeFolder: string;

    // ============================================================================
    // PATH GETTERS - GOverlay
    // ============================================================================

    /// <summary>
    /// Gets the GOverlay configuration folder path
    /// </summary>
    /// <returns>Full path to GOverlay config folder</returns>
    class function GetGoverlayFolder: string;

    /// <summary>
    /// Gets the blacklist configuration file path
    /// </summary>
    /// <returns>Full path to blacklist.conf</returns>
    class function GetBlacklistFile: string;

     /// <summary>
     /// Gets the distro cache file path
     /// </summary>
     /// <returns>Full path to distro file</returns>
     class function GetDistroFile: string;

     /// <summary>
     /// Gets the GOverlay logs folder path
     /// </summary>
     /// <returns>Full path to GOverlay logs folder</returns>
     class function GetGoverlayLogsDir: string;

     /// <summary>
     /// Gets the GOverlay main configuration file path
     /// </summary>
     /// <returns>Full path to goverlay.conf</returns>
     class function GetConfigFilePath: string;

     // ============================================================================
     // MODULE CONFIGURATION
     // ============================================================================

     class function IsFirstRunWizardCompleted: Boolean;
     class procedure SetFirstRunWizardCompleted(ACompleted: Boolean);
     class function IsModuleEnabled(const AModuleName: string; ADefault: Boolean = False): Boolean;
     class procedure SetModuleEnabled(const AModuleName: string; AEnabled: Boolean);
     class procedure MigrateExistingInstallation(AIni: TIniFile);

     // ============================================================================
     // PATH GETTERS - OptiScaler/fgmod
     // ============================================================================

    /// <summary>
    /// Gets the fgmod installation folder path
    /// </summary>
    /// <returns>Full path to fgmod folder</returns>
    class function GetFgmodFolder: string;

    /// <summary>
    /// Gets the fgmod script file path
    /// </summary>
    /// <returns>Full path to fgmod script</returns>
    class function GetFgmodScriptFile: string;

    /// <summary>
    /// Gets the OptiScaler INI file path
    /// </summary>
    /// <returns>Full path to OptiScaler.ini</returns>
    class function GetOptiScalerIniFile: string;

    /// <summary>
    /// Gets the FakeNvapi INI file path
    /// </summary>
    /// <returns>Full path to fakenvapi.ini</returns>
    class function GetFakeNvapiIniFile: string;

    /// <summary>
    /// Gets the GOverlay vars file path (version tracking)
    /// </summary>
    /// <returns>Full path to goverlay.vars</returns>
    class function GetGoverlayVarsFile: string;

    // ============================================================================
    // XDG / FLATPAW-AWARE PATH HELPERS
    // ============================================================================

    /// <summary>
    /// Gets the host config directory (Flatpak-aware).
    /// Checks HOST_XDG_CONFIG_HOME first, then XDG_CONFIG_HOME, then ~/.config.
    /// </summary>
    class function GetHostConfigDir: string;

    /// <summary>
    /// Gets the host data directory (Flatpak-aware).
    /// Checks HOST_XDG_DATA_HOME first, then XDG_DATA_HOME, then ~/.local/share.
    /// </summary>
    class function GetHostDataDir: string;

    // ============================================================================
    // DIRECTORY OPERATIONS
    // ============================================================================

    /// <summary>
    /// Ensures a directory exists, creating it if necessary
    /// </summary>
    /// <param name="DirPath">Directory path to check/create</param>
    /// <returns>True if directory exists or was created successfully</returns>
    class function EnsureDirectoryExists(const DirPath: string): Boolean;

    /// <summary>
    /// Ensures all configuration directories exist
    /// </summary>
    /// <returns>True if all directories exist or were created successfully</returns>
    class function EnsureAllConfigDirsExist: Boolean;

    // ============================================================================
    // FILE OPERATIONS
    // ============================================================================

    /// <summary>
    /// Checks if a configuration file exists
    /// </summary>
    /// <param name="FilePath">File path to check</param>
    /// <returns>True if file exists</returns>
    class function ConfigFileExists(const FilePath: string): Boolean;

    /// <summary>
    /// Reads a configuration file into a TStringList
    /// </summary>
    /// <param name="FilePath">File path to read</param>
    /// <param name="Lines">TStringList to populate with file contents</param>
    /// <returns>True if file was read successfully</returns>
    class function ReadConfigFile(const FilePath: string; Lines: TStringList): Boolean;

    /// <summary>
    /// Writes a TStringList to a configuration file
    /// </summary>
    /// <param name="FilePath">File path to write</param>
    /// <param name="Lines">TStringList containing file contents</param>
    /// <returns>True if file was written successfully</returns>
    class function WriteConfigFile(const FilePath: string; Lines: TStringList): Boolean;

    /// <summary>
    /// Creates a backup of a configuration file
    /// </summary>
    /// <param name="FilePath">File path to backup</param>
    /// <returns>True if backup was created successfully</returns>
    class function BackupConfigFile(const FilePath: string): Boolean;
  end;

implementation

class function TConfigManager.GetUserConfigDir: string;
var
  UserConfig: String;
begin
  UserConfig := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if not DirectoryExists(UserConfig) then
  begin
    UserConfig := GetUserDir + '.config';
  end;
  Result := UserConfig;
end;

class function TConfigManager.GetUserHomeDir: string;
begin
  Result := GetUserDir;
end;

// ============================================================================
// MangoHud Paths
// ============================================================================

class function TConfigManager.GetMangoHudFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetHostConfigDir) + MANGOHUD_FOLDER_NAME;
end;

class function TConfigManager.GetMangoHudConfigFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetMangoHudFolder) + MANGOHUD_CONFIG_FILE;
end;

class function TConfigManager.GetMangoHudCustomFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetMangoHudFolder) + MANGOHUD_CUSTOM_FILE;
end;

// ============================================================================
// vkBasalt Paths
// ============================================================================

class function TConfigManager.GetVkBasaltFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetHostConfigDir) + VKBASALT_FOLDER_NAME;
end;

class function TConfigManager.GetVkBasaltConfigFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetVkBasaltFolder) + VKBASALT_CONFIG_FILE;
end;

class function TConfigManager.GetReshadeFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetVkBasaltFolder) + RESHADE_SHADERS_FOLDER;
end;

// ============================================================================
// GOverlay Paths
// ============================================================================

class function TConfigManager.GetGoverlayFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetUserConfigDir) + GOVERLAY_FOLDER_NAME;
end;

class function TConfigManager.GetBlacklistFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetGoverlayFolder) + GOVERLAY_BLACKLIST_FILE;
end;

class function TConfigManager.GetDistroFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetGoverlayFolder) + GOVERLAY_DISTRO_FILE;
end;

class function TConfigManager.GetGoverlayLogsDir: string;
begin
  Result := IncludeTrailingPathDelimiter(GetGoverlayFolder) + 'logs';
end;

class function TConfigManager.GetConfigFilePath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetGoverlayFolder) + 'goverlay.conf';
end;

// ============================================================================
// Module Configuration
// ============================================================================

class function TConfigManager.IsFirstRunWizardCompleted: Boolean;
var
  Ini: TIniFile;
  DefaultValue: Boolean;
begin
  DefaultValue := GetEnvironmentVariable('GOVERLAY_TEST') = '1';
  try
    Ini := TIniFile.Create(GetConfigFilePath);
    try
      Result := Ini.ReadBool('General', KEY_FIRST_RUN_WIZARD, DefaultValue);
    finally
      Ini.Free;
    end;
  except
    Result := DefaultValue;
  end;
end;

class procedure TConfigManager.SetFirstRunWizardCompleted(ACompleted: Boolean);
var
  Ini: TIniFile;
begin
  try
    EnsureDirectoryExists(GetGoverlayFolder);
    Ini := TIniFile.Create(GetConfigFilePath);
    try
      Ini.WriteBool('General', KEY_FIRST_RUN_WIZARD, ACompleted);
    finally
      Ini.Free;
    end;
  except
  end;
end;

class function TConfigManager.IsModuleEnabled(const AModuleName: string;
  ADefault: Boolean): Boolean;
var
  Ini: TIniFile;
  FallbackDefault: Boolean;
begin
  if AModuleName = MODULE_MANGOHUD then
    Exit(True);

  FallbackDefault := ADefault;
  if GetEnvironmentVariable('GOVERLAY_TEST') = '1' then
    FallbackDefault := True;

  try
    Ini := TIniFile.Create(GetConfigFilePath);
    try
      // If the exact module/library key is saved in the config, honor it directly
      if Ini.ValueExists(SECTION_MODULES, AModuleName) then
        Exit(Ini.ReadBool(SECTION_MODULES, AModuleName, ADefault));

      // For groups without explicit group key, check if any constituent library is explicitly saved/enabled
      if AModuleName = MODULE_POSTPROCESSING then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_VKBASALT) or
           Ini.ValueExists(SECTION_MODULES, MODULE_RESHADE) or
           Ini.ValueExists(SECTION_MODULES, MODULE_VKSUMI) then
          Exit(IsModuleEnabled(MODULE_VKBASALT, ADefault) or
               IsModuleEnabled(MODULE_RESHADE, ADefault) or
               IsModuleEnabled(MODULE_VKSUMI, ADefault));
        Exit(FallbackDefault);
      end;

      if AModuleName = MODULE_UPSCALERS then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_OPTISCALER) or
           Ini.ValueExists(SECTION_MODULES, MODULE_DLSSENABLER) or
           Ini.ValueExists(SECTION_MODULES, MODULE_HELIXSR) then
          Exit(IsModuleEnabled(MODULE_OPTISCALER, ADefault) or
               IsModuleEnabled(MODULE_DLSSENABLER, ADefault) or
               IsModuleEnabled(MODULE_HELIXSR, ADefault));
        Exit(FallbackDefault);
      end;

      if AModuleName = MODULE_FRAMEGENERATION then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_LSFGVK) or
           Ini.ValueExists(SECTION_MODULES, MODULE_MAKO) or
           Ini.ValueExists(SECTION_MODULES, MODULE_AFMF) then
          Exit(IsModuleEnabled(MODULE_LSFGVK, ADefault) or
               IsModuleEnabled(MODULE_MAKO, ADefault) or
               IsModuleEnabled(MODULE_AFMF, ADefault));
        Exit(FallbackDefault);
      end;

      // For individual libraries without their own key, check if legacy parent group key exists
      if (AModuleName = MODULE_VKBASALT) or
         (AModuleName = MODULE_RESHADE) or
         (AModuleName = MODULE_VKSUMI) then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_POSTPROCESSING) then
          Exit(Ini.ReadBool(SECTION_MODULES, MODULE_POSTPROCESSING, ADefault));
      end;

      if (AModuleName = MODULE_OPTISCALER) or
         (AModuleName = MODULE_DLSSENABLER) or
         (AModuleName = MODULE_HELIXSR) then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_UPSCALERS) then
          Exit(Ini.ReadBool(SECTION_MODULES, MODULE_UPSCALERS, ADefault));
      end;

      if (AModuleName = MODULE_LSFGVK) or
         (AModuleName = MODULE_MAKO) or
         (AModuleName = MODULE_AFMF) then
      begin
        if Ini.ValueExists(SECTION_MODULES, MODULE_FRAMEGENERATION) then
          Exit(Ini.ReadBool(SECTION_MODULES, MODULE_FRAMEGENERATION, ADefault));
      end;

      Result := FallbackDefault;
    finally
      Ini.Free;
    end;
  except
    Result := FallbackDefault;
  end;
end;

class procedure TConfigManager.SetModuleEnabled(const AModuleName: string;
  AEnabled: Boolean);
var
  Ini: TIniFile;
begin
  try
    EnsureDirectoryExists(GetGoverlayFolder);
    Ini := TIniFile.Create(GetConfigFilePath);
    try
      Ini.WriteBool(SECTION_MODULES, AModuleName, AEnabled);
    finally
      Ini.Free;
    end;
  except
  end;
end;

class procedure TConfigManager.MigrateExistingInstallation(AIni: TIniFile);
var
  DataDir: string;
  HasExistingConfig: Boolean;
  HasExistingComponents: Boolean;
begin
  if AIni = nil then
    Exit;

  if AIni.ValueExists('General', KEY_FIRST_RUN_WIZARD) then
    Exit;

  DataDir := IncludeTrailingPathDelimiter(GetHostDataDir) +
             GOVERLAY_FOLDER_NAME + PathDelim;

  HasExistingConfig := AIni.ValueExists('General', 'Version') or
                       AIni.SectionExists('MangoHud') or
                       AIni.SectionExists('vkBasalt') or
                       AIni.SectionExists('OptiScaler') or
                       AIni.SectionExists('LosslessScaling') or
                       AIni.SectionExists('Tweaks');

  HasExistingComponents :=
    FileExists(DataDir + 'optiscaler' + PathDelim + 'OptiScaler.dll') or
    FileExists(DataDir + 'optiscaler-stable' + PathDelim + 'OptiScaler.dll') or
    FileExists(DataDir + 'optiscaler-edge' + PathDelim + 'OptiScaler.dll') or
    FileExists(DataDir + 'optiscaler-helixsr' + PathDelim + 'OptiScaler.dll') or
    FileExists(IncludeTrailingPathDelimiter(GetFgmodFolder) + 'OptiScaler.dll') or
    FileExists(DataDir + 'reshade' + PathDelim + 'ReShade64.dll') or
    FileExists(IncludeTrailingPathDelimiter(GetReshadeFolder) + 'ReShade64.dll') or
    DirectoryExists(DataDir + 'lsfg-vk') or
    DirectoryExists(DataDir + 'mako') or
    DirectoryExists(DataDir + 'afmf');

  if HasExistingConfig or HasExistingComponents then
  begin
    AIni.WriteBool('General', KEY_FIRST_RUN_WIZARD, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_VKBASALT, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_RESHADE, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_VKSUMI, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_OPTISCALER, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_DLSSENABLER, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_HELIXSR, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_LSFGVK, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_MAKO, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_AFMF, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_POSTPROCESSING, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_UPSCALERS, True);
    AIni.WriteBool(SECTION_MODULES, MODULE_FRAMEGENERATION, True);
  end
  else
  begin
    AIni.WriteBool('General', KEY_FIRST_RUN_WIZARD, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_VKBASALT, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_RESHADE, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_VKSUMI, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_OPTISCALER, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_DLSSENABLER, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_HELIXSR, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_LSFGVK, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_MAKO, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_AFMF, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_POSTPROCESSING, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_UPSCALERS, False);
    AIni.WriteBool(SECTION_MODULES, MODULE_FRAMEGENERATION, False);
  end;
end;

// ============================================================================
// OptiScaler/fgmod Paths
// ============================================================================

class function TConfigManager.GetFgmodFolder: string;
begin
  Result := IncludeTrailingPathDelimiter(GetUserHomeDir) + FGMOD_FOLDER_NAME;
end;

class function TConfigManager.GetFgmodScriptFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetFgmodFolder) + FGMOD_SCRIPT_NAME;
end;

class function TConfigManager.GetOptiScalerIniFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetFgmodFolder) + OPTISCALER_INI_FILE;
end;

class function TConfigManager.GetFakeNvapiIniFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetFgmodFolder) + FAKENVAPI_INI_FILE;
end;

class function TConfigManager.GetGoverlayVarsFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetFgmodFolder) + GOVERLAY_VARS_FILE;
end;

// ============================================================================
// XDG / Flatpak-Aware Path Helpers
// ============================================================================

class function TConfigManager.GetHostConfigDir: string;
begin
  // When running inside Flatpak, HOST_XDG_CONFIG_HOME points to the real
  // host config directory so we can read/write configs that are visible to
  // native (non-Flatpak) applications.
  Result := GetEnvironmentVariable('HOST_XDG_CONFIG_HOME');
  if Result = '' then
    Result := GetEnvironmentVariable('XDG_CONFIG_HOME');
  if Result = '' then
    Result := GetUserDir + '.config';
end;

class function TConfigManager.GetHostDataDir: string;
begin
  // When running inside Flatpak, HOST_XDG_DATA_HOME points to the real
  // host data directory.
  Result := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
  if Result = '' then
    Result := GetEnvironmentVariable('XDG_DATA_HOME');
  if Result = '' then
    Result := GetUserDir + '.local/share';
end;

// ============================================================================
// Directory Operations
// ============================================================================

class function TConfigManager.EnsureDirectoryExists(const DirPath: string): Boolean;
begin
  Result := True;
  if not DirectoryExists(DirPath) then
  begin
    try
      ForceDirectories(DirPath);
      Result := DirectoryExists(DirPath);
    except
      Result := False;
    end;
  end;
end;

class function TConfigManager.EnsureAllConfigDirsExist: Boolean;
begin
  Result := EnsureDirectoryExists(GetMangoHudFolder) and
            EnsureDirectoryExists(GetVkBasaltFolder) and
            EnsureDirectoryExists(GetGoverlayFolder) and
            EnsureDirectoryExists(GetFgmodFolder);
end;

// ============================================================================
// File Operations
// ============================================================================

class function TConfigManager.ConfigFileExists(const FilePath: string): Boolean;
begin
  Result := FileExists(FilePath);
end;

class function TConfigManager.ReadConfigFile(const FilePath: string; Lines: TStringList): Boolean;
begin
  Result := False;
  if FileExists(FilePath) then
  begin
    try
      Lines.LoadFromFile(FilePath);
      Result := True;
    except
      Result := False;
    end;
  end;
end;

class function TConfigManager.WriteConfigFile(const FilePath: string; Lines: TStringList): Boolean;
begin
  Result := False;
  try
    // Ensure directory exists
    EnsureDirectoryExists(ExtractFilePath(FilePath));
    Lines.SaveToFile(FilePath);
    Result := True;
  except
    Result := False;
  end;
end;

class function TConfigManager.BackupConfigFile(const FilePath: string): Boolean;
var
  BackupPath: string;
begin
  Result := False;
  if FileExists(FilePath) then
  begin
    try
      BackupPath := FilePath + '.backup';
      CopyFile(FilePath, BackupPath);
      Result := FileExists(BackupPath);
    except
      Result := False;
    end;
  end;
end;

end.
