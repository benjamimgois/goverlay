# Proposal: Unified versions.json Manifest for DLSS Enabler Downloads

## Summary

Read DLSS Enabler Stable and Edge versions/urls directly from `versions.json` hosted on `raw.githubusercontent.com` to eliminate GitHub API rate limiting (`api.github.com` 60 requests/hour limit).

## Motivation

Unauthenticated calls to `api.github.com` cause HTTP 403 Rate Limit Exceeded errors when checking for DLSS Enabler builds. OptiScaler avoids this by using `raw.githubusercontent.com` CDN (`versions.json`). Adding `dlssenabler_stable` and `dlssenabler_edge` entries to `versions.json` unifies asset manifest fetching and guarantees rate-limit-free downloads.

## Proposed Changes

- **`optiscaler_update.pas`**:
  - Update `FetchManifest` to parse `dlssenabler_stable` and `dlssenabler_edge` version tags and download URLs from `versions.json`.
  - Update `GetDlssEnablerLatestTag` and `CheckAndInstallDlssEnabler` to use `versions.json` as the primary version resolution and download URL source.
  - Retain HTML scraping / hardcoded URLs strictly as fallback mechanisms.

## Scope

- Modifies `optiscaler_update.pas`.
- No breaking changes to user UI or configuration files.
