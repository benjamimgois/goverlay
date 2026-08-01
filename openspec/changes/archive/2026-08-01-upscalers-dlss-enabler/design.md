# Design: Upscalers Tab & DLSS Enabler Support

## Technical Architecture

### 1. UI Layout Reflow (`optiscaler_tab.pas`)
In `ReflowOptiScalerTabNew`:
- Calculate card width `CardW := (CW - GAP) div 2`.
- `FOsUpscalerCard.SetBounds(MARGIN, MARGIN, CardW, GPU_H);`
- `FOsGpuCard.SetBounds(MARGIN + CardW + GAP, MARGIN, CardW, GPU_H);`
- Inside `FOsUpscalerCard`:
  - Place OptiScaler checkbox + `OptiScaler` logo image at left.
  - Place DLSS Enabler checkbox + `DLSS Enabler` logo image at right.
  - Mutual exclusion logic: checking one unchecks the other.
  - Opacity effect: set parent paint / image opacity or alpha mask rendering (1.0 vs 0.4).
  - On selecting DLSS Enabler: if `FActiveGameName` has no stored `DLL` in `bgmod.conf`, set `filenameComboBox.ItemIndex` to index of `version.dll`.

### 2. Download and Version Management (`optiscaler_update.pas`)
- Query GitHub API for `https://api.github.com/repos/bygalacos/OptiScalerBuilder/releases/latest`.
- Parse asset download URL ending in `.7z` and version string.
- Download to cache and extract using `Extract7z` into `GetOptiScalerInstallPath + 'dlssenabler-edge/'`.
- Write `dlssenablerversion=<tag>` into `dlssenabler-edge/goverlay.vars`.
- Add DLSS Enabler version indicator label into `FOsStatVerLbls` grid in `optiscaler_tab.pas` / `optiscaler_update.pas`.

### 3. Execution Sync (`sidebar_nav.pas` & `bgmod`)
- Add support for channel `dlssenabler-edge` when building launch command or copying game files.
- Copy `OptiScaler.ini`, `OptiScaler/` folder, and `OptiScaler.dll` (renamed to target proxy DLL, e.g. `version.dll`) into game folder.
- Write/copy `goverlay.vars` to game directory for version tracking.
