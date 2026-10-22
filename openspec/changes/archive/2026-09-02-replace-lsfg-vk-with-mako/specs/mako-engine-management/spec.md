## Purpose

Manages the dynamic discovery, download, user-space installation, version tracking, boot-time provisioning, and DLL compatibility validation of the standalone MAKO Renderer for Vulkan frame generation and spatial scaling.

## ADDED Requirements

### Requirement: Dynamic Download and Headless Installation of MAKO Renderer
The system SHALL support querying GitHub releases for the MAKO repository, downloading the latest `MAKO-Renderer-*.tar.xz` archive matching the `render-v*` release tags, and performing a non-interactive user-space installation.

#### Scenario: Installing MAKO Renderer when not present
- **WHEN** user clicks the "Install MAKO" button or triggers dynamic installation on the Lossless Scaling tab
- **THEN** system downloads the latest renderer archive with progress feedback, extracts it, executes the headless installer (`MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1`), and updates the UI status upon completion.

### Requirement: Startup Splash Screen Auto-Provisioning
The system SHALL verify the presence of the MAKO Vulkan layer during application startup boot and automatically download and install it in the background if missing, reporting progress on the splash screen alongside OptiScaler, DLSS-Enabler, and vkSumi.

#### Scenario: First application launch without MAKO installed
- **WHEN** Goverlay boots and `TStartupDownloadThread` executes its initial dependency checks
- **THEN** system checks for `VkLayer_MAKO_render.json` and, if absent, invokes `CheckAndInstallMako` to download and install the layer in user-space with progress reported on the splash screen before the main window opens.

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json` or equivalent manifest, and alert the user when a newer release is available.

#### Scenario: Checking for MAKO updates
- **WHEN** user opens the Lossless Scaling tab or clicks "Check for Updates"
- **THEN** system compares the local version against the latest `render-v*` tag from GitHub and displays a green notification badge if an update is available.

### Requirement: Lossless DLL Compatibility Inspection
The system SHALL inspect the selected `Lossless.dll` file using `mako-cli inspect-dll` to verify the presence and compatibility of required LSFG FP32/FP16 models and LS1 spatial scaling shader resources.

#### Scenario: User selects or auto-detects Lossless.dll
- **WHEN** a path to `Lossless.dll` is configured in the UI and MAKO is installed
- **THEN** system executes `mako-cli inspect-dll` and displays detailed status badges indicating compatibility for FP16, FP32, and LS1 upscaling.

### Requirement: Dependency Detection and Home Tab Integration
The system dependency checker and Home tab module indicators SHALL recognize MAKO as satisfied when either system or user-space `VkLayer_MAKO_render.json` implicit layer manifests are detected.

#### Scenario: Verifying MAKO dependency on Home tab
- **WHEN** MAKO layer manifest exists in `~/.local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json` or system paths
- **THEN** the Home tab module status for Frame Generation displays a green status indicator and shows the installed MAKO version.
