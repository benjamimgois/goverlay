# Design

## Context

In `pascube_src/src/UnitPasCubeScreen.pas`, `DrawResultsOverlay` currently renders a fixed top shell (`cardY = 1.0 * charHeight`, height `6.0 * charHeight`) consisting of:
1. Top-left: `Main Score` hero card (`leftColX1`, width `0.43 * 1920`).
2. Top-right: `DrawCarouselNavBar` (`rightColX1`, width `0.43 * 1920`), which displays the current slide title, `[ Auto: Xs ]`/`[ PAUSED ]`, 6 navigation pills, and a thin progress bar.

Because this top shell is anchored across all slides, the slide viewport starts at `carouselY = 7.45 * charHeight` and ends at `y = 970.0` (`1080.0 - 110.0`), leaving `6.45 * charHeight` (~180px) unavailable to the slides. Meanwhile, the bottom action button bar (`y = 1005.0`, height `50.0`) is horizontally centered around `cx = 960.0` (`x = 550.0` to `x = 1370.0`), leaving `454px` (`x = 1370.0` to `x = 1824.0`) completely unused in the bottom-right corner. See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Unify the slide viewport to start at `carouselY = 1.0 * charHeight` (`carouselH = 1080.0 - 110.0 - carouselY`), reclaiming `+6.45 * charHeight` of vertical height across every slide.
- Render `Main Score` inside `DrawSlide0_Overview` so it is only visible on Slide 1 and animates smoothly during slide transitions (`fSlideTransitionT`).
- Expand Slide 1's `Hardware Comparison` card (`rightColX1`) from `1.0 * charHeight` down to the bottom of the viewport, increasing item heights and spacing for the 12 GPU entries.
- Increase vertical height and internal breathing room of existing cards, gauges, and bars on Slides 2–6 (`DrawSlide1_BellCurve` through `DrawSlide5_Distros`).
- Replace the top-right `DrawCarouselNavBar` with a compact bottom-right pagination and countdown pill (`[ ━━ ▪ ▪ ▪ ▪ ▪ | Xs ]` / `PAUSED`) aligned with the bottom button bar and right edge (`x = 1824.0`).

**Non-Goals:**
- Adding new leaderboard entries or increasing item counts on Slides 2–6 (keep existing item counts and only increase vertical height/breathing room).
- Changing side navigation arrows (`DrawSideNavArrows`), keyboard navigation, or scroll-wheel slide switching.

## Decisions

### 1. Full-Height Carousel Viewport with `Main Score` Inside `DrawSlide0_Overview`
- **Decision**: Set `carouselY := 1.0 * charHeight` and `carouselH := 1080.0 - 110.0 - carouselY` in `DrawResultsOverlay` and `IsCarouselAreaHovered`. Move the `Main Score` card drawing code from `DrawResultsOverlay` into the top-left of `DrawSlide0_Overview` (`aX`, `aY`, `leftColWidth`, `6.0 * charHeight`), applying `aAlpha` to all its boxes and texts.
- **Rationale**: Drawing `Main Score` inside `DrawSlide0_Overview` using the slide's `aX` and `aAlpha` parameters means that when transitioning between Slide 1 and Slide 2 (`fSlideTransitionT`), `Main Score` slides and cross-fades together with the rest of Slide 1 rather than popping in/out abruptly.
- **Hit-Testing Guard**: Update `IsMethodologyButtonHovered` to return `False` when `fActiveSlide <> 0` so hovering the top-left area on Slides 2–6 does not trigger the methodology overlay. Notice that on Slide 1, the left-column subcards (`CPU Single/Multi`, `GPU Raster/RT`, `Live Telemetry`, `Score Trend`) start at `aY + 6.45 * charHeight` (`= 7.45 * charHeight`), which preserves their exact screen Y coordinates and keeps the `Score Trend` hover logic accurate.

### 2. Full-Height `Hardware Comparison` Card on Slide 1
- **Decision**: In `DrawSlide0_Overview`, `hwCardY := aY` (`1.0 * charHeight`) and `hwCardH := aH` (spanning the full height of the viewport). Increase `baseItemH` from `2.25 * charHeight` to `2.70 * charHeight`, `expandExtra` from `2.75 * charHeight` to `3.10 * charHeight`, and `barH` from `0.25 * charHeight` to `0.30 * charHeight` (with proportionally adjusted internal offsets for RT bar and specs text). Update `IsHardwareItemHovered` to use `cardY := 1.0 * charHeight` and the exact same `baseItemH` and `expandExtra` values.
- **Rationale**: With 12 items (`11 * baseItemH + 1 * (baseItemH + expandExtra)` or `10 * baseItemH + 2 * (baseItemH + expandExtra)` when a second GPU is clicked), the extra `6.45 * charHeight` allows `baseItemH = 2.70 * charHeight` and `expandExtra = 3.10 * charHeight` (`12 * 2.70 + 2 * 3.10 + 2.6 = 41.2 * charHeight`), fitting comfortably inside the full-height card without bottom overflow.

