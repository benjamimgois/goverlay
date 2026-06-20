## ADDED Requirements

### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available centrally/globally by comparing the `goverlay.vars` files in the global and local configuration directories. If a mismatch exists or the local vars file is missing, it SHALL sync the latest DLLs, folders, and resources from the global directory to the game's local configuration folder.

#### Scenario: Version mismatch or missing local files
- **WHEN** the game is executed via `bgmod` and the central `goverlay.vars` is newer or the local `goverlay.vars` does not exist
- **THEN** `bgmod` syncs the latest files from the central directory to the local config directory, preserving user configuration files like `bgmod.conf` and `OptiScaler.ini`.

### Requirement: Prevent redundant file copies
The `bgmod` execution SHALL avoid copying OptiScaler files to the game directory on run if the files already exist and match the version specified in the local config's `goverlay.vars`.

#### Scenario: Files already present and matching version
- **WHEN** the game is executed via `bgmod` and the game directory already has the proxy DLL and a `goverlay.vars` that matches the version in the local configuration folder
- **THEN** `bgmod` logs that files are up to date and skips the copying process to the game folder.

### Requirement: Copy version file to game folder
When `bgmod` installs or updates OptiScaler files in the game folder, it SHALL copy `goverlay.vars` to the game folder to track the version of files installed.

#### Scenario: Successful copy
- **WHEN** `bgmod` installs or updates OptiScaler files in the game folder
- **THEN** `bgmod` copies the `goverlay.vars` file to the game folder.
