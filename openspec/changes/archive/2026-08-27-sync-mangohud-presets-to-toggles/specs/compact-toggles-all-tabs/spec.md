## ADDED Requirements

### Requirement: MangoHud Preset Selection Synchronization
The system SHALL synchronize all toggle switches across all MangoHud tabs immediately whenever a preset is selected (Full, Basic, Basic Horizontal, FPS Only, User Custom) or whenever a sub-tab is displayed.

#### Scenario: Switching presets updates all toggle switches
- **WHEN** the user selects a MangoHud preset layout card or button
- **THEN** all toggle switches across Visual, Performance, Metrics, and Extras tabs immediately update to reflect the preset configuration

#### Scenario: Navigating between MangoHud sub-tabs retains synchronized toggle states
- **WHEN** the user switches between MangoHud sub-tabs (Visual, Performance, Metrics, Extras)
- **THEN** each tab synchronizes its toggle switches with the underlying active configuration upon becoming visible
