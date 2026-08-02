# Tasks: Dynamic Frame Generation Options

- [x] 1. Add `UpdateFrameGenOptionsUI` method in `optiscaler_tab.pas` to dynamically populate combobox items and hints based on `UpscalerTypeItemIndex` (OptiScaler vs DLSS-Enabler).
- [x] 2. Update radio button click handlers (`optiscalerRadioButtonClick` and `dlssenablerRadioButtonClick`) in `overlayunit.pas` to invoke `UpdateFrameGenOptionsUI`.
- [x] 3. Update `SaveOptiScalerConfigCore` and `LoadOptiScalerConfig` in `overlay_config.pas` to correctly serialize and deserialize mode-specific FGInput and FGOutput values.
- [x] 4. Verify UI state switching and configuration persistence for both OptiScaler and DLSS-Enabler modes.
