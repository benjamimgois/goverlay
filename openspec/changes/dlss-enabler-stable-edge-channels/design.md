# Design Document: DLSS-Enabler Dual Channel (Stable & Bleeding-Edge)

## Overview
This document details the technical design for downloading DLSS-Enabler builds across two channels (Stable and Bleeding-edge) and deploying them using OptiScaler as a base wrapper.

## Architecture & Data Flow

```
 GitHub Repository: benjamimgois/OptiScaler-builds (branch: nightly-action, path: de/)
 ├── "DLSS Enabler <version> STABLE ...zip"  ──▶ dlssenabler-stable/version.dll
 └── "DLSS Enabler <version> TRUNK.zip"       ──▶ dlssenabler-edge/version.dll
                                │
                                ▼
                       GOverlay GUI Updates
  - Parses version string (e.g. "4.8.12" or "4.8.13.5") from filename
  - Writes goverlay.vars in cache directory
  - Updates UI labels
                                │
                                ▼
                   bgmod Game Directory Deployment
  1. Base OptiScaler install from optiscaler-stable (OptiScaler.ini, libxess, etc.)
  2. Copy version.dll from active DLSS Enabler channel ──▶ GameDir/OptiScaler.dll
  3. Copy/rename GameDir/OptiScaler.dll               ──▶ GameDir/<DllName>
```

## Detailed Component Design

### 1. Download & Version Extraction (`optiscaler_update.pas`)
In `GetDlssEnablerLatestTag` and `CheckAndInstallDlssEnabler`:
- API URL: `https://api.github.com/repos/benjamimgois/OptiScaler-builds/contents/de?ref=nightly-action`
- Filter criteria:
  - Stable Channel: Search item in JSON array where `name` contains `"STABLE"`.
  - Bleeding-edge Channel: Search item in JSON array where `name` contains `"TRUNK"`.
- Version parsing:
  ```pascal
  StartPos := Pos('DLSS Enabler ', ItemName);
  if StartPos > 0 then
  begin
    VerStart := StartPos + Length('DLSS Enabler ');
    SpacePos := PosEx(' ', ItemName, VerStart);
    if SpacePos > VerStart then
      ExtractedVersion := Copy(ItemName, VerStart, SpacePos - VerStart);
  end;
  ```
- Download & extraction:
  - Download target file using `download_url` via `curl`.
  - Extract `.zip` into `GetDlssEnablerPath` (`dlssenabler-stable` or `dlssenabler-edge`).
  - Verify `version.dll` exists after extraction.
  - Write `dlssenablerversion=<ExtractedVersion>` and `upscalertype=1` to `goverlay.vars`.

### 2. Channel Resolution (`bgmod.lpr`)
In `bgmod.lpr`:
```pascal
if UpscalerType = 1 then
begin
  if IsStable then
    ChannelFolder := 'dlssenabler-stable'
  else
    ChannelFolder := 'dlssenabler-edge';
end;
```

### 3. Game Installation Pipeline (`bgmod.lpr`)
When `UpscalerType = 1`:
```pascal
// 1. Install base OptiScaler files from optiscaler-stable
OptiBaseDir := GetOptiScalerStablePath();
SafeCopyFile(OptiBaseDir + 'OptiScaler.ini', GameDir + 'OptiScaler.ini');
// ... (copy libxess.dll, fakenvapi.dll, etc.)

// 2. Overwrite OptiScaler.dll with DLSS Enabler's version.dll
if FileExists(SourceDir + 'version.dll') then
begin
  Log('Overwriting OptiScaler.dll with DLSS Enabler version.dll');
  SafeCopyFile(SourceDir + 'version.dll', IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll');
end;

// 3. Renaming to Proxy DllName
SafeCopyFile(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler.dll', IncludeTrailingPathDelimiter(GameDir) + DllName);
```

## Benefits
- Fully backwards compatible with OptiScaler's proxy DLL mechanism.
- Clean separation between Stable (`4.8.12`) and Bleeding-edge (`4.8.13.5`) DLSS Enabler channels.
- Automatic version string resolution directly from GitHub build filenames.
