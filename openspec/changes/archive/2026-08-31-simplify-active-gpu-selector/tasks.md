## 1. Helper Function and Logic

- [x] 1.1 Implement `ExtractGpuMarketName` helper function and add unit tests in `tests/logic/logic_test_cases.pas` covering AMD, NVIDIA, Intel, and Steam Deck GPU strings.
- [x] 1.2 Update GPU detection loop in `overlayunit.pas` to populate `pcidevComboBox` with `GPU <index>: <Market Name>` items.

## 2. UI Layout and Styling

- [x] 2.1 Update `InitializeTab` and `ReflowVisualTab` in `mangohud_ui.pas` to hide `gpudescEdit` and stretch `pcidevComboBox` across the full width of `FVisualGpuBar`.
- [x] 2.2 Update theme styling and event handling in `overlayunit.pas` and `mangohud_ui.pas` to ensure clean combobox selection and persistence.

## 3. Verification and Testing

- [x] 3.1 Run `make test-logic` and `make test-gui` to ensure all unit and GUI tests pass.
- [x] 3.2 Verify bidirectional `gpu_list` serialization (`gpu_list=0`, `gpu_list=1`, `gpu_list=0,1`) with MangoHud configuration files.
