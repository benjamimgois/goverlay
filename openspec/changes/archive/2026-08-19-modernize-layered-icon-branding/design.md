## Context

GOverlay's classic identity is based on cascading overlay screen frames. Following user exploration, Option 2 (dual neon/white screen frame + cascading neon blue layers) was selected. The technical implementation requires vector SVGs, multi-resolution raster PNGs, a pure uncompressed Windows BMP DIB ICO (`goverlay.ico`), and Lazarus LFM resource synchronization.

## Goals / Non-Goals

**Goals:**
- Implement the modernized cascading layered overlay identity across all vector masters (`data/icons/goverlay.svg`, `goverlay_logo.svg`, `goverlay_splash.svg`).
- Render pixel-perfect PNG assets across 16px to 512px.
- Use hand-aligned pixel hinting for low-resolution frames (16x16, 24x24, 32x32) with 100% border opacity (`A=255`) to eliminate Qt6/LCL 1-bit binary mask clipping artifacts.
- Pack spec-compliant uncompressed DIB ICO headers (`biSize=40`) into `overlayunit.lfm` `Icon.Data` to avoid `Range check error`.

**Non-Goals:**
- Changing sidebar navigation layout, buttons, or Pascal GUI logic.

## Decisions

- **Visual Theme:** Option 2 — Screen visor in diagonal Slate Navy (`#0F172A`) to Sapphire Blue (`#38BDF8`), outer neon border (`#4895EF`), inner white core (`#FFFFFF`), and two cascading L-brackets (`#4895EF` and `#2563EB`).
- **Low-Resolution Hinting:** 16x16 and 24x24 icon frames are programmatically drawn with exact 1-2px solid strokes and zero semi-transparent anti-aliasing on outer edges, ensuring clean thresholding in the Lazarus Qt6 widgetset.

## Risks / Trade-offs

- [Qt6 LCL 1-bit mask on titlebars] → Mitigated by generating 100% solid opacity frames on small DIB sizes.
- [PNG inside ICO incompatibility] → Mitigated by compiling pure uncompressed BMP DIB headers without embedded PNG blobs.
