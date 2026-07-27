## ADDED Requirements

### Requirement: Sidebar navigation items display using PNG assets
The system SHALL display graphics for all sidebar navigation items (`Games`, `MangoHud`, `Post processing`, `OptiScaler`, `EnvVars`) using PNG image files bundled with the application, with zero dependency on system font glyphs.

#### Scenario: Displaying sidebar items on launch
- **WHEN** GOverlay launches on a system without Nerd Fonts or specialized icon fonts installed
- **THEN** all 5 sidebar menu items display clean, high-definition PNG icons without blank rectangles or broken characters

#### Scenario: Switching active sidebar item
- **WHEN** user clicks on a sidebar navigation item (e.g. Games, Post processing, EnvVars)
- **THEN** the active item's icon updates to its active PNG variant and previously active items revert to their inactive PNG variants
