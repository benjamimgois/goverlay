## Why

The backmost cascading layer in the current layered icon (`#2563EB`) has low luminance and subtle contrast on dark UI surfaces and window titlebars. Elevating the two cascading layers to Sky Blue (`#38BDF8`) and Light Sapphire (`#60A5FA`) improves visual contrast, depth, and vibrancy while preserving the calibrated dimensions and geometric proportions of the branding assets.

## What Changes

- **Layer Palette Enhancement:** Update the two cascading overlay layer strokes in all vector assets (`data/icons/goverlay.svg`, `goverlay_logo.svg`, `goverlay_splash.svg`) from `#4895EF` / `#2563EB` to Sky Blue (`#38BDF8`) and Light Sapphire (`#60A5FA`).
- **Dimension Preservation:** Strictly maintain current pixel-calibrated dimensions, margins, kerning, and positions across header logo and splash screen components.
- **Multi-Resolution Asset Re-rendering:** Regenerate all PNG icon resolutions (`16x16` to `512x512`), header logos, and splash screen graphics with high-fidelity anti-aliasing.
- **Pixel-Hinted DIB ICO & Resource Synchronization:** Update `goverlay.ico` with `#38BDF8` and `#60A5FA` solid frames for 16px/24px/32px resolutions, and update `overlayunit.lfm` resources.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `app-icon-branding`: Update color specifications and contrast requirements for the cascading overlay layers.

## Impact

- `data/icons/goverlay.svg`, `data/icons/goverlay_logo.svg`, `data/icons/goverlay_splash.svg`
- `data/icons/{16x16..512x512}/goverlay.png`, `assets/icons/goverlay.png`, `assets/textures/goverlay.png`
- `data/goverlay_logo.png`, `data/goverlay_splash.png`, `data/goverlay_splash_small.png`
- `goverlay.ico`, `overlayunit.lfm`
