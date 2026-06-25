## Why

The OptiScaler version channel combobox ("Stable Channel" / "Bleeding-edge") does not persist user selection across application restarts. The `optversionComboBox.ItemIndex` is never saved to any config file. On startup, `InitializeTab` derives the combobox value from the installed version tag in `goverlay.vars` — which resets to "Stable" whenever the installed package lacks an `edge-` prefix, or when the vars file is missing or unreachable. This affects both global and per-game configurations.

## What Changes

- **Save** `optversionComboBox.ItemIndex` (0=Stable, 1=Bleeding) into the per-game OptiScaler config (`bgmod.conf`) when the user changes the selection.
- **Restore** the combobox from this saved value on startup and on game switch, before falling back to the installed-version-tag heuristic.
- **Preserve** the existing version-tag heuristic as a fallback for the initial install scenario (no saved config yet).

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `bgmod-update-optiscaler`: Add requirement that the OptiScaler channel selection persisted in per-game config and restored on startup.

## Impact

- `optiscaler_tab.pas`: `SaveOptiScalerConfig` (save `optversionComboBox.ItemIndex` to config), `LoadOptiScalerConfig` (restore it)
- `optiscaler_update.pas`: `InitializeTab` (read saved channel before falling back to version-tag heuristic)
- `overlay_config.pas`: `TOptiScalerSettings` record (add `OptVersionItemIndex` field)
