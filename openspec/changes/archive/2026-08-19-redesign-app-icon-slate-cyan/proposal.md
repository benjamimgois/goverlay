# Proposal: Redesign GOverlay Application Icon with Slate Navy & Cyan Palette

## Why

With the recent UI modernization of GOverlay towards a unified **Slate Navy** dark theme and vibrant **Cyan Accent** (`#30BEF0`), the legacy monochrome/grayscale application icon (dark gray gradient with isolated white brackets and orbiting dots) feels detached from the app's current aesthetic.

Redesigning the application icon to feature a streamlined central screen with a rich Slate-to-Cyan gradient and four neon cyan framing brackets creates complete brand cohesion across desktop launchers, docks, taskbars, splash screens, and header logos, while improving visual balance, symmetry, and contrast across both dark and light desktop environments.

## What Changes

- **Streamlined HUD Icon Geometry:** Redesign the official GOverlay application icon to focus on the core HUD overlay concept (central screen/visor enclosed by 4 corner framing brackets), eliminating external asymmetrical orbital dots for cleaner symmetry and scalability.
- **Color Palette Alignment:**
  - Central visor: Smooth diagonal gradient from Deep Slate Navy (`#141B23` / `#1A283B`) to vibrant Cyan (`#219FD1` / `#3CD0F6`).
  - Framing brackets: L-shaped rounded corner brackets in vibrant Neon Cyan (`#30BEF0`) with crisp high-contrast core highlights (`#E0F7FF`).
  - Subtle visor border: High-tech boundary (`#2D3A54` to `#4FD1F8`).
- **Standardized Vector & Raster Asset Generation:**
  - Master editable vector source (`data/icons/goverlay.svg`).
  - Multi-resolution PNG icon hierarchy (`data/icons/128x128/goverlay.png`, `data/icons/256x256/goverlay.png`, `data/icons/512x512/goverlay.png`, plus small variants).
  - Updated branding logo assets (`data/goverlay_logo.png`, `data/goverlay_splash_small.png`).

## Capabilities

### New Capabilities
- `app-icon-branding`: Defines requirements for the modernized vector and raster application icon assets, visual branding, and multi-resolution packaging fidelity for GOverlay across desktop environments.

### Modified Capabilities
- (None - no behavioral requirements for existing capabilities are modified).

## Impact

- **Affected Files & Assets:**
  - `data/icons/128x128/goverlay.png`
  - `data/icons/256x256/goverlay.png`
  - `data/icons/512x512/goverlay.png`
  - `data/icons/goverlay.svg` (new master vector asset)
  - `data/goverlay_logo.png`
  - `data/goverlay_splash_small.png`
- **Packaging & Desktop Integration:** Linux `.desktop` launcher icon, Flatpak exports, AppImage, DEB/RPM packaging assets.
- **Dependencies:** None. Build scripts continue using standard icon paths.
