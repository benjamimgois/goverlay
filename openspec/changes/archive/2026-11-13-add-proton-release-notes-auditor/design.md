# Design

## Context

`goverlay-update-auditor` currently audits upstream tools by fetching `releases/latest` and parsing a single `upstream_sample_config` file (`key = value`) against Pascal string literals in `goverlay_files`. See `proposal.md` for motivation.

In `tweaks_md3.pas` and `configkeys.pas`, Proton/Wine environment variables are stored as `'VAR_NAME=1'` in `TWEAK_ROWS` and checked via `SameText(AKey, 'VAR_NAME')`. Meanwhile, `CachyOS/proton-cachyos` and `GloriousEggroll/proton-ge-custom` publish new environment variables inside GitHub release notes (Markdown), often across multiple recent releases (e.g., a major release followed by a hotfix release).

## Goals / Non-Goals

**Goals:**
- Support a release-notes environment variable audit mode in `audit_upstream.py` without breaking existing sample-config auditing for MangoHud, OptiScaler, etc.
- Fetch the last `N` releases (`releases?per_page=N`, default `5`, CLI flag `--releases`) for release-notes tools.
- Extract uppercase environment variables (`[A-Z][A-Z0-9]*_[A-Z0-9_]+(?:=[^\s`",;)]+)?`) from release note Markdown bodies, deduplicating by base variable name while preserving the most recent release tag and bullet/line context.
- Normalize `VAR=value` to `VAR` when matching against `extract_goverlay_keys(goverlay_files)`.
- Group missing environment variables into prefix blocks (`PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, `Other`) in Markdown output.

**Non-Goals:**
- Modifying Goverlay Pascal files (`tweaks_md3.pas`, `configkeys.pas`, `hintsunit.pas`) automatically — selection remains manual after reviewing the report.
- Scraping external linked documentation pages (e.g. `EM-ADDITIONS.md`, `FSR4.md`) beyond the GitHub Releases API in this change.

## Decisions

1. **Tool configuration via `"audit_mode": "release_notes_env"` in `repositories.json`**
   - *Rationale*: Keeps the existing `tools` array schema backward-compatible. Tools without `audit_mode` continue using `upstream_sample_config` + `releases/latest`.
   - *Alternative*: Hardcoding tool IDs (`proton-cachyos`, `proton-ge-custom`) in Python — rejected because data-driven metadata in `repositories.json` makes adding future Proton/Wine forks trivial.

2. **Multi-release fetching (`repos/{repo}/releases?per_page={N}`)**
   - *Rationale*: Hotfix releases (such as `cachyos-11.0-20261015-slr`) contain minimal notes and would hide environment variables introduced in the preceding release (`cachyos-11.0-20261014-slr`). Defaulting `N=5` balances API payload size and coverage, while `--releases` lets users widen or narrow the window.
   - *Alternative*: Fetching only `releases/latest` — rejected after observing that `proton-cachyos` latest is frequently a hotfix.

3. **Regex extraction + false-positive filtering for env vars**
   - *Rationale*: Release notes mix env vars (`PROTON_ZLUDA=1`, `PROTON_SONY_WINDOWS_DEVICE_NAMES=1`) with unrelated uppercase tokens (URLs, commit hashes, Windows APIs, or `DX11`/`D3D12`). Requiring at least one underscore (`[A-Z][A-Z0-9]*_[A-Z0-9_]+`) and stripping `=value` for deduplication/comparison captures env vars across `PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and others while avoiding common non-env tokens.
   - *Alternative*: Restricting only to `PROTON_*` — rejected because the user requested checking all variables and separating them into blocks for selection.

4. **Prefix-based block grouping in Markdown**
   - *Rationale*: Grouping into `PROTON_*`, `WINE_*`, `DXVK_*`, `VKD3D_*`, and `Other` lets the user scan Proton-specific tweaks first and decide separately whether lower-level `DXVK_*`/`WINE_*`/`VKD3D_*` variables belong in Goverlay's Tweaks tab.

## Risks / Trade-offs

- **Noise from non-tweak uppercase identifiers in release notes** (e.g. `VK_KHR_*`, `GL_*`, `WIN32_*` constants) → **Mitigation**: Filter out known non-env prefixes (`VK_`, `GL_`, `D3D`, `WIN32_`, `ERR_`, `FIXME_`) and deduplicate per base variable name, keeping the context line so irrelevant constants are immediately obvious.
- **GitHub API rate limits on unauthenticated `curl` fallback** → **Mitigation**: `fetch_github_api` already prefers authenticated `gh api`, and fetching `?per_page=5` is still a single API call per Proton tool.
