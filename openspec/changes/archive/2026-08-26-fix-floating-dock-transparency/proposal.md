## Why

The floating action pill dock in GOverlay has dark/black borders and clipping artifacts around its outer corners and button edges. This occurs because the dock draws a hard black drop shadow `(0, 0, 0)` that leaks outside the pill geometry, while its container uses separate child `TPaintBox` widgets that erase rectangular areas over the background. Removing the hard drop shadow, unifying the rendering onto a single continuous canvas with exact semicircular corner radii (`Rad = Height div 2 = 19px`), and harmonizing the container background with the active interface tone ensures a clean, 100% transparent and perfectly rounded pill bar.

## What Changes

- **Remove Hard Drop Shadow**: Eliminate the `(0, 0, 0)` drop shadow `RoundRect` that creates a 2px dark band along the right and bottom edges of the pill and Finish button.
- **Unified Single-Surface Rendering**: Eliminate individual child `TPaintBox` controls (`FMenuBox`, `FPreviewBox`, `FAddBox`, `FFinishBox`) in favor of unified rendering on `FPillBox` with coordinated hit-testing.
- **Accurate Corner Curvature**: Use exact semicircular radius `Rad := PB.Height div 2` (19px) to prevent Qt6 octagonal/chamfered clipping.
- **Seamless Interface Background Blending**: Dynamically fill the bounding box outside the pill curve with the exact interface background tone (`#161A28` on dark theme, `#F5F5F5` on light theme).
- **Integrated Primary Finish Section**: Retain solid blue primary accent fill for the Finish button seamlessly spanning the right portion of the pill.

## Capabilities

### Modified Capabilities
- `floating-action-dock`: Update rendering requirements to ensure seamless rounded curvature, elimination of hard black drop shadows, and true transparency/background harmonization.

## Impact

- `floating_dock.pas`: Refactored to unified single-surface painting and event handling without hard shadows.
- `tests/gui/gui_test_cases.pas`: Verified across all automated GUI test cases.
