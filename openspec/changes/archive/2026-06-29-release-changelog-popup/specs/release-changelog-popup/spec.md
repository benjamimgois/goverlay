# Capability: release-changelog-popup

Displays a release notes popup on the first launch of a new version using GitHub release notes.

## ADDED Requirements

### Requirement: First-launch version changelog detection and popup
GOverlay SHALL check the configured `ChangelogSeenVersion` on startup, and if it differs from the current `GVERSION`, GOverlay SHALL fetch the release notes for the version from GitHub and display them in a popup window.

#### Scenario: First launch after installing a new version
- **WHEN** user launches GOverlay for the first time on a new version
- **THEN** GOverlay fetches the GitHub release notes for `GVERSION` and displays a modal dialog with the release highlights.

#### Scenario: Subsequent launches on the same version
- **WHEN** user launches GOverlay again on the same version after closing the changelog popup
- **THEN** GOverlay opens directly without displaying the changelog popup.
