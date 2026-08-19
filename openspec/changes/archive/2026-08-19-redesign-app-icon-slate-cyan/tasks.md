## 1. Vector Master Asset Creation

- [x] 1.1 Create `data/icons/goverlay.svg` with the refined Slate Navy + Cyan HUD geometry, gradient, and glow filters.

## 2. Multi-Resolution Icon Asset Generation

- [x] 2.1 Render `data/icons/512x512/goverlay.png` from the master SVG.
- [x] 2.2 Render `data/icons/256x256/goverlay.png` from the master SVG.
- [x] 2.3 Render `data/icons/128x128/goverlay.png` from the master SVG.

## 3. Branding & Splash Assets Synchronization

- [x] 3.1 Create `data/icons/goverlay_logo.svg` master vector wordmark (All-Caps `GOVERLAY` with integrated HUD).
- [x] 3.2 Update `data/goverlay_logo.png` with the new all-caps wordmark and tight kerning.
- [x] 3.3 Update `data/goverlay_splash_small.png` and `data/goverlay_splash.png` with the modern branding.
- [x] 3.4 Update `overlayunit.lfm` embedded `Picture.Data` and `sidebar_nav.pas` runtime loading for expanded/collapsed sidebar.
- [x] 3.5 Regenerate `goverlay.ico` and sync `assets/` legacy textures/icons.

## 4. Verification and Build Integrity

- [x] 4.1 Verify asset dimensions, alpha channel transparency, and visual fidelity across all target files.
- [x] 4.2 Run test suite (`make test`) to ensure build and packaging integrity (68/68 passed).
