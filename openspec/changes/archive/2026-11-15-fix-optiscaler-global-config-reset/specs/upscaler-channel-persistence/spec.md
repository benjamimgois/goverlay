# Spec Delta

## ADDED Requirements

### Requirement: Startup and Load Guard for Channel Persistence
The system SHALL NOT overwrite the persisted `OPT_CHANNEL` in global or per-game `bgmod.conf` during application startup (`FormCreate`) or programmatic configuration loading (`LoadOptiScalerConfig`), and SHALL restore the persisted channel in the channel combobox regardless of uninitialized version labels.

#### Scenario: Global channel preserved across application restart
- **WHEN** the user selects a non-default OptiScaler channel (such as Bleeding-edge or Custom Build) in global mode, closes Goverlay, and restarts Goverlay
- **THEN** the startup load sequence SHALL restore the saved `OPT_CHANNEL` in `optversionComboBox` without firing radio-button click handlers that reset `OPT_CHANNEL` to `0` in `gameconfig/global/bgmod.conf`

#### Scenario: Switching from None upscaler to OptiScaler profile preserves channel
- **WHEN** the user switches from a profile using `None` (`UPSCALER_TYPE=2`) to a profile using `OptiScaler` (`UPSCALER_TYPE=0`) with a non-default channel
- **THEN** `LoadOptiScalerConfig` SHALL populate all UI controls without triggering an intermediate `SaveOptiScalerConfig` call that overwrites the loaded profile's `OPT_CHANNEL`
