## Context

Currently, GOverlay checks for MAKO updates on startup, but the UI state is lost when navigating between tabs because `UpdateEngineStatus` and `UpdateStatusCard` unconditionally reset the display to the local installed version. Furthermore, the Home tab module status indicator is not notified when an update is found, and asset parsing matches Flatpak tarballs instead of native Linux tarballs. See `proposal.md` for background and motivation.

## Goals / Non-Goals

**Goals:**
- Maintain persistent in-memory update state (`FMakoRemoteVersion`, `FMakoUpdateAvailable`) in `TLosslessScalingTabHelper`.
- Keep the update notification badge (`CleanLocal → CleanRemote`) and "Install update" button visible across tab navigation and settings reloads.
- Reflect update availability in the Lossless Scaling tab Software Status card with accent color (`$0044AAFF` / `CLR_TEXT_ACCENT`), consistent with OptiScaler.
- Update the Home tab module indicator (`FHomeModVerLbls[5]`) when a MAKO update is detected.
- Exclude `-flatpaks.tar.xz` archives in `GetMakoLatestRemoteVersion` and strictly prioritize native Linux tarballs (`-linux.tar.xz`).

**Non-Goals:**
- Modifying the underlying MAKO installer script or headless execution parameters.
- Changing `lsfg-vk` layer update mechanisms (this change is specifically focused on MAKO renderer notifications).
- Adding scheduled recurring periodic pollers while the app is idle; checks occur on startup and tab load if not previously checked.

## Decisions

### 1. State Persistence in `TLosslessScalingTabHelper`
- **Choice**: Store `FMakoRemoteVersion: string` and `FMakoUpdateAvailable: Boolean` as fields on `TLosslessScalingTabHelper`.
- **Rationale**: `TLosslessScalingTabHelper` owns both the update checking thread (`TMakoCheckUpdateThread`) and the UI elements on the Lossless Scaling tab. Keeping the state here allows `UpdateEngineStatus` and `UpdateStatusCard` to inspect whether an update was already detected before redrawing.
- **Alternative considered**: Storing in `TOptiscalerUpdate` or global variables. Rejected because MAKO UI controls and threads are encapsulated inside `TLosslessScalingTabHelper`.

### 2. Guarding `UpdateEngineStatus` and `UpdateStatusCard` Against Overwrite
- **Choice**: In `UpdateEngineStatus`, check `if FMakoUpdateAvailable then ...` and preserve the update banner and `FLsInstallBtn.Visible := True`. In `UpdateStatusCard`, show `CleanLocal + ' → ' + FMakoRemoteVersion` with accent color.
- **Rationale**: Prevents `LoadLosslessConfig` (triggered on every tab show) from wiping out update status.

### 3. Home Tab Synchronization via Main Form Hook
- **Choice**: Add `procedure RefreshHomeMakoStatus(const ACurrentVer, ANewVer: string)` to `THomeTabHelper` (or `Tgoverlayform`) and invoke it from `TMakoCheckUpdateThread.SyncResult`.
- **Rationale**: OptiScaler does this via `RefreshHomeOptiStatus`. MAKO will follow the exact same architectural pattern so that users see pending updates immediately on the Home screen.

### 4. Strict Tarball Matching in `GetMakoLatestRemoteVersion`
- **Choice**: Update `GetMakoLatestRemoteVersion` to match `(Pos('-linux.tar.xz', AssetName) > 0) and (Pos('flatpak', LowerCase(AssetName)) = 0)`.
- **Rationale**: GitHub release assets for MAKO include both `flatpaks.tar.xz` and `linux.tar.xz`. The existing `or (Pos('.tar.xz', AssetName) > 0)` matched Flatpak first because GitHub returned it first in the JSON array.

## Risks / Trade-offs

- [Risk] GitHub API rate limiting could prevent remote version lookup. → [Mitigation] Existing error handling already catches network failures and retains installed version status gracefully.
- [Risk] User updates MAKO externally while GOverlay is open. → [Mitigation] Tab show re-checks the local installed version from disk; if `CleanLocal` matches `FMakoRemoteVersion`, `FMakoUpdateAvailable` is cleared.
