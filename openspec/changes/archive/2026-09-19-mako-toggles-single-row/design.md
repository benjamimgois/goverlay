# Design

## Context

In `lossless_scaling_tab.pas`, when the MAKO interpolation method is selected, the layout inside `FLsScrollBox` arranges cards vertically:
1. `FLsMethodCard`: Height 88px.
2. `FLsGpuCard`: Height 56px.
3. `FLsFrameGenCard`: Previously 276px.
4. `FLsSpatialCard`: Previously 154px.
5. `FLsStatusCard`: Previously 142px.

With 10px margins and gaps, the total content height was 700px. With standard window client height at ~648px, this caused vertical scrollbars to activate.

In the Frame Generation card, `FLsPerfModeToggle`, `FLsUltraPerfToggle`, and `FLsAllowFp16Toggle` were placed on row `Y = 206` across 3 columns (`Col3W`), while `FLsFgLiveToggle` was alone on row `Y = 238`.

## Architecture & Layout Changes

1. **Single-Row 4-Column Layout for MAKO Toggles**:
   - In `ReflowLosslessScalingTab`, calculate `Col4W := (CW - (PAD * 2) - 36) div 4`.
   - Place all four active MAKO toggles on row `Y = 202`:
     - `FLsPerfModeToggle` at `(PAD, 202, Col4W, 24)`
     - `FLsUltraPerfToggle` at `(PAD + Col4W + 12, 202, Col4W, 24)`
     - `FLsAllowFp16Toggle` at `(PAD + (Col4W + 12) * 2, 202, Col4W, 24)`
     - `FLsFgLiveToggle` at `(PAD + (Col4W + 12) * 3, 202, Col4W, 24)`
   - Set hidden compatibility toggles (`FLsHdrModeToggle`, `FLsNoFp16Toggle`) using `Col4W` bounds to preserve test safety.

2. **Frame Generation Card Height Reduction**:
   - In standard (non-adaptive) mode, reduce `FLsFrameGenCard` height from 276px to 236px.
   - When adaptive mode is active (`IsAdaptive = True`), keep 276px height for adaptive toggles.

3. **Subtle Card Vertical Tightening**:
   - `FLsSpatialCard`: Reduced height from 154px to 144px (trackbars at `Top = 108` instead of `114`, value labels at `112`).
   - `FLsStatusCard`: Reduced row spacing from 8px to 6px, setting non-progress height to `Y2 + ROW_H + 10` (~100px).
   - Total height now equals 642px (<= 648px client height), completely eliminating vertical scrolling.

4. **Expose Properties for Automated GUI Verification**:
   - Expose `ScrollBox: TScrollBox` and `BgPanel: TPanel` on `TLosslessScalingTabHelper`.

## Verification Plan

- Run GUI regression test `TestLosslessScalingMakoTogglesLayoutAndNoScroll`:
  - Assert all 4 toggles share the same `Top` position.
  - Assert `FrameGenCard.Height <= 240`.
  - Assert `BgPanel.Height <= ScrollBox.ClientHeight` and status card fits within client height.
- Run `make test` to verify the full 118-test suite passes without errors.
