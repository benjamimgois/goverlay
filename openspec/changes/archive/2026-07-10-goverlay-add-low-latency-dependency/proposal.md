## Why

The vulkan-low-latency-layer is a useful Vulkan implicit layer that reduces input latency in games. To help users ensure it is properly installed and configured on their system, GOverlay should verify its presence and display its status on the Home tab alongside other system dependencies.

## What Changes

- Add `vulkan-low-latency-layer` as a tracked dependency in GOverlay's dependency checker.
- Identify the layer on disk by looking for its Vulkan implicit layer JSON metadata file (`low_latency_layer.json`) or fallback shared library (`libVkLayer_KORTHOS_LowLatency`).
- Expand the Home tab dependencies grid from a 3x2 to a 3x3 layout to display the new dependency.

## Capabilities

### New Capabilities

- `low-latency-dependency`: Verifies the installation status of vulkan-low-latency-layer by checking for its configuration JSON and binary files on disk, and presents its status on the Home page.

### Modified Capabilities

<!-- None -->

## Impact

- `home_tab.pas`: Updates the layout of the dependencies card to a 3x3 grid to accommodate the new dependency, adding its display name, keys, and hover hints.
- `goverlay_system.pas` and `apputils.pas`: Updates `CheckDependencies` to verify the existence of the layer JSON metadata files and shared library on disk.
- `overlayunit.pas`: Declared arrays `FHomeDepDots` and `FHomeDepLbls` are already sized for up to 8 items, so no changes are needed there.
