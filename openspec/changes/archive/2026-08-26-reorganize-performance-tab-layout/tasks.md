## 1. Performance Tab 4-Card Infrastructure

- [x] 1.1 In `mangohud_ui.pas`, update `BuildPerformanceTab` to create 4 dedicated card panels (`FPerfCards[0..3]`) and section title labels for `Information`, `Limiters`, `VSYNC`, and `Filters`. Verify compilation with `lazbuild --ws=qt6 goverlay.lpi`.
- [x] 1.2 In `mangohud_ui.pas`, update `UpdatePerfCardTheme` to apply theme colors and background styling to all 4 cards (`FPerfCards[0..3]`). Verify compilation with `lazbuild --ws=qt6 goverlay.lpi`.

## 2. Dynamic 2-Column Reflow Layout

- [x] 2.1 In `mangohud_ui.pas`, update `ReflowPerformanceTab` to compute 2-column geometry (Left column: Information ~200px + Limiters expanding; Right column: VSYNC ~130px + Filters expanding). Verify layout alignment.
- [x] 2.2 In `mangohud_ui.pas`, adjust internal control positions for Information (3 columns), VSYNC (2 compact rows), Limiters (proportional vertical centering), and Filters (generous slider spacing). Verify with `lazbuild --ws=qt6 goverlay.lpi`.

## 3. Verification & Automated Tests

- [x] 3.1 In `tests/gui/gui_test_cases.pas`, update `TestPerformanceFiltersLayoutOnResize` and add assertions for 4-card 2-column geometry at normal (960x650) and maximized (1920x1080) window sizes. Verify test execution with `lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests --all`.
