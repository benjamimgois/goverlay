# Design

## Context

See `proposal.md` for motivation. The Goverlay Performance tab currently houses the MangoHud FPS Limiter, method selector, toggle hotkey, and dynamic FPS color thresholds in Card 0 Left (`FPerfLimitSec`). Card 0 Right (`FPerfVsyncSec`) has only two combobox rows, creating a large visual density imbalance. Relocating `fpscolorCheckBox` and its threshold controls to `FPerfInfoSec` aligns the color alerts directly with the FPS counter display they affect while simplifying `FPerfLimitSec`.

## Goals / Non-Goals

**Goals:**
- Provide a clean, airy, high-contrast Rate Control sub-card focused strictly on frame rate limiting.
- Position quick-preset chips in the section header alongside the title label.
- Provide a full-width or balanced two-column layout for limit, method, and toggle key controls.
- Integrate the FPS color gradient alert controls into the Frame Rate telemetry sub-card without cluttering or clipping.
- Rebalance vertical card heights (`CARD0_H = 160`, `CARD1_H = 210`, `CARD2_H = 250`).

**Non-Goals:**
- Altering the backend serialization logic in `overlayunit.pas` for `fps_limit`, `fps_limit_method`, `toggle_fps_limit`, `fps_color_change`, or `fps_value`.
- Changing the behavior or options of the VSYNC, vkNemu, or Filters sub-cards.

## Decisions

### Decision 1: Homogeneous 3-Column Rate Control Card Architecture
- **Choice**: `FPerfLimitSec` organizes limiter controls into 3 equal-sized columns with identical width (`105px`) and height (`28px`), topped by discrete header presets (`Presets: [60] [120] [144] [Off]`), with subtitle hint and the dynamic FPS color gradient alert bar integrated below:
  - Header Row: `⚡ FPS Limit:` on left, `Presets: [60] [120] [144] [Off]` on right.
  - Controls Row: `FFpsLimitEdit`, `fpslimmetComboBox`, and `FLimitCaptureBtn` sharing identical dimensions (105x28) and aligned labels on Y=36.
  - Subtitle: `e.g. 30,60,120,0 — 0 to unlimited` centered at Y=88.
  - Color Alert Bar: `Change FPS colors` toggle and 3-phase swatches/breakpoints at Y=112..138.
- **Rationale**: Re-establishes a clean, homogeneous visual rhythm in Card 0 while filling vertical space in balance with VSYNC.

### Decision 2: Symmetrical 4x4 Telemetry Cards (Frame Rate & Frame Timing)
- **Choice**:
  - `FPerfInfoSec` (Frame Rate): Contains strictly 4 clean toggles:
    1. `Show FPS`
    2. `FPS Average` + `1% low | 0.1% low` pill right-aligned
    3. `FPS limit` on HUD
    4. `Count frames`
  - `FPerfFrametimeSec` (Frame Timing): Receives `vpsCheckBox` (`Vulkan Pacing`), creating an exact 4-row counterpart:
    1. `Frame Time` toggle + square swatch + `Curve | Histogram` pill right-aligned
    2. `Frame Time +`
    3. `ftrace debug`
    4. `Vulkan Pacing (VPS)`
- **Rationale**: Achieves complete visual and functional symmetry across Card 1. Moves pacing to frame timing where it functionally belongs, removing all clutter from Frame Rate.

### Decision 3: Card Height Rebalancing
- **Choice**:
  - `CARD0_H = 185` (Rate Control & VSYNC).
  - `CARD1_H = 170` (Frame Rate & Frame Timing both having 4 rows).
  - `CARD2_H = 250` (vkNemu and Filters & LOD).
- **Rationale**: Perfectly fills vertical space without any cutting or scroll clipping.

## Risks / Trade-offs

- **[Risk]** Moving controls across parents in LCL can cause handle re-allocation or Z-order issues.
  → **Mitigation**: Update parent assignment in `InitPerformanceTab` during form initialization before first show, ensuring all anchors are cleared.
