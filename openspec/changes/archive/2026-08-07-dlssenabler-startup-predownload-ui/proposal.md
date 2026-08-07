# Change Proposal: DLSS Enabler Bleeding-Edge Startup Pre-download & Progress UI

## Context
On startup, GOverlay auto-installs missing assets for OptiScaler and DLSS Enabler stable (`dlssenabler-stable/`). Currently, DLSS Enabler bleeding-edge (`dlssenabler-edge/`) is not pre-downloaded at startup, requiring a delay when switching channels. Additionally, when initial asset downloads occur, the user lacks visual progress feedback.

## Proposed Changes

### 1. Pre-download DLSS Enabler Bleeding-Edge on Startup
- Update `overlayunit.pas` startup routine to check and download both `dlssenabler-stable/` and `dlssenabler-edge/` assets if missing.
- Update `optiscaler_update.pas` (`CheckAndInstallOptiScaler`) to trigger pre-download of both DLSS Enabler channels.

### 2. Display Progress Bar UI During Startup Downloads
- Display `updateProgressBar` and `updatestatusLabel` with the caption `"Downloading files..."` whenever missing assets are being downloaded during startup.
- Hide progress controls and restore button states when startup downloads complete.

## Non-Goals
- Modifying game launching (`bgmod.lpr`) execution logic.
