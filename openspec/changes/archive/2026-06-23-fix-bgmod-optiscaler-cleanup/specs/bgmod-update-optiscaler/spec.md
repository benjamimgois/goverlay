## ADDED Requirements

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
