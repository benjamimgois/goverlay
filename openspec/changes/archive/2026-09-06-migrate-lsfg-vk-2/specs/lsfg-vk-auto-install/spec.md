## Purpose

Automates the acquisition, version verification, and Flatpak extension integration for the `lsfg-vk` 2.0 Vulkan layer during application startup and on-demand within GOverlay.

## ADDED Requirements

### Requirement: Automated startup download and installation for native environments
The system SHALL verify the presence of the `lsfg-vk` Vulkan layer during startup download thread execution, and in native environments, automatically download the official pre-built tarball from `builds.lsfg-vk.dev` and extract it into `~/.local` if not already installed.

#### Scenario: Startup check when lsfg-vk is missing in native environment
- **WHEN** GOverlay launches outside a container and `VkLayer_LSFGVK_frame_generation.json` is not detected in user or system layer directories
- **THEN** system downloads `lsfg-vk-2.0.0.tar.xz` with progress updates on the boot splash and extracts its contents to `~/.local/`, setting executable permissions on `bin/lsfg-vk-cli`.

#### Scenario: Startup check when lsfg-vk is already installed
- **WHEN** GOverlay launches and `VkLayer_LSFGVK_frame_generation.json` is detected
- **THEN** system logs that `lsfg-vk` is available and proceeds immediately to the next startup check.

### Requirement: Native Flatpak extension integration for Flatpak environments
The system SHALL integrate with the official Flathub Vulkan layer extension `org.freedesktop.Platform.VulkanLayer.lsfgvk` within Flatpak packages, skipping manual archive downloading inside the sandbox and persisting user configuration through `xdg-config/lsfg-vk:create`.

#### Scenario: Startup check in Flatpak environment
- **WHEN** GOverlay launches inside Flatpak (`IsRunningInFlatpak` is true)
- **THEN** system verifies the layer via Flatpak extension or existing layer registration without initiating `curl` or `tar` operations to the sandboxed user home.

### Requirement: On-demand manual installation and update check from UI
The system SHALL provide an interactive installation/update trigger in the Software Status card allowing the user to initiate or refresh the `lsfg-vk` 2.0 runtime with visual progress reporting.

#### Scenario: User clicks install or update for lsfg-vk
- **WHEN** user clicks the install or update button adjacent to `lsfg-vk` in the Software Status card
- **THEN** system initiates a background thread to fetch the latest archive, extracts the runtime into `~/.local`, and updates the status dot and version label upon completion.
