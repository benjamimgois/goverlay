## Purpose

Automates the download, user-space extraction, and Vulkan layer manifest registration of the vkSumi post-processing layer during Goverlay's startup boot splash.

## ADDED Requirements

### Requirement: Automated vkSumi Layer Download and Provisioning
Goverlay SHALL check for the presence of the vkSumi Vulkan layer library and, if missing, automatically download and extract `libVkLayer_vksumi.so` into the user data directory during application boot.

#### Scenario: First launch without vkSumi installed
- **WHEN** Goverlay starts up and detects that `libVkLayer_vksumi.so` is not present in user space or system paths
- **THEN** the startup download thread downloads the vkSumi binary, places it in `~/.local/share/goverlay/layers/vksumi/`, and reports progress on the boot splash screen.

### Requirement: Vulkan Layer Manifest Registration
Goverlay SHALL automatically generate and maintain an implicit Vulkan layer manifest in the user's XDG data directory pointing to the installed vkSumi library.

#### Scenario: Writing implicit layer JSON
- **WHEN** vkSumi is downloaded or verified on startup
- **THEN** Goverlay ensures that `~/.local/share/vulkan/implicit_layer.d/vksumi.json` exists with a valid `library_path` pointing to `~/.local/share/goverlay/layers/vksumi/libVkLayer_vksumi.so`.

### Requirement: Dependency Detection and UI State
The system dependency checker and Home tab module indicators SHALL recognize vkSumi as satisfied when either a system layer or user-space layer manifest is present.

#### Scenario: Displaying vkSumi status on Home tab
- **WHEN** vkSumi is installed in user-space at `~/.local/share/vulkan/implicit_layer.d/vksumi.json`
- **THEN** the Home tab module status displays a green status dot for vkSumi and does not list it in the missing dependencies panel.
