# Spec Delta

## ADDED Requirements

### Requirement: AFMF Version Tracking and Update Notifications
The system SHALL check the installed `afmf-linux` version against upstream releases using GitHub REST API and unthrottled Atom feed fallbacks. Remote update discovery SHALL return an empty string upon resolution failure rather than a hardcoded legacy version, and update banners SHALL only display when the remote release is semantically newer than installed (`CompareVersions > 0`).

#### Scenario: AFMF update check with newer release available
- **WHEN** user views the Software Status card or initiates an update check
- **AND** GitHub API or Atom feed reports an `afmf-linux` release strictly newer than installed
- **THEN** system displays the update indicator (`InstalledVer → RemoteVer`) and the "Install update" action button.

#### Scenario: AFMF update check when remote version is equal or older
- **WHEN** remote version check returns a version equal to or older than the installed AFMF version
- **THEN** system SHALL NOT display the update indicator, SHALL NOT show "Install update", and SHALL suppress downgrade actions.

#### Scenario: Remote AFMF check fails due to rate limits or offline network
- **WHEN** GitHub API rate limits are exceeded and Atom feed fallback fails to resolve a valid release
- **THEN** system returns an empty version string rather than hardcoded `1.3.1`, preventing false downgrade notifications.
