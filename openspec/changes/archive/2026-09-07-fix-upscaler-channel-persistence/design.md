## Context

See `proposal.md` for motivation. Currently, `optversionComboBox` (`0 = 'Stable Channel'`, `1 = 'Bleeding-edge'`) controls the channel for both OptiScaler and DLSS Enabler. When selected for a specific game profile, changes are not automatically persisted because `optversionComboBoxChange` lacks auto-save triggering. Additionally, `FOptiscalerUpdate.InitializeTab` hardcodes global configuration (`''`), which causes the combobox to be reset to the global channel when game cards are clicked or the application starts. Furthermore, `LoadVersionsFromFile` and `CopyOptiScalerGameFiles` ignore the channel selection when dealing with DLSS Enabler or OptiScaler fallback caches.

## Goals / Non-Goals

**Goals:**
- Persist `OPT_CHANNEL` immediately to the active profile's `bgmod.conf` (global or per-game) when `optversionComboBox` is changed.
- Honor the active game profile in `FOptiscalerUpdate.InitializeTab` so the saved channel is restored when clicking game cards or loading profiles.
- Immediately reload in-card version labels in `optversionComboBoxChange` via `FOptiscalerUpdate.LoadVersionsFromFile`.
- Ensure `TSidebarNavHelper.CopyOptiScalerGameFiles` deploys files from `GetDlssEnablerPath(IsStable)` for DLSS Enabler.
- Add an automated GUI test to verify per-game channel persistence across navigation and reloads.

**Non-Goals:**
- Adding channels to `lsfg-vk` or `Mako` (both upstream components maintain a single release stream and are not channelized).
- Changing the underlying download mechanism from GitHub repositories.

## Decisions

### 1. Auto-save on `optversionComboBoxChange`
- **Choice**: Call `StartAutoSaveTimer` and `FOptiscalerUpdate.LoadVersionsFromFile` inside `Tgoverlayform.optversionComboBoxChange`.
- **Rationale**: `WireAutoSaveEvents` skips `optversionComboBox` because its `OnChange` was already assigned. Calling `StartAutoSaveTimer` ensures that modifying the channel immediately writes `OPT_CHANNEL` to the active profile's `bgmod.conf` without requiring the user to touch other controls. Calling `LoadVersionsFromFile` refreshes the version labels in the Software Status card immediately to reflect the newly chosen channel.
- **Alternatives considered**: Manually adding an OnChange wrapper in `WireAutoSaveEvents`. Rejected because `optversionComboBoxChange` is the centralized event handler and is already dedicated to channel updates.

### 2. Respect active game profile in `InitializeTab`
- **Choice**: Pass the active game profile name (`Tgoverlayform(goverlayform).FActiveGameName`) when calling `overlay_config.LoadOptiScalerConfig` in `FOptiscalerUpdate.InitializeTab`.
- **Rationale**: Currently, `LoadOptiScalerConfig('', SavedSettings)` is called with an empty string, which forces global settings even when a game card was just clicked. Loading with `FActiveGameName` correctly restores the game profile's saved `OPT_CHANNEL`.
- **Alternatives considered**: Passing a game profile parameter to `InitializeTab`. Rejected because `FOptiscalerUpdate` already has access to `goverlayform` and `FFGModPath`.

### 3. Deploy correct channel assets in `CopyOptiScalerGameFiles`
- **Choice**: Change `CacheDir := GetDlssEnablerPath` to `CacheDir := GetDlssEnablerPath(IsStable)` in `TSidebarNavHelper.CopyOptiScalerGameFiles`.
- **Rationale**: `GetDlssEnablerPath` defaults to `True` (Stable). Passing `IsStable` ensures that if `OPT_CHANNEL=1` (Bleeding-edge/Trunk) is configured, the trunk assets from `dlssenabler-edge/` are deployed rather than stable assets.
- **Alternatives considered**: Always deploying stable and letting update scripts swap. Rejected because GOverlay already maintains separate `dlssenabler-stable` and `dlssenabler-edge` cache folders.

### 4. Cache resolution in `LoadVersionsFromFile`
- **Choice**: In `optiscaler_update.pas`, check `FOptVersionComboBox.ItemIndex` when selecting the fallback cache directory for OptiScaler versions (`GetBGModOriginalEdgePath` if index is 1, otherwise `GetBGModOriginalPath`).
- **Rationale**: Ensures the displayed OptiScaler version reflects the selected channel when local `goverlay.vars` is evaluated.

## Risks / Trade-offs

- **[Risk]** Unintended auto-save triggers during form initialization or programmatic combobox index assignment.
  → **Mitigation**: `StartAutoSaveTimer` checks `if FLoadingConfig then Exit;`, and `LoadOptiScalerConfig` temporarily detaches `optversionComboBox.OnChange := nil`.
- **[Risk]** Game profile without `bgmod.conf` falling back unexpectedly.
  → **Mitigation**: `LoadOptiScalerConfig` already handles missing config files gracefully and defaults to index 0 (`Stable Channel`).
