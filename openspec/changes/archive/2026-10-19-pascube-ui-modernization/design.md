# Design: PasCube UI Modernization

## Context

PasCube uses an immediate 2D quad overlay system (`TTextOverlay`) powered by a signed distance field (SDF) monospace font and quad-buffer pipeline rendered onto offscreen Vulkan swapchain images at a fixed 1920x1080 virtual resolution. Overlay procedures in `UnitPasCubeScreen.pas` (`DrawMenuOverlay`, `DrawBenchmarkOverlay`, `DrawResultsOverlay`, and `DrawMethodologyOverlay`) position elements relative to screen dimensions and `app.TextOverlay.FontCharWidth` / `FontCharHeight`.

Telemetry data (CPU/GPU temperatures, power draw, and frequencies) is already sampled asynchronously by `TTelemetryThread` during the benchmark phases, but has not been exposed in real time or prominently showcased in final results.

## Goals / Non-Goals

**Goals:**
- Provide a modern dark-mode aesthetic (deep slate/obsidian `#0D1117` / `#161B22` background with `#38BDF8` cyan and `#C084FC` violet accents).
- Render hardware specs summary pills on the idle menu and results screens.
- Implement an in-engine phase stepper (`Warmup` → `CPU ST` → `CPU MT` → `GPU` → `RT`) and live floating telemetry card during benchmark execution.
- Create a Hero Score card with dynamic Tier Badges (*Enthusiast*, *Mainstream*, *Entry/Handheld*) on results.
- Showcase peak hardware telemetry (maximum temperatures and peak power wattage) in a dedicated result card.
- Modernize the Score Trend chart with run-to-run delta percentage indicators and sleek hardware leaderboard cards.

**Non-Goals:**
- Modifying benchmark scoring algorithms, run durations, or physics engine mechanics.
- Replacing the SDF font pipeline or introducing external vector graphics dependencies.
- Changing CLI arguments or Goverlay launcher invocation syntax.

## Decisions

### 1. Unified Card & Badge Styling Helpers
- **Rationale**: Instead of repeating ad-hoc `AddBox` color parameters across multiple methods, define helper procedures within `TPasCubeScreen`:
  - `DrawStyledCard(x, y, w, h, isHighlighted)`: renders glassmorphism surfaces with semi-transparent dark slate fills and subtle cyan/blue-grey borders.
  - `DrawPillBadge(x, y, text, r, g, b)`: renders compact rounded status chips for tiers and specs.
- **Alternatives considered**: Inline color definitions as currently done. Rejected because inconsistent color adjustments cause visual fragmentation.

### 2. Tier Classification Logic
- **Rationale**: Benchmark scores are grouped into recognizable gaming categories to give users immediate context on their machine's capability:
  - `Score >= 4,000`: **Enthusiast Gaming** (Bright Cyan/Gold badge)
  - `Score 2,200 .. 3,999`: **Mainstream Gaming** (Sky Blue badge)
  - `Score < 2,200`: **Entry / Handheld** (Slate/Emerald badge)
- **Alternatives considered**: Continuous percentile ranking against online database. Deferred until online database API provides live percentile endpoints.

### 3. Live HUD Layout During Execution
- **Rationale**: During stress phases (`bpGPU_1080p`, `bpRT_1080p`), the center of the screen must remain uncluttered for visual inspection of rendered cubes.
  - Phase Stepper placed horizontally along the top (`y = 40.0`).
  - Live Telemetry Card anchored in the top-right corner (`x = 1920 - 360`, `y = 40.0`).
  - Progress bar and phase details anchored near the bottom (`y = 1080 - 100`).
- **Alternatives considered**: Centered HUD overlay. Rejected because it occludes central 3D cube animations.

## Risks / Trade-offs

- **[Quad Buffer Limit]** Adding extra cards and text quads could increase buffer utilization.
  → *Mitigation*: The text overlay buffer size is 65,536 quads (`TextOverlayBufferCharSize = 65536`). All new HUD and result elements collectively consume under 400 quads (< 1% of capacity).
- **[Hardware Telemetry Availability]** Some systems lack hwmon permissions or NVIDIA drivers.
  → *Mitigation*: Graceful fallbacks display "N/A" for missing sensor values without shifting card alignments.
