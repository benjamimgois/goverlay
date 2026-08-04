## Why

On the OptiScaler (Upscalers) and EnvVars (Tweaks) tabs, the preview button (`FPreviewBtn`) and popup menu button (`popupBitBtn`) are hidden (`Visible := False`). Because LCL's layout engine skips invisible anchor controls, `commandPanel` (the Steam launch command edit box at the bottom bar) stretches across the entire right side of `goverlaybarPanel` with a 6px margin instead of maintaining the consistent right boundary (153px margin) present on all other tabs (MangoHud, vkBasalt, vkSumi, Games).

Standardizing `commandPanel` width ensures visual consistency and clean alignment across all navigation tabs regardless of bottom-bar button visibility.

## What Changes

- **Command Panel Anchor Helper**: Add `UpdateCommandPanelRightAnchor(AButtonsVisible: Boolean)` to `Tgoverlayform` in `overlayunit.pas`.
- **Adaptive Right Spacing**: When `AButtonsVisible` is `True`, anchor `commandPanel` right to `FPreviewBtn` with `BorderSpacing.Right := 6`. When `AButtonsVisible` is `False`, anchor `commandPanel` right to `goverlaybarPanel` with `BorderSpacing.Right := 153`.
- **Tab Navigation Integration**: Invoke `UpdateCommandPanelRightAnchor` in `optiscalerLabelClick`, `tweaksLabelClick`, `mangohudLabelClick`, `vkbasaltLabelClick`, and `GameCardClick`.

## Capabilities

### New Capabilities
- `standardized-command-panel-width`: Standardizes `commandPanel` horizontal width and right margin across all navigation tabs.

### Modified Capabilities

## Impact

- `overlayunit.pas`: Implements `UpdateCommandPanelRightAnchor` helper and updates tab navigation handlers.
- `tests/gui/gui_test_cases.pas`: Adds GUI tests asserting `commandPanel.BorderSpacing.Right` and alignment behavior across tab switches.
