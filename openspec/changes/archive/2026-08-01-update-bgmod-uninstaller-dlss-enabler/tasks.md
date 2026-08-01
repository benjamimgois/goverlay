# Tasks: Update BGMod Uninstaller for DLSS Enabler

## 1. Uninstaller Logic Implementation
- [x] 1.1 In `bgmod-uninstaller.lpr`, add `TempStr + 'dlssenabler-edge'` directory removal to the global uninstallation block (`IsGlobalUninstall`).
- [x] 1.2 In `bgmod-uninstaller.lpr`, add `SafeDeleteDirectory(IncludeTrailingPathDelimiter(GameDir) + 'OptiScaler')` to game directory uninstallation.

## 2. Compilation & Build Verification
- [x] 2.1 Compile `bgmod-uninstaller` using `fpc -O3 bgmod-uninstaller.lpr`.
- [x] 2.2 Verify full build via `make`.
