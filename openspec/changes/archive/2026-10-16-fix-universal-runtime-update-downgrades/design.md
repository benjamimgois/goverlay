# Design

## Context

Runtime update checks and startup provisioning in GOverlay handle four frame generation and upscaling runtimes:
- **MAKO Renderer** (`optiscaler_update.pas`, `lossless_scaling_tab.pas`, `home_tab.pas`)
- **AFMF Linux** (`optiscaler_update.pas`, `lossless_scaling_tab.pas`)
- **lsfg-vk** (`optiscaler_update.pas`, `lossless_scaling_tab.pas`)
- **HelixSR** (`optiscaler_update.pas`, `optiscaler_tab.pas`)

As established in `proposal.md`, GitHub REST API rate limits (60 unauthenticated requests/hr per IP) regularly cause JSON API requests to fail. Currently, the fallback handlers return hardcoded legacy version strings (e.g. `v3.0.0` for MAKO, `1.3.1` for AFMF, `2.0.0` for lsfg-vk, `v1.8.1` for HelixSR). Coupled with update banner conditions based on inequality (`CleanRemote <> CleanLocal`), GOverlay mistakenly treats older versions as updates and prompts users to downgrade.

## Goals / Non-Goals

**Goals:**
- Guarantee that update banners and "Install update" buttons only activate when `CompareVersions(CleanRemote, CleanLocal) > 0`.
- Eliminate hardcoded legacy version fallbacks across all runtime discovery functions, returning `''` when discovery fails.
- Provide a rate-limit-resilient fallback using GitHub Atom feeds (`releases.atom`) across GitHub-hosted runtimes.
- Ensure headless startup auto-installers only use baseline archives if the component is entirely missing, never overwriting existing installs on network failures.
- Maintain full test suite coverage (`make test` passing 100%).

**Non-Goals:**
- Introducing heavy XML/Atom parsing dependencies.
- Modifying game profile configuration serialization (`conf.toml` or `bgmod.conf`).
- Changing upscaler core rendering logic.

## Decisions

### Decision 1: Strict Semantic Version Comparison Helper (`IsRemoteVersionNewer`)
- **Choice**: Introduce a centralized or standardized check `IsRemoteVersionNewer(RemoteVer, LocalVer: string): Boolean` using `CompareVersions(CleanVersionString(RemoteVer), CleanVersionString(LocalVer)) > 0`.
- **Rationale**: Currently, `lossless_scaling_tab.pas` uses `if (CleanRemote <> '') and (CleanRemote <> CleanLocal) then`. If `RemoteVer` is older than `LocalVer`, this evaluates to true. Checking `CompareVersions > 0` mathematically guarantees that only newer versions trigger update indicators.
- **Alternatives Considered**: Checking `CleanRemote > CleanLocal` with string comparison, which fails for multi-digit semver (`4.10.0 < 4.9.0`). `CompareVersions` already parses numeric semver components (`Major.Minor.Patch`).

### Decision 2: Zero-Dependency GitHub Atom Feed Parser
- **Choice**: Implement `FetchLatestReleaseTagFromAtom(Owner, Repo: string): string` in `optiscaler_update.pas`.
- **Rationale**: GitHub Atom feeds (`https://github.com/<owner>/<repo>/releases.atom`) are served through GitHub's web CDN and do not count against the 60 req/hr REST API rate limit. The latest release tag can be extracted by searching for `<link rel="alternate" type="text/html" href="https://github.com/<owner>/<repo>/releases/tag/([^"]+)"/>` or `<id>tag:github.com,2008:Repository/\d+/([^<]+)</id>`.
- **Alternatives Considered**: Using an authenticated GitHub token (requires user configuration) or web scraping release HTML (Atom is much more lightweight and structured).

### Decision 3: Remove Downgrade Fallbacks from Query Functions
- **Choice**: In `GetMakoLatestRemoteVersion`, `GetAfmfLatestRemoteVersion`, `GetLsfgVkLatestRemoteVersion`, and `FetchHelixSRLatestRelease`, if both GitHub REST API and Atom feed fail to resolve a release, set `Result := ''`.
- **Rationale**: An empty string communicates to the UI that remote version discovery is temporarily unavailable. The UI retains the installed version label without displaying downgrade banners.
- **Alternatives Considered**: Retaining fallbacks with a flag; discarded because fallbacks inevitably become obsolete as newer upstream versions release.

### Decision 4: Safe Initial Install vs Update Isolation
- **Choice**: In `CheckAndInstallMako` and `CheckAndInstallAfmf`, inspect whether the component is already installed (`IsMakoInstalled`, `IsAfmfInstalled`) before attempting downloads. If already installed and remote version resolution fails, abort silently without reinstalling an older archive.
- **Rationale**: Prevents startup verification from downgrading existing installations when offline or rate-limited.

## Risks / Trade-offs

- **[Risk]** GitHub Atom feed structure changes or is unavailable.
  - **Mitigation**: The Atom feed is used as a secondary fallback when REST API fails. If both fail, GOverlay gracefully returns `''` and skips the update notification.
- **[Risk]** Tag formats differ between projects (e.g. `render-v4.5.0` in MAKO, `v1.9.0` in HelixSR, `1.4.0` in AFMF).
  - **Mitigation**: `CleanVersionString` strips repository-specific prefixes (`render-`, `v`, `release-`), leaving clean semver strings for comparison.
