# Tasks

## 1. Component Styling & Proportions

- [x] 1.1 Update `FFpsLimitEdit` in `mangohud_ui.pas` to standard input height (~28px), proportional font size, and compact width (~110px). Verify widget styling compiles and renders cleanly.
- [x] 1.2 Configure `fpscolor1ColorButton`, `fpscolor2ColorButton`, and `fpscolor3ColorButton` in `InitPerformanceTab` to form a cohesive, gapless segmented color bar.

## 2. Layout & Positioning Refactor

- [x] 2.1 Refactor the upper row in `TMangoHudUiHelper.ReflowPerformanceTab` to position FPS Limit, Method, and Toggle Key side-by-side with the hint label centered below. Verify bounds calculations prevent overlaps.
- [x] 2.2 Update the color grading section in `ReflowPerformanceTab` to align `fpscolor2SpinEdit` and `fpscolor3SpinEdit` directly centered beneath the segment seams between adjacent color buttons.
- [x] 2.3 Verify vertical spacing in `FPerfLimitSec` to ensure ~70–80px of clear margin above `FVkNemuDivider`.

## 3. Build & Integration Verification

- [x] 3.1 Compile the project using `lazbuild -B goverlay.lpi` and verify successful build with 0 errors.
- [x] 3.2 Inspect runtime layout rendering on Performance tab to verify the new horizontal alignment and color bar symmetry.
