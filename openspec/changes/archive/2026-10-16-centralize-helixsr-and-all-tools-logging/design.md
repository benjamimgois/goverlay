# Design

## Context

Centralized logging in GOverlay relies on two mechanisms inside the `bgmod` game launcher:
1. **Real-time stderr stream routing** (`RunSubprocessLogger`): Reads game process standard error, recognizes tool-specific signatures, and writes formatted timestamps to centralized tool log files in `~/.local/share/goverlay/logs/<GameDirName>/`.
2. **File synchronization** (`SyncGameDirLogsToCentral`): Discovers file-based logs produced by injected DLLs (e.g., OptiScaler, DLSS Enabler, ReShade) in the game directory and copies them to the central log directory periodically and on game exit.

Currently, HelixSR and AFMF lack stderr routing in `RunSubprocessLogger`, and `SyncGameDirLogsToCentral` only searches the root game directory without scanning `<GameDir>/HelixSR/` where HelixSR writes its runtime logs. In the GOverlay GUI, `GetActiveTabLogFile` does not recognize HelixSR, AFMF, or ReShade.

## Goals / Non-Goals

**Goals:**
- Guarantee that all diagnostic outputs from HelixSR (`helixsr.log`, `helixsr_loader.log`, `nvexec.log`) and AFMF (`afmf.log`) are stored in `~/.local/share/goverlay/logs/<GameDirName>/`.
- Route HelixSR and AFMF standard error messages through `RunSubprocessLogger`.
- Discover and synchronize file-based logs located in `<GameDir>/HelixSR/` into `<CentralLogDir>`.
- Update GOverlay GUI log resolution so "Open log folder" and active log tab viewers correctly point to the tool's log file.
- Verify through automated unit and GUI tests (`make test`).

**Non-Goals:**
- Changing upstream DLL log formats or logging verbosity in game configuration files.
- Storing active log files inside the game directory.

## Decisions

### Decision 1: Extend RunSubprocessLogger for HelixSR and AFMF
- **Choice**: Add `HelixCent, AfmfCent: string; LogHelix, LogAfmf: Boolean` parameters to `RunSubprocessLogger` in `bgmod.lpr`.
- **Rationale**: When games or proton run with HelixSR or AFMF, runtime messages (e.g. shader compilation status, DX12 upscaler hooks, optical flow errors) are written to stderr. Routing lines matching `helixsr`, `hxsr`, `dx12_upscaler`, and `afmf` into their respective central log files guarantees complete diagnostics.

### Decision 2: Multi-Directory Candidate Scanning in SyncGameDirLogsToCentral
- **Choice**: Expand `SyncGameDirLogsToCentral` to search both `<GameDir>` and `<GameDir>/HelixSR/` (as well as `<GameDir>/HelixSR/helixsr-fg/`) for candidate files: `helixsr.log`, `helixsr_loader.log`, `nvexec.log`, and `afmf.log`.
- **Rationale**: Depending on deployment mode (OptiScaler backend vs Native DLSS), HelixSR DLLs write their logs in the subfolder where they reside. Scanning the subfolder ensures no log file is missed.

### Decision 3: Complete UI Log File Resolution
- **Choice**: Update `GetActiveTabLogFile` in `overlayunit.pas` to resolve:
  - `helixsr.log` when `helixsrRadioButton.Checked` is true on `optiscalerTabSheet`.
  - `afmf.log` when `InterpolationMethod = imAfmf` on `losslessScalingTabSheet`.
  - `reshade.log` when on `reshadeTabSheet`.
- **Rationale**: Keeps the UI consistent and allows users to immediately inspect the relevant tool's log.

## Risks / Trade-offs

- **[Risk] Multiple tools emitting shared strings on stderr**
  - **Mitigation**: Filter checks are specific (`helixsr`, `hxsr`, `dx12_upscaler` for HelixSR; `afmf`, `fluid motion` for AFMF). Raw stderr is preserved and forwarded to original stderr descriptors.
