# compact-toggles-all-tabs Specification

## Purpose
Replicates compact high-resolution antialiased toggle switches (`TToggleSwitch`, 28x16px) across MangoHud Visual, Performance, Extras, and Lossless Scaling tabs for complete UI consistency.

## Requirements

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

### Requirement: MangoHud Preset Selection Synchronization
The system SHALL synchronize all toggle switches across all MangoHud tabs immediately whenever a preset is selected (Full, Basic, Basic Horizontal, FPS Only, User Custom) or whenever a sub-tab is displayed.

#### Scenario: Switching presets updates all toggle switches
- **WHEN** the user selects a MangoHud preset layout card or button
- **THEN** all toggle switches across Visual, Performance, Metrics, and Extras tabs immediately update to reflect the preset configuration

#### Scenario: Navigating between MangoHud sub-tabs retains synchronized toggle states
- **WHEN** the user switches between MangoHud sub-tabs (Visual, Performance, Metrics, Extras)
- **THEN** each tab synchronizes its toggle switches with the underlying active configuration upon becoming visible

### Requirement: OptiScaler Tab Toggle Switches
The system SHALL display compact toggle switches (28x16px with anti-aliasing SDF rendering and neon glow) for all active toggleable settings on the OptiScaler tab, including OptiPatcher, Spoof DLSS, Force FSR4-i8, Force MLFG in RDNA3, Force Reflex, and Force LatencyFlex, and SHALL automatically trigger configuration auto-save upon state modification.

#### Scenario: OptiScaler toggle switch state synchronization
- **WHEN** OptiScaler configuration is loaded or modified
- **THEN** all OptiScaler toggle switches reflect the configuration and persist changes upon saving

#### Scenario: OptiScaler toggle automatic persistence
- **WHEN** a user clicks any toggle switch on the OptiScaler tab
- **THEN** the configuration is automatically saved without requiring an explicit finish button click

#### Scenario: OptiPatcher companion button alignment
- **WHEN** the OptiScaler tab layout is reflowed
- **THEN** the OptiPatcher toggle switch and its companion games list button align seamlessly within the Main options sub-card

### Requirement: Global Auto-Save for Toggle Switches
The system SHALL automatically wire all toggle switches and checkboxes to trigger auto-save timers across all tabs so that user state changes persist across application restarts.

#### Scenario: Auto-save event registration
- **WHEN** the application wires controls for auto-saving during startup or dynamic initialization
- **THEN** both `OnChange` and `OnClick` handlers on `TCheckBox` and `TToggleSwitch` are wired to trigger the background auto-save timer
