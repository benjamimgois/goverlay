# Proposal

## Why

In the Lossless Scaling tab (`lossless_scaling_tab.pas`), the cards had fixed hardcoded heights (`FLsFrameGenCard`: 236px/276px, `FLsSpatialCard`: 144px, `FLsStatusCard`: 140px) stacked top-to-bottom. The Software Status card was not anchored to the bottom of the viewport, and the middle cards did not expand when the application window was resized or maximized.

Consequently, when the user resized the interface (or opened it at standard window heights), an empty dead area appeared at the bottom of the tab below the status card, while other tabs (OptiScaler, ReShade, MangoHud) adaptively expand cards to fill the vertical space with the status card pinned to the bottom.

## What Changes

- Anchor `FLsStatusCard` to the bottom of the viewport (`TotalH - MARGIN - StatusCardH`).
- Dynamically expand the middle cards (`FLsFrameGenCard` and `FLsSpatialCard`) to take up all available vertical space when the viewport is taller than the minimum required height.
- In MAKO mode, distribute extra vertical space proportionally (60% to Frame Generation, 40% to Spatial Scaling).
- In `imLsfg` and `imNone` modes, expand `FLsFrameGenCard` to meet the anchored bottom status card.
- Retain minimum size clamping (`MinFgH`, `MinSpatialH`) so that if the window is shrunk below minimum dimensions, the scroll box smoothly allows vertical scrolling without clipping or distortion.
- Enhance GUI test `TestLosslessScalingMakoTogglesLayoutAndNoScroll` in `tests/gui/gui_test_cases.pas` to test dynamic card height expansion and bottom status card anchoring across window resizes.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `lossless-scaling-config`: Dynamically adapt card heights to fill viewport and anchor Software Status card to bottom on window resize.

## Impact

- **Affected Files**:
  - `lossless_scaling_tab.pas`: `ReflowLosslessScalingTab` height distribution and status card bottom anchoring.
  - `tests/gui/gui_test_cases.pas`: GUI tests verifying dynamic expansion and bottom anchoring on resize.
- **Compatibility**: No regressions; minimum dimensions preserved.
