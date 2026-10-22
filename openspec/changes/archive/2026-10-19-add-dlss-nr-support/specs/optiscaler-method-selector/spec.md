# Spec Delta

## MODIFIED Requirements

### Requirement: Upscaler Method Selection and Visual Highlighting
The system SHALL provide a Method selector card in the OptiScaler tab spanning the full horizontal width (`CW`), containing radio buttons and clickable logo images for "None", "OptiScaler", "DLSS Enabler", "HelixSR", and "DLSS-NR" evenly distributed across five equal-width slots. The active selection SHALL display its logo image at 100% full brightness, while unselected selections SHALL display their logo images dimmed to approximately 35% RGB brightness with preserved alpha transparency.

#### Scenario: User selects OptiScaler method
- **WHEN** the user selects the "OptiScaler" method via its radio button or logo image
- **THEN** the system marks the OptiScaler radio button as checked, displays the OptiScaler logo at 100% brightness, dims the None, DLSS Enabler, HelixSR, and DLSS-NR logos to approximately 35% brightness, and enables OptiScaler-specific version and configuration controls.

#### Scenario: User selects DLSS Enabler method
- **WHEN** the user selects the "DLSS Enabler" method via its radio button or logo image
- **THEN** the system marks the DLSS Enabler radio button as checked, displays the DLSS Enabler logo at 100% brightness, dims the None, OptiScaler, HelixSR, and DLSS-NR logos to approximately 35% brightness, and configures version.dll settings.

#### Scenario: User selects HelixSR method
- **WHEN** the user selects the "HelixSR" method via its radio button or logo image
- **THEN** the system marks the HelixSR radio button as checked, displays the HelixSR logo at 100% brightness, dims the None, OptiScaler, DLSS Enabler, and DLSS-NR logos to approximately 35% brightness, and configures HelixSR-specific options.

#### Scenario: User selects DLSS-NR method
- **WHEN** the user selects the "DLSS-NR" method via its radio button or logo image
- **THEN** the system marks the DLSS-NR radio button as checked, displays the DLSS-NR logo at 100% brightness, dims the None, OptiScaler, DLSS Enabler, and HelixSR logos to approximately 35% brightness, and reveals DLSS-NR specific architecture, model, and route configuration controls.

#### Scenario: User selects None method
- **WHEN** the user selects the "None" method via its radio button or logo image
- **THEN** the system marks the None radio button as checked, displays the None logo at 100% brightness, dims the OptiScaler, DLSS Enabler, HelixSR, and DLSS-NR logos to approximately 35% brightness, and disables upscaler controls.

#### Scenario: Full-width Method card layout
- **GIVEN** GOverlay is opened and the user is on the OptiScaler tab
- **WHEN** the tab performs layout reflow
- **THEN** `FOsUpscalerCard` width SHALL span the full content width `CW`
- **AND** the five method slots ("None", "OptiScaler", "DLSS Enabler", "HelixSR", "DLSS-NR") SHALL be distributed evenly across the card width
- **AND** the obsolete standalone GPU Driver card `FOsGpuCard` SHALL remain hidden
