## Why

Installing the aarch64 Flatpak build on a Single Board Computer (SBC) like Orange Pi 5 running Armbian results in a "List index (0) out of bounds" error on startup. This happens because SBCs do not have PCI-based GPUs, so the `lspci` command returns no display/video controllers, leading to an empty `pcidevComboBox` and subsequent out-of-bounds array access in Pascal.

## What Changes

- Add guards to prevent accessing index 0 or out-of-bounds indexes on `pcidevComboBox` when it is empty.
- Safely handle cases where `lspci` returns no GPU controllers, keeping the combo box and GPU description fields blank rather than throwing an exception.
- Ensure change event handlers for the GPU selection combo box check bounds before indexing into the GPU description list.

## Capabilities

### New Capabilities

<!-- None -->

### Modified Capabilities

<!-- None -->

## Impact

- `overlayunit.pas`: Safer GPU initialization and dropdown indexing.
