# Implementation Tasks: DLSS-Enabler Dual Channel (Stable & Bleeding-Edge)

- [x] 1. Update DLSS Enabler Download & Version Parsing in GOverlay
  - [x] 1.1 In `optiscaler_update.pas`, update `GetDlssEnablerLatestTag` to query `https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action` and filter by `"STABLE"` (Stable) or `"TRUNK"` (Bleeding-edge).
  - [x] 1.2 In `optiscaler_update.pas`, implement version string extraction from build filename (e.g. `"4.8.12"` from STABLE, `"4.8.13.5"` from TRUNK).
  - [x] 1.3 In `optiscaler_update.pas` (`CheckAndInstallDlssEnabler`), download target build ZIP to `dlssenabler-stable/` or `dlssenabler-edge/` based on active channel and extract `version.dll`.
  - [x] 1.4 Write `dlssenablerversion=<parsed_version>` and `upscalertype=1` to `goverlay.vars` in cache directory.

- [x] 2. Update Game Folder Installation Logic in `bgmod.lpr`
  - [x] 2.1 In `bgmod.lpr`, update `ChannelFolder` selection for `UpscalerType = 1` to target `dlssenabler-stable` when `IsStable` is true and `dlssenabler-edge` when `IsStable` is false.
  - [x] 2.2 In `bgmod.lpr`, update upscaler installation pipeline when `UpscalerType = 1` to copy base OptiScaler files first, then overwrite `OptiScaler.dll` in `GameDir` with `version.dll` from `ChannelFolder`.
  - [x] 2.3 Ensure proxy DLL renaming (`OptiScaler.dll` -> `DllName`) copies the updated `version.dll` correctly.

- [x] 3. Build & Verification
  - [x] 3.1 Rebuild GOverlay and `bgmod`.
  - [x] 3.2 Verify download and version display for both Stable (`4.8.12`) and Bleeding-edge (`4.8.13.5`) channels.
  - [x] 3.3 Verify game folder deployment and proxy DLL renaming.
