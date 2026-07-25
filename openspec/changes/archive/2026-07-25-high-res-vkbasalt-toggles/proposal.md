## Why

In `vkbasalt_tab.pas`, the `DrawToggle` procedure renders item toggles by drawing to an intermediate `TBitmap` at 4x scale (176x96) and downscaling it using `ACanvas.StretchDraw`. On Qt6/LCL Linux environments, nearest-neighbor downscaling produces pixelated and aliased edges compared to the crisp, vector anti-aliased toggles rendered directly on `ACanvas` in `tweaks_md3.pas`. Additionally, allocating and freeing `TBitmap` instances on every paint cycle causes unnecessary overhead during scrolling.

## What Changes

- Replace the `TBitmap` + `StretchDraw` approach in `TVkBasaltTabHelper.DrawToggle` (`vkbasalt_tab.pas`) with direct `ACanvas` vector drawing matching `tweaks_md3.pas`.
- Ensure toggle switches in the VkBasalt Reshade list are rendered crisply with native vector anti-aliasing.

## Capabilities

### New Capabilities
- `high-res-vkbasalt-toggles`: Renders high-resolution, anti-aliased vector toggle switches in the VkBasalt tab using direct Canvas painting.

### Modified Capabilities

## Impact

- `vkbasalt_tab.pas`: `DrawToggle` in `VkReshadeMD3Paint` is updated to draw shapes directly onto `ACanvas`.
