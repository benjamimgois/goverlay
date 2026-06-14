## Why

The `pascube_src/pasvulkan/src/` directory contains 255 unused Free Pascal unit source files (including the entire `Scene3D` renderer, RISC-V emulator, command-line tools, and deprecated ECS systems) that are not compiled or referenced by `pascube`. Removing these files clean up the codebase and reduces the repository size.

## What Changes

- Remove unused Pascal source files from `pascube_src/pasvulkan/src/`:
  - All `PasVulkan.Scene3D.*` files and directories (178 files)
  - The `pascube_src/pasvulkan/src/tools/` directory
  - The `pascube_src/pasvulkan/src/old/` directory
  - Unused feature units (`PasVulkan.VirtualReality.pas`, `PasVulkan.PasRISCVEmulator.pas`, `PasVulkan.FileFormats.*`, etc.)

## Capabilities

### New Capabilities
- `pasvulkan-src-sanitization`: Remove unused Pascal source code files from the pasvulkan framework source directory to reduce clutter.

### Modified Capabilities

## Impact

- 255 unused Pascal source files in `pascube_src/pasvulkan/src/` will be deleted.
