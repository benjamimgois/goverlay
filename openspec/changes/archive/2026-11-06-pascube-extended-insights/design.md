# Design

## Context

PasCube uses an immediate-mode 2D UI rendering pipeline directly inside the Vulkan benchmark results screen (`UnitPasCubeScreen.pas`) backed by an asynchronous community analytics module (`UnitCommunityInsights.pas`). The initial carousel implementation established a 4-slide structure with timer-based autoplay and manual pill switching. We now expand this structure to 7 dedicated slides, incorporating deep telemetry analysis (points/watt, silicon binning, and gamification) while maintaining 60 FPS UI rendering and strict English text.

## Goals / Non-Goals

**Goals:**
- Implement 7 distinct results slides in exact sequence: Overview, Curve, Silicon, Efficiency, Scaling, Distros, Badges.
- Update `UnitCommunityInsights.pas` to compute silicon lottery metrics, thermal headroom, points per watt, gamification badges, and updated scaling targets (High-End PC, Mid-Range PC, PlayStation 5 Base).
- Implement high-contrast needle (Amber/Gold `#f59e0b`) on the Gaussian curve for clear visibility against the blue background.
- Render Silicon Lottery with dual visualization (dispersion spectrum bar + community leaderboard).
- Render Thermal & Power Efficiency with thermal margin gauges and points/watt architecture spectrum.
- Render Badges in a 3x2 cyber card grid with glowing borders and unlock progression.
- Ensure all mouse hit-testing (accordion, pills, arrows) is mathematically aligned with rendered rectangles.

**Non-Goals:**
- Writing back to remote PasCubeDB servers (submission remains via standard `SubmitResults` action).
- Altering the benchmark Vulkan compute or raster workload loops.

## Decisions

1. **Dual-View Silicon Lottery**:
   - *Decision*: Provide both a continuous dispersion spectrum bar (Min -> Avg -> User Die -> Record) and a mini-leaderboard table on Slide 3.
   - *Rationale*: Enthusiasts want both the macro visual of where their die lands on the silicon quality curve and the exact names/distros of other systems with identical GPUs.
   - *Alternative Considered*: Tabbed toggle between spectrum and leaderboard. Rejected in favor of a clean 2-column layout which displays all information simultaneously without requiring clicks.

2. **Updated Scaling Reference Targets**:
   - *Decision*: In Slide 5 (Scaling), compare the left column against Handhelds (Steam Deck, ROG Ally X, Nintendo Switch 2) and the right column against Desktops & Consoles (High-End Gamer PC, Mid-Range Gamer PC, PlayStation 5 Base).
   - *Rationale*: Directly responds to user instruction and provides realistic comparisons against common gaming baselines.

3. **High-Contrast Bell Curve Needle**:
   - *Decision*: Render the user score indicator on Slide 2 with vibrant Amber/Gold (`$000BF5`, RGB 245, 158, 11) with a distinct dark background badge.
   - *Rationale*: Resolves the user-reported difficulty of discerning a blue needle on a blue histogram background.

4. **Dynamic Header Pills for 7 Slides**:
   - *Decision*: Calculate pill width dynamically based on carousel header width divided by 7, using compact padding and concise labels (`1. Overview`, `2. Curve`, `3. Silicon`, `4. Efficiency`, `5. Scaling`, `6. Distros`, `7. Badges`).
   - *Rationale*: Guarantees all 7 buttons fit neatly without wrapping or clipping across resolutions (1080p, 1440p, 4K).

## Risks / Trade-offs

- **[Screen Real Estate on 1080p]** → Mitigated by using 2-column layouts and compact fonts (9-11pt) formatted cleanly with cyber borders.
- **[Hit-test desynchronization]** → Mitigated by centralizing all Y coordinates relative to `carouselY` formula (`7.45 * charHeight`) used in rendering.
