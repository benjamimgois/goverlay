# Proposal

## Why

The current Performance tab in Goverlay suffers from major visual asymmetry, rigid vertical sizing without a scrollbox, and ergonomic bottlenecks. While the FPS Limiter is the most frequently accessed tool by players, it is currently buried below the fold in a cramped sub-card alongside vkNemu, while VSYNC and Filters leave large areas of empty space. Following the modular redesign successfully implemented in the Metrics and Visual tabs, the Performance tab needs a cohesive 3-card modular layout that elevates the FPS Limiter to the top position, gives vkNemu a dedicated autonomous module presence, and balances telemetry and graphics filters.

## What Changes

- **Add TScrollBox Architecture**: Wrap the Performance tab in a modern responsive `TScrollBox` (`FPerfScrollBox`) with `PresetsWrapperPaint` and dynamic reflow, replacing hardcoded row heights.
- **Top Card: Rate Control & Synchronization (FPS Limiter + VSYNC)**:
  - Elevate the MangoHud FPS Limiter to Card 1 (top of the tab) as the primary control surface.
  - Introduce quick-preset click chips (`60`, `120`, `144`, `Off`) alongside the freeform comma-separated input field.
  - Modernize the dynamic FPS color gradient into an inline horizontal bar with integrated color swatches and aligned threshold inputs.
  - Pair the FPS Limiter with modernized Vulkan and OpenGL VSYNC cards displaying clear mode descriptions (e.g. Mailbox, Adaptive, FIFO) and latency guidance.
- **Middle Card: Telemetry & HUD Graphics**:
  - Sub-card 1: Frame Rate Display (`fps`, `fps_avg` with `1% Low` segmented dual-pill, `show_fps_limit`, `frame_count`, `vps`).
  - Sub-card 2: Frame Timing & Plots (`frametime` graph with color swatch, `Curve | Histogram` segmented dual-pill, detailed frametime `+`, and `ftrace` kernel tracing).
- **Bottom Card: Energy Saving (vkNemu) & Visual Optimization**:
  - Sub-card 1: vkNemu Autonomous Idle Limiter with breathing room for the state transition flow diagram (`In-Game` -> `Idle (30 FPS)` -> `Instant Resume`), sensitivity grid (Idle FPS, Timeout, Wake Trigger, Delay), and window unfocus cap toggle.
  - Sub-card 2: Texture & Mipmap LOD Filters with segmented pill mode selector (`Off`, `Bilinear`, `Trilinear`, `Anisotropic`) and responsive sliders with real-time value badges for Anisotropic Filtering (0-16x) and Mipmap Bias (-4.0 to +4.0).

## Capabilities

### New Capabilities
- `mangohud-performance-modular-ui`: Defines the 3 master cards architecture (`Rate Control & Sync`, `Telemetry & HUD Plots`, `Energy & Visual Optimization`), symmetrical sub-card pairs, and the responsive scroll container on the Performance tab.

### Modified Capabilities
- `mangohud-limiters-ui`: Updates the FPS Limiter presentation requirements to include quick preset chips, inline color gradient swatches with threshold inputs, and top-card placement.

## Impact

- Affected code: `mangohud_ui.pas` (`InitPerformanceTab`, `ReflowPerformanceTab`, layout helpers), `overlayunit.pas` / `overlayunit.lfm` (container reparenting and event bindings).
- No breaking changes to MangoHud configuration files or vkNemu daemon parameters (`mangohud.conf` and `vknemu.conf` options remain fully compatible).
