# Implementation Tasks: DLSS Enabler Unified Manifest

- [x] 1. Update `FetchManifest` in `optiscaler_update.pas`
  - [x] 1.1 Extend `FetchManifest` (or add overloaded/extended procedure) to parse `dlssenabler_stable` and `dlssenabler_edge` version & url fields from `versions.json`.
  - [x] 1.2 Store parsed DLSS Enabler stable/edge tags and download URLs in `TOptiscalerTab` fields.

- [x] 2. Update DLSS Enabler Tag and Download Resolution
  - [x] 2.1 Update `GetDlssEnablerLatestTag` in `optiscaler_update.pas` to return the version tag from `versions.json` as primary source.
  - [x] 2.2 Update `CheckAndInstallDlssEnabler` in `optiscaler_update.pas` to use the download URL from `versions.json` as primary source.
  - [x] 2.3 Retain HTML scraping / static fallback URLs if `versions.json` fetch fails or lacks DLSS Enabler entries.

- [x] 3. Build & Verify
  - [x] 3.1 Rebuild GOverlay with `lazbuild`.
  - [x] 3.2 Test startup download and version check to verify rate-limit-free manifest resolution.
