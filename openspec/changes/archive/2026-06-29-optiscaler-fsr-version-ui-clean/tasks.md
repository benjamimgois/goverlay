## 1. UI Modification

- [x] 1.1 In `overlayunit.lfm` and `overlayunit.pas`, update `fsrversionComboBox` items to replace "Latest (FP8)" with "Latest".
- [x] 1.2 In `overlayunit.lfm` and `overlayunit.pas`, hide `emufp8CheckBox` by setting `Visible := False`.

## 2. Config Parser Updates

- [x] 2.1 In `overlay_config.pas` and `optiscaler_update.pas`, update FSR version string matching and writing to handle "Latest" while retaining backwards compatibility for "Latest (FP8)".

## 3. Verification

- [x] 3.1 Verify OptiScaler tab displays "Latest" in FSR version combobox and `emufp8CheckBox` is hidden.
- [x] 3.2 Verify project builds cleanly with `lazbuild goverlay.lpi`.
