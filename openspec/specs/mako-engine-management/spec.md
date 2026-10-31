## Purpose

Manages the dynamic discovery, download, user-space installation, version tracking, boot-time provisioning, and DLL compatibility validation of the standalone MAKO Renderer for Vulkan frame generation and spatial scaling.

## Requirements

### Requirement: Dynamic Download and Headless Installation of MAKO Renderer
The system SHALL support querying GitHub releases for the MAKO repository, downloading the latest native Linux `MAKO-Renderer-*-linux.tar.xz` archive matching the `render-v*` release tags (strictly excluding `-flatpaks.tar.xz` packages), and performing a non-interactive user-space installation.

#### Scenario: Installing MAKO Renderer when not present
- **WHEN** user clicks the "Install MAKO" button or triggers dynamic installation on the Lossless Scaling tab
- **THEN** system downloads the latest native Linux renderer archive (`*-linux.tar.xz`) with progress feedback, extracts it, executes the headless installer (`MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1`), and updates the UI status upon completion.

#### Scenario: Upgrading MAKO Renderer when update is available
- **WHEN** user clicks the "Install update" button
- **THEN** system downloads the latest native Linux release archive, extracts it, runs the installer, and updates the installed version status to the new release without manual intervention.

### Requirement: Startup Splash Screen Auto-Provisioning
The system SHALL verify the presence of the MAKO Vulkan layer during application startup boot in native environments and automatically download and install it in the background if missing, reporting progress on the splash screen alongside OptiScaler, DLSS-Enabler, and vkSumi. When running inside Flatpak, MAKO auto-provisioning SHALL be skipped to protect host layer stability.

#### Scenario: First application launch without MAKO installed
- **WHEN** Goverlay boots natively and `TStartupDownloadThread` executes its initial dependency checks
- **THEN** system checks for `VkLayer_MAKO_render.json` and, if absent, invokes `CheckAndInstallMako` to download and install the layer in user-space with progress reported on the splash screen before the main window opens.

#### Scenario: Startup inside Flatpak environment
- **WHEN** Goverlay boots inside a Flatpak container
- **THEN** `TStartupDownloadThread` skips MAKO layer installation, avoiding host implicit layer registration without corresponding host binaries.

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json`, and perform asynchronous update checks using GitHub releases and unthrottled Atom feed fallbacks. The system SHALL strictly require the remote version to be semantically newer than the local version (`CompareVersions > 0`) before displaying the update indicator (`InstalledVer → RemoteVer`) or enabling "Install update", suppressing downgrades when remote <= local.

#### Scenario: Checking for MAKO updates
- **WHEN** GOverlay launches or user navigates to the Lossless Scaling tab
- **THEN** system asynchronously checks the installed MAKO version against the latest GitHub release or Atom feed, persists the detected remote version in session state, and only shows the update indicator and "Install update" action if the remote release is semantically newer than the installed version.

#### Scenario: Navigating to Lossless Scaling tab with pending update
- **WHEN** user navigates to the Lossless Scaling tab while an update is pending
- **THEN** system preserves the update state (`InstalledVer → RemoteVer`) on the engine status label, displays the update status in the Software Status card, and keeps the "Install update" button visible.

#### Scenario: Checking for MAKO updates when installed version is up-to-date or newer
- **WHEN** remote version check returns a version equal to or older than the installed version (e.g., local 4.0.0 and remote 3.0.0 or 4.0.0)
- **THEN** system SHALL NOT display any update indicator (`→`), SHALL NOT enable the "Install update" button, and SHALL report that MAKO is up to date.

#### Scenario: Remote check fails due to rate limits or offline network
- **WHEN** GitHub API rate limits are exceeded and Atom feed fallback fails to resolve a valid release
- **THEN** system returns an empty version string rather than a hardcoded legacy version, preserving current local status without triggering a false downgrade notification.

### Requirement: Lossless DLL Compatibility Inspection
The system SHALL inspect the selected `Lossless.dll` file using `mako-cli inspect-dll` to verify the presence and compatibility of required LSFG FP32/FP16 models and LS1 spatial scaling shader resources.

#### Scenario: User selects or auto-detects Lossless.dll
- **WHEN** a path to `Lossless.dll` is configured in the UI and MAKO is installed
- **THEN** system executes `mako-cli inspect-dll` and displays detailed status badges indicating compatibility for FP16, FP32, and LS1 upscaling.

### Requirement: Dependency Detection and Home Tab Integration
The system dependency checker and Home tab module indicators SHALL recognize MAKO as satisfied when either system or user-space `VkLayer_MAKO_render.json` implicit layer manifests are detected, and SHALL dynamically reflect available MAKO update versions (`InstalledVer → RemoteVer`) in the Home tab Frame Generation module status label when an update is detected.

#### Scenario: Verifying MAKO dependency on Home tab
- **WHEN** MAKO layer manifest exists in `~/.local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json` or system paths
- **THEN** the Home tab module status for Frame Generation displays a green status indicator and shows the installed MAKO version.

#### Scenario: Displaying available MAKO update on Home tab
- **WHEN** background update check discovers a newer MAKO version than currently installed
- **THEN** the Home tab Frame Generation module version label is updated to show `InstalledVer → RemoteVer` in update accent styling, consistent with OptiScaler.

### Requirement: GPU Headroom Configuration and Persistence
The system SHALL allow users to configure and persist the MAKO GPU Headroom percentage (`gpu_headroom_percent`) across discrete choices (0% [Off], 5%, 10%, 15%, 20%) within the Lossless Scaling tab. The setting SHALL be serialized to `conf.toml` for the active game profile and exported as `MAKO_GPU_HEADROOM_PERCENT` in generated launch environment commands.

#### Scenario: Configuring GPU Headroom in Lossless Scaling tab
- **WHEN** user selects MAKO as the interpolation method on the Lossless Scaling tab
- **THEN** system displays the GPU Headroom selector with options: "Off (0%)", "5%", "10%", "15%", "20%".

#### Scenario: Persisting GPU Headroom to conf.toml
- **WHEN** user changes the GPU Headroom setting and saves or launches the profile
- **THEN** system writes `gpu_headroom_percent = <val>` into `conf.toml` under the active game profile.

#### Scenario: Generating environment variables for headless or custom launch
- **WHEN** launch options are assembled for a game using MAKO
- **AND** GPU Headroom is set to a non-zero value (e.g., 10%)
- **THEN** system includes `MAKO_GPU_HEADROOM_PERCENT=10` in the environment launch string.
