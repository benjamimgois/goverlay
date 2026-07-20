# bgmod-update-optiscaler

## Purpose
This capability enables the `bgmod` execution wrapper to automatically update and sync the game's local configuration directory with the latest OptiScaler files on run, while avoiding redundant file copying on launch.
## Requirements
### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available by fetching a static JSON manifest file `versions.json` from a raw GitHub URL. The system SHALL compare the version string from the manifest against the installed version. The version comparison SHALL strip version channel prefixes (specifically `stable.` and `edge.`) and use numeric component ordering (e.g., `0.9.3 > 0.9.2`, `0.9.3-2 > 0.9.3-1`).

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

#### Scenario: Stable channel update available
- **WHEN** the installed version is `0.9.3-0` and the latest remote version in the stable manifest is `stable-0.9.4`
- **THEN** the system strips the `stable.` prefix during comparison, detects that `0.9.4` is newer than `0.9.3.0`, and displays the update notification.

#### Scenario: Edge channel update available
- **WHEN** the installed version is `edge-0.9.3-0` and the latest remote version in the edge manifest is `edge-0.9.4-1`
- **THEN** the system strips the `edge.` prefix during comparison, detects that `0.9.4.1` is newer than `0.9.3.0`, and displays the update notification.

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
When GOverlay updates/installs OptiScaler, it SHALL write or update the `OptiScalerVersion` key in the `goverlay.vars` file with the version tag that was installed. The file SHALL be saved in both the selected channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) and the active configuration folder.

#### Scenario: Installation generates correct version variable globally
- **WHEN** GOverlay successfully extracts OptiScaler release `0.9.3-0` with the global profile active on stable channel
- **THEN** GOverlay writes `OptiScalerVersion=0.9.3-0` to the `goverlay.vars` file in both `optiscaler-stable` and `gameconfig/global/`.

#### Scenario: Installation generates correct version variable per-game
- **WHEN** GOverlay successfully extracts OptiScaler release `edge-0.9.4-1` with the game `Hades` active on bleeding-edge channel
- **THEN** GOverlay writes `OptiScalerVersion=edge-0.9.4-1` to the `goverlay.vars` file in both `optiscaler-edge` and `gameconfig/Hades/`, and does NOT write to `gameconfig/global/`.

### Requirement: Copy plugins folder during manual update
When GOverlay updates OptiScaler files during a manual update, it SHALL copy the `plugins` folder (if it exists) from the active channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) directly to the destination directory.

#### Scenario: Update copies plugins folder successfully
- **WHEN** GOverlay performs a manual update on the stable channel and `optiscaler-stable/plugins` directory exists
- **THEN** GOverlay copies `optiscaler-stable/plugins` directory recursively to the target destination.

### Requirement: Move OptiScaler subfolder contents to root
After extracting the OptiScaler release archive to the chosen channel's cache folder, GOverlay SHALL check if an `OptiScaler` subfolder exists. If present, it SHALL recursively copy all files and directories inside `OptiScaler` to the root of the cache folder and then delete the `OptiScaler` subfolder.

#### Scenario: Subfolder contents moved to root during update
- **WHEN** OptiScaler is extracted to `optiscaler-stable` and contains a subfolder named `OptiScaler`
- **THEN** GOverlay moves its contents to the root of `optiscaler-stable` and deletes the `OptiScaler` subfolder.

### Requirement: Download frame generation helper
When installing or updating OptiScaler (both interactive and auto-install), GOverlay SHALL download `dlssg_to_fsr3_amd_is_better.dll` from the stable releases URL to the selected channel's cache folder.

#### Scenario: Auxiliary DLL downloaded successfully
- **WHEN** GOverlay performs a manual or automatic OptiScaler installation
- **THEN** the auxiliary DLL `dlssg_to_fsr3_amd_is_better.dll` is downloaded to the target channel's cache folder.

### Requirement: Download and extract FakeNVAPI
GOverlay SHALL query the GitHub API to find the latest stable release tag of `fakenvapi`. It SHALL download the `.7z` release archive, extract it to the selected channel's cache folder, delete the downloaded archive, and add `FakeNvapiVersion=<version>` (without the 'v' prefix) to `goverlay.vars` inside the cache folder.

When updating the `FakeNvapiVersion` key in an existing `goverlay.vars`, the system SHALL match the key using a prefix copy of exactly 17 characters (`'fakenvapiversion='`) so that the existing line is correctly identified and updated in-place rather than a duplicate line being appended.

#### Scenario: FakeNVAPI installed and version tracked
- **WHEN** GOverlay updates or installs OptiScaler
- **THEN** GOverlay downloads and extracts the latest stable `fakenvapi` DLL and INI files to the cache folder, and writes `FakeNvapiVersion` to `goverlay.vars`.

