# Spec Delta

## ADDED Requirements

### Requirement: Preserve Existing fakenvapi.ini During Asset Sync
The system SHALL only seed `fakenvapi.ini` from the cache template during `CopyOptiScalerGameFiles` when `fakenvapi.ini` does not already exist in the target configuration directory, preserving existing user settings such as `force_reflex`.

#### Scenario: Enabling OptiScaler globally does not overwrite existing fakenvapi.ini
- **WHEN** `gameconfig/global/fakenvapi.ini` already exists with `force_reflex=2` and the user enables OptiScaler via the sidebar toggle
- **THEN** `CopyOptiScalerGameFiles` SHALL preserve the existing `gameconfig/global/fakenvapi.ini` instead of overwriting it with the cache template

### Requirement: Default Force Reflex Mode When Toggled On
When the user enables the Force Reflex toggle while the Reflex mode selector is set to `Follow game setting` (`0`), the system SHALL automatically select `Force enable` (`2`) so that the enabled toggle persists as `force_reflex=2` rather than `force_reflex=0`.

#### Scenario: Toggling Force Reflex on from default mode persists across restart
- **WHEN** the user enables the Force Reflex toggle without manually changing the Reflex mode combobox from `Follow game setting`
- **THEN** the Reflex mode combobox SHALL switch to `Force enable` (`2`), serialize `force_reflex=2` to `fakenvapi.ini`, and restore the checked state on restart
