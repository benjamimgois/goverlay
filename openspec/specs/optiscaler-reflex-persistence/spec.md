# optiscaler-reflex-persistence Specification

## Purpose
Governs the persistence and UI synchronization of OptiScaler FakeNVAPI's `force_reflex` setting, ensuring follow-in-game (`0`) is treated as unforced and user toggle states persist accurately across template seeding and profile loading.

## Requirements

### Requirement: Interpret Force Reflex Settings on Load
The system SHALL interpret `force_reflex=0` or an absent key as unforced (toggle unchecked), and SHALL interpret `force_reflex=1` (force disable) or `force_reflex=2` (force enable) as forced (toggle checked).

#### Scenario: Loading configuration with force_reflex set to 0
- **WHEN** OptiScaler configuration containing `force_reflex=0` is loaded
- **THEN** the Force Reflex toggle switch SHALL be unchecked and disabled

#### Scenario: Loading configuration with force_reflex set to 1 or 2
- **WHEN** OptiScaler configuration containing `force_reflex=1` or `force_reflex=2` is loaded
- **THEN** the Force Reflex toggle switch SHALL be checked and the corresponding mode SHALL be selected

#### Scenario: Loading configuration without force_reflex key
- **WHEN** OptiScaler configuration lacking a `force_reflex` directive is loaded
- **THEN** the Force Reflex toggle switch SHALL default to unchecked

### Requirement: Persist Force Reflex Settings on Save
The system SHALL serialize `force_reflex` to `fakenvapi.ini` reflecting the user's toggle and mode selection, ensuring unchecked state prevents ghost re-activation during template seeding.

#### Scenario: Saving with Force Reflex disabled
- **WHEN** the user unchecks the Force Reflex toggle and configuration is saved
- **THEN** the system SHALL serialize `force_reflex=0` into `fakenvapi.ini`

#### Scenario: Saving with Force Reflex enabled
- **WHEN** the user checks the Force Reflex toggle, selects force enable or force disable, and configuration is saved
- **THEN** the system SHALL serialize `force_reflex=2` or `force_reflex=1` into `fakenvapi.ini` respectively
