## Purpose

Ensures that built-in vkBasalt effects (CAS, FXAA, SMAA, DLS) are serialized exactly once in `vkBasalt.conf` and are not treated as external ReShade shader file paths.

## ADDED Requirements

### Requirement: Single-instance Built-in Effects Serialization
The system SHALL serialize active built-in effects (`cas`, `fxaa`, `smaa`, `dls`) at most once into the `effects` line in `vkBasalt.conf`.

#### Scenario: Enabling CAS sharpness
- **WHEN** CAS sharpness trackbar is set to a non-zero value (e.g. position 1 or 5) and configuration is saved
- **THEN** `vkBasalt.conf` contains `effects = cas` (not `effects = cas:cas`) and does not contain `cas = .../reshade-shaders/cas`.

#### Scenario: Enabling multiple built-in effects alongside ReShade shaders
- **WHEN** CAS and FXAA trackbars are active and an external ReShade shader (e.g. `Shaders/ColorMatrix.fx`) is active
- **THEN** `effects` line lists `cas:fxaa:ColorMatrix` with each effect appearing exactly once, and only `ColorMatrix` is assigned a shader file path (`ColorMatrix = .../reshade-shaders/Shaders/ColorMatrix.fx`).

### Requirement: ReShade Active Effects List Separation
The system SHALL maintain `acteffectsListbox` exclusively for user-selected external ReShade shaders and NOT populate it with built-in effect identifiers.

#### Scenario: Adjusting built-in effect trackbars
- **WHEN** user moves `casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, or `dlsTrackBar`
- **THEN** the trackbar values and labels are updated without adding `'cas'`, `'fxaa'`, `'smaa'`, or `'dls'` items into `acteffectsListbox`.
