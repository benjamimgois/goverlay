# Proposal: Native Linux Game Support for bgmod

## Why

Currently, `bgmod` (and `bgmod-uninstaller`) only detects game executables by scanning command-line arguments for `.exe` extensions. When launching native Linux games (such as Euro Truck Simulator 2 running natively with `-rdevice vk`, where the binary is `eurotrucks2`), `bgmod` fails to resolve `TargetExeName` and `GameDir`. As a result:
1. `bgmod` regenerates `conf.toml` for `lsfg-vk` and `mako` without the game profile in `active_in`, preventing Lossless Scaling frame generation from activating (reported in GitHub issue #420).
2. Per-game tool log synchronization and `MangoHud.conf` deployment to the game folder fail because `GameDir` is empty.
3. Windows-only upscaler DLL injection (OptiScaler / ReShade) might attempt invalid operations if enabled on a native game.

Supporting native Linux executables allows Vulkan layers (`lsfg-vk`, `mako`, `MangoHud`, `vkBasalt`, `vkSumi`) and environment tweaks to work seamlessly with native Linux titles.

## What Changes

- Extend `ResolveGameDirectory` in `bgmod.lpr` and `bgmod-uninstaller.lpr` to detect native Linux executables when no `.exe` argument is present:
  - Filter out command-line flags (`-*`, `--*`).
  - Filter out container runtimes, wrapper tools, and interpreters (`_v2-entry-point`, `pressure-vessel-wrap`, `steam-runtime-launch-client`, `steam-launch-wrapper`, `gamemoderun`, `mangohud`, `vkbasalt`, `optirun`, `prime-run`, `env`, `sh`, `bash`, `python3`, etc.).
  - Handle container boundaries (`--` delimiter in Steam Linux Runtime) by prioritizing target arguments following the runtime options.
  - Verify candidate files on disk (`FileExists`, `fpAccess(..., X_OK) = 0`) checking for ELF binary headers (`#$7F 'E' 'L' 'F'`) or executable scripts (`.x86_64`, `.bin`, `.sh`).
  - Resolve `TargetExeName` and `GameDir`.
- Update `conf.toml` profile generation in `bgmod.lpr` (`lsfg` and `mako`):
  - Ensure detected native Linux binary names (and lowercase variants) are populated into `active_in`.
  - Cache detected `TARGET_EXE` and `GAME_DIR` in `bgmod.conf` for persistent reference.
- Safeguard Windows DLL injection in `bgmod.lpr`:
  - When a native Linux executable is detected, skip OptiScaler and ReShade Windows DLL injection (`dxgi.dll`, `OptiScaler.dll`) while preserving native Vulkan layers and environment variables.
- Update `lossless_scaling_tab.pas` in GOverlay:
  - If `TARGET_EXE` is recorded in `bgmod.conf`, include it in `active_in` when saving `conf.toml` from the GUI.

## Capabilities

### New Capabilities
- `bgmod-native-game-support`: Wrapper detection of native Linux game executables (ELF binaries and scripts), wrapper skipping (Steam Linux Runtime, gamemoderun, etc.), caching in `bgmod.conf`, and safe bypassing of Windows PE DLL injection for native games.

### Modified Capabilities
- `lossless-scaling-config`: Update `conf.toml` generation requirements so that `active_in` profile entries accommodate native Linux game executable names detected by `bgmod` or saved in `bgmod.conf`.

## Impact

- Affected files:
  - `bgmod.lpr`: Executable detection, wrapper filtering, ELF validation, Windows DLL guard, `TARGET_EXE` caching.
  - `bgmod-uninstaller.lpr`: Executable and `GameDir` detection alignment.
  - `lossless_scaling_tab.pas`: Fallback to cached `TARGET_EXE` when generating `conf.toml` in GUI.
- No breaking changes: existing Windows/Proton games continue detecting `.exe` with priority.
