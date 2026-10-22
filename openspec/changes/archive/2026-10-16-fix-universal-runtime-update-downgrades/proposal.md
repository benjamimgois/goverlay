# Proposal

## Why

Runtime update checks and startup provisioning in GOverlay currently suffer from two critical architectural flaws across multiple modules (MAKO, AFMF, lsfg-vk, and HelixSR):
1. When GitHub REST API rate limits (60 req/hr unauthenticated limit) or network hiccups occur, version resolution silently falls back to legacy hardcoded versions (e.g., `v3.0.0` for MAKO, `1.3.1` for AFMF, `2.0.0` for lsfg-vk, `v1.8.1` for HelixSR) instead of reporting check failure (`''`).
2. Update availability is checked via simple string inequality (`CleanRemote <> CleanLocal`) rather than semantic version comparison (`CompareVersions(CleanRemote, CleanLocal) > 0`).

As a result, users running newer versions (e.g. MAKO `4.0.0`) are presented with downgrade prompts (e.g. `4.0.0 → 3.0.0` with active "Install update" buttons), and clicking update actively downgrades their installation to legacy binaries, completely missing newly available releases (e.g., MAKO `4.5.0`).

## What Changes

- **Strict Semver Comparison for Update Banners**:
  - Update checking across Lossless Scaling modules (MAKO, lsfg-vk, and AFMF) in `lossless_scaling_tab.pas` and `home_tab.pas` will strictly require `CompareVersions(CleanRemote, CleanLocal) > 0` before declaring an update available, displaying update arrows, or enabling "Install update" actions. If `CleanRemote <= CleanLocal`, GOverlay will state that the software is up to date and suppress downgrade actions.
- **Elimination of Silent Hardcoded Downgrade Fallbacks**:
  - Remove hardcoded legacy fallbacks from `GetMakoLatestRemoteVersion`, `GetAfmfLatestRemoteVersion`, `GetLsfgVkLatestRemoteVersion`, and `FetchHelixSRLatestRelease`. If remote discovery fails, return `''` so UI displays offline / rate-limited feedback rather than false older versions.
- **Rate-Limit Resilient Discovery via GitHub Atom Feeds**:
  - For GitHub-hosted runtimes (MAKO, AFMF, HelixSR, vkSumi), implement secondary fallback parsing using the public `releases.atom` feed (`https://github.com/<owner>/<repo>/releases.atom`). Because Atom feeds are not subject to GitHub REST API 60 req/hr rate limits, GOverlay will reliably discover the true latest releases (e.g. MAKO `render-v4.5.0`, HelixSR `v1.9.0`) even during heavy API exhaustion.
- **Safe Fallback for Initial Installation Only**:
  - In headless auto-installers (`CheckAndInstallMako`, `CheckAndInstallAfmf`, etc.), only use known baseline download URLs when the module is not installed at all and network discovery fails, never when the module is already installed.

## Capabilities

### Modified Capabilities

- `mako-engine-management`: Update version discovery to prevent downgrades, enforce `CompareVersions > 0`, eliminate `v3.0.0` fallback, and add unthrottled `releases.atom` fallback.
- `lossless-scaling-config`: Ensure all status cards and update threads (MAKO, AFMF, lsfg-vk) strictly enforce `CompareVersions > 0` and display appropriate rate-limit messages.
- `lsfg-vk-auto-install`: Replace inequality comparison with semver `CompareVersions > 0` and remove hardcoded `2.0.0` downgrade fallback.
- `afmf-frame-interpolation`: Enforce `CompareVersions > 0` for AFMF update notifications and add unthrottled Atom fallback.
- `helixsr-runtime-management`: Add unthrottled Atom fallback to `FetchHelixSRLatestRelease` to ensure initial installation fetches `v1.9.0`+ even if the GitHub API is rate-limited.

## Impact

- `optiscaler_update.pas`: `GetMakoLatestRemoteVersion`, `GetAfmfLatestRemoteVersion`, `GetLsfgVkLatestRemoteVersion`, `FetchHelixSRLatestRelease`, `CheckAndInstallMako`, `CheckAndInstallAfmf`, and Atom feed helper.
- `lossless_scaling_tab.pas`: `TMakoCheckUpdateThread.SyncResult`, `TAfmfCheckUpdateThread.SyncResult`, `TLsfgVkCheckUpdateThread.SyncResult`, `CheckUpdatesClick`, and `UpdateStatusCard`.
- `home_tab.pas`: `RefreshHomeMakoStatus` and module status labels.
- `tests/gui/gui_test_cases.pas` & `tests/logic/logic_test_cases.pas`: Automated tests verifying that no downgrade banners appear when remote <= local, and Atom feed parsing resolves latest versions.
