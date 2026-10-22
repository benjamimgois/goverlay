## 1. Graphics Utility

- [x] 1.1 Implement `CreateDimmedPng` in `apputils.pas` to scale RGB channels to 35% while preserving the alpha channel, and verify compilation with `make test-logic`

## 2. OptiScaler Method Logos Dimming

- [x] 2.1 Pre-compute dimmed PNG instances for `None`, `OptiScaler`, and `DLSS Enabler` during OptiScaler tab initialization in `optiscaler_tab.pas` / `overlayunit.pas` and ensure proper destruction in destructor
- [x] 2.2 Update `UpdateUpscalerImageOpacity` in `overlayunit.pas` to assign the original 100% PNG to the checked option and the dimmed PNG to unchecked options, while keeping `TImage.Enabled := True` for click handling

## 3. Lossless Scaling Method Logos Dimming

- [x] 3.1 Pre-compute dimmed PNG instances for `None`, `LSFG-VK`, and `MAKO` during Method card setup in `lossless_scaling_tab.pas` and ensure proper destruction in destructor
- [x] 3.2 Update `UpdateMethodImageOpacity` in `lossless_scaling_tab.pas` to assign the original 100% PNG to the checked option and the dimmed PNG to unchecked options, while keeping `TImage.Enabled := True` for click handling

## 4. Testing and Verification

- [x] 4.1 Add GUI test cases in `tests/gui/gui_test_cases.pas` verifying that clicking each method in OptiScaler and Lossless Scaling properly assigns the expected logo states
- [x] 4.2 Run `make test-logic` and `make test-gui` to verify all tests pass without regressions
