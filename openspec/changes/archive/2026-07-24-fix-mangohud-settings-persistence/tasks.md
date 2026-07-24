## 1. Constants Definition

- [x] 1.1 In `configkeys.pas`, define key constants for `MANGO_KEY_GPU_LOAD_COLOR`, `MANGO_KEY_CPU_LOAD_COLOR`, `MANGO_KEY_FPS_VALUE`, `MANGO_KEY_GPU_LOAD_VALUE`, `MANGO_KEY_CPU_LOAD_VALUE`, `MANGO_KEY_GPU_LIST`, and `MANGO_GL_VSYNC_4 = '4'`.

## 2. Configuration Saving & Parsing

- [x] 2.1 In `overlay_config.pas`, update `SaveMangoHudConfigCore` to write `gl_vsync=4` for index 4 ("Unset"), `gl_vsync=n` for index 2 ("-N-"), and `gl_vsync=1` for index 3 ("ON").
- [x] 2.2 In `mangohud_ui.pas`, update `LoadMangoHudKeyValue` to map `gl_vsync` values `-1`, `0`, `n`, `1`, `4` to indices 0, 1, 2, 3, 4 respectively.
- [x] 2.3 In `mangohud_ui.pas`, add handlers in `LoadMangoHudKeyValue` for `MANGO_KEY_FPS_COLOR`, `MANGO_KEY_GPU_LOAD_COLOR`, `MANGO_KEY_CPU_LOAD_COLOR`, `MANGO_KEY_FPS_VALUE`, `MANGO_KEY_GPU_LOAD_VALUE`, `MANGO_KEY_CPU_LOAD_VALUE`, and `MANGO_KEY_GPU_LIST` to parse comma-separated strings and update UI controls.

## 3. Testing & Verification

- [x] 3.1 Add automated test cases in `tests/gui/gui_test_cases.pas` verifying that `gl_vsync=4` (Unset), `fps_color`, `gpu_load_color`, `cpu_load_color`, and `gpu_list` survive round-trip saving and loading in `MangoHud.conf`.
- [x] 3.2 Run `make test` to verify all unit and GUI tests pass cleanly.
