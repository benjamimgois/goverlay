# Design: Finish Pill Highlight Hover Styling

## Context

`floating_dock.pas` provides `TFloatingActionDock`, which draws a floating action bar at the bottom-right of the window. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Eliminate the dark theme flat button hover rectangle rendered by the native widgetset over the primary `✓ Finish` action button.
- Implement custom state-aware painting for the Finish button:
  - **Normal**: `#2078B4` (`RGB(32, 120, 180)`).
  - **Hover**: `#2B94DC` (`RGB(43, 148, 220)`) — vibrant, luminous blue/cyan.
  - **Pressed**: `#185F9B` (`RGB(24, 95, 155)`) — deep active blue for tactile feedback.
- Keep text crisp white (`clWhite`) across all states.
- Support solo Finish pill mode (when other buttons are hidden) and multi-button dock mode seamlessly.

**Non-Goals:**
- Altering the secondary button styles (`FPreviewBtn`, `FMenuBtn`, `FAddBtn`), which already blend correctly with the dark dock background.

## Decisions

### Decision 1: Custom Paint & Event Tracking for Finish Control
- **Choice**: Use a dedicated `TPaintBox` (or custom canvas-painted control) with `Cursor := crHandPoint`, `OnMouseEnter`, `OnMouseLeave`, `OnMouseDown`, `OnMouseUp`, `OnClick`, and `OnPaint`.
- **Rationale**: `TSpeedButton` with `Flat := True` delegates hover painting to the underlying LCL widgetset engine (Qt6), which forcibly draws a dark surface rectangle over the canvas. A custom-painted control grants 100% pixel-level control across all widgetsets.

### Decision 2: Harmonized Pill Background & Button Canvas
- **Choice**: `FPillBox.PillPaint` and the Finish button share the state-driven color calculation (`Normal`, `Hover`, `Pressed`) so the rounded right edge and the button interior always render an unbroken, seamless surface.

## Risks / Trade-offs

- **Risk**: Keyboard accessibility / tab focus.
  - **Mitigation**: `TSpeedButton` did not participate in tab ordering. The dock retains its exact click and notification event model.
