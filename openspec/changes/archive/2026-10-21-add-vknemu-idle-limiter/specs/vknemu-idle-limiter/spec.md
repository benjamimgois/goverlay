# Spec Delta

## Purpose

Automates the provisioning, update monitoring, UI configuration in the MangoHud Limiters panel, and runtime environment variable injection for the vkNemu idle frame limiter Vulkan layer.

## ADDED Requirements

### Requirement: Automated vkNemu Runtime Provisioning
Goverlay SHALL verify the presence of the vkNemu Vulkan layer on startup and, if missing or outdated in a native Linux environment, download the latest release package, extract the shared library into the user data layers directory, validate binary integrity, and register an implicit Vulkan layer manifest.

#### Scenario: Missing layer download and registration
- **WHEN** Goverlay starts in a native (non-Flatpak) environment and vkNemu is not installed
- **THEN** it downloads the latest release from GitHub, extracts `libVkLayer_vknemu.so` to `~/.local/share/goverlay/layers/vknemu/`, verifies the shared library, and creates `~/.local/share/vulkan/implicit_layer.d/vknemu.json`

#### Scenario: Flatpak sandbox bypass
- **WHEN** Goverlay starts inside a Flatpak sandbox
- **THEN** automated host layer download and registration is skipped immediately to avoid host corruption

#### Scenario: Corrupted download prevention
- **WHEN** the downloaded archive or extracted library fails binary validation
- **THEN** the corrupt file is deleted immediately and no manifest file is generated

### Requirement: Upstream Update Detection
The system SHALL query the latest vkNemu release from the upstream GitHub repository during startup and detect when a new version is available by comparing the remote release tag against the locally installed version tag.

#### Scenario: Update available
- **WHEN** a newer release tag exists upstream than the tag stored in local variables
- **THEN** the system triggers an update download and replaces the local shared library and manifest

#### Scenario: Upstream unreachable
- **WHEN** GitHub API is unavailable or returns an error during startup
- **THEN** Goverlay uses existing local files without blocking application startup

### Requirement: Limiters Card UI Integration
Goverlay SHALL display dedicated controls for vkNemu inside the "Limiters" section of the MangoHud Performance tab, allowing users to enable or disable the layer and adjust its idle throttling parameters.

#### Scenario: Control presentation
- **WHEN** the user views the MangoHud Performance tab
- **THEN** the Limiters card displays a distinct vkNemu sub-section containing a master toggle switch, an Idle FPS spin box, a Timeout spin box, an Input device selector, and a Cap on Unfocus toggle

#### Scenario: Disabled state dimming
- **WHEN** the vkNemu master toggle switch is turned off
- **THEN** the vkNemu parameter controls (Idle FPS, Timeout, Input, Unfocus) are disabled and visually dimmed

### Requirement: Configuration Persistence
The system SHALL persist all vkNemu user preferences to Goverlay configuration files and restore them when loading global or per-game configurations.

#### Scenario: Saving preferences
- **WHEN** the user changes vkNemu settings and saves configuration
- **THEN** the values for enabled state, idle FPS, timeout, unfocused cap, input mode, and delay are written to the active configuration profile

#### Scenario: Per-game configuration loading
- **WHEN** the user switches between games or global profile
- **THEN** the vkNemu UI controls update to reflect the selected profile's saved settings

### Requirement: Launch Environment Variable Injection
Goverlay SHALL inject vkNemu environment variables into game launch commands and test executions when the feature is enabled in the active profile.

#### Scenario: Enabled launch environment
- **WHEN** vkNemu is enabled in the active configuration and a game or preview is launched
- **THEN** `VKNEMU=1` along with configured `VKNEMU_IDLE_FPS`, `VKNEMU_TIMEOUT`, `VKNEMU_UNFOCUSED`, and `VKNEMU_INPUT` environment variables are prepended to the command line

#### Scenario: Disabled launch environment
- **WHEN** vkNemu is disabled in the active configuration
- **THEN** `DISABLE_VKNEMU=1` or omitting `VKNEMU=1` ensures the layer remains inactive
