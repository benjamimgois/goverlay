# Design: PasCube Community Insights Carousel

## Context

PasCube operates as a standalone Vulkan 1.3 application based on the PasVulkan engine. Rendering is handled primarily in `UnitPasCubeScreen.pas` with UI elements and vector text composited through `UnitTextOverlay.pas`. Currently, when the benchmark reaches the `bpResults` phase, it displays a single static dashboard showing subscores, sensor telemetry, and hardcoded hardware comparison entries (`THardwareRef`).

See `proposal.md` for motivation and `specs/` for behavioral requirements.

## Goals / Non-Goals

**Goals:**
- Provide a responsive multi-slide carousel in the central region of the results view.
- Anchor the top hero score header and bottom action button bar so they remain persistently visible and interactive across all slides.
- Implement an automated timing mechanism (8s on Slide 0, 6s on slides 1-3) with a visual progress bar and automatic pause on mouse hover.
- Support manual click navigation via pagination indicator dots (`● ○ ○ ○`).
- Fetch community benchmark submissions asynchronously via `TCommunitySyncThread` without hitching the 60+ FPS Vulkan presentation loop.
- Support local cache storage in `~/.cache/goverlay/pascubedb_cache.csv` with instant fallback to embedded offline statistics.
- Render high-performance 2D vector data visualizations (Gaussian bell curve, comparative scaling cards, and distro bar charts) using existing `UnitTextOverlay` primitives.

**Non-Goals:**
- Interactive database filtering, sorting, or searching within the PasCube in-engine results overlay.
- Replacing the existing benchmark score submission flow (`TSubmitThread`).
- Full web view embedding inside the native Vulkan engine.

## Decisions

### 1. Central Carousel Viewport Framing
- **Decision**: Keep top boundary `Y1 ≈ 3.8 * charHeight` and bottom boundary `Y2 ≈ 1080.0 - 4.5 * charHeight`. The hero score card stays at the top, and `RETURN TO MENU`, `SUBMIT RESULTS`, `CLEAR RESULTS` remain at the bottom.
- **Rationale**: Keeps primary navigation and primary score visible at all times, preventing user disorientation when slides transition.
- **Alternatives Considered**: Fullscreen slide replacement (rejected because users lose visibility of action buttons and may feel interrupted while reviewing core scores).

### 2. Carousel State Management and Easing
- **Decision**: Introduce carousel state variables in `TPasCubeScreen`:
  ```pascal
  fActiveSlide: Integer;          // 0 = Overview, 1 = Bell Curve, 2 = Scaling, 3 = Distros
  fTargetSlide: Integer;
  fSlideTimer: TpvFloat;          // Elapsed time in current slide
  fSlideDuration: TpvFloat;       // 8.0s for slide 0, 6.0s for others
  fSlideTransitionT: TpvFloat;    // 0.0 to 1.0 animation progress
  fIsCarouselHovered: Boolean;    // Pauses timer when true
  ```
  Transitions will utilize cubic easing:
  $$\text{easeOutQuad}(t) = 1.0 - (1.0 - t)^2$$
  to cross-fade alpha and apply subtle horizontal displacement ($\Delta X = \pm 40\text{px}$) during changes.
- **Rationale**: Smooth, non-linear easing creates a polished, high-refresh-rate gaming UI feel.

### 3. Asynchronous Data Ingestion and Local Caching
- **Decision**: Implement a background thread `TCommunitySyncThread` inheriting from `TThread`.
  - Runs upon application startup or at benchmark completion.
  - Checks if `~/.cache/goverlay/pascubedb_cache.csv` exists and is fresher than 24 hours.
  - If outdated, attempts to fetch `SPREADSHEET_URL` using curl in a detached process.
  - Parses the CSV into an internal structure `TCommunityStats` (Total submissions, Mean Score, StdDev, GPU-to-Distro map).
  - If network fails or user is offline, immediately parses an embedded baseline string constant `FALLBACK_COMMUNITY_CSV`.
- **Rationale**: PasCube must never stall or drop frames due to HTTP network latency.

### 4. Vector Bell Curve and Bar Chart Rendering
- **Decision**:
  - **Normal Distribution Curve**: Sample 30 to 40 points using standard Gaussian PDF:
    $$f(x) = \frac{1}{\sigma \sqrt{2\pi}} \exp\left(-\frac{1}{2}\left(\frac{x - \mu}{\sigma}\right)^2\right)$$
    Renders interconnected line segments and subtle vertical bars with neon cyan gradient fill using `AddBox`.
  - An animated marker pin highlights the user's score on the $X$ axis.
  - **Horizontal Bars**: Render rounded rectangular pills using existing `AddBox` and `AddText` methods from `UnitTextOverlay`.

## Risks / Trade-offs

- **[Risk] High CSV parsing overhead in Pascal** → **Mitigation**: Parse only relevant columns (`Main Score`, `GPU`, `Operating System`) in the background thread. Once processed, store summary scalar values in memory so render frames execute in $< 0.1\text{ms}$.
- **[Risk] User interaction conflict with auto-advance** → **Mitigation**: Immediate pause when mouse enters the central bounds (`[cx - 45%, cy - 35%]`), plus instant jump when clicking any pagination dot.
- **[Risk] GPU name mismatch across drivers and kernel releases** → **Mitigation**: Normalize GPU string before matching (e.g. stripping vendor strings, lowercase comparison, matching chip model like `7900 xtx`, `4070`, `6700 xt`). If no GPU match is found, fallback to all-GPU distribution stats.
