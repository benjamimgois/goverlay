## 1. UI Relocation

- [x] 1.1 In `overlayunit.lfm` / `overlayunit.pas`, move "Wine prefix" button and setup dialog handler to Settings modal, below "Status" config area. Add a divider line.
- [x] 1.2 In `overlayunit.lfm` / `overlayunit.pas`, remove the old Wine prefix button from the OptiScaler tab.

## 2. Preferred Upscaler Combobox Implementation

- [x] 2.1 In `optiscaler_update.pas` (or `overlayunit.pas`), add a `TComboBox` for Preferred Upscaler with items: `auto`, `xess`, `fsr21`, `fsr22`, `fsr4`, `dlss`.
- [x] 2.2 Implement the change callback to read selected value and map `"fsr4"` to `"fsr31"`.
- [x] 2.3 Write values to `OptiScaler.ini` (`Dx11Upscaler=`, `Dx12Upscaler=`, `VulkanUpscaler=`).

## 3. Verification & Testing

- [x] 3.1 Verify that the Pascal project builds successfully without syntax or type errors
- [ ] 3.2 Verify the UI changes in the settings modal and OptiScaler tab
- [x] 3.3 Verify writing preferred upscaler values to a mock `OptiScaler.ini` configuration file
