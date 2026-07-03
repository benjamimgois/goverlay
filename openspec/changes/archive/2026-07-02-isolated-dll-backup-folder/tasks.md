## 1. Introduce `BackupsDir` resolution in both binaries

- [x] 1.1 In `bgmod.lpr`, after `ConfigDir` is resolved (around line 732 / 742), compute `BackupsDir := ConfigDir + 'backups' + PathDelim;` and `ForceDirectories(BackupsDir)` once before the install block. Skip `ForceDirectories`/backups in global-profile mode per design (Decision 1, Risk mitigation) — guard with `if LowerCase(Key) <> 'bgmod'` (i.e. per-game path) before creating the folder.
- [x] 1.2 In `bgmod-uninstaller.lpr`, after `UninstallerPath := ExtractFilePath(ParamStr(0))` (around line 516), compute `BackupsDir := UninstallerPath + 'backups' + PathDelim;`. Do NOT ForceDirectories here yet (created in 2.2 only when actually restoring). Same per-game/global distinction: in global mode (`LowerCase(Key) = 'bgmod'`), `BackupsDir` points at `bgmod/backups/` which is fine — we still try to read, and skip restore when nothing is there.

## 2. Rewrite `SafeBackupFile` in `bgmod.lpr`

- [x] 2.1 Change the signature to `procedure SafeBackupFile(const GameDir, BackupsDir, DllFile: string);`. Body: if `FileExists(GameDir + DllFile)` AND `not FileExists(BackupsDir + DllFile)` AND `not FileExists(GameDir + 'goverlay.vars')` (first-install guard), then `CopyFile(GameDir + DllFile, BackupsDir + DllFile)` (use CopyFile, not Rename, so GameDir file stays in place for the subsequent SafeCopyFile overwrite) and log `Backed up original <DllFile> -> gameconfig backups/`. Otherwise log `Skipping backup of <DllFile> (already installed or no source)`.
- [x] 2.2 Update all `SafeBackupFile` call sites inside the install block (around bgmod.lpr lines 868-874) to pass `IncludeTrailingPathDelimiter(GameDir), BackupsDir, OrigDlls[i] / ProxyDlls[i]`.
- [x] 2.3 Remove the now-dead `SafeBackupFile`'s old `RenameFile` semantics — the original no longer leaves a `.b` in `GameDir`, so the subsequent Overwrite step in the install block can remain a plain `SafeCopyFile` and will replace the in-`GameDir` original.

## 3. Rewrite `SafeCleanOrRestore` in `bgmod.lpr` and `bgmod-uninstaller.lpr`

- [x] 3.1 In `bgmod.lpr`, change the signature to `procedure SafeCleanOrRestore(const TargetDir, BackupsDir, FileName: string; IsOriginalGameFile: Boolean);`. Body: if `FileExists(BackupsDir + FileName)` then copy `BackupsDir + FileName` to `TargetDir + FileName` (overwrite), delete `BackupsDir + FileName` slot, log `Restored original <FileName> from backups`. Else fall through to the existing `IsProxyDllName` + `IsGOverlayProxyFile` delete branch. Remove the `TargetDir + FileName + '.b'` lookup entirely.
- [x] 3.2 Apply the same rewrite in `bgmod-uninstaller.lpr` (same new signature, same body).
- [x] 3.3 Update all `SafeCleanOrRestore` call sites in `bgmod.lpr` (install block + disabled-cleanup block) and `bgmod-uninstaller.lpr` (the main uninstall block) to pass `BackupsDir` between `TargetDir` and `FileName`.

## 4. Delete legacy `<file>.b` breadcrumbs on first encounter

- [x] 4.1 In `bgmod.lpr`, before the install block backup loop, if `FileExists(GameDir + OrigDlls[i] + '.b')` then `DeleteFile(GameDir + OrigDlls[i] + '.b')` and log `Deleted legacy .b backup of <OrigDlls[i]>`. Do the same for each `ProxyDlls[i]` that was backed up in the old scheme. This is unconditional — we do not trust legacy `.b` files (per design Decision 6).
- [x] 4.2 In `bgmod-uninstaller.lpr`, before the restore loop, do the same cleanup of any leftover `<file>.b` in `GameDir` for all `OrigDlls` and `ProxyDlls`.

## 5. Update the disabled-cleanup block in `bgmod.lpr`

- [x] 5.1 In `bgmod.lpr`'s `else begin ... OptiScaler disabled ... end` block (around lines 940-1000), pass `BackupsDir` into every `SafeCleanOrRestore` call. The restore-from-backup branch runs first; if no backup exists, the proxy delete branch runs as today.

## 6. Spec/MAkefile + Build

- [x] 6.1 Build `bgmod.lpr` with `fpc -O3 bgmod.lpr` and confirm no compile errors.
- [x] 6.2 Build `bgmod-uninstaller.lpr` with `fpc -O3 bgmod-uninstaller.lpr` and confirm no compile errors.
- [x] 6.3 Copy fresh binaries into `data/bgmod/` over `data/bgmod/bgmod` and `data/bgmod/bgmod-uninstaller`.
- [x] 6.4 Build the full goverlay project (`lazbuild goverlay.lpi`) as a smoke test; no behavioral change in GOverlay binary itself expected.

## 7. Verification (manual)

- [ ] 7.1 **First install with original** — pick a game that ships a `dxgi.dll` (e.g. Cyberpunk 2077). Delete `gameconfig/<game>/` beforehand. Launch via `bgmod`. Confirm `gameconfig/<game>/backups/dxgi.dll` exists and is the original (compare size/md5 against Steam's untouched install). No `dxgi.dll.b` in `GameDir`.
- [ ] 7.2 **First install without original** — pick a game without a shipped `dxgi.dll` (God of War Ragnarok). Delete `gameconfig/<game>/`. Launch via `bgmod`. Confirm no `dxgi.dll` in `gameconfig/<game>/backups/` and no `.b` in `GameDir`. Game loads OptiScaler.
- [ ] 7.3 **Reinstall does not corrupt backup** — for the same GoW Ragnarok or Cyberpunk, run the install a second time (channel switch stable→edge via Update). Confirm `gameconfig/<game>/backups/` is *unchanged* (Cyberpunk still has the true original; GoW still empty) and that `GameDir/dxgi.dll` is now the edge proxy.
- [ ] 7.4 **Uninstall restores true original** — for Cyberpunk, click "Uninstall changes" in GUI. Confirm `GameDir/dxgi.dll` content matches the true original (compare md5 against `gameconfig/<game>/backups/dxgi.dll`), and that the game launches without `bgmod` and does NOT show OptiScaler.
- [ ] 7.5 **Uninstall deletes proxy when no backup** — for GoW Ragnarok, click Uninstall. Confirm `GameDir/dxgi.dll` is deleted, `gameconfig/<game>/backups/dxgi.dll` does not exist, and the game launched without `bgmod` does NOT show OptiScaler.
- [ ] 7.6 **Stale-recovery check** — for a game where the prior-bug `.b` was corrupted (proxy stable saved as `.b`), install the new bgmod, click Uninstall. Confirm the legacy `.b` is deleted (untrusted), the proxy is removed via the marker rule, and OptiScaler does not load. The user may need to "Verify integrity" once for the genuine original — that's expected.
- [ ] 7.7 **Global profile limitation** — verify in global mode (`~/.local/share/goverlay/bgmod/bgmod`) that no `BackupsDir` is created (per design) and proxy installs still proceed; uninstall falls through to delete-on-marker. Document a one-line note in the change if behavior differs.