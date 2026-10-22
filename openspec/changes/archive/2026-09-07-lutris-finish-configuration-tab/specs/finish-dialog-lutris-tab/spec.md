## Purpose

Provides a dedicated Lutris tab within the Finish Configuration dialog, guiding users to apply GOverlay's generated wrapper command as a Lutris Command Prefix.

## ADDED Requirements

### Requirement: Lutris platform switcher option
The Finish Configuration dialog SHALL display a "Lutris" platform option alongside Steam and Heroic.

#### Scenario: User switches to Lutris tab
- **WHEN** user clicks the "Lutris" platform button in the Finish Configuration dialog
- **THEN** system switches the active platform to Lutris
- **THEN** system updates the displayed command to remove `%command%` and quotes
- **THEN** system displays step-by-step instructions for configuring the Command prefix in Lutris
- **THEN** system renders the Lutris Libadwaita animated UI walkthrough

### Requirement: Lutris command prefix formatting
The system SHALL format the launch command for Lutris without surrounding quotes and without the `%command%` suffix.

#### Scenario: Copying Lutris command
- **WHEN** active platform is Lutris and user clicks the Copy button
- **THEN** system copies the unquoted wrapper binary path without `%command%` to the clipboard
- **THEN** system provides visual copied feedback on the Copy button

### Requirement: Lutris step-by-step instructions
The system SHALL display concise instructions for applying the command within Lutris settings.

#### Scenario: Viewing Lutris instructions
- **WHEN** Lutris platform is active
- **THEN** step instructions indicate opening game Configure › System options tab › pasting into "Command prefix" › clicking Save

### Requirement: Lutris UI canvas animation
The system SHALL paint a modern Lutris interface walkthrough showing the System options tab and Command prefix field.

#### Scenario: Painting Lutris animation box
- **WHEN** Lutris platform is active and the animation box redraws
- **THEN** canvas renders Lutris header bar with Advanced switch, System options tab, and a highlighted Command prefix entry with blinking cursor and guide indicator
