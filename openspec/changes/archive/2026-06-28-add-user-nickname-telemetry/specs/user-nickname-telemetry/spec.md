## ADDED Requirements

### Requirement: User nickname configuration UI
The system SHALL provide a text input field in settings allowing the user to enter and save an optional display nickname.

#### Scenario: Saving user nickname
- **WHEN** user enters a nickname and saves configuration
- **THEN** the system stores the nickname in `goverlay.ini` and reloads it on launch

### Requirement: Telemetry nickname inclusion
The system SHALL pass the configured user nickname to benchmark execution processes (PasCube) alongside the hardware client-id.

#### Scenario: Launching PasCube benchmark with nickname
- **WHEN** PasCube is launched by GOverlay for benchmarking
- **THEN** the system passes `--nickname "<nickname>"` in the launch command line parameters
