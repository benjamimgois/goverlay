## MODIFIED Requirements

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json` or equivalent manifest, check for updates in the background on startup and tab activation, and conditionally present an "Install update" action button only when a newer release is detected.

#### Scenario: Checking for MAKO updates
- **WHEN** user opens the Lossless Scaling tab or the application starts
- **THEN** system checks the local version against the latest `render-v*` tag from GitHub in the background without requiring a manual check button, displaying an update notice badge and making the "Install update" button visible only if a newer version is available.

## ADDED Requirements

### Requirement: Software Status Card Layout
The system SHALL display a "Software Status" card anchored at the base of the Lossless Scaling tab (below Frame Generation and Spatial Scaling cards), organizing Lossless Scaling and MAKO Renderer components in vertically stacked rows across full card width.

#### Scenario: Displaying software status and paths
- **WHEN** user views the Lossless Scaling tab
- **THEN** the Software Status card renders at the bottom with Lossless Scaling (duck icon, DLL path input, browse button, status indicator, inspect button) positioned above MAKO Renderer (shark mascot icon, detected `libmako-render.so` path, installed version status, conditional update/install button), followed by Target GPU Device selection.

#### Scenario: Positioning Target GPU selection
- **WHEN** user views the Software Status card
- **THEN** the Target GPU Device selection dropdown is positioned below the MAKO Renderer section.
