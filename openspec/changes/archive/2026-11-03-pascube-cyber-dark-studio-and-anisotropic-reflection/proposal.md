# Proposal: Cyber Dark Studio Background and Anisotropic Floor Reflection

## Problem
The initial in-app implementation of "Cyber Dark Studio" in `assets/shaders/sky/sky.frag` appeared washed out (medium grey-blue) and had a hollow glowing ring (donut shape) under the cube instead of a realistic reflection:
1. **Swapchain Gamma Encoding**: In Vulkan with `VK_FORMAT_B8G8R8A8_SRGB`, output colors are hardware-converted to sRGB ($C_{linear}^{1/2.2}$). When the shader wrote linear values of 0.045 to 0.12, the display output was elevated to 60–90/255 (a washed out light/medium grey).
2. **Radial Backlight Radius**: The spotlight radius was overly wide with a slow falloff, illuminating almost the entire viewport with cyan light.
3. **Circular Ring Artifact**: The reflection used an annular formula (`smoothstep(0.32, 0.70, rDist) * smoothstep(1.20, 0.70, rDist)`), generating a hollow colored circle rather than an authentic directional reflection.

## Proposed Changes
1. **Calibrate Linear Tone Values for Vulkan sRGB**:
   - Set deep obsidian linear constants (`vec3(0.0020, 0.0025, 0.0040)`) so the hardware sRGB conversion yields authentic dark obsidian `#080a10`.
   - Tighten the backlight spotlight to a focused radial halo directly behind the floating cube (`exp(-spotDistSq * 16.0)`).
   - Recalibrate perspective grid lines to subtle dark cyan traces (`vec3(0.003, 0.012, 0.025)`).
2. **Implement Realistic Anisotropic Floor Reflection**:
   - Replace the hollow ring with an anisotropic reflection that vertically stretches and diffuses horizontally (`spread = 0.05 + dy * 0.20`, `vertDecay = exp(-dy * 10.0)`).
   - Synchronize reflection streaks with the 3D cube's Y-rotation so cyan and violet edge reflections rotate underneath in exact sync with the cube facets.
   - Anchor the cube with a tight ambient occlusion contact shadow (`0.70 + yOffset`).
   - Add a smooth corner vignette to focus contrast in the center.
3. **Synchronize WebGL Prototype**:
   - Update `pascube_simulation.html` to reflect the improved anisotropic floor reflection model.

## Impact
- PasCube idle screen attains deep obsidian contrast matching the simulation design.
- Floor reflections accurately model a polished dark mirror showroom floor.
