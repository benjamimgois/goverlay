# Tasks

## 1. UI Controls & Layout Integration

- [x] 1.1 In `mangohud_ui.pas` (`InitMetricsTab`), configure `FGpuNamePanel` and `FCpuNamePanel` child order with `TColorButton` on the left, `TEdit` with placeholder `'Default (GPU)'` / `'Default (CPU)'` in the middle, and `TLabel` caption `'HUD'` on the right.
- [x] 1.2 In `mangohud_ui.pas` (`ReflowMetricsTab`), update pill dimensions (`PillW := 265`, `PillH := 30`) and layout internal elements (`ColorButton` at left 6, `Edit` at left 34, `HUD Label` at left 220), with responsive horizontal centering and clamping.

## 2. Styling & Tooltips

- [x] 2.1 In `hintsunit.pas`, update tooltips for `gpunameEdit`, `cpunameEdit`, `gpuColorButton`, and `cpuColorButton` to clearly indicate HUD overlay line prefix and color customization.
- [x] 2.2 In `mangohud_ui.pas` (`ApplyMetricsTabTheme`), verify theme colors and font styling for `FGpuNameLabel` and `FCpuNameLabel`.

## 3. Build & Test Verification

- [x] 3.1 Compile the project with `lazbuild goverlay.lpi` and verify zero errors or warnings.
- [x] 3.2 Run the GUI test suite (`./tests/gui/goverlay_gui_tests`) and confirm all tests pass without regressions.
