# optiscaler-panel-resilience

## Purpose
Defines requirements for UI state consistency, instant global profile synchronization, and asset download fallback resilience in the OptiScaler tab.

## ADDED Requirements

### Requirement: GPU Driver Restriction Enforcement in OptiScaler Tab
GOverlay SHALL enforce GPU driver restrictions whenever the OptiScaler configuration tab is loaded or selected, disabling Nvidia-incompatible controls (such as Spoof DLSS and Force Reflex) if the Nvidia driver preference is selected.

#### Scenario: Navigating to OptiScaler tab with Nvidia selected
- **WHEN** Nvidia driver is selected and the user clicks on the OptiScaler menu item in the left navigation
- **THEN** `spoofCheckBox` and `forcereflexCheckBox` SHALL remain disabled (`Enabled = False`).

### Requirement: Immediate Global Profile Sync on Save
GOverlay SHALL synchronize OptiScaler binaries, plugins, and configuration files into `gameconfig/global/` immediately upon saving settings when OptiScaler is enabled.

#### Scenario: Saving OptiScaler configuration for global profile
- **WHEN** the user enables OptiScaler and clicks Save in the global profile
- **THEN** GOverlay synchronizes OptiScaler DLLs and plugins to `~/.local/share/goverlay/gameconfig/global/` without requiring an application restart.

### Requirement: FakeNVAPI Update Download Fallback
GOverlay SHALL preserve existing `fakenvapi` binaries and configuration files in the OptiScaler cache folder if downloading or extracting the latest FakeNVAPI from GitHub fails during an update or installation process.

#### Scenario: FakeNVAPI download failure during OptiScaler update
- **WHEN** an OptiScaler update or installation is executed and the network download of `fakenvapi-latest.7z` fails
- **THEN** GOverlay logs a warning and restores or preserves pre-existing `fakenvapi.dll` and `fakenvapi.ini` in the cache directory.
