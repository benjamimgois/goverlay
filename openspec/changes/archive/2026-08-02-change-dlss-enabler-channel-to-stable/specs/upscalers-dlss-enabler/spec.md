# Capability: Upscalers Tab & DLSS Enabler Support

## MODIFIED Requirements

### Requirement: DLSS Enabler Downloading and Version Tracking
GOverlay SHALL download and extract the latest DLSS Enabler release from `https://github.com/bygalacos/OptiScalerBuilder` into `~/.local/share/goverlay/dlssenabler-stable`.
GOverlay SHALL parse the release description body from `bygalacos/OptiScalerBuilder` to extract the specific `DLSS Enabler` version and integrated `OptiScaler` version and write them to `dlssenabler-stable/goverlay.vars` as `dlssenablerversion` and `optiscalerversion`.
When DLSS Enabler is selected, the channel dropdown `optversionComboBox` SHALL select index 0 ("Stable Channel") and be disabled.
Global uninstallation via `bgmod-uninstaller --global` SHALL remove the `~/.local/share/goverlay/dlssenabler-stable` directory (and `dlssenabler-edge` if present).

#### Scenario: DLSS Enabler channel and cache directory
- **WHEN** user selects DLSS Enabler option or GOverlay downloads DLSS Enabler
- **THEN** GOverlay downloads files into `~/.local/share/goverlay/dlssenabler-stable` and sets channel dropdown to index 0 ("Stable Channel")
