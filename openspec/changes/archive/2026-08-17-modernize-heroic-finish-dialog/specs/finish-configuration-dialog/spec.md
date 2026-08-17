## MODIFIED Requirements

### Requirement: Platform Selection
The system SHALL provide platform selection options for Steam and Heroic Games Launcher, adapting tutorial instructions and guide steps to the selected platform.

#### Scenario: Selecting Steam platform
- **WHEN** user selects Steam in the dialog platform selector
- **THEN** the dialog SHALL display the Steam-targeted launch command and the Steam launch options animation.

#### Scenario: Selecting Heroic Games Launcher platform
- **WHEN** user selects Heroic in the dialog platform selector
- **THEN** the dialog SHALL display the Heroic-targeted wrapper command, the updated step-by-step instructions directing the user to Settings › Advanced › Wrapper Command, and the Heroic settings animation.

### Requirement: Custom Animated Setup Guide
The system SHALL render custom lightweight step-by-step canvas/frame animations illustrating where to locate and paste launch options in the respective launcher UI, using modern Steam Properties UI layout when Steam is selected, and modern Heroic Games Launcher UI layout (with horizontal tabs, highlighted Advanced tab, scrollbar indicator, Wrapper Command section, and add button) when Heroic is selected.

#### Scenario: Viewing animated setup guide
- **WHEN** the Finish Configuration dialog is active with Steam platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough showing a modern Steam Properties window with dark sidebar, game title, General navigation item, and an animated pulsing Launch Options input field.

#### Scenario: Viewing Heroic animated setup guide
- **WHEN** the Finish Configuration dialog is active with Heroic platform selected
- **THEN** the dialog SHALL render an animated visual walkthrough demonstrating the modern Heroic Games Launcher layout with horizontal tabs, Advanced tab active, scrollbar indicator, and an animated pulsing Wrapper field in the Wrapper Command section.
