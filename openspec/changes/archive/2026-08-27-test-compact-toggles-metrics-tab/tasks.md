## 1. Reusable Toggle Switch Component

- [x] 1.1 Implement `TToggleSwitch = class(TCustomControl)` with antialiased rendering, compact dimensions (28x16px), and click interaction, verifying clean compilation with `lazbuild --ws=qt6`.
- [x] 1.2 Add support for tooltip hints, parent theme colors, and `OnChange` event dispatch in `TToggleSwitch`.

## 2. MangoHud Metrics Tab Integration

- [x] 2.1 Integrate `TToggleSwitch` controls for all GPU metrics in `FMtGpuCard` within `InitMetricsTab` and `ReflowMetricsTab`.
- [x] 2.2 Integrate `TToggleSwitch` controls for all CPU and Memory metrics in `FMtCpuCard` within `InitMetricsTab` and `ReflowMetricsTab`.
- [x] 2.3 Connect state synchronization between `TToggleSwitch` instances and MangoHud config load/save methods (`LoadMangoHudConfig`, `ResetMangoHudControls`, `SaveMangoHudConfigCore`).

## 3. Verification & Testing

- [x] 3.1 Add automated GUI test cases verifying `TToggleSwitch` rendering, click toggling, enabled/disabled state, and config persistence.
- [x] 3.2 Run full test suite `./tests/gui/gui_tests --all` and build release binary `lazbuild --ws=qt6 goverlay.lpi`.
