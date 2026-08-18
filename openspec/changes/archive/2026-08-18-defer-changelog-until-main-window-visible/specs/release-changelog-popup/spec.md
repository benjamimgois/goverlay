# Capability: release-changelog-popup (Delta)

## MODIFIED CAPABILITY
`release-changelog-popup`

## Requirements

### Requirement: First-launch version changelog detection and popup
GOverlay SHALL check the configured `ChangelogSeenVersion` on startup, and if it differs from the current `GVERSION`, GOverlay SHALL fetch the release notes for the version from GitHub and display them in an asynchronous, frameless popup window with custom navy borders.
Furthermore, manual requests for the changelog (via the "What's New" menu item) SHALL be executed asynchronously in a background thread and SHALL NOT block the main GUI loop.
The fetch operation SHALL NOT deadlock or block indefinitely, regardless of the size of the release notes payload returned by the GitHub API.

#### Scenario: First launch with startup downloads active
- **WHEN** user launches GOverlay for the first time on a new version and startup downloads are required
- **THEN** GOverlay displays the boot splash screen for downloads, closes the splash screen, displays the main application window, and ONLY then presents the "What's New" release notes popup.

#### Scenario: First launch without startup downloads
- **WHEN** user launches GOverlay for the first time on a new version and no startup downloads are required
- **THEN** GOverlay displays the main application window and asynchronously presents the "What's New" release notes popup.
