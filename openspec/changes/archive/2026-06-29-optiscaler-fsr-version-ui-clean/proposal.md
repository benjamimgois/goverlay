## Why

In the OptiScaler tab, the FSR version combobox option "Latest (FP8)" contains redundant architectural detail, and the "Emulate FP8" checkbox is no longer needed in the UI. Simplifying the combobox text to "Latest" and hiding the "Emulate FP8" checkbox streamlines the OptiScaler configuration interface and eliminates unnecessary UI clutter.

## What Changes

- Change the first item text in `fsrversionComboBox` from "Latest (FP8)" to "Latest".
- Hide the `emufp8CheckBox` component from the OptiScaler tab interface (`Visible := False`).
- Update config saving and loading logic (`overlay_config.pas` and `optiscaler_update.pas`) to handle both "Latest" and legacy "Latest (FP8)" strings seamlessly.

## Capabilities

### New Capabilities
- `optiscaler-fsr-version-ui-clean`: Updates OptiScaler FSR version option label to "Latest" and hides the Emulate FP8 checkbox.

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.lfm`, `overlayunit.pas`: Updates combobox items text and sets `emufp8CheckBox.Visible := False`.
- `overlay_config.pas`, `optiscaler_update.pas`: Ensures config parser supports "Latest" alongside legacy "Latest (FP8)" values.
