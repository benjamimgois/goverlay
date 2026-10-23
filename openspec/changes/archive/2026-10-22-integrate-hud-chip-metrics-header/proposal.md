# Proposal: Integrate HUD Chip Metrics Header

## Why
In the modern redesign of the MangoHud Metrics tab, the custom hardware name input fields (`gpunameEdit` and `cpunameEdit`) and their respective line color pickers (`gpuColorButton` and `cpuColorButton`) are placed as isolated, centered controls in the card headers. This placement creates visual disconnection and cognitive friction: users are unsure whether the text renames the card, overrides hardware detection, or modifies in-game HUD telemetry, while the color button appears detached from its associated text.

Transforming these elements into a unified, semantically clear "HUD Chip" (Variação 1B: color bullet on the left + name input with intelligent hint + "HUD" tag suffix) grounds their purpose as the in-game display line configuration while preserving the clean aesthetics of the card headers.

## What Changes
- Unify `gpunameEdit` and `gpuColorButton` in `FMtGpuCard` header into a styled HUD Chip pill:
  - Color indicator button (`gpuColorButton`) anchored on the left (22x22).
  - Text input (`gpunameEdit`) positioned adjacent to the color button with placeholder `Default (GPU)`.
  - Subtle `HUD` tag suffix label on the right.
- Unify `cpunameEdit` and `cpuColorButton` in `FMtCpuCard` header into an identical HUD Chip pill:
  - Color indicator button (`cpuColorButton`) on the left (22x22).
  - Text input (`cpunameEdit`) adjacent to the color button with placeholder `Default (CPU)`.
  - Subtle `HUD` tag suffix label on the right.
- Refine container styling (`LimitSubCardPaint`) and responsive layout calculations in `ReflowMetricsTab` so the chip centers cleanly between the card title and vendor logo without overlaps across different window widths.
- Update tooltips in `hintsunit.pas` to clearly explain that these controls configure the prefix label and line color in the in-game overlay.

## Capabilities

### Modified Capabilities
- `mangohud-metrics-modular-ui`: Extends the modular presentation requirements to include unified HUD Chip identity controls in the GPU and CPU card headers.

## Impact
- **Affected Code**: `mangohud_ui.pas` (creation, styling, and `ReflowMetricsTab` geometry calculation for `FGpuNamePanel` / `FCpuNamePanel`), `hintsunit.pas` (enhanced user hints).
- **APIs/Dependencies**: None; utilizes existing LCL controls and theme-aware custom painting.
- **Breaking Changes**: None. Settings keys (`GpuText`, `CpuText`, `GpuColor`, `CpuColor`) and config serialization remain 100% backward-compatible.
