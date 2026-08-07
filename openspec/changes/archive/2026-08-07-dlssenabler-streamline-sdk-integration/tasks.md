# Implementation Tasks: DLSS-Enabler Streamline SDK Integration

- [x] 1. Implement Streamline SDK Download & Extraction in GOverlay
  - [x] 1.1 In `optiscaler_update.pas`, add `CheckAndInstallStreamlineSDK` to query `https://api.github.com/repos/NVIDIA-RTX/Streamline/releases/latest` and download the release ZIP.
  - [x] 1.2 In `optiscaler_update.pas`, extract all `.dll` files in `/bin/x64/` from the ZIP into `dlssenabler-stable/` and `dlssenabler-edge/`.
  - [x] 1.3 Write `streamlineversion=<version>` to `goverlay.vars` in the cache directory and parse it in `LoadVersionsFromFile`.

- [x] 2. Update Software Status UI Card in `optiscaler_tab.pas`
  - [x] 2.1 Update `STAT_NAMES` array to include `'Streamline SDK'`.
  - [x] 2.2 Update `RefreshOsStatusDots` to populate and display the Streamline SDK version.

- [x] 3. Update Game Directory Deployment in `bgmod.lpr`
  - [x] 3.1 In `bgmod.lpr`, copy Streamline DLLs (`sl.*.dll`) from `SourceDir` to `GameDir` when installing DLSS Enabler.

- [x] 4. Build & Verification
  - [x] 4.1 Rebuild GOverlay and `bgmod`.
  - [x] 4.2 Verify Streamline SDK download, extraction, and UI display.
  - [x] 4.3 Verify Streamline DLL deployment into game directory.
