# vkbasalt-builtin-effects-serialization Specification

## Purpose
Ensures that built-in vkBasalt effects (CAS, FXAA, SMAA, DLS, LUT) are serialized exactly once in `vkBasalt.conf` and are not treated as external ReShade shader file paths.

## Requirements

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

### Requirement: Available ReShade Effects Filtering and Deduplication
The system SHALL populate the available ReShade effects list (`aveffectsListBox`) exclusively with unique, runnable shader files, excluding header files (`.fxh`, `.h`), duplicate effect names, and built-in effects that have dedicated native controls (`FXAA`, `SMAA`, `LUT`, `CAS`, `DLS`).

#### Scenario: Scanning shader repository with header and duplicate files
- **WHEN** the system scans the vkBasalt shader repository containing `.fx` files, header files (`.fxh`, `.h`), and multiple files sharing the same base effect name
- **THEN** only files with executable shader extensions (`.fx`, `.glsl`) are considered.
- **AND** header files such as `FXAA.fxh`, `SMAA.fxh`, `UIDetect.fxh`, `ReShade.fxh`, and `DrawText.fxh` are not added to `aveffectsListBox`.
- **AND** if multiple files share the same base effect name (case-insensitive), only the first encountered file is added to `aveffectsListBox`.

#### Scenario: Excluding built-in effects from ReShade effects list
- **WHEN** the system discovers `FXAA.fx`, `SMAA.fx`, or `LUT.fx` in the shader repository
- **THEN** they are excluded from `aveffectsListBox`, ensuring FXAA, SMAA, and LUT are only configured through the dedicated Built-in Effects controls.
