## 1. Flatpak Manifest and Environment Integration

- [x] 1.1 Add `org.freedesktop.Platform.VulkanLayer.lsfgvk` extension to `flatpak/io.github.benjamimgois.goverlay.yml` and `io.github.benjamimgois.goverlay.nightly.yml`, and verify YAML formatting
- [x] 1.2 Add `--filesystem=xdg-config/lsfg-vk:create` permission to `finish-args` in Flatpak manifests and verify YAML formatting
- [x] 1.3 Update execution environment in `overlayunit.pas` to export `LSFGVK_CONFIG` pointing to `conf.toml` when launching with `imLsfg`, and verify environment variable string construction

## 2. Configuration Parser and Serializer for lsfg-vk 2.0

- [x] 2.1 Update `WriteLsfgTomlConfig` in `lossless_scaling_tab.pas` to generate canonical `conf.toml` with `version = 2`, `[global]` (`dll`, `allow_fp16`), and `[[profile]]` (`name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, `preserve_swapchain_image_count`) omitting MAKO-only keys
- [x] 2.2 Update `ParseLsfgToml` in `lossless_scaling_tab.pas` to parse `conf.toml` version 2 fields (including quirks and `allow_fp16`), verifying correct state extraction
- [x] 2.3 Verify generated TOML config file content conforms to upstream `lsfg-vk` 2.0 requirements

## 3. UI Controls and Tab Layout

- [x] 3.1 Declare and instantiate `FLsOverridePresentModeCheckBox`/`Toggle` and `FLsPreserveSwapchainCheckBox`/`Toggle` in `lossless_scaling_tab.pas`
- [x] 3.2 Place `FLsOverridePresentMode` and `FLsPreserveSwapchain` toggles alongside Frame Generation toggles in `lossless_scaling_tab.pas`, and verify proper visual alignment
- [x] 3.3 Update `UpdateControlsEnabled` in `lossless_scaling_tab.pas` to show Quirks and Allow FP16 toggles when `imLsfg` is selected, while hiding HDR Mode and MAKO-only controls
- [x] 3.4 Adjust Multiplier slider in `lossless_scaling_tab.pas` to support 1x (Bypass) through 4x+, verifying label updates

## 4. Layer and Version Detection

- [x] 4.1 Update `CheckLsfgVkLayerInstalled` in `lossless_scaling_tab.pas` to detect `VkLayer_LSFGVK_frame_generation.json` in user and system layer locations with legacy fallbacks
- [x] 4.2 Update `GetLsfgVkInstalledVersion` in `lossless_scaling_tab.pas` to check `lsfg-vk-cli --version` / `lsfg-vk-cli healthcheck` and package manager databases
- [x] 4.3 Update `home_tab.pas` module status dot and version detection for `lsfg-vk` 2.0, verifying status indicator rendering

## 5. Startup Splash Screen Download and On-Demand Update

- [x] 5.1 Implement `CheckAndInstallLsfgVk` in `optiscaler_update.pas` to download `lsfg-vk-2.0.0.tar.xz` from `https://builds.lsfg-vk.dev/` and extract to `~/.local` in native environments
- [x] 5.2 Add Flatpak awareness in `CheckAndInstallLsfgVk` to skip `curl`/`tar` extraction when `IsRunningInFlatpak` is true
- [x] 5.3 Integrate `CheckAndInstallLsfgVk` into `TStartupDownloadThread.Execute` in `overlayunit.pas` with splash progress reporting
- [x] 5.4 Connect manual "Install runtime" / "Install update" button in the Software Status card for `lsfg-vk`
- [x] 5.5 Verify project builds cleanly with `lazbuild`
