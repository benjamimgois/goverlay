# Proposal: Finish Pill Highlight Hover Styling

## Why

When hovering the mouse over the primary `✓ Finish` pill in the floating action dock (`TFloatingActionDock`), the native Qt6 / LCL widgetset draws a dark theme flat button hover rectangle (`#1B2332` with an outline), which overrides and replaces the primary button's vibrant blue accent fill (`#2078B4`). While dark hover states look natural over the dark portion of the dock for secondary buttons (`Menu`, `Preview`, `Add`), it causes the primary `Finish` button to lose its distinct highlighted appearance. Implementing custom canvas hover rendering ensures the button remains prominently illuminated with a brighter, more vibrant blue/cyan fill and crisp white text.

## What Changes

- Update `TFloatingActionDock` in `floating_dock.pas` to manage custom hover and press states for the primary `Finish` button:
  - Track mouse state (`MouseEnter`, `MouseLeave`, `MouseDown`, `MouseUp`) on the Finish button.
  - Draw custom background on `FPillBox` for the Finish button:
    - **Normal**: Solid primary blue/cyan fill (`RGBToColor(32, 120, 180)` / `#2078B4`).
    - **Hover (Mouse In)**: Luminous, brighter blue/cyan fill (`RGBToColor(43, 148, 220)` / `#2B94DC`) with white text and smooth edge rounding.
    - **Pressed (Click)**: Deeper active blue fill (`RGBToColor(24, 95, 155)` / `#185F9B`) for tactile feedback.
  - Prevent default opaque dark widgetset hover overlay on the Finish button.
- Maintain seamless dark-theme styling on secondary buttons (`FPreviewBtn`, `FMenuBtn`, `FAddBtn`).

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `floating-action-dock`: Update floating action dock styling to render custom vibrant hover and press states for the primary Finish action button without dark widgetset overlay.

## Impact

- `floating_dock.pas`: Updated `TFloatingActionDock` painting and event handling for hover/press states.
- `tests/gui/gui_test_cases.pas`: Automated GUI test verifying Finish button hover and press state transitions.
