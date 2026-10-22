## 1. Mascot Asset Preparation

- [x] 1.1 Process and save the MAKO cyber shark image to `assets/icons/mako_renderer.png` and verify file dimensions and presence

## 2. Helper Logic

- [x] 2.1 Implement `GetMakoLibraryPath` in `optiscaler_update.pas` (or `lossless_scaling_tab.pas`) to detect `libmako-render.so` path and verify detection

## 3. UI Component Creation & Layout Refactoring

- [x] 3.1 Rename card title to "Software Status" in `lossless_scaling_tab.pas`
- [x] 3.2 Create `FLsMakoLogoImage` (TImage) and `FLsMakoPathEdit` (TEdit) in `InitLosslessScalingTab` and apply styling
- [x] 3.3 Refactor `ReflowLosslessScalingTab` to anchor "Software Status" at the base of the tab with vertically stacked Lossless Scaling, MAKO, and Target GPU rows
- [x] 3.4 Update `UpdateEngineStatus` and `TMakoCheckUpdateThread` to set `.so` path, status caption, and conditional visibility for `FLsInstallBtn`

## 4. Verification

- [x] 4.1 Compile Goverlay and run automated logic tests (`make test`) to ensure build and test clean pass
