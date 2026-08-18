# Proposal: Fix Background Height and Viewport Gap on Lossless Scaling Tab

## Problem Statement

When the "Upscalers" sidebar category toggle is set to `OFF`, navigating to or viewing the "Lossless Scaling" tab reveals a large gray rectangle filling the lower section of the window below the "Hardware & Pacing" card.

This occurs because:
1. `TLosslessScalingTabHelper.ReflowLosslessScalingTab` in `lossless_scaling_tab.pas` sets `FLsBgPanel.Height := CurY` (approx 422px), which is shorter than `FLsScrollBox.ClientHeight` (approx 600-650px).
2. When the tool is toggled off, `SetControlTreeEnabled` sets `FLsScrollBox.Enabled := False`. Qt6 draws the exposed, uncovered viewport area of the disabled `QScrollArea` in the system disabled palette color (gray).
3. In `overlayunit.pas`, `FormResize` did not invoke `ReflowLosslessScalingTab`, leaving the panel dimensions stale upon window resizing.

## Proposed Solution

1. **Expand Background Panel to Fill Viewport Height**:
   - In `lossless_scaling_tab.pas` (`ReflowLosslessScalingTab`), set `FLsBgPanel.SetBounds(0, 0, W, Max(FLsScrollBox.ClientHeight, CurY))` using `Math.Max`.
   - Ensure the styled background panel (`FLsBgPanel`) always covers 100% of the visible viewport area, seamlessly painting the dark navy background (`#161A28`) on dark theme and light background on light theme.

2. **Hook Form Resize**:
   - In `overlayunit.pas` (`FormResize`), call `ReflowLosslessScalingTab(ContentW)` alongside the other tab reflow routines.

## Capabilities

### Modified Capabilities
- `lossless-scaling-tab`: Ensures the background panel covers the entire viewport height and renders seamlessly under both enabled and disabled states.

## Impact

- No gray gaps or visual glitches on the Lossless Scaling tab regardless of window dimensions, resize actions, or tool toggle state (`ON` or `OFF`).
