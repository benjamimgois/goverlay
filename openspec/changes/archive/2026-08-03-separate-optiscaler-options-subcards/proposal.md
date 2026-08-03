# Proposal: Separate OptiScaler Options into 4 Independent Sub-Cards

## Problem Statement
In the Upscalers tab under the "Options" card, the "Main", "Spatial Upscaler", and "Temporal Upscaler" sections currently share a single 75% width panel (`FOsOptiSec`) with painted vertical line dividers (`FOsOptiDiv1` / `FOsOptiDiv2`). In contrast, "Reflex / Antilag" (`FOsFakeSec`) is a separate 25% width sub-card with its own border box and header label (`FOsFakeLbl`). This creates visual asymmetry and inconsistent layout structure inside the "Options" card.

## Proposed Changes
1. **Replace Single OptiScaler Panel with 3 Independent Sub-Cards**:
   - Replace `FOsOptiSec` with three individual `TPanel` controls: `FOsMainSec`, `FOsSpatialSec`, and `FOsTemporalSec`.
   - Style all 4 sub-cards (`FOsMainSec`, `FOsSpatialSec`, `FOsTemporalSec`, and `FOsFakeSec`) using `SubCardPaint` so each section gets its own distinct border box, dark fill, and header title.

2. **Reflow & Coordinate System Improvements**:
   - Update `ReflowOptiScalerTabNew` in `optiscaler_tab.pas` to calculate 4 equal 25% width columns (`ColW := (InnerW - 3 * IGAP) div 4`).
   - Reparent controls (`filenameComboBox`, `menuscaleComboBox`, `optipatcherCheckBox`, `preferredUpscalerComboBox`, `spoofCheckBox`, `fgInputComboBox`, `fgOutputComboBox`, etc.) to their respective parent sub-card panels with local `(Left, Top)` offsets.

3. **Code Cleanup**:
   - Remove `FOsOptiDiv1` and `FOsOptiDiv2` line divider variables from `TOptiScalerTabHelper` / `Tgoverlayform`.
   - Remove the painted line divider logic in `Tgoverlayform.SubCardPaint` in `overlayunit.pas`.

## Impact
- Delivers a completely homogeneous 4-column sub-card grid inside the "Options" card.
- Improves code modularity by giving each section its own container panel and local coordinate frame.
