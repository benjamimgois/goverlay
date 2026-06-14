# PasVulkan Assets Sanitization

## Purpose
Sanitize unused assets in the PasVulkan engine to reduce repository size and clean up the codebase.

## Requirements

### Requirement: Delete unused mono font notomono
The system SHALL not contain the font file `pascube_src/pasvulkan/src/assets/fonts/notomono.ttf` as it has been replaced by `hackregular.ttf`.

#### Scenario: Verify notomono deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/assets/fonts/` directory
- **THEN** the file `notomono.ttf` MUST NOT exist.

### Requirement: Delete unused logo assets folder
The system SHALL not contain the directory `pascube_src/pasvulkan/src/assets/logo/` containing unused logo files and scripts.

#### Scenario: Verify logo directory deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/assets/` directory
- **THEN** the directory `logo` MUST NOT exist.

### Requirement: Delete unused scene3d shaders folder
The system SHALL not contain the directory `pascube_src/pasvulkan/src/assets/shaders/scene3d/` containing uncompiled 3D scene shaders.

#### Scenario: Verify scene3d shaders directory deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/assets/shaders/` directory
- **THEN** the directory `scene3d` MUST NOT exist.
