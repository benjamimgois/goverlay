## Why

Installing OptiScaler on the bleeding-edge channel always writes `goverlay.vars` to `~/.local/share/goverlay/gameconfig/global/`, even when a game is selected. Likewise, the "Software status" card on the OptiScaler tab reads the global pristine `bgmod/` instead of the active game's `gameconfig/<game>/`. As a result, switching a game to bleeding-edge leaves that game's `goverlay.vars` showing stable versions and the status card never reflects per-game reality. The per-game isolation model introduced by `global-profile-gameconfig-isolation` is incomplete on the install + status paths.

## What Changes

- **Per-game install target**: `UpdateButtonClick` SHALL resolve the active install destination as `GetGameConfigDir(FActiveGameName)` (global when empty, otherwise the game folder). All DLLs, `plugins/`, `FSR4_*`, `fakenvapi.ini`, and the regenerated `goverlay.vars` are written to that destination, not to a hardcoded `gameconfig/global/`.
- **First-selection stable seeding**: When a game card is clicked for the first time (no `gameconfig/<game>/goverlay.vars` yet), GOverlay SHALL copy the stable OptiScaler DLLs/assets from `.bgmod_original` into `gameconfig/<game>/` and generate a stable `goverlay.vars` there, so the Software status card shows the stable version immediately.
- **Per-game status source**: `LoadVersionsFromFile`, `RefreshOsStatusDots`, and `InitializeTab` SHALL read `goverlay.vars` from `GetGameConfigDir(FActiveGameName)` instead of the global pristine `FFGModPath`. The OptiScaler tab's `FGModPath` is re-pointed whenever the active game changes.
- **OptiScaler tab per-game visibility**: `Tgoverlayform.GameCardClick` SHALL make `optiscalertabsheet.TabVisible := True` so users can view and interact with Software status per-game. All form fields remain disabled when the game's OptiScaler toggle is off (existing behavior preserved); only the channel combobox + update button are actionable when enabled.
- **Clobber on install**: Per-game install SHALL overwrite the destination's existing `goverlay.vars` and DLLs (force copy), ensuring a switch from stable → bleeding-edge actually replaces the files. The global pristine `.bgmod_original` remains the no-clobber template source for first-selection seeding.
- **Cache reuse**: When the user switches a game to bleeding-edge, GOverlay SHALL reuse the cached `.bgmod_original` extraction if its `OptiScalerVersion` already matches the latest edge tag fetched from the manifest; a full re-download only happens when the cached tag differs or is absent.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `bgmod-update-optiscaler`: Install/destination path becomes per-game; Software status reads active game's `goverlay.vars`; first-click seeds stable assets; OptiScaler tab visible for per-game interaction; cached extraction is reused when its tag matches the latest remote.
- `fix-optiscaler-channel-leak`: Channel combobox restoration on game switch is reinforced by re-pointing `FGModPath` and reloading versions from `gameconfig/<game>/` whenever the active game changes.

## Impact

- **Affected files**: `optiscaler_update.pas` (install destination, FGModPath re-pointing, cache reuse), `overlay_config.pas` (status path resolution), `optiscaler_tab.pas` (RefreshOsStatusDots source), `overlayunit.pas` (GameCardClick hookup, tab visibility, FOptiscalerUpdate.FGModPath on game switch), `games_tab.pas` (first-selection stable seeding, tab visibility), `sidebar_nav.pas` (CopyOptiScalerGameFiles clobber vs. no-clobber distinction).
- **APIs & Paths**: `TOptiscalerTab.FGModPath` becomes the active config dir, not the pristine install dir; `UpdateButtonClick` destination resolution changes; `RefreshOsStatusDots` source labels reflect the active game's vars.
- **Persisted data**: New per-game `goverlay.vars` files created on first selection (stable seeding); existing game vars files overwritten on channel install.
- **Compatibility**: Users with existing `gameconfig/<game>/` folders get their `goverlay.vars` regenerated with the correct channel version on next install; first-selection seeding is skipped when a vars file already exists.