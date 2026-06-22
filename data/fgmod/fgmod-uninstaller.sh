#!/usr/bin/env bash

set -x
exec > >(tee -i /tmp/fgmod-uninstaller.log) 2>&1

error_exit() {
  echo "❌ $1"
  if [[ -n $STEAM_ZENITY ]]; then
    $STEAM_ZENITY --error --text "$1"
  else
    zenity --error --text "$1" || echo "Zenity failed to display error"
  fi
  logger -t fgmod-uninstaller "❌ ERROR: $1"
  exit 1
}

is_goverlay_proxy_file() {
  local target_file="$1"
  local dll_name="$2"
  
  [[ ! -f "$target_file" ]] && return 1
  
  local target_size
  target_size=$(wc -c < "$target_file" 2>/dev/null | tr -d '[:space:]')
  [[ -z "$target_size" ]] && return 1
  
  local global_fgmod_path=""
  if [[ "$HOME" != "" ]]; then
    global_fgmod_path="$HOME/.local/share/goverlay/bgmod"
    if [[ ! -d "$global_fgmod_path" ]]; then
      global_fgmod_path="$HOME/.local/share/goverlay/fgmod"
    fi
  fi
  
  local flatpak_base="$HOME/.var/app/io.github.benjamimgois.goverlay/data/goverlay"
  local global_flatpak_bgmod="$flatpak_base/bgmod"
  local global_flatpak_fgmod="$flatpak_base/fgmod"
  
  local size_local_rename=""
  local size_local_optiscaler=""
  if [[ -f "$script_dir/renames/$dll_name" ]]; then
    size_local_rename=$(wc -c < "$script_dir/renames/$dll_name" 2>/dev/null | tr -d '[:space:]')
  fi
  if [[ -f "$script_dir/OptiScaler.dll" ]]; then
    size_local_optiscaler=$(wc -c < "$script_dir/OptiScaler.dll" 2>/dev/null | tr -d '[:space:]')
  fi
  
  if [[ -n "$size_local_rename" && "$target_size" -eq "$size_local_rename" ]] || \
     [[ -n "$size_local_optiscaler" && "$target_size" -eq "$size_local_optiscaler" ]]; then
    return 0
  fi

  if [[ -d "$global_fgmod_path" ]]; then
    local size_global_rename=""
    local size_global_optiscaler=""
    if [[ -f "$global_fgmod_path/renames/$dll_name" ]]; then
      size_global_rename=$(wc -c < "$global_fgmod_path/renames/$dll_name" 2>/dev/null | tr -d '[:space:]')
    fi
    if [[ -f "$global_fgmod_path/OptiScaler.dll" ]]; then
      size_global_optiscaler=$(wc -c < "$global_fgmod_path/OptiScaler.dll" 2>/dev/null | tr -d '[:space:]')
    fi
    
    if [[ -n "$size_global_rename" && "$target_size" -eq "$size_global_rename" ]] || \
       [[ -n "$size_global_optiscaler" && "$target_size" -eq "$size_global_optiscaler" ]]; then
      return 0
    fi
  fi

  for fp_path in "$global_flatpak_bgmod" "$global_flatpak_fgmod"; do
    if [[ -d "$fp_path" ]]; then
      local size_fp_rename=""
      local size_fp_optiscaler=""
      if [[ -f "$fp_path/renames/$dll_name" ]]; then
        size_fp_rename=$(wc -c < "$fp_path/renames/$dll_name" 2>/dev/null | tr -d '[:space:]')
      fi
      if [[ -f "$fp_path/OptiScaler.dll" ]]; then
        size_fp_optiscaler=$(wc -c < "$fp_path/OptiScaler.dll" 2>/dev/null | tr -d '[:space:]')
      fi
      
      if [[ -n "$size_fp_rename" && "$target_size" -eq "$size_fp_rename" ]] || \
         [[ -n "$size_fp_optiscaler" && "$target_size" -eq "$size_fp_optiscaler" ]]; then
        return 0
      fi
    fi
  done
  
  return 1
}

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 program [program_arguments...]"
  exit 1
fi

# === Resolve Game Path ===
exe_folder_path=""
if [[ "$1" == *.exe ]]; then
  exe_folder_path=$(dirname "$1")
