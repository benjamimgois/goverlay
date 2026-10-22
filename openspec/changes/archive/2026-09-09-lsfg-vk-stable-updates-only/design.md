## Context

See `proposal.md` for motivation. In `optiscaler_update.pas`, `GetLsfgVkLatestRemoteVersion` parses the HTML from `https://builds.lsfg-vk.dev/`. It currently checks `(Pos('Latest release (', Line) > 0) or (Pos('Latest git version (', Line) > 0)`. Because the autobuild server outputs the git build row first, the parser binds to `Latest git version (...)` and aborts loop traversal, surfacing commit-level autobuilds as application updates.

## Goals / Non-Goals

**Goals:**
- Guarantee that `GetLsfgVkLatestRemoteVersion` resolves strictly to official stable releases tagged in `builds.lsfg-vk.dev`.
- Prevent git autobuilds (e.g. `2.0.0.r1.g0e7a389`) and release candidates from triggering update alerts or appearing as the latest version.
- Preserve fallback to `URL_LSFGVK_TARBALL` (`2.0.0`) if the endpoint is unreachable or cannot be parsed.
- Add test coverage ensuring HTML containing git versions and release versions extracts only the stable release.

**Non-Goals:**
- Introducing an experimental/git channel selector for `lsfg-vk` in the UI (out of scope; `lsfg-vk` 2.0 tracks official stable releases).
- Altering the extraction or installation procedure in `CheckAndInstallLsfgVk`.

## Decisions

### Decision 1: Restrict HTML Tag Search Strictly to `Latest release (`
- **Details**: Modify the line match in `GetLsfgVkLatestRemoteVersion`:
  ```pascal
  if Pos('Latest release (', Line) > 0 then
  ```
- **Rationale**: In the upstream HTML table:
  - Row 1: `&gt;&gt; Latest git version (2.0.0.r1.g0e7a389) &lt;&lt;`
  - Row 2: `&gt;&gt; Latest release candidate (2.0.0) &lt;&lt;`
  - Row 3: `&gt;&gt; Latest release (2.0.0) &lt;&lt;`
  Matching `Pos('Latest release (', Line)` skips rows 1 and 2 (note that row 2 contains `'candidate ('`, so `'release ('` is not present) and reliably selects row 3.
- **Alternatives Considered**:
  - *Fallback to git version if release not found*: Rejected because the autobuild server always generates git builds; falling back would mean that any commit would trigger an update if release parsing ever differed.
  - *Comparing versions with `CompareVersions`*: While `CompareVersions` handles semver numbers, git version tags like `2.0.0.r1.g0e7a389` compared to `2.0.0` could still yield unequal string states in UI sync checks (`SyncResult`). Restricting the remote version to stable releases prevents the discrepancy at the source.

## Risks / Trade-offs

- `[Risk] Upstream changes the label text in builds.lsfg-vk.dev` → Mitigation: If `Result` remains empty after scanning the page, the existing fallback assigns `Result := '2.0.0'` and `AUrl := URL_LSFGVK_TARBALL`.
