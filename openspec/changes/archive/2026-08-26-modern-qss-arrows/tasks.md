## 1. QSS Stylesheet Updates

- [x] 1.1 Update `GetComboBoxStyleSheet` in `themeunit.pas` with pure QSS border triangle arrows and hover cyan accents
- [x] 1.2 Update `GetSpinBoxStyleSheet` in `themeunit.pas` with pure QSS stepper buttons, border triangle arrows, and hover cyan accents
- [x] 1.3 Update `overlayunit.pas`, `mangohud_ui.pas`, and `lossless_scaling_tab.pas` to ensure consistent propagation
- [x] 1.4 Remove unused temporary chevron icon files in `assets/icons/`

## 2. Verification

- [x] 2.1 Run full GUI test suite (`lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests --all`) and verify 71/71 tests pass
- [x] 2.2 Rebuild `./goverlay` binary
