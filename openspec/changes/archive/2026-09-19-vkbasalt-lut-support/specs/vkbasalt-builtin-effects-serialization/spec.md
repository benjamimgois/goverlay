# Spec Delta

## MODIFIED Requirements

### Requirement: Single-instance Built-in Effects Serialization
The system SHALL serialize active built-in effects (`cas`, `fxaa`, `smaa`, `dls`, `lut`) at most once into the `effects` line in `vkBasalt.conf`, and serialize `lutFile = "<path>"` when `lut` is active.

#### Scenario: Enabling CAS sharpness
- **WHEN** CAS sharpness trackbar is set to a non-zero value (e.g. position 1 or 5) and configuration is saved
- **THEN** `vkBasalt.conf` contains `effects = cas` (not `effects = cas:cas`) and does not contain `cas = .../reshade-shaders/cas`.

#### Scenario: Enabling multiple built-in effects alongside ReShade shaders
- **WHEN** CAS and FXAA trackbars are active and an external ReShade shader (e.g. `Shaders/ColorMatrix.fx`) is active
- **THEN** `effects` line lists `cas:fxaa:ColorMatrix` with each effect appearing exactly once, and only `ColorMatrix` is assigned a shader file path (`ColorMatrix = .../reshade-shaders/Shaders/ColorMatrix.fx`).

#### Scenario: Enabling Color LUT effect
- **WHEN** Color LUT has a valid file path configured and configuration is saved
- **THEN** `effects` line includes `lut` at its designated position in the pipeline.
- **AND** `vkBasalt.conf` contains `lutFile = "<path>"`.
- **AND** `vkBasalt.conf` does NOT treat `lut` as an external ReShade shader (`lut = .../reshade-shaders/lut.fx` is not emitted).

#### Scenario: Loading configuration with LUT
- **WHEN** `vkBasalt.conf` contains `effects = cas:lut` and `lutFile = "/home/user/lut.cube"`
- **THEN** `LoadVkBasaltConfig` parses `lut` into the pipeline and sets the LUT file path to `/home/user/lut.cube`.
- **AND** `lut` is NOT added to `acteffectsListBox` as a ReShade shader.

### Requirement: ReShade Active Effects List Separation
The system SHALL maintain `acteffectsListbox` exclusively for user-selected external ReShade shaders and NOT populate it with built-in effect identifiers (`cas`, `fxaa`, `smaa`, `dls`, `lut`).

#### Scenario: Adjusting built-in effect trackbars
- **WHEN** user moves `casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, `dlsTrackBar`, or configures a Color LUT file
- **THEN** the trackbar values, labels, and LUT path are updated without adding `'cas'`, `'fxaa'`, `'smaa'`, `'dls'`, or `'lut'` items into `acteffectsListbox`.
