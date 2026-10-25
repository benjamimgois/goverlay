# Design

## Context

The Goverlay Performance tab currently uses hardcoded row heights with static anchors and no scrollbox (`ROW1_H = 180`, `BASE_ROW2_H = 389`), causing severe visual imbalance between dense and sparse sections. vkNemu is currently crammed inside the lower half of the Limiters card, while VSYNC and Filters leave substantial empty negative space. Following the architectural pattern established in the Metrics tab (`InitMetricsTab` / `ReflowMetricsTab`), we will refactor the Performance tab to use a modern `TScrollBox` host, three dedicated master cards, and symmetrical sub-cards.

## Goals / Non-Goals

**Goals:**
- Provide a smooth, responsive, scrollable container (`FPerfScrollBox` + `FPerfBgPanel`) that eliminates vertical clipping across different screen resolutions and display scalings.
- Elevate the MangoHud FPS Limiter to the top card as the primary user control, enriched with quick-preset chips (`60`, `120`, `144`, `Off`) and an integrated inline color gradient bar.
- Reposition VSYNC side-by-side with the FPS Limiter in Card 1 to form a unified Rate Control & Synchronization hub.
- Group HUD telemetry in Card 2 with distinct sub-cards for Frame Rate metrics and Frametime plots/graphs (incorporating segmented dual-pills).
- Establish vkNemu in Card 3 with its state transition flow diagram given full breathing room alongside Texture & Mipmap LOD Filters.

**Non-Goals:**
- Modifying underlying backend serialization or parser logic for `mangohud.conf` or `vknemu.conf`.
- Changing the underlying behavior of vkNemu daemon or ftrace kernel triggers.

## Decisions

### Decision 1: ScrollBox Architecture with Adaptive Content Height
- **Choice:** Create `FPerfScrollBox: TScrollBox` filling `performanceTabSheet` with `alClient`, hosting `FPerfBgPanel: TPanel` painted via `PresetsWrapperPaint`.
- **Rationale:** Aligns with the Metrics and Visual tabs. Prevents controls from overflowing on 768p or scaled screens and maintains background painting uniformity without Qt6 GroupBox border artifacts.
- **Alternatives Considered:** Keeping fixed row anchors. Rejected because it causes control collisions and cannot scale gracefully as new features are added.

### Decision 2: Card Hierarchy & Thematic Grouping
- **Choice:** Three master cards with two equal-width sub-cards each:
  1. `FPerfCards[0]`: Rate Control & Synchronization (`FPerfLimitSec` + `FPerfVsyncSec`)
  2. `FPerfCards[1]`: Telemetry & HUD Graphics (`FPerfFpsSec` + `FPerfFrametimeSec`)
  3. `FPerfCards[2]`: Energy Saving & Visual Optimization (`FPerfNemuSec` + `FPerfFiltersSec`)
- **Rationale:** Reflects the user's workflow priority (Rate Limiting is most used -> Top). Balances visual density with 3-5 controls per sub-card and zero awkward negative space.
- **Alternatives Considered:** 2x2 grid with full-width bottom card. Rejected because 3 stacked pairs maintain visual rhythm and consistent height rhythm across the entire Goverlay application.

### Decision 3: FPS Limiter Quick Preset Chips & Inline Gradient
- **Choice:** Implement quick-preset click chips above the freeform comma-separated edit field, and refactor the 3-color threshold selector into a horizontal flex-style row with interactive swatches and centered numeric inputs.
- **Rationale:** Dramatically accelerates everyday configuration (clicking `60` or `144` is instantaneous) while preserving power-user comma-separated toggles (e.g. `60, 120`).

### Decision 4: Segmented Dual-Pill Controls
- **Choice:** Apply `dual-pill` button components to `1% Low` / `0.1% Low` and `Curve` / `Histogram` selections.
- **Rationale:** Matches the segmented pill pattern introduced in `mangohud-metrics-modular-ui` for format selectors, providing immediate visual feedback of active options.

### Decision 5: Row-Based Settings Pattern for Telemetry & Frametime
- **Choice:** Telemetry & HUD Graphics (`FPerfInfoSec` and `FPerfFrametimeSec`) adopt full-width row layouts (`ClientWidth - 28px`), with descriptive labels on the left, optional inline pills (`fpsavgBitBtn`, `frametimetypeBitBtn`) or swatches (`frametimegraphColorButton`), and toggle switches (`TToggleSwitch`) anchored to the far right.
- **Rationale:** Eliminates the two-column split (`Col1X`/`Col2X`) inside ~360px sub-cards, giving every setting full breathing room and completely preventing pill/toggle collisions.

### Decision 6: Stacked Form Layout for vkNemu (Idle Limiter)
- **Choice:** The 2x2 grid in `FVkNemuSec` adopts a stacked pattern: labels are placed directly above their corresponding inputs (`FVkNemuIdleFpsSpin`, `FVkNemuTimeoutSpin`, `FVkNemuInputCombo`, `FVkNemuDelaySpin`). Controls fill their half-column width with 12px vertical spacing between rows.
- **Rationale:** Prevents horizontal collisions where labels and spinboxes touched or were truncated. Allows inputs to maintain readable widths and comfortable click targets.

## Risks / Trade-offs

- **[Risk]** Dynamic reparenting of existing LFM controls could break legacy event handlers or visibility checks.
  → **Mitigation:** Retain all original control references and event bindings; only clear LCL anchor chains (`AnchorSide*.Control := nil`) and set explicit bounds during `ReflowPerformanceTab`.
- **[Risk]** vkNemu flow card canvas repaint might flicker during scroll or resize.
  → **Mitigation:** Ensure `DoubleBuffered := True` on `FVkNemuFlowCard` and only trigger `UpdateVkNemuFlowDiagram` on value changes or resize.
