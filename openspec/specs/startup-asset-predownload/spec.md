# Capability Spec: Startup Asset Pre-download and Progress UI

## Purpose

Ensures missing OptiScaler and DLSS Enabler asset binaries (stable and bleeding-edge) are automatically pre-downloaded on startup with a clean, borderless boot splash progress UI.

## Requirements

### Requirement: Startup Pre-download of DLSS Enabler Channels
- WHEN GOverlay starts up:
  - GOverlay SHALL check if assets for DLSS Enabler stable (`dlssenabler-stable/`) and DLSS Enabler bleeding-edge (`dlssenabler-edge/`) exist in the local cache.
  - IF any DLSS Enabler asset is missing, GOverlay SHALL download and extract the missing channel release to its corresponding cache directory.

#### Scenario: Missing DLSS Enabler downloaded on startup
- **WHEN** GOverlay launches and DLSS Enabler stable or edge DLLs are not present in local cache
- **THEN** GOverlay downloads and extracts the missing release archives before presenting the main interface

### Requirement: Visual Progress Feedback During Startup Downloads
- WHEN GOverlay performs initial asset downloads on startup:
  - GOverlay SHALL display a standalone borderless boot splash window (`TForm`) styled with GOverlay's dark mode visual theme.
  - GOverlay SHALL display status messages prefixed with the active component name (`OptiScaler (Stable)`, `OptiScaler (Edge)`, `DLSS Enabler (Stable)`, `DLSS Enabler (Edge)`).
  - GOverlay SHALL hide the boot splash and restore the main window once all startup downloads complete.

#### Scenario: Boot splash displays real-time progress
- **WHEN** startup downloads are in progress
- **THEN** the boot splash updates percentage and component status labels in real-time on a background thread
