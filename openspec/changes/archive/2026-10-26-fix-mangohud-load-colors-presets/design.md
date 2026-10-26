# Design

## Context

In `mangohud_ui.pas`, `ResetMangoHudControls` assigns `clWhite` across all 6 load color swatches (`gpuload1..3ColorButton` and `cpuload1..3ColorButton`). Additionally, the four preset click handlers in `overlayunit.pas` (`mangocolorBitBtnClick`, `goverlayBitBtnClick`, `whitecolorBitBtnClick`, and `afterburnercolorBitBtn1Click`) only set the first swatch (`load1`), leaving `load2` and `load3` unassigned and stuck at white.

See `proposal.md` for full motivation.

## Goals / Non-Goals

**Goals:**
- Provide named constants in `constants.pas` for load color thresholds and the GOverlay brand cyan accent.
- Ensure `ResetMangoHudControls` initializes CPU and GPU load colors to MangoHud Stock defaults (White, Orange, Red).
- Ensure all 4 color theme presets update all 3 swatches for both CPU and GPU according to their thematic definition:
  - **MangoHud Stock**: White, Orange, Red
  - **Goverlay**: GOverlay Cyan (`$00F0BE30`), Orange, Red
  - **Simple White**: White, White, White
  - **Old Afterburner**: Pink (`clFuchsia`), Pink, Pink
- Add automated logic and GUI test coverage for preset mappings and reset states.

**Non-Goals:**
- Changing file persistence logic (`cpu_load_color` and `gpu_load_color` serialization).
- Altering load threshold percentages (50%, 90%).

## Decisions

### Decision 1: Centralized Load and Accent Constants
- **Approach**: Declare named constants in `constants.pas`:
  ```pascal
  COLOR_LOAD_LOW   = clWhite;   // Low load (< 50%): White ($00FFFFFF)
  COLOR_LOAD_MED   = 8366847;   // Medium load (50 - 90%): Orange ($7FABFF)
  COLOR_LOAD_HIGH  = 204;       // High load (> 90%): Red ($000000CC)
  COLOR_GOVERLAY_CYAN = $00F0BE30; // Brand cyan accent: RGB(48, 190, 240)
  ```
- **Rationale**: Eliminates magic numbers across `mangohud_ui.pas`, `overlayunit.pas`, and test suites.

### Decision 2: Thematic Load Colors per Preset
- **Approach**: In `overlayunit.pas`:
  - `mangocolorBitBtnClick`: Set swatches to `COLOR_LOAD_LOW`, `COLOR_LOAD_MED`, `COLOR_LOAD_HIGH`.
  - `goverlayBitBtnClick`: Set swatches to `COLOR_GOVERLAY_CYAN`, `COLOR_LOAD_MED`, `COLOR_LOAD_HIGH`.
  - `whitecolorBitBtnClick`: Set swatches to `clWhite`, `clWhite`, `clWhite`.
  - `afterburnercolorBitBtn1Click`: Set swatches to `clFuchsia`, `clFuchsia`, `clFuchsia`.
- **Rationale**: Gives each theme a distinct and cohesive visual appearance while restoring expected behavior.

## Risks / Trade-offs

- **[Risk] Existing user configs with custom load colors**:
  → **Mitigation**: `LoadMangoHudConfig` continues to read and apply user-saved `cpu_load_color` and `gpu_load_color` values from file, overriding defaults when present.
