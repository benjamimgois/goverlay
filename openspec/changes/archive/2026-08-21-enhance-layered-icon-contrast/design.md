## Context

The user selected Option A from color exploration: elevating the two cascading overlay layers to Sky Blue (`#38BDF8`) and Light Sapphire (`#60A5FA`). A critical requirement is to preserve all existing visual dimensions, kerning, and layout bounds without modification.

## Goals / Non-Goals

**Goals:**
- Update the cascading overlay layers from `#4895EF` / `#2563EB` to `#38BDF8` (Middle layer) and `#60A5FA` (Back layer).
- Maintain 100% identical canvas sizes, bounding boxes, element positioning, and kerning in all SVGs and PNGs.
- Regenerate uncompressed Windows BMP DIB `goverlay.ico` with pixel-hinted `#38BDF8` / `#60A5FA` solid frames.
- Update `overlayunit.lfm` `Icon.Data` and `Picture.Data`.

**Non-Goals:**
- Altering any layout dimensions, margins, font sizes, or padding.

## Decisions

- **Palette Definition:**
  - Middle Layer 2: `#38BDF8` (Sky Blue)
  - Backmost Layer 3: `#60A5FA` (Light Sapphire)
  - Front Square Frame: `#FFFFFF` (Solid White)
  - Visor Screen: `#111822` to `#4895EF` (Slate Navy to Sapphire diagonal gradient)
- **Low-Resolution Pixel Hinting:** Update 16px, 24px, and 32px ICO frames with 100% solid opacity (`A=255`) on the `#38BDF8` and `#60A5FA` layer pixels to avoid Qt6/LCL 1-bit mask threshold artifacts.

## Risks / Trade-offs

- [Risk of dimension shift during re-render] → Prevented by utilizing the exact calibrated geometry and bounding box parameters.
