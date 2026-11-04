## MODIFIED Requirements

### Requirement: Glossy Studio Floor Reflection
The PasCube environment renderer SHALL render an attenuated glossy reflection of the floating cube and its glowing features onto the perspective floor plane during idle showcase presentation.

#### Scenario: Display glossy reflection underneath floating cube
- **WHEN** PasCube renders the studio background environment
- **THEN** the floor below the horizon displays an anisotropic, vertically softened reflection of the cube's specular highlight and neon cyber edges centered with the cube's rotation.

#### Scenario: Deep obsidian studio contrast
- **WHEN** PasCube displays the Cyber Dark Studio environment
- **THEN** background colors are calibrated for Vulkan sRGB swapchain encoding to present true obsidian dark backdrop with a focused backlight halo and corner vignette.
