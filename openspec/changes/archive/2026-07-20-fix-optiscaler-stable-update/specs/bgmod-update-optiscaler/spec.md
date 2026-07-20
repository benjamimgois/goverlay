## MODIFIED Requirements

### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available by fetching a static JSON manifest file `versions.json` from a raw GitHub URL. The system SHALL compare the version string from the manifest against the installed version. The version comparison SHALL strip version channel prefixes (specifically `stable.` and `edge.`) and use numeric component ordering (e.g., `0.9.3 > 0.9.2`, `0.9.3-2 > 0.9.3-1`).

#### Scenario: Stable channel version detection
- **WHEN** the OptiScaler stable channel check reads the `versions.json` manifest
- **THEN** the system extracts the stable version string and URL without querying the GitHub tags API.

#### Scenario: Bleeding-edge channel version detection
- **WHEN** the OptiScaler bleeding-edge channel check reads the `versions.json` manifest
- **THEN** the system extracts the bleeding-edge version string and URL without querying the GitHub tags API.

#### Scenario: Update shown only when remote is higher
- **WHEN** the installed version is `0.9.3-0` and the latest remote version in the manifest is `0.9.3-0`
- **THEN** no update notification is shown.

#### Scenario: Older remote version does not trigger update
- **WHEN** the installed version is `0.9.4-0` and the latest remote version in the manifest is `0.9.3-0`
- **THEN** no update notification is shown.

#### Scenario: Stable channel update available
- **WHEN** the installed version is `0.9.3-0` and the latest remote version in the stable manifest is `stable-0.9.4`
- **THEN** the system strips the `stable.` prefix during comparison, detects that `0.9.4` is newer than `0.9.3.0`, and displays the update notification.

#### Scenario: Edge channel update available
- **WHEN** the installed version is `edge-0.9.3-0` and the latest remote version in the edge manifest is `edge-0.9.4-1`
- **THEN** the system strips the `edge.` prefix during comparison, detects that `0.9.4.1` is newer than `0.9.3.0`, and displays the update notification.
