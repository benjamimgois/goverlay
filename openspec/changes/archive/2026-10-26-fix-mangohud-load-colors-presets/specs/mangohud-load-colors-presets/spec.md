# Spec Delta

## Purpose

Governs the initialization, reset defaults, and preset theme mappings for CPU and GPU load color thresholds in MangoHud.

## ADDED Requirements

### Requirement: Default CPU and GPU Load Colors on Reset
The system SHALL initialize CPU and GPU load color controls to MangoHud Stock defaults (low = White, medium = Orange, high = Red) upon control reset or when loading configurations without load color directives.

#### Scenario: UI controls reset to defaults
- **WHEN** MangoHud controls are reset to defaults
- **THEN** both GPU and CPU low-load swatches SHALL be White, medium-load swatches SHALL be Orange, and high-load swatches SHALL be Red

### Requirement: Preset Color Theme Mappings for Load Colors
The system SHALL update all three load color swatches for both CPU and GPU when a color preset theme is selected.

#### Scenario: MangoHud Stock preset selected
- **WHEN** the user selects the MangoHud Stock color theme preset
- **THEN** both CPU and GPU load colors SHALL be set to White for low, Orange for medium, and Red for high

#### Scenario: Goverlay preset selected
- **WHEN** the user selects the Goverlay color theme preset
- **THEN** both CPU and GPU load colors SHALL be set to GOverlay Cyan for low, Orange for medium, and Red for high

#### Scenario: Simple White preset selected
- **WHEN** the user selects the Simple White color theme preset
- **THEN** both CPU and GPU load colors SHALL be set to White across low, medium, and high thresholds

#### Scenario: Old Afterburner preset selected
- **WHEN** the user selects the Old Afterburner color theme preset
- **THEN** both CPU and GPU load colors SHALL be set to Pink across low, medium, and high thresholds
