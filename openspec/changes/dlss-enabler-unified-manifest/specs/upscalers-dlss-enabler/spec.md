# Capability Spec: DLSS-Enabler Manifest Resolution

## MODIFIED Requirements

### Requirement: DLSS-Enabler Dual Channel Support (Stable & Bleeding-edge)
- GOverlay SHALL query `https://raw.githubusercontent.com/benjamimgois/OptiScaler-builds/nightly-action/versions.json` as the primary manifest for DLSS Enabler Stable and Edge versions and URLs.
- WHEN `dlssenabler_stable` or `dlssenabler_edge` entries are present in `versions.json`, GOverlay SHALL resolve download URLs and version tags directly from `versions.json` without calling `api.github.com`.
- WHEN Stable channel is selected for DLSS Enabler (`OPT_CHANNEL=0`), GOverlay SHALL download the URL specified in `dlssenabler_stable.url` into `~/.local/share/goverlay/dlssenabler-stable/`.
- WHEN Bleeding-edge channel is selected for DLSS Enabler (`OPT_CHANNEL=1`), GOverlay SHALL download the URL specified in `dlssenabler_edge.url` into `~/.local/share/goverlay/dlssenabler-edge/`.
- GOverlay SHALL extract `version.dll` from the downloaded ZIP archive into the respective channel cache directory.
- GOverlay SHALL write `dlssenablerversion=<parsed_version>` and `upscalertype=1` to `goverlay.vars` inside the channel directory.
- IF `versions.json` is unreachable or does not contain DLSS Enabler entries, GOverlay SHALL fall back to HTML directory listing scraping and valid static fallback URLs.

#### Scenario: Rate-Limit-Free DLSS-Enabler Manifest Fetching
- **WHEN** DLSS Enabler pre-downloads or version checks execute
- **THEN** GOverlay fetches `versions.json` via CDN without hitting `api.github.com` rate limits
