# Design Document: DLSS-Enabler Streamline SDK Integration

## Overview
This document details the technical design for fetching, caching, displaying, and deploying the NVIDIA Streamline SDK alongside DLSS-Enabler.

## Architecture & Data Flow

```
  NVIDIA-RTX/Streamline Releases API
                 │
                 │ 1. Download streamline-sdk-v<version>.zip
                 ▼
  GOverlay Cache (dlssenabler-stable/ & dlssenabler-edge/)
                 │
                 │ 2. Extract bin/x64/*.dll (sl.common.dll, sl.dlss.dll, etc.)
                 │    Write streamlineversion=<version> into goverlay.vars
                 ▼
  GOverlay UI ("Software Status" Card)
                 │
                 │ 3. Displays Streamline SDK: <version>
                 ▼
  bgmod Launch Wrapper
                 │
                 │ 4. Copies sl.*.dll + version.dll (as OptiScaler.dll)
                 ▼
  Target Game Directory
```

## Detailed Component Design

### 1. Download & Extraction (`optiscaler_update.pas`)
In `CheckAndInstallStreamlineSDK`:
- GitHub API: `https://api.github.com/repos/NVIDIA-RTX/Streamline/releases/latest`
- Asset selection: ZIP file with name containing `streamline-sdk`.
- Version parsing: Strip `v` prefix from `tag_name` or ZIP filename (e.g. `v2.12.0` -> `2.12.0`).
- Extract `/bin/x64/*.dll` into target directory (`dlssenabler-stable` or `dlssenabler-edge`).
- Write `streamlineversion=<version>` into `goverlay.vars`.

### 2. Software Status UI (`optiscaler_tab.pas`)
- Expand `STAT_NAMES` array to `array[0..5]` in `optiscaler_tab.pas`:
  ```pascal
  STAT_NAMES: array[0..5] of string = (
    'OptiScaler', 'DLSS Enabler', 'Streamline SDK', 'FakeNVAPI', 'DLSS / FSR / XeSS', 'OptiPatcher');
  ```
- In `RefreshOsStatusDots`, update index `2` for `Streamline SDK` using `streamlineLabel1.Caption`.

### 3. Game Directory Deployment (`bgmod.lpr`)
When `UPSCALER_TYPE=1`:
```pascal
// Copy all Streamline DLLs (sl.*.dll) from SourceDir to GameDir
for i := 0 to High(StreamlineDlls) do
  SafeCopyFile(SourceDir + StreamlineDlls[i], IncludeTrailingPathDelimiter(GameDir) + StreamlineDlls[i]);
```
