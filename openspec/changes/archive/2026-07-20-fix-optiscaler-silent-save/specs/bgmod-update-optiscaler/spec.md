## MODIFIED Requirements

### Requirement: Synchronize GPU driver options to configuration files
When the GPU driver selection (NVIDIA or MESA) is toggled in the OptiScaler tab, GOverlay SHALL automatically, immediately, and silently save the updated status of dependent options (such as Spoof DLSS, Force Reflex, and Reflex) into their respective configuration files (`OptiScaler.ini` and `fakenvapi.ini`) to prevent UI desynchronization on tab change or application reload.

The synchronization save operation SHALL be silent (i.e. not trigger user-facing desktop notifications or command panel updates/invalidations) when initiated programmatically via driver selection changes. GOverlay SHALL NOT trigger any configuration saving during application startup when restoring the previously saved driver selection.

#### Scenario: Switching to MESA saves dependent configs silently
- **WHEN** the user selects the MESA GPU Driver option
- **THEN** GOverlay enables and checks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files silently (no desktop notifications or command panel updates).

#### Scenario: Switching to NVIDIA saves dependent configs silently
- **WHEN** the user selects the NVIDIA GPU Driver option
- **THEN** GOverlay disables and unchecks the Spoof DLSS and Force Reflex checkboxes, and writes these settings directly to the profile's config files silently (no desktop notifications or command panel updates).

#### Scenario: Program startup does not trigger save operations
- **WHEN** GOverlay starts up and loads the saved driver preference
- **THEN** the driver radio button is updated in the UI, but no configuration files are written, and no desktop notifications are shown.
