## Purpose

Defines the Method selection card behavior in the OptiScaler tab, allowing users to toggle between None, OptiScaler, and DLSS Enabler with visual brightness highlighting.

## ADDED Requirements

### Requirement: Upscaler Method Selection and Visual Highlighting
The system SHALL provide a Method selector card in the OptiScaler tab containing radio buttons and adjacent clickable logo images for "None", "OptiScaler", and "DLSS Enabler". The active selection SHALL display its logo image at 100% full brightness, while inactive/unselected selections SHALL display their logo images dimmed to approximately 35% RGB brightness with preserved alpha transparency.

#### Scenario: User selects OptiScaler method
- **WHEN** the user selects the "OptiScaler" method via its radio button or logo image
- **THEN** the system marks the OptiScaler radio button as checked, displays the OptiScaler logo at 100% brightness, dims the None and DLSS Enabler logos to approximately 35% brightness, and enables OptiScaler-specific version and configuration controls.

#### Scenario: User selects DLSS Enabler method
- **WHEN** the user selects the "DLSS Enabler" method via its radio button or logo image
- **THEN** the system marks the DLSS Enabler radio button as checked, displays the DLSS Enabler logo at 100% brightness, dims the None and OptiScaler logos to approximately 35% brightness, and configures version.dll settings.

#### Scenario: User selects None method
- **WHEN** the user selects the "None" method via its radio button or logo image
- **THEN** the system marks the None radio button as checked, displays the None logo at 100% brightness, dims the OptiScaler and DLSS Enabler logos to approximately 35% brightness, and disables upscaler controls.
