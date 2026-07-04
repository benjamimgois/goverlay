## MODIFIED Requirements

### Requirement: First-selection stable seeding on game card click
When the user clicks a game card whose `gameconfig/<game>/goverlay.vars` does not yet exist, GOverlay SHALL seed the game's config folder with only the core wrapper scripts (`bgmod`, `bgmod-uninstaller`, and a default `goverlay.vars` baseline) from the pristine `bgmod` template directory. The actual OptiScaler DLLs and plugin assets SHALL NOT be copied at this time.

#### Scenario: First click on a game with no config
- **WHEN** the user clicks the game card for `Hades` and `~/.local/share/goverlay/gameconfig/Hades/goverlay.vars` does not exist
- **THEN** GOverlay force-creates `gameconfig/Hades/` and copies only the core wrapper files (`bgmod`, `bgmod-uninstaller`, `goverlay.vars`) from `~/.local/share/goverlay/bgmod/` (no-clobber for `bgmod.conf`), leaving all OptiScaler DLLs/plugins uncopied.

#### Scenario: Existing vars file skips seeding
- **WHEN** the user clicks a game card and `gameconfig/<game>/goverlay.vars` already exists
- **THEN** GOverlay does not re-seed; it only re-points `FOptiscalerUpdate.FGModPath` to that folder and refreshes the Software status card.

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

#### Scenario: FakeNVAPI installed and version tracked
- **WHEN** GOverlay updates or installs OptiScaler
- **THEN** GOverlay downloads and extracts the latest stable `fakenvapi` DLL and INI files to the cache folder, and writes `FakeNvapiVersion` to `goverlay.vars`.

### Requirement: gameconfig/global/ receives full OptiScaler assets on first run
When GOverlay auto-installs OptiScaler during the first run, the global profile configuration directory SHALL receive the downloaded OptiScaler runtime files directly from `optiscaler-stable/`.

#### Scenario: Auto-install on first run
- **WHEN** GOverlay auto-installs OptiScaler because the global config folder does not yet contain `OptiScaler.dll`
- **THEN** after the download and extraction finish, `~/.local/share/goverlay/gameconfig/global/` SHALL contain the same OptiScaler DLLs, plugins, and supporting libraries as `~/.local/share/goverlay/optiscaler-stable/`.

## ADDED Requirements

### Requirement: Copy OptiScaler assets only when toggle is enabled
When the user enables the OptiScaler toggle for a game (or global profile), GOverlay SHALL copy the OptiScaler files (DLLs, plugins, FSR4 folders, `fakenvapi.ini`, and `goverlay.vars`) from the configured channel's cache folder (`optiscaler-stable` or `optiscaler-edge`) to the target config directory.

#### Scenario: OptiScaler toggle enabled for a stable game
- **WHEN** the user enables the OptiScaler toggle for a game set to the stable channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-stable` to the game's config directory.

#### Scenario: OptiScaler toggle enabled for a bleeding-edge game
- **WHEN** the user enables the OptiScaler toggle for a game set to the bleeding-edge channel
- **THEN** GOverlay copies all OptiScaler runtime files and `goverlay.vars` from `optiscaler-edge` to the game's config directory.
