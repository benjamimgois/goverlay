## 1. UI Control Definitions and DLL Status Feedback
- [x] 1.1 In `lossless_scaling_tab.pas`, add `FLsDllStatusLabel` to `FLsGeneralCard` and update `UpdateDllStatus` to set green `"● DLL file located"` or red `"● Install Lossless scaling on steam or point the correct file path"` along with red edit background.
- [x] 1.2 In `lossless_scaling_tab.pas`, replace `FLsMultiplierComboBox` with `FLsMultiplierTrackBar` (range 1-10) and `FLsMultiplierValueLabel`.

## 2. Card Consolidation and Layout Reflow
- [x] 2.1 In `lossless_scaling_tab.pas`, re-parent `FLsNoFp16CheckBox`, `FLsPacingComboBox`, and `FLsGpuComboBox` into `FLsFrameGenCard` (Configuration) and remove `FLsHardwareCard`.
- [x] 2.2 In `lossless_scaling_tab.pas`, update `ReflowLosslessScalingTab` to layout Option 2 (Row 1: Sliders; Row 2: 3 inline checkboxes; Row 3: 2 dropdowns).

## 3. Configuration Loading, Saving, and Enabled State
- [x] 3.1 In `lossless_scaling_tab.pas`, update `UpdateControlsEnabled`, `LoadLosslessConfig`, `SaveLosslessConfig`, and `WriteLsfgTomlConfig` to use `FLsMultiplierTrackBar.Position`.

## 4. Testing and Verification
- [x] 4.1 Update GUI test cases in `tests/gui/gui_test_cases.pas` to use `MultiplierTrackBar` and assert status label / card consolidation.
- [x] 4.2 Run test suites (`make test-logic`, `make test-gui`) and compile release binary.
