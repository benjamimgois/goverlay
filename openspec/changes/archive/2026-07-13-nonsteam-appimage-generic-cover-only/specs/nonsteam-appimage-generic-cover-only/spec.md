## ADDED Requirements

### Requirement: Always Use Generic Cover for AppImages
GOverlay SHALL always apply the local generic fallback cover art to detected `.appimage`/`.AppImage` games instead of searching for covers online.

#### Scenario: AppImage Initial Load Fallback
- **WHEN** GOverlay loads an AppImage game that does not have a cached cover
- **THEN** it generates the generic fallback cover file immediately and displays it, without queueing the game for online cover download.
