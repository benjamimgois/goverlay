## MODIFIED Requirements

### Requirement: Conditional OptiScaler disabled cleanup
The `bgmod` execution wrapper SHALL NOT perform any file cleanup, restoration, or deletion in the game directory when OptiScaler is disabled. No files, folders, or configuration SHALL be modified in the game directory during this code path.

#### Scenario: OptiScaler disabled
- **WHEN** `bgmod` is executed with OptiScaler disabled
- **THEN** `bgmod` logs a skip message and does not modify any files in the game directory.

## REMOVED Requirements

### Requirement: Uninstaller cleanup of version file
**Reason**: This requirement was only needed because the cleanup guard checked `goverlay.vars`. Since bgmod no longer performs cleanup at launch, `goverlay.vars` deletion in bgmod is no longer relevant. The uninstaller still deletes `goverlay.vars` as part of its full cleanup — this is implementation behavior, not a separate spec requirement.
**Migration**: No migration needed. Uninstaller behavior is unchanged.
