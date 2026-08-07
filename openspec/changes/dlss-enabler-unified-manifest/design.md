# Design: Unified versions.json Manifest for DLSS Enabler Downloads

## Context

GitHub REST API endpoints (`api.github.com/repos/.../contents/de`) enforce a 60 requests/hour limit for unauthenticated client IPs. In contrast, `raw.githubusercontent.com` is served via Fastly CDN and has no API rate limits.

OptiScaler already uses `https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/versions.json`.

## Technical Approach

### 1. Extended `versions.json` Schema
```json
{
  "stable": {
    "version": "stable-0.9.4",
    "url": "https://github.com/benjamimgois/OptiScaler-builds/releases/download/stable-0.9.4/OptiScaler_stable_0.9.4.7z"
  },
  "edge": {
    "version": "edge-2026.08.07-00ac50d2",
    "url": "https://github.com/benjamimgois/OptiScaler-builds/releases/download/edge-2026.08.07-00ac50d2/optiscaler-edge.7z"
  },
  "dlssenabler_stable": {
    "version": "4.8.12",
    "url": "https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.12%20STABLE%20757%204.8.12%202026-07-26T18-01Z%20K8HToGjQv.zip"
  },
  "dlssenabler_edge": {
    "version": "4.8.13.6",
    "url": "https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/de/DLSS%20Enabler%204.8.13.6%20RC2%20TRUNK.zip"
  }
}
```

### 2. GOverlay `FetchManifest` Update
In `optiscaler_update.pas`:
- Add `ADlssStableVer`, `ADlssStableURL`, `ADlssEdgeVer`, `ADlssEdgeURL` out parameters or helper getters to `FetchManifest`.
- Parse `dlssenabler_stable` and `dlssenabler_edge` objects from `versions.json`.

### 3. DLSS Enabler Version Resolution
In `GetDlssEnablerLatestTag` and `CheckAndInstallDlssEnabler`:
- First try obtaining version tag and download URL from `FetchManifest`.
- If present, use the URL directly without hitting `api.github.com`.
- If missing or network error, fall back to HTML scraping / hardcoded URLs.
