# finish-configuration-dialog Specification

## Purpose
Provides a dedicated, interactive popup dialog for finalizing overlay configurations, displaying platform-specific launch commands, custom tutorial animations, and one-click copy functionality.

## Requirements

### Requirement: Modal Finish Configuration Dialog
The system SHALL display a modern modal dialog upon triggering the Finish Config action, showing the generated launch command for the current active configuration, instructions, and platform options in English.

#### Scenario: Opening Finish Configuration dialog
- **WHEN** user clicks the Finish Config button
- **THEN** GOverlay SHALL display the Finish Configuration dialog containing the launch command box, copy button, platform selector, and animated guide.

### Requirement: Platform Selection
The system SHALL provide platform selection options for Steam and Heroic Games Launcher, adapting tutorial instructions to the selected platform.

#### Scenario: Selecting Steam platform
- **WHEN** user selects Steam in the dialog platform selector
- **THEN** the dialog SHALL display the Steam-targeted launch command and the Steam launch options animation.

#### Scenario: Selecting Heroic Games Launcher platform
- **WHEN** user selects Heroic in the dialog platform selector
- **THEN** the dialog SHALL display the Heroic-targeted wrapper command and the Heroic settings animation.

### Requirement: Custom Animated Setup Guide
The system SHALL render custom lightweight step-by-step canvas/frame animations illustrating where to locate and paste launch options in the respective launcher UI, using modern Steam Properties UI layout (with dark sidebar, active game title, General section, and Launch Options input box) when Steam platform is selected.

#### Scenario: Viewing animated setup guide
- **WHEN** the Finish Configuration dialog is active with Steam platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough showing a modern Steam Properties window with dark sidebar, game title, General navigation item, and an animated pulsing Launch Options input field.

#### Scenario: Viewing Heroic animated setup guide
- **WHEN** the Finish Configuration dialog is active with Heroic platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough demonstrating the Wrapper Command configuration path in Heroic Games Launcher.

### Requirement: One-Click Command Copy with Feedback
The system SHALL copy the full generated launch command to the system clipboard upon clicking the copy button and provide immediate visual feedback.

#### Scenario: Clicking Copy Command button
- **WHEN** user clicks the Copy Command button
- **THEN** the system SHALL copy the launch command string to the system clipboard and display temporary visual feedback (`Copied!`) in English.
