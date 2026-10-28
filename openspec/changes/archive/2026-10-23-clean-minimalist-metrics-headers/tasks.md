# Tasks

## 1. Clean Minimalist Typography Implementation

- [x] 1.1 In `mangohud_ui.pas`, remove the 8 badge label declarations (`FGpuCoreBadge`, etc.) and the `MakeBadge` helper.
- [x] 1.2 In `mangohud_ui.pas` (`InitMetricsTab`), ensure clean captions without prefixes for all 8 section labels.
- [x] 1.3 In `mangohud_ui.pas` (`ReflowMetricsTab`), restore section label positioning to `Left = 12`, `Top = 8`, `Width = SecW - 24`.
- [x] 1.4 In `mangohud_ui.pas` (`UpdateMetricsCardTheme`), apply theme title color (`clWhite` in dark theme, `LightTextColor` in light theme) directly to all 8 section labels.

## 2. Verification

- [x] 2.1 Compile project with `lazbuild goverlay.lpi` and verify zero errors.
- [x] 2.2 Run GUI tests (`./tests/gui/gui_tests --all`) and verify all 148 tests pass.
