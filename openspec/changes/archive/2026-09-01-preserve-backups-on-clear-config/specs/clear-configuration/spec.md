## Purpose

Provides a safe configuration reset mechanism that removes all GOverlay application settings, caches, and game configuration files while preserving game DLL backup folders.

## ADDED Requirements

### Requirement: Safe Clear Configuration with Backup Preservation
The system SHALL recursively remove GOverlay configuration files, logs, caches, and directories across native and Flatpak configuration paths, while preserving any non-empty `backups` directory and its parent directory path structure.

#### Scenario: Preserving game backup directories containing original DLLs
- **WHEN** clear configuration is executed and a game directory contains a non-empty `backups/` folder
- **THEN** configuration files (`MangoHud.conf`, `bgmod.conf`, `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`, etc.) are removed, but the `backups/` directory, its original DLL files, and its parent game folder remain intact

#### Scenario: Removing configuration directories without backups
- **WHEN** clear configuration is executed on directories, games, or caches that do not contain any `backups/` directory
- **THEN** all files and empty parent directories are completely deleted

#### Scenario: Pruning empty backup directories
- **WHEN** clear configuration is executed and a `backups/` directory is empty (contains zero files)
- **THEN** the empty `backups/` directory and any parent directory that becomes empty are removed

### Requirement: Clear Configuration Confirmation Dialogue
The system SHALL present a confirmation dialogue before executing configuration reset, clearly informing the user that application settings and configs will be cleared while game DLL backups will be preserved.

#### Scenario: User confirms clear configuration
- **WHEN** the user clicks "Clear configuration" in the UI and confirms the prompt
- **THEN** the safe cleanup routine is executed and a success notification is shown upon completion

#### Scenario: User cancels clear configuration
- **WHEN** the user clicks "Clear configuration" in the UI and chooses No or cancels the prompt
- **THEN** no files or directories are removed or modified
