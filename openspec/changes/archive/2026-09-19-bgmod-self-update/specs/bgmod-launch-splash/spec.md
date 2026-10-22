# Spec Delta: bgmod-launch-splash

## ADDED Requirements

### Requirement: Launch Splash Wrapper Update Notification
The launch splash window SHALL display an informational notification item (`"BGMod updated"`) in English when `bgmod` has performed a self-update during the current game launch.

#### Scenario: Display update notification on splash screen
- **WHEN** launch splash is enabled and `bgmod` has performed a self-update on the current launch
- **THEN** the splash screen checklist includes `"BGMod updated"` alongside other enabled modules

#### Scenario: No update notification on regular launches
- **WHEN** `bgmod` starts without performing a self-update
- **THEN** the splash screen displays only the standard enabled modules checklist without `"BGMod updated"`
