# bgmod-update-optiscaler

This capability enables the `bgmod` execution wrapper to automatically update and sync the game's local configuration directory with the latest OptiScaler files on run, while avoiding redundant file copying on launch.

## Requirements

### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available centrally/globally by comparing the `goverlay.vars` files in the global and local configuration directories. The version comparison SHALL use numeric component ordering (e.g., `0.9.3 > 0.9.2`, `0.9.3-2 > 0.9.3-1`). The system SHALL collect all matching tags from the GitHub API and return the numerically highest tag for the selected channel.

#### Scenario: Stable channel finds highest version
- **WHEN** the OptiScaler stable channel check fetches tags `0.9.2-0`, `0.9.3-0`, `0.9.1-0`
- **THEN** the system returns `0.9.3-0` as the latest version, regardless of API order.

#### Scenario: Bleeding-edge channel finds highest version
- **WHEN** the OptiScaler bleeding-edge check fetches tags `edge-0.9.4-1`, `edge-0.9.4-2`, `edge-0.9.3-5`
- **THEN** the system strips the `edge-` prefix, compares numerically, and returns `edge-0.9.4-2`.

#### Scenario: Update shown only when remote is higher
- **WHEN** the installed version is `0.9.3-0` and the latest remote version is `0.9.3-0`
- **THEN** no update notification is shown.

#### Scenario: Older remote version does not trigger update
- **WHEN** the installed version is `0.9.4-0` and the latest remote version is `0.9.3-0`
- **THEN** no update notification is shown.

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
The `bgmod` execution wrapper SHALL NOT perform any file cleanup, restoration, or deletion in the game directory when OptiScaler is disabled. No files, folders, or configuration SHALL be modified in the game directory during this code path.

#### Scenario: OptiScaler disabled
- **WHEN** `bgmod` is executed with OptiScaler disabled
- **THEN** `bgmod` logs a skip message and does not modify any files in the game directory.

### Requirement: Persist OptiScaler channel selection
The GOverlay OptiScaler tab SHALL save the user's channel selection (Stable or Bleeding‑edge) to the per‑game OptiScaler configuration and SHALL restore it on application startup or game switch, before falling back to the installed version tag heuristic.

#### Scenario: User selects Bleeding‑edge, restarts app
- **WHEN** the user selects "Bleeding‑edge" in the OptiScaler channel combobox, saves the configuration, and restarts the application
- **THEN** the combobox displays "Bleeding‑edge" (not "Stable‑channel").

#### Scenario: No saved preference (first run)
- **WHEN** no prior channel selection has been saved
- **THEN** the combobox falls back to the installed version tag (edge- prefix → Bleeding, otherwise Stable).

