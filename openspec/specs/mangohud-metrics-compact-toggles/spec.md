# mangohud-metrics-compact-toggles Specification

## Purpose
Provides compact, high-resolution antialiased toggle switches on the MangoHud Metrics tab to replace standard checkboxes for all GPU and CPU/memory metric options.

## Requirements

### Requirement: Compact Antialiased Toggle Switch Control
The system SHALL provide a reusable toggle switch component (`TToggleSwitch`) rendered with antialiased stadium track (28x16px), a circular thumb (10px) with drop shadow, and high contrast active/inactive states.

#### Scenario: Visual rendering of active state
- **WHEN** a toggle switch is in the active (ON) state
- **THEN** the track is rendered in green (`#34AF5A`) with the thumb positioned to the right

#### Scenario: Visual rendering of inactive state
- **WHEN** a toggle switch is in the inactive (OFF) state
- **THEN** the track is rendered in dark slate (`#2C3244`) with the thumb positioned to the left

### Requirement: Toggle Click Interaction
The system SHALL toggle the switch state whenever a user clicks either on the toggle pill or on its accompanying label text.

#### Scenario: User clicks label or toggle pill
- **WHEN** user clicks on the toggle switch or its text label
- **THEN** the switch toggles its checked state and triggers its `OnChange` notification

### Requirement: MangoHud Metrics Tab Toggle Integration
The system SHALL display compact toggle switches for all configurable metric options across the GPU Metrics card and the CPU / Memory Metrics card on the MangoHud Metrics tab.

#### Scenario: Loading saved configuration into toggles
- **WHEN** MangoHud configuration is loaded
- **THEN** all toggle switches on the Metrics tab reflect the active state from the configuration file

#### Scenario: Saving toggle states to configuration
- **WHEN** a metric toggle switch is toggled and configuration is saved
- **THEN** the corresponding MangoHud configuration key is written to `MangoHud.conf`

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
