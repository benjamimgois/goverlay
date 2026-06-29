# Capability: set-bleeding-edge-fsr-version

Writes `fsrversion=4.1.1` to `goverlay.vars` when OptiScaler is installed or updated on the bleeding-edge channel.

## Requirements

### Requirement: Set FSR version to 4.1.1 on bleeding-edge OptiScaler update/install
GOverlay SHALL write or update the `fsrversion` key in `goverlay.vars` to `4.1.1` when OptiScaler is installed or updated on the bleeding-edge channel.

#### Scenario: Installing or updating bleeding-edge OptiScaler
- **WHEN** user installs or updates OptiScaler on the bleeding-edge channel
- **THEN** GOverlay updates `goverlay.vars` with `fsrversion=4.1.1` in both active and `.bgmod_original` directories.
