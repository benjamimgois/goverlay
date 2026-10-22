## MODIFIED Requirements

### Requirement: Dynamic Download and Headless Installation of MAKO Renderer
The system SHALL support querying GitHub releases for the MAKO repository, downloading the latest native Linux `MAKO-Renderer-*-linux.tar.xz` archive matching the `render-v*` release tags (strictly excluding `-flatpaks.tar.xz` packages), and performing a non-interactive user-space installation.

#### Scenario: Installing MAKO Renderer when not present
- **WHEN** user clicks the "Install MAKO" button or triggers dynamic installation on the Lossless Scaling tab
- **THEN** system downloads the latest native Linux renderer archive (`*-linux.tar.xz`) with progress feedback, extracts it, executes the headless installer (`MAKO_INSTALLER_ASSUME_YES=1 MAKO_INSTALLER_NO_LAUNCH=1`), and updates the UI status upon completion.

#### Scenario: Upgrading MAKO Renderer when update is available
- **WHEN** user clicks the "Install update" button
- **THEN** system downloads the latest native Linux release archive, extracts it, runs the installer, and updates the installed version status to the new release without manual intervention.

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json` or equivalent manifest, perform asynchronous background update checks upon launch, persist remote version and update availability state across tab navigation and reloads, and present the update indicator (`InstalledVer → RemoteVer`) and "Install update" action on both the Lossless Scaling tab engine card and the Software Status card whenever a newer release is available.

#### Scenario: Checking for MAKO updates
- **WHEN** GOverlay launches or user navigates to the Lossless Scaling tab
- **THEN** system asynchronously checks the installed MAKO version against the latest GitHub release, persists the detected remote version in session state, and preserves the update notice and "Install update" action if a newer release exists.

#### Scenario: Navigating to Lossless Scaling tab with pending update
- **WHEN** user navigates to the Lossless Scaling tab while an update is pending
- **THEN** system preserves the update state (`InstalledVer → RemoteVer`) on the engine status label, displays the update status in the Software Status card, and keeps the "Install update" button visible.

### Requirement: Dependency Detection and Home Tab Integration
The system dependency checker and Home tab module indicators SHALL recognize MAKO as satisfied when either system or user-space `VkLayer_MAKO_render.json` implicit layer manifests are detected, and SHALL dynamically reflect available MAKO update versions (`InstalledVer → RemoteVer`) in the Home tab Frame Generation module status label when an update is detected.

#### Scenario: Verifying MAKO dependency on Home tab
- **WHEN** MAKO layer manifest exists in `~/.local/share/vulkan/implicit_layer.d/VkLayer_MAKO_render.json` or system paths
- **THEN** the Home tab module status for Frame Generation displays a green status indicator and shows the installed MAKO version.

#### Scenario: Displaying available MAKO update on Home tab
- **WHEN** background update check discovers a newer MAKO version than currently installed
- **THEN** the Home tab Frame Generation module version label is updated to show `InstalledVer → RemoteVer` in update accent styling, consistent with OptiScaler.
