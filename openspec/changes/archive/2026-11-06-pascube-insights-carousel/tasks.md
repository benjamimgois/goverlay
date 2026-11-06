# Tasks: PasCube Community Insights Carousel

## 1. Community Data Layer & Background Sync

- [x] 1.1 Embed static fallback community dataset (`FALLBACK_COMMUNITY_CSV`) and verify parsing populates valid baseline stats without network access
- [x] 1.2 Implement `TCommunitySyncThread` in `UnitPasCubeScreen.pas` to asynchronously retrieve PasCubeDB submissions and write cache to `~/.cache/goverlay/pascubedb_cache.csv`, verifying non-blocking execution
- [x] 1.3 Implement statistical analysis routines (mean, standard deviation, Gaussian PDF sampling, percentile ranking, and GPU-specific distro aggregation) and verify math against reference scores

## 2. Results Overlay Shell & Carousel Engine

- [x] 2.1 Refactor `DrawResultsOverlay` in `UnitPasCubeScreen.pas` to separate the anchored shell (top hero score header and bottom action buttons) from the central carousel viewport
- [x] 2.2 Implement carousel timing controller (`fActiveSlide`, `fSlideTimer`, `fSlideDuration`, `fSlideTransitionT`, cubic easing) and verify automated progression
- [x] 2.3 Implement top-right pagination indicator dots (`● ○ ○ ○`), smooth time progress bar, and hover hit-testing to pause timer when cursor enters central bounds

## 3. Specialized Insights Slide Renderers

- [x] 3.1 Wrap existing results cards (Subscores, Live Telemetry, Score Trend, Hardware Comparison) into Slide 0 and verify rendering integrity
- [x] 3.2 Implement Slide 1 (Gaussian Distribution Bell Curve & Percentile Pin) with vector curve fill and percentile text, verifying visual layout
- [x] 3.3 Implement Slide 2 (Hardware Scaling Multipliers) showing comparative speedups vs. Steam Deck, ROG Ally, and #1 High-End PC, verifying multiplier formatting
- [x] 3.4 Implement Slide 3 (Linux Distribution Breakdown for User's GPU) showing ranked distro percentage bars with matching GPU filtering, verifying fallback when GPU is rare

## 4. Compilation & Verification

- [x] 4.1 Compile `pascube` binary with `lazbuild` and verify zero compilation errors or linking regressions
- [x] 4.2 Run end-to-end benchmark execution in PasCube to verify smooth slide cross-fades, hover-pause, and interactive pagination in the results overlay
