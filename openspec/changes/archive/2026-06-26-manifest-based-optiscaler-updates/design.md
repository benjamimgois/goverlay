## Context

Current update logic requests tag array from `/tags` GH API via curl → parse array → sort version strings. Rates limit risk + fragile parse logic.

## Goals / Non-Goals

**Goals:**
- Replace GH `/tags` check with raw manifest JSON request.
- Remove version sorting algorithms from GOverlay.
- Simplify update check in GOverlay.

**Non-Goals:**
- Do not host/write automated GitHub Actions release workflow within GOverlay repository.

## Decisions

### Use static versions.json manifest
- **Choice:** Raw content URL (raw.githubusercontent.com) over GitHub API.
- **Why:** Bypasses GitHub API rate limits.
- **Alt:** Fetch latest release API. Still rate-limited, no edge pre-release sorting.

## Risks / Trade-offs

- [Risk] Manifest desync with actual release asset → [Mitigation] Automate `versions.json` updates in release GHA in the `OptiScaler-builds` repo.
