# Tasks: Symmetric 3x3 Visual Independent Cards Layout

## 1. Structure and Container Integration

- [x] 1.1 In `InitVisualTab` and `ReflowVisualTab` (`mangohud_ui.pas`), reorder the right column cards according to Option A: Row 1 = `FVisFlowSec` (95px), Row 2 = `FVisSystemSec` (165px), Row 3 = `FVisScreenSec` (flex, ~240px+)
- [x] 1.2 Update monitor vector canvas height and anchor positioning in `FVisScreenSec` to utilize the expanded height (~155px) with comfortable breathing room and clear stand rendering
- [x] 1.3 Position Offset X and Offset Y neatly below the monitor stand in `FVisScreenSec`
- [x] 1.4 Update `UpdateVisualCardTheme` and verify all 6 cards are properly refreshed
- [x] 1.5 Polish UI details: rename "Corner borders:" to "Corners:", remove overlapping label in `FVisFlowSec`, and update QComboBox stylesheet padding to 10px
- [x] 1.6 Remove redundant hint labels `FVisTitleHintLbl` and `FVisCanvasHintLbl`, and enrich `FVisCanvasSec` with `Corner radius` trackbar and `No outer margins` (`hud_no_margin`) toggle switch in backend and UI

## 2. Verification & Automated Tests

- [x] 2.1 Update GUI test suite in `tests/gui/gui_test_cases.pas` (`TestMangoHudVisualCompactToggles`) to verify new controls and labels
- [x] 2.2 Compile project with `lazbuild -B goverlay.lpi` and verify clean build
- [x] 2.3 Run logic test suite with `make test-logic` and verify all tests pass
- [x] 2.4 Run GUI tests with `./tests/gui/gui_tests --test=TGoverlayGuiTests.TestMangoHudVisualCompactToggles` and verify all visual tests pass
