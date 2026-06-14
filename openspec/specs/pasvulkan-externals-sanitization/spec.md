# PasVulkan Externals Sanitization

## Purpose
Sanitize unused externals and non-Linux precompiled libraries in the PasVulkan engine to reduce repository size and clean up the codebase.

## Requirements

### Requirement: Delete unused floating-point parsing testdata
The system SHALL not contain the testdata folder under `pascube_src/pasvulkan/externals/pasdblstrutils/testdata/`.

#### Scenario: Verify testdata deletion
- **WHEN** checking the `pasdblstrutils` directory
- **THEN** the `testdata` folder MUST NOT exist.

### Requirement: Delete unused pasgltf project files and compiled binary viewers
The system SHALL not contain Delphi/FPC project files, demo viewers, or compiled binary viewers under `pascube_src/pasvulkan/externals/pasgltf/` (specifically `bin/`, `src/viewer/`, `src/combineanimations/`, and `src/smartcombineanimations/`).

#### Scenario: Verify pasgltf viewer cleanup
- **WHEN** checking folders inside `pascube_src/pasvulkan/externals/pasgltf/`
- **THEN** the directories `bin/`, `src/viewer/`, `src/combineanimations/`, and `src/smartcombineanimations/` MUST NOT exist.

### Requirement: Remove non-Linux-64 precompiled libraries
The system SHALL not contain precompiled static or dynamic libraries under `pascube_src/pasvulkan/libs/` targeting Windows, macOS, Android, or Linux 32-bit platforms.

#### Scenario: Verify platform libraries cleanup
- **WHEN** checking folders inside `pascube_src/pasvulkan/libs/`
- **THEN** only `libktxlinux64` and `sdl20linux64` MUST remain, and all other platform directories (`libktxwin64`, `libpngandroid`, `sdl20androidarm32`, `sdl20androidarm64`, `sdl20androidi386`, `sdl20androidx64`, `sdl20linux32`, `sdl20macosx32`, `sdl20macosx64`, `sdl20win32`, and `sdl20win64`) MUST NOT exist.

### Requirement: Clear all untracked folder remnants
The system SHALL not contain filesystem folder remnants of deleted libraries (`flre/`, `pasllm/`, `poca/`).

#### Scenario: Verify untracked directory removal
- **WHEN** checking folders inside `pascube_src/pasvulkan/externals/`
- **THEN** the directories `flre/`, `pasllm/`, and `poca/` MUST NOT exist.
