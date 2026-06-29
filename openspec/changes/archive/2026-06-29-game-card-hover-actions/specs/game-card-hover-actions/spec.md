# Capability: game-card-hover-actions

Provides an interactive hover action overlay bar on game cards to quickly access game folder management and overlay configuration cleanup.

## ADDED Requirements

### Requirement: Display hover action bar on game card mouse hover
When the user moves the mouse cursor over a game card panel (or any child control within the card), GOverlay SHALL make the action overlay bar visible at the bottom of the card panel.

#### Scenario: Mouse enters game card
- **WHEN** user moves mouse cursor over a Steam or non-Steam game card
- **THEN** GOverlay reveals the action overlay bar at the bottom of the card panel.

#### Scenario: Mouse leaves game card
- **WHEN** user moves mouse cursor outside the boundaries of the game card panel
- **THEN** GOverlay hides the action overlay bar.

### Requirement: Execute action on hover button click
When the user clicks any of the action buttons on the hover overlay bar, GOverlay SHALL trigger the corresponding operation ("Open install folder", "Open prefix folder", or "Uninstall changes").

#### Scenario: Open install folder clicked
- **WHEN** user clicks the "Open install folder" button on the hover bar
- **THEN** GOverlay opens the game installation folder in the system file manager.

#### Scenario: Open prefix folder clicked
- **WHEN** user clicks the "Open prefix folder" button on the hover bar
- **THEN** GOverlay opens the Wine/Proton prefix folder in the system file manager.

#### Scenario: Uninstall changes clicked
- **WHEN** user clicks the "Uninstall changes" button on the hover bar
- **THEN** GOverlay resets the game-specific overlay configuration files for that game.
