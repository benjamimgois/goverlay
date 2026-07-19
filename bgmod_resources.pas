unit bgmod_resources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BaseUnix, Process;

// Initialize the bgmod directory with all resources from the shared folder
procedure InitializeBGModDirectory;

// Initialize or sync the isolated global profile config directory
// (gameconfig/global/) from the active bgmod/ directory.
procedure InitializeGlobalConfigDirectory;

// Check if bgmod directory exists and is properly initialized
function IsBGModInitialized: Boolean;

// Get the bgmod installation path (Flatpak-aware)
function GetBGModPath: string;

// Get the pristine bgmod original path (Flatpak-aware).
function GetBGModOriginalPath: string;
function GetBGModOriginalEdgePath: string;

// Compatibility aliases for legacy FGMod calls
function GetFGModPath: string;
function GetFGModOriginalPath: string;
function GetFGModOriginalEdgePath: string;

// Check if OptiScaler is installed in BGMOD directory
function IsBGModOptiScalerInstalled(const ABGModPath: string): Boolean;

// Resolve the directory where compiled bgmod and bgmod-uninstaller binaries are stored
function GetBGModBinariesSourceDir: string;

// Migrate FGMOD/BGMOD from old location if needed
function MigrateBGModToXDG: Boolean;

implementation

uses
  FileUtil, LazFileUtils, IniFiles;

function GetFGModPath: string;
begin
  Result := GetBGModPath;
end;

function GetFGModOriginalPath: string;
begin
  Result := GetBGModOriginalPath;
end;

function GetFGModOriginalEdgePath: string;
begin
  Result := GetBGModOriginalEdgePath;
end;

// Detect if running in Flatpak environment
function IsRunningInFlatpak: Boolean;
begin
  Result := GetEnvironmentVariable('FLATPAK_ID') <> '';
end;

function GetAppBaseDir: string;
var
  AppDir, BinaryDir: string;
begin
  AppDir := GetEnvironmentVariable('APPDIR');
  if AppDir <> '' then
    Result := IncludeTrailingPathDelimiter(AppDir) + 'bin/'
  else
  begin
    BinaryDir := ExtractFilePath(ParamStr(0));
    if DirectoryExists(BinaryDir + 'assets') then
      Result := BinaryDir
    else
      Result := ExtractFilePath(ExtractFileDir(ParamStr(0))) + 'share/goverlay/';
  end;
end;

function GetBGModSourceDir: string;
var
  BaseDir: string;
begin
  BaseDir := GetAppBaseDir;
  if DirectoryExists(BaseDir + 'bgmod') then
    Result := BaseDir + 'bgmod'
  else if DirectoryExists(BaseDir + 'data' + PathDelim + 'bgmod') then
    Result := BaseDir + 'data' + PathDelim + 'bgmod'
  else
    Result := '';
end;

function GetBGModBinariesSourceDir: string;
var
  BinaryDir, AppDirEnv, Candidate: string;
begin
  Result := '';
  BinaryDir := ExtractFilePath(ParamStr(0));

  // Candidate 1: Executable directory (default /usr/libexec/goverlay/ or development folder)
  if FileExists(IncludeTrailingPathDelimiter(BinaryDir) + 'bgmod') then
  begin
    Result := BinaryDir;
    Exit;
  end;

  // Candidate 2: Relative lib/ directory (ExtractFilePath(ExcludeTrailingPathDelimiter(BinaryDir)) + 'lib')
  Candidate := IncludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(BinaryDir))) + 'lib';
  if FileExists(IncludeTrailingPathDelimiter(Candidate) + 'bgmod') then
  begin
    Result := Candidate;
    Exit;
  end;

  // Candidate 3: Environment variable APPDIR (for AppImage compatibility)
  AppDirEnv := GetEnvironmentVariable('APPDIR');
  if AppDirEnv <> '' then
  begin
    Candidate := IncludeTrailingPathDelimiter(AppDirEnv) + 'lib';
    if FileExists(IncludeTrailingPathDelimiter(Candidate) + 'bgmod') then
    begin
      Result := Candidate;
      Exit;
    end;
  end;
end;

// Get the correct bgmod installation path based on environment
function GetBGModPath: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';

  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'bgmod';
end;

// Pristine bgmod copy — always reflects the latest installation assets
function GetBGModOriginalPath: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'optiscaler-stable';
end;

function GetBGModOriginalEdgePath: string;
var
  DataHome: string;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'optiscaler-edge';
end;

