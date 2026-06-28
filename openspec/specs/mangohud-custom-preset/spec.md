## ADDED Requirements

### Requirement: Custom preset loading and UI synchronization
The system SHALL copy `custom.conf` to `MangoHud.conf` and immediately reload all GOverlay UI controls from `MangoHud.conf` when the user triggers the Custom preset card.

#### Scenario: Loading custom preset with existing custom.conf
- **WHEN** user clicks the Custom preset card and `custom.conf` exists
- **THEN** the system copies `custom.conf` to `MangoHud.conf`, reloads GOverlay UI controls to reflect the custom configuration, and sets the Custom preset card as active

#### Scenario: Triggering custom preset without custom.conf
- **WHEN** user clicks the Custom preset card and `custom.conf` does not exist
- **THEN** the system displays an informational message instructing the user to save a custom preset first and does not set the Custom preset card as active
