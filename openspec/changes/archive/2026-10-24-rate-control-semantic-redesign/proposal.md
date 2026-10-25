# Proposal

## Why

The current Rate Control section in the Performance tab attempts to combine active frame rate limiting (`fps_limit`, `fps_limit_method`, toggle hotkey) with passive HUD telemetry aesthetics (`Change FPS colors` gradient thresholds) inside a single compact card. This creates visual clutter, broken alignment baselines, and cramped inputs. Relocating the FPS color gradient thresholds to the adjacent Frame Rate telemetry card (where `Show FPS` and `FPS Average` are configured) restores semantic purity to Rate Control, giving the FPS limiter the dedicated, clean, and spacious presentation it warrants.

## What Changes

- **Rate Control Semantic Purification**: Focus the Rate Control sub-card exclusively on active rate-limiting controls:
  - Top header row: `⚡ FPS Limit:` on the left with discrete quick-preset chips (`60`, `120`, `144`, `Off`) aligned on the right.
  - Primary Hero Input: Wide `fps_limit` text field supporting comma-separated values with clear subtitle hint.
  - Secondary Row: Symmetrical two-column pairing for `Method` (`Late*` / `Early`) and `Limit toggle key` (`⌨ Hotkey Capture`).
- **Telemetry Color Threshold Relocation**: Move `Change FPS colors` toggle and the 3-phase color threshold swatches/spin edits into the `Frame Rate` telemetry card (`FPerfInfoSec`), directly associating counter color changes with the FPS counter itself.
- **Visual Baseline Balance**: Eliminate floating labels and misaligned rows in Card 0, providing harmonious symmetry with the neighboring VSYNC card.

## Capabilities

### Modified Capabilities
- `mangohud-limiters-ui`: Scope the Rate Control card to active limiter controls (presets, input, method, toggle key) and relocate the color gradient thresholds to the Frame Rate telemetry section.
- `mangohud-performance-modular-ui`: Update the sub-card layout and component distribution across Card 0 (Rate Control) and Card 1 (Frame Rate telemetry).

## Impact

- `mangohud_ui.pas`:
  - Reparent `fpscolorCheckBox`, `fpscolor1..3ColorButton`, and `fpscolor2..3SpinEdit` to `FPerfInfoSec`.
  - Adjust layout positioning in `ReflowPerformanceTab` for `FPerfLimitSec` and `FPerfInfoSec`.
- Configuration persistence (`mangohud.conf`) remains 100% backward-compatible and unchanged.
