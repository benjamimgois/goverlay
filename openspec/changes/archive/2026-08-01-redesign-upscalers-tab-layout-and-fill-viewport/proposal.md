# Proposal: Redesign Upscalers Tab Layout to Fill Viewport and Eliminate Red Background Strip

## Problem Statement
When navigating between tabs (e.g. from "Post processing" back to "Upscalers"), a reddish background strip is exposed at the bottom of the container above the bottom action bar. This occurs because card positions and heights are calculated statically, leaving empty unused vertical space at the bottom of `FOsScrollBox`. Additionally, the middle Options card (`FOsOptionsCard`) has fixed-width inner sub-cards (`FOsOptiSec`, `FOsImgSec`, `FOsFakeSec`) with unutilized horizontal margins on the left/right and between sections.

## Proposed Changes
1. **Dynamic Viewport Height & Bottom Anchoring**:
   - Anchor `FOsStatusCard` ("Software Status") dynamically to the bottom margin of `FOsScrollBox` (`Top := TotalH - MARGIN - STAT_H`), covering the unpainted bottom background area.
   - Stretch `FOsOptionsCard` ("Options") vertically so its height (`OPT_H`) fills all available space between the top cards ("Upscaler" & "GPU Driver") and the bottom "Software Status" card (`OPT_H := FOsStatusCard.Top - GAP - (MARGIN + GPU_H + GAP)`).

2. **100% Horizontal Expansion for Sub-cards**:
   - Divide `FOsOptionsCard` inner width into 3 equal 33.3% columns (`SubCardW := (InnerW - 2 * IGAP) div 3`).
   - Stretch `FOsOptiSec`, `FOsImgSec`, and `FOsFakeSec` across the full width of the Options card, eliminating empty side gaps.

3. **Background Coverage**:
   - Set `FOsBgPanel.SetBounds(0, 0, FOsScrollBox.ClientWidth, TotalH)` so the dark background panel covers the entire viewport seamlessly.

## Impact
- Eliminates the reddish background strip exposed at the bottom of the Upscalers tab when switching tabs or resizing.
- Provides extra vertical and horizontal room inside the Options card for controls.
- Maintains clean alignment across all screen resolutions without unnecessary scrollbars.
