# Design: Download Only Stable OptiScaler and DLSS Enabler on Startup

## Context

On initial launch, GOverlay checks whether OptiScaler and DLSS Enabler are downloaded in `~/.local/share/goverlay/`. Previously it performed startup downloads for all 4 channels (Stable and Edge for both OptiScaler and DLSS Enabler). This change reduces startup downloads strictly to the stable channels, leaving edge builds for on-demand installation through the UI.

## Goals / Non-Goals

**Goals:**
- Only download OptiScaler Stable (`optiscaler-stable/`) and DLSS Enabler Stable (`dlssenabler-stable/`) during startup.
- Update `StartupDownloadsAsync` check to only trigger boot splash if stable files are missing.
- Re-scale progress reporting: OptiScaler Stable (0% to 50%), DLSS Enabler Stable (50% to 95%), Finishing (100%).
- Ensure `SyncUpdateUI` in `TOptiUpdateThread` displays `FUpdateBtn` ("Update" / "Install") when the user selects the Bleeding-edge channel and no local edge version is present.

**Non-Goals:**
- Changing manual in-app update logic or channel switching mechanics for already downloaded versions.

## Decisions

### Decision 1: Startup check and thread execution scope
- **Choice**: In `StartupDownloadsAsync`, check only `FileExists(GetBGModOriginalPath + 'OptiScaler.dll')` and `FileExists(GetDlssEnablerPath(True) + 'version.dll')`.
- **In `TStartupDownloadThread.Execute`**:
  ```pascal
  CheckAndInstallOptiScaler(GetFGModPath, True, @OnDownloadProgress);
  CheckAndInstallDlssEnabler(True, False, @OnDownloadProgress);
  OnDownloadProgress(100, 'Finishing setup...');
  ```

### Decision 2: In-app Edge detection in `SyncUpdateUI`
- **Choice**: In `TOptiUpdateThread.SyncUpdateUI`, when `(FLatestOptiTag <> '')` and `(CurrentVersion = '') or (CurrentVersion = '—')`, treat this as a missing installation and set `HasUpdates := True;`, showing `Install Available <tag>` and making `FUpdateBtn` visible.

## Risks / Trade-offs

- **Risk**: User switches to Bleeding-edge without an internet connection when edge was not pre-downloaded.
  - **Mitigation**: The UI clearly shows update check failure or download failure toast if offline, while stable channel remains fully functional and intact.
