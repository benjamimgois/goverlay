# Tasks: Eliminate Action Bar and Integrate Controls into Visual Cards

## 1. Structure and Container Integration

- [x] 1.1 Declare `FVisSystemSec: TPanel` in `TMangoHudUiHelper` (`mangohud_ui.pas`)
- [x] 1.2 Update `InitVisualTab` to eliminate `FVisActionBar`, reparent `FhudcompactToggle` and `FVisCompactLbl` to `FVisCanvasSec`, and initialize `FVisSystemSec` inside `FVisLayoutCard` hosting `pcidevComboBox`, `FVisualCaptureBtn`, and `FhidehudToggle`
- [x] 1.3 Update `ReflowVisualTab` to expand `FVisAppearanceCard` and `FVisLayoutCard` to the full available height without calculating an action bar, and position the sub-cards cleanly
- [x] 1.4 Update `UpdateVisualCardTheme` to style `FVisSystemSec` and synchronize button palettes without referencing `FVisActionBar`

## 2. Verification & Automated Tests

- [x] 2.1 Update GUI test suite in `tests/gui/gui_test_cases.pas` (`TestMangoHudVisualCompactToggles`) to verify new control hierarchy and positive coordinates
- [x] 2.2 Compile project with `lazbuild -B goverlay.lpi` and verify clean build
- [x] 2.3 Run logic test suite with `make test-logic` and verify all tests pass
- [x] 2.4 Run GUI tests with `./tests/gui/gui_tests --test=TGoverlayGuiTests.TestMangoHudVisualCompactToggles` and verify all visual tests pass
