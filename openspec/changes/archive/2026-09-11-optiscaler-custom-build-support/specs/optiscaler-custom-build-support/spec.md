## Purpose

Provides mechanisms to import and manage custom OptiScaler builds from local directories, automatically inherit missing companion libraries from the stable cache, and enable an unmanaged in-game configuration mode to protect custom settings from being overwritten.

## ADDED Requirements

### Requirement: Custom OptiScaler Build Directory Selection and Validation
The system SHALL allow users to select a local directory containing a custom OptiScaler build and validate that the directory contains `OptiScaler.dll` before importing it into the application cache.

#### Scenario: Valid custom build folder selection
- **WHEN** user selects a directory containing `OptiScaler.dll` via the folder picker for the Custom Build channel
- **THEN** system copies all files from the selected directory into `optiscaler-custom/`, writes the version metadata to `goverlay.vars`, and updates the status indicator to green.

#### Scenario: Missing OptiScaler.dll validation error
- **WHEN** user selects a directory that does not contain `OptiScaler.dll`
- **THEN** system displays a user-facing error message informing that `OptiScaler.dll` was not found, and cancels the import without modifying the existing custom cache.

### Requirement: Companion Library Fallback Inheritance
The system SHALL automatically populate missing companion upscaling and wrapper libraries in `optiscaler-custom/` by copying them from the stable cache (`optiscaler-stable/`) when importing a custom build.

#### Scenario: Automatic fallback to stable companion libraries
- **WHEN** a custom build is imported that contains `OptiScaler.dll` but lacks secondary libraries (such as `amd_fidelityfx_*.dll`, `libxess.dll`, or `fakenvapi.dll`)
- **THEN** system copies the missing libraries and wrapper scripts (`bgmod`, `bgmod-uninstaller`) from `optiscaler-stable/` into `optiscaler-custom/`.

#### Scenario: Informing user of library inheritance
- **WHEN** user selects or imports a Custom Build
- **THEN** system displays a non-intrusive notification (toast and status card hint) explaining that missing companion libraries are inherited from the stable cache.

### Requirement: In-Game Menu Configuration Only Toggle
The system SHALL provide an "In-game menu configuration only" toggle that is visible exclusively when the Custom Build channel is selected, allowing users to prevent GOverlay from modifying `OptiScaler.ini`.

#### Scenario: Toggle visibility matches Custom Build channel selection
- **WHEN** user selects "Custom Build" in the channel selection combobox
- **THEN** system displays the "In-game menu configuration only" toggle, and hides it when "Stable Channel" or "Bleeding-edge" is selected.

#### Scenario: Unmanaged mode prevents GOverlay from overwriting OptiScaler.ini
- **WHEN** "In-game menu configuration only" is enabled and user saves the profile in GOverlay
- **THEN** system persists `OPT_UNMANAGED_INI=1` in `bgmod.conf` and does not modify or overwrite `OptiScaler.ini`.
