## MODIFIED Requirements

### Requirement: On-demand manual installation and update check from UI
The system SHALL provide an interactive installation/update trigger and status indicator in the Software Status card and Home tab, evaluating remote updates strictly against official stable releases from `builds.lsfg-vk.dev` while ignoring development git autobuilds and pre-releases.

#### Scenario: User clicks install or update for lsfg-vk
- **WHEN** user clicks the install or update button adjacent to `lsfg-vk` in the Software Status card
- **THEN** system initiates a background thread to fetch the latest official stable archive, extracts the runtime into `~/.local`, and updates the status dot and version label upon completion.

#### Scenario: Background update check when newer git commit exists upstream
- **WHEN** an upstream git commit build exists on `builds.lsfg-vk.dev` (e.g. `Latest git version`) but the official `Latest release` matches the installed version
- **THEN** system SHALL NOT report an update available, SHALL NOT show an update indicator (`installed → remote`), and SHALL NOT display the install update button.
