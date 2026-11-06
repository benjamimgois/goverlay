# Proposal: PasCube Community Insights Carousel

## Why

The current PasCube benchmark results screen is static and only displays instantaneous numbers and a fixed list of reference systems. By integrating community telemetry from PasCubeDB into an animated, multi-slide carousel in the central region of the results screen, users gain immediate context on where their hardware stands in the Linux gaming ecosystem (percentile rank, handheld/high-end scaling factors, and popular distributions for their specific GPU) without losing access to primary scores or action buttons.

## What Changes

- **Preserved Results Shell**: Keep the top hero score header (Main Score + Performance Tier) and the bottom action controls (`RETURN TO MENU`, `SUBMIT RESULTS`, `CLEAR RESULTS`) permanently anchored on screen.
- **Dynamic Multi-Slide Carousel**: Transform the central viewport of the results screen into an animated carousel displaying 4 distinct slides:
  - **Slide 0 (Detailed Breakdown)**: The classic full view (Single/Multi-Thread, GPU Raster, Ray Tracing, Telemetry, Trend, and Hardware Leaderboard).
  - **Slide 1 (Global Distribution Curve)**: A Gaussian bell curve plotted from PasCubeDB main scores showing community mean and the user's exact percentile rank.
  - **Slide 2 (Hardware Scaling Factors)**: Direct comparative multipliers against handhelds (Steam Deck, ROG Ally) and the #1 global high-end configuration.
  - **Slide 3 (Distro Popularity Breakdown)**: Ranked distribution breakdown showing the most popular Linux distributions running the user's GPU model.
- **Carousel Controls & Auto-Advance**: Smooth auto-advancing timer bar with interactive pagination dots (`● ○ ○ ○`) and automatic hover-pause to allow leisurely reading.
- **Fluid Visual Transitions**: Implement cubic easing (`EaseOutQuad`/`SmoothStep`) for rapid, fluid transitions and cross-fade effects between slides at high frame rates.
- **Resilient Data Architecture**: Asynchronous background synchronization with PasCubeDB with local caching in `~/.cache/goverlay/` and a bundled offline fallback dataset, ensuring immediate rendering even without an active internet connection.

## Capabilities

### New Capabilities
- `pascube-community-insights`: Fetches, caches, and calculates community-wide benchmark statistics from PasCubeDB (normal distribution metrics, percentile position, hardware scaling multipliers, and distribution share by GPU) with guaranteed offline fallback resilience.

### Modified Capabilities
- `pascube-ui-presentation`: Updates the benchmark results screen layout to embed a responsive, timed, animated carousel in the central viewport with pagination dots, progress indicator, and hover-pause mechanics while preserving the top score header and bottom action button bar.

## Impact

- **pascube_src/src/UnitPasCubeScreen.pas**: Results overlay rendering logic, animation update cycle, slide state management, mouse hit-testing for pagination controls, and community dataset statistical processing.
- **Network / Threading**: Non-blocking background thread (`TBenchmarkSyncThread`) to query PasCubeDB and manage local cache without hitching the main Vulkan render loop.
- **Assets / Fallback**: Bundled fallback dataset within PasCube to guarantee flawless offline operation.
