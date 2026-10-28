# mangohud-metrics-modular-ui Delta Specification

## MODIFIED Requirements

### Requirement: Thematic Hardware Module Cards
The system SHALL group related telemetry metrics into distinct, visually framed sub-cards arranged in a balanced two-column grid within both the GPU Metrics and CPU / Memory Metrics panels, identified by colored vertical accent badges on the left edge with clean, theme-contrasting white title text.

#### Scenario: Displaying grouped hardware modules
- **WHEN** the user navigates to the Metrics tab
- **THEN** the system SHALL display distinct themed sub-modules for Core Telemetry, Thermals & Cooling, Power & Energy, Hardware & Drivers, Memory & Swap, and Storage & IO, each identified by a colored vertical accent badge matching the subsystem palette and a white header title label in dark theme

#### Scenario: Balanced sub-card dimensions and alignment
- **WHEN** the Metrics tab content area is reflowed
- **THEN** sub-cards across rows SHALL maintain uniform heights and symmetrical two-column widths without asymmetrical trailing voids
