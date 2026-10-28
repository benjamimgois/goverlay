# Spec Delta

## MODIFIED Requirements

### Requirement: Automated startup download and installation for native environments
The system SHALL verify the presence of the `lsfg-vk` Vulkan layer during startup download thread execution, and in native environments, automatically download the official pre-built tarball from `builds.lsfg-vk.dev` using a compatible standard HTTP User-Agent and extract it into `~/.local` if not already installed. If the download archive fails to fetch, the system SHALL log a download error and abort extraction instead of falsely reporting layer detection failure.

#### Scenario: Startup check when lsfg-vk is missing in native environment
- **WHEN** GOverlay launches outside a container and `VkLayer_LSFGVK_frame_generation.json` is not detected in user or system layer directories
- **THEN** system downloads `lsfg-vk-2.0.0.tar.xz` with progress updates on the boot splash using a compatible standard User-Agent, extracts its contents to `~/.local/`, and sets executable permissions on `bin/lsfg-vk-cli`.

#### Scenario: Startup check when lsfg-vk is already installed
- **WHEN** GOverlay launches and `VkLayer_LSFGVK_frame_generation.json` is detected
- **THEN** system logs that `lsfg-vk` is available and proceeds immediately to the next startup check.

#### Scenario: Startup archive download failure
- **WHEN** network request to download the tarball fails (e.g. HTTP error or connection timeout)
- **THEN** system logs the specific download failure and skips archive extraction without falsely reporting a missing layer error.

### Requirement: On-demand manual installation and update check from UI
The system SHALL provide an interactive installation/update trigger and status indicator in the Software Status card and Home tab, evaluating remote updates strictly against official stable releases from `builds.lsfg-vk.dev` using a compatible standard HTTP User-Agent while ignoring development git autobuilds and pre-releases. Remote update discovery SHALL return an empty string rather than hardcoded legacy version fallbacks on failure, and update banners SHALL only display when the remote release is semantically newer than installed.

#### Scenario: User clicks install or update for lsfg-vk
- **WHEN** user clicks the install or update button adjacent to `lsfg-vk` in the Software Status card
- **THEN** system initiates a background thread to fetch the latest official stable archive using a compatible standard User-Agent, extracts the runtime into `~/.local`, and updates the status dot and version label upon completion.

#### Scenario: Background update check when newer git commit exists upstream
- **WHEN** an upstream git commit build exists on `builds.lsfg-vk.dev` (e.g. `Latest git version`) but the official `Latest release` matches the installed version
- **THEN** system SHALL NOT report an update available, SHALL NOT show an update indicator (`installed → remote`), and SHALL NOT display the install update button.

#### Scenario: Remote discovery fails on network or service error
- **WHEN** query to `builds.lsfg-vk.dev` fails or times out
- **THEN** system returns an empty remote version rather than a hardcoded legacy version, suppressing false downgrade notices.
