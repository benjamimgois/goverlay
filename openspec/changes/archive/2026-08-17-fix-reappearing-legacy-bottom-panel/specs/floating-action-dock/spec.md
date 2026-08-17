## ADDED Requirements

### Requirement: Permanent Suppression of Legacy Bottom Bar
The system SHALL keep the legacy bottom bar (`goverlaybarPanel`) and embedded command panel (`commandPanel`) permanently hidden across all navigation actions, game card selections, and configuration save operations, relying exclusively on the floating action dock for actions and the Finish dialog for launch options.

#### Scenario: Selecting a game from Games tab
- **WHEN** user selects a game card from the Games tab to edit its configuration
- **THEN** GOverlay SHALL activate the floating action dock for MangoHud and keep the legacy bottom bar and command panel hidden (`Visible = False`).

#### Scenario: Saving configuration
- **WHEN** user saves configuration settings across any tab or profile mode
- **THEN** GOverlay SHALL display the floating auto-save toast and maintain the legacy bottom bar and command panel in hidden state.
