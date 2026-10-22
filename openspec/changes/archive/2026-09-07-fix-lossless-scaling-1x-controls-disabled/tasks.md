## 1. GUI Controls Enablement Logic

- [x] 1.1 Update `FgActive` calculation in `TLosslessScalingTabHelper.UpdateControlsEnabled` in `lossless_scaling_tab.pas` to `(FInterpolationMethod in [imLsfg, imMako])` so that controls remain enabled regardless of multiplier position.
- [x] 1.2 Verify that `FLsMultiplierTrackBar`, `FLsFlowScaleTrackBar`, compact toggles, and dropdowns remain enabled when `FLsMultiplierTrackBar.Position = 1` under `imLsfg` and `imMako`.
- [x] 1.3 Verify that controls properly disable when `imNone` is selected or when the Upscalers tool is toggled off in the sidebar.

## 2. Test Updates and Verification

- [x] 2.1 Update `TestLosslessScalingCompactToggles` in `tests/gui/gui_test_cases.pas` to assert that toggles remain enabled at multiplier 1x under `imLsfg` and disable under `imNone`.
- [x] 2.2 Run the full GUI test suite (`./build_gui_tests.sh && ./run_gui_tests.sh`) and verify all tests pass.
