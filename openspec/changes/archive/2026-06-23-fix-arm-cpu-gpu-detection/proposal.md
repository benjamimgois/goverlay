## Why

On ARM single board computers (like the Orange Pi Zero 3), the CPU name is often missing from `/proc/cpuinfo` (yielding 'Unknown CPU'), and Bifrost v7 Mali GPUs are not recognized by Mesa's panvk Vulkan driver unless the environment variable `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1` is set (causing a fallback to `llvmpipe` CPU software rendering). This change addresses both issues to ensure correct hardware detection and driver loading during benchmarks.

## What Changes

- Modify CPU name detection in PasCube to fall back to `lscpu` and check alternate `/proc/cpuinfo` fields if the standard `model name` is missing.
- Set the environment variable `PAN_I_WANT_A_BROKEN_VULKAN_DRIVER=1` at PasCube startup to allow the Mali GPU Vulkan driver to load successfully on Bifrost v7 devices.

## Capabilities

### New Capabilities

### Modified Capabilities

- `pascube-benchmark-compatibility`: Add requirements for ARM CPU detection fallback strategies and Mesa Mali GPU driver environment overrides during Vulkan initialization.

## Impact

- Affected files: `pascube_src/src/UnitPasCubeScreen.pas` (CPU detection fallback), `pascube_src/pascube.lpr` (Vulkan driver environment setup).
