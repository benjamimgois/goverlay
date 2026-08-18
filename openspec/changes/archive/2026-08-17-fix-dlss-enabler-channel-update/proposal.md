## Why

When the Bleeding-edge channel is selected on the Upscalers tab, GOverlay can erroneously report that DLSS Enabler 4.9.0.6 (Bleeding-edge build) can be updated to 4.8.13.6 (older stable build). This happens because DLSS Enabler update checking uses a string inequality check (not SameText) instead of a semver-based CompareVersions check, and uses a hardcoded fallback version when remote scraping fails. Updates must be strictly channel-isolated and only offered when a strictly newer version exists within the active channel (Stable or Bleeding-edge).

## What Changes

- Use semver version comparison (`CompareVersions(NormLatest, NormCurrent) > 0`) for DLSS Enabler in `SyncUpdateUI`, replacing string inequality checks (`not SameText`).
- Isolate update checks to the selected channel (`OPT_CHANNEL`): Stable checks `*STABLE.zip` against `dlssenabler-stable/goverlay.vars`, Bleeding-edge checks `*TRUNK.zip` against `dlssenabler-edge/goverlay.vars`.
- Prevent downgrades or cross-channel notifications from being presented as updates.
- Remove hardcoded fallback versions (`4.8.13.6` / `4.8.12`) in `GetDlssEnablerLatestTag`, returning an empty string when remote version discovery fails.

## Capabilities

### Modified Capabilities
- `upscalers-dlss-enabler`: Update requirements for DLSS Enabler version discovery, channel isolation, and update checking using semver comparison (`CompareVersions > 0`).

## Impact

- `optiscaler_update.pas`: `GetDlssEnablerLatestTag` and `TOptiUpdateThread.SyncUpdateUI`.
- `optiscaler_tab.pas`: `RefreshOsStatusDots` and version label updates.
- `tests/gui/gui_test_cases.pas`: Automated GUI test coverage for DLSS Enabler channel update logic and downgrade suppression.
