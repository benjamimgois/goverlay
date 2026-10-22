# Proposal

## Why

The MangoHud Metrics tab in Goverlay currently presents nearly 30 toggle switches in flat, unorganized horizontal rows across the GPU Metrics and CPU / Memory Metrics cards. Secondary controls—including load gradient colors, VRAM and RAM color indicators, and format buttons like `[Frames / Joule]` and `[% Percent]`—float disconnectedly below their labels, creating visual clutter and switch fatigue.

Restructuring this tab into cohesive thematic hardware modules (sub-cards) with inline secondary control integration provides clear visual hierarchy, eliminates orphaned controls, and elevates the user experience to match modern telemetry suites.

## What Changes

- Reorganize GPU Metrics into 4 clear thematic sub-modules:
  - **Core & Memory Telemetry**: Load (with inline 3-color gradient buttons and graph toggle), VRAM (with inline color indicator and graph toggle), Core Frequency, and Memory Frequency.
  - **Thermals & Cooling**: GPU Temp (with graph toggle), Memory Temp, Junction Temp, and Fan Speed.
  - **Power & Efficiency**: Power, Voltage, Throttling, Throttling Graph, Efficiency (with inline `[Frames / Joule]` selector), and Power Limit.
  - **Hardware & Process**: GPU Model, Vulkan Driver, and Process VRAM.
- Reorganize CPU / Memory Metrics into 3 thematic sub-modules:
  - **Processor Core & Freq**: Overall Load (with inline 3-color gradient buttons and graph toggle), Core Load (with inline format selector), Core Frequency, and Core Type.
  - **Thermals & Power**: CPU Temp (with graph toggle), CPU Power (with inline Intel power fix button), Efficiency (with inline format selector), and RAM Temp.
  - **Memory & Storage IO**: RAM Usage (with inline color indicator and graph toggle), Disk IO (with inline color indicator), Process Memory, and Swap File.
- Reflow the layout responsively with rounded elevated sub-panels (`SubCardPaint`) and consistent horizontal baselines.

## Capabilities

### New Capabilities
- `mangohud-metrics-modular-ui`: Defines the modular sub-card layout and inline secondary control integration for the MangoHud Metrics tab.

### Modified Capabilities
<!-- None: Core MangoHud configuration keys and serialization remain unchanged. -->

## Impact

- Code: `mangohud_ui.pas` (`InitMetricsTab`, `ReflowMetricsTab`, `UpdateMetricsCardTheme`).
- UI: Performance tab -> Metrics tab.
- Dependencies: None.
