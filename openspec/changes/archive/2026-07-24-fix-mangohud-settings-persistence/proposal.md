## Why

GOverlay fails to save and reload several MangoHud configuration settings: OpenGL VSYNC Default (`gl_vsync`), FPS Colors (`fps_color`), GPU Load Colors (`gpu_load_color`), CPU Load Colors (`cpu_load_color`), and Selected GPU Device (`gpu_list`). Upon saving, switching tabs, or restarting the application, these settings revert to default values due to missing key parsers in `LoadMangoHudKeyValue` and incomplete/misaligned VSYNC option index mappings.

Fixing this ensures user-configured colors, GPU selection, and VSYNC options persist correctly across tab navigation and application restarts.

## What Changes

- Add missing key constants for `gpu_load_color`, `cpu_load_color`, `fps_color`, `fps_value`, `gpu_load_value`, `cpu_load_value`, `gpu_list`, and `gl_vsync=4` ("Unset").
- Fix `gl_vsync` ComboBox index mapping in both configuration saving (`SaveMangoHudConfigCore`) and loading (`LoadMangoHudKeyValue`).
- Implement key parsing in `LoadMangoHudKeyValue` for multi-color hex strings (`fps_color`, `gpu_load_color`, `cpu_load_color`), threshold values (`fps_value`, `gpu_load_value`, `cpu_load_value`), and GPU device selection (`gpu_list`).

## Capabilities

### New Capabilities
- `mangohud-settings-persistence`: Persists and restores MangoHud multi-color thresholds (`fps_color`, `gpu_load_color`, `cpu_load_color`), GPU device selection (`gpu_list`), and OpenGL VSYNC options (including Unset) when navigating UI tabs or restarting GOverlay.

### Modified Capabilities

## Impact

- `configkeys.pas`: Added MangoHud key constants (`MANGO_KEY_GPU_LOAD_COLOR`, `MANGO_KEY_CPU_LOAD_COLOR`, `MANGO_KEY_FPS_VALUE`, `MANGO_KEY_GPU_LOAD_VALUE`, `MANGO_KEY_CPU_LOAD_VALUE`, `MANGO_GL_VSYNC_4`).
- `overlay_config.pas`: Corrected `gl_vsync` saving logic.
- `mangohud_ui.pas`: Added color, value, and GPU list parsing in `LoadMangoHudKeyValue` and fixed `gl_vsync` index assignment.
