# Design: Refine Metrics Color and Format Chips

## Context
See `proposal.md` for motivation. On the Metrics tab, secondary color buttons are embedded inline next to toggles in `mangohud_ui.pas`. Currently, their bounds (`18x14` and `24x14`) crush them into thin dashes, and they lack descriptive tooltips. Format buttons also share generic rectangular button stylesheets.

## Goals / Non-Goals

**Goals:**
- Resize secondary color buttons to square `20x20` px swatches with rounded appearance.
- Align swatches precisely on the vertical center of the toggle baseline (`R2Y`, `R3Y`).
- Add descriptive tooltips to load color thresholds and individual metric swatches in `hintsunit.pas`.
- Ensure format buttons (`Frames / Joule`, `Percent`, `Power Fix`) have modern rounded corners (`border-radius: 6px`).

**Non-Goals:**
- Changing MangoHud config options or parsing logic.
- Adding complex multi-color popup pickers beyond the native LCL `TColorButton`.

## Decisions

### Decision 1: Sizing and Spacing of Color Swatches
- **Choice**: `Width := 20; Height := 20;` with 4px horizontal gap between sequential buttons.
- **Rationale**: 20x20px matches the 20px height of `TToggleSwitch` controls, creating a balanced visual baseline. It converts flat lines into tactile, clickable color chips.

### Decision 2: Contextual Tooltips in `hintsunit.pas`
- **Choice**:
  - `gpuload1ColorButton` / `cpuload1ColorButton`: "Low load color (< 50%)"
  - `gpuload2ColorButton` / `cpuload2ColorButton`: "Medium load color (50% - 80%)"
  - `gpuload3ColorButton` / `cpuload3ColorButton`: "High load color (> 80%)"
  - `vramColorButton`: "VRAM text color in HUD"
  - `ramColorButton`: "RAM text color in HUD"
  - `iordrwColorButton`: "Disk I/O read/write text color in HUD"
- **Rationale**: Eliminates guesswork regarding which color swatch affects which load band or telemetry line.

### Decision 3: Refined Button Styling
- **Choice**: In `themeunit.pas` (`StyleBitBtnTheme`), enhance button border-radius from 4px to 6px and optimize padding (`padding: 2px 8px;`) for compact inline integration.
- **Rationale**: Gives buttons a smooth, chip-like appearance matching modern UI trends.

## Risks / Trade-offs

- **Risk**: Expanding swatch width by a few pixels could collide with adjacent column controls on narrow sizes.
  - **Mitigation**: `Col1X` (12) + `Toggle.Width` (~90) + `3 * (20 + 4)` (~72) = ~174px, comfortably below `Col2X` (~250px on standard resolutions).
