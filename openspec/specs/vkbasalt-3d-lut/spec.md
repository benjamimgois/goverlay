# vkbasalt-3d-lut Specification

## Purpose

Provides dedicated UI controls and lifecycle management for vkBasalt 3D LookUp Table (LUT) color grading using Adobe .cube and HaldCLUT .png files.

## Requirements

### Requirement: 3D LUT File Selection and Activation
The system SHALL provide a file selection mechanism in the Built-in Effects card supporting Adobe 3D LUT (`.cube`) and HaldCLUT (`.png`) files, automatically activating the effect upon file selection.

#### Scenario: Selecting a valid LUT file
- **WHEN** the user clicks "Browse" on the Color LUT control and selects a valid `.cube` or `.png` file
- **THEN** the file path is displayed in the Color LUT path field.
- **AND** `lut` is automatically added to the Effect Pipeline if not already present.
- **AND** auto-save is triggered.

### Requirement: 3D LUT Clearing and Deactivation
The system SHALL provide a clear action to remove the selected LUT file and deactivate the effect.

#### Scenario: Clearing the LUT file
- **WHEN** the user clicks the clear button (`✕`) next to the Color LUT path field
- **THEN** the path field is cleared.
- **AND** `lut` is removed from the Effect Pipeline.
- **AND** auto-save is triggered.

### Requirement: 3D LUT Pipeline Chip Synchronization
The system SHALL synchronize the Color LUT UI controls with the Effect Pipeline card.

#### Scenario: Closing LUT chip in pipeline
- **WHEN** the user clicks the close button (`✕`) on the `LUT` chip in the Effect Pipeline card
- **THEN** the Color LUT path field is cleared.
- **AND** the `LUT` chip is removed from the pipeline.
- **AND** auto-save is triggered.

#### Scenario: Restoring vkBasalt defaults
- **WHEN** the user clicks "Restore Defaults" on the vkBasalt options card
- **THEN** the Color LUT path field is cleared.
- **AND** `lut` is removed from the Effect Pipeline.