// Migrate FGMOD/BGMOD from old location to new XDG-compliant location
function MigrateBGModToXDG: Boolean;
var
  OldPath, NewPath: string;
  SearchRec: TSearchRec;
  SourceFile, DestFile: string;
  MigratedCount: Integer;
begin
  Result := False;
  MigratedCount := 0;
  
  if IsRunningInFlatpak then
    OldPath := GetUserDir + '.var/app/io.github.benjamimgois.goverlay/fgmod'
  else
    OldPath := GetUserDir + 'fgmod';
    
  NewPath := GetBGModPath;
  
  WriteLn('[BGMOD] Checking for auto-migration...');
  if not DirectoryExists(OldPath) then
  begin
    WriteLn('[BGMOD] Old path does not exist, no migration needed');
    Exit;
  end;
  
  if DirectoryExists(NewPath) and FileExists(IncludeTrailingPathDelimiter(NewPath) + 'bgmod') then
  begin
    WriteLn('[BGMOD] New path already exists, skipping migration');
    Exit;
  end;
  
  WriteLn('[BGMOD] Starting migration from old fgmod location...');
  if not ForceDirectories(NewPath) then Exit;
  
  if FindFirst(IncludeTrailingPathDelimiter(OldPath) + '*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          if (SearchRec.Attr and faDirectory) = 0 then
          begin
            SourceFile := IncludeTrailingPathDelimiter(OldPath) + SearchRec.Name;
            
            // Map old filenames to new ones if needed
            DestFile := SearchRec.Name;
            if DestFile = 'fgmod' then DestFile := 'bgmod';
            if DestFile = 'fgmod-uninstaller.sh' then DestFile := 'bgmod-uninstaller.sh';
            if DestFile = 'fgmod-remover.sh' then DestFile := 'bgmod-remover.sh';
            
            DestFile := IncludeTrailingPathDelimiter(NewPath) + DestFile;
            
            if CopyFile(SourceFile, DestFile) then
            begin
              Inc(MigratedCount);
              if (LowerCase(ExtractFileExt(SearchRec.Name)) = '.sh') or (SearchRec.Name = 'fgmod') then
                fpChmod(DestFile, &755);
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
  
  WriteLn('[BGMOD] Migrated ', MigratedCount, ' files.');
  Result := True;
end;

procedure MigrateGlobalConfigToIsolatedFolder;
var
  DataHome: string;
  BGModPath, GlobalCfgDir: string;
  Proc: TProcess;
begin
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';

  BGModPath    := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'bgmod');
  GlobalCfgDir := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'gameconfig' + PathDelim + 'global' + PathDelim;

  // Only run if gameconfig/global/ does not yet have the bgmod binary
  if not FileExists(GlobalCfgDir + 'bgmod') then
  begin
    WriteLn('[BGMOD] Initializing gameconfig/global/ from bgmod/...');
    if ForceDirectories(GlobalCfgDir) then
    begin
      // Copy everything from bgmod/ into gameconfig/global/
      Proc := TProcess.Create(nil);
      try
        Proc.Executable := 'sh';
        Proc.Parameters.Add('-c');
        Proc.Parameters.Add('cp -rf --no-preserve=mode ' +
                            QuotedStr(BGModPath + '.') +
                            ' ' + QuotedStr(GlobalCfgDir) + ' 2>/dev/null');
        Proc.Options := [poWaitOnExit];
        Proc.Execute;
      finally
        Proc.Free;
      end;
      // Make binaries executable
      fpChmod(PChar(GlobalCfgDir + 'bgmod'), &755);
      fpChmod(PChar(GlobalCfgDir + 'bgmod-uninstaller'), &755);
      WriteLn('[BGMOD] gameconfig/global/ initialized from bgmod/');
    end;
  end
  else
    WriteLn('[BGMOD] gameconfig/global/ already initialized, skipping migration.');
end;


procedure InitializeBGModDirectory;
var
  SourceDir, OriginalPath, BGModPath, BinaryDir, LegacyOrigPath: string;
  Proc: TProcess;
