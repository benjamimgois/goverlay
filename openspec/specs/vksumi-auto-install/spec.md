# vksumi-auto-install Specification

## Purpose
Automates the download, user-space extraction, and Vulkan layer manifest registration of the vkSumi post-processing layer during Goverlay's startup boot splash.

## Requirements

### Requirement: Automated vkSumi Layer Download and Provisioning
Goverlay SHALL check for the presence and version of the vkSumi Vulkan layer library and, if missing or outdated and running in a native (non-Flatpak) environment, automatically download and extract `libVkLayer_vksumi.so` into the user data directory during application boot. Downloads SHALL enforce HTTP error failure checking, validate binary integrity before any layer registration, and record the installed version tag.

#### Scenario: First launch without vkSumi installed
- **WHEN** Goverlay starts up natively and detects that `libVkLayer_vksumi.so` is not present in user space or system paths
- **THEN** the startup download thread downloads the latest vkSumi binary, validates that the download was successful, places it in `~/.local/share/goverlay/layers/vksumi/`, records the release version, and reports progress on the boot splash screen.

#### Scenario: Startup inside Flatpak environment
- **WHEN** Goverlay starts up inside a Flatpak container
- **THEN** the startup download thread skips vkSumi download and host user-space layer provisioning, preventing incomplete or corrupt layers from being registered on the host.

#### Scenario: Update available for existing vkSumi installation
- **WHEN** Goverlay starts up natively, detects that a newer vkSumi release is available on GitHub compared to the locally recorded version, and initiates startup downloads
- **THEN** the download thread replaces the existing `libVkLayer_vksumi.so` with the updated binary, validates its integrity, updates the manifest, and updates the recorded version tag.

### Requirement: Vulkan Layer Manifest Registration
Goverlay SHALL automatically generate and maintain an implicit Vulkan layer manifest pointing to the installed vkSumi library only when a valid, non-empty shared object binary exists on disk.

#### Scenario: Writing implicit layer JSON
- **WHEN** vkSumi is verified on startup and `libVkLayer_vksumi.so` is confirmed to be a valid binary file exceeding minimum size threshold
- **THEN** Goverlay ensures that `~/.local/share/vulkan/implicit_layer.d/vksumi.json` exists with a valid `library_path` pointing to `~/.local/share/goverlay/layers/vksumi/libVkLayer_vksumi.so`.

#### Scenario: Corrupted or missing download prevents manifest registration
- **WHEN** a vkSumi binary download fails, returns an HTTP error code, or produces an invalid/corrupt payload
- **THEN** Goverlay does not generate or update `vksumi.json` in the Vulkan implicit layers directory.

### Requirement: Dependency Detection and UI State
The system dependency checker and Home tab module indicators SHALL recognize vkSumi as satisfied when either a system layer or user-space layer manifest is present.

#### Scenario: Displaying vkSumi status on Home tab
- **WHEN** vkSumi is installed in user-space at `~/.local/share/vulkan/implicit_layer.d/vksumi.json`
- **THEN** the Home tab module status displays a green status dot for vkSumi and does not list it in the missing dependencies panel.

### Requirement: Automated Upstream Version Tracking and Update Detection
The system SHALL query the latest vkSumi release from the upstream GitHub repository using a non-blocking timeout and determine if an update is available by comparing the remote release tag with the locally recorded version.

#### Scenario: Newer release found on upstream GitHub
- **WHEN** the system checks for updates and the remote release tag is newer than the locally recorded version
- **THEN** `IsVkSumiUpdateAvailable` evaluates to `True`, triggering download splash verification on startup.

#### Scenario: Upstream version matches local or network unavailable
- **WHEN** the remote release tag matches the local version or the network request times out
- **THEN** `IsVkSumiUpdateAvailable` evaluates to `False`, avoiding unnecessary downloads or application launch delays.
