## ADDED Requirements

### Requirement: Sync configuration files on launch
The `bgmod` execution wrapper SHALL check if the user-editable configuration files (`OptiScaler.ini` and `fakenvapi.ini`) in the GOverlay config directory need to be synchronized to the game directory on every run, regardless of whether the main DLL files are up-to-date and the core file copying is skipped.

For `OptiScaler.ini`, synchronization SHALL only happen:
- If `OptiScaler.ini` does not exist in the game directory.
- OR if `PRESERVE_INI` is set to false in `bgmod.conf`.
- OR if the modification time of `OptiScaler.ini` in GOverlay's config directory is newer than the modification time of `OptiScaler.ini` in the game directory.

For `fakenvapi.ini`, synchronization SHALL happen unconditionally if `fakenvapi.ini` exists in GOverlay's config directory.

#### Scenario: OptiScaler.ini missing in game directory
- **WHEN** the game is launched, and `OptiScaler.ini` does not exist in the game directory
- **THEN** `bgmod` copies `OptiScaler.ini` from GOverlay's config directory to the game directory.

#### Scenario: OptiScaler.ini config directory is newer
- **WHEN** the game is launched, and the modification time of `OptiScaler.ini` in GOverlay's config directory is newer than the one in the game directory
- **THEN** `bgmod` copies/overwrites `OptiScaler.ini` in the game directory with the one from GOverlay's config directory.

#### Scenario: OptiScaler.ini game directory is newer
- **WHEN** the game is launched, and the modification time of `OptiScaler.ini` in the game directory is newer than or equal to the one in GOverlay's config directory
- **THEN** `bgmod` preserves the existing `OptiScaler.ini` in the game directory.

#### Scenario: fakenvapi.ini synced unconditionally
- **WHEN** the game is launched and `fakenvapi.ini` exists in GOverlay's config directory
- **THEN** `bgmod` copies `fakenvapi.ini` to the game directory, overwriting any existing one.
