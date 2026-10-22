# Spec Delta

## Purpose

Automatically synchronizes wrapper binaries across all existing per-game configuration folders on application startup and logs explicit wrapper version information during launch.

## ADDED Requirements

### Requirement: Automated Wrapper Binary Synchronization On Startup
The system SHALL scan all existing per-game configuration folders under `goverlay/gameconfig/` during application startup and synchronize the wrapper executables (`bgmod`, `bgmod-uninstaller`, `bgmod-splash`) and ensure the `fgmod` symlink from the active template cache, maintaining executable permissions (`0755`).

#### Scenario: Existing game profiles receive updated wrapper binaries on launch
- **WHEN** the application starts up and finds existing game configuration directories in `gameconfig/`
- **THEN** it copies `bgmod`, `bgmod-uninstaller`, and `bgmod-splash` from the template cache to each directory, applies execution permissions, and ensures `fgmod` points to `bgmod`

#### Scenario: Global configuration directory remains synchronized
- **WHEN** the application initializes configuration directories on startup
- **THEN** `gameconfig/global/` is synchronized with latest wrapper binaries alongside all individual game directories

### Requirement: Preservation of User Configuration and Game Data
The system SHALL preserve all user configurations, custom overlay files, and backup directories when synchronizing wrapper binaries in game configuration directories.

#### Scenario: User configuration files are not overwritten during binary sync
- **WHEN** wrapper binaries are synchronized across game configuration directories
- **THEN** files matching `*.conf`, `*.ini`, `*.vars` (including `bgmod.conf`, `MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`) and the `backups/` subdirectory remain completely untouched

### Requirement: Wrapper Version Logging
The `bgmod` and `bgmod-uninstaller` executables SHALL log their explicit version string upon startup to assist troubleshooting and issue diagnosis.

#### Scenario: Wrapper outputs version in log header
- **WHEN** `bgmod` or `bgmod-uninstaller` is executed
- **THEN** the initial log output contains the explicit wrapper version string (e.g. `Executing bgmod v1.9.3: <path>`)
