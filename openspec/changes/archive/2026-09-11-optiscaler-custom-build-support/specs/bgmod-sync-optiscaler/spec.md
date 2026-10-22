## MODIFIED Requirements

### Requirement: Bidirectional synchronization of OptiScaler configuration
The `bgmod` execution wrapper SHALL synchronize `OptiScaler.ini` bidirectionally between the GOverlay configuration directory (`ConfigDir`) and the game directory (`GameDir`) based on file modification timestamps and user preservation settings, unless unmanaged mode (`OPT_UNMANAGED_INI=1`) is enabled.

#### Scenario: In-game configuration is newer
- **WHEN** the game is launched with OptiScaler enabled, `PRESERVE_INI` is true, unmanaged mode is disabled, and the modification timestamp of `GameDir/OptiScaler.ini` is newer than `ConfigDir/OptiScaler.ini`
- **THEN** `bgmod` copies `GameDir/OptiScaler.ini` to `ConfigDir/OptiScaler.ini` and preserves the source modification timestamp on the destination file.

#### Scenario: GOverlay configuration is newer
- **WHEN** the game is launched with OptiScaler enabled, `PRESERVE_INI` is true, unmanaged mode is disabled, and the modification timestamp of `ConfigDir/OptiScaler.ini` is newer than `GameDir/OptiScaler.ini`
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
- **WHEN** the game is launched with OptiScaler enabled, `PRESERVE_INI` is false, and unmanaged mode is disabled
- **THEN** `bgmod` unconditionally copies `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini`.

#### Scenario: Unmanaged mode enabled with existing game configuration
- **WHEN** the game is launched with OptiScaler enabled, `OPT_UNMANAGED_INI` is 1 in `bgmod.conf`, and `GameDir/OptiScaler.ini` already exists
- **THEN** `bgmod` preserves `GameDir/OptiScaler.ini` without modifying or overwriting it from `ConfigDir/OptiScaler.ini`.
