## MODIFIED Requirements

### Requirement: Version Tracking and Update Notifications
The system SHALL detect whether MAKO is currently installed, read the local version from `~/.local/share/mako-render/active-renderer.json` or equivalent manifest, perform asynchronous background update checks without requiring a manual check button, and present an "Install Update" button in the Software Status card when a newer release is available or when MAKO is uninstalled.

#### Scenario: Checking for MAKO updates
- **WHEN** GOverlay launches or user navigates to the Lossless Scaling tab
- **THEN** system asynchronously checks the installed MAKO version against the latest GitHub release without a dedicated check button and displays the "Install Update" action only if a newer release exists or MAKO is missing.
