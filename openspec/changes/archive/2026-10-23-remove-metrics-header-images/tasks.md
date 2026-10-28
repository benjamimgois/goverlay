# Tasks

## 1. Clean Header Images & Fix Storage Label

- [x] 1.1 In `mangohud_ui.pas` (`InitMetricsTab`), hide `gpuImage` and `cpuImage` and set `FStorageLabel.ShowAccelChar := False`.
- [x] 1.2 In `mangohud_ui.pas` (`ReflowMetricsTab`), remove `gpuImage` and `cpuImage` repositioning and ensure `Visible := False`.

## 2. Verification

- [x] 2.1 Compile project with `lazbuild goverlay.lpi`.
- [x] 2.2 Run GUI tests (`./tests/gui/gui_tests --all`) and verify all 148 tests pass.
