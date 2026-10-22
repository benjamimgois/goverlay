## 1. Core State Synchronization & Launch Guard in overlayunit.pas

- [x] 1.1 Implement `IsMakoActive: Boolean` and `SyncMakoEnvVarsState` in `overlayunit.pas` with state caching (`FPreMakoWaylandChecked`, `FPreMakoHdrChecked`) and verify compilation with `lazbuild goverlay.lpi`.
- [x] 1.2 Hook `SyncMakoEnvVarsState` in `ApplyToolEnabledState(2, ...)` and guard `GetTweaksLaunchEnv` to omit `PROTON_ENABLE_WAYLAND`, `PROTON_ENABLE_HDR`, `ENABLE_HDR_WSI`, and `DXVK_HDR` when `IsMakoActive` is true, verifying launch command generation.

## 2. Lossless Scaling Tab Integration in lossless_scaling_tab.pas

- [x] 2.1 Add `FLsMakoNoteLabel` on `FLsStatusCard` displaying `(Wayland and HDR envvars are disabled with MAKO)` beside the MAKO version, and show `FFloatingToast` on interactive `MethodMakoClick`, verifying visual rendering.
- [x] 2.2 In `SetInterpolationMethod`, trigger `SyncMakoEnvVarsState` and in `SaveLosslessConfig`, prune conflicting Wayland and HDR keys from `[Env]` in `bgmod.conf` when MAKO is active.

## 3. EnvVars Tab Styling and Interaction in tweaks_md3.pas

- [x] 3.1 Update `DrawToggle` and `DrawItem` in `tweaks_md3.pas` with `AEnabled: Boolean = True` to render disabled toggles in dimmed slate/gray palette.
- [x] 3.2 Update `MouseDown` to block toggling on disabled items and `MouseMove` to show `TweakHint` when hovering over disabled items.
- [x] 3.3 Call `SyncMakoEnvVarsState` at the end of `LoadTweaksFromFGMod` to ensure UI state remains synchronized after loading configuration.

## 4. Test Suite Isolation & Verification

- [ ] 4.1 Fix test isolation in `tests/gui/gui_test_cases.pas` (`TestLosslessScalingDynamicConfigFileAndLog` and `TestLosslessScalingMethodSwitching`) by resetting `Helper.SetInterpolationMethod(imNone)` in `finally` blocks.
- [ ] 4.2 Add GUI unit test `TestMakoDeactivatesWaylandAndHdrEnvVars` in `tests/gui/gui_test_cases.pas` covering notification, toggle deactivation, launch env exclusion, and re-enabling/state restoration.
- [ ] 4.3 Run `make test` and verify that all 95 GUI tests and 30 logic tests pass cleanly with 0 failures and 0 errors.
