# Capability: nonsteam-add-folder-floating-button

Adds floating action button to the "Add non-Steam folder" card to replace its right-click context menu.

## ADDED Requirements

### Requirement: Floating action button on Add non-Steam folder card
GOverlay SHALL display a floating action button on hover for the "Add non-Steam folder" card that opens the remove/manage non-Steam folders menu when clicked.

#### Scenario: Hovering and clicking floating action button on Add non-Steam folder card
- **WHEN** user hovers over the "Add non-Steam folder" card and clicks its floating action button
- **THEN** GOverlay opens the "Remove nonsteam folders" popup menu.
