## Context

In GOverlay, MangoHud configuration settings are saved to `MangoHud.conf` using `SaveMangoHudConfigCore` in `overlay_config.pas` and loaded back into UI controls via `LoadMangoHudConfig` and `LoadMangoHudKeyValue` in `mangohud_ui.pas`. 

When switching tabs or restarting GOverlay, `ResetMangoHudControls` is called to reset UI controls to default states before parsing `MangoHud.conf`. Because `LoadMangoHudKeyValue` lacks handlers for `fps_color`, `gpu_load_color`, `cpu_load_color`, and `gpu_list`, and because `gl_vsync` has misaligned index mapping and omits `gl_vsync=4` ("Unset"), these settings revert to default values upon reload.

## Goals / Non-Goals

**Goals:**
- Fix `gl_vsync` mapping in `overlay_config.pas` and `mangohud_ui.pas` so that all 5 dropdown options (Adaptive, OFF, -N-, ON, Unset) save and load properly.
- Implement comma-separated hex color, integer value list parsing, and GPU list parsing in `LoadMangoHudKeyValue` for `fps_color`, `gpu_load_color`, `cpu_load_color`, `fps_value`, `gpu_load_value`, `cpu_load_value`, and `gpu_list`.
- Add necessary constants in `configkeys.pas`.
- Add unit/GUI tests in `tests/gui/gui_test_cases.pas` to prevent regression.

**Non-Goals:**
- Redesigning the MangoHud UI layout or changing default color palettes.

## Decisions

### Decision 1: ComboBox index mapping for `gl_vsync`
`glvsyncComboBox` in `overlayunit.lfm` has the following item order:
0: `Adaptive` -> `gl_vsync=-1`
1: `OFF` -> `gl_vsync=0`
2: `-N-` -> `gl_vsync=n`
3: `ON` -> `gl_vsync=1`
4: `Unset` -> `gl_vsync=4`

- In `SaveMangoHudConfigCore` (`overlay_config.pas`):
  ```pascal
  case Settings.GlvsyncItemIndex of
    0: ConfigLines.Add('gl_vsync=-1');
    1: ConfigLines.Add('gl_vsync=0');
    2: ConfigLines.Add('gl_vsync=n');
    3: ConfigLines.Add('gl_vsync=1');
    4: ConfigLines.Add('gl_vsync=4');
  end;
  ```
- In `LoadMangoHudKeyValue` (`mangohud_ui.pas`):
  ```pascal
  else if SameText(AKey, MANGO_KEY_GL_VSYNC) then
  begin
    if SameText(AValue, MANGO_GL_VSYNC_MINUS1) then
      glvsyncComboBox.ItemIndex := 0
    else if SameText(AValue, MANGO_GL_VSYNC_0) then
      glvsyncComboBox.ItemIndex := 1
    else if SameText(AValue, MANGO_GL_VSYNC_N) then
      glvsyncComboBox.ItemIndex := 2
    else if SameText(AValue, MANGO_GL_VSYNC_1) then
      glvsyncComboBox.ItemIndex := 3
    else if SameText(AValue, MANGO_GL_VSYNC_4) then
      glvsyncComboBox.ItemIndex := 4;
  end;
  ```

### Decision 2: Parsing comma-separated color and value lists and GPU list
For `fps_color`, `gpu_load_color`, and `cpu_load_color`, values are formatted as `HEX1,HEX2,HEX3` (e.g. `FF0000,FF5500,00FF00`).
A helper logic in `LoadMangoHudKeyValue` will split `AValue` using a `TStringList` (delimited by `,`) and assign:
- `fps_color`: `fpscolor1ColorButton`, `fpscolor2ColorButton`, `fpscolor3ColorButton` via `HexToColor`.
- `gpu_load_color`: `gpuload1ColorButton`, `gpuload2ColorButton`, `gpuload3ColorButton` via `HexToColor`.
- `cpu_load_color`: `cpuload1ColorButton`, `cpuload2ColorButton`, `cpuload3ColorButton` via `HexToColor`.
- `fps_value`, `gpu_load_value`, `cpu_load_value`: spin edit threshold controls if present.
- `gpu_list`: parse index or match item in `pcidevComboBox`.

## Risks / Trade-offs

- [Risk] Malformed config lines with fewer than 3 colors or non-numeric GPU indices.
  - *Mitigation*: Check `TStringList.Count` before dereferencing array elements to avoid index out of bounds exceptions.
