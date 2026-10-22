# Spec Delta

## ADDED Requirements

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
