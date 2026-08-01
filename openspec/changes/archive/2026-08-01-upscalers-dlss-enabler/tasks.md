# Tasks: Upscalers Tab & DLSS Enabler Support

## 1. Asset Preparation & Sidebar Tab Rename
- [x] 1.1 Copy provided OptiScaler and DLSS Enabler logo images into `assets/icons/upscaler_optiscaler.png` and `assets/icons/upscaler_dlss_enabler.png`.
- [x] 1.2 Update `sidebar_nav.pas` caption array to rename `'OptiScaler'` to `'Upscalers'`.

## 2. UI Layout & Upscaler Selection Card
- [x] 2.1 In `optiscaler_tab.pas`, create `FOsUpscalerCard` and update `ReflowOptiScalerTabNew` to position `FOsUpscalerCard` (left) and `FOsGpuCard` (right) at 50% width each.
- [x] 2.2 Add mutually exclusive checkboxes for OptiScaler (default) and DLSS Enabler with logo images.
- [x] 2.3 Implement opacity toggle effect (100% for active, 40% for inactive).
- [x] 2.4 Pre-select `version.dll` in `filenameComboBox` when DLSS Enabler is checked if no game override exists.

## 3. DLSS Enabler Download & Version Tracking
- [x] 3.1 In `optiscaler_update.pas`, add download/extraction logic for `bygalacos/OptiScalerBuilder` into `dlssenabler-edge`.
- [x] 3.2 Extract `.7z` directly into `~/.local/share/goverlay/dlssenabler-edge`.
- [x] 3.3 Create/update `goverlay.vars` with `dlssenablerversion=<tag_name>`.
- [x] 3.4 Display DLSS Enabler version label in the Software Status grid.

## 4. Game Directory Sync & Verification
- [x] 4.1 In `bgmod.lpr` and `sidebar_nav.pas`, detect `UPSCALER_TYPE=1` in `bgmod.conf`.
- [x] 4.2 Copy `OptiScaler.dll` (renamed to proxy DLL), `OptiScaler.ini`, and `OptiScaler/` folder when game launches or syncs.
- [x] 4.3 Verify full compilation of `goverlay` and `bgmod` using `make`.
