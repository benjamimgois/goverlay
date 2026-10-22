# mangohud-metrics-modular-ui Specification

## Purpose
Defines the modular sub-card presentation and inline secondary control alignment of the MangoHud GPU and CPU/Memory telemetries on the Goverlay Metrics tab.

## Requirements

### Requirement: Thematic Hardware Module Cards
The system SHALL group related telemetry metrics into distinct, visually framed sub-cards within the GPU Metrics and CPU / Memory Metrics panels.

#### Scenario: Displaying grouped hardware modules
- **WHEN** the user navigates to the Metrics tab
- **THEN** the system SHALL display distinct themed sub-modules for Core Telemetry, Thermals & Cooling, Power & Efficiency, and Memory & Storage IO, each styled with elevated backgrounds and icon headers

### Requirement: Inline Secondary Control Integration
The system SHALL place all secondary metric controls—including load gradient colors, individual color indicators, and format buttons—on the same horizontal baseline as their parent metric toggles.

#### Scenario: Visual alignment of secondary controls
- **WHEN** the user inspects metric items having secondary controls (such as Load Color, VRAM, RAM, Core Load, or Efficiency)
- **THEN** the associated color palettes, indicators, or format buttons SHALL be rendered aligned side-by-side with the corresponding toggle switch without floating beneath the label