#### Scenario: FakeNVAPI version key updated in-place
- **WHEN** GOverlay performs a second install or update and the `goverlay.vars` file already contains a `FakeNvapiVersion=<old>` line
- **THEN** GOverlay replaces that line in-place with the new version, and no duplicate `FakeNvapiVersion` line is added.

#### Scenario: FakeNVAPI version key removed on uninstall
- **WHEN** GOverlay uninstalls OptiScaler for a game or switches game context
- **THEN** the `FakeNvapiVersion` line is correctly removed from the game's `goverlay.vars` during cleanup.

### Requirement: Dynamic FSR and XeSS version resolution
During installation or update, GOverlay SHALL fetch `vars.txt` from the remote repository. It SHALL parse the FSR and XeSS version strings for both the stable and edge channels, and write the corresponding values as `fsrversion` and `xessversion` to `goverlay.vars` based on the selected channel.

#### Scenario: Versions retrieved and written to variables file
- **WHEN** GOverlay installs or updates OptiScaler on the stable or edge channel
- **THEN** it parses `vars.txt` and writes the correct `fsrversion` and `xessversion` keys to `goverlay.vars`.

#### Scenario: Network failure during version resolution fallback to defaults
- **WHEN** the remote `vars.txt` file cannot be reached during installation or update
- **THEN** GOverlay SHALL fallback to using the default version `4.1.1` for FSR on the stable channel.

### Requirement: gameconfig/global/ receives full OptiScaler assets on first run
When GOverlay auto-installs OptiScaler during the first run, the global profile configuration directory SHALL receive the downloaded OptiScaler runtime files directly from `optiscaler-stable/`.

#### Scenario: Auto-install on first run
- **WHEN** GOverlay auto-installs OptiScaler because the global config folder does not yet contain `OptiScaler.dll`
- **THEN** after the download and extraction finish, `~/.local/share/goverlay/gameconfig/global/` SHALL contain the same OptiScaler DLLs, plugins, and supporting libraries as `~/.local/share/goverlay/optiscaler-stable/`.

### Requirement: Per-game install destination resolution
When GOverlay installs or updates OptiScaler, the active install destination SHALL be `GetGameConfigDir(FActiveGameName)` — `~/.local/share/goverlay/gameconfig/global/` when no game is selected, or `~/.local/share/goverlay/gameconfig/<game>/` when a game is active. The freshly downloaded DLLs, `plugins/`, `FSR4_LATEST/`, `FSR4_INT8/`, `fakenvapi.ini`, and the regenerated `goverlay.vars` SHALL be written directly to that destination from the corresponding cache directory (`optiscaler-stable` or `optiscaler-edge` depending on the selected channel).

#### Scenario: Bleeding-edge install with a game selected
- **WHEN** a game `Cyberpunk2077` is active and the user switches to the bleeding-edge channel and clicks Update
- **THEN** GOverlay writes the bleeding-edge DLLs, plugins, FSR4 folders, `fakenvapi.ini`, and a `goverlay.vars` containing `OptiScalerVersion=<edge-tag>` directly from `optiscaler-edge` to `~/.local/share/goverlay/gameconfig/Cyberpunk2077/`, leaving `gameconfig/global/` untouched.

#### Scenario: Stable install with global profile active
- **WHEN** no game is selected and the user installs the stable channel
- **THEN** the destination is `~/.local/share/goverlay/gameconfig/global/`, copying files directly from `optiscaler-stable` to `gameconfig/global/`.

### Requirement: Cache reuse on per-game channel switch
When the user triggers an OptiScaler install on a channel and the corresponding cache folder (`optiscaler-stable/goverlay.vars` or `optiscaler-edge/goverlay.vars`) already contains an `OptiScalerVersion` that equals the latest tag for that channel freshly fetched from the manifest, GOverlay SHALL skip the 7z download and extraction steps and reuse the cached assets. It SHALL still force-copy the DLLs/assets and regenerate `goverlay.vars` in the active destination.

#### Scenario: Cached edge tag matches latest remote
- **WHEN** `optiscaler-edge/goverlay.vars` already has `OptiScalerVersion=edge-0.9.4-1`, the user selects a game that currently shows stable and switches to bleeding-edge, and the latest edge tag fetched from the manifest is `edge-0.9.4-1`
- **THEN** GOverlay does NOT download `optiscaler-edge.7z` again; it copies the cached DLLs from `optiscaler-edge` into `gameconfig/<game>/` and writes a fresh `goverlay.vars` with `OptiScalerVersion=edge-0.9.4-1` there.

#### Scenario: Cached tag differs from latest remote
- **WHEN** the cached `optiscaler-edge` tag is `edge-0.9.3-0` and the latest edge tag is `edge-0.9.4-1`
- **THEN** GOverlay downloads and extracts the new `optiscaler-edge.7z` into `optiscaler-edge` before copying to the active destination.

