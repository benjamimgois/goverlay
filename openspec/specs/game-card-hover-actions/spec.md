# Capability: game-card-hover-actions

Provides an interactive quick action button on game cards to quickly access game options, folder management and overlay configuration cleanup.

## Requirements

### Requirement: Display quick action button on game card mouse hover
When the user moves the mouse cursor over a game card panel (or any child control within the card), GOverlay SHALL make the quick action button visible at the bottom right corner of the card panel.

#### Scenario: Mouse enters game card
- **WHEN** user moves mouse cursor over a Steam or non-Steam game card
- **THEN** GOverlay reveals the quick action button at the bottom right corner of the card panel.

#### Scenario: Mouse leaves game card
- **WHEN** user moves mouse cursor outside the boundaries of the game card panel
- **THEN** GOverlay hides the quick action button.

### Requirement: Execute action on quick action button click
When the user clicks the quick action button, GOverlay SHALL trigger the corresponding game options menu.

#### Scenario: Quick action button clicked
- **WHEN** user clicks the quick action button
- **THEN** GOverlay opens the game context menu with options ("Open install folder", "Open prefix folder", or "Uninstall changes").
