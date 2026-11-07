# Proposal

## Why

The PasCube benchmark results screen (`bpResults`) currently pins two large cards across the top of all 6 carousel slides: the left "Main Score" hero card and the right "Carousel Navigation Bar" (which duplicates the slide title, renders 6 large pills, and displays a countdown). This fixed top shell consumes `6.45 * charHeight` (~180px of vertical height) across every page, visually cluttering the layout, cramping the 12-item "Hardware Comparison" list on Slide 1, and compressing the charts and cards on Slides 2–6.

Eliminating the top-right navigation box, scoping the "Main Score" card exclusively to Slide 1, expanding all slide cards to use the full vertical viewport (`1.0 * charHeight` down to the bottom bar), and moving slide pagination + countdown to a compact bottom-right pill indicator (`[ ━━ ▪ ▪ ▪ ▪ ▪ | 8s ]`) significantly declutters every page and gives existing cards and bars much better vertical breathing room.

## What Changes

- **Remove Top-Right Carousel Navigation Card**: Remove the large top-right navigation card (duplicate slide title, 6 labeled pills, and wide progress bar) from the top of the results screen.
- **Scope "Main Score" Hero Card to Slide 1 (`DrawSlide0_Overview`) Only**: Move the "Main Score" card (including the performance tier badge and `?` methodology button) into Slide 1's left column (`1.0 * charHeight` to `7.0 * charHeight`) so it transitions smoothly with Slide 1 and is absent from Slides 2–6. Restrict methodology `?` hover detection (`IsMethodologyButtonHovered`) to Slide 1 (`fActiveSlide = 0`).
- **Expand "Hardware Comparison" Card on Slide 1 to Full Height**: Extend the right-column "Hardware Comparison" card upward to `1.0 * charHeight` (matching the top of "Main Score"), increasing vertical item height (`baseItemH`), expanded details spacing (`expandExtra`), and bar thickness across the 12 reference GPUs while keeping `IsHardwareItemHovered` hit-boxes aligned.
- **Expand Slides 2–6 to Full Vertical Height with Increased Card/Bar Breathing Room**: Raise the top of the slide viewport from `7.45 * charHeight` to `1.0 * charHeight` across all slides. Increase vertical height and internal breathing room of existing KPI cards, spectrum bars, leaderboards, and distribution cards on Slides 2–6 (`DrawSlide1_BellCurve`, `DrawSlide2_Silicon`, `DrawSlide3_Efficiency`, `DrawSlide4_Scaling`, `DrawSlide5_Distros`) without adding extra list items.
- **Compact Bottom-Right Pagination Dots & Countdown Pill**: Add a compact pagination and timer pill (`[ ━━ ▪ ▪ ▪ ▪ ▪ | 8s ]` / `PAUSED`) in the bottom-right corner aligned vertically with the bottom action buttons and right-aligned with the slide container (`x = 1824`), with clickable dot hit-testing in `IsCarouselDotHovered`.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `pascube-community-insights`: Update `Results Carousel Navigation` requirement to replace the 6-pill top-right navigation bar with the compact bottom-right dash/dot pagination and countdown indicator while preserving side arrows and pause-on-hover behavior.
- `pascube-ui-presentation`: Update `Central Viewport Multi-Slide Insights Carousel` and `Carousel Pagination and Timed Auto-Advance Navigation` requirements so the viewport spans from the top margin (`1.0 * charHeight`), the `Main Score` hero card is exclusive to Slide 1 alongside a full-height `Hardware Comparison` card, Slides 2–6 occupy the full viewport height with taller cards/bars, and pagination/timer controls reside in the bottom-right corner.

## Impact

- `pascube_src/src/UnitPasCubeScreen.pas`:
  - `DrawResultsOverlay`: Remove top anchored shell (`Main Score` and top-right `DrawCarouselNavBar`), set `carouselY := 1.0 * charHeight`, and render the compact bottom-right pagination/timer indicator.
  - `DrawCarouselNavBar` & `IsCarouselDotHovered`: Reposition and redesign as a compact bottom-right pill (`[ ━━ ▪ ▪ ▪ ▪ ▪ | Xs ]` / `PAUSED`) with clickable dot hit-testing.
  - `DrawSlide0_Overview`, `IsHardwareItemHovered`, `IsMethodologyButtonHovered`, & Score Trend hover check: Render `Main Score` at the top of the left column on Slide 1, shift left-column subcards below it, and expand `Hardware Comparison` to full slide height (`aY` to `aY + aH`).
  - `DrawSlide1_BellCurve`, `DrawSlide2_Silicon`, `DrawSlide3_Efficiency`, `DrawSlide4_Scaling`, `DrawSlide5_Distros`: Increase vertical spacing, card heights, and bar dimensions to utilize the full-height viewport (`1.0 * charHeight` to `970px`).
