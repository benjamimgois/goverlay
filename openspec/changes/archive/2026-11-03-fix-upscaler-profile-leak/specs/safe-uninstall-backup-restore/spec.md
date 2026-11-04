# Spec Delta

## MODIFIED Requirements

### Requirement: OptiScaler cleanup gating in bgmod
The `bgmod` launcher wrapper SHALL gate OptiScaler and upscaler leftovers cleanup so that it only executes when OptiScaler-specific markers exist in `goverlay.vars` (`proxydll`, `upscalertype`, or legacy upscaler version keys) or explicit OptiScaler and HelixSR binary files and directories (`OptiScaler.dll`, `OptiScaler.ini`, `fakenvapi.dll`, `dlssg_to_fsr3_amd_is_better.dll`, `D3D12_OptiScaler`, `HelixSR/`, `helixsr-fg/`, or `helixsr.ini`) exist in the game directory. When upscalers are disabled, the cleanup routine SHALL purge HelixSR proxy binaries and folders in addition to standard OptiScaler files.

#### Scenario: ReShade active with OptiScaler disabled
- **WHEN** a game is launched through `bgmod` with ReShade enabled and OptiScaler disabled
- **THEN** `bgmod` detects that `goverlay.vars` contains only `reshadeproxy` without any OptiScaler markers, skips OptiScaler cleanup entirely, and preserves all existing vendor and game files.

#### Scenario: External mod manager directory protection
- **WHEN** cleanup of OptiScaler runs and a subfolder named `OptiScaler/` contains an external mod management marker (such as `__folder_managed_by_vortex`)
- **THEN** the cleanup routine skips deleting the `OptiScaler/` directory and logs that the directory is externally managed.

#### Scenario: HelixSR leftovers purged when upscaler disabled
- **WHEN** a game directory contains HelixSR files (`HelixSR/`, `helixsr-fg/`, `helixsr.ini`, or HelixSR proxy DLL) and `bgmod` launches the game with upscalers disabled
- **THEN** `bgmod` detects the HelixSR leftovers, purges the HelixSR subdirectories and proxy DLLs, and restores any original native backups.

#### Scenario: Uninstaller removes HelixSR proxy and restores native DLL
- **WHEN** "Uninstall changes" is invoked for a game configured with HelixSR
- **THEN** `bgmod-uninstaller` identifies the HelixSR proxy DLL, removes it from the game root, and restores the original game DLL from backup.
