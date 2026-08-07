# Capability Spec: Startup Asset Pre-download and Progress UI

## Specification

### Startup Pre-download of DLSS Enabler Channels
- WHEN GOverlay starts up:
  - GOverlay SHALL check if assets for DLSS Enabler stable (`dlssenabler-stable/`) and DLSS Enabler bleeding-edge (`dlssenabler-edge/`) exist in the local cache.
  - IF any DLSS Enabler asset is missing, GOverlay SHALL download and extract the missing channel release to its corresponding cache directory.

### Visual Progress Feedback During Startup Downloads
- WHEN GOverlay performs initial asset downloads on startup:
  - GOverlay SHALL display `updateProgressBar` and `updatestatusLabel` styled with GOverlay's dark mode visual theme.
  - GOverlay SHALL set `updatestatusLabel` caption to `"Downloading files..."`.
  - GOverlay SHALL hide `updateProgressBar` and `updatestatusLabel` once all startup downloads complete.
