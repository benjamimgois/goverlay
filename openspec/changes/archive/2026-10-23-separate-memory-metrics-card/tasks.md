# Tasks

## 1. Declarations & Card Construction
- [x] 1.1 Declare `FMtMemCard: TPanel` in `overlayunit.pas` (`TGoverlayform` public section).
- [x] 1.2 Declare `FMemTitleLbl: TLabel` in `mangohud_ui.pas` (`TMangoHudUiHelper` private section).
- [x] 1.3 In `InitMetricsTab`, update CPU card creation caption to `'CPU Metrics'`, create `FMtMemCard` with caption `'Memory metrics'`, and parent `FCpuMemSec` and `FCpuStorageSec` to `FMtMemCard`.

## 2. Reflow & Theme Styling
- [x] 2.1 In `ReflowMetricsTab`, calculate `ActiveCpuH` (1 row) and `ActiveMemH` (1 row), set bounds for `FMtGpuCard`, `FMtCpuCard`, and `FMtMemCard`, and update `TotalH` / scroll range.
- [x] 2.2 In `UpdateMetricsCardTheme`, call `UpdateGenericCardTheme(FMtMemCard)`.
- [x] 2.3 Compact vertical spacing across all 3 cards and disable vertical scrollbar on `FMtScrollBox` (`AutoScroll := False`, `VertScrollBar.Visible := False`, `Range := 0`).

## 3. Verification
- [x] 3.1 Compile project with `lazbuild goverlay.lpi`.
- [x] 3.2 Run test suite (`lazbuild --ws=qt6 tests/gui/gui_tests.lpi && ./tests/gui/gui_tests --all`) and verify all 148 tests pass.
