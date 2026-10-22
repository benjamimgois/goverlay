# Spec Delta

## ADDED Requirements

### Requirement: OptiScaler cleanup gating in bgmod
The `bgmod` launcher wrapper SHALL gate OptiScaler and upscaler leftovers cleanup so that it only executes when OptiScaler-specific markers exist in `goverlay.vars` (`proxydll`, `upscalertype`, or legacy upscaler version keys) or explicit OptiScaler binary files exist in the game directory.

#### Scenario: ReShade active with OptiScaler disabled
- **WHEN** a game is launched through `bgmod` with ReShade enabled and OptiScaler disabled
- **THEN** `bgmod` detects that `goverlay.vars` contains only `reshadeproxy` without any OptiScaler markers, skips OptiScaler cleanup entirely, and preserves all existing vendor and game files.

#### Scenario: External mod manager directory protection
- **WHEN** cleanup of OptiScaler runs and a subfolder named `OptiScaler/` contains an external mod management marker (such as `__folder_managed_by_vortex`)
- **THEN** the cleanup routine skips deleting the `OptiScaler/` directory and logs that the directory is externally managed.

## MODIFIED Requirements

### Requirement: Safe handling of Streamline libraries during uninstallation
The system SHALL NOT delete native Streamline or DLSS SDK DLLs (`sl.*.dll`, `nvngx_dlss*.dll`, `amd_fidelityfx_loader_dx12.dll`) from the game directory during uninstallation or disabled-mod cleanup when a backup is absent, unless the target file's size exactly matches GOverlay's distributed payload in `SourceDir`.

#### Scenario: Uninstallation with intact backups
- **WHEN** uninstallation runs on a game with native Streamline DLLs backed up in the backups directory
- **THEN** native Streamline DLLs (including `sl.common.dll`, `sl.interposer.dll`, and `sl.pcl.dll`) are restored from the backup folder, and mod-only plugins without backups are deleted.

#### Scenario: Disabled cleanup when no backup exists
- **WHEN** cleanup runs for a game that natively ships `sl.dlss.dll` or `nvngx_dlss.dll` without a backup in `BackupsDir`
- **THEN** `bgmod` skips deleting those DLLs and preserves the game's original files.
