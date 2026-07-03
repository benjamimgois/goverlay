## Context

`SafeBackupFile` (in `bgmod.lpr`) saves the original DLL from `GameDir/<name>` to `GameDir/<name>.b` before overwriting `GameDir/<name>` with the OptiScaler proxy. `SafeCleanOrRestore` (in both `bgmod.lpr` and `bgmod-uninstaller.lpr`) restores `GameDir/<name>.b` back to `<name>` and deletes the `.b`. The mechanism has two latent failure modes that compound into the reported bug:

1. **No-original first install.** For games that do not ship a particular DLL (e.g. `dxgi.dll` in God of War Ragnarok), `SafeBackupFile` skips entirely because `FileExists(FullSrc)` is false. No `.b` is created.
2. **Second install overwrites a non-original.** On a subsequent install, `GameDir/<name>` is now the GOverlay proxy from the first install. The guard `if FileExists(FullSrc) and not FileExists(FullDest)` passes (because no `.b` was ever written), so `SafeBackupFile` renames the *proxy* to `.b`, permanently replacing the game's true original (which never existed in `GameDir` in the first place). Every subsequent uninstall then "restores" a proxy.

The same corruption applies to any original DLL that GOverlay backs up. Once corrupted, uninstalling just swaps one proxy for another and OptiScaler keeps loading.

The marker-based ownership fix from the prior change (`fix-proxy-dll-uninstall-marker-detection`) correctly identifies the leftover `dxgi.dll` as GOverlay-owned (because `goverlay.vars` is in the same dir), and deletes it — but only when no `.b` exists. When a corrupted `.b` exists, the `.b` branch runs first and reinstalls a proxy. So the marker fix is necessary but not sufficient; the backup location must change.

## Goals / Non-Goals

**Goals:**
- Store original-DLL backups outside `GameDir` so they cannot be corrupted by repeated installs, channel switches, or Steam "Verify integrity of game files".
- Restore the true original DLL during uninstall, not a previously-installed proxy.
- Keep the backup lifecycle tied to the per-game GOverlay config: creating the GOverlay config on install creates the backup folder; deleting the GOverlay config on uninstall deletes the backups too (they are no longer needed once the originals have been restored).
- Preserve the public-facing behavior of "Uninstall changes" and the disabled-cleanup launch path.

**Non-Goals:**
- Recovering originals that were already irrevocably corrupted by the old `in-GameDir .b` mechanism. The user must repair those game files via Steam "Verify integrity" once. The new mechanism prevents any *new* corruption.
- Migrating existing in-`GameDir` `.b` files (corrupted or not) into the new backup folder. Those `.b` files are unreliable post-bug and cannot be trusted as originals. They are simply deleted on the first run of the new code path. The user verifies integrity once if needed.
- Changing the file list of DLLs that are backed up/restored — the same `OrigDlls` and `ProxyDlls` arrays apply.
- Supporting multiple game installs with different DLL names backed up to the same folder — the per-game folder is naturally single-installation.

## Decisions

### 1. Backup folder location

**Decision:** `~/.local/share/goverlay/gameconfig/<game>/backups/`.

- For `bgmod` running per-game, `BgmodPath = ExtractFilePath(ParamStr(0))` is `gameconfig/<game>/`, so the backup folder is simply `BgmodPath + 'backups/'`. The existing `ConfigDir` variable (which already equals `BgmodPath` for per-game and `<grandparent>/gameconfig/global/` for the global profile) is used uniformly: `BackupsDir := ConfigDir + 'backups/'`.
- For the global profile, `BackupsDir = gameconfig/global/backups/`. Global installs still back up originals from whichever `GameDir` they target, but the backups are scoped to the global config dir. (If the same `bgmod` binary is later reused against a different game with the *global* profile, the backups would collide. The existing code only runs the global install path once per machine and per game's bgmod script — there is always a per-game `bgmod` in `gameconfig/<game>/` after the first click on that game card, so per-game backup folders are the norm. For the rare case where the user runs `bgmod` directly with the global profile against multiple games, only the last game's original would be backed up — acceptable, documented below.)

