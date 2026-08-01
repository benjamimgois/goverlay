# Design: BGMod Uninstaller DLSS Enabler Cleanup

## Overview

Update `bgmod-uninstaller.lpr` to handle DLSS Enabler artifacts in both global mode (`--global` / `-g`) and per-game uninstallation mode.

## Proposed Architecture & Changes

### 1. Global Uninstall (`IsGlobalUninstall` = True)
- Calculate base goverlay data path `TempStr := IncludeTrailingPathDelimiter(ExtractFileDir(ExcludeTrailingPathDelimiter(GetBGModPath)))`.
- Check if `TempStr + 'dlssenabler-edge'` exists.
- If present, log removal and call `SafeDeleteDirectory(TempStr + 'dlssenabler-edge')`.

### 2. Game Directory Uninstall (`GameDir` <> '')
- Add `SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler')` alongside existing cleanup of `D3D12_OptiScaler` and proxy DLLs.

## Migration & Compatibility
- Backward-compatible with existing OptiScaler uninstallations.
