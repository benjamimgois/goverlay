# Spec Delta

## ADDED Requirements

### Requirement: HelixSR DLSS Spoofing Configuration
The system SHALL maintain the DLSS Spoofing toggle control visible and interactive when HelixSR is selected as the upscaler method in standard mode. When experimental Native DLSS mode is enabled, DLSS spoofing SHALL be hidden or disabled as Native DLSS bypasses the OptiScaler translation layer.

#### Scenario: DLSS Spoofing visible during standard HelixSR mode
- **WHEN** the user selects the HelixSR upscaler method
- **AND** experimental Native DLSS mode is disabled
- **THEN** the system SHALL display the "Spoof DLSS" toggle switch within the upscaler options card
- **AND** allow the user to toggle DLSS spoofing on or off, persisting the setting to the game profile configuration.

#### Scenario: Native DLSS mode interaction with DLSS Spoofing
- **WHEN** the user selects the HelixSR upscaler method
- **AND** enables the experimental Native DLSS toggle
- **THEN** the system SHALL hide or disable the "Spoof DLSS" toggle switch, reflecting that direct DLSS loader bypasses OptiScaler spoofing.
