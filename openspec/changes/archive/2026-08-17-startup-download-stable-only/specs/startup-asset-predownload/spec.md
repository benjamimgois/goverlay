## MODIFIED Requirements

### Requirement: Startup Pre-download of DLSS Enabler Channels
- WHEN GOverlay starts up:
  - GOverlay SHALL check if assets for OptiScaler stable (`optiscaler-stable/`) and DLSS Enabler stable (`dlssenabler-stable/`) exist in the local cache.
  - IF any stable asset is missing, GOverlay SHALL download and extract the missing stable release to its corresponding cache directory before presenting the main interface.
  - GOverlay SHALL NOT pre-download bleeding-edge releases (`optiscaler-edge/`, `dlssenabler-edge/`) on startup.

#### Scenario: Missing DLSS Enabler downloaded on startup
- **WHEN** GOverlay launches and DLSS Enabler stable DLLs are not present in local cache
- **THEN** GOverlay downloads and extracts only the missing stable release archives before presenting the main interface.

### Requirement: Visual Progress Feedback During Startup Downloads
- WHEN GOverlay performs initial asset downloads on startup:
  - GOverlay SHALL display a standalone borderless boot splash window (`TForm`) styled with GOverlay's dark mode visual theme.
  - GOverlay SHALL display status messages prefixed with the active component name (`OptiScaler (Stable)`, `DLSS Enabler (Stable)`).
  - GOverlay SHALL hide the boot splash and restore the main window once all startup downloads complete.

#### Scenario: Boot splash displays real-time progress
- **WHEN** startup downloads are in progress
- **THEN** the boot splash updates percentage (0% to 50% for OptiScaler stable, 50% to 95% for DLSS Enabler stable) and component status labels in real-time on a background thread.
