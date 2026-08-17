## MODIFIED Requirements

### Requirement: Custom Animated Setup Guide
The system SHALL render custom lightweight step-by-step canvas/frame animations illustrating where to locate and paste launch options in the respective launcher UI, using modern Steam Properties UI layout (with dark sidebar, active game title, General section, and Launch Options input box) when Steam platform is selected.

#### Scenario: Viewing animated setup guide
- **WHEN** the Finish Configuration dialog is active with Steam platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough showing a modern Steam Properties window with dark sidebar, game title, General navigation item, and an animated pulsing Launch Options input field.

#### Scenario: Viewing Heroic animated setup guide
- **WHEN** the Finish Configuration dialog is active with Heroic platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough demonstrating the Wrapper Command configuration path in Heroic Games Launcher.
