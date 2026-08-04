## Purpose

Defines requirements for hiding the legacy "Auto launch PasCube" option from the settings menu.

## ADDED Requirements

### Requirement: Hide Auto Launch PasCube Menu Option
GOverlay SHALL hide the "Auto launch PasCube" menu item from the settings menu.

#### Scenario: Opening settings menu
- **WHEN** the user opens the settings menu in GOverlay
- **THEN** the "Auto launch PasCube" menu item SHALL NOT be visible (`Visible = False`).
