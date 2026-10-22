## Context

Currently, `StartupDownloadsAsync` in `overlayunit.pas` only checks if `OptiScaler.dll` and `version.dll` exist on disk. If both exist, it assumes setup is complete and bypasses the splash screen. Furthermore, `CheckAndInstallOptiScaler` in `optiscaler_update.pas` exits early if `OptiScaler.dll` exists, bypassing the FSR4 and companion DLSS downloads.

See `proposal.md` for motivation and background.

## Goals / Non-Goals

**Goals:**
- Provide a unified check `HasMissingMandatoryLibraries(out AMissingList: TStringList): Boolean` that audits all required libraries (OptiScaler, NVIDIA DLSS, FrameGen bridge, FakeNVAPI, FSR4, and DLSS Enabler).
- Introduce a modular `CheckAndInstallFsr4` function in `optiscaler_update.pas` (and update `CheckAndInstallOptiScaler` for self-healing) to download missing files without re-downloading existing archives.
- Ensure that `TStartupDownloadThread` records any failed downloads in a list rather than crashing or aborting early.
- Guarantee that GOverlay opens normally even if network downloads fail, displaying a non-intrusive warning toast via `notificationunit.ShowToast`.

**Non-Goals:**
- Auto-installing pre-release / edge builds on startup (stable channel remains default).
- Overwriting existing game-level configurations.
- Blocking application launch when running in offline mode.

## Decisions

### Decision 1: Modular `CheckAndInstallFsr4` function with self-healing
- **Rationale**: Following the pattern of `CheckAndInstallVkSumi` and `CheckAndInstallMako`, FSR4 downloads (`Latest`, `4.1.1b`, `4.0.2c`) should have a dedicated self-healing procedure that checks `GetFSR4BasePath`, copies `Latest` from OptiScaler cache if present, and downloads `4.1.1b` / `4.0.2c` only if missing.
- **Alternative considered**: Keeping FSR4 coupled inside `CheckAndInstallOptiScaler`. Rejected because it prevents checking or healing FSR4 independently.

### Decision 2: Self-healing companion check in `CheckAndInstallOptiScaler`
- **Rationale**: When `OptiScaler.dll` already exists, `CheckAndInstallOptiScaler` will not abort immediately. Instead, it checks for missing companion files (`nvngx_dlss*.dll`, `dlssg_to_fsr3_amd_is_better.dll`, `fakenvapi.dll`) and downloads only the missing items.
- **Alternative considered**: Deleting `OptiScaler.dll` to force full archive download. Rejected because re-downloading the entire bundle consumes unnecessary bandwidth and increases splash time.

### Decision 3: Error aggregation in `TStartupDownloadThread` and Toast Notification
- **Rationale**: `TStartupDownloadThread` maintains an `FFailedFiles: TStringList`. When a download step fails (curl exit code <> 0 or target file missing), the friendly file description is appended to `FFailedFiles`. Once `HideBootSplash` and `Self.Show` execute, if `FFailedFiles.Count > 0`, `ShowToast(ntWarning, ...)` is called.
- **Alternative considered**: Showing a modal dialog (`ShowMessage`). Rejected because modal dialogs interrupt the user, whereas toast notifications inform the user while allowing normal navigation.

## Risks / Trade-offs

- **[Risk] Curl timeouts on offline startup**: If the user has no internet connection, curl requests will wait for the 10-second connect timeout before failing.
  - *Mitigation*: Run curl with `--connect-timeout 10` (already standard in `RunCurlWithProgress`). If the core files exist and only 1-2 companion files are missing, the delay is bounded, errors are caught, and GOverlay displays the toast without crashing.
- **[Risk] Toast message overflow**: If multiple files fail, the message string might exceed standard toast dimensions.
  - *Mitigation*: If more than two files fail, summarize the notification (e.g. "Failed to download FSR4 and DLSS libraries (X files). Check internet connection.").
