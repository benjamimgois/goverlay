## Why

MangoHud supports rendering visual real-time graphs (lines/histograms) for specific metrics when declared in the `graphs=` configuration directive (e.g. `graphs=gpu_load,cpu_load`). Users currently have no way in GOverlay to enable graphs for these supported metrics without manually editing configuration files. Adding a dedicated, high-contrast graph toggle button adjacent to the 8 supported metric toggles enables users to toggle graphs directly in the GUI while preserving a clean layout.

## What Changes

- Add graph toggle button support to `TToggleSwitch` for the 8 supported MangoHud graph metrics:
  - `gpu_load` (`gpuavgloadCheckBox`)
  - `vram` (`vramusageCheckBox`)
  - `gpu_core_clock` (`gpufreqCheckBox`)
  - `gpu_mem_clock` (`gpumemfreqCheckBox`)
  - `gpu_temp` (`gputempCheckBox`)
  - `cpu_load` (`cpuavgloadCheckBox`)
  - `cpu_temp` (`cputempCheckBox`)
  - `ram` (`ramusageCheckBox`)
- Style the graph icon button with state-aware visual feedback (dimmed when metric is off, subtle dark border when graph is inactive, glowing illuminated cyan/mint outline when graph is active).
- Update MangoHud configuration serialization (`overlay_config.pas`) and deserialization (`mangohud_ui.pas`) to load, persist, and serialize the `graphs=...` parameter into `MangoHud.conf`.
- Add automated GUI tests covering graph toggle activation, persistence, and roundtrip loading.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `mangohud-metrics-compact-toggles`: Add support for inline graph toggle buttons on the 8 supported metrics, saving `graphs=...` to `MangoHud.conf`.

## Impact

- **UI (`mangohud_ui.pas`, `toggle_switch.pas`)**: Extends `TToggleSwitch` with optional graph button rendering and click hit-testing; enables graph buttons on the 8 specified metric toggles.
- **Config (`overlay_config.pas`)**: Extends `TMangoHudSettings` with graph boolean flags and writes `graphs=var1,var2,...` to `MangoHud.conf`.
- **Tests (`tests/gui/gui_test_cases.pas`)**: Adds test cases validating graph activation, serialization, and deserialization.
