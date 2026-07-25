## Context

In `vkbasalt_tab.pas`, `DrawToggle` allocates a 176x96 `TBitmap`, draws enlarged toggle components, and calls `ACanvas.StretchDraw(Rect(AX, AY, AX + 44, AY + 24), Bmp)`. This causes pixelated/aliased edge rendering due to nearest-neighbor scaling in LCL canvas stretch methods, whereas `tweaks_md3.pas` draws shapes directly on `ACanvas` at 44x24 scale, benefiting from native QPainter anti-aliasing.

## Goals / Non-Goals

**Goals:**
- Update `DrawToggle` in `vkbasalt_tab.pas` to use direct `ACanvas` rendering.
- Ensure visual consistency and crispness across all Material Design 3 toggle switches.

**Non-Goals:**
- Changing the dimensions (44x24px) or toggle color schemes (green/grey).

## Decisions

### Decision 1: Direct Canvas Drawing
- Remove `TBitmap.Create`, `Bmp.SetSize`, and `StretchDraw` from `DrawToggle` in `vkbasalt_tab.pas`.
- Adopt the direct `ACanvas` drawing logic from `tweaks_md3.pas`.

## Risks / Trade-offs

- None identified. Direct rendering improves both visual fidelity and paint performance.
