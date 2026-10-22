## Why

When users select a MangoHud layout preset (such as Full, Basic, Basic Horizontal, FPS Only, or User Custom), the underlying checkboxes are updated and saved, but the newly introduced `TToggleSwitch` controls on the Metrics, Visual, Performance, and Extras tabs do not update their visual state to match the selected preset. This causes the UI to display outdated toggle states after preset selection.

## What Changes

- Hook `SyncAllToggles` into `PresetCardClick` and individual preset click handlers (`fullBitBtnClick`, `basicBitBtnClick`, `basichorizontalBitBtnClick`, `fpsonlyBitBtnClick`, `usercustomBitBtnClick`).
- Hook `SyncAllToggles` into `SetAllCheckBoxesToTrue` and `SetAllCheckBoxesToFalse`.
- Hook individual tab toggle synchronization (`SyncVisualToggles`, `SyncPerformanceToggles`, `SyncMetricsToggles`, `SyncExtrasToggles`) into sub-tab `OnShow` events.
- Ensure all toggles immediately and accurately reflect preset configuration changes.

## Capabilities

### Modified Capabilities
- `compact-toggles-all-tabs`: Add preset synchronization requirement ensuring that switching presets or navigating between tabs immediately updates all toggle switches to match the underlying active preset configuration.

## Impact

- `mangohud_ui.pas`: `PresetCardClick`, `SaveMangoHudConfig`, subtab show/reflow routines.
- `overlayunit.pas`: `fullBitBtnClick`, `basicBitBtnClick`, `basichorizontalBitBtnClick`, `fpsonlyBitBtnClick`, `SetAllCheckBoxesToTrue`, `SetAllCheckBoxesToFalse`, and tab show procedures.
- `tests/gui/gui_test_cases.pas`: New test cases verifying that clicking presets updates all toggle switches across all tabs.
