# Proposal

## Why

CPU and GPU load colors in MangoHud (`cpu_load_color` and `gpu_load_color`) inadvertently reset to all-white across all three load thresholds due to `ResetMangoHudControls` assigning `clWhite` to all color controls, while color preset themes ("MangoHud Stock", "Goverlay", "Simple white", "Old afterburner") only updated the low-load swatch (`load1`), leaving medium (`load2`) and high (`load3`) load swatches unassigned. Furthermore, the GOverlay color theme should showcase GOverlay's signature cyan accent color (`#30BEF0`) for low load instead of plain white.

## What Changes

- **Constants Definition**: Add semantic constants in `constants.pas` for load colors:
  - `COLOR_LOAD_WHITE` (`clWhite` / `$00FFFFFF`)
  - `COLOR_LOAD_ORANGE` (`8366847` / `$007FABFF`)
  - `COLOR_LOAD_RED` (`204` / `$000000CC`)
  - `COLOR_GOVERLAY_CYAN` (`$00F0BE30` / RGB(48, 190, 240))
- **Reset Defaults**: Update `ResetMangoHudControls` in `mangohud_ui.pas` to set default CPU and GPU load colors to White, Orange, and Red.
- **Preset Theme Mappings**: Update color theme button handlers in `overlayunit.pas`:
  - **MangoHud Stock** (`mangocolorBitBtnClick`): Low = White, Med = Orange, High = Red.
  - **Goverlay** (`goverlayBitBtnClick`): Low = GOverlay Cyan (`$00F0BE30`), Med = Orange, High = Red.
  - **Simple White** (`whitecolorBitBtnClick`): Low = White, Med = White, High = White.
  - **Old Afterburner** (`afterburnercolorBitBtn1Click`): Low = Pink (`clFuchsia`), Med = Pink, High = Pink.
- **Automated Tests**: Add test cases covering preset color application and reset states for both GPU and CPU load color swatches.

## Capabilities

### New Capabilities
- `mangohud-load-colors-presets`: Governs the initialization, reset defaults, and preset theme mappings for CPU and GPU load color thresholds in MangoHud.

### Modified Capabilities

## Impact

- `constants.pas`: Definition of load and accent color constants.
- `overlayunit.pas`: Preset theme click handlers (`mangocolorBitBtnClick`, `goverlayBitBtnClick`, `whitecolorBitBtnClick`, `afterburnercolorBitBtn1Click`).
- `mangohud_ui.pas`: Default control reset logic in `ResetMangoHudControls`.
- `tests/`: New logic/gui tests verifying load color preset mappings.
