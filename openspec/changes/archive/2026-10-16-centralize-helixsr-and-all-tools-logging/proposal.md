# Proposal

## Why

Currently, diagnostic logs for HelixSR (`helixsr.log`, `helixsr_loader.log`, `nvexec.log`) and AFMF (`afmf.log`) are not reliably collected into the centralized log directory (`~/.local/share/goverlay/logs/<GameDirName>/`). In `bgmod.lpr`, `RunSubprocessLogger` does not capture stderr for HelixSR or AFMF, and `SyncGameDirLogsToCentral` only searches the root game directory without scanning `<GameDir>/HelixSR/`. Furthermore, in the GOverlay GUI (`overlayunit.pas`), `GetActiveTabLogFile` does not resolve `helixsr.log` when HelixSR is chosen, `afmf.log` when AFMF is chosen, or `reshade.log` when ReShade is viewed.

## What Changes

- **HelixSR Centralized Logging**:
  - In `bgmod.lpr`, route HelixSR stderr messages to `~/.local/share/goverlay/logs/<GameDirName>/helixsr.log` inside `RunSubprocessLogger`.
  - In `SyncGameDirLogsToCentral`, discover and synchronize `helixsr.log`, `helixsr_loader.log`, and `nvexec.log` from both `<GameDir>` and `<GameDir>/HelixSR/` (and subfolders) into the central log directory.
- **AFMF Centralized Logging**:
  - In `bgmod.lpr`, initialize and route AFMF stderr output to `~/.local/share/goverlay/logs/<GameDirName>/afmf.log`.
  - In `SyncGameDirLogsToCentral`, discover and synchronize `afmf.log` to the central log directory.
- **GOverlay UI Log Integration**:
  - Update `GetActiveTabLogFile` in `overlayunit.pas` to resolve `helixsr.log` when HelixSR is active on the OptiScaler tab, `afmf.log` when AFMF is active on the Frame Interpolation tab, and `reshade.log` on the ReShade tab.
- **Automated Verification**:
  - Add tests in `tests/gui/gui_test_cases.pas` verifying that `GetActiveTabLogFile` resolves `helixsr.log`, `afmf.log`, and `reshade.log`.
  - Add tests in `tests/logic/logic_test_cases.pas` verifying that `SyncGameDirLogsToCentral` discovers logs located in both root and tool subdirectories like `HelixSR/`.

## Capabilities

### Modified Capabilities

- `centralized-tools-logging`: Extend centralized log capture, directory synchronization, and UI log resolution to include HelixSR, AFMF, and nested tool log folders.

## Impact

- `bgmod.lpr`: `RunSubprocessLogger`, `SyncGameDirLogsToCentral`, and tool logging initialization before subprocess fork.
- `overlayunit.pas`: `GetActiveTabLogFile`.
- `tests/gui/gui_test_cases.pas` and `tests/logic/logic_test_cases.pas`: test coverage for log file resolution and synchronization.
