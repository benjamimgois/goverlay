## Purpose

Provides bidirectional and timestamp-aware synchronization of OptiScaler configuration files between GOverlay configuration directories and game installation directories on game launch.

## ADDED Requirements

### Requirement: Bidirectional synchronization of OptiScaler configuration
The `bgmod` execution wrapper SHALL synchronize `OptiScaler.ini` bidirectionally between the GOverlay configuration directory (`ConfigDir`) and the game directory (`GameDir`) based on file modification timestamps and user preservation settings.

#### Scenario: In-game configuration is newer
- **WHEN** the game is launched with OptiScaler enabled, `PRESERVE_INI` is true, and the modification timestamp of `GameDir/OptiScaler.ini` is newer than `ConfigDir/OptiScaler.ini`
- **THEN** `bgmod` copies `GameDir/OptiScaler.ini` to `ConfigDir/OptiScaler.ini` and preserves the source modification timestamp on the destination file.

#### Scenario: GOverlay configuration is newer
- **WHEN** the game is launched with OptiScaler enabled, `PRESERVE_INI` is true, and the modification timestamp of `ConfigDir/OptiScaler.ini` is newer than `GameDir/OptiScaler.ini`
- **THEN** `bgmod` copies `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini` and preserves the source modification timestamp on the destination file.

#### Scenario: OptiScaler configuration missing in game directory
- **WHEN** the game is launched with OptiScaler enabled, `ConfigDir/OptiScaler.ini` exists, but `GameDir/OptiScaler.ini` does not exist
- **THEN** `bgmod` copies `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini` and sets the modification timestamp of `GameDir/OptiScaler.ini` to match `ConfigDir/OptiScaler.ini`.

#### Scenario: OptiScaler configuration missing in config directory
- **WHEN** the game is launched with OptiScaler enabled, `GameDir/OptiScaler.ini` exists, but `ConfigDir/OptiScaler.ini` does not exist
- **THEN** `bgmod` copies `GameDir/OptiScaler.ini` to `ConfigDir/OptiScaler.ini` and sets the modification timestamp of `ConfigDir/OptiScaler.ini` to match `GameDir/OptiScaler.ini`.

#### Scenario: Timestamps are identical
- **WHEN** the game is launched with OptiScaler enabled and both `ConfigDir/OptiScaler.ini` and `GameDir/OptiScaler.ini` have matching modification timestamps
- **THEN** `bgmod` performs no file copying for `OptiScaler.ini`.

#### Scenario: Preserve INI disabled
- **WHEN** the game is launched with OptiScaler enabled and `PRESERVE_INI` is false in `bgmod.conf`
- **THEN** `bgmod` unconditionally copies `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini`.

### Requirement: Safe synchronization of fakenvapi configuration
The `bgmod` execution wrapper SHALL synchronize `fakenvapi.ini` between `ConfigDir` and `GameDir` while preserving modification timestamps.

#### Scenario: fakenvapi configuration exists in config directory
- **WHEN** the game is launched with OptiScaler enabled and `ConfigDir/fakenvapi.ini` exists
- **THEN** `bgmod` copies `ConfigDir/fakenvapi.ini` to `GameDir/fakenvapi.ini` if `GameDir/fakenvapi.ini` is missing or older, and preserves the modification timestamp.
