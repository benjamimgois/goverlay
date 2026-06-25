## MODIFIED Requirements

### Requirement: Auto-update game configuration folder
The `bgmod` execution SHALL check if there is a newer version of OptiScaler available centrally/globally by comparing the `goverlay.vars` files in the global and local configuration directories. The version comparison SHALL use numeric component ordering (e.g., `0.9.3 > 0.9.2`, `0.9.3-2 > 0.9.3-1`). The system SHALL collect all matching tags from the GitHub API and return the numerically highest tag for the selected channel.

#### Scenario: Stable channel finds highest version
- **WHEN** the OptiScaler stable channel check fetches tags `0.9.2-0`, `0.9.3-0`, `0.9.1-0`
- **THEN** the system returns `0.9.3-0` as the latest version, regardless of API order.

#### Scenario: Bleeding-edge channel finds highest version
- **WHEN** the OptiScaler bleeding-edge check fetches tags `edge-0.9.4-1`, `edge-0.9.4-2`, `edge-0.9.3-5`
- **THEN** the system strips the `edge-` prefix, compares numerically, and returns `edge-0.9.4-2`.

#### Scenario: Update shown only when remote is higher
- **WHEN** the installed version is `0.9.3-0` and the latest remote version is `0.9.3-0`
- **THEN** no update notification is shown.

#### Scenario: Older remote version does not trigger update
- **WHEN** the installed version is `0.9.4-0` and the latest remote version is `0.9.3-0`
- **THEN** no update notification is shown.
