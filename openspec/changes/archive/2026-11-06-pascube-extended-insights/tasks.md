# Tasks

## 1. Community Insights Analytics Engine Expansion

- [x] 1.1 Extend `UnitCommunityInsights.pas` data models for dual Silicon Lottery (same-GPU and same-CPU model filtering, rank calculation, average, min, record).
- [x] 1.2 Implement dual Thermal & Power Efficiency calculations (GPU pts/Watt, CPU pts/Watt, GPU headroom vs 90°C throttle limit, CPU headroom vs 95°C TjMax).
- [x] 1.3 Add Linux ecosystem software statistics data models (Desktop Environment popularity, Mesa/Nvidia graphics driver performance deltas, Kernel vs CPU performance deltas).
- [x] 1.4 Update Hardware Performance Scaling targets to compare Handhelds (Steam Deck, ROG Ally X, Nintendo Switch 2) with Desktops & Consoles (High-End Gamer PC, Mid-Range Gamer PC, PlayStation 5 Base).

## 2. UI Carousel Layout & Slide Renderers

- [x] 2.1 Update carousel to 6 slides and render a 6-pill header bar (`1. Overview` through `6. Distros`) with accurate mouse hit-testing and pause-on-hover autoplay.
- [x] 2.2 Update Slide 1 (Curve) with an Amber/Gold high-contrast needle and badge for the user score.
- [x] 2.3 Implement Slide 2 (Silicon) with dual GPU + CPU side-by-side visualization: dispersion spectrum bars (Min, Avg, User Die, Record) and properly bounded verdict boxes.
- [x] 2.4 Implement Slide 3 (Efficiency) with 3 top KPI cards (Total, GPU, CPU pts/W) + dual GPU/CPU thermal headroom gauges and power draw spectrum.
- [x] 2.5 Implement Slide 4 (Scaling) with updated desktop/console references (High-End PC, Mid-Range PC, PlayStation 5 Base) and handhelds using 14px thick progress bars.
- [x] 2.6 Implement Slide 5 (Distros) rendering distro brand badges (`[CY]`, `[AR]`, `[FD]`, `[UB]`) + 3 statistical cards (Desktop Environment popularity, Driver/Vulkan stack delta, Kernel vs CPU delta).
- [x] 2.7 Remove Slide 6 (Badges) from interface and carousel logic.

## 3. Verification, Build & Polish

- [x] 3.1 Verify clean compilation of `pascube_src/pascube.lpi` with `lazbuild` and zero compiler errors.
- [x] 3.2 Verify clean compilation of `goverlay.lpi` with `lazbuild` and zero compiler errors.
- [x] 3.3 Verify all user-facing labels and metrics across all 6 slides are strictly in English and ASCII-safe.
- [x] 3.4 Validate OpenSpec change specification with `openspec validate pascube-extended-insights --strict`.
