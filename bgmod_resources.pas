unit bgmod_resources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BaseUnix, Process;

// Initialize the bgmod directory with all resources from the shared folder
procedure InitializeBGModDirectory;

// Check if bgmod directory exists and is properly initialized
function IsBGModInitialized: Boolean;

// Get the bgmod installation path (Flatpak-aware)
function GetBGModPath: string;

// Get the pristine bgmod original path (Flatpak-aware).
function GetBGModOriginalPath: string;

// Compatibility aliases for legacy FGMod calls
function GetFGModPath: string;
function GetFGModOriginalPath: string;

// Check if OptiScaler is installed in BGMOD directory
function IsBGModOptiScalerInstalled(const ABGModPath: string): Boolean;

// Migrate FGMOD/BGMOD from old location if needed
function MigrateBGModToXDG: Boolean;

implementation

uses
  FileUtil, LazFileUtils;

function GetFGModPath: string;
begin
  Result := GetBGModPath;
end;

function GetFGModOriginalPath: string;
begin
  Result := GetBGModOriginalPath;
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
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + '.bgmod_original';
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
  SourceDir, OriginalPath, BGModPath, BinaryDir: string;
  GlobalCfgDir, DataHomeEnv: string;
  Proc: TProcess;
begin
  // Handle any migration from older versions first
  MigrateBGModToXDG;

  OriginalPath := GetBGModOriginalPath;
  BGModPath    := GetBGModPath;
  SourceDir    := GetBGModSourceDir;

  WriteLn('[BGMOD] Source directory     : ', SourceDir);
  WriteLn('[BGMOD] Original path (.b)  : ', OriginalPath);
  WriteLn('[BGMOD] Active config path  : ', BGModPath);

  if SourceDir = '' then
  begin
    WriteLn('[BGMOD] ERROR: Source bgmod directory not found!');
    Exit;
  end;

  // 1. Copy pristine files from SourceDir to OriginalPath
  if not ForceDirectories(OriginalPath) then
  begin
    WriteLn('[BGMOD] ERROR: cannot create .bgmod_original directory, aborting.');
    Exit;
  end;

  WriteLn('[BGMOD] Copying pristine resources to .bgmod_original...');
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('cp -rf --no-preserve=mode ' + QuotedStr(IncludeTrailingPathDelimiter(SourceDir) + '.') +
                        ' ' + QuotedStr(OriginalPath) + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // Copy architecture-dependent binaries from GOverlay's executable directory (libexec/goverlay/)
  BinaryDir := ExtractFilePath(ParamStr(0));
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('cp -f --no-preserve=mode ' +
                        QuotedStr(IncludeTrailingPathDelimiter(BinaryDir) + 'bgmod') + ' ' +
                        QuotedStr(IncludeTrailingPathDelimiter(BinaryDir) + 'bgmod-uninstaller') + ' ' +
                        QuotedStr(OriginalPath) + '/ 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  // Make sure binaries are executable
  if FileExists(IncludeTrailingPathDelimiter(OriginalPath) + 'bgmod') then
    fpChmod(IncludeTrailingPathDelimiter(OriginalPath) + 'bgmod', &755);
  if FileExists(IncludeTrailingPathDelimiter(OriginalPath) + 'bgmod-uninstaller') then
    fpChmod(IncludeTrailingPathDelimiter(OriginalPath) + 'bgmod-uninstaller', &755);

  // Create backward compatibility symlink for fgmod in original path
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    Proc.Parameters.Add('ln -sf bgmod ' + QuotedStr(IncludeTrailingPathDelimiter(OriginalPath) + 'fgmod') + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;

  WriteLn('[BGMOD] .bgmod_original resources initialized.');

  // 2. Refresh active config path with the latest bgmod binaries/scripts
  ForceDirectories(BGModPath);
  WriteLn('[BGMOD] Refreshing active bgmod directory from .bgmod_original...');

  // Refresh bgmod/ with the latest binaries and assets from .bgmod_original,
  // but deliberately skip user config files which now live in gameconfig/global/.
  Proc := TProcess.Create(nil);
  try
    Proc.Executable := 'sh';
    Proc.Parameters.Add('-c');
    // Use rsync to copy everything except config files that belong in gameconfig/global/
    Proc.Parameters.Add('rsync -a --no-owner --no-group' +
                        ' --exclude=bgmod.conf --exclude=goverlay.vars' +
                        ' --exclude=OptiScaler.ini --exclude=fakenvapi.ini' +
                        ' ' + QuotedStr(IncludeTrailingPathDelimiter(OriginalPath)) +
                        ' ' + QuotedStr(IncludeTrailingPathDelimiter(BGModPath)) +
                        ' 2>/dev/null || ' +
                        // Fallback to cp if rsync is not available
                        'cp -rf ' + QuotedStr(IncludeTrailingPathDelimiter(OriginalPath) + '.') +
                        ' ' + QuotedStr(BGModPath) + ' 2>/dev/null');
    Proc.Options := [poWaitOnExit];
    Proc.Execute;
  finally
    Proc.Free;
  end;


  // Make sure binaries are executable in active config path
  if FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod') then
    fpChmod(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod', &755);
  if FileExists(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller') then
    fpChmod(IncludeTrailingPathDelimiter(BGModPath) + 'bgmod-uninstaller', &755);

  // Create backward compatibility symlink for fgmod in active path
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
