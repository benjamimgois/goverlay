# Proposal: Rename OptiScaler tab to Upscalers & Add DLSS Enabler Support

## Summary
Rename the "OptiScaler" sidebar navigation tab to "Upscalers", reorganize the top section into two 50% width cards ("Upscaler" and "GPU Driver"), add mutually exclusive image-based checkboxes for OptiScaler and DLSS Enabler, and implement download, extraction, version tracking, and execution sync for DLSS Enabler.

## Problem / Background
Currently, the OptiScaler tab is dedicated exclusively to OptiScaler configuration. However, DLSS Enabler is a specialized variant of OptiScaler available from `bygalacos/OptiScalerBuilder` that offers expanded functionality while using the same configuration structure (`OptiScaler.ini` and `bgmod.conf`). Users need a clean way to choose between standard OptiScaler and DLSS Enabler per game, with DLSS Enabler automatically downloaded and synced when selected.

## Proposed Changes
1. **Sidebar Navigation**: Rename the tab caption from `'OptiScaler'` to `'Upscalers'` in `sidebar_nav.pas`.
2. **Top Card Reorganization**:
   - Split top section into two 50% width cards side-by-side in `optiscaler_tab.pas`.
   - Left card: `FOsUpscalerCard` ("Upscaler").
   - Right card: `FOsGpuCard` ("GPU Driver").
3. **Mutually Exclusive Upscaler Image Checkboxes**:
   - Add two checkboxes inside `FOsUpscalerCard`: OptiScaler (default selected) and DLSS Enabler.
   - Use logo images for each checkbox (`assets/icons/upscaler_optiscaler.png` and `assets/icons/upscaler_dlss_enabler.png`).
   - Active checkbox image renders at 100% opacity; inactive renders at ~40% opacity.
   - Selecting DLSS Enabler pre-selects `version.dll` in `filenameComboBox` if no prior game proxy configuration exists.
4. **DLSS Enabler Download & Maintenance**:
   - Add download logic in `optiscaler_update.pas` fetching the latest release asset from `https://github.com/bygalacos/OptiScalerBuilder`.
   - Extract `.7z` package into `~/.local/share/goverlay/dlssenabler-edge/` containing `OptiScaler.dll`, `OptiScaler.ini`, and `OptiScaler/`.
   - Generate `goverlay.vars` inside `dlssenabler-edge/` with `dlssenablerversion=<ver>`.
   - Add DLSS Enabler version row to the "Software Status" card.
5. **Runtime Game Sync (`bgmod`)**:
   - Update `bgmod` and `sidebar_nav.pas` copy logic to support syncing from `dlssenabler-edge`.
   - Copy `OptiScaler.ini`, `OptiScaler/` folder, and copy/rename root `OptiScaler.dll` to the active proxy DLL name (`version.dll`, `dxgi.dll`, etc.) in the game directory.
