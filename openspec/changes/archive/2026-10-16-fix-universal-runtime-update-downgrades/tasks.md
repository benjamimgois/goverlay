# Tasks

## 1. Version Discovery and Atom Feed Fallback in optiscaler_update

- [x] 1.1 Implement `FetchLatestReleaseTagFromAtom` in `optiscaler_update.pas` to extract the latest release tag from GitHub Atom feeds (`releases.atom`) without REST API rate limits, and verify with unit tests.
- [x] 1.2 Remove hardcoded legacy fallbacks (`v3.0.0`, `1.3.1`, `2.0.0`, `v1.8.1`) from `GetMakoLatestRemoteVersion`, `GetAfmfLatestRemoteVersion`, `GetLsfgVkLatestRemoteVersion`, and `FetchHelixSRLatestRelease`, returning empty string on failure.
- [x] 1.3 Guard `CheckAndInstallMako` and `CheckAndInstallAfmf` so baseline fallback archives are only downloaded if the module is not already installed on the system.

## 2. Strict Semver Comparison in Lossless Scaling and Home Tabs

- [x] 2.1 Update `TMakoCheckUpdateThread.SyncResult`, `TAfmfCheckUpdateThread.SyncResult`, `TLsfgVkCheckUpdateThread.SyncResult`, and `CheckUpdatesClick` in `lossless_scaling_tab.pas` to enforce `CompareVersions(CleanRemote, CleanLocal) > 0` before showing update arrows or buttons.
- [x] 2.2 Update `home_tab.pas` (`RefreshHomeMakoStatus`) to verify that MAKO update styling and versions are only applied when remote version is semantically newer than installed.

## 3. Automated Verification and Tests

- [x] 3.1 Add automated test cases in `tests/logic/logic_test_cases.pas` verifying Atom feed parsing and version comparison edge cases (e.g., local 4.0.0 vs remote 3.0.0, 4.0.0, and 4.5.0).
- [x] 3.2 Add test cases in `tests/gui/gui_test_cases.pas` confirming that update banners and buttons are suppressed when remote <= local across all runtime cards.
- [x] 3.3 Execute `make test` to verify complete test suite pass with 0 errors and 0 failures.
