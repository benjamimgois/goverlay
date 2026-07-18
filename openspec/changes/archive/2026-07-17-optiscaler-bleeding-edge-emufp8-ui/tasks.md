## 1. UI Adjustments for emufp8CheckBox and forceFsr4Int8CheckBox

- [x] 1.1 In `optiscaler_tab.pas`, adjust `forceFsr4Int8CheckBox.Top` from `142` to `165` to prevent overlap with `emufp8CheckBox`.
- [x] 1.2 In `overlayunit.pas` `fsrversionComboBoxChange`, update logic to keep `emufp8CheckBox` visible and active under the bleeding-edge channel and dynamically update its hint.

## 2. Verification and Build

- [x] 2.1 Build GOverlay using `lazbuild` to verify there are no compilation errors.
- [x] 2.2 Verify that the OptiScaler options layout shows both checkboxes correctly without overlap, and the hints are updated dynamically on channel switch.
