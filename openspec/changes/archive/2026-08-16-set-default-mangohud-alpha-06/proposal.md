## Why

When creating a new profile (global or per-game) or resetting the MangoHud configuration, the background opacity slider ("Alpha") on the "Visual" tab currently defaults to `1.0` in `ResetMangoHudControls`. To improve out-of-the-box overlay readability while gaming, the default alpha should be `0.6` (matching the default stock config in `CreateDefaultGlobalMangoHudConfig` and `overlayunit.lfm`).

## What Changes

- Change default `transpTrackBar.Position` from `10` to `6` in `TMangoHudUiHelper.ResetMangoHudControls` (`mangohud_ui.pas`).
- Change default `alphavalueLabel.Caption` from `'1.0'` to `'0.6'` in `TMangoHudUiHelper.ResetMangoHudControls` (`mangohud_ui.pas`).

## Capabilities

### New Capabilities

### Modified Capabilities
- `mangohud-ui-reset-on-load`: Define the default background transparency trackbar value as `6` (`0.6`) during MangoHud control reset.

## Impact

- `mangohud_ui.pas`: `ResetMangoHudControls` sets `transpTrackBar.Position := 6` and `alphavalueLabel.Caption := '0.6'`.
- `tests/gui/gui_test_cases.pas`: GUI tests verifying reset state of MangoHud visual controls.
