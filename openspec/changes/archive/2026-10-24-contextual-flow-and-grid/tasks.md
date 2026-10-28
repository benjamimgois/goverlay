# Tasks: Contextual Flow & Grid (Adaptive Row - Option 2)

## 1. Contextual Visibility and Layout Adaptation

- [x] 1.1 Declare `procedure SyncFlowGridVisibility;` in `TMangoHudUiHelper` in `mangohud_ui.pas`
- [x] 1.2 Implement `SyncFlowGridVisibility` to toggle visibility between Columns controls (`FVisColumnsSubLbl`, `FColumnsMinusBtn`, `columvalueLabel`, `FColumnsPlusBtn`, `FVisColumnsPaintBox`) and Horizontal Stretch controls (`FVisStretchLbl`, `FhorizontalstrechToggle`) based on orientation
- [x] 1.3 Call `SyncFlowGridVisibility` from `VisOrientPillBtnClick`, `SyncVisualPills`, `LoadMangoHudConfig`, and `ResetMangoHudControls`
- [x] 1.4 Update `ReflowVisualTab` to position whichever controls are active at the consistent secondary row Y-coordinate (~68px) inside `FVisFlowSec`

## 2. Verification & Test Suite

- [x] 2.1 Compile project with `lazbuild -B goverlay.lpi` and verify clean compilation
- [x] 2.2 Run logic test suite with `make test-logic` and verify all tests pass
- [x] 2.3 Run GUI tests with `./tests/gui/gui_tests --test=TGoverlayGuiTests.TestMangoHudVisualCompactToggles` and verify all visual tests pass
