# Proposal

## Why

In the Lossless Scaling tab, when the "MAKO" method is selected, the Frame Generation card placed the "Live FG Switch" toggle switch alone on a separate row (`Y = 238`) below the other toggles (`Performance Mode`, `Ultra Performance`, `Allow FP16`) on row `Y = 206`.

This increased the required height of the Frame Generation card to 276px, and when combined with the Spatial Scaling card and Software Status card, caused the total tab content height to exceed the standard window client height (~648px), triggering an unnecessary vertical scrollbar.

## What Changes

- Move `FLsFgLiveToggle` to the same row (`Y = 202`) alongside `FLsPerfModeToggle`, `FLsUltraPerfToggle`, and `FLsAllowFp16Toggle`, distributing them evenly across 4 columns (`Col4W`).
- Reduce the Frame Generation card height from 276px to 236px in standard (non-adaptive) mode.
- Fine-tune vertical spacing slightly in `FLsSpatialCard` (144px) and `FLsStatusCard` (134px) so that the entire Lossless Scaling tab content height in MAKO mode is 642px, fitting completely within the 648px client height with zero vertical scroll.
- Add GUI regression test `TestLosslessScalingMakoTogglesLayoutAndNoScroll` in `tests/gui/gui_test_cases.pas`.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `lossless-scaling-config`: Update MAKO Frame Generation card layout to position toggles on a single row and eliminate vertical scrolling on standard window heights.

## Impact

- **Affected Files**:
  - `lossless_scaling_tab.pas`: Toggle positioning, card heights, and exposed `ScrollBox`/`BgPanel` properties.
  - `tests/gui/gui_test_cases.pas`: GUI regression tests verifying single-row toggle alignment and scroll box height bounds.
- **Compatibility**: All toggles remain fully functional and visible; hidden compatibility toggles are retained for test assertions.
