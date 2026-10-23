# Tasks

## 1. Sub-Card Rebalancing & Layout Updates

- [x] 1.1 In `mangohud_ui.pas`, declare `FCpuStorageSec: TPanel` and `FStorageLabel: TLabel`, initialize them in `InitMetricsTab`, and configure captions for Memory & Swap and Storage & Disk IO.
- [x] 1.2 In `mangohud_ui.pas` (`InitMetricsTab`), reparent `FprocvramToggle` to `FGpuCoreSec`, `FgputhrottlingToggle` / `FgputhrottlinggraphToggle` to `FGpuThermalSec`, `FramtempToggle` to `FCpuMemSec`, and `FdiskioToggle` / `iordrwColorButton` to `FCpuStorageSec`.
- [x] 1.3 In `mangohud_ui.pas` (`ReflowMetricsTab`), update geometry: set `Sec2H_GPU := 114`, layout GPU controls evenly across 3 rows, and layout CPU controls into symmetrical 2-column cards (`FCpuMemSec` left, `FCpuStorageSec` right).

## 2. Theme & Verification

- [x] 2.1 In `mangohud_ui.pas` (`ApplyMetricsTabTheme`), apply accent styling to `FStorageLabel` matching the CPU/Memory warm palette.
- [x] 2.2 Compile the project with `lazbuild goverlay.lpi` and verify zero errors.
- [x] 2.3 Run the GUI test suite (`./tests/gui/gui_tests --all`) and confirm all tests pass without regressions.
