## 1. Core Decoupling

- [x] 1.1 Remove the forced FPS limit parsing and spin edit assignment block from `SaveMangoHudConfig` in `mangohud_ui.pas`, ensuring `fpscolor2SpinEdit.Value` and `fpscolor3SpinEdit.Value` are preserved and saved directly into `Settings.FpsColorValues`
- [x] 1.2 Clean up the legacy startup calculation in `overlayunit.pas` (`FormCreate`) that derived `MaxFPS / 2` and `MaxFPS` for the spin edits

## 2. Automated Tests & Validation

- [x] 2.1 Update GUI test cases in `tests/gui/gui_test_cases.pas` to set custom `fpscolor2SpinEdit` and `fpscolor3SpinEdit` values alongside an FPS limit, and verify that `fps_value` in the generated config matches the custom spin edit values
- [x] 2.2 Run GUI and unit tests to ensure that all test assertions pass and no regressions occur
