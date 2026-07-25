## Why

In the MangoHud Metrics tab, the CPU and GPU name edit controls (`gpunameEdit`, `cpunameEdit`) and their associated color buttons (`gpuColorButton`, `cpuColorButton`) are positioned with hardcoded static X offsets (`Left = 285` and `Left = 281`). When the main application window is maximized, the metric columns stretch across the wider card, but these header controls remain fixed on the left side, making them visually misaligned and off-center.

## What Changes

- Dynamically calculate the horizontal position of `gpunameEdit`, `gpuColorButton`, `cpunameEdit`, and `cpuColorButton` inside `TMangoHudUiHelper.ReflowMetricsTab`.
- Center these header controls relative to the card's available width (`CW`), keeping them perfectly centered whether the window is in its minimum size (1045x683) or maximized.

## Capabilities

### New Capabilities
- `center-metrics-header-edits`: Dynamically centers CPU and GPU name edit fields and color buttons within the Metrics tab cards upon window resize and reflow.

### Modified Capabilities

## Impact

- `mangohud_ui.pas`: `ReflowMetricsTab` will update `Left` properties of `gpunameEdit`, `gpuColorButton`, `cpunameEdit`, and `cpuColorButton` based on card width `CW`.
