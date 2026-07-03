## Why

OptiScaler proxy DLLs remain loaded in games after the user clicks "Uninstall changes" in the GOverlay GUI. The `bgmod-uninstaller` log shows `Restored original dxgi.dll`, yet the restored `dxgi.dll` is itself an OptiScaler proxy (confirmed by `strings`: `OptiScaler working as dxgi.dll, dxgi-original.dll loaded`). Root cause: `SafeBackupFile` (bgmod.lpr) stores the original game DLL alongside the proxy as `dxgi.dll.b` in the same `GameDir`. On the *first* install of a game that ships without a `dxgi.dll` (e.g. God of War Ragnarok), no `.b` is created because `FullSrc` doesn't exist. On a *second* install (channel switch, reinstall, or any re-run), the proxy from the first install becomes `dxgi.dll`, the `not FileExists(FullDest)` guard passes (no `.b` was ever written), so `SafeBackupFile` renames the *proxy* into `dxgi.dll.b`, permanently replacing the game's true original. From that point on, every uninstall "restores" a proxy, leaving OptiScaler active even after cleanup.

The same corruption pattern applies to every original game DLL that GOverlay backs up (`d3dcompiler_47.dll`, `amd_fidelityfx_*`, `libxess*`, `nvngx*`, etc.) — any of them can be replaced with a GOverlay-placed copy and then "restored" as that copy.

## What Changes

- **Move `.b` backups out of `GameDir`** into a dedicated per-game backup folder at `~/.local/share/goverlay/gameconfig/<game>/backups/`. The backups now live outside the game installation tree, so:
  - Steam "Verify integrity of game files" cannot delete or rewrite them.
  - A second GOverlay install can never overwrite the true original with a previously-installed proxy, because the backup folder is only ever written when the original truly exists, and never overwritten once it exists.
- **`SafeBackupFile` writes to `gameconfig/<game>/backups/<filename>`** (creating the folder if missing), only when the source file in `GameDir` exists and the backup slot is not already taken. The function no longer writes `.b` files inside `GameDir`.
- **`SafeCleanOrRestore` reads from `gameconfig/<game>/backups/<filename>`** instead of `GameDir + filename + '.b'`. If a backup exists there, it restores the original file into `GameDir` and deletes the backup slot. If no backup exists, it falls through to the existing delete/skip branch (using the marker-based `IsGOverlayProxyFile` from the prior fix).
- **Pass the active game name** to `SafeBackupFile` and `SafeCleanOrRestore` so they can resolve the per-game backup folder. The bgmod launcher already knows `BgmodPath` and can derive the game name from it (`gameconfig/<game>/` is its parent when running per-game). The bgmod-uninstaller already receives `GameDir` and resolves the game name; it can resolve the backup folder the same way it already resolves the central log dir.
- **No `.b` files are left in `GameDir`** after this change. Existing `.b` files in `GameDir` from prior installs are migrated once: on the first run of the new `bgmod`/`bgmod-uninstaller` that finds a `<file>.b` in `GameDir` for a file we are about to manage, move it to the new backup folder (only if the new slot is empty) and delete the old in-place `.b`. This is a best-effort, idempotent migration; if the in-place `.b` is already a corrupted proxy (the bug), the migration still moves it (we cannot tell good from bad from here), but no *new* corruption happens.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `fix-optiscaler-game-uninstall-cleanup`: cleanup and backup flows now resolve backups from a per-game folder outside `GameDir` instead of `<file>.b` in `GameDir`, preventing backup corruption across reinstalls and channel switches.

## Impact

- **Affected files**: `bgmod.lpr` (`SafeBackupFile`, `SafeCleanOrRestore` and the install/disabled-cleanup call sites that pass the game config dir), `bgmod-uninstaller.lpr` (`SafeCleanOrRestore` and the call sites; the uninstaller already resolves a per-game log dir so the same resolver is reused), `games_tab.pas` (no behavior change — the GUI now invokes `bgmod-uninstaller`, which handles backups itself; only the call signature passed through `STEAM_COMPAT_INSTALL_PATH` may need to also expose the game name via an env var so the uninstaller can resolve the backup folder).
- **APIs & Paths**: `SafeBackupFile`/`SafeCleanOrRestore` signatures change to accept the per-game backup directory. Call sites pass that directory explicitly. No public API changes.
- **Persisted data**: a new `gameconfig/<game>/backups/` directory per game; populated on install, emptied/restored on uninstall; deleted alongside `gameconfig/<game>/` when the user uninstalls the game's GOverlay config (existing `DeleteDirectory(GameCfgDir)` flow).
- **Build**: the `bgmod` and `bgmod-uninstaller` binaries must be rebuilt (`fpc -O3`) and copied into `data/bgmod/`.
- **Migration**: existing `<file>.b` files inside `GameDir` are moved to the new folder on first encounter; if they are already proxies (corrupted), the migration still moves them but no new corruption happens. Games that already had their original DLL irrecoverably replaced by a proxy (the bug) will continue to load OptiScaler until the user restores the original DLL from Steam's "Verify integrity" — out of scope for this change, documented as a known limitation.
- **Compatibility**: the `bgmod` wrapper will read the original game's `bgmod.conf` to resolve the per-game config dir (already does via `BgmodPath` parent). For the global profile (`BgmodPath` ends with `/bgmod/`), the backups folder is `gameconfig/global/backups/`.