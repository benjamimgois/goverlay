## ADDED Requirements

### Requirement: Synchronize GPU driver options to configuration files
When the GPU driver selection (NVIDIA or MESA) is toggled in the OptiScaler tab, GOverlay SHALL automatically and immediately save the updated status of dependent options (such as Spoof DLSS, Force Reflex, and Reflex) into their respective configuration files (`OptiScaler.ini` and `fakenvapi.ini`) to prevent UI desynchronization on tab change or application reload.

#### Scenario: Switching to MESA saves dependent configs
- **WHEN** the user selects the MESA GPU Driver option
- **THEN** GOverlay enables and checks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files without requiring the user to click Save.

#### Scenario: Switching to NVIDIA saves dependent configs
- **WHEN** the user selects the NVIDIA GPU Driver option
- **THEN** GOverlay disables and unchecks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files without requiring the user to click Save.

### Requirement: Global navigation updates Save button state
When the user switches tabs (MangoHud, vkBasalt, OptiScaler, Tweaks) in global mode, GOverlay SHALL update the Save button enabled state and the tab sheet enabled state to reflect the global enable status of the target tool.

#### Scenario: Navigating to OptiScaler global updates save button
- **WHEN** the user clicks the OptiScaler tab in global mode and the OptiScaler tool is globally enabled
- **THEN** the Save button is enabled and set to the active color.
