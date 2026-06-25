## Why

OptiScaler update check uses simple string inequality (`tag <> CurrentVersion`) and returns the first regex-matching tag from GitHub API (relying on chronological order). This causes two bugs:
1. **Wrong channel comparison**: A bleeding-edge install is compared against the stable tag, showing "update available" even when on the latest bleeding-edge.
2. **No numeric ordering**: Tags are matched by API order, not version. If `0.9.3-0` was pushed before `0.9.2-0`, the older `0.9.2-0` is returned as "latest". Same for edge tags — `edge-0.9.4-2` must compare numerically against `edge-0.9.4-1`.

## What Changes

- **Rewrite tag discovery**: Scan ALL matching tags from the API, sort them numerically using `CompareVersions`, return the highest.
- **Stable channel**: Match regex `^\d+\.\d+\.\d+(-\d+)?$`, compare by `X.Y.Z-P` components.
- **Bleeding-edge channel**: Match regex `^edge-`, strip `edge-` prefix, compare remaining numeric version.
- **Fixed comparison**: In `SyncUpdateUI`, use `CompareVersions` to check if `FLatestTag > CurrentVersion` (only show update when the remote version is actually higher).
- **Channel-aware filtering**: Never compare a stable tag against a bleeding-edge installed version or vice-versa.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `bgmod-update-optiscaler`: Modify the update check logic to properly sort tags numerically and compare within the same channel.

## Impact

- `optiscaler_update.pas`: Rewrite `GetOptiScalerStableTag`, `GetOptiScalerPreReleaseTag`, update `SyncUpdateUI` version comparison
- `constants.pas`: Add stable/edge tag regex constants