### 3. Increased Vertical Breathing Room Across Slides 2–6
- **Decision**: Because `aH` increases by `+6.45 * charHeight` on Slides 2–6:
  - **Slide 2 (`DrawSlide1_BellCurve`)**: Increase header vertical spacing (`kpiY := aY + 4.0 * charHeight`), increase KPI card height (`kpiH := 4.2 * charHeight`), and let `plotH` absorb the remaining height (`plotY := kpiY + kpiH + 1.4 * charHeight`) so the 32 Gaussian density bars and callout pins are taller and more spacious.
  - **Slide 3 (`DrawSlide2_Silicon`)**: Increase `colY := aY + 4.0 * charHeight`, move the spectrum bar down (`barY := colY + 5.0 * charHeight`, thickness `18.0px`), increase the Bin/Delta summary strip height (`2.3 * charHeight`), and move `lbHeaderY := barY + 5.0 * charHeight` so the 4 leaderboard rows (`lbRowH`) automatically expand to fill the taller column with thicker progress bars (`10.0px`) and centered text.
  - **Slide 4 (`DrawSlide3_Efficiency`)**: Increase top KPI card height (`kpiY := aY + 3.8 * charHeight`, `kpiH := 4.0 * charHeight`), increase thermal gauge bar height (`barH := 16.0`), add vertical breathing room around the gauge (`barY := colY + 2.6 * charHeight`, `rowY := barY + 1.5 * charHeight`), and let the 5 efficiency ranking rows (`itemH`) expand automatically with `availH` and thicker bars (`12.0px`).
  - **Slide 5 (`DrawSlide4_Scaling`)**: Set `ladderY := aY + 4.0 * charHeight` and `ladderH := aH - 5.8 * charHeight` with `10.0px` row gap; the 6 ladder rungs (`rowH`) expand automatically, with thicker proportional bars (`barH := 20.0`) and vertically centered labels/badges.
  - **Slide 6 (`DrawSlide5_Distros`)**: Set `colY := aY + 4.0 * charHeight` and `colH := aH - 5.8 * charHeight` with `10.0px` row gap for the 4 left-column distro cards (thicker bars `12.0px`), and expand the right-column Desktop Environment (`card1H`) and Display/Graphics Stack (`card2H`) cards with taller segmented bars (`16.0px`) and spaced DE rows (`11.0px` bars).

### 4. Bottom-Right Dash/Dot Pagination & Timer Pill (Option A)
- **Decision**: Repurpose `DrawCarouselNavBar` (or replace it with a dedicated bottom-right renderer called from `DrawResultsOverlay`) positioned at the right edge `rightEdgeX = 1920.0 * 0.95` (`1824.0`), vertically centered on the bottom button bar (`btnY = 1080.0 - 75.0`, `btnHeight = 50.0`, so `pillH = 38.0`, `pillY = btnY + 6.0 = 1011.0`, `pillW = 240.0`, `pillX = rightEdgeX - pillW = 1584.0`).
  - Inside the dark navy cyber-bordered pill (`#131a28` fill, `#2e3d58` border):
    - Left section: 6 interactive indicators vertically centered at `pillY + pillH * 0.5`. The active slide (`i = fActiveSlide`) renders as an elongated cyan pill/dash (`24x8px`, `#38bdf8`), hovered inactive dot renders as a bright slate/white square (`10x8px`), and inactive dots render as muted slate squares (`8x8px`, `#475569`) with `8px` gaps.
    - Divider: A subtle `1px` vertical separator line (`#334155`).
    - Right section: Countdown text (`8s` / `6s` in cyan `#38bdf8`, or `PAUSED` in amber `#fbbf24` when `fIsCarouselHovered` or `fHoveredSideArrow >= 0`).
  - Update `IsCarouselDotHovered` to hit-test each of the 6 dot/dash slots inside this bottom-right pill (`padding` of `+-4px` per slot for easy clicking).

## Risks / Trade-offs

- **[Risk] Hit-box desynchronization on Slide 1 Hardware Comparison or Bottom-Right Dots** → Mitigation: Use identical layout constants in `DrawSlide0_Overview` / `IsHardwareItemHovered` (`cardY = 1.0 * charHeight`, `baseItemH = 2.70 * charHeight`, `expandExtra = 3.10 * charHeight`) and in `DrawCarouselNavBar` / `IsCarouselDotHovered`.
- **[Risk] Methodology `?` popup triggering on Slides 2–6** → Mitigation: Explicitly check `fActiveSlide = 0` inside `IsMethodologyButtonHovered`.
