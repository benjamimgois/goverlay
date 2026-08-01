# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: DLSS Enabler Downloading and Version Tracking
GOverlay SHALL download and extract the latest DLSS Enabler release from `https://github.com/bygalacos/OptiScalerBuilder` into `~/.local/share/goverlay/dlssenabler-edge`.
GOverlay SHALL parse the release description body from `bygalacos/OptiScalerBuilder` to extract the specific `DLSS Enabler` version (e.g. `4.8.10.11`) and integrated `OptiScaler` version (e.g. `v0.10.0-pre1`) and write them to `dlssenabler-edge/goverlay.vars` as `dlssenablerversion` and `optiscalerversion`.
The Software Status section on the Upscalers tab SHALL display the parsed DLSS Enabler version and integrated OptiScaler version.
When DLSS Enabler is enabled (`UPSCALER_TYPE=1`), background update checking and manual update operations SHALL target the `bygalacos/OptiScalerBuilder` repository instead of standard OptiScaler channels.
Global uninstallation via `bgmod-uninstaller --global` SHALL remove the `~/.local/share/goverlay/dlssenabler-edge` directory.

#### Scenario: Global uninstallation cleans DLSS Enabler cache
- **WHEN** user runs `bgmod-uninstaller --global`
- **THEN** system removes the `dlssenabler-edge` cache directory

#### Scenario: Parsing DLSS Enabler release versions
- **WHEN** GOverlay checks or downloads a release from `bygalacos/OptiScalerBuilder`
- **THEN** GOverlay parses the release body table to extract `DLSS Enabler` version (e.g. `4.8.10.11`) and integrated `OptiScaler` version (e.g. `v0.10.0-pre1`) and writes them into `goverlay.vars`

#### Scenario: Targeted update checking when DLSS Enabler is active
- **WHEN** DLSS Enabler is enabled and GOverlay checks for updates
- **THEN** GOverlay compares local `dlssenablerversion` against `bygalacos/OptiScalerBuilder` release tags and displays update status specifically for DLSS Enabler
