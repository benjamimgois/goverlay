# Proposal: Notify and Allow User Update for DLSS Enabler Rolling Releases

## Problem Statement
The DLSS Enabler stack (packaged via `bygalacos/OptiScalerBuilder`) receives frequent rolling release updates. While the sub-component version (e.g. `4.8.10.11`) may sometimes remain static, integrated wrapper DLLs, hooks, and OptiScaler binaries within the builder package are frequently updated across new release tags. Currently, GOverlay lacks a clear notification and user-triggered update flow for DLSS Enabler rolling releases when newer release tags exist upstream.

## Proposed Changes
1. **Full Tag-Based Version Tracking (`optiscaler_update.pas`)**:
   - Store and compare the exact full release `tag_name` (e.g. `OptiScaler_v0.10.0-pre1_7233fc0c_...`) in `dlssenabler-stable/goverlay.vars`.
   - Perform full string tag comparison against GitHub API `bygalacos/OptiScalerBuilder/releases/latest`.

2. **Update Check & Proactive Notification**:
   - On background update check (or when switching to OptiScaler tab with DLSS Enabler active), compare local vs remote tag.
   - If a new release tag is detected upstream:
     - Show a Toast / status message: `"DLSS Enabler update available!"`.
     - Set the status dot in Software Status to yellow/orange.
     - Display and highlight the `[Update]` button for DLSS Enabler.

3. **User-Triggered Installation**:
   - When the user clicks `[Update]`, download and extract the latest `.7z` package into `dlssenabler-stable/`.
   - Update `dlssenablerversion` key in `goverlay.vars` to the new full release tag.
   - Instantly update the UI label and set the status dot to green.

## Impact
- Users are notified pro-actively whenever a new DLSS Enabler rolling release tag is published on GitHub, with full user control over when to download and install the update.
