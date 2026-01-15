unit fgmod_resources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BaseUnix;

// Initialize the fgmod directory with all embedded scripts
// This should be called at application startup
procedure InitializeFGModDirectory;

// Check if fgmod directory exists and is properly initialized
function IsFGModInitialized: Boolean;

// Get the fgmod installation path (Flatpak-aware)
function GetFGModPath: string;

// Migrate FGMOD from old location to new XDG-compliant location
// Returns True if migration was performed, False if skipped
function MigrateFGModToXDG: Boolean;

implementation

uses
  FileUtil, LazFileUtils;

// Detect if running in Flatpak environment
function IsRunningInFlatpak: Boolean;
begin
  Result := GetEnvironmentVariable('FLATPAK_ID') <> '';
end;

// Get the correct fgmod installation path based on environment
// For Flatpak, this uses HOST_XDG_DATA_HOME to access the real host location
// For native, this uses XDG_DATA_HOME to follow XDG Base Directory specification
// Returns: ~/.local/share/goverlay/fgmod for both Flatpak and native installations
function GetFGModPath: string;
var
  DataHome: string;
  UserName: string;
begin
  // For Flatpak, try HOST_XDG_DATA_HOME first to access the real host location
  DataHome := GetEnvironmentVariable('HOST_XDG_DATA_HOME');
  
  // If in Flatpak and HOST_XDG_DATA_HOME is not available, construct the host path manually
  if (DataHome = '') and IsRunningInFlatpak then
  begin
    UserName := GetEnvironmentVariable('USER');
    if UserName <> '' then
      DataHome := '/home/' + UserName + '/.local/share'
    else
      DataHome := GetUserDir + '.local/share';
  end;
  
  // Fall back to standard XDG_DATA_HOME for native installations
  if DataHome = '' then
    DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  
  // Final fallback to ~/.local/share
  if DataHome = '' then
    DataHome := GetUserDir + '.local/share';
  
  Result := IncludeTrailingPathDelimiter(DataHome) + 'goverlay' + PathDelim + 'fgmod';
end;

// Migrate FGMOD from old location to new XDG-compliant location
// Returns True if migration was performed, False if skipped
function MigrateFGModToXDG: Boolean;
var
  OldPath, NewPath: string;
  SearchRec: TSearchRec;
  SourceFile, DestFile: string;
  MigratedCount: Integer;
