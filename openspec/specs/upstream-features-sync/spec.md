# upstream-features-sync Specification

## Purpose
Provides graphical UI controls and configuration persistence for newly introduced upstream features in OptiScaler, MangoHud, HelixSR, vkSumi, and MAKO.

## Requirements

### Requirement: OptiScaler FSR4 Preset Selection
The system SHALL provide a dropdown selector for FSR4 presets (`Fsr4Preset`) allowing the user to select Auto, Native, Quality, Balanced, Performance, Ultra Performance, or DRS.

#### Scenario: User selects FSR4 Quality preset
- **WHEN** user selects `Quality` from the FSR4 Preset dropdown and saves
- **THEN** Goverlay writes `Fsr4Preset=quality` into `OptiScaler.ini`

### Requirement: MangoHud DirectX API Metric
The system SHALL provide a graphical switch in the MangoHud tab to display the translated DirectX API (`dx_api`).

#### Scenario: Enabling DirectX API metric
- **WHEN** user enables the `Display DirectX API` toggle in MangoHud tab and saves
- **THEN** Goverlay includes `dx_api` in the active `MangoHud.conf`

### Requirement: MangoHud Text Outline Control
The system SHALL provide a graphical toggle in the MangoHud tab to enable text outlining (`text_outline`).

#### Scenario: Enabling text outline
- **WHEN** user enables the `Text Outline` toggle and saves
- **THEN** Goverlay writes `text_outline` into `MangoHud.conf`

### Requirement: HelixSR Sharpening and WaveSize Controls
The system SHALL provide controls in the OptiScaler tab for HelixSR sharpener algorithm, sharpness level, and shader wave size.

#### Scenario: Configuring HelixSR RCAS sharpener
- **WHEN** user selects `RCAS` and sets sharpness to 0.70 in the HelixSR section
- **THEN** Goverlay writes `Sharpener=RCAS` and `Sharpness=0.70` into `helixsr.ini`

### Requirement: vkSumi Compare Mode and Daltonize Controls
The system SHALL provide a split-screen compare toggle and color blindness correction selector for vkSumi.

#### Scenario: Enabling A/B comparison
- **WHEN** user toggles `Compare Mode` on in the Color Grading (vkSumi) tab
- **THEN** Goverlay writes `compare=true` into `vksumi.conf`

### Requirement: MAKO Steam Overlay Suppression
The system SHALL provide a toggle in the Lossless Scaling tab to suppress the Steam overlay in MAKO configuration (`disable_steam_overlay`).

#### Scenario: Disabling Steam overlay in MAKO
- **WHEN** user checks `Disable Steam Overlay` in the MAKO configuration section
- **THEN** Goverlay writes `disable_steam_overlay = true` into `conf.toml`
