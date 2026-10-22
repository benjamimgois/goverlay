# Proposal

## Why

NVIDIA DLSS 5 Neural Rendering (DLSS-NR) re-creates path traced and ray traced detail using real-time neural networks, which can now run on AMD Radeon hardware via Vulkan compute shaders through the RDNA4 upstream project (`mochizuki0323/DLSSNR-AMD`) and the RDNA3 emulated port (`mauri870/DLSSNR-RDNA3`). Adding native support in Goverlay gives users a one-click way to install, configure, and manage DLSS-NR runtimes on AMD GPUs with automatic architecture detection and direct file deployment.

## What Changes

- Add a new upscaler method named **"DLSS-NR"** to the Method card in the OptiScaler tab, alongside OptiScaler, DLSS Enabler, and HelixSR.
- Add an architecture selector allowing automatic detection (RDNA3 vs RDNA4 based on detected GPU model) as well as manual override.
- Implement central runtime management and downloading for both `mochizuki0323/DLSSNR-AMD` (RDNA4) and `mauri870/DLSSNR-RDNA3` (RDNA3) GitHub releases.
- Implement a one-time weights extraction helper that accepts the user's `nvngx_dlssnr.dll` (v310.9.16 or v310.8.0) and generates cached `dlssnr.bin` / `dlssnr-small.bin` models for persistent offline game deployments.
- Support direct file deployment managed by Goverlay into game directories (deploying OptiScaler-NR or ReShade-feeder companion libraries, neural binaries, and `dlssnr-amd.ini` configuration).
- Display the installed DLSS-NR version and status in the Goverlay **Software Status** section.
- Add configuration controls for DLSS-NR: Route (OptiScaler, ReShade Feeder, ReShade Vulkan, ReShade DX9), Model Version (New 310.9.16 vs Old 310.8.0), Model Resolution Scale (100%, 75%, 50%, 25% - essential for RDNA3 performance), Int4 Mixed toggle, RenoDX Style toggle, and Preprocess Auto-exposure toggle.

## Capabilities

### New Capabilities
- `dlss-nr-runtime-management`: Automated lifecycle management, release downloads, proprietary weights extraction from `nvngx_dlssnr.dll`, configuration generation (`dlssnr-amd.ini`), and direct file deployment for DLSS-NR on RDNA3 and RDNA4 AMD GPUs.

### Modified Capabilities
- `optiscaler-method-selector`: Expand the Method card in the OptiScaler tab to support "DLSS-NR" alongside "None", "OptiScaler", "DLSS Enabler", and "HelixSR", adjusting layout spacing and visual brightness highlighting (100% active, 35% dimmed).

## Impact

- **UI**: `optiscaler_tab.pas` (Method card radio buttons, logo image, DLSS-NR configuration controls, reflow logic), `home_tab.pas` / `systemdetector.pas` (Software Status version reporting and RDNA GPU architecture detection).
- **Backend**: `optiscaler_update.pas` (release download, version caching, model weights extraction, companion sync), `games_tab.pas` and `bgmod` (direct file deployment and cleanup on uninstall).
- **Configuration**: `configkeys.pas` and `overlay_config.pas` (storing selected method, architecture, route, model version, and options in INI/conf).
