# Proposal

## Why

HelixSR is a neural upscaler implementation that brings NVIDIA's DLSS Model E network to AMD Radeon GPUs (RDNA 1, RDNA 2, RDNA 3/3.5, and Vega) using native Direct3D 12 compute shaders without proprietary NVIDIA hardware or drivers. Users want to leverage this neural upscaler on Linux for superior image quality over conventional spatial upscalers. Adding HelixSR as a dedicated Method in GOverlay gives users a streamlined experience: lightweight zip asset verification on splash, on-demand local compilation of the neural shaders when first activated, and choice between the standard OptiScaler backend integration and an experimental native DLSS loader.

## What Changes

- Add **HelixSR** as a 4th upscaler method in the OptiScaler tab's "Method" card alongside "None", "OptiScaler", and "DLSS Enabler", adjusting layout from 3 to 4 equal-width slots.
- Integrate HelixSR runtime download (`HelixSR-*.zip`) into the startup splash verification (`TStartupDownloadThread`) targeting `~/.local/share/goverlay/optiscaler-helixsr/`.
- Implement on-demand compilation: when the user selects the HelixSR method for the first time, check if `amd_fidelityfx_dx12.dll` has been compiled (marked with `HXSRNET1`); if not, display a compilation modal with a step-by-step progress bar running the shader compilation via Proton/Wine and DXC.
- Support HelixSR game deployment in `bgmod`:
  - `UPSCALER_TYPE = 3` represents the HelixSR method in `bgmod.conf`.
  - Standard mode (default): deploys `OptiScaler.dll`, `fakenvapi.dll`, and `HelixSR/` backend (`amd_fidelityfx_dx12.dll`, `helixsr.ini`).
  - Experimental "Native DLSS" mode: deploys `dlss-loader/dxgi.dll` and `nvngx.dll` directly without OptiScaler for single-player games.
- Add HelixSR configuration options in the UI (Native DLSS toggle with single-player safety warning, WaveSize configuration for RDNA 3, and sharpening controls).

## Capabilities

### New Capabilities
- `helixsr-runtime-management`: Covers downloading the HelixSR package during startup verification, on-demand compilation of DLSS Model E compute shaders via Proton/Wine with real-time UI progress, and deploying files to game profiles.

### Modified Capabilities
- `optiscaler-method-selector`: Update the Method card layout from 3 to 4 equal-width slots to include HelixSR with dedicated radio button, logo image, and visual dimming states.

## Impact

- `optiscaler_tab.pas`: Card 0 layout refactored for 4 slots, new radio/image controls, and contextual option cards for HelixSR.
- `overlayunit.pas` and `overlayunit.lfm`: Event handlers for HelixSR selection, on-demand compilation trigger, and form state synchronization.
- `optiscaler_update.pas`: Routines for downloading HelixSR releases and executing the headless compilation process.
- `bgmod_resources.pas` & `sidebar_nav.pas`: Path helpers and file synchronization for `optiscaler-helixsr/`.
- `bgmod.lpr` & `overlay_config.pas`: Support `UPSCALER_TYPE = 3` in `bgmod.conf`.
