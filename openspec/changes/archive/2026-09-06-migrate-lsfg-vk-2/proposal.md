## Why

The upstream `lsfg-vk` project has moved from GitHub to `https://git.lsfg-vk.dev/lsfg-vk/` and published version 2.0.0. This release introduces a major architectural overhaul: a new TOML `version = 2` profile-based configuration schema, renamed Vulkan implicit layer manifests (`VkLayer_LSFGVK_frame_generation.json`), new present quirks (`override_present_mode`, `preserve_swapchain_image_count`), unified `allow_fp16` in `[global]`, removal of legacy `hdr_mode` and `gpu` options, and availability of pre-built release tarballs on `https://builds.lsfg-vk.dev/` as well as Flathub platform extensions (`org.freedesktop.Platform.VulkanLayer.lsfgvk`).

GOverlay must migrate its Lossless Scaling tab interface, configuration serialization, launch environment variables, and startup download workflow to ensure full compatibility with `lsfg-vk` 2.0 while maintaining support for MAKO and Flatpak environments.

## What Changes

- **Update Configuration Format**:
  - Update `TLosslessScalingTabHelper.WriteLsfgTomlConfig` to write canonical `conf.toml` adhering strictly to `lsfg-vk` 2.0 TOML schema (`version = 2`, `[global]` with `dll` and `allow_fp16`, and `[[profile]]` with `name`, `active_in`, `multiplier`, `flow_scale`, `performance_mode`, `pacing`, `override_present_mode`, and `preserve_swapchain_image_count`).
  - Omit MAKO-specific fields (`adaptive`, `scaling_method`, `target_fps`, etc.) from `lsfg-vk` configurations to prevent parser runtime errors in `lsfg-vk`.
  - Maintain backward-compatible fallback for existing launch scripts.

- **GUI & Controls Update (`lossless_scaling_tab.pas`)**:
  - Add **Override Present Mode** toggle (quirk, default: ON) grouped with Frame Generation toggles.
  - Add **Preserve Swapchain Image Count** toggle (quirk, default: OFF) grouped with Frame Generation toggles.
  - Standardize **Allow FP16** toggle for `lsfg-vk` (default: ON).
  - Remove/hide deprecated **HDR Mode** toggle when `lsfg-vk` is selected.
  - Support multiplier 1x (acting as bypass mode) through 4x+.
  - Maintain contextual visibility so MAKO-exclusive controls (Spatial Scaling, Adaptive FG, Ultra Performance, Base FPS Cap) remain hidden when `lsfg-vk` is selected.

- **Vulkan Layer & Version Detection**:
  - Update layer detection in `lossless_scaling_tab.pas` and `home_tab.pas` to detect `VkLayer_LSFGVK_frame_generation.json` in user and system directories (`~/.local/share/vulkan/implicit_layer.d/`, `/usr/share/...`, `/etc/...`), preserving fallbacks for legacy layer names.
  - Detect installed version using `lsfg-vk-cli --version` / `lsfg-vk-cli healthcheck`, local package managers (pacman, dpkg, rpm), or Flatpak extension metadata.

- **Startup Splash Screen Download & Runtime Management**:
  - Create `CheckAndInstallLsfgVk` in `optiscaler_update.pas` and integrate it into `TStartupDownloadThread.Execute` in `overlayunit.pas`.
  - For native/AppImage environments, download official binaries from `https://builds.lsfg-vk.dev/` and extract to `~/.local/`.
  - Add manual "Install runtime" / "Install update" button for `lsfg-vk` in the Software Status card.
  - For Flatpak, declare `org.freedesktop.Platform.VulkanLayer.lsfgvk` extension with `autodownload: true` in `flatpak/io.github.benjamimgois.goverlay.yml` and add `--filesystem=xdg-config/lsfg-vk:create` in `finish-args`, avoiding manual sandbox curl extraction.

- **Launch Environment**:
  - Update launch commands to export `LSFGVK_CONFIG` pointing to the generated `conf.toml` (and support `LSFGVK_ENV=1` where applicable) when launching games or `pascube`/`vkcube` previews with `imLsfg`.

## Capabilities

### New Capabilities
- `lsfg-vk-auto-install`: Automatic download, installation, update detection, and Flatpak extension integration for the `lsfg-vk` 2.0 Vulkan layer during startup splash and on-demand from the GUI.

### Modified Capabilities
- `lossless-scaling-config`: Update configuration generation, GUI controls (quirks, FP16, multiplier bypass), and layer detection for the `lsfg-vk` 2.0 specification.

## Impact

- `lossless_scaling_tab.pas`: UI layout, toggle switches, layer detection, config serialization (`WriteLsfgTomlConfig`), status indicators.
- `optiscaler_update.pas`: `CheckAndInstallLsfgVk` and remote version checking.
- `overlayunit.pas`: Splash screen startup download progression percentages and launch environment exports (`LSFGVK_CONFIG`).
- `home_tab.pas`: Module status dot and version detection for `lsfg-vk`.
- `flatpak/io.github.benjamimgois.goverlay.yml` & `io.github.benjamimgois.goverlay.nightly.yml`: Addition of `org.freedesktop.Platform.VulkanLayer.lsfgvk` extension and `xdg-config/lsfg-vk:create` permission.
