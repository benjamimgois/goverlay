## Context

On the Upscalers tab, DLSS Enabler supports two release channels:
- **Stable**: downloads and extracts `*STABLE.zip` to `~/.local/share/goverlay/dlssenabler-stable/`.
- **Bleeding-edge**: downloads and extracts `*TRUNK.zip` to `~/.local/share/goverlay/dlssenabler-edge/`.

When checking for updates in `TOptiUpdateThread.SyncUpdateUI`, DLSS Enabler previously used string inequality (`not SameText(CurrentVersion, FLatestOptiTag)`) to detect updates. Furthermore, `GetDlssEnablerLatestTag` had hardcoded fallbacks (`4.8.13.6` on edge channel) when scraping failed. As a result, when installed version was `4.9.0.6` on Bleeding-edge and scraping returned an older build or fallback `4.8.13.6`, GOverlay flagged it as an update, displaying `4.9.0.6 → 4.8.13.6`.

## Goals / Non-Goals

**Goals:**
- Enforce strict channel isolation: update checks only compare the installed version against remote versions within the same channel.
- Implement semver-aware comparison via `CompareVersions(NormLatest, NormCurrent) > 0` for DLSS Enabler, preventing downgrades or identical version notifications.
- Remove hardcoded fallback versions in `GetDlssEnablerLatestTag` so failure to reach remote releases yields no update.

**Non-Goals:**
- Modifying OptiScaler update comparison logic (already using `CompareVersions`).
- Changing the storage locations (`dlssenabler-stable` and `dlssenabler-edge`).

## Decisions

### Decision 1: Use `CompareVersions` in `TOptiUpdateThread.SyncUpdateUI` for DLSS Enabler
In `optiscaler_update.pas` `SyncUpdateUI`:
- Normalize `FLatestOptiTag` and `CurrentVersion` by removing prefixes/suffixes and replacing delimiters with dots if needed.
- If `CurrentVersion` is empty/placeholder (`''`, `'—'`, `'--'`) and `FLatestOptiTag <> ''`, mark `HasUpdate := True` (first-time install).
- Otherwise, evaluate `HasUpdate := (FLatestOptiTag <> '') and (CompareVersions(NormLatest, NormCurrent) > 0)`.
- If `HasUpdate` is false, hide `FOptiLabel2` and do not display update arrows.

*Alternative considered*: Maintaining string inequality and special-casing known versions. *Rejected*: Fragile and does not scale across version bumps.

### Decision 2: Remove hardcoded fallback version strings in `GetDlssEnablerLatestTag`
In `optiscaler_update.pas` `GetDlssEnablerLatestTag`:
- Remove `if Result = '' then begin if AIsStable then Result := '4.8.12' else Result := '4.8.13.6'; end;`.
- If manifest and HTML scraping fail, `Result` stays `''`. `SyncUpdateUI` will safely see empty latest tag and perform no update action.

## Risks / Trade-offs

- **[Risk]** If GitHub changes HTML structure and versions.json is not populated, tag discovery returns empty.
  - **Mitigation**: GOverlay silently skips update notifications and keeps displaying the currently installed version without false alarms.
