## 1. Toggle Switch Graph Button Extension

- [x] 1.1 Add `HasGraphButton`, `GraphActive`, `OnGraphClick`, and hover/mouse hit-testing for graph button in `toggle_switch.pas`
- [x] 1.2 Implement high-resolution antialiased rendering of the graph button (active glowing, inactive subtle, disabled states) in `toggle_switch.pas`
- [x] 1.3 Update `GetOptimalWidth` in `toggle_switch.pas` to include graph button dimensions when `HasGraphButton` is true

## 2. Metrics Tab Integration

- [x] 2.1 Enable `HasGraphButton := True` on the 8 metric toggles (`gpu_load`, `vram`, `gpu_core_clock`, `gpu_mem_clock`, `gpu_temp`, `cpu_load`, `cpu_temp`, `ram`) in `mangohud_ui.pas`
- [x] 2.2 Hook `OnGraphClick` event on the 8 toggles to update state and trigger auto-save in `mangohud_ui.pas`

## 3. Configuration Serialization and Deserialization

- [x] 3.1 Add graph boolean fields to `TMangoHudSettings` in `overlay_config.pas`
- [x] 3.2 Serialize `graphs=var1,var2,...` in `SaveMangoHudConfigCore` in `overlay_config.pas`
- [x] 3.3 Parse `graphs=` line in `LoadMangoHudConfig` in `mangohud_ui.pas` and populate toggle graph states

## 4. Verification and GUI Tests

- [x] 4.1 Add automated GUI test cases verifying graph toggle clicks, config writing of `graphs=...`, and reload roundtrip in `tests/gui/gui_test_cases.pas`
- [x] 4.2 Compile with `lazbuild --ws=qt6` and execute `./tests/gui/gui_tests --all` to verify all tests pass with 0 errors
