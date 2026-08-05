# Capability: optiscaler-persistence

## ADDED Requirements

### Requirement: OptiScaler Fsr4Update default value set to auto
GOverlay SHALL write `Fsr4Update=auto` to `OptiScaler.ini` when saving OptiScaler settings with the Latest FSR version selected, and GOverlay SHALL parse both `Fsr4Update=auto` and `Fsr4Update=true` when loading OptiScaler settings to set the FSR version selection to Latest.

#### Scenario: Saving OptiScaler settings with Latest FSR version selected
- **WHEN** GOverlay saves OptiScaler settings with Latest FSR version selected (index 0)
- **THEN** GOverlay sets `Fsr4Update=auto` in `OptiScaler.ini`.

#### Scenario: Loading OptiScaler settings with Fsr4Update=true or auto
- **WHEN** GOverlay loads an `OptiScaler.ini` file containing `Fsr4Update=true` or `Fsr4Update=auto`
- **THEN** GOverlay selects the Latest FSR version (index 0) in the FSR version combobox.