begin
  Result := False;
  MigratedCount := 0;
  
  // Determine old path based on environment
  if IsRunningInFlatpak then
    OldPath := GetUserDir + '.var/app/io.github.benjamimgois.goverlay/fgmod'
  else
    OldPath := GetUserDir + 'fgmod';
  
  NewPath := GetFGModPath;
  
  WriteLn('[FGMOD] Checking for auto-migration...');
  WriteLn('[FGMOD] Old path: ', OldPath);
  WriteLn('[FGMOD] New path: ', NewPath);
  
  // Check if old path exists
  if not DirectoryExists(OldPath) then
  begin
    WriteLn('[FGMOD] Old path does not exist, no migration needed');
    Exit;
  end;
  
  // Check if new path already exists and has the main fgmod script
  if DirectoryExists(NewPath) then
  begin
    if FileExists(IncludeTrailingPathDelimiter(NewPath) + 'fgmod') then
    begin
      WriteLn('[FGMOD] New path already exists with fgmod script, skipping migration');
      Exit;
    end;
  end;
  
  // Create new directory structure
  WriteLn('[FGMOD] ===========================================');
  WriteLn('[FGMOD] Starting automatic migration...');
  WriteLn('[FGMOD] ===========================================');
  
  if not ForceDirectories(NewPath) then
  begin
    WriteLn('[ERROR] Failed to create new directory: ', NewPath);
    Exit;
  end;
  
  // Copy all files from old to new location
  if FindFirst(IncludeTrailingPathDelimiter(OldPath) + '*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          // Only process files, not subdirectories
          if (SearchRec.Attr and faDirectory) = 0 then
          begin
            SourceFile := IncludeTrailingPathDelimiter(OldPath) + SearchRec.Name;
            DestFile := IncludeTrailingPathDelimiter(NewPath) + SearchRec.Name;
            
            try
              if CopyFile(SourceFile, DestFile) then
              begin
                WriteLn('[FGMOD]   ✓ Migrated: ', SearchRec.Name);
                Inc(MigratedCount);
                
                // Preserve executable permission for scripts
                if (LowerCase(ExtractFileExt(SearchRec.Name)) = '.sh') or 
                   (SearchRec.Name = 'fgmod') then
                begin
                  fpChmod(DestFile, &755);  // rwxr-xr-x
                  WriteLn('[FGMOD]     → Preserved executable permission');
                end;
              end
              else
                WriteLn('[WARN]   ✗ Failed to copy: ', SearchRec.Name);
            except
              on E: Exception do
                WriteLn('[ERROR]   ✗ Exception copying ', SearchRec.Name, ': ', E.Message);
            end;
          end;
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
  
  // Verify migration success
  if FileExists(IncludeTrailingPathDelimiter(NewPath) + 'fgmod') then
  begin
    WriteLn('[FGMOD] ===========================================');
    WriteLn('[FGMOD] Migration completed successfully!');
    WriteLn('[FGMOD] Files migrated: ', MigratedCount);
    WriteLn('[FGMOD] ===========================================');
    WriteLn('[FGMOD] Old location: ', OldPath);
    WriteLn('[FGMOD] New location: ', NewPath);
    WriteLn('[FGMOD] You can safely delete the old directory manually');
    WriteLn('[FGMOD] ===========================================');
    Result := True;
  end
  else
  begin
    WriteLn('[ERROR] Migration verification failed - fgmod script not found in new location');
    WriteLn('[ERROR] Old directory kept at: ', OldPath);
  end;
end;

// ============================================================================
// EMBEDDED SCRIPT: fgmod (main installer script)
// ============================================================================
function GetFGModScript: string;
begin

  Result :=
    '#!/usr/bin/env bash' + LineEnding +
    '' + LineEnding +
    'set -x' + LineEnding +
    'exec > >(tee -i /tmp/fgmod-install.log) 2>&1' + LineEnding +
    '' + LineEnding +
    'error_exit() {' + LineEnding +
    '  echo "❌ $1"' + LineEnding +
    '  if [[ -n $STEAM_ZENITY ]]; then' + LineEnding +
    '    $STEAM_ZENITY --error --text "$1"' + LineEnding +
    '  else ' + LineEnding +
    '    zenity --error --text "$1" || echo "Zenity failed to display error"' + LineEnding +
    '  fi' + LineEnding +
    '  logger -t fgmod "❌ ERROR: $1"' + LineEnding +
    '  exit 1' + LineEnding +
    '}' + LineEnding +
    '' + LineEnding +
    '# === CONFIG ===' + LineEnding +
    'fgmod_path="$(dirname "$0")"' + LineEnding +
    'dll_name="${DLL:-dxgi.dll}"' + LineEnding +
    'preserve_ini="${PRESERVE_INI:-true}"' + LineEnding +
    '' + LineEnding +
    '# === Resolve Game Path ===' + LineEnding +
    'if [[ "$#" -lt 1 ]]; then' + LineEnding +
    '  error_exit "Usage: $0 program [program_arguments...]"' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    'exe_folder_path=""' + LineEnding +
    'if [[ $# -eq 1 ]]; then' + LineEnding +
    '  [[ "$1" == *.exe ]] && exe_folder_path=$(dirname "$1") || exe_folder_path="$1"' + LineEnding +
    'else' + LineEnding +
    '  for arg in "$@"; do' + LineEnding +
    '    if [[ "$arg" == *.exe ]]; then' + LineEnding +
    '      [[ "$arg" == *"Cyberpunk 2077"* ]] && arg=${arg//REDprelauncher.exe/bin/x64/Cyberpunk2077.exe}' + LineEnding +
    '      [[ "$arg" == *"Witcher 3"* ]]      && arg=${arg//REDprelauncher.exe/bin/x64_dx12/witcher3.exe}' + LineEnding +
    '      [[ "$arg" == *"Baldurs Gate 3"* ]] && arg=${arg//Launcher\/LariLauncher.exe/bin/bg3_dx11.exe}' + LineEnding +
    '      [[ "$arg" == *"HITMAN 3"* ]]       && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}' + LineEnding +
    '      [[ "$arg" == *"HITMAN World of Assassination"* ]] && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}' + LineEnding +
    '      [[ "$arg" == *"SYNCED"* ]]         && arg=${arg//Launcher\/sop_launcher.exe/SYNCED.exe}' + LineEnding +
    '      [[ "$arg" == *"2KLauncher"* ]]     && arg=${arg//2KLauncher\/LauncherPatcher.exe/DoesntMatter.exe}' + LineEnding +
    '      [[ "$arg" == *"Warhammer 40,000 DARKTIDE"* ]] && arg=${arg//launcher\/Launcher.exe/binaries/Darktide.exe}' + LineEnding +
    '      [[ "$arg" == *"Warhammer Vermintide 2"* ]]    && arg=${arg//launcher\/Launcher.exe/binaries_dx12/vermintide2_dx12.exe}' + LineEnding +
    '      [[ "$arg" == *"Satisfactory"* ]]   && arg=${arg//FactoryGameSteam.exe/Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe}' + LineEnding +
    '      [[ "$arg" == *"FINAL FANTASY XIV Online"* ]] && arg=${arg//boot\/ffxivboot.exe/game/ffxiv_dx11.exe}' + LineEnding +
    '      [[ "$arg" == *"DuneAwakening"* ]]    && arg=${arg//Launcher\/FuncomLauncher.exe/DuneSandbox/Binaries/Win64/DuneSandbox-Win64-Shipping.exe}' + LineEnding +
    '      exe_folder_path=$(dirname "$arg")' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '  done' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    'for arg in "$@"; do' + LineEnding +
    '  if [[ "$arg" == lutris:rungameid/* ]]; then' + LineEnding +
    '    lutris_id="${arg#lutris:rungameid/}"' + LineEnding +
    '' + LineEnding +
    '    # Get slug from Lutris JSON' + LineEnding +
    '    slug=$(lutris --list-games --json 2>/dev/null | jq -r ".[] | select(.id == $lutris_id) | .slug")' + LineEnding +
    '' + LineEnding +
    '    if [[ -z "$slug" || "$slug" == "null" ]]; then' + LineEnding +
    '      echo "Could not find slug for Lutris ID $lutris_id"' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    # Find matching YAML file using slug' + LineEnding +
    '    config_file=$(find ~/.config/lutris/games/ -iname "${slug}-*.yml" | head -1)' + LineEnding +
    '' + LineEnding +
    '    if [[ -z "$config_file" ]]; then' + LineEnding +
    '      echo "No config file found for slug ''$slug''"' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    # Extract executable path from YAML' + LineEnding +
    '    exe_path=$(grep -E ''^\s*exe:'' "$config_file" | sed ''s/.*exe:[[:space:]]*//'' )' + LineEnding +
    '' + LineEnding +
    '    if [[ -n "$exe_path" ]]; then' + LineEnding +
    '      exe_folder_path=$(dirname "$exe_path")' + LineEnding +
    '      echo "Resolved executable path: $exe_path"' + LineEnding +
    '      echo "Executable folder: $exe_folder_path"' + LineEnding +
    '    else' + LineEnding +
    '      echo "Executable path not found in $config_file"' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    break' + LineEnding +
    '  fi' + LineEnding +
    'done' + LineEnding +
    '' + LineEnding +
    '[[ -z "$exe_folder_path" && -n "$STEAM_COMPAT_INSTALL_PATH" ]] && exe_folder_path="$STEAM_COMPAT_INSTALL_PATH"' + LineEnding +
    '' + LineEnding +
    'if [[ -d "$exe_folder_path/Engine" ]]; then' + LineEnding +
    '  ue_exe=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 -path "*Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)' + LineEnding +
    '  exe_folder_path=$(dirname "$ue_exe")' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '[[ ! -d "$exe_folder_path" ]] && error_exit "❌ Could not resolve game directory!"' + LineEnding +
    '[[ ! -w "$exe_folder_path" ]] && error_exit "🛑 No write permission to the game folder!"' + LineEnding +
    '' + LineEnding +
    'logger -t fgmod "🟢 Target directory: $exe_folder_path"' + LineEnding +
    'logger -t fgmod "🧩 Using DLL name: $dll_name"' + LineEnding +
    'logger -t fgmod "📄 Preserve INI: $preserve_ini"' + LineEnding +
    '' + LineEnding +
    '# === Cleanup Old Injectors ===' + LineEnding +
    'rm -f "$exe_folder_path"/{dxgi.dll,winmm.dll,nvngx.dll,_nvngx.dll,nvngx-wrapper.dll,dlss-enabler.dll,OptiScaler.dll}' + LineEnding +
    '' + LineEnding +
    '# === Optional: Backup Original DLLs ===' + LineEnding +
    'original_dlls=("d3dcompiler_47.dll" "amd_fidelityfx_dx12.dll" "amd_fidelityfx_framegeneration_dx12.dll" "amd_fidelityfx_upscaler_dx12.dll" "amd_fidelityfx_vk.dll")' + LineEnding +
    'for dll in "${original_dlls[@]}"; do' + LineEnding +
    '  [[ -f "$exe_folder_path/$dll" && ! -f "$exe_folder_path/$dll.b" ]] && mv -f "$exe_folder_path/$dll" "$exe_folder_path/$dll.b"' + LineEnding +
    'done' + LineEnding +
    '' + LineEnding +
    '# === Remove nvapi64.dll and its backup (conflicts from previous fakenvapi versions) ===' + LineEnding +
    'rm -f "$exe_folder_path/nvapi64.dll" "$exe_folder_path/nvapi64.dll.b"' + LineEnding +
    'echo "🧹 Cleaned up nvapi64.dll and backup (legacy fakenvapi conflicts)"' + LineEnding +
    '' + LineEnding +
    '# === Core Install ===' + LineEnding +
    'if [[ -f "$fgmod_path/renames/$dll_name" ]]; then' + LineEnding +
    '  echo "✅ Using pre-renamed $dll_name"' + LineEnding +
    '  cp "$fgmod_path/renames/$dll_name" "$exe_folder_path/$dll_name" || error_exit "❌ Failed to copy $dll_name"' + LineEnding +
    'else' + LineEnding +
    '  echo "⚠️ Pre-renamed $dll_name not found, falling back to OptiScaler.dll"' + LineEnding +
    '  cp "$fgmod_path/OptiScaler.dll" "$exe_folder_path/$dll_name" || error_exit "❌ Failed to copy OptiScaler.dll as $dll_name"' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# === OptiScaler.ini Handling ===' + LineEnding +
    'if [[ "$preserve_ini" == "true" && -f "$exe_folder_path/OptiScaler.ini" ]]; then' + LineEnding +
    '  echo "📄 Preserving existing OptiScaler.ini (user settings retained)"' + LineEnding +
    '  logger -t fgmod "📄 Existing OptiScaler.ini preserved in $exe_folder_path"' + LineEnding +
    'else' + LineEnding +
    '  echo "📄 Installing OptiScaler.ini from plugin defaults"' + LineEnding +
    '  cp "$fgmod_path/OptiScaler.ini" "$exe_folder_path/OptiScaler.ini" || error_exit "❌ Failed to copy OptiScaler.ini"' + LineEnding +
    '  logger -t fgmod "📄 OptiScaler.ini installed to $exe_folder_path"' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# === ASI Plugins Directory ===' + LineEnding +
    'if [[ -d "$fgmod_path/plugins" ]]; then' + LineEnding +
    '  echo "🔌 Installing ASI plugins directory"' + LineEnding +
    '  cp -r "$fgmod_path/plugins" "$exe_folder_path/" || true' + LineEnding +
    '  logger -t fgmod "🔌 ASI plugins directory installed to $exe_folder_path"' + LineEnding +
    'else' + LineEnding +
    '  echo "⚠️ No plugins directory found in fgmod"' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# === Supporting Libraries ===' + LineEnding +
    'cp -f "$fgmod_path/libxess.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/libxess_dx11.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/libxess_fg.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/libxell.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/amd_fidelityfx_dx12.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/amd_fidelityfx_framegeneration_dx12.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/amd_fidelityfx_upscaler_dx12.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/amd_fidelityfx_vk.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/nvngx.dll" "$exe_folder_path/" || true' + LineEnding +
    '' + LineEnding +
    '# === Nukem FG Mod Files (now in fgmod directory) ===' + LineEnding +
    'cp -f "$fgmod_path/dlssg_to_fsr3_amd_is_better.dll" "$exe_folder_path/" || true' + LineEnding +
    '# Note: dlssg_to_fsr3.ini is not included in v0.9.0-pre4 archive' + LineEnding +
    '' + LineEnding +
    '# === FakeNVAPI Files ===' + LineEnding +
    '# Remove legacy nvapi64.dll to avoid conflicts' + LineEnding +
    '# rm -f "$exe_folder_path/nvapi64.dll"' + LineEnding +
    '# echo "🧹 Removed legacy nvapi64.dll"' + LineEnding +
    '' + LineEnding +
    '# Copy fakenvapi.dll with original name (v1.3.8.1) ' + LineEnding +
    'cp -f "$fgmod_path/fakenvapi.dll" "$exe_folder_path/" || true' + LineEnding +
    'cp -f "$fgmod_path/fakenvapi.ini" "$exe_folder_path/" || true' + LineEnding +
    'echo "📦 Installed fakenvapi.dll and fakenvapi.ini"' + LineEnding +
    '' + LineEnding +
    '# === Additional Support Files ===' + LineEnding +
    '# cp -f "$fgmod_path/d3dcompiler_47.dll" "$exe_folder_path/" || true' + LineEnding +
    '' + LineEnding +
    '# Note: d3dcompiler_47.dll is not included in v0.9.0-pre4 archive' + LineEnding +
    '' + LineEnding +
    'echo "✅ Installation completed successfully!"' + LineEnding +
    'echo "📄 For Steam, add this to the launch options: \"$fgmod_path/fgmod\" %COMMAND%"' + LineEnding +
    'echo "📄 For Heroic, add this as a new wrapper: \"$fgmod_path/fgmod\""' + LineEnding +
    'logger -t fgmod "🟢 Installation completed successfully for $exe_folder_path"' + LineEnding +
    '' + LineEnding +
    '# === Execute original command ===' + LineEnding +
    'if [[ $# -gt 1 ]]; then' + LineEnding +
    '  # Log to both file and system journal' + LineEnding +
    '  logger -t fgmod "=================="' + LineEnding +
    '  logger -t fgmod "Debug Info (Launch Mode):"' + LineEnding +
    '  logger -t fgmod "Number of arguments: $#"' + LineEnding +
    '  for i in $(seq 1 $#); do' + LineEnding +
    '    logger -t fgmod "Arg $i: ${!i}"' + LineEnding +
    '  done' + LineEnding +
    '  logger -t fgmod "Final executable path: $exe_folder_path"' + LineEnding +
    '  logger -t fgmod "=================="' + LineEnding +
    '  ' + LineEnding +
    '  # Execute the original command' + LineEnding +
    '  export SteamDeck=0' + LineEnding +
    '  export WINEDLLOVERRIDES="$WINEDLLOVERRIDES,dxgi=n,b"' + LineEnding +
    '  exec "$@"' + LineEnding +
    'else' + LineEnding +
    '  echo "Done!"' + LineEnding +
    '  echo "----------------------------------------"' + LineEnding +
    '  echo "Debug Info (Standalone Mode):"' + LineEnding +
    '  echo "Number of arguments: $#"' + LineEnding +
    '  for i in $(seq 1 $#); do' + LineEnding +
    '    echo "Arg $i: ${!i}"' + LineEnding +
    '  done' + LineEnding +
    '  echo "Final executable path: $exe_folder_path"' + LineEnding +
    '  echo "----------------------------------------"' + LineEnding +
    '  ' + LineEnding +
    '  # Also log standalone mode to journal' + LineEnding +
    '  logger -t fgmod "=================="' + LineEnding +
    '  logger -t fgmod "Debug Info (Standalone Mode):"' + LineEnding +
    '  logger -t fgmod "Number of arguments: $#"' + LineEnding +
    '  for i in $(seq 1 $#); do' + LineEnding +
    '    logger -t fgmod "Arg $i: ${!i}"' + LineEnding +
    '  done' + LineEnding +
    '  logger -t fgmod "Final executable path: $exe_folder_path"' + LineEnding +
    '  logger -t fgmod "=================="' + LineEnding +
    'fi' + LineEnding;
end;

// ============================================================================
// EMBEDDED SCRIPT: fgmod-uninstaller.sh
// ============================================================================
function GetFGModUninstallerScript: string;
begin

  Result :=
    '#!/usr/bin/env bash' + LineEnding +
    '' + LineEnding +
    'set -x' + LineEnding +
    'exec > >(tee -i /tmp/fgmod-uninstaller.log) 2>&1' + LineEnding +
    '' + LineEnding +
    'error_exit() {' + LineEnding +
    '  echo "❌ $1"' + LineEnding +
    '  if [[ -n $STEAM_ZENITY ]]; then' + LineEnding +
    '    $STEAM_ZENITY --error --text "$1"' + LineEnding +
    '  else ' + LineEnding +
    '    zenity --error --text "$1" || echo "Zenity failed to display error"' + LineEnding +
    '  fi' + LineEnding +
    '  logger -t fgmod-uninstaller "❌ ERROR: $1"' + LineEnding +
    '  exit 1' + LineEnding +
    '}' + LineEnding +
    '' + LineEnding +
    'if [ "$#" -lt 1 ]; then' + LineEnding +
    '  echo "Usage: $0 program [program_arguments...]"' + LineEnding +
    '  exit 1' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# === Resolve Game Path ===' + LineEnding +
    'exe_folder_path=""' + LineEnding +
    'if [[ "$1" == *.exe ]]; then' + LineEnding +
    '  exe_folder_path=$(dirname "$1")' + LineEnding +
    'else' + LineEnding +
    '  for arg in "$@"; do' + LineEnding +
    '    if [[ "$arg" == *.exe ]]; then' + LineEnding +
    '      # Handle special cases for specific games' + LineEnding +
    '      [[ "$arg" == *"Cyberpunk 2077"* ]] && arg=${arg//REDprelauncher.exe/bin/x64/Cyberpunk2077.exe}' + LineEnding +
    '      [[ "$arg" == *"Witcher 3"* ]]      && arg=${arg//REDprelauncher.exe/bin/x64_dx12/witcher3.exe}' + LineEnding +
    '      [[ "$arg" == *"Baldurs Gate 3"* ]] && arg=${arg//Launcher\/LariLauncher.exe/bin/bg3_dx11.exe}' + LineEnding +
    '      [[ "$arg" == *"HITMAN 3"* ]]       && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}' + LineEnding +
    '      [[ "$arg" == *"HITMAN World of Assassination"* ]] && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}' + LineEnding +
    '      [[ "$arg" == *"SYNCED"* ]]         && arg=${arg//Launcher\/sop_launcher.exe/SYNCED.exe}' + LineEnding +
    '      [[ "$arg" == *"2KLauncher"* ]]     && arg=${arg//2KLauncher\/LauncherPatcher.exe/DoesntMatter.exe}' + LineEnding +
    '      [[ "$arg" == *"Warhammer 40,000 DARKTIDE"* ]] && arg=${arg//launcher\/Launcher.exe/binaries/Darktide.exe}' + LineEnding +
    '      [[ "$arg" == *"Warhammer Vermintide 2"* ]]    && arg=${arg//launcher\/Launcher.exe/binaries_dx12/vermintide2_dx12.exe}' + LineEnding +
    '      [[ "$arg" == *"Satisfactory"* ]]   && arg=${arg//FactoryGameSteam.exe/Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe}' + LineEnding +
    '      [[ "$arg" == *"FINAL FANTASY XIV Online"* ]] && arg=${arg//boot\/ffxivboot.exe/game/ffxiv_dx11.exe}' + LineEnding +
    '      [[ "$arg" == *"DuneAwakening"* ]]    && arg=${arg//Launcher\/FuncomLauncher.exe/DuneSandbox/Binaries/Win64/DuneSandbox-Win64-Shipping.exe}' + LineEnding +
    '      exe_folder_path=$(dirname "$arg")' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '  done' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    'for arg in "$@"; do' + LineEnding +
    '  if [[ "$arg" == lutris:rungameid/* ]]; then' + LineEnding +
    '    lutris_id="${arg#lutris:rungameid/}"' + LineEnding +
    '' + LineEnding +
    '    # Get slug from Lutris JSON' + LineEnding +
    '    slug=$(lutris --list-games --json 2>/dev/null | jq -r ".[] | select(.id == $lutris_id) | .slug")' + LineEnding +
    '' + LineEnding +
    '    if [[ -z "$slug" || "$slug" == "null" ]]; then' + LineEnding +
    '      echo "Could not find slug for Lutris ID $lutris_id"' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    # Find matching YAML file using slug' + LineEnding +
    '    config_file=$(find ~/.config/lutris/games/ -iname "${slug}-*.yml" | head -1)' + LineEnding +
    '' + LineEnding +
    '    if [[ -z "$config_file" ]]; then' + LineEnding +
    '      echo "No config file found for slug ''$slug''"' + LineEnding +
    '      break' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    # Extract executable path from YAML' + LineEnding +
    '    exe_path=$(grep -E ''^\s*exe:'' "$config_file" | sed ''s/.*exe:[[:space:]]*//'' )' + LineEnding +
    '' + LineEnding +
    '    if [[ -n "$exe_path" ]]; then' + LineEnding +
    '      exe_folder_path=$(dirname "$exe_path")' + LineEnding +
    '      echo "Resolved executable path: $exe_path"' + LineEnding +
    '      echo "Executable folder: $exe_folder_path"' + LineEnding +
    '    else' + LineEnding +
    '      echo "Executable path not found in $config_file"' + LineEnding +
    '    fi' + LineEnding +
    '' + LineEnding +
    '    break' + LineEnding +
    '  fi' + LineEnding +
    'done' + LineEnding +
    '' + LineEnding +
    '# Fallback to STEAM_COMPAT_INSTALL_PATH when no path was found' + LineEnding +
    '[[ -z "$exe_folder_path" && -n "$STEAM_COMPAT_INSTALL_PATH" ]] && exe_folder_path="$STEAM_COMPAT_INSTALL_PATH"' + LineEnding +
    '' + LineEnding +
    '# Check for Unreal Engine game paths' + LineEnding +
    'if [[ -d "$exe_folder_path/Engine" ]]; then' + LineEnding +
    '  ue_exe_path=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 -path "*Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)' + LineEnding +
    '  exe_folder_path=$(dirname "$ue_exe_path")' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# Verify the game folder exists' + LineEnding +
    '[[ ! -d "$exe_folder_path" ]] && error_exit "Unable to locate the game folder: $exe_folder_path"' + LineEnding +
    '' + LineEnding +
    '# Avoid operating on the uninstaller''s own directory' + LineEnding +
    'script_dir=$(dirname "$(realpath "$0")")' + LineEnding +
    '[[ "$(realpath "$exe_folder_path")" == "$script_dir" ]] && error_exit "The target directory matches the script''s directory. Aborting to prevent accidental deletion."' + LineEnding +
    '' + LineEnding +
    '# Change to the game directory' + LineEnding +
    'cd "$exe_folder_path" || error_exit "Failed to change directory to $exe_folder_path"' + LineEnding +
    '' + LineEnding +
    '# Verify current directory before proceeding' + LineEnding +
    '[[ "$(pwd)" != "$exe_folder_path" ]] && error_exit "Unexpected working directory: $(pwd)"' + LineEnding +
    '' + LineEnding +
    'logger -t fgmod-uninstaller "🟢 Uninstalling from: $exe_folder_path"' + LineEnding +
    '' + LineEnding +
    '# === Remove OptiScaler Files ===' + LineEnding +
    'echo "🧹 Removing OptiScaler files..."' + LineEnding +
    'rm -f "OptiScaler.dll" "dxgi.dll" "winmm.dll" "dbghelp.dll" "version.dll" "wininet.dll" "winhttp.dll" "OptiScaler.asi"' + LineEnding +
    'rm -f "OptiScaler.ini" "OptiScaler.log"' + LineEnding +
    '' + LineEnding +
    '# === Remove Nukem FG Mod Files ===' + LineEnding +
    'echo "🧹 Removing Nukem FG Mod files..."' + LineEnding +
    'rm -f "dlssg_to_fsr3_amd_is_better.dll" "dlssg_to_fsr3.ini" "dlssg_to_fsr3.log"' + LineEnding +
    'rm -f "nvapi64.dll" "fakenvapi.ini" "fakenvapi.log"' + LineEnding +
    '' + LineEnding +
    '# === Remove Supporting Libraries ===' + LineEnding +
    'echo "🧹 Removing supporting libraries..."' + LineEnding +
    'rm -f "libxess.dll" "libxess_dx11.dll" "libxess_fg.dll" "libxell.dll" "nvngx.dll" "nvngx.ini"' + LineEnding +
    'rm -f "amd_fidelityfx_dx12.dll" "amd_fidelityfx_framegeneration_dx12.dll" "amd_fidelityfx_upscaler_dx12.dll" "amd_fidelityfx_vk.dll"' + LineEnding +
    '' + LineEnding +
    '# === Remove FG Mod Files ===' + LineEnding +
    'echo "🧹 Removing frame generation mod files..."' + LineEnding +
    'rm -f "dlssg_to_fsr3_amd_is_better.dll" "dlssg_to_fsr3.ini"' + LineEnding +
    '' + LineEnding +
    '# === Remove NVAPI Files (Current and Legacy) ===' + LineEnding +
    'echo "🧹 Removing NVAPI files..."' + LineEnding +
    'rm -f "fakenvapi.dll" "fakenvapi.ini"  # Current v0.9.0-pre4 approach' + LineEnding +
    'rm -f "nvapi64.dll" "nvapi64.dll.b"    # Legacy cleanup for older versions and backups' + LineEnding +
    '' + LineEnding +
    '# === Remove ASI Plugins ===' + LineEnding +
    'echo "🧹 Removing ASI plugins directory..."' + LineEnding +
    'rm -rf "plugins"' + LineEnding +
    '' + LineEnding +
    '# === Remove Legacy Files ===' + LineEnding +
    'echo "🧹 Removing legacy files..."' + LineEnding +
    'rm -f "dlss-enabler.dll" "dlss-enabler-upscaler.dll" "dlss-enabler.log"' + LineEnding +
    'rm -f "nvngx-wrapper.dll" "_nvngx.dll"' + LineEnding +
    'rm -f "dlssg_to_fsr3_amd_is_better-3.0.dll"' + LineEnding +
    '' + LineEnding +
    '# === Restore Original DLLs ===' + LineEnding +
    'echo "🔄 Restoring original DLLs..."' + LineEnding +
    'original_dlls=("d3dcompiler_47.dll" "amd_fidelityfx_dx12.dll" "amd_fidelityfx_framegeneration_dx12.dll" "amd_fidelityfx_upscaler_dx12.dll" "amd_fidelityfx_vk.dll" "libxess.dll" "libxess_dx11.dll" "libxess_fg.dll" "libxell.dll")' + LineEnding +
    'for dll in "${original_dlls[@]}"; do' + LineEnding +
    '  if [[ -f "${dll}.b" ]]; then' + LineEnding +
    '    mv "${dll}.b" "$dll"' + LineEnding +
    '    echo "✅ Restored original $dll"' + LineEnding +
    '    logger -t fgmod-uninstaller "✅ Restored original $dll"' + LineEnding +
    '  fi' + LineEnding +
    'done' + LineEnding +
    '' + LineEnding +
    '# === Self-remove uninstaller ===' + LineEnding +
    'echo "🗑️ Removing uninstaller..."' + LineEnding +
    'rm -f "fgmod-uninstaller.sh"' + LineEnding +
    '' + LineEnding +
    'echo "✅ fgmod removed from this game successfully!"' + LineEnding +
    'logger -t fgmod-uninstaller "✅ fgmod removed from $exe_folder_path"' + LineEnding +
    '' + LineEnding +
    '# === Execute original command if provided ===' + LineEnding +
    'if [[ $# -gt 1 ]]; then' + LineEnding +
    '  echo "🚀 Launching the game..."' + LineEnding +
    '  export SteamDeck=0' + LineEnding +
    '  export WINEDLLOVERRIDES="${WINEDLLOVERRIDES},dxgi=n,b"' + LineEnding +
    '  exec "$@"' + LineEnding +
    'else' + LineEnding +
    '  echo "✅ Uninstallation complete. No game specified to run."' + LineEnding +
    'fi' + LineEnding;
end;

// ============================================================================
// EMBEDDED SCRIPT: fgmod-remover.sh
// ============================================================================
function GetFGModRemoverScript(IsFlatpak: Boolean): string;
begin
  // Use XDG-compliant path for both Flatpak and native
  // The path resolution uses HOST_XDG_DATA_HOME for Flatpak and XDG_DATA_HOME for native
  Result :=
    '#!/usr/bin/env bash' + LineEnding +
    '' + LineEnding +
    '# Determine the correct fgmod path using XDG directories' + LineEnding +
    'if [ -n \"$HOST_XDG_DATA_HOME\" ]; then' + LineEnding +
    '    FGMOD_PATH=\"$HOST_XDG_DATA_HOME/goverlay/fgmod\"' + LineEnding +
    'elif [ -n \"$XDG_DATA_HOME\" ]; then' + LineEnding +
    '    FGMOD_PATH=\"$XDG_DATA_HOME/goverlay/fgmod\"' + LineEnding +
    'else' + LineEnding +
    '    FGMOD_PATH=\"$HOME/.local/share/goverlay/fgmod\"' + LineEnding +
    'fi' + LineEnding +
    '' + LineEnding +
    '# Remove fgmod directory if it exists' + LineEnding +
    'if [[ -d \"$FGMOD_PATH\" ]]; then' + LineEnding +
    '    rm -rf \"$FGMOD_PATH\"' + LineEnding +
    '    echo \"FGmod removed from $FGMOD_PATH\"' + LineEnding +
    'else' + LineEnding +
    '    echo \"FGmod directory not found at $FGMOD_PATH\"' + LineEnding +
    'fi' + LineEnding;
end;

// ============================================================================
// EMBEDDED FILE: LICENSE
// ============================================================================
function GetFGModLicense: string;
begin
  Result :=
    'MIT License' + LineEnding +
    '' + LineEnding +
    'Copyright (c) 2024 Benjamim Gois' + LineEnding +
    '' + LineEnding +
    'Permission is hereby granted, free of charge, to any person obtaining a copy' + LineEnding +
    'of this software and associated documentation files (the "Software"), to deal' + LineEnding +
    'in the Software without restriction, including without limitation the rights' + LineEnding +
    'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell' + LineEnding +
    'copies of the Software, and to permit persons to whom the Software is' + LineEnding +
    'furnished to do so, subject to the following conditions:' + LineEnding +
    '' + LineEnding +
    'The above copyright notice and this permission notice shall be included in all' + LineEnding +
    'copies or substantial portions of the Software.' + LineEnding +
    '' + LineEnding +
    'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR' + LineEnding +
    'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,' + LineEnding +
    'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE' + LineEnding +
    'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER' + LineEnding +
    'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,' + LineEnding +
    'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE' + LineEnding +
    'SOFTWARE.' + LineEnding;
end;

// ============================================================================
// EMBEDDED FILE: README.md
// ============================================================================
function GetFGModReadme: string;
begin
  Result :=
    '# FGMod - Frame Generation Mod Installer' + LineEnding +
    '' + LineEnding +
    'FGMod is an integrated part of GOverlay that simplifies the installation of OptiScaler' + LineEnding +
    'and frame generation mods for games running through Wine/Proton.' + LineEnding +
    '' + LineEnding +
    '## Usage' + LineEnding +
    '' + LineEnding +
    '### Steam' + LineEnding +
    'Add the following to your game''s launch options:' + LineEnding +
    '```' + LineEnding +
    '"~/fgmod/fgmod" %command%' + LineEnding +
    '```' + LineEnding +
    '' + LineEnding +
    '### Heroic Games Launcher' + LineEnding +
    'Add `~/fgmod/fgmod` as a wrapper in the game settings.' + LineEnding +
    '' + LineEnding +
    '### Lutris' + LineEnding +
    'Add `~/fgmod/fgmod` as a command prefix in the game''s runner options.' + LineEnding +
    '' + LineEnding +
    '## Scripts' + LineEnding +
    '' + LineEnding +
    '- `fgmod` - Main installer script that copies OptiScaler files to the game directory' + LineEnding +
    '- `fgmod-uninstaller.sh` - Removes fgmod files from a specific game' + LineEnding +
    '- `fgmod-remover.sh` - Removes the entire fgmod directory' + LineEnding +
    '' + LineEnding +
    '## Environment Variables' + LineEnding +
    '' + LineEnding +
    '- `DLL` - Override the default DLL name (default: `dxgi.dll`)' + LineEnding +
    '- `PRESERVE_INI` - Keep existing OptiScaler.ini if present (default: `true`)' + LineEnding +
    '' + LineEnding +
    '## License' + LineEnding +
    '' + LineEnding +
    'MIT License - See LICENSE file for details.' + LineEnding;
end;

// Write a script file with executable permissions
procedure WriteScriptFile(const FilePath, Content: string);
var
  FileStream: TFileStream;
  ContentBytes: TBytes;
begin
  try
    // Ensure parent directory exists
    ForceDirectories(ExtractFilePath(FilePath));
    
    // Write content
    FileStream := TFileStream.Create(FilePath, fmCreate);
    try
      ContentBytes := TEncoding.UTF8.GetBytes(Content);
      FileStream.WriteBuffer(ContentBytes[0], Length(ContentBytes));
    finally
      FileStream.Free;
    end;
    
    // Make executable (chmod 755)
    fpChmod(FilePath, &755);
    
    WriteLn('[FGMOD] Created: ', FilePath);
  except
    on E: Exception do
      WriteLn('[FGMOD] Error writing ', FilePath, ': ', E.Message);
  end;
end;

// Write a regular text file
procedure WriteTextFile(const FilePath, Content: string);
var
  FileStream: TFileStream;
  ContentBytes: TBytes;
begin
  try
    // Ensure parent directory exists
    ForceDirectories(ExtractFilePath(FilePath));
    
    // Write content
    FileStream := TFileStream.Create(FilePath, fmCreate);
    try
      ContentBytes := TEncoding.UTF8.GetBytes(Content);
      FileStream.WriteBuffer(ContentBytes[0], Length(ContentBytes));
    finally
      FileStream.Free;
    end;
    
    WriteLn('[FGMOD] Created: ', FilePath);
  except
    on E: Exception do
      WriteLn('[FGMOD] Error writing ', FilePath, ': ', E.Message);
  end;
end;

// Check if fgmod is properly initialized
function IsFGModInitialized: Boolean;
var
  FGModPath: string;
begin
  FGModPath := GetFGModPath;
  Result := DirectoryExists(FGModPath) and
            FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'fgmod') and
            FileExists(IncludeTrailingPathDelimiter(FGModPath) + 'fgmod-uninstaller.sh');
