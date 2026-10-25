# Tasks

## 1. Component Reparenting & Initialization

- [x] 1.1 Reparent `fpscolorCheckBox` (and `FfpscolorToggle`), `fpscolor1..3ColorButton`, and `fpscolor2..3SpinEdit` to `FPerfLimitSec` in `InitPerformanceTab`
- [x] 1.2 Reparent `vpsCheckBox` (and `FvpsToggle`) to `FPerfFrametimeSec` in `InitPerformanceTab`
- [x] 1.3 Update card height constants in `InitPerformanceTab` and `ReflowPerformanceTab` (`CARD0_H = 185`, `CARD1_H = 170`, `CARD2_H = 250`)

## 2. Rate Control Layout Homogenization (Option A Cleaned)

- [x] 2.1 Refactor `FPerfLimitSec` layout in `ReflowPerformanceTab`:
  - Row 1: 3 homogeneous columns sharing identical dimensions (105px width, height dynamically matched to combobox ~32px)
  - Labels: Left-aligned to each control's left edge (`FPS Limit` without icon, `Method`, `Limit toggle key`)
  - Tooltip: Guidance (`e.g. 30,60,120,0 — 0 to unlimited` and cycling info) moved into `FFpsLimitEdit.Hint` (`ShowHint := True`), removing clutter from card surface
  - Presets removed from card surface to ensure a clean, modern aesthetic
  - Row 2: `Change FPS colors` toggle (`FfpscolorToggle`) at Y=88
  - Row 3: 3-phase color gradient swatches (`fpscolor1..3ColorButton`) and spin edits (`fpscolor2..3SpinEdit`) at Y=118
- [x] 2.2 Unify heights in Idle Limiter (`FVkNemuSec`):
  - Set `AutoSize := False` and match `Constraints.MinHeight`/`MaxHeight` to `NemuCtrlH` (~32px) on all 4 controls (`FVkNemuIdleFpsSpin`, `FVkNemuTimeoutSpin`, `FVkNemuInputCombo`, `FVkNemuDelaySpin`)

## 3. Symmetrical 4x4 Telemetry Layout

- [x] 3.1 Refactor `FPerfInfoSec` (Frame Rate) to 4 clean rows:
  - Row 1 (Y=12): `Show FPS` toggle (`FfpsToggle`)
  - Row 2 (Y=44): `FPS Average` toggle (`FfpsavgToggle`) + `1% low | 0.1% low` segmented dual-pill right-aligned (`fpsavgBitBtn`)
  - Row 3 (Y=76): `FPS limit` on HUD (`FshowfpslimToggle`)
  - Row 4 (Y=108): `Count frames` (`FframecountToggle`)
- [x] 3.2 Refactor `FPerfFrametimeSec` (Frame Timing) to 4 symmetrical rows:
  - Row 1 (Y=12): `Frame Time` toggle (`FframetimegraphToggle`) + 22x22 square swatch on left, `Curve | Histogram` pill right-aligned (`frametimetypeBitBtn`)
  - Row 2 (Y=44): `Frame Time +` toggle (`FframetimedetailedToggle`)
  - Row 3 (Y=76): `ftrace debug` toggle (`FftraceToggle`)
  - Row 4 (Y=108): `Vulkan Pacing (VPS)` toggle (`FvpsToggle`)

## 4. Build & Visual Verification

- [x] 4.1 Compile the project with `lazbuild goverlay.lpi --bm=Release --ws=qt6`
- [x] 4.2 Verify homogeneous inputs in Rate Control, 4x4 telemetry symmetry, and zero clipping
