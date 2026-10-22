## 1. Subprocess Logger Enhancements in bgmod

- [x] 1.1 Add MangoHud log file initialization and stderr stream filtering (`LogMango`, `mangohud.log` in both `CentralLogDir` and `GameDir`) in `bgmod.lpr` and verify compilation.
- [x] 1.2 Add DLSS Enabler log file paths and header initialization (`dlss-enabler.log` and `fakenvapi.log`) when `UpscalerType = 1` in `bgmod.lpr` and verify compilation.

## 2. File-Based Tool Log Synchronization in bgmod

- [x] 2.1 Implement case-insensitive log synchronization routine (`SyncGameDirLogsToCentral`) in `bgmod.lpr` covering `optiscaler.log`, `dlss-enabler.log`, `fakenvapi.log`, `vksumi.log`, `vkbasalt.log`, `mako.log`, `lsfg.log`, and `bgmod-uninstaller.log`.
- [x] 2.2 Hook `SyncGameDirLogsToCentral` into `RunSubprocessLogger` upon game process termination (pipe EOF) and verify compilation.

## 3. GOverlay UI Log Viewer Resolution

- [x] 3.1 Update `GetActiveTabLogFile` in `overlayunit.pas` to check `dlssenablerRadioButton.Checked` on `optiscalerTabSheet` and return `dlss-enabler.log`, and return `mangohud.log` on MangoHud tabs.
- [x] 3.2 Verify that `openLogFileMenuItemClick` creates and opens the correct log file for each active tool tab.

## 4. Uninstaller Central Log Mirroring

- [x] 4.1 Ensure `bgmod-uninstaller.lpr` writes or copies its execution log to `CentralLogDir/bgmod-uninstaller.log` whenever the central log directory is resolved.

## 5. Build and Verification

- [x] 5.1 Build `bgmod`, `bgmod-uninstaller`, and `goverlay` using `make`, confirming successful compilation.
- [x] 5.2 Execute test suite (`./tests/gui/goverlay_gui_tests`) to confirm no regressions across GUI and mod routines.