end;

// Initialize the fgmod directory with all embedded scripts
// Only creates files if the fgmod directory doesn't exist
// This preserves user modifications to the scripts
procedure InitializeFGModDirectory;
var
  FGModPath: string;
  IsFlatpak: Boolean;
  ParentDir: string;
  FGModScript: string;
begin
  // Try to migrate from old location first (before any initialization)
  MigrateFGModToXDG;
  
  FGModPath := GetFGModPath;
  IsFlatpak := IsRunningInFlatpak;
  
  WriteLn('[FGMOD] Checking fgmod directory at: ', FGModPath);
  WriteLn('[FGMOD] Running in Flatpak: ', IsFlatpak);
  
  // Check if parent directory exists (especially important for Flatpak)
  ParentDir := ExtractFilePath(ExcludeTrailingPathDelimiter(FGModPath));
  WriteLn('[FGMOD] Parent directory: ', ParentDir);
  WriteLn('[FGMOD] Parent exists: ', DirectoryExists(ParentDir));
  
  // Check if fgmod SCRIPT exists (not just directory)
  // This handles the case where directory exists but is empty
  FGModScript := IncludeTrailingPathDelimiter(FGModPath) + 'fgmod';
  WriteLn('[FGMOD] Checking for fgmod script at: ', FGModScript);
  
  if not FileExists(FGModScript) then
  begin
    WriteLn('[FGMOD] fgmod script not found, creating fgmod directory and scripts...');
    
    // Try to create the directory
    if not ForceDirectories(FGModPath) then
    begin
      WriteLn('[FGMOD] ERROR: Failed to create directory: ', FGModPath);
      WriteLn('[FGMOD] Trying to create parent directories first...');
      
      // Try to create parent directory first
      if not DirectoryExists(ParentDir) then
      begin
        if ForceDirectories(ParentDir) then
          WriteLn('[FGMOD] Created parent directory: ', ParentDir)
        else
          WriteLn('[FGMOD] ERROR: Failed to create parent directory: ', ParentDir);
      end;
      
      // Try again to create fgmod directory
      if not ForceDirectories(FGModPath) then
      begin
        WriteLn('[FGMOD] ERROR: Still cannot create directory. Aborting initialization.');
        Exit;
      end;
    end;
    
    WriteLn('[FGMOD] Directory created successfully');
    
    // Write all embedded script files
    WriteScriptFile(IncludeTrailingPathDelimiter(FGModPath) + 'fgmod', GetFGModScript);
    WriteScriptFile(IncludeTrailingPathDelimiter(FGModPath) + 'fgmod-uninstaller.sh', GetFGModUninstallerScript);
    WriteScriptFile(IncludeTrailingPathDelimiter(FGModPath) + 'fgmod-remover.sh', GetFGModRemoverScript(IsFlatpak));
    WriteTextFile(IncludeTrailingPathDelimiter(FGModPath) + 'LICENSE', GetFGModLicense);
    WriteTextFile(IncludeTrailingPathDelimiter(FGModPath) + 'README.md', GetFGModReadme);
    
    WriteLn('[FGMOD] Initialization complete');
  end
  else
  begin
    WriteLn('[FGMOD] fgmod script already exists, preserving user modifications');
  end;
end;

end.
