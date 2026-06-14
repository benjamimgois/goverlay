# PasVulkan Src Sanitization

## Purpose
Sanitize unused source files and directories in the PasVulkan engine to reduce repository size and clean up the codebase.

## Requirements

### Requirement: Delete unused Scene3D source files
The system SHALL not contain any `PasVulkan.Scene3D*.pas` unit files or the `pascube_src/pasvulkan/src/PasVulkan.Scene3D.Renderer/` subdirectory.

#### Scenario: Verify Scene3D unit deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/` directory
- **THEN** no files starting with `PasVulkan.Scene3D` or subdirectories named `PasVulkan.Scene3D.Renderer` SHALL exist.

### Requirement: Delete unused developer tools folder
The system SHALL not contain the `pascube_src/pasvulkan/src/tools/` directory.

#### Scenario: Verify tools directory deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/` directory
- **THEN** the directory `tools` MUST NOT exist.

### Requirement: Delete deprecated ECS old folder
The system SHALL not contain the `pascube_src/pasvulkan/src/old/` directory containing deprecated Entity Component System code.

#### Scenario: Verify old directory deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/` directory
- **THEN** the directory `old` MUST NOT exist.

### Requirement: Delete unused VR RISCV and format source files
The system SHALL not contain unused feature files such as `PasVulkan.VirtualReality*.pas`, `PasVulkan.PasRISCV*.pas`, and `PasVulkan.FileFormats*.pas`.

#### Scenario: Verify unused feature files deletion
- **WHEN** checking the `pascube_src/pasvulkan/src/` directory
- **THEN** files such as `PasVulkan.VirtualReality.pas`, `PasVulkan.PasRISCVEmulator.pas`, and `PasVulkan.FileFormats.GLTF.pas` MUST NOT exist.
