## Purpose

Provides native Linux game executable and directory resolution in `bgmod` and `bgmod-uninstaller`, enabling Vulkan layers, Lossless Scaling, and tool configuration for native titles while bypassing incompatible Windows DLL injection.

## Requirements

### Requirement: Detection of native Linux game executables in bgmod
The `bgmod` wrapper executable SHALL inspect command-line arguments when no `.exe` argument is detected, filter out flags and known wrapper/runtime binaries, and identify the primary native Linux game executable and its containing directory.

#### Scenario: Launching native Linux game directly
- **WHEN** Steam launches a native game command such as `/path/to/Euro Truck Simulator 2/bin/linux_x64/eurotrucks2 -rdevice vk`
- **THEN** `bgmod` resolves `TargetExeName` as `eurotrucks2` and `GameDir` as `/path/to/Euro Truck Simulator 2/bin/linux_x64/`.

#### Scenario: Launching native Linux game via Steam Linux Runtime container
- **WHEN** Steam launches a game using a container runtime such as `.../_v2-entry-point --verb=waitforexitandrun -- /path/to/bin/linux_x64/eurotrucks2 -rdevice vk`
- **THEN** `bgmod` skips the runtime wrapper and arguments before `--`, resolving `TargetExeName` as `eurotrucks2` and `GameDir` as `/path/to/bin/linux_x64/`.

#### Scenario: Launching native Linux game with gamemoderun wrapper
- **WHEN** the launch options include `-- env gamemoderun /path/to/bin/linux_x64/eurotrucks2 -rdevice vk`
- **THEN** `bgmod` ignores `env` and `gamemoderun`, correctly resolving `TargetExeName` as `eurotrucks2`.

### Requirement: Persistent caching of detected native executable
The `bgmod` wrapper SHALL record the resolved `TARGET_EXE` and `GAME_DIR` in the active game profile's `bgmod.conf` under `[Config]` when launching in per-game mode.

#### Scenario: Caching resolved executable on launch
- **WHEN** `bgmod` resolves `TargetExeName` as `eurotrucks2` during game startup
- **THEN** `bgmod` persists `TARGET_EXE=eurotrucks2` and `GAME_DIR=<path>` into the active `bgmod.conf`.

### Requirement: Windows DLL injection bypass for native Linux executables
The system SHALL bypass Windows PE DLL copying and injection (OptiScaler, DLSS Enabler, ReShade proxy DLLs) when the resolved game executable is a native Linux binary (non-`.exe`), while preserving native Vulkan layers and environment variables.

#### Scenario: OptiScaler toggle active on native Linux game
- **WHEN** a user has `GOVERLAY_OPTISCALER=1` in `bgmod.conf` but the detected executable is native Linux (ELF binary or script without `.exe`)
- **THEN** `bgmod` logs that a native Linux game was detected and skips copying `dxgi.dll`, `OptiScaler.dll`, or other Windows PE files into `GameDir`.

### Requirement: Uninstaller parity for native Linux game directory resolution
The `bgmod-uninstaller` executable SHALL implement the identical native Linux executable and directory detection logic as `bgmod` to ensure proper cleanup of configuration files and logs in native game folders.

#### Scenario: Uninstalling wrapper from native game
- **WHEN** `bgmod-uninstaller` is executed for a native Linux game
- **THEN** `bgmod-uninstaller` resolves the native game directory and cleans up `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, and log files from that directory.
