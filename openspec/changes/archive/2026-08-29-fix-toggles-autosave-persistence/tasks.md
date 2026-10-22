## 1. Auto-Save Wiring and Event Handling

- [x] 1.1 Add `TToggleSwitch` handling to `WireAutoSaveEvents` in `overlayunit.pas`, wiring `OnChange` to `@GenericControlChange`.
- [x] 1.2 Wire `TCheckBox.OnChange` to `@GenericControlChange` in `WireAutoSaveEvents` for programmatic check state updates.
- [x] 1.3 Guard `forceFsr4Int8CheckBox` creation in `optiscaler_tab.pas` with `if forceFsr4Int8CheckBox = nil then` to prevent duplicate controls.

## 2. Verification and Testing

- [x] 2.1 Add automated test in `tests/gui/gui_test_cases.pas` verifying that clicking `TToggleSwitch` triggers the auto-save timer.
- [x] 2.2 Run `make test-logic` and verify all 14 logic tests pass.
- [x] 2.3 Run `make test-gui` and verify all GUI tests pass.
- [x] 2.4 Build `make goverlay` release binary to verify clean compilation.
