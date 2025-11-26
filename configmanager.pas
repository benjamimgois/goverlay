unit configmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, constants;

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
  Result := IncludeTrailingPathDelimiter(GetUserConfigDir) + MANGOHUD_FOLDER_NAME;
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
  Result := IncludeTrailingPathDelimiter(GetUserConfigDir) + VKBASALT_FOLDER_NAME;
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
