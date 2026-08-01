# Tasks: Redesign Upscalers Tab Layout to Fill Viewport

## Implementation Steps
- [x] 1. Update `ReflowOptiScalerTabNew` in `optiscaler_tab.pas`:
  - [x] 1.1 Calculate `TotalH := FOsScrollBox.ClientHeight` and set `FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, TotalH)`.
  - [x] 1.2 Position `FOsStatusCard` anchored at `CardTop := TotalH - MARGIN - STAT_H`.
  - [x] 1.3 Compute `OPT_H := FOsStatusCard.Top - GAP - (MARGIN + GPU_H + GAP)` and set `FOsOptionsCard` height.
  - [x] 1.4 Reflow inner sub-cards (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) to 33.3% equal columns spanning 100% of inner width.
- [x] 2. Build & verify layout:
  - [x] 2.1 Recompile with `lazbuild --build-mode=Release goverlay.lpi`.
  - [x] 2.2 Verify tab switching between "Post processing" and "Upscalers" to ensure red background strip is completely gone.
