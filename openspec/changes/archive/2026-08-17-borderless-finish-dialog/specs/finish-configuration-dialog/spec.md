## MODIFIED Requirements

### Requirement: Modal Finish Configuration Dialog
The system SHALL display a modern borderless modal dialog upon triggering the Finish Config action, featuring custom window borders matching GOverlay styling, a draggable header bar with a top-right close button (`✕`), dismissal via the `Escape` key, displaying the generated launch command for the current active configuration, instructions, and platform options in English without requiring a bottom "Done" button.

#### Scenario: Opening Finish Configuration dialog
- **WHEN** user clicks the Finish Config button
- **THEN** GOverlay SHALL display the borderless Finish Configuration dialog with custom chrome, a draggable top header, close icon, platform switcher, animated guide, and prominent command box.

#### Scenario: Closing dialog via close icon or Escape key
- **WHEN** user clicks the top-right `✕` button or presses the `Escape` key
- **THEN** the dialog SHALL immediately close and return control to the main window.

### Requirement: One-Click Command Copy with Feedback
The system SHALL display the generated launch command in a prominent, high-contrast terminal/code-styled container featuring a terminal prompt symbol, distinct dark surface background, subtle accent border, and a prominent copy button that copies the full command string to the clipboard and provides immediate visual feedback.

#### Scenario: Clicking Copy Command button
- **WHEN** user clicks the Copy button
- **THEN** the system SHALL copy the active platform's command string to the system clipboard and display temporary visual feedback (`Copied!`) in English.
