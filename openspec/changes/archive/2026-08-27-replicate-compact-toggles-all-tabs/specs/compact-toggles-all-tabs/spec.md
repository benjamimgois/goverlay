## Purpose

Replicates compact high-resolution antialiased toggle switches (`TToggleSwitch`, 28x16px) across MangoHud Visual, Performance, Extras, and Lossless Scaling tabs for complete UI consistency.

## ADDED Requirements

### Requirement: MangoHud Visual Tab Toggle Switches
The system SHALL display compact toggle switches for Compact HUD, Horizontal Stretch, Hide by default, and Change FPS colors on the MangoHud Visual tab.

#### Scenario: Visual tab toggle state synchronization
- **WHEN** MangoHud configuration is loaded or modified
- **THEN** Visual tab toggle switches reflect the configuration and persist changes upon saving

### Requirement: MangoHud Performance Tab Toggle Switches
The system SHALL display compact toggle switches for Information items (Show FPS, FPS Average, FPS limit, Frame Time, Frame Time +, VPS, Count frames, ftrace debug) on the MangoHud Performance tab.

#### Scenario: Performance tab toggle interaction
- **WHEN** a user toggles an option on the Performance tab
- **THEN** the state updates immediately and couples properly (disabling Frame Time + when Frame Time is unchecked)

### Requirement: MangoHud Extras Tab Toggle Switches
The system SHALL display compact toggle switches across all cards on the MangoHud Extras tab (Engine/Wine, Logging, Battery, Custom text, Time, Media, Present mode).

#### Scenario: Extras tab configuration persistence
- **WHEN** user enables or disables metrics on the Extras tab
- **THEN** the toggle switches synchronize with `MangoHud.conf`

### Requirement: Lossless Scaling Tab Toggle Switches
The system SHALL display compact toggle switches for Performance Mode, HDR Mode, and Disable FP16 on the Lossless Scaling configuration tab.

#### Scenario: Lossless Scaling toggle persistence
- **WHEN** user toggles options on the Lossless Scaling tab
- **THEN** the toggle switches update the underlying configuration and persist to disk
