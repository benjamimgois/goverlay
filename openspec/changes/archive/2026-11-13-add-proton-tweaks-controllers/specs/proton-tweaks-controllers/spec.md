# Spec Delta

## Purpose

Provides a dedicated `Controllers` category with `GE` badges in Goverlay's Tweaks tab for Proton controller environment variables, and exposes `PROTON_ZLUDA=1` in the `Experimental` category.

## ADDED Requirements

### Requirement: Controllers category in Tweaks tab
The system SHALL display a `Controllers` category card in the Tweaks tab containing `PROTON_USE_SDL=1` (moved from `General`) and the Proton-GE controller environment variables.

#### Scenario: Viewing the Controllers card
- **WHEN** the user opens the Tweaks tab
- **THEN** a `Controllers` category card is rendered with `PROTON_USE_SDL=1` and the Proton-GE controller toggles

### Requirement: Proton-GE badge rendering
The system SHALL render a `GE` badge for Tweaks entries whose description begins with `[GE]` or `[proton-ge]`.

#### Scenario: Rendering a Proton-GE exclusive tweak
- **WHEN** a tweak row has a description prefixed with `[GE]`
- **THEN** the Tweaks card renders a `GE` badge next to the variable and strips the `[GE]` prefix from the displayed description text

### Requirement: Proton-GE controller environment variables
The system SHALL provide toggles in the `Controllers` category for `PROTON_SONY_WINDOWS_DEVICE_NAMES=1`, `PROTON_STEAM_INPUT_XBOX_PROMPTS=1`, `PROTON_SONY_AUTO_XINPUT=0`, `PROTON_SONY_HIDRAW_XINPUT=1`, and `PROTON_DUALSENSE_HAPTICS_PREFER_NON_EVENT=1`, each with a `[GE]` badge and English description, and persist them in fgmod/global config.

#### Scenario: Saving and reloading a Proton-GE controller tweak
- **WHEN** the user enables `PROTON_SONY_WINDOWS_DEVICE_NAMES=1` or `PROTON_SONY_AUTO_XINPUT=0` and saves Tweaks
- **THEN** the corresponding key/value (`1` or `0`) is written to the `[Env]` configuration and restored as checked when Tweaks is reloaded

### Requirement: PROTON_ZLUDA=1 in Experimental category
The system SHALL provide a toggle for `PROTON_ZLUDA=1` in the `Experimental` category with the `[proton-cachyos]` badge (`CachyOS`) and English description, and persist it in `[Env]` configuration.

#### Scenario: Enabling PROTON_ZLUDA=1
- **WHEN** the user enables `PROTON_ZLUDA=1` in the `Experimental` card and saves Tweaks
- **THEN** `PROTON_ZLUDA=1` is persisted to `[Env]` configuration and restored on reload
