# Tasks

## 1. Segmented Format Button Styling & Visuals

- [x] 1.1 In `themeunit.pas`, declare and implement `StyleSegmentedFormatBtn(ABtn: TBitBtn)`.
- [x] 1.2 In `overlayunit.pas`, update `coreloadtypeBitBtnClick` and `gpuframesjouleBitBtnClick` to set segmented dual-state captions, hints, and call `StyleSegmentedFormatBtn`.
- [x] 1.3 In `mangohud_ui.pas`, update `ResetMangoHudControls`, `LoadMangoHudBoolFlag`, and `UpdateMetricsCardTheme` to apply segmented captions, hints, and styling.
- [x] 1.4 In `mangohud_ui.pas` (`ReflowMetricsTab`), update bounds for `coreloadtypeBitBtn` (width: 84px) and `gpuframesjouleBitBtn`/`cpuframesjouleBitBtn` (width: 88px).

## 2. Verification

- [x] 2.1 Compile project with `lazbuild goverlay.lpi`.
- [x] 2.2 Run GUI tests (`./tests/gui/gui_tests --all`) and verify all 148 tests pass.
