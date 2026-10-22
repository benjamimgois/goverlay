## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Global Auto-Save for Toggle Switches
The system SHALL automatically wire all toggle switches and checkboxes to trigger auto-save timers across all tabs so that user state changes persist across application restarts.

#### Scenario: Auto-save event registration
- **WHEN** the application wires controls for auto-saving during startup or dynamic initialization
- **THEN** both `OnChange` and `OnClick` handlers on `TCheckBox` and `TToggleSwitch` are wired to trigger the background auto-save timer
