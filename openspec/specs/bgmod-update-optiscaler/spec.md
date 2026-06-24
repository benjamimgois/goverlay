# bgmod-update-optiscaler

This capability enables the `bgmod` execution wrapper to automatically update and sync the game's local configuration directory with the latest OptiScaler files on run, while avoiding redundant file copying on launch.

## Requirements

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

### Requirement: Conditional OptiScaler disabled cleanup
The `bgmod` execution wrapper SHALL only perform the OptiScaler cleanup/restoring routine (restoring backup DLLs, deleting OptiScaler libraries/folders, and removing plugins directory) if the `goverlay.vars` file exists in the game directory. If `goverlay.vars` is not present, no cleanup or file operations for OptiScaler SHALL be performed.

#### Scenario: Cleanup when previously installed
- **WHEN** `bgmod` is executed with OptiScaler disabled and `goverlay.vars` is present in the game directory
- **THEN** `bgmod` restores backup files, deletes OptiScaler files, and deletes the `goverlay.vars` file.

#### Scenario: No cleanup when never installed
- **WHEN** `bgmod` is executed with OptiScaler disabled and `goverlay.vars` is NOT present in the game directory
- **THEN** `bgmod` skips all cleanup operations and does not modify any files in the game directory.

### Requirement: Uninstaller cleanup of version file
When the `bgmod-uninstaller` runs, it SHALL delete the `goverlay.vars` file from the game directory to ensure a complete clean.

#### Scenario: Uninstaller execution
- **WHEN** `bgmod-uninstaller` executes in the game directory
- **THEN** `bgmod-uninstaller` deletes `goverlay.vars`.

