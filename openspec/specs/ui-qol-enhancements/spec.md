# Specification: UI Quality of Life Enhancements (`ui-qol-enhancements`)

## Requirements

### Requirement 1: Game Card Badge Tooltips
GOverlay SHALL display tooltips on game card badge icons explaining which tool is enabled. All tooltip strings SHALL be in English (`"MangoHud: Enabled"`, `"vkBasalt: Enabled"`, `"OptiScaler: Enabled"`, `"Tweaks: Enabled"`).

#### Scenario: Hovering over game card badge
- **WHEN** the user hovers the mouse cursor over a badge icon on a game card
- **THEN** GOverlay SHALL show a tooltip indicating the active tool status in English.

### Requirement 2: Sidebar Tool Toggle Status Messages
GOverlay SHALL display a status toast message when toggling sidebar tool switches. All messages SHALL be in English.

#### Scenario: Toggling a tool switch on the sidebar
- **WHEN** the user toggles a tool switch (MangoHud, vkBasalt, OptiScaler, Tweaks) on or off
- **THEN** GOverlay SHALL show a status message such as `"MangoHud enabled for Cyberpunk 2077"` or `"vkBasalt disabled globally"`.

### Requirement 3: vkBasalt Restore Defaults Action
GOverlay SHALL provide a "Restore Defaults" button on the vkBasalt tab layout.

#### Scenario: Clicking Restore Defaults on vkBasalt tab
- **WHEN** the user clicks the "Restore Defaults" button on the vkBasalt tab
- **THEN** GOverlay SHALL clear active effects, reset all trackbars and MD3 labels to zero, and display a status message `"vkBasalt settings restored to defaults"`.