### Requirement: First-selection stable seeding on game card click
When the user clicks a game card whose `gameconfig/<game>/goverlay.vars` does not yet exist, GOverlay SHALL seed the game's config folder with only the core wrapper scripts (`bgmod`, `bgmod-uninstaller`, and a default `goverlay.vars` baseline) from the pristine `bgmod` template directory. The actual OptiScaler DLLs and plugin assets SHALL NOT be copied at this time.

#### Scenario: First click on a game with no config
- **WHEN** the user clicks the game card for `Hades` and `~/.local/share/goverlay/gameconfig/Hades/goverlay.vars` does not exist
- **THEN** GOverlay force-creates `gameconfig/Hades/` and copies only the core wrapper files (`bgmod`, `bgmod-uninstaller`, `goverlay.vars`) from `~/.local/share/goverlay/bgmod/` (no-clobber for `bgmod.conf`), leaving all OptiScaler DLLs/plugins uncopied.

#### Scenario: Existing vars file skips seeding
- **WHEN** the user clicks a game card and `gameconfig/<game>/goverlay.vars` already exists
- **THEN** GOverlay does not re-seed; it only re-points `FOptiscalerUpdate.FGModPath` to that folder and refreshes the Software status card.

### Requirement: Per-game Software status source
The OptiScaler tab's Software status card (`RefreshOsStatusDots`) and the version labels it mirrors (populated by `LoadVersionsFromFile` and `InitializeTab`) SHALL read `goverlay.vars` from `GetGameConfigDir(FActiveGameName)` rather than from the global pristine `bgmod/` path. Whenever the active game changes, GOverlay SHALL re-point `TOptiscalerTab.FGModPath` to the new game config dir, reload versions, and refresh the status dots before the user can interact with the tab.

#### Scenario: Switching from a stable game to a bleeding-edge game
- **WHEN** the user is on game A (stable, `OptiScalerVersion=0.9.3-0`) and clicks game B (bleeding-edge, `OptiScalerVersion=edge-0.9.4-1`)
- **THEN** the Software status card updates to show `edge-0.9.4-1` for OptiScaler and the bleeding-edge FSR/XeSS versions for game B, without restarting GOverlay.

#### Scenario: Returning to global profile
- **WHEN** the user returns to the global profile (no active game) after interacting with a bleeding-edge game
- **THEN** the Software status card reflects the global `gameconfig/global/goverlay.vars`, which is unaffected by the per-game install.

### Requirement: OptiScaler tab visible per-game
The OptiScaler tab SHALL be visible when a game is selected so the user can view and interact with Software status and channel selection per-game. All form controls on the tab (including the channel combobox and Update button) SHALL remain disabled when the game's OptiScaler toggle is off, preserving the existing `ApplyToolEnabledState` gating; enabling the toggle re-enables the controls.

#### Scenario: Game selected with OptiScaler toggle off
- **WHEN** the user selects a game whose OptiScaler toggle is off
- **THEN** the OptiScaler tab is visible, the Software status card displays the game's versions, and all controls (channel combobox, Update button, checkboxes) are disabled.

#### Scenario: Game selected with OptiScaler toggle on
- **WHEN** the user enables the OptiScaler toggle for the active game
- **THEN** the channel combobox and Update button become enabled, allowing the user to switch the game to bleeding-edge and install.

### Requirement: Copy OptiScaler assets only when toggle is enabled
When the user enables the OptiScaler toggle for a game (or global profile), GOverlay SHALL copy the OptiScaler files (DLLs, plugins, FSR4 folders, `fakenvapi.ini`, and `goverlay.vars`) from the configured channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) to the target config directory.

#### Scenario: OptiScaler toggle enabled for a stable game
- **WHEN** the user enables the OptiScaler toggle for a game set to the stable channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-stable` to the game's config directory.

#### Scenario: OptiScaler toggle enabled for a bleeding-edge game
- **WHEN** the user enables the OptiScaler toggle for a game set to the bleeding-edge channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-edge` to the game's config directory.

### Requirement: Fallback load of default OptiScaler settings when missing
When GOverlay loads the OptiScaler configuration for a profile (global or game), if `OptiScaler.ini` does not exist in the profile's configuration directory, GOverlay SHALL load the configuration values from the default `OptiScaler.ini` file located in the active channel's cache folder (Stable or Edge depending on `OPT_CHANNEL` in `bgmod.conf`).

#### Scenario: Global OptiScaler.ini is missing on load
- **WHEN** the user opens the OptiScaler tab with the global profile active and `gameconfig/global/OptiScaler.ini` does not exist
- **THEN** GOverlay loads the default `ShortcutKey`, `Scale`, and checkbox values from the `OptiScaler.ini` file in the configured channel's cache folder, populating the GUI.

