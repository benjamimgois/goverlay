# Spec Delta: mangohud-metrics-modular-ui

## MODIFIED Requirements

### Requirement: Thematic Hardware Module Cards
The system SHALL group related telemetry metrics into distinct, visually framed sub-cards arranged in a balanced two-column grid within both the GPU Metrics and CPU / Memory Metrics panels, identified by semantic color-coded accent badges rather than text emojis.

#### Scenario: Displaying grouped hardware modules
- **WHEN** the user navigates to the Metrics tab
- **THEN** the system SHALL display distinct themed sub-modules for Core Telemetry, Thermals & Cooling, Power & Energy, Hardware & Drivers, Memory & Swap, and Storage & IO, each identified by an accent badge prefix and theme-aware subsystem color

#### Scenario: Balanced sub-card dimensions and alignment
- **WHEN** the Metrics tab content area is reflowed
- **THEN** sub-cards across rows SHALL maintain uniform heights and symmetrical two-column widths without asymmetrical trailing voids
