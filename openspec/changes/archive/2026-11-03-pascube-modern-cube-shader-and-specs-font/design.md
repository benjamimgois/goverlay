# Design: PasCube Modern Cube Shader and High-Legibility Specs Font

## Context
PasCube is GOverlay's real-time Vulkan benchmark and stress test utility. In its idle menu state (`bpIdleMenu`), users see the rotating cube and bottom buttons. The specifications pill card at the bottom was reported as barely legible, and the cube's visual presentation was deemed too plain.

## Architecture & Technical Decisions

### 1. Typography and Pill Layout
In `UnitPasCubeScreen.pas`:
- `subtitle` is constructed from CPU name, cleaned GPU name, Vulkan version, and resolution preset.
- The font scale is raised to `1.30`.
- The width calculation `specsW` scales with the 1.30 factor:
  ```pascal
  specsW := (Length(subtitle) * charWidth * 1.30) + 64.0;
  dockY := 1080.0 - 195.0;
  app.TextOverlay.AddBox(cx - (specsW * 0.5), dockY, specsW, 52.0, ...);
  app.TextOverlay.AddText(cx, dockY + 13.0, 1.30, toaCenter, subtitle, ...);
  ```
- Separator characters can be styled or given high contrast against the dark background.

### 2. Shader Implementation (`cube.frag`)
In `assets/shaders/cube/cube.frag`, when `gpuStressMode <= 0.5`:
- Compute distance to UV boundary:
  ```glsl
  vec2 edgeDist = min(inTexCoord, vec2(1.0) - inTexCoord);
  float distToBorder = min(edgeDist.x, edgeDist.y);
  float edge = 1.0 - smoothstep(0.015, 0.045, distToBorder);
  ```
- Neon pulsation using `pushConsts.params.w` or local continuous trigonometric modulation.
- Multi-tone iridescent Fresnel:
  ```glsl
  float fresnel = pow(1.0 - max(dot(N, V), 0.0), 3.2);
  vec3 iridCyan = vec3(0.12, 0.75, 0.95);
  vec3 iridViolet = vec3(0.55, 0.20, 0.85);
  vec3 iridColor = mix(iridCyan, iridViolet, clamp(fresnel * 1.5, 0.0, 1.0));
  vec3 iridGlow = iridColor * fresnel * 1.6;
  ```
- Titanium satin base with directional light:
  ```glsl
  vec3 ambient = vec3(0.14);
  vec3 titanium = vec3(0.20, 0.22, 0.26) * (ambient + diff * 0.8) + vec3(spec);
  ```
- Resulting composite: `titanium + iridGlow + neonGlow * edge`.

### 3. Build & Compilation
- `glslangValidator -V assets/shaders/cube/cube.frag -o assets/shaders/cube/cube_frag.spv`
- Compile PasCube with `lazbuild pascube_src/pascube.lpi`