### Requirement: Seed default OptiScaler.ini template during configuration save
When saving the OptiScaler configuration, if the target `OptiScaler.ini` file does not exist in the profile's configuration directory, GOverlay SHALL copy the template `OptiScaler.ini` file from the active channel's cache folder to the destination directory before loading, modifying, and saving the updated user settings.

#### Scenario: Global OptiScaler.ini is missing on save
- **WHEN** the user saves the global OptiScaler configuration and `gameconfig/global/OptiScaler.ini` does not exist
- **THEN** GOverlay copies `OptiScaler.ini` from the active channel's cache folder into `gameconfig/global/` and then successfully saves the user's customized GUI selections to it.

### Requirement: Unreal Engine game folder resolution in bgmod
The `bgmod` launcher wrapper and `bgmod-uninstaller` SHALL resolve the game's binaries directory for Unreal Engine games by searching for subfolders containing `Binaries/Win64` while ignoring standard engine/system utility folders named `ENGINE`, `BUGREPORTCLIENT`, and `CRASHREPORTCLIENT` (case-insensitively).

#### Scenario: Game directory resolved with utility folders present
- **WHEN** the game directory contains subfolders named `BugReportClient`, `Engine`, and `RogueCore`, and `RogueCore` has a `Binaries/Win64` subfolder containing the game executable
- **THEN** the system ignores `BugReportClient` and `Engine`, recursively enters `RogueCore`, and resolves the target game directory as `RogueCore/Binaries/Win64`.

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

### Requirement: Robust path resolution for bgmod template binaries
During the initialization of the local configuration directory (`InitializeBGModDirectory`), GOverlay SHALL locate the template binaries (`bgmod` and `bgmod-uninstaller`) by checking the following candidate locations:
1. GOverlay's executable directory (`ExtractFilePath(ParamStr(0))`).
2. GOverlay's executable directory's relative `lib/` directory.
3. The directory specified by the `$APPDIR` environment variable, specifically under `$APPDIR/lib/` (for AppImage compatibility).

If found in any of these candidate locations, GOverlay SHALL copy them to the local `bgmod/` configuration directory.

#### Scenario: AppImage environment path resolution
- **WHEN** GOverlay is executed inside an AppImage, and the template binaries exist in `/tmp/.mount_XXXXXX/lib/`
- **THEN** GOverlay successfully copies `bgmod` and `bgmod-uninstaller` to `~/.local/share/goverlay/bgmod/`.

#### Scenario: Source development directory resolution
- **WHEN** GOverlay is run from the source root directory, and the compiled `bgmod` and `bgmod-uninstaller` exist in the same root directory
- **THEN** GOverlay successfully copies `bgmod` and `bgmod-uninstaller` to `~/.local/share/goverlay/bgmod/`.


### Requirement: Synchronize GPU driver options to configuration files
When the GPU driver selection (NVIDIA or MESA) is toggled in the OptiScaler tab, GOverlay SHALL automatically, immediately, and silently save the updated status of dependent options (such as Spoof DLSS, Force Reflex, and Reflex) into their respective configuration files (`OptiScaler.ini` and `fakenvapi.ini`) to prevent UI desynchronization on tab change or application reload.

The synchronization save operation SHALL be silent (i.e. not trigger user-facing desktop notifications or command panel updates/invalidations) when initiated programmatically via driver selection changes. GOverlay SHALL NOT trigger any configuration saving during application startup when restoring the previously saved driver selection.

#### Scenario: Switching to MESA saves dependent configs silently
- **WHEN** the user selects the MESA GPU Driver option
- **THEN** GOverlay enables and checks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files silently (no desktop notifications or command panel updates).

#### Scenario: Switching to NVIDIA saves dependent configs silently
- **WHEN** the user selects the NVIDIA GPU Driver option
- **THEN** GOverlay disables and unchecks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files silently (no desktop notifications or command panel updates).

#### Scenario: Program startup does not trigger save operations
- **WHEN** GOverlay starts up and loads the saved driver preference
- **THEN** the driver radio button is updated in the UI, but no configuration files are written, and no desktop notifications are shown.

### Requirement: Global navigation updates Save button state
When the user switches tabs (MangoHud, vkBasalt, OptiScaler, Tweaks) in global mode, GOverlay SHALL update the Save button enabled state and the tab sheet enabled state to reflect the global enable status of the target tool.

#### Scenario: Navigating to OptiScaler global updates save button
- **WHEN** the user clicks the OptiScaler tab in global mode and the OptiScaler tool is globally enabled
- **THEN** the Save button is enabled and set to the active color.

