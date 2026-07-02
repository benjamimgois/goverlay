## ADDED Requirements

### Requirement: Per-game install destination resolution
When GOverlay installs or updates OptiScaler, the active install destination SHALL be `GetGameConfigDir(FActiveGameName)` — `~/.local/share/goverlay/gameconfig/global/` when no game is selected, or `~/.local/share/goverlay/gameconfig/<game>/` when a game is active. The freshly downloaded DLLs, `plugins/`, `FSR4_LATEST/`, `FSR4_INT8/`, `fakenvapi.ini`, and the regenerated `goverlay.vars` SHALL be written to that destination. The pristine `~/.local/share/goverlay/bgmod/` MAY also be kept in sync with `.bgmod_original` for heuristics, but it MUST NOT be the active destination when a game is selected.

#### Scenario: Bleeding-edge install with a game selected
- **WHEN** a game `Cyberpunk2077` is active and the user switches to the bleeding-edge channel and clicks Update
- **THEN** GOverlay writes the bleeding-edge DLLs, plugins, FSR4 folders, `fakenvapi.ini`, and a `goverlay.vars` containing `OptiScalerVersion=<edge-tag>` to `~/.local/share/goverlay/gameconfig/Cyberpunk2077/`, leaving `gameconfig/global/` untouched.

#### Scenario: Stable install with global profile active
- **WHEN** no game is selected and the user installs the stable channel
- **THEN** the destination is `~/.local/share/goverlay/gameconfig/global/`, preserving the existing behavior for the global profile.

### Requirement: Cache reuse on per-game channel switch
When the user triggers an OptiScaler install on a channel and `.bgmod_original/goverlay.vars` already contains an `OptiScalerVersion` that equals the latest tag for that channel freshly fetched from the manifest, GOverlay SHALL skip the 7z download and extraction steps and reuse the cached `.bgmod_original` assets. It SHALL still force-copy the DLLs/assets and regenerate `goverlay.vars` in the active destination.

#### Scenario: Cached edge tag matches latest remote
- **WHEN** `.bgmod_original/goverlay.vars` already has `OptiScalerVersion=edge-0.9.4-1`, the user selects a game that currently shows stable and switches to bleeding-edge, and the latest edge tag fetched from the manifest is `edge-0.9.4-1`
- **THEN** GOverlay does NOT download `optiscaler-edge.7z` again; it copies the cached DLLs into `gameconfig/<game>/` and writes a fresh `goverlay.vars` with `OptiScalerVersion=edge-0.9.4-1` there.

#### Scenario: Cached tag differs from latest remote
- **WHEN** the cached `.bgmod_original` tag is `edge-0.9.3-0` and the latest edge tag is `edge-0.9.4-1`
- **THEN** GOverlay downloads and extracts the new `optiscaler-edge.7z` into `.bgmod_original` before copying to the active destination.

### Requirement: First-selection stable seeding
When the user clicks a game card whose `gameconfig/<game>/goverlay.vars` does not yet exist, GOverlay SHALL seed the game's config folder with the stable OptiScaler assets from `.bgmod_original` (no-clobber for user-editable files such as `bgmod.conf`, `OptiScaler.ini`, `fakenvapi.ini`) and SHALL place a stable `goverlay.vars` there, so that the Software status card immediately displays the stable version for that game.

#### Scenario: First click on a game with no config
- **WHEN** the user clicks the game card for `Hades` and `~/.local/share/goverlay/gameconfig/Hades/goverlay.vars` does not exist
- **THEN** GOverlay force-creates `gameconfig/Hades/`, copies the stable OptiScaler DLLs and supporting assets from `.bgmod_original` (no-clobber for `bgmod.conf`/`OptiScaler.ini`/`fakenvapi.ini`), and writes a `goverlay.vars` containing `OptiScalerVersion=<stable-tag>` to `gameconfig/Hades/`.

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

## MODIFIED Requirements

### Requirement: Save OptiScaler version in manifest file during update
When GOverlay updates/installs OptiScaler, it SHALL write or update the `OptiScalerVersion` key in the `goverlay.vars` file with the version tag that was installed. The file SHALL be saved in both the pristine `.bgmod_original` folder and the active configuration folder — `~/.local/share/goverlay/gameconfig/global/` when no game is selected, or `~/.local/share/goverlay/gameconfig/<game>/` when a game is active.

#### Scenario: Installation generates correct version variable globally
- **WHEN** GOverlay successfully extracts OptiScaler release `0.9.3-0` with the global profile active
- **THEN** GOverlay writes `OptiScalerVersion=0.9.3-0` to the `goverlay.vars` file in both `.bgmod_original` and `gameconfig/global/`.

#### Scenario: Installation generates correct version variable per-game
- **WHEN** GOverlay successfully extracts OptiScaler release `edge-0.9.4-1` with the game `Hades` active
- **THEN** GOverlay writes `OptiScalerVersion=edge-0.9.4-1` to the `goverlay.vars` file in both `.bgmod_original` and `gameconfig/Hades/`, and does NOT write to `gameconfig/global/`.