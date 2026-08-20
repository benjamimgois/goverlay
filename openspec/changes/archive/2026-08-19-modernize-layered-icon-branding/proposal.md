## Why

The user prefers preserving GOverlay's iconic original identity—representing cascading screen overlays ("Overlays over Overlays")—while elevating it with modern aesthetic standards: a rich Slate Navy to Sapphire Blue diagonal gradient, dual neon borders with a white core highlight, and dedicated pixel-hinted icon frames to guarantee crisp rendering across all desktop environments without green subpixel distortion.

## What Changes

- **Vector Masters Redesign:** Reconstruct the official application icon (`data/icons/goverlay.svg`), wordmark logo (`data/icons/goverlay_logo.svg`), and splash screen (`data/icons/goverlay_splash.svg`) using the modernized cascading layered overlay geometry with Slate Navy (`#111822`) to Sapphire Blue (`#4895EF`) gradient and dual neon/white strokes.
- **Multi-Resolution Asset Hierarchy:** Generate pristine PNG assets (`16x16` through `512x512`), header logos, and splash screen graphics.
- **Pixel-Hinted DIB ICO:** Build an uncompressed multi-resolution Windows DIB ICO (`goverlay.ico`) with pixel-aligned 16px/24px/32px frames to ensure 100% opacity on borders, preventing Qt6/LCL 1-bit mask threshold artifacts and `Range check error`.
- **Form Resource Sincronization:** Update `overlayunit.lfm` `Icon.Data` and `Picture.Data` to embed the new layered branding into the compiled binary.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `app-icon-branding`: Update requirements and scenarios from the HUD corner bracket visor to the modernized cascading layered overlay identity.

## Impact

- `data/icons/goverlay.svg`, `data/icons/goverlay_logo.svg`, `data/icons/goverlay_splash.svg`
- `data/icons/{128x128,256x256,512x512}/goverlay.png`, `assets/icons/goverlay.png`, `assets/textures/goverlay.png`
- `data/goverlay_logo.png`, `data/goverlay_splash.png`, `data/goverlay_splash_small.png`
- `goverlay.ico`, `overlayunit.lfm`
