# finish-configuration-dialog Specification

## Purpose
Provides a dedicated, interactive popup dialog for finalizing overlay configurations, displaying platform-specific launch commands, custom tutorial animations, and one-click copy functionality.

## Requirements

### Requirement: Modal Finish Configuration Dialog
The system SHALL display a modern borderless modal dialog upon triggering the Finish Config action, featuring custom window borders matching GOverlay styling, a draggable header bar with a top-right close button (`✕`), dismissal via the `Escape` key, displaying the generated launch command for the current active configuration, instructions, and platform options in English without requiring a bottom "Done" button.

#### Scenario: Opening Finish Configuration dialog
- **WHEN** user clicks the Finish Config button
- **THEN** GOverlay SHALL display the borderless Finish Configuration dialog with custom chrome, a draggable top header, close icon, platform switcher, animated guide, and prominent command box.

#### Scenario: Closing dialog via close icon or Escape key
- **WHEN** user clicks the top-right `✕` button or presses the `Escape` key
- **THEN** the dialog SHALL immediately close and return control to the main window.

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

### Requirement: One-Click Command Copy with Feedback
The system SHALL display the generated launch command in a prominent, high-contrast terminal/code-styled container featuring a terminal prompt symbol, distinct dark surface background, subtle accent border, and a prominent copy button that copies the full command string to the clipboard and provides immediate visual feedback.

#### Scenario: Clicking Copy Command button
- **WHEN** user clicks the Copy button
- **THEN** the system SHALL copy the active platform's command string to the system clipboard and display temporary visual feedback (`Copied!`) in English.