begin
  // Handle any migration from older versions first
  MigrateBGModToXDG;

  OriginalPath := GetBGModOriginalPath;
  BGModPath    := GetBGModPath;
  SourceDir    := GetBGModSourceDir;

  WriteLn('[BGMOD] Source directory     : ', SourceDir);
  WriteLn('[BGMOD] Stable cache path    : ', OriginalPath);
  WriteLn('[BGMOD] Active config path  : ', BGModPath);

  if SourceDir = '' then
  begin
    WriteLn('[BGMOD] ERROR: Source bgmod directory not found!');
    Exit;
  end;

  // Migration of legacy .bgmod_original to optiscaler-stable
  LegacyOrigPath := IncludeTrailingPathDelimiter(ExtractFileDir(OriginalPath)) + '.bgmod_original';
  if DirectoryExists(LegacyOrigPath) then
  begin
    if not DirectoryExists(OriginalPath) then
    begin
      WriteLn('[BGMOD] Migrating legacy .bgmod_original to optiscaler-stable...');
      if not RenameFile(LegacyOrigPath, OriginalPath) then
        WriteLn('[BGMOD] WARNING: Failed to rename legacy cache folder');
    end
    else
    begin
      WriteLn('[BGMOD] Removing legacy .bgmod_original folder...');
      try
        DeleteDirectory(LegacyOrigPath, False);
      except
        on E: Exception do
          WriteLn('[BGMOD] WARNING: Failed to remove legacy cache folder: ', E.Message);
      end;
    end;
  end;

  // Initialize the bgmod/ template directory with wrapper scripts
  if not ForceDirectories(BGModPath) then
  begin
    WriteLn('[BGMOD] ERROR: cannot create bgmod directory, aborting.');
    Exit;
  end;

  WriteLn('[BGMOD] Copying pristine resources to bgmod template directory...');
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('cp -rf --no-preserve=mode ' + QuotedStr(IncludeTrailingPathDelimiter(SourceDir) + '.') +
                        ' ' + QuotedStr(BGModPath) + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // Copy architecture-dependent binaries from GOverlay's executable directory (libexec/goverlay/)
  BinaryDir := GetBGModBinariesSourceDir;
  if BinaryDir <> '' then
  begin
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'sh';
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('cp -f --no-preserve=mode ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BinaryDir) + 'bgmod') + ' ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BinaryDir) + 'bgmod-uninstaller') + ' ' +
                          QuotedStr(BGModPath) + '/ 2>/dev/null');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;
  end
  else
    WriteLn('[BGMOD] WARNING: Compiled bgmod templates not found in any candidate directory!');

  // Make sure binaries are executable
  if FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod') then
    fpChmod(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod', &755);
  if FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller') then
    fpChmod(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller', &755);

  // Create backward compatibility symlink for fgmod in bgmod path
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('ln -sf bgmod ' + QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'fgmod') + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // Copy wrapper scripts from bgmod/ to optiscaler-stable, and also to optiscaler-edge if it exists
  OriginalPath := GetBGModOriginalPath;
  if DirectoryExists(OriginalPath) then
  begin
    WriteLn('[BGMOD] Copying wrapper scripts to optiscaler-stable cache...');
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'sh';
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('cp -f --no-preserve=mode ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod') + ' ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller') + ' ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'fgmod') + ' ' +
                          QuotedStr(OriginalPath) + '/ 2>/dev/null');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;
  end;

  OriginalPath := GetBGModOriginalEdgePath;
  if DirectoryExists(OriginalPath) then
  begin
    WriteLn('[BGMOD] Copying wrapper scripts to optiscaler-edge cache...');
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'sh';
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('cp -f --no-preserve=mode ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod') + ' ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller') + ' ' +
                          QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + 'fgmod') + ' ' +
                          QuotedStr(OriginalPath) + '/ 2>/dev/null');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;
  end;

  WriteLn('[BGMOD] bgmod template directory resources initialized.');

end;

procedure InitializeGlobalConfigDirectory;
var
  BGModPath, GlobalCfgDir, DataHomeEnv, GlobalConf, CacheDir: string;
  Proc: TProcess;
  IsStable, IsOptiEnabled: Boolean;
  Ini: TIniFile;
