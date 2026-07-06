# Purpose

This specification defines the asynchronous update checking behavior in GOverlay on startup and manual refresh to avoid freezing the UI thread.

# Requirements

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

### Requirement: Update Check UI Feedback
The system SHALL show the user that the update check is in progress on the OptiScaler tab and prevent redundant checks.

#### Scenario: Checking status display
- **WHEN** the update check is running
- **THEN** the update notification label (FOptiLabel2) SHALL be visible and display "Searching for updates..." in clAqua.
- **THEN** the "Check for updates" button (FCheckupdBtn) SHALL be disabled.

#### Scenario: Completion updates
- **WHEN** the background update check completes
- **THEN** the update notification label (FOptiLabel2) SHALL display "Update Available [tag]" in clLime if a newer version is available, or be hidden otherwise.
- **THEN** the "Check for updates" button (FCheckupdBtn) SHALL be enabled.
- **THEN** the system SHALL refresh the Home tab module status and the status dots.
