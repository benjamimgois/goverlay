## MODIFIED Requirements

### Requirement: First-launch version changelog detection and popup
GOverlay SHALL check the configured `ChangelogSeenVersion` on startup, and if it differs from the current `GVERSION`, GOverlay SHALL fetch the release notes for the version from GitHub and display them in an asynchronous, frameless popup window with custom navy borders.
Furthermore, manual requests for the changelog (via the "What's New" menu item) SHALL be executed asynchronously in a background thread and SHALL NOT block the main GUI loop.
The fetch operation SHALL NOT deadlock or block indefinitely, regardless of the size of the release notes payload returned by the GitHub API.

#### Scenario: First launch after installing a new version
- **WHEN** user launches GOverlay for the first time on a new version
- **THEN** GOverlay opens normally and asynchronously displays a frameless modal dialog with the release highlights.

#### Scenario: Subsequent launches on the same version
- **WHEN** user launches GOverlay again on the same version after closing the changelog popup
- **THEN** GOverlay opens directly without displaying the changelog popup.

#### Scenario: User manually requests version changelog
- **WHEN** user clicks on the "What's New" menu item
- **THEN** GOverlay remains fully responsive and asynchronously fetches and displays the release notes popup.

#### Scenario: Fetching release notes with large payloads
- **WHEN** the GitHub API release notes payload exceeds the default operating system pipe buffer (e.g. 64KB)
- **THEN** GOverlay SHALL successfully read the entire payload and display the popup without deadlock.
