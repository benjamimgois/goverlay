## Purpose

Ensures game modification uninstallation restores all original game files from backup and cleans mod artifacts before any configuration data is deleted.

## Requirements

### Requirement: Preservation of backups until restoration completes
The system SHALL execute the uninstaller and restore all backed-up native libraries into the game directory before deleting any game configuration or backup directories.

#### Scenario: Original files restored prior to config deletion
- **WHEN** the user triggers "Uninstall changes" for a game
- **THEN** the uninstaller runs with access to the game's backup directory, restores all backed-up native files into the game directory, cleans mod artifacts, and only deletes the game configuration folder after uninstallation succeeds.

### Requirement: Explicit backup directory resolution for uninstaller
The system SHALL pass the active game's configuration and backup paths to the uninstaller process, and the uninstaller SHALL prioritize these paths over default global paths.

#### Scenario: Uninstaller invoked from GUI or external caller
- **WHEN** `bgmod-uninstaller` is executed with environment variables `BGMOD_BACKUPS_DIR` or `BGMOD_CONFIG_DIR`
- **THEN** it resolves `BackupsDir` to the specified directory and restores backups from that location.

#### Scenario: Fallback when per-game uninstaller is invoked directly
- **WHEN** `bgmod-uninstaller` is invoked without environment variables from inside a per-game configuration directory
- **THEN** it resolves `BackupsDir` relative to its own executable path (`<UninstallerPath>/backups/`).

### Requirement: Safe handling of Streamline libraries during uninstallation
The system SHALL NOT delete native Streamline or DLSS SDK DLLs (`sl.*.dll`, `nvngx_dlss*.dll`, `amd_fidelityfx_loader_dx12.dll`) from the game directory during uninstallation or disabled-mod cleanup when a backup is absent, unless the target file's size exactly matches GOverlay's distributed payload in `SourceDir`.

#### Scenario: Uninstallation with intact backups
- **WHEN** uninstallation runs on a game with native Streamline DLLs backed up in the backups directory
- **THEN** native Streamline DLLs (including `sl.common.dll`, `sl.interposer.dll`, and `sl.pcl.dll`) are restored from the backup folder, and mod-only plugins without backups are deleted.

#### Scenario: Disabled cleanup when no backup exists
- **WHEN** cleanup runs for a game that natively ships `sl.dlss.dll` or `nvngx_dlss.dll` without a backup in `BackupsDir`
- **THEN** `bgmod` skips deleting those DLLs and preserves the game's original files.

### Requirement: Robust shell quoting for uninstaller execution
The system SHALL use POSIX-compliant single-quote escaping when passing file and directory paths, environment variables, and executable binaries to the shell for uninstallation.

#### Scenario: Uninstaller invoked for a game path containing apostrophes
- **WHEN** uninstallation is triggered for a game whose directory path contains an apostrophe or single quote (e.g. `No Man's Sky`)
- **THEN** the shell invocation command quotes `STEAM_COMPAT_INSTALL_PATH`, `BGMOD_CONFIG_DIR`, and `BGMOD_BACKUPS_DIR` using POSIX single-quote escaping (`'\''`) such that the uninstaller receives the exact uncorrupted path without stripped or substituted characters.

### Requirement: Defensive game directory validation in bgmod uninstaller
The uninstaller SHALL verify whether the resolved game directory exists on disk, and fallback to the stored configuration when an environment variable provides a non-existent path.

#### Scenario: Environment path does not exist but config specifies valid path
- **WHEN** `bgmod-uninstaller` receives a `STEAM_COMPAT_INSTALL_PATH` whose directory does not exist on disk
- **THEN** the uninstaller discards the invalid path and falls back to reading the `GAME_DIR` value stored in `bgmod.conf`.

### Requirement: OptiScaler cleanup gating in bgmod
The `bgmod` launcher wrapper SHALL gate OptiScaler and upscaler leftovers cleanup so that it only executes when OptiScaler-specific markers exist in `goverlay.vars` (`proxydll`, `upscalertype`, or legacy upscaler version keys) or explicit OptiScaler binary files exist in the game directory.

#### Scenario: ReShade active with OptiScaler disabled
- **WHEN** a game is launched through `bgmod` with ReShade enabled and OptiScaler disabled
- **THEN** `bgmod` detects that `goverlay.vars` contains only `reshadeproxy` without any OptiScaler markers, skips OptiScaler cleanup entirely, and preserves all existing vendor and game files.

#### Scenario: External mod manager directory protection
- **WHEN** cleanup of OptiScaler runs and a subfolder named `OptiScaler/` contains an external mod management marker (such as `__folder_managed_by_vortex`)
- **THEN** the cleanup routine skips deleting the `OptiScaler/` directory and logs that the directory is externally managed.
