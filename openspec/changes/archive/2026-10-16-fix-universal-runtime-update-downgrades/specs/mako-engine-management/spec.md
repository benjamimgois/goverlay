# Spec Delta

## MODIFIED Requirements

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json`, and perform asynchronous update checks using GitHub releases and unthrottled Atom feed fallbacks. The system SHALL strictly require the remote version to be semantically newer than the local version (`CompareVersions > 0`) before displaying the update indicator (`InstalledVer → RemoteVer`) or enabling "Install update", suppressing downgrades when remote <= local.

#### Scenario: Checking for MAKO updates
- **WHEN** GOverlay launches or user navigates to the Lossless Scaling tab
- **THEN** system asynchronously checks the installed MAKO version against the latest GitHub release or Atom feed, persists the detected remote version in session state, and only shows the update indicator and "Install update" action if the remote release is semantically newer than the installed version.

#### Scenario: Navigating to Lossless Scaling tab with pending update
- **WHEN** user navigates to the Lossless Scaling tab while an update is pending
- **THEN** system preserves the update state (`InstalledVer → RemoteVer`) on the engine status label, displays the update status in the Software Status card, and keeps the "Install update" button visible.

#### Scenario: Checking for MAKO updates when installed version is up-to-date or newer
- **WHEN** remote version check returns a version equal to or older than the installed version (e.g., local 4.0.0 and remote 3.0.0 or 4.0.0)
- **THEN** system SHALL NOT display any update indicator (`→`), SHALL NOT enable the "Install update" button, and SHALL report that MAKO is up to date.

#### Scenario: Remote check fails due to rate limits or offline network
- **WHEN** GitHub API rate limits are exceeded and Atom feed fallback fails to resolve a valid release
- **THEN** system returns an empty version string rather than a hardcoded legacy version, preserving current local status without triggering a false downgrade notification.
