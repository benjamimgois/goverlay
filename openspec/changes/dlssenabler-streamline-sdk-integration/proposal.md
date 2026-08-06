# Change Proposal: DLSS-Enabler Streamline SDK Integration

## Context
On branch `de-alternate`, we are completing the DLSS-Enabler package by downloading and bundling the official NVIDIA Streamline SDK (`NVIDIA-RTX/Streamline`).

## Proposed Changes

### 1. Download & Extraction (`optiscaler_update.pas`)
- Fetch the latest release from `https://api.github.com/repos/NVIDIA-RTX/Streamline/releases/latest`.
- Download the release ZIP asset (e.g. `streamline-sdk-v2.12.0.zip`).
- Extract all `.dll` files in `/bin/x64/` (e.g., `sl.common.dll`, `sl.dlss.dll`, `sl.dlss_g.dll`, `sl.interposer.dll`, `sl.nis.dll`, `sl.reflex.dll`, etc.) directly into `dlssenabler-stable/` and `dlssenabler-edge/`.
- Save `streamlineversion=<version>` into `goverlay.vars`.

### 2. UI Software Status Card (`optiscaler_tab.pas`)
- Expand the Software Status card grid in `optiscaler_tab.pas` from 5 to 6 items by adding **Streamline SDK**.
- Update `RefreshOsStatusDots` to populate and display the installed Streamline SDK version.

### 3. Game Directory Deployment (`bgmod.lpr`)
- Update `bgmod.lpr` to copy Streamline DLLs (`sl.*.dll`) from the active DLSS Enabler cache directory into the game directory.

## Non-Goals
- Modifying OptiScaler stable/edge channels.
