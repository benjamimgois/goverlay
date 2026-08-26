## MODIFIED Requirements

### Requirement: Vertical Card Expansion Across Tabs
The system SHALL calculate card heights and layout offsets using the reclaimed vertical space, distributing extra height to primary configuration cards.

#### Scenario: Viewing Visual Settings tab
- **WHEN** user views the MangoHud Visual tab
- **THEN** the `Visual Settings` card SHALL expand in height to fill available vertical space above the floating dock, with the bottom HUD shortcut controls anchored cleanly to the card base.

#### Scenario: Viewing Metrics tab
- **WHEN** user views the MangoHud Metrics tab
- **THEN** `GPU Metrics` and `CPU / Memory Metrics` cards SHALL expand proportionally to fill the tab scroll area with balanced row spacing.

#### Scenario: Viewing Performance tab
- **WHEN** user views the MangoHud Performance tab
- **THEN** the layout SHALL render a top panoramic card (~190px) integrating `Information` and `VSYNC` side-by-side, above two balanced bottom cards (`Limiters` on the left and `Filters` on the right) that expand vertically to fill the available canvas while maintaining clean clearance from the floating action dock.

#### Scenario: Viewing Upscalers tab
- **WHEN** user views the OptiScaler tab
- **THEN** the `Options` card SHALL expand vertically to fill the space between the top method card and bottom software status card.

#### Scenario: Viewing Post-processing tabs
- **WHEN** user views the vkBasalt or vkSumi tab
- **THEN** the `ReShade Shaders` card SHALL expand its height beyond 340px to display additional visible shader items without leaving empty space below the bottom cards.
