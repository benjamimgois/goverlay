## 1. MangoHud Preset Cards Reset and Refresh

- [x] 1.1 Reset `FActiveLayoutCard := -1` and `FActiveColorCard := -1` in `ResetMangoHudControls` in `mangohud_ui.pas`.
- [x] 1.2 Call `UpdatePresetCardVisuals;` at the end of `LoadMangoHudConfig` in `mangohud_ui.pas`.

## 2. Testing and Verification

- [x] 2.1 Add GUI tests in `tests/gui/gui_test_cases.pas` to verify preset card highlights reset upon profile context switch.
- [x] 2.2 Run `make test` to confirm all tests pass cleanly.
