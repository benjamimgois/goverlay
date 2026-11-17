# finish-dialog-bottles-tab Specification

## Purpose

Provides a dedicated Bottles tab within the Apply Configuration dialog, guiding users to apply GOverlay's generated wrapper command in modern Bottles' Launch Arguments field.

## ADDED Requirements

### Requirement: Bottles platform switcher option
The Apply Configuration dialog SHALL display a "Bottles" platform option with a monochrome icon alongside Steam, Heroic, and Lutris.

#### Scenario: User switches to Bottles tab
- **WHEN** user clicks the "Bottles" platform button in the Apply Configuration dialog
- **THEN** system switches the active platform to Bottles
- **THEN** system updates the displayed command to the Bottles-formatted launch command
- **THEN** system displays step-by-step instructions for configuring Launch Arguments in Bottles
- **THEN** system renders the modern Bottles Libadwaita animated UI walkthrough

### Requirement: Bottles launch command formatting
The system SHALL format the launch command for modern Bottles with quotes when the wrapper path contains spaces and with the `%command%` suffix appended.

#### Scenario: Copying Bottles command from a Steam or global card
- **WHEN** active platform is Bottles and user clicks the Copy button
- **THEN** system copies the quoted `bgmod` launch command including `%command%` to the clipboard
- **THEN** system provides visual copied feedback on the Copy button

#### Scenario: Viewing Bottles command when a non-Steam card is selected
- **WHEN** active platform is Bottles and the dialog was opened with a non-Steam launch command lacking `%command%`
- **THEN** system appends `%command%` and quotes the `bgmod` path if it contains spaces

### Requirement: Bottles step-by-step instructions
The system SHALL display concise instructions in English for applying the command within modern Bottles settings.

#### Scenario: Viewing Bottles instructions
- **WHEN** Bottles platform is active
- **THEN** step instructions indicate copying the command, opening the game's Settings › Launch › "Arguments" in Bottles, pasting into the field, and clicking "Save" in both dialogs

### Requirement: Bottles UI canvas animation
The system SHALL paint a modern Bottles Libadwaita interface walkthrough showing Game Settings, the Launch Arguments sub-dialog, and a pulsing teal/blue highlight around the Arguments input field.

#### Scenario: Painting Bottles animation box
- **WHEN** Bottles platform is active and the animation box redraws
- **THEN** canvas renders the Game Settings modal, the Launch Arguments overlay with Cancel/Save header buttons, and a highlighted Arguments entry displaying a preview of the `%command%` launch command
