## Context

The `pasvulkan` framework embedded inside `pascube_src/` contains 3D rendering features and assets that are not used by the `pascube` benchmark binary. Particularly, the `scene3d` shaders, unused logos, and the `notomono.ttf` font are not compiled or referenced, yet they clutter the codebase and increase repository size (~39MB of unused files).

## Goals / Non-Goals

**Goals:**
- Delete the unused `pascube_src/pasvulkan/src/assets/shaders/scene3d/` directory.
- Delete the unused `pascube_src/pasvulkan/src/assets/logo/` directory.
- Delete the unused font file `pascube_src/pasvulkan/src/assets/fonts/notomono.ttf`.
- Verify that both GOverlay and PasCube compile and run successfully after these deletions.

**Non-Goals:**
- Modifying canvas shaders (`pascube_src/pasvulkan/src/assets/shaders/canvas/`) since they are compiled and embedded as assets for UI rendering.
- Deleting or editing any other active framework assets.

## Decisions

### Decision 1: Delete the `shaders/scene3d/` folder
- **Rationale**: The `pascube` binary does not use the `Scene3D` renderer framework. The compiler does not compile any `PasVulkan.Scene3D.*` units, so these shader assets are completely unused.
- **Alternatives**: Keeping them would retain unnecessary files and inflate repository size.

### Decision 2: Delete the `logo/` assets folder
- **Rationale**: The logo assets folder is not used or packaged by `pascube`.
- **Alternatives**: None needed.

### Decision 3: Delete the `fonts/notomono.ttf` file
- **Rationale**: In `convert.dpr`, the `notomono.ttf` conversion line is commented out, and `hackregular.ttf` is used instead. Thus, `notomono.ttf` is completely unused.
- **Alternatives**: Keep it, but it serves no purpose.

## Risks / Trade-offs

- **[Risk]** Missing assets during compile time.
  - *Mitigation*: FPC is a smart compiler that does not compile/link units that are not in the transitive closure of the main program uses clause. We verified that none of the compiled objects are part of the `Scene3D` namespace.