begin
  BGModPath := GetBGModPath;

  // Ensure gameconfig/global/ exists as a full copy of bgmod/ (first run),
  // then keep its binaries/DLLs up-to-date on subsequent runs (skip user configs).
  DataHomeEnv := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHomeEnv = '' then
    DataHomeEnv := GetUserDir + '.local/share';
  GlobalCfgDir := IncludeTrailingPathDelimiter(
    IncludeTrailingPathDelimiter(DataHomeEnv) + 'goverlay' + PathDelim + 'gameconfig' + PathDelim + 'global');

  if not FileExists(GlobalCfgDir + 'bgmod') then
  begin
    // First time: copy EVERYTHING from bgmod/ to gameconfig/global/
    WriteLn('[BGMOD] Initializing gameconfig/global/ from bgmod/...');
    if ForceDirectories(GlobalCfgDir) then
    begin
      Proc := TProcess.Create(nil);
      try
        Proc.Executable := 'sh';
        Proc.Parameters.Add('-c');
        Proc.Parameters.Add('cp -rf --no-preserve=mode ' +
                            QuotedStr(IncludeTrailingPathDelimiter(BGModPath) + '.') +
                            ' ' + QuotedStr(GlobalCfgDir) + ' 2>/dev/null');
        Proc.Options := [poWaitOnExit];
        Proc.Execute;
      finally
        Proc.Free;
      end;
      WriteLn('[BGMOD] gameconfig/global/ initialized from bgmod/');
    end;
  end
  else
  begin
    // Subsequent runs: sync only binaries/DLLs (exclude user config files)
    WriteLn('[BGMOD] Syncing binaries/DLLs to gameconfig/global/...');
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := 'sh';
      Proc.Parameters.Add('-c');
      Proc.Parameters.Add('rsync -a --no-owner --no-group' +
                          ' --exclude=bgmod.conf --exclude=goverlay.vars' +
                          ' --exclude=OptiScaler.ini --exclude=fakenvapi.ini' +
                          ' ' + QuotedStr(IncludeTrailingPathDelimiter(BGModPath)) +
                          ' ' + QuotedStr(GlobalCfgDir) +
                          ' 2>/dev/null');
      Proc.Options := [poWaitOnExit];
      Proc.Execute;
    finally
      Proc.Free;
    end;

    // Read OPT_CHANNEL and GOVERLAY_OPTISCALER from bgmod.conf
    IsStable := True;
    IsOptiEnabled := False;
    GlobalConf := GlobalCfgDir + 'bgmod.conf';
    if FileExists(GlobalConf) then
    begin
      Ini := TIniFile.Create(GlobalConf);
      try
        IsStable := Ini.ReadInteger('Config', 'OPT_CHANNEL', 0) <> 1;
        IsOptiEnabled := Ini.ReadString('Config', 'GOVERLAY_OPTISCALER', '0') = '1';
      finally
        Ini.Free;
      end;
    end;

    // Then, if OptiScaler is enabled, sync DLLs and plugins from the correct cache folder
    if IsOptiEnabled then
    begin
      if IsStable then
        CacheDir := GetBGModOriginalPath
      else
        CacheDir := GetBGModOriginalEdgePath;

      WriteLn('[BGMOD] Syncing OptiScaler assets from ', CacheDir, ' to gameconfig/global/...');
      Proc := TProcess.Create(nil);
      try
        Proc.Executable := 'sh';
        Proc.Parameters.Add('-c');
        Proc.Parameters.Add(
          'Source=' + QuotedStr(IncludeTrailingPathDelimiter(CacheDir)) + '; ' +
          'Target=' + QuotedStr(GlobalCfgDir) + '; ' +
          'for f in "$Source"*.dll; do ' +
          '  [ -f "$f" ] && cp -f "$f" "$Target"; ' +
          'done; ' +
          'if [ -f "$Source"fakenvapi.ini ] && [ ! -f "$Target"fakenvapi.ini ]; then ' +
          '  cp "$Source"fakenvapi.ini "$Target"; ' +
          'fi; ' +
          'if [ -d "$Source"plugins ]; then ' +
          '  cp -rf "$Source"plugins "$Target"; ' +
          'fi; ' +
          'if [ -d "$Source"FSR4_LATEST ]; then ' +
          '  cp -rf "$Source"FSR4_LATEST "$Target"; ' +
          'fi; ' +
          'if [ -d "$Source"FSR4_INT8 ]; then ' +
          '  cp -rf "$Source"FSR4_INT8 "$Target"; ' +
          'fi 2>/dev/null');
        Proc.Options := [poWaitOnExit];
        Proc.Execute;
      finally
        Proc.Free;
      end;
    end;
  end;

  // Ensure binaries are executable in gameconfig/global/
  if FileExists(GlobalCfgDir + 'bgmod') then
    fpChmod(PChar(GlobalCfgDir + 'bgmod'), &755);
  if FileExists(GlobalCfgDir + 'bgmod-uninstaller') then
    fpChmod(PChar(GlobalCfgDir + 'bgmod-uninstaller'), &755);
end;

function IsBGModInitialized: Boolean;
var
  BGModPath: string;
begin
  BGModPath := GetBGModPath;
  Result := DirectoryExists(BGModPath) and
            FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod') and
            FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller');
end;

function IsBGModOptiScalerInstalled(const ABGModPath: string): Boolean;
var
  OptiScalerDLL: string;
begin
  OptiScalerDLL := IncludeTrailingPathDelimiter(ABGModPath) + 'OptiScaler.dll';
  Result := FileExists(OptiScalerDLL);
end;

end.
