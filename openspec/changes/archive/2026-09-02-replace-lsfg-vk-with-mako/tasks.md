## 1. Engine Management & Dynamic Updater

- [x] 1.1 Implement GitHub release fetching and download logic for `MAKO-Renderer-*.tar.xz` in `mako_update.pas` (or `optiscaler_update.pas`) and verify it queries and resolves the latest `render-v*` asset URL.
- [x] 1.2 Implement headless extraction and installation invoking `mako-installer --install` with `MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1`, verifying layer manifests exist in `~/.local/share/vulkan/implicit_layer.d/`.
- [x] 1.3 Implement startup boot provisioning in `TStartupDownloadThread.Execute` (`overlayunit.pas`), verifying `CheckAndInstallMako` reports progress on the boot splash screen if MAKO is not installed.
- [x] 1.4 Implement local version detection and update notification logic, verifying it compares local `active-renderer.json` with the latest remote release tag.
- [x] 1.5 Implement `mako-cli inspect-dll` integration to verify `Lossless.dll` capability reporting (FP16/FP32/LS1) and display status badges in the UI.

## 2. Configuration & Serialization

- [x] 2.1 Implement canonical `conf.toml` (version = 2) generator with `[[profile]]` blocks matching `active_in = ["pascube", "vkcube", "<game>"]` in `lossless_scaling_tab.pas` and verify generated TOML validates with `mako-cli validate`.
- [x] 2.2 Implement config parser to read existing `conf.toml` (with backward-compatible import from legacy `lsfg.toml`) and verify settings populate UI fields correctly.
- [x] 2.3 Update `bgmod.lpr` to serialize `conf.toml` (version = 2) for game execution and verify output.

## 3. Lossless Scaling Tab GUI Redesign

- [x] 3.1 Redesign Card 0 for MAKO Engine: add version display, "Check Updates" / "Install MAKO" buttons, download progress bar, and DLL inspection status badges.
- [x] 3.2 Redesign Card 1 for Frame Generation: implement Fixed Multiplier (2x–5x) vs Adaptive Frame Generation mode switcher, Target FPS (30–240), Max Multiplier, Base FPS Cap, Refresh Threshold, and Flow Scale controls.
- [x] 3.3 Create Card 2 for Spatial Scaling: implement Scaling Enable toggle, Method dropdown (LS1 Quality, LS1 Performance, MAKO Scaler, Native), Factor slider (1.0–2.0), Sharpness slider (0.0–1.0), and Supersampling toggle.
- [x] 3.4 Implement layout reflow and responsive resizing in `lossless_scaling_tab.pas` and verify cards adapt properly to window resizing.

## 4. Environment Variables & Launch Integration

- [x] 4.1 Update `GetLosslessScalingLaunchEnv` in `overlayunit.pas` and `lossless_scaling_tab.pas` to export `ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, `DISABLE_GAMESCOPE_WSI=1`, `DISABLE_LSFG=1`, and `DISABLE_LSFGVK=1`.
- [x] 4.2 Update `apputils.pas` and `home_tab.pas` to detect MAKO Vulkan layer manifests and reflect MAKO installation status on the Home tab.

## 5. Verification & Testing

- [x] 5.1 Run GUI test suite (`tests/gui/gui_test_cases.pas`) and verify all assertions pass.
- [x] 5.2 Build Goverlay binary and verify launch command generation, startup splash download integration, and `conf.toml` validation.
