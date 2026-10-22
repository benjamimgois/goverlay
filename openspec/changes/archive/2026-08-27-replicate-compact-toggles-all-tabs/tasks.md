## 1. MangoHud Visual Tab Integration

- [x] 1.1 Integrate `TToggleSwitch` controls for Compact HUD, Horizontal Stretch, Hide HUD, and Change FPS Colors in `InitVisualTab` and `ReflowVisualTab`.
- [x] 1.2 Add `SyncVisualToggles` and hook into `LoadMangoHudConfig` and `ResetMangoHudControls`.

## 2. MangoHud Performance Tab Integration

- [x] 2.1 Integrate `TToggleSwitch` controls for Information card options (Show FPS, FPS Average, FPS limit, Frame Time, Frame Time +, VPS, Count frames, ftrace debug) in `InitPerformanceTab` and `ReflowPerformanceTab`.
- [x] 2.2 Add `SyncPerformanceToggles` and maintain coupling between Frame Time and Frame Time +.

## 3. MangoHud Extras Tab Integration

- [x] 3.1 Integrate `TToggleSwitch` controls across all cards in `InitExtrasTab` and `ReflowExtrasTab`.
- [x] 3.2 Add `SyncExtrasToggles` and hook into `LoadMangoHudConfig` and `ResetMangoHudControls`.

## 4. Lossless Scaling Tab Integration

- [x] 4.1 Integrate `TToggleSwitch` controls for Performance Mode, HDR Mode, and Disable FP16 in `lossless_scaling_tab.pas`.
- [x] 4.2 Hook state synchronization into `LoadGameLosslessScaling` and `SaveGameLosslessScaling`.

## 5. Verification & Testing

- [x] 5.1 Add automated GUI test cases verifying toggle behavior across Visual, Performance, Extras, and Lossless Scaling tabs.
- [x] 5.2 Run full test suite `./tests/gui/gui_tests --all` and build release binary `lazbuild --ws=qt6 goverlay.lpi`.
