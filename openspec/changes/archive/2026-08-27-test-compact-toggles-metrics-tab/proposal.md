## Why

GOverlay currently uses standard Lazarus LCL checkboxes across the MangoHud tabs. In dense metric panels (such as GPU and CPU metrics cards), standard checkboxes look dated and consume significant horizontal space. To provide a modern Material/Fluent-inspired visual aesthetic and prepare for a consistent toggle-based design across all tabs, we will test compact high-resolution antialiased toggle switches (`TToggleSwitch`, 28x16px) specifically on the MangoHud **Metrics** tab.

## What Changes

- Create a reusable `TToggleSwitch` custom control class (`TCustomControl`) with antialiased stadium track rendering, custom thumb with drop shadow, configurable dimensions (compact 28x16px), click handling across both the toggle pill and label, and properties compatible with `TCheckBox` (`Checked`, `Caption`, `Enabled`, `Hint`, `OnChange`).
- Replace standard checkboxes in the **Metrics** tab (`FMtGpuCard` and `FMtCpuCard`) with `TToggleSwitch` instances:
  - GPU Metrics: Average load, Load colors, VRAM, GPU frequency, Memory frequency, GPU/Mem/Junction temperatures, Fan speed, Power, Voltage, Throttling, Efficiency, Power limit, GPU model, Vulkan driver, Process VRAM.
  - CPU/Memory Metrics: Average load, Load colors, Core load, CPU frequency, Core types, CPU temperature, Power, Efficiency, RAM temperature, RAM usage, Disk I/O, Process memory, Swap usage.
- Wire full bi-directional state synchronization between the new toggle switches, configuration loader/saver, and automated test suite.

## Capabilities

### New Capabilities
- `mangohud-metrics-compact-toggles`: Reusable compact toggle switch component and its integration into the MangoHud Metrics tab (GPU and CPU metric cards).

### Modified Capabilities
<!-- None -->

## Impact

- **UI Components**: Introduces `TToggleSwitch` in `mangohud_ui.pas` (or a dedicated helper unit).
- **Tab Layout**: Updates `InitMetricsTab` and `ReflowMetricsTab` in `mangohud_ui.pas` to layout compact toggle controls seamlessly.
- **Config & Persistence**: Preserves complete compatibility with existing `MangoHud.conf` loading and saving routines.
- **Tests**: Updates GUI test suite to verify toggle interaction, state sync, and visual layout.
