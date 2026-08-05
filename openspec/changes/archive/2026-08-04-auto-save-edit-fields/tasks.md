## 1. Auto-Save Wiring for TCustomEdit Controls

- [x] 1.1 Update `WireAutoSaveEvents` in `overlayunit.pas` to check `(Ctrl is TCustomEdit) and (Ctrl.Tag <> 9999)` and wire unassigned `OnChange` to `@GenericControlChange`.

## 2. Verification & Testing

- [x] 2.1 Add automated test case in `tests/gui/gui_test_cases.pas` to verify text edit change triggers auto-save.
- [x] 2.2 Run full test suite (`lazbuild -B goverlay.lpi --bm=Release && make test`) and verify all tests pass.
