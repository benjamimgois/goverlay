## Why

Although the main unused Vulkan directories have been removed, the remaining dependencies in `pascube_src/pasvulkan/externals/` still contain significant bloat. Specifically, `pasdblstrutils` contains over 260MB of floating-point parsing test cases (`testdata/`), and `pasgltf` contains demo project files and compiled binary viewers. Furthermore, `pasvulkan/libs/` contains precompiled libraries for Windows, macOS, and Android that are completely unused since GOverlay and PasCube only target Linux 64-bit.

## What Changes

- **Testdata Removal**:
  - Delete `pascube_src/pasvulkan/externals/pasdblstrutils/testdata/` to remove 262MB of unused test text files.
- **Unused Demos and Binary Cleanups**:
  - Delete Delphi/FPC project directories and compiled binary viewer outputs under `pascube_src/pasvulkan/externals/pasgltf/` (specifically `bin/`, `src/viewer/`, `src/combineanimations/`, and `src/smartcombineanimations/`).
  - Completely remove untracked filesystem remnants of previously deleted libraries (`flre/`, `pasllm/`, and `poca/`).
- **Platform Libraries Optimization**:
  - Delete all precompiled static and dynamic libraries in `pascube_src/pasvulkan/libs/` that target non-Linux-64 platforms: `libktxwin64`, `libpngandroid`, `sdl20androidarm32`, `sdl20androidarm64`, `sdl20androidi386`, `sdl20androidx64`, `sdl20linux32`, `sdl20macosx32`, `sdl20macosx64`, `sdl20win32`, and `sdl20win64`.

## Capabilities

### New Capabilities

- `pasvulkan-externals-sanitization`: Clean up unused testdata, platform-specific compiled binaries, and multi-platform library files within the PasVulkan engine to minimize repository footprint.

### Modified Capabilities

None.

## Impact

- **Affected Code**: None (only removes unused directories, tests, demos, and unused binaries/libs).
- **Repository Size**: Further footprint reduction by over 300MB.
