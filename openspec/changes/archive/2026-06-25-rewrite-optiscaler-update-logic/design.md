## Context

Currently `GetOptiScalerStableTag` and `GetOptiScalerPreReleaseTag` each iterate the GitHub `/tags` API response, return the first regex match (API returns newest-first), and store it. `SyncUpdateUI` compares with `FLatestOptiTag <> CurrentVersion` (simple string !=). This breaks when: (a) API order doesn't match numerical version order, (b) version labels come from different channels.

## Goals / Non-Goals

**Goals:**
- Find the **numerically highest** tag for the selected channel
- Compare versions using numeric component comparison, not string equality
- Only show "update available" when remote version > installed version
- Channel isolation: stable tags never compared against bleeding-edge installed versions

**Non-Goals:**
- Changing the API endpoint or authentication
- Adding a new update UI
- Changing how `goverlay.vars` stores the version tag

## Decisions

### 1. Collect all matching tags, sort numerically, pick max

- **Choice**: Replace "first match wins" with a loop that collects ALL matching tags into a `TStringList`, sorts with a custom sort function that calls `CompareVersions`, and returns `TStringList[0]` (highest).
- **Rationale**: GitHub API order is chronological (push time), not numerical (version). Two-pass approach relies on API ordering for priority within each pass. A single-pass collection + numeric sort is deterministic and correct.
- **Alternative considered**: Over-engineering with semver library. Rejected — `CompareVersions` already exists and handles `X.Y.Z-P` format. Simple enough.

### 2. Stable tag matching: single regex `^\d+\.\d+\.\d+(-\d+)?$`

- **Choice**: Replace two-pass (patched first, then plain) with a single regex that matches both `0.9.3` and `0.9.3-0`. `CompareVersions(0.9.3, 0.9.3-0)` correctly returns 0 (equal).
- **Rationale**: `CompareVersions` treats `0.9.3` and `0.9.3.0` as equal. The `-P` suffix maps to the 4th component. No need for priority passes — just sort all matches.

### 3. Edge tag matching: `^edge-` prefix, strip for comparison

- **Choice**: Match `^edge-`, strip the prefix to extract the numeric part, collect with the full tag name as a key-value pair, sort by the numeric part using `CompareVersions`.
- **Rationale**: The `edge-` prefix is metadata. The actual version is after the prefix. Sorting `edge-0.9.4-2` vs `edge-0.9.4-1` means comparing `0.9.4.2` vs `0.9.4.1`.

### 4. Numeric comparison in SyncUpdateUI

- **Choice**: Replace `FLatestOptiTag <> CurrentVersion` with `CompareVersions(StripPrefix(FLatestOptiTag), StripPrefix(CurrentVersion)) > 0`.
- **Rationale**: Only show update when remote is numerically HIGHER. If remote equals current (or is older), no update notification.

## Risks / Trade-offs

- **[Risk]** Old tags without `-P` suffix (e.g., `0.7.9`) vs new ones (`0.7.9-2`). `CompareVersions(0.7.9, 0.7.9.2)` correctly says `0.7.9.2` is higher.
  - **Mitigation**: Already handled by `CompareVersions` — missing parts = 0.
- **[Risk]** API returns >100 tags → sorting large list. GitHub `/tags` endpoint returns 30 per page without pagination.
  - **Mitigation**: 30 tags is negligible. Sorting takes <1ms.
