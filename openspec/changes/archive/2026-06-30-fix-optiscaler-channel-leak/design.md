## Context

The update channel selection for OptiScaler (`optversionComboBox`) was not reset to a default value during `LoadOptiScalerConfig` if the loaded settings returned an invalid or missing update channel index (`-1`).

## Goals / Non-Goals

**Goals:**
- Reset the update channel dropdown state to index `0` (Stable) when the configuration lacks a valid `OPT_CHANNEL` index.
- Correctly synchronize the dropdown state to prevent leaking previous state across games/global selection.

**Non-Goals:**
- Changing configuration file structure or storage schema.

## Decisions

### Fallback selection in TOptiScalerTabHelper.LoadOptiScalerConfig
Modify `TOptiScalerTabHelper.LoadOptiScalerConfig` to assign index `0` (Stable Channel) if the loaded settings' `OptVersionItemIndex` is not in `[0, 1]`.

- **Option A (Recommended):** Add an `else` branch in `optiscaler_tab.pas` where the index is assigned:
  ```pascal
  if Settings.OptVersionItemIndex in [0, 1] then
    optversionComboBox.ItemIndex := Settings.OptVersionItemIndex
  else
    optversionComboBox.ItemIndex := 0;
  ```
  - *Pros:* Extremely simple, safe, and guarantees combobox value is overridden with the default on every configuration load.
  - *Cons:* None.

- **Option B:** Initialize `Settings.OptVersionItemIndex` in `LoadOptiScalerConfig` default values.
  - *Pros:* Centralizes defaults.
  - *Cons:* Bypasses the edge-version fallback detection in `InitializeTab` (since it checks for `-1`).

We choose Option A.

## Risks / Trade-offs

- **Risk:** Breaks manual override values.
- **Mitigation:** Only triggers when `OPT_CHANNEL` is absent or invalid (outside `[0, 1]`).
