## Purpose

Defines requirements for expanding tab sheets, layout cards, and scrollable content containers to occupy the full vertical window canvas following the removal of the legacy bottom panel.

## ADDED Requirements

### Requirement: Full-Height Tab Container
The system SHALL configure the main tab container (`goverlayPageControl`) without bottom border spacing, allowing tab sheets to span to the bottom of the parent content container.

#### Scenario: Rendering main tab container
- **WHEN** GOverlay initializes or resizes
- **THEN** `goverlayPageControl` SHALL anchor to the bottom of `goverlayPanel` with `BorderSpacing.Bottom` equal to 0.

### Requirement: Vertical Card Expansion Across Tabs
The system SHALL calculate card heights and layout offsets using the reclaimed vertical space, distributing extra height to primary configuration cards.

#### Scenario: Viewing Visual Settings tab
- **WHEN** user views the MangoHud Visual tab
- **THEN** the `Visual Settings` card SHALL expand in height to fill available vertical space above the floating dock, with the bottom HUD shortcut controls anchored cleanly to the card base.

#### Scenario: Viewing Metrics tab
- **WHEN** user views the MangoHud Metrics tab
- **THEN** `GPU Metrics` and `CPU / Memory Metrics` cards SHALL expand proportionally to fill the tab scroll area with balanced row spacing.

#### Scenario: Viewing Upscalers tab
- **WHEN** user views the OptiScaler tab
- **THEN** the `Options` card SHALL expand vertically to fill the space between the top method card and bottom software status card.

#### Scenario: Viewing Post-processing tabs
- **WHEN** user views the vkBasalt or vkSumi tab
- **THEN** the `ReShade Shaders` card SHALL expand its height beyond 340px to display additional visible shader items without leaving empty space below the bottom cards.
