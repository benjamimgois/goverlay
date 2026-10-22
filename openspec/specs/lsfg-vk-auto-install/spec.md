## Purpose

Automates the acquisition, version verification, and Flatpak extension integration for the `lsfg-vk` 2.0 Vulkan layer during application startup and on-demand within GOverlay.

## Requirements

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
The system SHALL provide an interactive installation/update trigger and status indicator in the Software Status card and Home tab, evaluating remote updates strictly against official stable releases from `builds.lsfg-vk.dev` while ignoring development git autobuilds and pre-releases. Remote update discovery SHALL return an empty string rather than hardcoded legacy version fallbacks on failure, and update banners SHALL only display when the remote release is semantically newer than installed.

#### Scenario: User clicks install or update for lsfg-vk
- **WHEN** user clicks the install or update button adjacent to `lsfg-vk` in the Software Status card
- **THEN** system initiates a background thread to fetch the latest official stable archive, extracts the runtime into `~/.local`, and updates the status dot and version label upon completion.

#### Scenario: Background update check when newer git commit exists upstream
- **WHEN** an upstream git commit build exists on `builds.lsfg-vk.dev` (e.g. `Latest git version`) but the official `Latest release` matches the installed version
- **THEN** system SHALL NOT report an update available, SHALL NOT show an update indicator (`installed → remote`), and SHALL NOT display the install update button.

#### Scenario: Remote discovery fails on network or service error
- **WHEN** query to `builds.lsfg-vk.dev` fails or times out
- **THEN** system returns an empty remote version rather than a hardcoded legacy version, suppressing false downgrade notices.
