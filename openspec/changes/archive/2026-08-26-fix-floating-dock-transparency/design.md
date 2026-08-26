## Context

The floating action dock (`TFloatingActionDock` in `floating_dock.pas`) is an anchored pill-style floating bar positioned in the bottom-right corner of `goverlayPanel`. In commit `37f8f98`, it had visual defects including black drop shadows, clipping corners outside the pill curve, and seams around individual button controls.

See `proposal.md` for motivation and `specs/floating-action-dock/spec.md` for requirements.

## Goals / Non-Goals

**Goals:**
- Eliminate the hard black drop shadow `(0, 0, 0)` from `PillPaint`.
- Unify all painting (pill shape, Finish blue accent, separator, button icons and labels) onto a single `TPaintBox` (`FPillBox`).
- Dynamically match the container's background color with `FParent.Color` (`#161A28` on dark theme, `#F5F5F5` on light theme) to ensure seamless blending of pixels outside the semicircular pill boundary.
- Calculate exact corner radius `Rad := PB.Height div 2` (19px) to produce smooth semicircular ends without octagonal/chamfered edges.
- Maintain the solid blue Finish button section occupying the right side of the pill with state-aware hover/press illumination.

**Non-Goals:**
- Changing the dock dimensions, button layout order, or shortcuts.
- Introducing external graphic assets or third-party image dependencies.

## Decisions

1. **Single Unified `TPaintBox` vs. Multi-PaintBox Hierarchy**:
   - *Decision*: Consolidate all rendering into `FPillBox` and handle mouse hover/press/click via hit-testing (`GetButtonAt(X, Y)`).
   - *Rationale*: Individual child `TPaintBox` widgets in Qt6 LCL erase their bounding boxes to container background before painting, which created dark borders and seams around buttons. A single unified paint box eliminates all seams and allows pixel-perfect drawing in a single continuous pass.

2. **Removal of Hard `(0, 0, 0)` Drop Shadow**:
   - *Decision*: Completely remove the 2px offset drop shadow.
   - *Rationale*: A solid black drop shadow on a rounded control without alpha blur creates harsh dark bands and looks unpolished against both dark and light backgrounds.

3. **Exact Semicircular Corner Radius (`PB.Height div 2`)**:
   - *Decision*: Pass `Rad := PB.Height div 2` (19px) to `Canvas.RoundRect`.
   - *Rationale*: Over-specifying radius (e.g. `PB.Height` = 38px) causes Qt6 LCL to clamp or chamfer corners into octagonal facets. Div 2 produces true continuous semicircular ends.

## Risks / Trade-offs

- [Risk]: Mouse interaction on single surface requires manual hit-testing.
  → Mitigation: `GetButtonAt` maps coordinates cleanly to button bounding rects (`FMenuRect`, `FPreviewRect`, `FAddRect`, `FFinishRect`), updating hover states, hints, and cursor types smoothly.
