# Tasks: Redesign MangoHud Extras Tab with Modular Sub-Cards

## 1. Sub-Card Declarations and Container Setup

- [x] 1.1 Declare sub-card panels in `overlayunit.pas` / `mangohud_ui.pas` (`FExtPlatformSec`, `FExtWineSec`, `FExtGamingSec`, `FExtSessionSec`, `FExtLogTimingsSec`, `FExtLogToolsSec`) and verify compilation.
- [x] 1.2 Instantiate sub-cards inside `InitExtrasTab` using `MakeSubSec` with `CARD_BG` styling, and remove legacy header bitmaps (`sysinfoImage`, `Image2`).

## 2. Control Layout and Micro-Interactions

- [x] 2.1 Reparent Platform & Display controls (`distroinfo`, `displayserver`, `arch`, `resolution`, `refreshrate`, `time` + `FTimeConfigBtn`) into `FExtPlatformSec`.
- [x] 2.2 Reparent Wine & Compatibility controls (`wine`, `engineversion`, `engineshort`, `winesync`, `dxapi`, `fexstats`) into `FExtWineSec` with 20x20 round color chips inline beside their toggles.
- [x] 2.3 Reparent Gaming & Integrations controls (`hudversion`, `gamemodestatus`, `vkbasaltstatus`, `fcat`, `fsr`, `hdr`) into `FExtGamingSec`.
- [x] 2.4 Reparent Hardware & Session controls (Battery metrics + color chip, Media + color chip, Network + combo, custom command) into `FExtSessionSec`.
- [x] 2.5 Implement temperature unit segmented dual-pill (`[ °C | °F ]`) linked to `fahrenheitCheckBox`.
- [x] 2.6 Reparent and align Session Timings (trackbars + value chips) into `FExtLogTimingsSec`, and Storage & Tools (folder, capture key, PasPlot) into `FExtLogToolsSec`.

## 3. Responsive 2-Column Grid Reflow

- [x] 3.1 Refactor `ReflowExtrasTab` to calculate symmetrical 2-column widths (`SecW := (CW - 2 * SEC_PAD - SEC_GAP) div 2`) and position sub-cards in 2x2 and 1x2 grids.
- [x] 3.2 Update `UpdateExtrasCardTheme` to apply theme colors and dark styling to all sub-cards and labels.

## 4. Verification and Regression Testing

- [x] 4.1 Run GUI test suite (`./tests/run_tests.sh` or targeted `TestMangoExtrasTab` and `TestMangoHudExtrasCompactToggles`) and verify all tests pass without regressions.

## 5. Option 1 Polish (Mirrored Layout & Battery Clarity)

- [x] 5.1 Implement 3-row mirrored layout in `FExtLogToolsSec`: Row 1 for Output Folder, Row 2 for Logging Hotkey button (full width), Row 3 for PasPlot Benchmark Viewer button (full width), matching `FExtLogTimingsSec` slider rows.
- [x] 5.2 Clarify battery metric labels in `FExtSessionSec` (`Battery %`, `Battery Wattage`, `Battery Time`, `Battery Devices`).
- [x] 5.3 Synchronize `networkComboBox` enabled state and visual dimming with `networkCheckBox.Checked`.
- [x] 5.4 Re-run GUI test suite (`TestMangoExtrasTab`, `TestMangoHudExtrasCompactToggles`, `TestGplotWindowMultiRunComparisonAndPngExport`) and verify 100% green.
