## MODIFIED Requirements

### Requirement: Automated vkSumi Layer Download and Provisioning
Goverlay SHALL check for the presence of the vkSumi Vulkan layer library and, if missing and running in a native (non-Flatpak) environment, automatically download and extract `libVkLayer_vksumi.so` into the user data directory during application boot. Downloads SHALL enforce HTTP error failure checking and validate binary integrity before any layer registration.

#### Scenario: First launch without vkSumi installed
- **WHEN** Goverlay starts up natively and detects that `libVkLayer_vksumi.so` is not present in user space or system paths
- **THEN** the startup download thread downloads the vkSumi binary, validates that the download was successful, places it in `~/.local/share/goverlay/layers/vksumi/`, and reports progress on the boot splash screen.

#### Scenario: Startup inside Flatpak environment
- **WHEN** Goverlay starts up inside a Flatpak container
- **THEN** the startup download thread skips vkSumi download and host user-space layer provisioning, preventing incomplete or corrupt layers from being registered on the host.

### Requirement: Vulkan Layer Manifest Registration
Goverlay SHALL automatically generate and maintain an implicit Vulkan layer manifest pointing to the installed vkSumi library only when a valid, non-empty shared object binary exists on disk.

#### Scenario: Writing implicit layer JSON
- **WHEN** vkSumi is verified on startup and `libVkLayer_vksumi.so` is confirmed to be a valid binary file exceeding minimum size threshold
- **THEN** Goverlay ensures that `~/.local/share/vulkan/implicit_layer.d/vksumi.json` exists with a valid `library_path` pointing to `~/.local/share/goverlay/layers/vksumi/libVkLayer_vksumi.so`.

#### Scenario: Corrupted or missing download prevents manifest registration
- **WHEN** a vkSumi binary download fails, returns an HTTP error code, or produces an invalid/corrupt payload
- **THEN** Goverlay does not generate or update `vksumi.json` in the Vulkan implicit layers directory.
