## Why

GOverlay displays an incorrect tooltip for Vulkan VSync options (mapping 0 to Off and 3 to Adaptive, whereas MangoHud defines 0 as Adaptive and 3 as On), misinforming users about saved configuration values. Additionally, selecting "Unset" for VSync writes `vsync=4` or `gl_vsync=4` into `MangoHud.conf`, which in OpenGL sets swap interval 4 instead of removing/omitting the setting.

## What Changes

- Fix `vsyncComboBox` tooltip hint in `hintsunit.pas` to match MangoHud's specification (0 = Adaptive, 1 = Off, 2 = Mailbox mode, 3 = On).
- Update VSync configuration saving in `overlay_config.pas` so that selecting "Unset" omits `vsync` and `gl_vsync` keys from `MangoHud.conf` rather than outputting `vsync=4` or `gl_vsync=4`.
- Update `mangohud_ui.pas` loading logic to handle omitted keys by setting dropdowns to "Unset".
- Update existing logic and GUI unit tests in `tests/` to assert correct tooltip hints and "Unset" omission behavior.

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `mangohud-settings-persistence`: Correct Vulkan VSync tooltip hint and change "Unset" behavior for Vulkan/OpenGL VSync to omit keys from `MangoHud.conf`.

## Impact

- `hintsunit.pas`: Updated `vsyncComboBox` hint text.
- `overlay_config.pas`: Modified VSync save logic for item index 4 (Unset).
- `mangohud_ui.pas`: Modified VSync load logic for missing/unspecified VSync entries.
- `tests/gui/gui_test_cases.pas`: Updated test assertions for VSync configuration roundtrips and "Unset" behavior.
