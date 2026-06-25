## Context

The OptiScaler channel combobox (`optversionComboBox`) has two options: "Stable Channel" (index 0) and "Bleeding-edge" (index 1). Currently, `InitializeTab` derives the selected index from the installed version tag in `goverlay.vars` — if the tag starts with `edge-` it's Bleeding, otherwise Stable. The user's explicit selection is never saved anywhere. On restart, the tag-based heuristic resets the combobox to Stable even if the user previously selected Bleeding.

## Goals / Non-Goals

**Goals:**
- Save the user's channel selection to per-game config so it survives restarts
- Load the saved selection on startup, before falling back to the version-tag heuristic
- Work for both global and per-game configurations

**Non-Goals:**
- Changing how the update/install logic works
- Adding a new config file — reuse existing `TOptiScalerSettings` flow

## Decisions

### 1. Add `OptVersionItemIndex` field to `TOptiScalerSettings`

- **Choice**: Add `OptVersionItemIndex: Integer` to the `TOptiScalerSettings` record in `overlay_config.pas`.
- **Rationale**: The Settings record already carries all OptiScaler tab state between save/load. Adding a field here ensures auto-persistence via the existing `SaveOptiScalerConfig` / `LoadOptiScalerConfig` flow.
- **Alternative considered**: Saving/loading directly to `bgmod.conf` via separate key. Rejected — breaks the single-source-of-truth pattern already used for OptiScaler config.

### 2. Read combobox in SaveOptiScalerConfig, write in LoadOptiScalerConfig

- **Choice**: In `SaveOptiScalerConfig` (`optiscaler_tab.pas`), read `FOptVersionComboBox.ItemIndex` into `Settings.OptVersionItemIndex`. In `LoadOptiScalerConfig`, write it back.
- **Rationale**: SaveOptiScalerConfig already collects all tab state. Adding one line is minimal and consistent.

### 3. Use saved value as primary source in InitializeTab

- **Choice**: In `InitializeTab` (`optiscaler_update.pas`), check if the loaded Settings has a valid `OptVersionItemIndex` (>=0). If yes, use it directly. If not, fall back to the existing version-tag heuristic.
- **Rationale**: Saved user preference takes priority over heuristic. The fallback handles first-run where no config exists yet.

## Risks / Trade-offs

- **[Risk]** If settings file already exists but without `OptVersionItemIndex`, the `FillChar(..., 0)` in `LoadOptiScalerConfig` sets it to 0, which matches Stable. Before any explicit user selection, this is the correct default.
  - **Mitigation**: No action needed — this is the desired behavior.
