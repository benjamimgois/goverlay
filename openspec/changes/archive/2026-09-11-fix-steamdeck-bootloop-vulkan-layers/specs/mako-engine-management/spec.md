## MODIFIED Requirements

### Requirement: Startup Splash Screen Auto-Provisioning
The system SHALL verify the presence of the MAKO Vulkan layer during application startup boot in native environments and automatically download and install it in the background if missing, reporting progress on the splash screen alongside OptiScaler, DLSS-Enabler, and vkSumi. When running inside Flatpak, MAKO auto-provisioning SHALL be skipped to protect host layer stability.

#### Scenario: First application launch without MAKO installed
- **WHEN** Goverlay boots natively and `TStartupDownloadThread` executes its initial dependency checks
- **THEN** system checks for `VkLayer_MAKO_render.json` and, if absent, invokes `CheckAndInstallMako` to download and install the layer in user-space with progress reported on the splash screen before the main window opens.

#### Scenario: Startup inside Flatpak environment
- **WHEN** Goverlay boots inside a Flatpak container
- **THEN** `TStartupDownloadThread` skips MAKO layer installation, avoiding host implicit layer registration without corresponding host binaries.
