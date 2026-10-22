# Tasks

## 1. Sub-Card Scaffolding & Component Reparenting

- [x] 1.1 Create the 4 GPU sub-panels (`FGpuCoreSec`, `FGpuThermalSec`, `FGpuPowerSec`, `FGpuInfoSec`) and 3 CPU sub-panels (`FCpuCoreSec`, `FCpuThermalSec`, `FCpuMemSec`) in `InitMetricsTab` within `mangohud_ui.pas`.
- [x] 1.2 Reparent all metric controls, toggles, color buttons, and action buttons into their respective sub-panel containers.

## 2. Inline Control Alignment & Reflow

- [x] 2.1 Refactor `ReflowMetricsTab` in `mangohud_ui.pas` to position the sub-panels into responsive multi-column layouts across `FMtGpuCard` and `FMtCpuCard`.
- [x] 2.2 Align secondary controls (gradient buttons, color pickers, and format buttons) inline with their parent toggles on identical vertical baselines.

## 3. Build & Integration Verification

- [x] 3.1 Compile Goverlay with `lazbuild -B goverlay.lpi` and verify successful build with 0 errors.
- [x] 3.2 Inspect the Metrics tab layout across normal and maximized window sizes to verify module framing and inline alignment.