**Alternative considered:** a central backups folder per GameDir hash (`~/.local/share/goverlay/backups/<hash>/`). Rejected: it requires a hash and does not auto-cleanup with the game config.

**Alternative considered:** backup folder inside GameDir (`GameDir/.bgmod_backups/`). Rejected: Steam "Verify integrity" wipes GameDir entirely, leaving no backups to restore from.

### 2. `SafeBackupFile` writes only the true original, never overwrites

**Decision:** `SafeBackupFile(GameDir, BackupsDir, FileName)` backs up `GameDir + FileName` to `BackupsDir + FileName` *only if* (a) the source file exists in `GameDir` AND (b) the backup slot in `BackupsDir` is *not* already taken. The `not FileExists(FullDest)` guard is retained — it now protects against the second-install corruption case because `BackupsDir/<name>` only ever contains the true original (never reached a second time once the slot is filled).

Compare with the old behavior, where `GameDir/<name>.b` *would* be overwritten on the second install because the first install left no `.b` at all (no source existed). With the new location, the first backup-for-no-original case still skips the slot, but the slot stays empty; on the second install, the source *is* a proxy, but `GameDir + FileName` exists and the backup slot does not, so the proxy would be backed up — same bug!

To prevent that, `SafeBackupFile` additionally checks that we have not *already* installed GOverlay for this game: if `goverlay.vars` exists in `GameDir`, we are on a reinstall, and `SafeBackupFile` is a no-op (the originals were already either backed up on the first install or never existed). This second guard is what breaks the corruption cycle:

```
1st install:  no goverlay.vars in GameDir → backup originals (if any) → install proxy + vars
2nd install: goverlay.vars in GameDir → skip backup entirely → just overwrite proxy
Uninstall:    clean proxy + restore from BackupsDir (true originals) OR delete if no backup
```

This guard is the actual fix for the reported bug. The location change is the structural fix; the `goverlay.vars` guard is the immediate fix that prevents the reinstall-from-proxy corruption.

**Alternative considered:** track backup state in `bgmod.conf` instead of using `goverlay.vars` as a proxy for "already installed". Rejected: `goverlay.vars` is already written by the install flow as a final step and presence-checked elsewhere.

### 3. `SafeCleanOrRestore` restores from `BackupsDir`

**Decision:** `SafeCleanOrRestore(GameDir, BackupsDir, FileName, IsOriginalGameFile)` checks `FileExists(BackupsDir + FileName)` first. If present, restore it into `GameDir + FileName` (overwriting any current file there) and delete the `BackupsDir/<FileName>` slot. If no backup exists, fall through to the existing marker-based `IsGOverlayProxyFile`/delete branch. The `GameDir/<name>.b` in-place restore branch is removed entirely — it was the corruption source.

### 4. Pass `BackupsDir` explicitly to backup/restore helpers

**Decision:** change the signatures:

```pascal
procedure SafeBackupFile(const GameDir, BackupsDir, DllFile: string);   // bgmod.lpr only
procedure SafeCleanOrRestore(const TargetDir, BackupsDir, FileName: string; IsOriginalGameFile: Boolean);
```

