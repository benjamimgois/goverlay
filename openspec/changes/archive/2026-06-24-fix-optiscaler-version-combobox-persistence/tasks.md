## 1. Add field to Settings record

- [x] 1.1 In `overlay_config.pas`, add `OptVersionItemIndex: Integer` to `TOptiScalerSettings` record

## 2. Save combobox state

- [x] 2.1 In `optiscaler_tab.pas` `SaveOptiScalerConfig`, read `FOptVersionComboBox.ItemIndex` into `Settings.OptVersionItemIndex`

## 3. Restore combobox state on load

- [x] 3.1 In `optiscaler_tab.pas` `LoadOptiScalerConfig`, write `Settings.OptVersionItemIndex` to `FOptVersionComboBox.ItemIndex`
- [x] 3.2 In `optiscaler_update.pas` `InitializeTab`, use saved `OptVersionItemIndex` as primary source before falling back to version-tag heuristic

## 4. Build and verify

- [x] 4.1 Compile with `make`
- [ ] 4.2 Verify: select Bleeding-edge, restart GOverlay, combobox shows Bleeding-edge
- [ ] 4.3 Verify: Stable selection also persists across restarts
