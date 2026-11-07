# Tasks

## 1. Full-Height Viewport, Slide 1 Main Score & Hardware Comparison, and Bottom-Right Pagination Pill

- [x] 1.1 Update `DrawResultsOverlay` and `IsCarouselAreaHovered` in `pascube_src/src/UnitPasCubeScreen.pas` to remove the top-anchored `Main Score` and top-right `DrawCarouselNavBar`, expand `carouselY` to `1.0 * charHeight`, and verify that `carouselH` spans down to `y = 970.0`
- [x] 1.2 Redesign `DrawCarouselNavBar` and `IsCarouselDotHovered` in `pascube_src/src/UnitPasCubeScreen.pas` to render the compact bottom-right dash/dot pagination and countdown pill (`[ ━━ ▪ ▪ ▪ ▪ ▪ | Xs ]` / `PAUSED`) aligned with the bottom action buttons and right edge (`x = 1824.0`), and verify dot click hit-testing
- [x] 1.3 Move the `Main Score` hero card (with tier badge and `?` methodology trigger) into the top-left of `DrawSlide0_Overview`, guard `IsMethodologyButtonHovered` with `fActiveSlide = 0`, and expand Slide 1's right-column `Hardware Comparison` card (`DrawSlide0_Overview` and `IsHardwareItemHovered`) to full slide height with increased `baseItemH`, `expandExtra`, and bar thickness

## 2. Full-Height Card and Bar Expansion on Slides 2 to 6

- [x] 2.1 Increase header spacing, KPI card heights, and Gaussian bell curve plot height in `DrawSlide1_BellCurve` (Slide 2) and verify clean vertical layout without overlaps
- [x] 2.2 Increase spectrum bar spacing/thickness, Bin summary strip height, and leaderboard row heights/bars in `DrawSlide2_Silicon` (Slide 3) and verify GPU/CPU columns fill the expanded height cleanly
- [x] 2.3 Increase top efficiency KPI card heights, thermal gauge spacing/thickness, and 5-row efficiency leaderboard heights/bars in `DrawSlide3_Efficiency` (Slide 4) and verify balanced vertical spacing
- [x] 2.4 Increase ladder rung heights, bar thickness, and vertical alignment in `DrawSlide4_Scaling` (Slide 5) and `DrawSlide5_Distros` (Slide 6) (both left distro cards and right DE/stack cards) and compile `pascube` via `lazbuild` to verify zero errors
