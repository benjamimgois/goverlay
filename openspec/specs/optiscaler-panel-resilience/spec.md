# optiscaler-panel-resilience

## Purpose
Defines requirements for UI state consistency, instant global profile synchronization, and asset download fallback resilience in the OptiScaler tab.

## Requirements

### Requirement: GPU Driver Restriction Enforcement in OptiScaler Tab
GOverlay SHALL enforce GPU driver restrictions whenever the OptiScaler configuration tab or tool toggle state is updated, keeping Nvidia-incompatible controls disabled when Nvidia driver preference is selected and applying recommended Reflex defaults for MESA.

#### Scenario: Navigating to OptiScaler tab with Nvidia selected
- **WHEN** Nvidia driver is selected and the user clicks on the OptiScaler menu item in the left navigation
- **THEN** `spoofCheckBox` and `forcereflexCheckBox` SHALL remain disabled (`Enabled = False`).

#### Scenario: Re-enabling OptiScaler with NVIDIA selected
- **WHEN** the user re-enables the OptiScaler tool toggle switch after it was disabled
- **AND** `nvidiaRadioButton` is selected
- **THEN** `spoofCheckBox` ("Spoof DLSS") and `forcereflexCheckBox` ("Force Reflex") SHALL remain disabled (`Enabled = False`).

#### Scenario: First activation of OptiScaler with MESA selected
- **WHEN** the user enables the OptiScaler tool toggle switch for the first time
- **AND** `mesaRadioButton` is selected
- **THEN** `forcereflexCheckBox.Checked` SHALL be set to `True` and `reflexComboBox.ItemIndex` SHALL be set to `2` ("Force enable").

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
