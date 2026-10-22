## ADDED Requirements

### Requirement: Metric Overlay Graph Toggle
The system SHALL provide an inline graph toggle button on the 8 supported MangoHud metric toggles (`gpu_load`, `vram`, `gpu_core_clock`, `gpu_mem_clock`, `gpu_temp`, `cpu_load`, `cpu_temp`, `ram`).

#### Scenario: Visual state of active graph button
- **WHEN** a metric graph is enabled and the metric toggle is ON
- **THEN** the graph button displays an illuminated glowing outline and active icon indicating graph rendering is active

#### Scenario: Visual state of inactive graph button
- **WHEN** a metric graph is disabled and the metric toggle is ON
- **THEN** the graph button displays a subtle border and muted icon indicating graph rendering is inactive

#### Scenario: Visual state when parent metric is OFF
- **WHEN** a metric toggle is in the OFF state
- **THEN** the graph button is rendered in a dimmed/disabled state and ignores click interactions

#### Scenario: User toggles graph mode
- **WHEN** user clicks on an active metric's graph button
- **THEN** the graph mode for that metric toggles state, updates visual illumination, and triggers auto-save

### Requirement: MangoHud Graphs Configuration Serialization
The system SHALL serialize active metric graphs into a single comma-separated `graphs=` directive in `MangoHud.conf` when one or more supported graphs are active and their parent metrics are enabled.

#### Scenario: Saving active graphs
- **WHEN** user enables graph mode on one or more active metrics and configuration is saved
- **THEN** `graphs=` is written to `MangoHud.conf` containing only the active, enabled metric graph identifiers

#### Scenario: Loading graphs from configuration
- **WHEN** `MangoHud.conf` containing `graphs=...` is loaded
- **THEN** the corresponding metric graph buttons reflect their active state in the GUI
