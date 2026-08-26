## Context

See `proposal.md` for motivation. The Performance tab benefits from a cohesive layout that integrates quick monitoring/sync in the upper pane and detailed limiter/filter configuration in the lower pane.

## Goals / Non-Goals

**Goals:**
- Implement **Option C** layout:
  - Top Row: Full-width Panoramic Card (`FPerfCards[0]`, height ~190px) housing `Information` (left) and `VSYNC` (right).
  - Bottom Row: Two independent side-by-side cards (`FPerfCards[1]` for `Limiters`, `FPerfCards[2]` for `Filters`) sharing an identical top seam and expanding vertically to fill the remaining window canvas.
- Dynamic reflow support for window sizes from 960x650 through maximized 1920x1080.
- Preserve all existing configuration loading, saving, and keybindings.

**Non-Goals:**
- Altering existing control semantics, keybindings, or MangoHud config parameters.
- Changing other tabs (Visual, Metrics, Extras).

## Decisions

### 1. 3-Card Architecture (Option C)
- **Decision**: Create 1 full-width panoramic card on top (`FPerfCards[0]`) and 2 equal-width cards on the bottom (`FPerfCards[1]` and `FPerfCards[2]`).
- **Rationale**: Provides a unified horizontal seam across the tab. The top dashboard handles metrics & sync cleanly, while the bottom row gives ample vertical space for limiters and texture filters.

### 2. Geometry & Coordinate Calculations in `ReflowPerformanceTab`
- `FullCardW := AContentW - 2 * MARGIN;`
- `HalfCardW := (FullCardW - GAP) div 2;`
- `TOP_H := 190;`
- `BottomH := Max(360, TabH - TOP_H - GAP - 2 * MARGIN);`
- `FPerfCards[0].SetBounds(MARGIN, 0, FullCardW, TOP_H);`
- `FPerfCards[1].SetBounds(MARGIN, TOP_H + GAP, HalfCardW, BottomH);`
- `FPerfCards[2].SetBounds(MARGIN + HalfCardW + GAP, TOP_H + GAP, HalfCardW, BottomH);`

### 3. VSYNC Controls Layout
- Centered vertically in the top-right sub-section `FPerfVsyncSec`:
  - `VsyncStart := (FPerfVsyncSec.ClientHeight - 2 * 38 - 12) div 2;`
  - Vulkan row: `Top := VsyncStart`, `Height := 38`
  - OpenGL row: `Top := VsyncStart + 38 + 12`, `Height := 38`

### 4. Filters Controls Layout
- Top: `filterRadioGroup` at `Top := 12`
- Row 1: `afTrackBar` (horizontal slider) + `afvalueLabel` (right-aligned) at `Top := 80`
- Row 2: `mipmapTrackBar` (horizontal slider) + `mipmapvalueLabel` (right-aligned) at `Top := 150`
- Sliders finish above Y = 200px, leaving plenty of clear margin from the floating dock at the bottom right.

## Risks / Trade-offs

- [Risk] Theme switching between Dark and Light mode must style all cards and subpanels.
  - *Mitigation*: Ensure `UpdatePerfCardTheme` iterates through `FPerfCards[0..2]` and handles inner sub-panels.
