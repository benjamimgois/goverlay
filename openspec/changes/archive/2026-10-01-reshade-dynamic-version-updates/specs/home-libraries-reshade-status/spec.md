# Spec Delta

## MODIFIED Requirements

### Requirement: ReShade Runtime Status in Libraries Card
The system SHALL display ReShade in the Libraries card on the Home tab with its installation indicator dot and detected version string.

#### Scenario: ReShade is installed
- **WHEN** ReShade runtime binaries (`ReShade64.dll` or `ReShade32.dll`) are present in the ReShade bin directory
- **THEN** ReShade is listed in the Libraries card on the Home tab with a green status indicator dot.
- **AND** the version label displays the detected installed ReShade version string (e.g. `6.8.0 (Add-on Edition)`).

#### Scenario: ReShade is not installed
- **WHEN** ReShade runtime binaries are missing
- **THEN** ReShade is listed in the Libraries card on the Home tab with a red or muted indicator dot.
- **AND** the version label displays `not found` or `—`.
