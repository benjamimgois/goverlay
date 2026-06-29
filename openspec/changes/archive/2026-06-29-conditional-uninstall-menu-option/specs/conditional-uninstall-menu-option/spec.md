# Capability: conditional-uninstall-menu-option

Hides the "Uninstall changes" option from the game card context menu unless GOverlay configurations or OptiScaler files exist for that game.

## ADDED Requirements

### Requirement: Conditional visibility of Uninstall changes menu option
GOverlay SHALL check whether GOverlay configurations or OptiScaler installation files exist for a game before displaying the "Uninstall changes" menu item in the game card options menu.

#### Scenario: Game with active modifications or configurations
- **WHEN** user opens the options menu for a game that has a GOverlay config folder or OptiScaler installation markers in its install folder
- **THEN** GOverlay displays the "Uninstall changes" menu item.

#### Scenario: Clean game without modifications
- **WHEN** user opens the options menu for a game with no GOverlay config folder and no OptiScaler installation markers
- **THEN** GOverlay hides the "Uninstall changes" menu item.
