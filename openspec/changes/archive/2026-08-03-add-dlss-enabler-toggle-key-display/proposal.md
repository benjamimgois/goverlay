## Why

The shortcut key label in the Main section of the Upscalers tab is currently titled "Toggle key", which is ambiguous when DLSS Enabler is active alongside OptiScaler. Furthermore, DLSS Enabler uses a fixed toggle key (` ` ` / grave accent), but GOverlay does not display this shortcut key to the user.

## What Changes

- **Rename Label**: Update `shortcutkeyLabel` caption from `'Toggle key'` to `'Optiscaler toggle'`.
- **Add DLSS Enabler Toggle Display**: Add a "DLSS-Enabler toggle" label (`dlssenablerToggleLabel`) and a disabled shortcut button (`dlssenablerToggleBtn`, `Enabled := False`) pre-mapped with `⌨ ` `.
- **Conditional Visibility**: Show the DLSS-Enabler toggle label and button only when DLSS Enabler is selected (`dlssenablerRadioButton.Checked = True`). Hide them when standard OptiScaler is selected.
- **Layout Adjustments**: Increase the minimum height of the options sub-cards (`MinOptH`) to ensure the Main sub-card accommodates the additional controls without clipping.

## Capabilities

### New Capabilities

### Modified Capabilities
- `optiscaler-options-layout`: Renames shortcut key label to "Optiscaler toggle" and conditionally displays the fixed "DLSS-Enabler toggle" key button.

## Impact

- `optiscaler_tab.pas`: Updates label captions, creates `dlssenablerToggleLabel` & `dlssenablerToggleBtn`, adjusts layout math in `ReflowOptiScalerTab`, and manages visibility in `UpdateFrameGenOptionsUI`.
- `overlayunit.pas`: Declares `dlssenablerToggleLabel` and `dlssenablerToggleBtn` on `Tgoverlayform`.
- `tests/gui/gui_test_cases.pas`: Adds GUI unit test `TestOptiscalerAndDlssEnablerToggleKeyDisplay` verifying label captions, disabled button state, and conditional visibility.
