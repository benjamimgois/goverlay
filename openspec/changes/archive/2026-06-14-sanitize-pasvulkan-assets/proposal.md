## Why

The `pascube_src/pasvulkan/src/assets/` directory contains various assets such as unused font files (`notomono.ttf`), unused logo files, and unused 3D scene shaders (`shaders/scene3d/` with 411 files). Removing these unused assets reduces the repository size, simplifies maintenance, and removes clutter from the project codebase.

## What Changes

- Remove the unused font file `pascube_src/pasvulkan/src/assets/fonts/notomono.ttf`.
- Remove the unused logo assets directory `pascube_src/pasvulkan/src/assets/logo/`.
- Remove the unused 3D scene shaders directory `pascube_src/pasvulkan/src/assets/shaders/scene3d/` containing all uncompiled shader source files.

## Capabilities

### New Capabilities
- `pasvulkan-assets-sanitization`: Remove unused assets (fonts, logo, and scene3D shaders) from pasvulkan src to clean up the codebase.

### Modified Capabilities

## Impact

- `pascube_src/pasvulkan/src/assets/fonts/notomono.ttf` will be deleted.
- `pascube_src/pasvulkan/src/assets/logo/` will be deleted.
- `pascube_src/pasvulkan/src/assets/shaders/scene3d/` will be deleted.
