# Proposal: OptiScaler Menu Scale Auto Option and Default

## Why

In the "Upscalers" tab, the `Menu scale` combobox (`menuscaleComboBox`) currently only lists numeric scaling factors from `1.0` to `2.0`. However, OptiScaler natively supports `Scale = auto` in the `[Menu]` section of `OptiScaler.ini` to automatically scale the in-game overlay menu according to display resolution and DPI. Adding `auto` as the primary and default option in `menuscaleComboBox` ensures users get optimal automatic menu scaling out-of-the-box while preserving the ability to manually pick a fixed scale (`1.0` - `2.0`).

## What Changes

- Add `'auto'` as the first item (Index 0) in `menuscaleComboBox` in `optiscaler_tab.pas`.
- Set `'auto'` (Index 0) as the default selection for `menuscaleComboBox` on initialization and when loading defaults.
- Update `SaveOptiScalerConfig` in `optiscaler_tab.pas` and `SaveOptiScalerConfigCore` in `overlay_config.pas`:
  - When `auto` (Index 0 or MenuScalePosition <= 0) is selected, persist `Scale=auto` to `[Menu]` in `OptiScaler.ini`.
  - When numeric options (`1.0` - `2.0`) are selected, persist formatted float (`Scale=1.0` .. `Scale=2.0`).
- Update `LoadOptiScalerConfig` in `optiscaler_tab.pas` and `LoadOptiScalerConfigCore` in `overlay_config.pas`:
  - Parse `Scale=auto` (or empty/missing) as `auto` (Index 0).
  - Parse numeric floats (`1.0` - `2.0`) to select the corresponding combobox item.
- Update automated GUI test fixtures and persistence assertions in `tests/gui/gui_test_cases.pas`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `optiscaler-persistence`: Add requirement and test scenarios for `Scale=auto` menu scale default persistence and loading in `OptiScaler.ini`.

## Impact

- `optiscaler_tab.pas`: Updated `menuscaleComboBox` items, index calculation, and default selection.
- `overlay_config.pas`: Updated `TOptiScalerSettings` defaults, `Scale=` value formatting, and parser logic for `Scale=auto`.
- `tests/gui/gui_test_cases.pas`: Updated `TestOptiMenuScaleSave` and test fixtures.