else
  for arg in "$@"; do
    if [[ "$arg" == *.exe ]]; then
      # Handle special cases for specific games
      [[ "$arg" == *"Cyberpunk 2077"* ]] && arg=${arg//REDprelauncher.exe/bin/x64/Cyberpunk2077.exe}
      [[ "$arg" == *"Witcher 3"* ]]      && arg=${arg//REDprelauncher.exe/bin/x64_dx12/witcher3.exe}
      [[ "$arg" == *"Baldurs Gate 3"* ]] && arg=${arg//Launcher\/LariLauncher.exe/bin/bg3_dx11.exe}
      [[ "$arg" == *"HITMAN 3"* ]]       && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}
      [[ "$arg" == *"HITMAN World of Assassination"* ]] && arg=${arg//Launcher.exe/Retail/HITMAN3.exe}
      [[ "$arg" == *"SYNCED"* ]]         && arg=${arg//Launcher\/sop_launcher.exe/SYNCED.exe}
      [[ "$arg" == *"2KLauncher"* ]]     && arg=${arg//2KLauncher\/LauncherPatcher.exe/DoesntMatter.exe}
      [[ "$arg" == *"Warhammer 40,000 DARKTIDE"* ]] && arg=${arg//launcher\/Launcher.exe/binaries/Darktide.exe}
      [[ "$arg" == *"Warhammer Vermintide 2"* ]]    && arg=${arg//launcher\/Launcher.exe/binaries_dx12/vermintide2_dx12.exe}
      [[ "$arg" == *"Satisfactory"* ]]   && arg=${arg//FactoryGameSteam.exe/Engine/Binaries/Win64/FactoryGameSteam-Win64-Shipping.exe}
      [[ "$arg" == *"FINAL FANTASY XIV Online"* ]] && arg=${arg//boot\/ffxivboot.exe/game/ffxiv_dx11.exe}
      [[ "$arg" == *"DuneAwakening"* ]]    && arg=${arg//Launcher\/FuncomLauncher.exe/DuneSandbox/Binaries/Win64/DuneSandbox-Win64-Shipping.exe}
      exe_folder_path=$(dirname "$arg")
      break
    fi
  done
fi

for arg in "$@"; do
  if [[ "$arg" == lutris:rungameid/* ]]; then
    lutris_id="${arg#lutris:rungameid/}"

    # Get slug from Lutris JSON
    slug=$(lutris --list-games --json 2>/dev/null | jq -r ".[] | select(.id == $lutris_id) | .slug")

    if [[ -z "$slug" || "$slug" == "null" ]]; then
      echo "Could not find slug for Lutris ID $lutris_id"
      break
    fi

    # Find matching YAML file using slug
    config_file=$(find ~/.config/lutris/games/ -iname "${slug}-*.yml" | head -1)

    if [[ -z "$config_file" ]]; then
      echo "No config file found for slug '$slug'"
      break
    fi

    # Extract executable path from YAML
    exe_path=$(grep -E '^\s*exe:' "$config_file" | sed 's/.*exe:[[:space:]]*//' )

    if [[ -n "$exe_path" ]]; then
      exe_folder_path=$(dirname "$exe_path")
      echo "Resolved executable path: $exe_path"
      echo "Executable folder: $exe_folder_path"
    else
      echo "Executable path not found in $config_file"
    fi

    break
  fi
done

# Fallback to STEAM_COMPAT_INSTALL_PATH when no path was found
[[ -z "$exe_folder_path" && -n "$STEAM_COMPAT_INSTALL_PATH" ]] && exe_folder_path="$STEAM_COMPAT_INSTALL_PATH"

# Check for Unreal Engine game paths
if [[ -d "$exe_folder_path/Engine" ]]; then
  ue_exe_path=$(find "$exe_folder_path" -maxdepth 4 -mindepth 4 -path "*Binaries/Win64/*.exe" -not -path "*/Engine/*" | head -1)
  exe_folder_path=$(dirname "$ue_exe_path")
fi

# Verify the game folder exists
[[ ! -d "$exe_folder_path" ]] && error_exit "Unable to locate the game folder: $exe_folder_path"

# Avoid operating on the uninstaller's own directory
script_dir=$(dirname "$(realpath "$0")")
[[ "$(realpath "$exe_folder_path")" == "$script_dir" ]] && error_exit "The target directory matches the script's directory. Aborting to prevent accidental deletion."

# Change to the game directory
cd "$exe_folder_path" || error_exit "Failed to change directory to $exe_folder_path"

# Verify current directory before proceeding
[[ "$(pwd)" != "$exe_folder_path" ]] && error_exit "Unexpected working directory: $(pwd)"

logger -t fgmod-uninstaller "🟢 Uninstalling from: $exe_folder_path"

# === Remove OptiScaler Files ===
echo "🧹 Removing OptiScaler files..."
rm -f "OptiScaler.dll" "OptiScaler.asi"
rm -f "OptiScaler.ini" "OptiScaler.log"

proxy_dlls=("dxgi.dll" "winmm.dll" "dbghelp.dll" "version.dll" "wininet.dll" "winhttp.dll")
for p_dll in "${proxy_dlls[@]}"; do
  if [[ -f "${p_dll}.b" ]]; then
    mv -f "${p_dll}.b" "$p_dll"
    echo "🔄 Restored proxy DLL backup: $p_dll"
  elif [[ -f "$p_dll" ]]; then
    if is_goverlay_proxy_file "$p_dll" "$p_dll"; then
      rm -f "$p_dll"
      echo "🧹 Cleaned up GOverlay proxy DLL: $p_dll"
    else
      echo "🛡️ Preserved third-party proxy DLL: $p_dll"
    fi
  fi
done

# === Remove Nukem FG Mod Files ===
echo "🧹 Removing Nukem FG Mod files..."
rm -f "dlssg_to_fsr3_amd_is_better.dll" "dlssg_to_fsr3.ini" "dlssg_to_fsr3.log"
rm -f "nvapi64.dll" "fakenvapi.ini" "fakenvapi.log"

# === Remove Supporting Libraries ===
echo "🧹 Removing supporting libraries..."
rm -f "libxess.dll" "libxess_dx11.dll" "libxess_fg.dll" "libxell.dll" "nvngx.dll" "nvngx.ini"
rm -f "amd_fidelityfx_dx12.dll" "amd_fidelityfx_framegeneration_dx12.dll" "amd_fidelityfx_upscaler_dx12.dll" "amd_fidelityfx_vk.dll"
rm -f "nvngx_dlss.dll" "nvngx_dlssd.dll" "nvngx_dlssg.dll"

# === Remove NVAPI Files (Current and Legacy) ===
echo "🧹 Removing NVAPI files..."
rm -f "fakenvapi.dll" "fakenvapi.ini"  # Current v0.9.0-pre4 approach
rm -f "nvapi64.dll" "nvapi64.dll.b"    # Legacy cleanup for older versions and backups

# === Remove ASI Plugins ===
echo "🧹 Removing ASI plugins directory..."
rm -rf "plugins"

# === Remove Legacy Files ===
echo "🧹 Removing legacy files..."
rm -f "dlss-enabler.dll" "dlss-enabler-upscaler.dll" "dlss-enabler.log"
rm -f "nvngx-wrapper.dll" "_nvngx.dll"
rm -f "dlssg_to_fsr3_amd_is_better-3.0.dll"

# === Remove Config Files Installed by fgmod ===
echo "🧹 Removing config files installed by fgmod..."
rm -f "MangoHud.conf" "vkBasalt.conf" "vkSumi.conf"

# === Restore Original DLLs ===
echo "🔄 Restoring original DLLs..."
original_dlls=("d3dcompiler_47.dll" "amd_fidelityfx_dx12.dll" "amd_fidelityfx_framegeneration_dx12.dll" "amd_fidelityfx_upscaler_dx12.dll" "amd_fidelityfx_vk.dll" "libxess.dll" "libxess_dx11.dll" "libxess_fg.dll" "libxell.dll")
for dll in "${original_dlls[@]}"; do
  if [[ -f "${dll}.b" ]]; then
    mv "${dll}.b" "$dll"
    echo "✅ Restored original $dll"
    logger -t fgmod-uninstaller "✅ Restored original $dll"
  fi
done

# === Self-remove uninstaller ===
echo "🗑️ Removing uninstaller..."
rm -f "fgmod-uninstaller.sh"

echo "✅ fgmod removed from this game successfully!"
logger -t fgmod-uninstaller "✅ fgmod removed from $exe_folder_path"

# === Execute original command if provided ===
if [[ $# -gt 1 ]]; then
  echo "🚀 Launching the game..."
  export SteamDeck=0
  export WINEDLLOVERRIDES="${WINEDLLOVERRIDES},dxgi=n,b"
  "$@"
else
  echo "✅ Uninstallation complete. No game specified to run."
fi
