## Why

The upstream `lsfg-vk` project has transitioned into MAKO (*Motion-Adaptive Kernel Orchestration*), which brings significant improvements including independent spatial scaling (LS1, MAKO Scaler), Adaptive Frame Generation (fractional multipliers, target FPS), Gamescope WSI presentation safety, and standalone packaged releases. Goverlay currently relies on the discontinued `lsfg-vk` 1.x format without auto-updater support; replacing it with MAKO modernizes frame generation and upscaling on Linux while providing dynamic downloads and updates identical to OptiScaler and DLSS-Enabler.

## What Changes

- **Replace backend engine**: Replace `lsfg-vk` with `MAKO` (`mako-render`, `mako-launch`, `mako-cli`).
- **Dynamic Updater / Downloader**: Implement GitHub release fetching and headless installation of `MAKO-Renderer-*.tar.xz` into user-space (`~/.local/`) with update checks and progress indication.
- **Configuration migration (BREAKING)**: Replace `lsfg.toml` (version = 1, `[[game]]`) with MAKO canonical `conf.toml` (version = 2, `[[profile]]` with `active_in = [...]`).
- **Environment variables & launch wrapper (BREAKING)**: Replace `LSFG_CONFIG` with `ENABLE_MAKO=1`, `MAKO_CONFIG`, `MAKO_DISABLE_HDR_EXPOSURE=1`, and `DISABLE_GAMESCOPE_WSI=1` (or `mako-launch %command%`), while suppressing legacy `DISABLE_LSFG=1` and `DISABLE_LSFGVK=1`.
- **UI - Lossless Scaling Tab redesign**:
  - Add engine status & dynamic update card with version badge, "Check Updates" / "Install MAKO" action buttons and progress reporting.
  - Integrate `mako-cli inspect-dll` for deep `Lossless.dll` model compatibility inspection.
  - Add Adaptive Frame Generation controls: Fixed Multiplier vs Adaptive toggle, Target FPS (30–240), Max Multiplier ceiling (2x–5x), Steady 2x Base FPS Cap, and Smooth Cadence.
  - Add general FG controls: Base FPS Cap, Refresh Threshold guard (Hz), Flow Scale slider (25%–100%, default 90%), Lighter FG Model (`performance_mode`), FP16 toggle (`allow_fp16`), and live FG toggle (`frame_generation_enabled`).
  - Add Spatial Scaling card: Enable spatial scaling toggle, Scaling Method dropdown (`ls1`, `ls1-performance`, `mako`, `native`), Scaling Factor slider (1.0x–2.0x), Sharpness slider (0.0–1.0), and Supersampling toggle.
- **Dependency detection & Home tab**: Update `apputils.pas` and `home_tab.pas` to detect `VkLayer_MAKO_render.json` and reflect MAKO installation status.

## Capabilities

### New Capabilities
- `mako-engine-management`: Dynamic download, installation, update detection, and DLL capability verification for MAKO Renderer from GitHub releases.

### Modified Capabilities
- `lossless-scaling-config`: Migrates configuration generation from `lsfg.toml` (v1) to MAKO `conf.toml` (v2), supports Spatial Scaling and Adaptive Frame Generation profiles, and configures MAKO environment variables in launch commands and `bgmod`.

## Impact

- **Affected Code**: `lossless_scaling_tab.pas`, `optiscaler_update.pas` (or new helper unit), `overlayunit.pas`, `bgmod.lpr`, `apputils.pas`, `home_tab.pas`, `constants.pas`, `tests/gui/gui_test_cases.pas`.
- **APIs / External Services**: GitHub Releases API (`eugeniosegala/MAKO`), checking for tags matching `render-v*`.
- **Filesystem / Configs**: Generates `conf.toml` instead of `lsfg.toml`; installs Vulkan implicit layers in `~/.local/share/vulkan/implicit_layer.d/` (`VkLayer_MAKO_render.json`, `VkLayer_MAKO_spatial_scaling.json`).
