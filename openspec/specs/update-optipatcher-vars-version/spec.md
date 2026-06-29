# Capability: update-optipatcher-vars-version

Automatically updates the `optipatcher=rolling-yyyy.MM.dd` version key in `goverlay.vars` whenever OptiScaler is installed or updated.

## Requirements

### Requirement: Write optipatcher version key in goverlay.vars on OptiScaler install/update
GOverlay SHALL write or update the `optipatcher` key in `goverlay.vars` whenever OptiScaler is installed or updated.

#### Scenario: Installing or updating OptiScaler
- **WHEN** user installs or updates OptiScaler via GOverlay
- **THEN** GOverlay updates `goverlay.vars` with `optipatcher=rolling-yyyy.MM.dd` matching the current local date in both active and `.bgmod_original` directories.
