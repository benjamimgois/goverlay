## 1. Vector Masters

- [x] 1.1 Update `data/icons/goverlay.svg` with Sky Blue (`#38BDF8`) and Light Sapphire (`#60A5FA`) layers
- [x] 1.2 Update `data/icons/goverlay_logo.svg` with `#38BDF8` and `#60A5FA` layers while preserving dimensions
- [x] 1.3 Update `data/icons/goverlay_splash.svg` with `#38BDF8` and `#60A5FA` layers while preserving dimensions

## 2. Rasterization & ICO Generation

- [x] 2.1 Re-render all PNG icon resolutions (`16x16` to `512x512`) in `data/icons/` and `assets/`
- [x] 2.2 Re-render `data/goverlay_logo.png`, `data/goverlay_splash.png`, and `data/goverlay_splash_small.png`
- [x] 2.3 Generate uncompressed Windows DIB `goverlay.ico` with pixel-hinted 16px/24px/32px frames

## 3. Resource Sync & Verification

- [x] 3.1 Synchronize `overlayunit.lfm` `Icon.Data` and `Picture.Data`
- [x] 3.2 Recompile with `make clean && make` and verify GUI execution and fidelity
