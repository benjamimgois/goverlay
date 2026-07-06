## MODIFIED Requirements

### Requirement: Asynchronous Update Check on Startup
The system SHALL run the OptiScaler and fgmod update checks in a background thread to prevent freezing the UI on application startup and when the user navigates to the OptiScaler tab page.

#### Scenario: Background execution on startup
- **WHEN** the main window is created and initialized
- **THEN** the system SHALL start a background thread to fetch the latest OptiScaler and fgmod tags from the GitHub API.

#### Scenario: Background execution on opening OptiScaler tab
- **WHEN** the user opens or navigates to the OptiScaler tab sheet
- **THEN** the system SHALL start a background thread to fetch the latest OptiScaler and fgmod tags.

#### Scenario: Preserving active configuration context
- **WHEN** an update check is initiated while a game-specific profile or global gameconfig profile is active
- **THEN** the system SHALL load installed versions from the active profile's directory and compare the remote versions against them.
