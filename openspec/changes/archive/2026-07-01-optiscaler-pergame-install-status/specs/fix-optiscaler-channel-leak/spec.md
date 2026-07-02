## MODIFIED Requirements

### Requirement: Default OptiScaler channel to Stable on load
When GOverlay loads the configuration for a game or global settings, if the configuration does not contain a saved `OPT_CHANNEL` index (or if it is invalid/not set), GOverlay SHALL default the update channel combobox selection to index `0` ("Stable Channel"). Additionally, whenever the active game changes, GOverlay SHALL re-point `TOptiscalerTab.FGModPath` to `GetGameConfigDir(FActiveGameName)`, reload versions from that folder's `goverlay.vars` via `LoadVersionsFromFile`, and refresh the Software status dots via `RefreshOsStatusDots` before the user can interact with the OptiScaler tab, so the combobox and status reflect the newly active game's saved channel and versions rather than the previously loaded game's selections.

#### Scenario: Loading new or unedited game configuration
- **WHEN** user selects a game config that has no saved `OPT_CHANNEL` setting
- **THEN** GOverlay selects index 0 ("Stable Channel") in `optversionComboBox` instead of leaking the previously loaded game's selection.

#### Scenario: Loading new or unedited global configuration
- **WHEN** user switches back to global configuration and it has no saved `OPT_CHANNEL` setting
- **THEN** GOverlay selects index 0 ("Stable Channel") in `optversionComboBox`.

#### Scenario: Switching games reloads versions from the new game's config dir
- **WHEN** the user switches from game A (saved bleeding-edge, `OptiScalerVersion=edge-0.9.4-1`) to game B (saved stable, `OptiScalerVersion=0.9.3-0`)
- **THEN** `TOptiscalerTab.FGModPath` is re-pointed to `gameconfig/gameB/`, `LoadVersionsFromFile` reads that folder's `goverlay.vars`, the OptiScaler version label updates to `0.9.3-0`, the channel combobox restores to game B's saved `OPT_CHANNEL`, and `RefreshOsStatusDots` refreshes the Software status card to game B's versions before the user interacts with the tab.

#### Scenario: Returning to global after a per-game install
- **WHEN** the user returns to the global profile after installing bleeding-edge on a game
- **THEN** `TOptiscalerTab.FGModPath` is re-pointed to `gameconfig/global/`, the Software status card reflects the global `goverlay.vars`, and the channel combobox restores to the global profile's saved `OPT_CHANNEL` (or defaults to Stable when unset).