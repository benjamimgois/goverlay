# Proposal

## Why

In the OptiScaler tab, the Options card had a minimum height clamp of `410px` (`MinOptH := 410`). This constant was originally increased when an extra log level combobox was added to the Main options column. When the log level combobox was subsequently hidden and the controls were shifted back up, `MinOptH` was not restored.

Consequently, on standard window dimensions (viewport height ~648px), the layout calculation forced the total content height to `702px`. This pushed the bottom Software Status card partially off-screen and triggered an unnecessary vertical scrollbar on the tab's scroll box.

## What Changes

- Reduce `MinOptH` in `optiscaler_tab.pas` from `410px` to `290px`, allowing the Options card to dynamically size to ~356px (or ~330px in custom channel mode) at standard window height.
- Improve `TotalH` fallback handling in `ReflowOptiScalerTabNew` to inspect `optiscalerTabSheet.ClientHeight` or form client height instead of a fixed 600px fallback.
- Tighten the DLSS-Enabler toggle button vertical offset slightly (`Y0 + 200` label, `Y0 + 218` button) so it fits with 282px maximum bottom bound.
- Add GUI regression test `TestOptiScalerOptionsCardHeightAndNoScroll` in `tests/gui/gui_test_cases.pas` to ensure the Options card height is reduced and the Software Status card fits completely without scrolling.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `optiscaler-options-layout`: Ensure the OptiScaler tab layout fits standard window heights without requiring vertical scrolling.

## Impact

- **Affected Files**:
  - `optiscaler_tab.pas`: `MinOptH` constant, fallback client height, DLSS-Enabler toggle Y offset.
  - `tests/gui/gui_test_cases.pas`: GUI assertion verifying no vertical scroll and reduced Options card height.
- **Compatibility**: No regressions or breaking changes; all controls remain fully accessible and visible.
