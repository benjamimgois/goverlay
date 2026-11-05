# Proposal: Modern Action Buttons and Clean Hero Layout in PasCube

## Why

The PasCube benchmark interface currently renders redundant hardware specification pills on both the idle menu and the results screen, overcrowding the bottom area and obscuring the 3D scene's glossy floor lighting reflections. Additionally, action buttons across both the idle start menu and the final benchmark results screen use generic, uniform dark-grey boxes with identical visual weight and low contrast. In the results view, the `Clear results` action uses a dated, muddy-red fill that clashes with Goverlay's modern dark theme palette.

Modernizing these interactive elements with Goverlay's Cyber-Accent aesthetic (`#30BEF0` cyan primary accent, dark ghost secondary, and refined danger styling) clarifies user action hierarchy, increases visual polish, and provides a cohesive experience between Goverlay and the PasCube benchmark tool.

## What Changes

- **Remove Hardware Specs Pill from Idle Menu**: Omit the bottom system specifications pill card (`Ryzen 7... | RX 7900 XTX...`) from the idle menu (`bpIdleMenu`), giving maximum visual clearance to the 3D cube and floor glow reflections. Keep full specifications prominently presented in the results screen hardware card (`bpResults`).
- **Modernize Idle Menu Buttons**:
  - `Start benchmark`: Styled as the primary Call-to-Action (CTA) with a luminous Goverlay Cyan border (`#30BEF0`), deep dark-blue translucent fill, high-contrast white typography, and a directional play glyph (`▶`). On hover, the button gains an illuminated cyan glow.
  - `View results`: Styled as a sleek secondary Ghost button with Goverlay's dark input palette (`rgb(22, 26, 40)` / `rgb(55, 70, 108)` border) and an index glyph (`≡`).
- **Modernize Results View Action Buttons**:
  - `Return to Menu`: Styled as the primary navigation action with Goverlay Cyan CTA styling and a back glyph (`◀`).
  - `Submit results`: Styled as a secondary Ghost action with dynamic submission state feedback (idle, submitting amber, submitted green, error red).
  - `Clear results`: Redesigned from the washed-out flat red box into Goverlay's sophisticated dark danger style (subtle crimson border, deep dark-red tinted fill, and rose hover illumination with glyph `✕`).
- **Refined Button Geometry & Hover Detection**: Adjust button vertical anchoring, padding, and hit-testing rectangles in `UnitPasCubeScreen.pas` for balanced proportioning.

## Capabilities

### Modified Capabilities
- `pascube-ui-presentation`: Updates the `System Specifications Summary Pill` requirement so the pill is only rendered on the results overlay, and introduces modern button hierarchy requirements for both idle menu and results views.

## Impact

- **Source Files**: `pascube_src/src/UnitPasCubeScreen.pas` (`DrawMenuOverlay`, `DrawResultsOverlay`, hit-testing routines `IsStartButtonHovered`, `IsViewResultsButtonHovered`, `IsReturnButtonHovered`, `IsSubmitButtonHovered`, `IsClearButtonHovered`).
- **Dependencies & APIs**: No external dependency changes; utilizes existing PasVulkan SDF text/box rendering (`UnitTextOverlay.pas`).
