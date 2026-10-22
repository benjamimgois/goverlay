# Design

## Context

See `proposal.md` for motivation. Currently, `optiscaler_update.pas` downloads `https://reshade.me/downloads/ReShade_Setup_6.4.0_Addon.exe` unconditionally, and UI labels in `reshade_tab.pas` and `home_tab.pas` display hardcoded `'6.4 (Add-on Edition)'`. Other components in GOverlay (such as MAKO and LSFG-VK) resolve remote tags dynamically and store local version metadata in text/json files (e.g. `MAKO-Renderer-version.txt`).

## Goals / Non-Goals

**Goals:**
- Provide dynamic remote version discovery for ReShade releases using GitHub tags API (`crosire/reshade`) with fallback to parsing `reshade.me`.
- Dynamically build the Add-on download URL based on resolved version.
- Persist installed ReShade version to `~/.local/share/goverlay/reshade/version.txt` upon successful installation or update.
- Provide `GetReShadeInstalledVersion` and use it dynamically in `reshade_tab.pas` and `home_tab.pas`.
- Ensure Pascal console output is explicitly flushed with `Flush(Output)` before invoking external tools like `7z`, and provide clear completion logs to eliminate the appearance of hanging.

**Non-Goals:**
- Supporting non-Addon builds of ReShade (GOverlay explicitly targets the Add-on edition for Vulkan/Wine injector compatibility).
- Managing third-party presets or arbitrary shader repositories beyond existing supported shader packages.

## Decisions

### 1. Remote Version Resolution: GitHub Tags with `reshade.me` Fallback
- **Decision**: Query `https://api.github.com/repos/crosire/reshade/tags` using `curl` with a 10s timeout, parsing the top tag (`tag_name` or `name` field, e.g. `v6.8.0`). If the GitHub API fails or is rate-limited, fall back to fetching `https://reshade.me` and parsing `/downloads/ReShade_Setup_([0-9]+\.[0-9]+\.[0-9]+)_Addon\.exe`. If both network requests fail, fall back to a known baseline (`6.8.0`).
- **Rationale**: ReShade does not publish binary assets directly on GitHub Releases, but creates git tags for all releases. Official binaries are hosted on `reshade.me/downloads/ReShade_Setup_<version>_Addon.exe`. This two-tier query guarantees reliable version detection even during GitHub API rate limits.
- **Alternatives Considered**:
  - Only scraping `reshade.me`: Fragile if webpage layout or Cloudflare challenge triggers.
  - Hardcoding a newer version like 6.8.0: Reintroduces the same bug whenever 6.8.1 or 6.9.0 is released.

### 2. Local Version Tracking via `version.txt`
- **Decision**: Save the installed version string in `IncludeTrailingPathDelimiter(GetReShadeBasePath) + 'version.txt'` upon successful extraction and DLL copy.
- **Rationale**: ReShade's generated `ReShade64.json` does not expose the application version (only `"implementation_version": "1"`). Reading a dedicated `version.txt` is instantaneous, cross-platform, and consistent with GOverlay's established patterns (`MAKO-Renderer-version.txt`).
- **Fallback for Existing Installs**: If `version.txt` is missing but `ReShade64.dll` exists, inspect `ReShade64.dll` or default gracefully to `'6.4.0'` until the next update.

### 3. Dynamic UI Status Updates
- **Decision**: Replace all literal string assignments of `'6.4 (Add-on Edition)'` in `reshade_tab.pas` (`RefreshStatus`) and `home_tab.pas` (`RefreshHomeOptiStatus`) with formatted strings using `GetReShadeInstalledVersion`:
  ```pascal
  Ver := GetReShadeInstalledVersion;
  if Ver <> '' then
    Caption := Ver + ' (Add-on Edition)'
  else
    Caption := '—';
  ```

### 4. Output Flushing and Synchronous Console Feedback
- **Decision**: Insert `Flush(Output)` before calling `ExtractArchive7z` and write an explicit success message upon completion:
  ```pascal
  WriteLn('[AUTO-INSTALL] ReShade runtime (Add-on) installed successfully (version: ', RemoteVer, ')');
  Flush(Output);
  ```
- **Rationale**: Prevents Pascal runtime stdout buffer interleaving with `7z` child process output and gives users immediate verification that the operation succeeded.

## Risks / Trade-offs

- **[Risk] GitHub API Rate Limit (60 req/hr unauthenticated)** → **Mitigation**: Fallback parser for `reshade.me` plus hardcoded safe baseline version ensures installation never fails even if rate-limited.
- **[Risk] Upstream URL format changes** → **Mitigation**: Validates downloaded file existence and archive integrity before deleting previous binaries.
