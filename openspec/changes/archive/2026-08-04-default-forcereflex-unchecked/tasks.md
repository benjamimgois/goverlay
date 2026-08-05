## 1. MESA Default Reflex State Adjustment

- [x] 1.1 Update `sidebar_nav.pas` (`ApplyToolEnabledState`) for MESA driver to remove `FForm.forcereflexCheckBox.Checked := True` and set `FForm.reflexComboBox.Enabled := FForm.forcereflexCheckBox.Checked`.
- [x] 1.2 Update `overlayunit.pas` (`mesaRadioButtonChange`) to set `forcereflexCheckBox.Checked := False` by default when MESA driver is selected.

## 2. Verification & Testing

- [x] 2.1 Update GUI test cases in `tests/gui/gui_test_cases.pas` to assert that `forcereflexCheckBox.Checked` is `False` by default when MESA is selected, and verify persistence when explicitly checked and saved.
- [x] 2.2 Run full test suite (`lazbuild -B goverlay.lpi --bm=Release && make test`) and verify all tests pass.
