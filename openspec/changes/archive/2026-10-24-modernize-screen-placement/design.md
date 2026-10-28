# Design: Modernize Screen Placement Monitor (Option 1)

## Context

See `proposal.md` for motivation. Currently, `mangohud_ui.pas` organizes the Visual tab into modular cards (`FVisScreenSec` in the right column). Within `FVisScreenSec`, the legacy `Image1` (`monitor.png`) is hosted alongside 8 individual `TRadioButton` controls and 2 `TSpinEdit` offset controls.

## Goals / Non-Goals

**Goals:**
- Implement a responsive vector monitor widget using `TPaintBox` (`FVisMonitorPaintBox`) inside `FVisScreenSec`.
- Vector-render the monitor bezel, screen display area, stand/pedestal, 8 anchor points, and a live mini-HUD preview chip placed at the active anchor.
- Provide interactive hover feedback (hand cursor, subtle anchor highlight) and instant click selection.
- Keep the underlying `TRadioButton`s (`topleftRadioButton`, etc.) fully synchronized to preserve 100% backward compatibility with configuration loading, saving (`GenericControlChange`), and existing test suites.
- Support Dark and Light themes automatically.
- Position `Offset X` and `Offset Y` cleanly below the monitor in a dedicated row.

**Non-Goals:**
- Modifying MangoHud configuration syntax or backend parsing logic.
- Altering the behavior of other Visual tab sections (Typography, Canvas, Action Bar).

## Decisions

### Decision 1: Custom Vector Rendering via TPaintBox vs. Bitmap Images
- **Choice**: Vector drawing on `TPaintBox` (`FVisMonitorPaintBox`).
- **Rationale**: Eliminates dependency on static bitmap assets (`monitor.png`), scales crisply on HiDPI displays, adapts colors dynamically to system Dark/Light themes, and enables rendering the live mini-HUD chip at exact geometric positions.
- **Alternative considered**: Storing 8 static bitmap pre-rendered images. Rejected because it multiplies asset overhead and does not adapt to themes.

### Decision 2: Synchronization Architecture with Legacy Radio Buttons
- **Choice**: The modern vector monitor acts as the primary visual facade while keeping existing `TRadioButton` controls in `FVisScreenSec` (either hidden or styled away).
- **Rationale**: GOverlay's persistence routines (`overlayunit.pas`), profile switches, and GUI test suites (`TestMangoHudAllRadioGroups`, etc.) directly check `topleftRadioButton.Checked`. By driving them when an anchor is clicked and updating `FVisMonitorPaintBox` on repaint/state change, zero breaking changes are introduced.
- **Workflow**:
  1. On click on `FVisMonitorPaintBox`: Calculate which of the 8 anchor zones (`Top-Left`, `Top-Center`, `Top-Right`, `Middle-Left`, `Middle-Right`, `Bottom-Left`, `Bottom-Center`, `Bottom-Right`) contains `(X, Y)`.
  2. Set corresponding `TRadioButton.Checked := True`.
  3. Call `GenericControlChange(Sender)` to immediately save to `MangoHud.conf`.
  4. Repaint `FVisMonitorPaintBox`.

### Decision 3: Anchor Geometry & Live HUD Anchor Chip
- **Screen Geometry**:
  - Screen area inside bezel: Margins of ~12px for bezel.
  - 8 Anchor points:
    - Top: Left (padding 14px, 14px), Center (middle X, 14px), Right (width - 14px, 14px).
    - Middle: Left (14px, middle Y), Right (width - 14px, middle Y).
    - Bottom: Left (14px, height - 14px), Center (middle X, height - 14px), Right (width - 14px, height - 14px).
  - Mini-HUD Chip:
    - Dimensions: ~56px × 24px (or proportional to monitor width).
    - Border: Accent color (Cyan / Highlight).
    - Label: `HUD` or `144 FPS` with mini colored indicator bars.
    - Position: Aligned directly to the selected anchor corner or edge.

## Risks / Trade-offs

- **Risk**: Existing GUI tests checking radio button visibility or position.
  - **Mitigation**: Keep the radio buttons in the component tree with `Visible := False` (or positioned behind the paintbox) while preserving their event bindings. If a GUI test expects them to exist, it can still interact with them directly.
- **Risk**: HiDPI scaling issues with hardcoded coordinates.
  - **Mitigation**: Compute all anchor coordinates, bezel radii, and HUD chip dimensions dynamically based on `FVisMonitorPaintBox.ClientWidth` and `ClientHeight`.
