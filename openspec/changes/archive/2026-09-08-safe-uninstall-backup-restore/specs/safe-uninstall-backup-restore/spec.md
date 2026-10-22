## Purpose

Ensures game modification uninstallation restores all original game files from backup and cleans mod artifacts before any configuration data is deleted.

## ADDED Requirements

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
The system SHALL NOT delete native Streamline SDK DLLs from the game directory during uninstallation when a backup is absent or when the file was not deployed by the mod.

#### Scenario: Uninstallation with intact backups
- **WHEN** uninstallation runs on a game with native Streamline DLLs backed up in the backups directory
- **THEN** native Streamline DLLs (including `sl.common.dll`, `sl.interposer.dll`, and `sl.pcl.dll`) are restored from the backup folder, and mod-only plugins without backups are deleted.
