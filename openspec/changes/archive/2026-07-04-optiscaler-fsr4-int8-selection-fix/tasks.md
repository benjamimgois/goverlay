## 1. Persist FSR version to variables file

- [x] 1.1 In `overlay_config.pas` `SaveOptiScalerConfigCore`, implement updating/saving the `fsrversion` key inside the game config directory's `goverlay.vars`.
- [x] 1.2 Resolve and load the actual latest FSR version from the update channel cache's `goverlay.vars` when index 0 (Latest) is selected.
- [x] 1.3 Write `'4.0.2c INT8'` to the variables file when index 1 (INT8) is selected.


## 2. Flexible string format loading & UI refresh

- [x] 2.1 In `overlay_config.pas` `LoadOptiScalerConfig`, restore `Settings.FsrversionItemIndex := 1` when loaded FSR version is either `'4.0.2c (INT8)'` or `'4.0.2c INT8'`.
- [x] 2.2 In `optiscaler_update.pas` `LoadVersionsFromFile`, set `ItemIndex := 1` in `FFsrVersionComboBox` when `FsrVer` is either `'4.0.2c (INT8)'` or `'4.0.2c INT8'`.
- [x] 2.3 In `optiscaler_tab.pas` `TOptiScalerTabHelper.SaveOptiScalerConfig`, call `FOptiscalerUpdate.LoadVersionsFromFile` and `RefreshOsStatusDots` to reload status and refresh dots immediately after save.


## 3. OptiScaler toggle activation copy fix

- [x] 3.1 In `sidebar_nav.pas` `CopyOptiScalerGameFiles`, load the saved configuration for the game after the basic `cp -rn` copy.
- [x] 3.2 Overwrite `amd_fidelityfx_upscaler_dx12.dll` inside the game's configuration folder with the DLL from the cache folder's `FSR4_INT8` subfolder if the saved FSR version index is 1 (INT8).


## 4. Verification and compilation

- [x] 4.1 Compile the project with `lazbuild goverlay.lpi` to verify there are no compilation errors.
- [ ] 4.2 Run GOverlay, configure a game card with FSR INT8, verify that it saves correctly, displays in Software Status card, and copies the INT8 DLL on toggle.

