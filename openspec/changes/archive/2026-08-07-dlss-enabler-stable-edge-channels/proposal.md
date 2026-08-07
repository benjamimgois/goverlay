# Change Proposal: DLSS-Enabler Dual Channel (Stable & Bleeding-Edge) Integration

## Context
We are introducing a new method for acquiring and deploying DLSS-Enabler in GOverlay with support for two channels: **Stable** and **Bleeding-edge**.

Builds are retrieved from `https://github.com/benjamimgois/OptiScaler-builds/tree/nightly-action/de`.

- Archives containing the term `"STABLE"` belong to the **Stable** channel (`dlssenabler-stable`).
- Archives containing the term `"TRUNK"` belong to the **Bleeding-edge** channel (`dlssenabler-edge`).
- The ZIP archives contain `version.dll`.
- The filename contains the version string (e.g., `4.8.12` from `DLSS Enabler 4.8.12 STABLE...zip`, `4.8.13.5` from `DLSS Enabler 4.8.13.5 TRUNK.zip`), which must be parsed and stored in `goverlay.vars` and displayed in the UI.

## Proposed Changes

### 1. Download & Version Extraction (`optiscaler_update.pas`)
- Query `https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action` to list available builds.
- Filter build list by `"STABLE"` for Stable channel (`dlssenabler-stable`) and `"TRUNK"` for Bleeding-edge channel (`dlssenabler-edge`).
- Parse the version string from the matching filename (extracting the version segment between `"DLSS Enabler "` and the subsequent space).
- Download the selected ZIP archive, extract `version.dll` into the channel directory (`dlssenabler-stable/` or `dlssenabler-edge/`), and write `dlssenablerversion=<parsed_version>` into `goverlay.vars`.

### 2. Game Folder Installation (`bgmod.lpr`)
- Update `ChannelFolder` logic so that when `UPSCALER_TYPE=1` (DLSS Enabler):
  - Select `dlssenabler-stable` when `OPT_CHANNEL=0` (Stable).
  - Select `dlssenabler-edge` when `OPT_CHANNEL=1` (Bleeding-edge).
- When deploying to a game folder with `UPSCALER_TYPE=1`:
  1. Perform standard OptiScaler base installation from `optiscaler-stable` (copying `OptiScaler.ini`, `libxess.dll`, `fakenvapi.dll`, etc.).
  2. Overwrite `OptiScaler.dll` in the game folder with `version.dll` from the selected DLSS Enabler channel folder (`ChannelFolder`).
  3. Execute standard proxy DLL renaming (`OptiScaler.dll` -> `DllName`, e.g., `dxgi.dll`, `version.dll`, `winmm.dll`).

## Non-Goals
- Altering OptiScaler stable/edge channels.
- Changing proxy DLL dropdown choices in the UI.
