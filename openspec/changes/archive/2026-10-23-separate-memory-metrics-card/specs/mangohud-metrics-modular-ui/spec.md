# mangohud-metrics-modular-ui Delta Specification

## MODIFIED Requirements

### Requirement: Thematic Hardware Module Cards
The system SHALL group related telemetry metrics into distinct, visually framed sub-cards arranged in a balanced two-column grid within dedicated main cards for GPU Metrics, CPU Metrics, and Memory metrics, identified by clean, minimalist typographic headers without text emojis or symbol prefixes.

#### Scenario: Displaying grouped hardware modules
- **WHEN** the user navigates to the Metrics tab
- **THEN** the system SHALL display distinct themed sub-modules:
  - Inside `GPU Metrics`: Core Telemetry, Thermals & Cooling, Power & Energy, Hardware & Drivers
  - Inside `CPU Metrics`: Processor Core & Freq, CPU Thermals & Power
  - Inside `Memory metrics`: Memory & Swap, Storage & Disk IO
  each identified by a clean minimalist title label in theme-contrasting font (white in dark theme)

#### Scenario: Dedicated Memory metrics card
- **WHEN** the Metrics tab is loaded or resized
- **THEN** the Memory & Swap and Storage & Disk IO sub-cards SHALL reside within the dedicated `Memory metrics` card (`FMtMemCard`) positioned below `CPU Metrics` (`FMtCpuCard`)

#### Scenario: Balanced sub-card dimensions and alignment
- **WHEN** the Metrics tab content area is reflowed
- **THEN** sub-cards across rows SHALL maintain uniform heights and symmetrical two-column widths without asymmetrical trailing voids

### Requirement: HUD Chip Header Integration
The system SHALL present custom hardware name inputs and line color indicators as unified, styled HUD Chip pills inside the GPU Metrics and CPU Metrics card headers without legacy asymmetrical illustrations.

#### Scenario: GPU HUD Chip layout and hint
- **WHEN** the user inspects the GPU Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (GPU)', and a 'HUD' tag on the right

#### Scenario: CPU HUD Chip layout and hint
- **WHEN** the user inspects the CPU Metrics card header
- **THEN** the system SHALL display a unified chip containing the line color button on the left, the name input in the middle with placeholder 'Default (CPU)', and a 'HUD' tag on the right

#### Scenario: Responsive alignment in card header
- **WHEN** the Metrics tab content area is resized
- **THEN** each HUD Chip SHALL maintain its horizontal position centered beside the card title without overlapping
