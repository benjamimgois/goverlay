# Proposal: Modern PasCube Shader (Cyber Edge + Iridescent Fresnel) and High-Legibility Hardware Specs Font

## Why
In the initial idle screen of PasCube:
1. The hardware specifications pill card at the bottom (`CPU | GPU | Vulkan 1.3 | 1080p`) uses a small font scale (`0.90x`) and tight pill padding, making it hard to read on 1080p and high-DPI displays.
2. The idle cube presentation uses a plain, flat directional light with muted grey specular highlights, lacking visual depth and modern character before the benchmark starts.

## What Changes
1. **Hardware Specifications Pill Typography & Layout**:
   - Increase text font scale from `0.90` to `1.30` in `UnitPasCubeScreen.pas`.
   - Expand the pill card dimensions (height `52.0px`, dynamic width scaled to font size) and center vertical text alignment (`dockY + 13.0px`).
   - Increase text brightness (`240, 240, 245`) with cyan-accented vertical separators (`|`) for clear, instant reading.

2. **Modern Idle Cube Shader (Cyber Edge Neon + Iridescent Electrochemical Fresnel)**:
   - In `assets/shaders/cube/cube.frag`, upgrade the idle state shader mode (`gpuStressMode <= 0.5`):
     - **Cyber Edge Glow**: Anti-aliased procedural neon glow along cube edges using `inTexCoord`, with subtle breathing pulsation.
     - **Iridescent Fresnel**: Electro-chemical multi-phase Fresnel reflection (shifting between electric cyan, deep blue, and violet) on grazing angles.
     - **Dark Brushed Titanium Base**: Rich dark metallic base with sharp directional specular highlight.
   - Recompile `cube.frag` to `cube_frag.spv` using `glslangValidator`.

## Capabilities
- `pascube-ui-presentation`: Improved readability and proportional pill sizing for system specifications on idle menu.
- `pascube-cube-rendering`: Dynamic cyberpunk neon edge + iridescent metallic surface shader for the PasCube showcase cube.

## Impact
- Files modified:
  - `assets/shaders/cube/cube.frag`
  - `assets/shaders/cube/cube_frag.spv` (compiled binary)
  - `pascube_src/src/UnitPasCubeScreen.pas`
