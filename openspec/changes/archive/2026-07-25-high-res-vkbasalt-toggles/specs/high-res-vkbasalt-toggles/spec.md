## ADDED Requirements

### Requirement: High Resolution Vector Toggles in VkBasalt
The VkBasalt tab helper SHALL render list toggle switches directly onto `ACanvas` using native vector drawing primitives (ellipse, fillrect) without intermediate bitmap downscaling.

#### Scenario: Rendering Reshade effect list toggles
- **WHEN** `VkReshadeMD3Paint` is called to draw Reshade effect toggles
- **THEN** `DrawToggle` draws vector tracks and thumbs directly on `ACanvas` with native anti-aliasing
- **THEN** no temporary `TBitmap` or `StretchDraw` is used
