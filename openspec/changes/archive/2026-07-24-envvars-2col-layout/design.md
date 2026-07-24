## Context

The EnvVars tab (`tweaks_md3.pas`) renders a list of 28+ environment variable tweak controls using a custom-painted `TPaintBox` and mouse hit-test tracking.
Currently, items are rendered in a 1-column layout where each item's rectangle spans `R := Rect(0, Y, PB.Width, Y + ItemH)`. The toggle switch is drawn at `ToggleX := ARect.Right - 60`. On widescreen monitors, this results in toggle switches positioned 800px-1200px to the right of item text labels, making visual alignment difficult and inflating the total vertical height of the scrollable panel.

## Goals / Non-Goals

**Goals:**
- Implement a 2-column grid layout for EnvVars items when panel width is `>= 700px`.
- Reduce total vertical scroll height by ~50%.
- Keep toggle switches within close proximity to descriptions (~300px column width).
- Update mouse event handlers (`MouseMove`, `MouseDown`) to calculate column hit targets (`Col := (X - PAD) div ColW`).

**Non-Goals:**
- Changing the underlying data structures (`TWEAK_ROWS` array or INI save/load logic).
- Modifying other tabs (MangoHud, OptiScaler, PostProcessing).

## Decisions

1. **Responsive 2-column grid threshold (`Width >= 700px`)**
   - Rationale: On window widths `< 700px` (e.g. compact windows), 2 columns would compress item description text excessively. Falling back to 1 column preserves readability.

2. **Full-width category headers spanning both columns**
   - Rationale: Category headers ('General', 'Graphics', 'Performance', 'Latency reduction') remain full width (`Rect(0, Y, PB.Width, Y + HeadH)`) to serve as clear visual section dividers.

3. **Column item index calculation in loop**
   - Rationale: In 2-column mode, pairs of items (e.g. item `i` and `i+1`) occupy the same vertical step `Y`, taking `Col = 0` (left: `0` to `PB.Width div 2`) and `Col = 1` (right: `PB.Width div 2` to `PB.Width`). Vertical height step increments by `ItemH` after every 2 items.

## Risks / Trade-offs

- [Risk] Custom text descriptions (user-added custom envvars with long names) might clip if column width is narrow → Mitigation: Use `ACanvas.TextRect` with ellipsis/clipping, which is already present in `DrawItem`.
