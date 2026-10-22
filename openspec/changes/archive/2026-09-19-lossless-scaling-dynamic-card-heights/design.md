# Design

## Context

In GOverlay tabs (such as OptiScaler, ReShade, and MangoHud Visual/Performance), the tab layout calculates the available client height `TotalH`, anchors the bottom status card or info bar to the bottom of the viewport, and dynamically expands the middle configuration cards to consume available vertical space.

In `lossless_scaling_tab.pas`, `ReflowLosslessScalingTab` previously used fixed heights for all cards regardless of window size, leaving empty background space below the status card when the window was resized or maximized.

## Architecture & Layout Changes

1. **Available Height Determination (`TotalH`)**:
   - `TotalH := FLsScrollBox.ClientHeight;`
   - If stale or in FormResize: fall back to `FForm.ClientHeight - 35`.
   - If below minimum: default to 648px.

2. **Status Card Anchoring**:
   - Precompute `StatusCardH := Y2 + ROW_H + 10` (or `Y3 + 36` if progress bar is visible).
   - Set `CardTop := TotalH - MARGIN - StatusCardH;`
   - Set bounds: `FLsStatusCard.SetBounds(MARGIN, CardTop, CW, StatusCardH);`

3. **Dynamic Middle Cards Height Allocation**:
   - Compute `AvailMiddleH := CardTop - GAP - TopCardsBottom;`
   - For `imMako`:
     - Minimums: `MinFgH := 236` (276 if adaptive), `MinSpatialH := 144`.
     - `MinMiddleH := MinFgH + GAP + MinSpatialH;`
     - If `AvailMiddleH < MinMiddleH`: clamp to minimums and set `TotalH := CardTop + StatusCardH + MARGIN;` (activating scrollbox scroll).
     - If `AvailMiddleH >= MinMiddleH`:
       - `ExtraH := AvailMiddleH - MinMiddleH;`
       - `ExtraFg := (ExtraH * 6) div 10;`
       - `ExtraSpatial := ExtraH - ExtraFg;`
       - `FgH := MinFgH + ExtraFg;`
       - `SpatialH := MinSpatialH + ExtraSpatial;`
     - `FLsFrameGenCard.SetBounds(MARGIN, TopCardsBottom, CW, FgH);`
     - `FLsSpatialCard.SetBounds(MARGIN, TopCardsBottom + FgH + GAP, CW, SpatialH);`
   - For `imLsfg` / `imNone`:
     - Allocate `FgH := AvailMiddleH` (clamped to minimum 240 / 84).

4. **Scrollbox Panel Bounds**:
   - `FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, TotalH));`

## Verification Plan

- Run GUI regression tests (`make test`):
  - Verify toggles stay aligned on single row in MAKO mode.
  - Verify cards fit within default viewport without vertical scrolling.
  - Verify cards expand vertically and status card stays anchored to bottom when window height is resized to 840px.
