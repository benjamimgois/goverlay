# PasVulkan Externals Cleanup

## Purpose
Clean up unused external libraries in the PasVulkan engine to reduce repository size and maintain codebase sanity.

## Requirements

### Requirement: Delete unused external kraft
The system SHALL not contain the external library directory `pascube_src/pasvulkan/externals/kraft/` containing uncompiled physics engine code.

#### Scenario: Verify kraft deletion
- **WHEN** checking the `pascube_src/pasvulkan/externals/` directory
- **THEN** the directory `kraft` MUST NOT exist.

### Requirement: Delete unused external pasgltf
The system SHALL not contain the external library directory `pascube_src/pasvulkan/externals/pasgltf/` containing GLTF loader code.

#### Scenario: Verify pasgltf deletion
- **WHEN** checking the `pascube_src/pasvulkan/externals/` directory
- **THEN** the directory `pasgltf` MUST NOT exist.

### Requirement: Delete unused external rnl
The system SHALL not contain the external library directory `pascube_src/pasvulkan/externals/rnl/` containing real-time network library code.

#### Scenario: Verify rnl deletion
- **WHEN** checking the `pascube_src/pasvulkan/externals/` directory
- **THEN** the directory `rnl` MUST NOT exist.

### Requirement: Delete unused external pasterm
The system SHALL not contain the external library directory `pascube_src/pasvulkan/externals/pasterm/` containing terminal emulation library code.

#### Scenario: Verify pasterm deletion
- **WHEN** checking the `pascube_src/pasvulkan/externals/` directory
- **THEN** the directory `pasterm` MUST NOT exist.

### Requirement: Delete unused external pinja
The system SHALL not contain the external library directory `pascube_src/pasvulkan/externals/pinja/` containing template engine code.

#### Scenario: Verify pinja deletion
- **WHEN** checking the `pascube_src/pasvulkan/externals/` directory
- **THEN** the directory `pinja` MUST NOT exist.
