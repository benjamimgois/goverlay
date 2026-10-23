# mangohud-metrics-modular-ui Specification

## Purpose
Defines the modular sub-card presentation and inline secondary control alignment of the MangoHud GPU and CPU/Memory telemetries on the Goverlay Metrics tab.

## Requirements

### Requirement: Thematic Hardware Module Cards
The system SHALL group related telemetry metrics into distinct, visually framed sub-cards arranged in a balanced two-column grid within both the GPU Metrics and CPU / Memory Metrics panels, identified by semantic color-coded accent badges rather than text emojis.

#### Scenario: Displaying grouped hardware modules
- **WHEN** the user navigates to the Metrics tab
- **THEN** the system SHALL display distinct themed sub-modules for Core Telemetry, Thermals & Cooling, Power & Energy, Hardware & Drivers, Memory & Swap, and Storage & IO, each identified by an accent badge prefix and theme-aware subsystem color

#### Scenario: Balanced sub-card dimensions and alignment
- **WHEN** the Metrics tab content area is reflowed
- **THEN** sub-cards across rows SHALL maintain uniform heights and symmetrical two-column widths without asymmetrical trailing voids

### Requirement: Inline Secondary Control Integration
The system SHALL place all secondary metric controls—including load gradient colors, individual color indicators, and format buttons—on the same horizontal baseline as their parent metric toggles, rendered as distinct, proportional chips with clear semantic tooltips.

#### Scenario: Visual alignment of secondary controls
- **WHEN** the user inspects metric items having secondary controls (such as Load Color, VRAM, RAM, Core Load, or Efficiency)
- **THEN** the associated color palettes, indicators, or format buttons SHALL be rendered aligned side-by-side with the corresponding toggle switch without floating beneath the label

#### Scenario: Color swatch dimensions and tooltips
- **WHEN** the user views secondary color buttons on the Metrics tab
- **THEN** the color buttons SHALL render as proportional swatches of at least 20x20 pixels with distinct tooltips explaining their threshold level or overlay metric target

### Requirement: HUD Chip Header Integration
The system SHALL present custom hardware name inputs and line color indicators as unified, styled HUD Chip pills inside the GPU Metrics and CPU / Memory Metrics card headers.

#### Scenario: GPU HUD Chip layout and hint
- **WHEN** the user inspects the GPU Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (GPU)', and a 'HUD' tag on the right

#### Scenario: CPU HUD Chip layout and hint
- **WHEN** the user inspects the CPU / Memory Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (CPU)', and a 'HUD' tag on the right

#### Scenario: Responsive alignment in card header
- **WHEN** the Metrics tab content area is resized
- **THEN** each HUD Chip SHALL maintain its horizontal position centered between the card title and vendor logo without visual overlapping