Both binaries compute `BackupsDir := ConfigDir + 'backups/'` (bgmod) or `BackupsDir := UninstallerPath + 'backups/'` (uninstaller — `UninstallerPath = ExtractFilePath(ParamStr(0))` already equals `gameconfig/<game>/` per-game, or `bgmod/` for the legacy global-mode uninstall case, in which case the backup folder is `bgmod/backups/` and the originals come from that one game's install).

`ForceDirectories(BackupsDir)` is called once before the install block (bgmod) and once before the uninstall block (uninstaller), both guarded with `if not DirectoryExists`.

### 5. GUI `STEAM_COMPAT_INSTALL_PATH` flow keeps working

The GUI's new `bgmod-uninstaller` invocation (from the `fix-proxy-dll-uninstall-marker-detection` change) passes only `STEAM_COMPAT_INSTALL_PATH` to point the uninstaller at the target `GameDir`. The uninstaller resolves `UninstallerPath` from its own binary location — which in the GUI flow is `gameconfig/<game>/bgmod-uninstaller` (copied there by `GameCardClick`). So `UninstallerPath = gameconfig/<game>/`, and the backup folder resolution is automatic. No GUI changes required beyond rebuilding `data/bgmod/bgmod-uninstaller`.

If the `bgmod-uninstaller` binary is invoked from `~/.local/share/goverlay/bgmod/bgmod-uninstaller` (e.g. dropped directly into `GameDir` by the old install flow before per-game config existed), `UninstallerPath = bgmod/` and `BackupsDir = bgmod/backups/`. That matches what `bgmod` would write when running in the global profile mode.

### 6. Delete leftover `.b` files in `GameDir` on first encounter

**Decision:** on the first run of the new `bgmod` (install path) or `bgmod-uninstaller` that finds a `<file>.b` in `GameDir` for a file we are about to manage, move it to `BackupsDir` *only if* the new slot is empty AND the install is first-time (no `goverlay.vars` in `GameDir`). Otherwise, delete the in-`GameDir` `.b` (it is unreliable post-bug). This is best-effort and idempotent; it cleans up the legacy breadcrumbs without attempting to recover already-corrupted state.

Rationale for not trusting existing `.b`: by the time the user sees OptiScaler loading after Uninstall, the `.b` is already a proxy (the bug), so preserving it would re-install the proxy on the next uninstall. Deleting it forces Steam Verify integrity (manual one-time fix), but stops the auto-reinstall loop.

## Risks / Trade-offs

- **[Risk] Global-profile installs back up to `gameconfig/global/backups/` and can collide across games.** If the user runs the global profile against two different games, the second game's `SafeBackupFile` would find the slot occupied (by the first game's original) and skip, but the proxy install would still proceed, and the second uninstall would then *restore the first game's DLL* into the second game — wrong file!
  - *Mitigation:* in global mode, `SafeBackupFile` skips if the slot is occupied, AND when restoring, `SafeCleanOrRestore` validates that the backup file size matches the original file size recorded in `goverlay.vars` via a new `BackupOriginalSize=` hint. If the size does not match, skip the restore and just delete the proxy (letting Steam Verify fix the rest). The per-game path (the normal case) is unaffected.
  - Simpler mitigation if this proves heavy: in global mode, do not back up at all (only delete/restore-proxy as a no-op for original DLLs that never existed). This is acceptable because the global profile is used for one-game testing and the per-game flow is the documented one. Choose the simple option: in global mode, the install path still skips backups (as today) and the uninstall path falls through to the delete branch. préférable.
- **[Risk] Games that ship a `dxgi.dll` but get it replaced by a third-party tool before GOverlay runs.** The backup now captures whatever is in `GameDir` at first install. If that's already a third-party proxy, we back it up and "restore" it later — the user loses the genuine game original. This is the *same* limitation as the old `.b` mechanism; the new design does not regress this.
- **[Risk] User manually deletes `gameconfig/<game>/backups/` mid-install.** The restore falls through to the marker-based delete, leaving no DLL. Same risk as deleting the old `.b`; documented as user-initiated destructive action.
- **[Trade-off] `goverlay.vars` acts as the "already installed" signal for `SafeBackupFile`.** The marker is already written by the install flow and is a stable signal. If `goverlay.vars` is absent but a proxy `dxgi.dll` is present (third-party install), `SafeBackupFile` proceeds and backs up the third-party DLL — same as the old behavior. The fix only kicks in on reinstall (where `goverlay.vars` exists).
- **[Trade-off] Existing `gameconfig/<game>/backups/` may not exist for already-installed games.** On the first run of the new `bgmod` against an already-installed game, `goverlay.vars` is present (the prior install wrote it), so `SafeBackupFile` skips and no backup is created. The uninstall then falls through to the delete branch, removing the proxy. If the user wants the original back, Steam Verify is required. This is a one-time inconvenience for upgrades; new installs work correctly.

## Open Questions

- Should the spec explicitly call out the global-profile backup-limitation, or is it acceptable to leave it under the existing "global profile is a test mode" framing inherited from `global-profile-gameconfig-isolation`? Current design treats it as documented limitation (no backups in global mode).