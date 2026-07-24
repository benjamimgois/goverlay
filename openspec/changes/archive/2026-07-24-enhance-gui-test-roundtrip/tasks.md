## 1. MangoHud Round-Trip Test Coverage

- [x] 1.1 In `tests/gui/gui_test_cases.pas`, update `TestMangoVisualTab` to call `LoadMangoHudConfig` and assert UI controls (`hudtitleEdit`, `transpTrackBar`, `roundRadioButton`, `hudbackgroundColorButton`, `fontsizeTrackBar`, `fontColorButton`, `toprightRadioButton`, `offsetxSpinEdit`, `offsetySpinEdit`, `hidehudCheckBox`, `hudcompactCheckBox`, `horizontalstrechCheckBox`).
- [x] 1.2 In `tests/gui/gui_test_cases.pas`, update `TestMangoMetricsGpuTab`, `TestMangoMetricsCpuTab`, `TestMangoMetricsMemIoTab`, and `TestMangoMetricsOtherTab` to add `LoadMangoHudConfig` and UI assertions.
- [x] 1.3 In `tests/gui/gui_test_cases.pas`, update `TestMangoPerformanceTab` and `TestMangoExtrasTab` to add `LoadMangoHudConfig` and UI assertions.

## 2. OptiScaler & Sidebar Navigation Tests

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, update OptiScaler test procedures to call `LoadOptiScalerConfig` and assert UI control states.
- [x] 2.2 In `tests/gui/gui_test_cases.pas`, add `TestTabSwitchingPersistence` simulating navigation between MangoHud and OptiScaler tabs and verifying control states.

## 3. Verification

- [x] 3.1 Run `make test` to verify all updated GUI round-trip tests pass cleanly.
