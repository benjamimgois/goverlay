## ADDED Requirements

### Requirement: Flatpak read access to /run/media
The GOverlay Flatpak manifests SHALL specify read-only filesystem access (`--filesystem=/run/media:ro`) to allow scanning and loading games from removable media, SD cards, and external storage drives mounted under `/run/media`.

#### Scenario: Scanning game folders mounted under /run/media in Flatpak
- **WHEN** GOverlay runs inside a Flatpak container
- **THEN** sandbox sandbox finish-args grant read permission to `/run/media` alongside `/mnt` and `/media`
