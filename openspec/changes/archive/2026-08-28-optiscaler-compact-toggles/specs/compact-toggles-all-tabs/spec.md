## ADDED Requirements

### Requirement: OptiScaler Tab Toggle Switches
The system SHALL display compact toggle switches (28x16px with anti-aliasing SDF rendering and neon glow) for all active toggleable settings on the OptiScaler tab, including OptiPatcher, Spoof DLSS, Force FSR4-i8, Force MLFG in RDNA3, Force Reflex, and Force LatencyFlex.

#### Scenario: OptiScaler toggle switch state synchronization
- **WHEN** OptiScaler configuration is loaded or modified
- **THEN** all OptiScaler toggle switches reflect the configuration and persist changes upon saving

#### Scenario: OptiPatcher companion button alignment
- **WHEN** the OptiScaler tab layout is reflowed
- **THEN** the OptiPatcher toggle switch and its companion games list button align seamlessly within the Main options sub-card
