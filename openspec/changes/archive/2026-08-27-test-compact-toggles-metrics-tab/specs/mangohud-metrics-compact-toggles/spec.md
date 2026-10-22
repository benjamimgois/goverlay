## Purpose

Provides compact, high-resolution antialiased toggle switches on the MangoHud Metrics tab to replace standard checkboxes for all GPU and CPU/memory metric options.

## ADDED Requirements

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
