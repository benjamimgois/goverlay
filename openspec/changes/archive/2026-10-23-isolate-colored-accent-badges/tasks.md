# Tasks

## 1. Implement Badge Separation

- [x] 1.1 In `mangohud_ui.pas` (`TMangoHudUiHelper`), declare 8 badge labels (`FGpuCoreBadge`, `FGpuThermalBadge`, `FGpuPowerBadge`, `FGpuInfoBadge`, `FCpuCoreBadge`, `FCpuThermalBadge`, `FCpuMemBadge`, `FCpuStorageBadge`).
- [x] 1.2 In `mangohud_ui.pas` (`InitMetricsTab`), instantiate and parent each badge label to its corresponding sub-card panel, and strip the `'▌ '` prefix from the 8 title labels.
- [x] 1.3 In `mangohud_ui.pas` (`ReflowMetricsTab`), position each badge at `Left = 12` and offset each title label to `Left = 25`.
- [x] 1.4 In `mangohud_ui.pas` (`UpdateMetricsCardTheme`), apply subsystem accent colors to the badges, and restore `clWhite` / `LightTextColor` to the title labels.

## 2. Verification

- [x] 2.1 Compile project with `lazbuild goverlay.lpi`.
- [x] 2.2 Run GUI tests (`./tests/gui/gui_tests --all`) and verify all 148 tests pass.
