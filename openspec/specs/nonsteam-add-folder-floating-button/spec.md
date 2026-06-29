# Capability: nonsteam-add-folder-floating-button

Adds floating action button to the "Add game folder" card to replace its right-click context menu.

## Requirements

### Requirement: Floating action button on Add game folder card
GOverlay SHALL display a floating action button on hover for the "Add game folder" card that opens the remove/manage non-Steam folders menu when clicked.

#### Scenario: Hovering and clicking floating action button on Add game folder card
- **WHEN** user hovers over the "Add game folder" card and clicks its floating action button
- **THEN** GOverlay opens the "Remove nonsteam folders" popup menu.
