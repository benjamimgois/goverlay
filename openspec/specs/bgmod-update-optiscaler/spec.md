# bgmod-update-optiscaler

## Purpose
This capability enables the `bgmod` execution wrapper to automatically update and sync the game's local configuration directory with the latest OptiScaler files on run, while avoiding redundant file copying on launch.
## Requirements
### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available by fetching a static JSON manifest file `versions.json` from a raw GitHub URL. The system SHALL compare the version string from the manifest against the installed version. The version comparison SHALL use numeric component ordering (e.g., `0.9.3 > 0.9.2`, `0.9.3-2 > 0.9.3-1`).

#### Scenario: Stable channel version detection
- **WHEN** the OptiScaler stable channel check reads the `versions.json` manifest
- **THEN** the system extracts the stable version string and URL without querying the GitHub tags API.

#### Scenario: Bleeding-edge channel version detection
- **WHEN** the OptiScaler bleeding-edge channel check reads the `versions.json` manifest
- **THEN** the system extracts the bleeding-edge version string and URL without querying the GitHub tags API.

#### Scenario: Update shown only when remote is higher
- **WHEN** the installed version is `0.9.3-0` and the latest remote version in the manifest is `0.9.3-0`
- **THEN** no update notification is shown.

#### Scenario: Older remote version does not trigger update
- **WHEN** the installed version is `0.9.4-0` and the latest remote version in the manifest is `0.9.3-0`
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

### Requirement: Save OptiScaler version in manifest file during update
When GOverlay updates/installs OptiScaler, it SHALL write or update the `OptiScalerVersion` key in the `goverlay.vars` file with the version tag that was installed. The file SHALL be saved in both the pristine `.bgmod_original` folder and the global `bgmod` configuration folder.

#### Scenario: Installation generates correct version variable
- **WHEN** GOverlay successfully extracts OptiScaler release `0.9.3-0`
- **THEN** GOverlay writes `OptiScalerVersion=0.9.3-0` to the `goverlay.vars` file in both directories.

### Requirement: Copy plugins folder during manual update
When GOverlay updates OptiScaler files during a manual update, it SHALL copy the `plugins` folder (if it exists) from the pristine `.bgmod_original` folder to the global `bgmod` configuration folder.

#### Scenario: Update copies plugins folder successfully
- **WHEN** GOverlay performs a manual update and `.bgmod_original/plugins` directory exists
- **THEN** GOverlay copies `.bgmod_original/plugins` directory recursively to the global `bgmod` directory.

### Requirement: Move OptiScaler subfolder contents to root
After extracting the OptiScaler release archive to `.bgmod_original`, GOverlay SHALL check if an `OptiScaler` subfolder exists. If present, it SHALL recursively copy all files and directories inside `OptiScaler` to the root of `.bgmod_original` and then delete the `OptiScaler` subfolder.

#### Scenario: Subfolder contents moved to root during update
- **WHEN** OptiScaler is extracted to `.bgmod_original` and contains a subfolder named `OptiScaler`
- **THEN** GOverlay moves its contents to the root and deletes the `OptiScaler` subfolder.

### Requirement: Download frame generation helper
When installing or updating OptiScaler (both interactive and auto-install), GOverlay SHALL download `dlssg_to_fsr3_amd_is_better.dll` from the stable releases URL to `.bgmod_original`.

#### Scenario: Auxiliary DLL downloaded successfully
- **WHEN** GOverlay performs a manual or automatic OptiScaler installation
- **THEN** the auxiliary DLL `dlssg_to_fsr3_amd_is_better.dll` is downloaded to `.bgmod_original`.

### Requirement: Download and extract FakeNVAPI
GOverlay SHALL query the GitHub API to find the latest stable release tag of `fakenvapi`. It SHALL download the `.7z` release archive, extract it to `.bgmod_original`, delete the downloaded archive, and add `FakeNvapiVersion=<version>` (without the 'v' prefix) to `goverlay.vars`.

#### Scenario: FakeNVAPI installed and version tracked
- **WHEN** GOverlay updates or installs OptiScaler
- **THEN** GOverlay downloads and extracts the latest stable `fakenvapi` DLL and INI files, and writes `FakeNvapiVersion` to `goverlay.vars`.

### Requirement: Dynamic FSR and XeSS version resolution
During installation or update, GOverlay SHALL fetch `vars.txt` from the remote repository. It SHALL parse the FSR and XeSS version strings for both the stable and edge channels, and write the corresponding values as `fsrversion` and `xessversion` to `goverlay.vars` based on the selected channel.

#### Scenario: Versions retrieved and written to variables file
- **WHEN** GOverlay installs or updates OptiScaler on the stable or edge channel
- **THEN** it parses `vars.txt` and writes the correct `fsrversion` and `xessversion` keys to `goverlay.vars`.

