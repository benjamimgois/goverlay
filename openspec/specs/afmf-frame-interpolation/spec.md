# afmf-frame-interpolation Specification

## Purpose
Enables system-wide and per-game configuration of AMD Fluid Motion Frames (AFMF) via the open-source `afmf-linux` Vulkan implicit layer, providing driver-level optical-flow frame generation, cadence pacing, and runtime isolation.

## Requirements

### Requirement: AFMF Vulkan Layer Status Detection
The system SHALL detect the presence of the `afmf-linux` Vulkan implicit layer by inspecting system and user layer directories (`/usr/share/vulkan/implicit_layer.d/afmf-linux.json`, `/usr/local/share/vulkan/implicit_layer.d/afmf-linux.json`, and `~/.local/share/vulkan/implicit_layer.d/afmf-linux.json`) and display the layer installation status in the Software Status card.

#### Scenario: Layer is detected
- **WHEN** user selects AFMF and `afmf-linux.json` exists in any recognized Vulkan implicit layer path
- **THEN** system displays a green status dot with the detected layer location and label "AFMF Vulkan Layer Installed".

#### Scenario: Layer is not detected
- **WHEN** user selects AFMF and `afmf-linux.json` is not found
- **THEN** system displays a yellow or red warning dot with "AFMF Vulkan Layer Not Found" and an informational hint link or guide to install `afmf-linux`.

### Requirement: AFMF Performance and Search Configuration
The system SHALL provide configuration controls for AFMF performance mode, search mode, and fast motion response, serializing selections to `bgmod.conf`.

#### Scenario: Configuring AFMF performance mode
- **WHEN** user selects Performance Mode as "Quality", "Performance", or "Auto"
- **THEN** system persists `AFMF_PERFORMANCE_MODE` with values `quality`, `performance`, or `auto` in `bgmod.conf`.

#### Scenario: Configuring AFMF search mode
- **WHEN** user selects Search Mode as "Auto", "Standard", or "High"
- **THEN** system persists `AFMF_SEARCH_MODE` with values `auto`, `standard`, or `high` in `bgmod.conf`.

#### Scenario: Configuring fast motion response
- **WHEN** user selects Fast Motion Response as "Blend" or "Repeat"
- **THEN** system persists `AFMF_FAST_MOTION_RESPONSE` with values `blend` or `repeat` in `bgmod.conf`.

### Requirement: AFMF Cadence and Pacing Configuration
The system SHALL provide tuning options for frame pacing, present mode rewriting, GPU governor, and minimum FPS floor to prevent latency and stuttering.

#### Scenario: Configuring pacing and present mode
- **WHEN** user configures Frame Pacing (toggle) and Present Mode ("Auto" / "Keep")
- **THEN** system persists `AFMF_PACING` (`1` or `0`) and `AFMF_PRESENT_MODE` (`auto` or `keep`) in `bgmod.conf`.

#### Scenario: Configuring GPU governor and min FPS floor
- **WHEN** user enables the GPU Governor toggle and adjusts the Min FPS slider
- **THEN** system persists `AFMF_GOVERNOR` (`1` or `0`) and `AFMF_MIN_FPS` (e.g. `30`) in `bgmod.conf`.

### Requirement: AFMF Optimizations and Gamescope Integration
The system SHALL provide controls for HUD detection, static block SAD, direct ingest/output, and automatic or manual Gamescope compatibility.

#### Scenario: Gamescope mode with extra images
- **WHEN** game is configured to run under Gamescope or user enables the Gamescope Mode toggle
- **THEN** system configures `AFMF_GAMESCOPE=1` and sets swapchain extra images `AFMF_EXTRA_IMAGES=5` in the launch environment.

#### Scenario: Configuring HUD detection and Direct Ingest
- **WHEN** user toggles HUD Detection and Direct Ingest
- **THEN** system persists `AFMF_HUD_DETECT` and `AFMF_DIRECT_INGEST` in `bgmod.conf`.

### Requirement: AFMF Environment Variable Serialization and Launch Isolation
The system SHALL export `AFMF_ENABLE=1` along with all configured AFMF parameters when launching games or PasCube preview with AFMF active, while explicitly suppressing conflicting frame generation layers by exporting `DISABLE_LSFGVK=1`.

#### Scenario: Launching a game with AFMF active
- **WHEN** user launches a game with `INTERPOLATION_METHOD=afmf`
- **THEN** the launch environment exports `AFMF_ENABLE=1`, `DISABLE_LSFGVK=1`, and the configured `AFMF_*` environment variables, and displays "AMD Fluid Motion Frames (AFMF)" in the launch splash screen.

#### Scenario: Launching PasCube or vkcube preview with AFMF
- **WHEN** user clicks Preview while on the Frame Interpolation tab with AFMF selected
- **THEN** PasCube or vkcube is launched with `AFMF_ENABLE=1` and active AFMF environment variables for immediate visual verification.

### Requirement: AFMF Version Tracking and Update Notifications
The system SHALL check the installed `afmf-linux` version against upstream releases using GitHub REST API and unthrottled Atom feed fallbacks. Remote update discovery SHALL return an empty string upon resolution failure rather than a hardcoded legacy version, and update banners SHALL only display when the remote release is semantically newer than installed (`CompareVersions > 0`).

#### Scenario: AFMF update check with newer release available
- **WHEN** user views the Software Status card or initiates an update check
- **AND** GitHub API or Atom feed reports an `afmf-linux` release strictly newer than installed
- **THEN** system displays the update indicator (`InstalledVer → RemoteVer`) and the "Install update" action button.

#### Scenario: AFMF update check when remote version is equal or older
- **WHEN** remote version check returns a version equal to or older than the installed AFMF version
- **THEN** system SHALL NOT display the update indicator, SHALL NOT show "Install update", and SHALL suppress downgrade actions.

#### Scenario: Remote AFMF check fails due to rate limits or offline network
- **WHEN** GitHub API rate limits are exceeded and Atom feed fallback fails to resolve a valid release
- **THEN** system returns an empty version string rather than hardcoded `1.3.1`, preventing false downgrade notifications.
