# Design

## Context

See `proposal.md` for background. GOverlay downloads various gaming tools, runtimes, and overlays using `RunCurlWithProgress` and specialized scraping functions in `optiscaler_update.pas`. For `lsfg-vk`, binaries and metadata are hosted on `builds.lsfg-vk.dev`. The upstream server blocks requests bearing `User-Agent: goverlay` with HTTP 403 Forbidden.

## Goals / Non-Goals

**Goals:**
- Eliminate HTTP 403 Forbidden rejections when scraping or downloading `lsfg-vk` assets from `builds.lsfg-vk.dev`.
- Standardize the HTTP User-Agent in `RunCurlWithProgress` and `GetLsfgVkLatestRemoteVersion` to a neutral browser User-Agent string compatible with both GitHub APIs and third-party web servers.
- Ensure `CheckAndInstallLsfgVk` checks the exit code of `RunCurlWithProgress` and provides distinct diagnostics if a download fails.

**Non-Goals:**
- Altering the extraction destination (`~/.local`) or Vulkan layer JSON structure for `lsfg-vk`.
- Altering Flatpak extension handling (which correctly bypasses curl downloads).
- Changing the HTML scraping parser logic in `ParseLsfgVkBuildsHtml` (which already correctly parses stable release anchors).

## Decisions

### 1. Neutral Standard User-Agent for Network Requests
- **Choice**: Use `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36` (or `Mozilla/5.0 (X11; Linux x86_64)`) in `GetLsfgVkLatestRemoteVersion` and `RunCurlWithProgress`.
- **Rationale**:
  - `builds.lsfg-vk.dev` rejects any User-Agent containing `goverlay` (case-insensitive) with 403 Forbidden, but accepts standard browser User-Agents and default curl User-Agents with 200 OK.
  - GitHub REST API accepts browser User-Agents without issue, while other CDNs and mirrors (such as ReShade or self-hosted servers) often employ bot protection rules that block non-browser user-agent strings.
  - Centralizing this header prevents future blocks on other mirrors.
- **Alternatives Considered**:
  - *Keep `User-Agent: goverlay` and only change `GetLsfgVkLatestRemoteVersion`*: Fails because `RunCurlWithProgress` also downloads from `builds.lsfg-vk.dev/lsfg-vk-2.0.0.tar.xz`, which also triggers the 403 block.
  - *Omit User-Agent entirely in curl*: Default curl header (`curl/x.x.x`) works on `builds.lsfg-vk.dev`, but GitHub API explicitly requires a User-Agent header and may throttle or reject requests without one. A browser User-Agent satisfies both.

### 2. Explicit Exit Code Verification in `CheckAndInstallLsfgVk`
- **Choice**: Inspect the integer return value of `RunCurlWithProgress` in `CheckAndInstallLsfgVk`. If non-zero, log the curl error code and immediately return `False`.
- **Rationale**: Currently, `CheckAndInstallLsfgVk` ignores the curl return code and proceeds directly to check `if FileExists(TempTarFile)`. When curl fails with `--fail`, the file is not created, the extraction step silently does nothing, and the method reports `ERROR: lsfg-vk layer not detected after installation`. Verifying the download exit code immediately distinguishes network/HTTP failures from layer registration issues.

## Risks / Trade-offs

- **[Risk] Upstream changes URL structure on builds.lsfg-vk.dev** → Mitigation: `GetLsfgVkLatestRemoteVersion` dynamically parses the latest stable release link from the HTML table, and falls back to `URL_LSFGVK_TARBALL` only if parsing yields no result.
- **[Risk] Other servers require specific User-Agent format** → Mitigation: Modern web servers and CDNs universally accept modern standard desktop browser User-Agents.
