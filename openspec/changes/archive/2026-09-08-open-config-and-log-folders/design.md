# Design: Open Config and Log Folders

## Overview

Update GOverlay's floating dock hamburger menu (`popsaveMenu`) to open configuration and log directories in the default desktop file manager (`xdg-open`) instead of attempting to open individual files directly.

## Key Changes

1. **Folder Resolution & Opening**:
   - `openConfigFileMenuItemClick`: Resolves `TargetFile := GetActiveTabConfigFile`. If valid, extracts its directory via `ExtractFilePath(TargetFile)`, falling back to `GetGameConfigDir(FActiveGameName)`. Ensures directory exists (`ForceDirectories`) and invokes `xdg-open <dir> &`.
   - `openLogFileMenuItemClick`: Resolves `TargetDir := GetGameLogDir(FActiveGameName)`. Ensures directory exists (`ForceDirectories`) and invokes `xdg-open <dir> &`.

2. **Menu Ordering & Visuals**:
   - In `popsaveMenu`, `saveoptionsItem` and `loadconfigMenuItem` precede `openConfigFileMenuItem` and `openLogFileMenuItem`.
   - Both menu items use `ImageIndex = 24` (the standard folder icon).
   - Captions are set to `"Open config folder"` and `"Open log folder"`.

3. **Localization & Streaming Persistence**:
   - Explicitly assigned in `FormCreate` and `popupBitBtnClick` to avoid stale streamed captions.
   - Updated `.lfm`, `.lrj`, and `.po`/`.pot` message catalogs.
