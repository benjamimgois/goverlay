# Proposal: Refine Metrics Color and Format Chips

## Why
On the MangoHud Metrics tab, secondary controls such as load gradient threshold colors and metric indicators (`VRAM`, `RAM`, `Disk IO`) are rendered with a flat 14px height (`18x14` and `24x14`), making them look like crushed horizontal dashes (`[- - -]`) rather than distinct color swatches. Furthermore, format buttons (`Frames / Joule`, `Percent`, `Intel Power Fix`) lack modern styling, and the three load color buttons lack descriptive tooltips indicating their respective threshold bands (Low, Medium, High).

Transforming these elements into proportional color chips (`20x20` px) with clear tooltips and modernizing format buttons into pill-styled controls enhances visual clarity and UX affordance across the Metrics tab.

## What Changes
- Enlarge secondary color indicator buttons (`gpuload1/2/3ColorButton`, `cpuload1/2/3ColorButton`, `vramColorButton`, `ramColorButton`, `iordrwColorButton`) to proportional `20x20` chips with 4px rounded corners.
- Add descriptive tooltips to load color thresholds in `hintsunit.pas`:
  - Threshold 1: Low load color (< 50%)
  - Threshold 2: Medium load color (50% - 80%)
  - Threshold 3: High load color (> 80%)
- Add descriptive tooltips for `vramColorButton`, `ramColorButton`, and `iordrwColorButton`.
- Modernize format button styling in `StyleBitBtnTheme` with enhanced pill borders (`border-radius: 6px`), padding, and theme colors.

## Capabilities

### Modified Capabilities
- `mangohud-metrics-modular-ui`: Extends inline secondary control integration to require distinct, proportional color chips and semantic tooltips.

## Impact
- **Affected Code**: `mangohud_ui.pas` (geometry bounds and styling), `hintsunit.pas` (tooltips), `themeunit.pas` (`StyleBitBtnTheme`).
- **Dependencies/APIs**: None.
- **Breaking Changes**: None.
