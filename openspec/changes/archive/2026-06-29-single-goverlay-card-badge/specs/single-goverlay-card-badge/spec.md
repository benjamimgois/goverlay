# Capability: single-goverlay-card-badge

Replaces multiple stacked game card badges with a single transparent GOverlay icon badge displaying active configuration tooltips on hover.

## ADDED Requirements

### Requirement: Display single GOverlay badge for custom configurations
When a game has one or more active custom overlay configurations or tweaks (MangoHud, vkBasalt, OptiScaler, or Tweaks), GOverlay SHALL render a single transparent GOverlay icon badge at the top-right corner of the game card.

#### Scenario: Game has active custom configurations
- **WHEN** user views a game card that has MangoHud, vkBasalt, OptiScaler, or Tweaks active
- **THEN** GOverlay renders a single transparent GOverlay icon badge at the top-right corner of the card instead of multiple stacked badge icons.

#### Scenario: Game has no active custom configurations
- **WHEN** user views a game card with no active custom configurations or tweaks
- **THEN** GOverlay does not render any badge at the top-right corner of the card.

### Requirement: Display active configuration tooltip on badge hover
When the user hovers the mouse over the GOverlay badge, GOverlay SHALL display a tooltip listing all active custom configurations for that game.

#### Scenario: Mouse hovers over GOverlay badge
- **WHEN** user moves mouse cursor over the transparent GOverlay badge on a game card
- **THEN** GOverlay displays a tooltip listing the specific active configurations (e.g., "Active configurations: MangoHud, OptiScaler").
