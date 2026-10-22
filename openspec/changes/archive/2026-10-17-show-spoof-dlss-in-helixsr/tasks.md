# Tasks

## 1. UI Layout Reflow for Spoof DLSS in HelixSR Mode

- [x] 1.1 Update `ReflowOptiScalerTabNew` in `optiscaler_tab.pas` to keep `FSpoofToggle` / `spoofCheckBox` visible when `IsHelixSrActive` is true, positioning it cleanly alongside HelixSR controls without height overflow.
- [x] 1.2 Implement state handling so that when Native DLSS is active (`helixsrNativeDlssCheckBox.Checked = True`), the `FSpoofToggle` is disabled or hidden, and re-enabled when Native DLSS is toggled off.

## 2. Test Verification

- [x] 2.1 Add or update GUI test cases in `tests/gui/gui_test_cases.pas` to assert that `FSpoofToggle` / `spoofCheckBox` remains visible and interactive when `helixsrRadioButton.Checked` is true, and properly disabled when `helixsrNativeDlssCheckBox.Checked` is true.
- [x] 2.2 Run GUI test suite (`./build_tests.sh && ./run_gui_tests.sh`) to verify no regressions in OptiScaler and HelixSR layouts.
