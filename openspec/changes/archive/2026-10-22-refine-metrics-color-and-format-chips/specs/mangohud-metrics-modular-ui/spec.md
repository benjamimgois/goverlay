# Spec Delta: mangohud-metrics-modular-ui

## MODIFIED Requirements

### Requirement: Inline Secondary Control Integration
The system SHALL place all secondary metric controls—including load gradient colors, individual color indicators, and format buttons—on the same horizontal baseline as their parent metric toggles, rendered as distinct, proportional chips with clear semantic tooltips.

#### Scenario: Visual alignment of secondary controls
- **WHEN** the user inspects metric items having secondary controls (such as Load Color, VRAM, RAM, Core Load, or Efficiency)
- **THEN** the associated color palettes, indicators, or format buttons SHALL be rendered aligned side-by-side with the corresponding toggle switch without floating beneath the label

#### Scenario: Color swatch dimensions and tooltips
- **WHEN** the user views secondary color buttons on the Metrics tab
- **THEN** the color buttons SHALL render as proportional swatches of at least 20x20 pixels with distinct tooltips explaining their threshold level or overlay metric target
