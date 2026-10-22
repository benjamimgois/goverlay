## 1. Top Cards Layout (Method & Target GPU Device)

- [x] 1.1 Create `FLsMethodCard` (50% width) with `None`, `lsfg-vk`, and `MAKO` radio buttons and logo images (`upscaler_none.png`, `lossless_scaling.png`, `mako_renderer.png`) with clickable handlers and opacity updates
- [x] 1.2 Create `FLsGpuCard` ("Target GPU Device", 50% width) side-by-side with `FLsMethodCard`, moving the GPU dropdown and device labels into it

## 2. Dynamic Configuration & Card Adaptability

- [x] 2.1 Implement method switching logic in `lossless_scaling_tab.pas` to toggle visibility/state between `None` (disabled notice), `lsfg-vk` (main-branch controls: multiplier, flow scale, toggles, pacing), and `MAKO` (full mako controls + spatial scaling)
- [x] 2.2 Update `ReflowLosslessScalingTab` to recalculate vertical positions and scrollbox dimensions dynamically based on the active Method

## 3. Software Status Card at Base

- [x] 3.1 Create and anchor `FLsStatusCard` at the bottom of the scrollbox matching OptiScaler's `FOsStatusCard` visual design
- [x] 3.2 Add vertical status rows with colored dot indicators (`stEllipse`) for Lossless.dll (with Browse button), MAKO Renderer (with installed version), and lsfg-vk layer
- [x] 3.3 Implement headless background update check for MAKO on initialization/tab show, displaying `[ ⬇ Install Update ]` only when a newer release is detected or MAKO is missing, with progress bar feedback during downloads

## 4. Configuration Persistence & bgmod Integration

- [x] 4.1 Update `LoadLosslessConfig` and `SaveLosslessConfig` to persist `INTERPOLATION_METHOD` (`none`, `lsfg`, `mako`) and `GOVERLAY_LOSSLESS` in `bgmod.conf`
- [x] 4.2 Update `bgmod.lpr` to inspect `INTERPOLATION_METHOD` and dispatch `LSFG_CONFIG` for `lsfg-vk` or `ENABLE_MAKO=1`/`MAKO_CONFIG` for `MAKO`, while suppressing injection flags when `None`

## 5. Verification & Automated Tests

- [x] 5.1 Run GUI and logic test suites (`./tests/gui/run_gui_tests.sh` and `./tests/logic/run_logic_tests.sh`) to verify config generation, method switching, and build integrity
