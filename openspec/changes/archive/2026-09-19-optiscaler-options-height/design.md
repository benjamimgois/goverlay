# Design

## Context

The OptiScaler tab layout consists of three vertical sections inside `FOsScrollBox`:
1. Top: Method and GPU Driver cards (`FOsUpscalerCard`, `FOsGpuCard`) with height `GPU_H = 102`.
2. Middle: Options card (`FOsOptionsCard`) containing four subcard columns (Main, Upscaler, Framegen, Reflex / Antilag).
3. Bottom: Software Status card (`FOsStatusCard`) with height `StatH = 170` (or `196` in Custom Channel mode).

In `ReflowOptiScalerTabNew`, `CardTop` for the status card is calculated relative to available height `TotalH`. When `MinOptH` was clamped to `410`, the formula `CardTop < MARGIN + GPU_H + GAP + MinOptH + GAP` evaluated to `474 < 528`, forcing `OptH := 410` and expanding `TotalH` to `702px`.

## Architecture & Layout Changes

1. **Height Clamping (`MinOptH := 290`)**:
   - In standard mode, the tallest column (Main) has its lowest element (`FOsShortcutCaptureBtn`) at `Y = 230px`.
   - In DLSS-Enabler mode, the toggle button ends at `Y = 282px`.
   - Clamping `MinOptH` to `290px` ensures `BoxH = 290 - 34 - 12 = 244px` in minimum scenarios and allows `OptH` to expand to ~356px (standard) or ~330px (custom) at standard window height (648px).
   - This ensures `TotalH <= 648px`, eliminating vertical scrolling.

2. **Accurate Available Height Fallback**:
   - If `FOsScrollBox.ClientHeight < 400`, fall back to `optiscalerTabSheet.ClientHeight` or `FForm.ClientHeight - 35`, preventing premature layout distortion during window initialization.

3. **DLSS-Enabler Toggle Geometry**:
   - Reposition `dlssenablerToggleLabel` to `Y0 + 200` and `dlssenablerToggleBtn` to `Y0 + 218` (Height 28px).
   - Keeps DLSS-Enabler controls within 282px height.

## Verification Plan

- Run GUI test suite (`make test`) verifying that:
  - `FOsOptionsCard.Height < 410`
  - `FOsBgPanel.Height <= FOsScrollBox.ClientHeight`
  - `FOsStatusCard` ends within `FOsScrollBox.ClientHeight`
