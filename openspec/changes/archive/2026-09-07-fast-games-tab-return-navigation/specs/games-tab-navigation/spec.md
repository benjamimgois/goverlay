## Purpose

Manages the responsive navigation and lifecycle of the Games tab, ensuring instantaneous transitions between game configuration mode and the games library grid without redundant full-library reloads.

## ADDED Requirements

### Requirement: Instantaneous Return to Games Tab
The system SHALL transition immediately to the Games tab without destroying, rescanning, or reconstructing game cards when navigating from per-game configuration mode.

#### Scenario: User clicks Games menu from per-game configuration
- **WHEN** the user is viewing a per-game configuration tab and clicks the "Games" sidebar item
- **THEN** the system switches to the Games tab immediately using existing card panels in memory without freezing the user interface.

### Requirement: In-Place Card Badge Synchronization
The system SHALL update the tool enablement badge and tooltip for the configured game in-place without rebuilding unaffected cards in the library.

#### Scenario: Configured game tools change
- **WHEN** user returns to the Games tab after modifying a game's tool configuration
- **THEN** the system updates only the target game's badge icon and hint to reflect the enabled tools, leaving all other game cards untouched.

#### Scenario: Configured game has all tools removed
- **WHEN** user returns to the Games tab after disabling all tools for a game
- **THEN** the system removes the badge icon from that game's card in-place and restores the default hint without rebuilding the grid.
