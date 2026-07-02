## 1. Rewrite `IsGOverlayProxyFile` in `bgmod-uninstaller.lpr`

- [x] 1.1 In `bgmod-uninstaller.lpr`, replace the body of `IsGOverlayProxyFile(TargetDir, FileName: string): Boolean` so it returns `True` when `IsProxyDllName(FileName)` is true AND `FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars')` is true; otherwise return `False`. Remove the `GetFileSize`-based comparisons against `BgmodPath + 'renames/' + FileName`, `BgmodPath + 'OptiScaler.dll'`, the flatpak global path variants, and the `TargetSize` lookup.
- [x] 1.2 Remove now-unused locals in `IsGOverlayProxyFile` (`TargetFile`, `TargetSize`, `BgmodPath`, `GlobalPath`) and keep only what's needed for the marker check. Keep `GetFileSize` declared in the unit (it is still used elsewhere if present, otherwise delete the helper if it becomes orphaned). Removed GetFileSize too (orphaned after rewrite).
- [x] 1.3 Verify `IsProxyDllName` is reachable from `IsGOverlayProxyFile` (it already is — both are forward-declared in the same `bgmod-uninstaller.lpr`). Added forward declaration.

## 2. Rewrite `IsGOverlayProxyFile` in `bgmod.lpr`

- [x] 2.1 In `bgmod.lpr`, apply the same rewrite to `IsGOverlayProxyFile`: return `True` iff `IsProxyDllName(FileName)` AND `FileExists(IncludeTrailingPathDelimiter(TargetDir) + 'goverlay.vars')`. Remove the `GetFileSize` size comparisons against `BgmodPath + 'renames/' + FileName` and `BgmodPath + 'OptiScaler.dll'` (and the flatpak global path block).
- [x] 2.2 Audit `NeedsLocalUpdate` and any other callers of `GetFileSize` in `bgmod.lpr`: keep `GetFileSize` declared only if still used by other code; otherwise remove the now-orphaned helper. Confirmed orphaned (only IsGOverlayProxyFile used it; NeedsLocalUpdate uses its own goverlay.vars text comparison). Removed.

## 3. Preserve `SafeCleanOrRestore` semantics

- [x] 3.1 Verify `SafeCleanOrRestore` still walks its branches in the original order: (a) restore `.b` backup if present; (b) skip deletion when `IsOriginalGameFile` is true and no `.b` exists; (c) for proxy DLLs (`IsProxyDllName` true), call `IsGOverlayProxyFile` and delete only if it returns true, otherwise log "Skipping deletion of third-party proxy DLL". The only behavior change is inside `IsGOverlayProxyFile` — no `SafeCleanOrRestore` body edits required. CONFIRMED in both files; no edits needed.

## 4. Build and ship updated binaries

- [x] 4.1 Build `bgmod.lpr` with `lazbuild bgmod.lpr` (or `fpc` if that is the project's build front-end) and confirm no compile errors or new warnings. Built with fpc -O3; 0 errors (1 pre-existing note about unused local).
- [x] 4.2 Build `bgmod-uninstaller.lpr` with `lazbuild bgmod-uninstaller.lpr` and confirm no compile errors or new warnings. Built with fpc -O3; 0 errors.
- [x] 4.3 Copy the freshly built `bgmod` and `bgmod-uninstaller` binaries over `data/bgmod/bgmod` and `data/bgmod/bgmod-uninstaller` so the Makefile / packaging step picks up the fixed wrappers. Copied.
- [x] 4.4 Build the full goverlay project (`lazbuild goverlay.lpi`) and confirm it still compiles; the GOverlay binary itself does not call `IsGOverlayProxyFile`, so no behavioral change is expected here — this is a smoke test only. Build OK (exit 0).

## 5. Verification

- [ ] 5.1 **Bleeding-edge uninstall test:** with a test game that has OptiScaler installed via the bleeding-edge channel (proxy DLL in `GameDir` came from `gameconfig/<game>/renames/`), click "Uninstall changes" in the GOverlay GUI and confirm the proxy DLL (`dxgi.dll` or whichever name was configured) is removed from `GameDir`. Launch the game without `bgmod` and confirm OptiScaler is NOT loaded.
- [ ] 5.2 **Stable uninstall regression:** with a test game installed via the stable channel, click Uninstall and confirm the proxy DLL is still removed (no regression — the `goverlay.vars` marker is present for stable installs too).
- [ ] 5.3 **Launch-wrapper disabled-cleanup test:** with a game that was installed with bleeding-edge, set `GOVERLAY_OPTISCALER=0` in `gameconfig/<game>/bgmod.conf`, launch the game via `bgmod`, and confirm the proxy DLL is cleaned up from `GameDir` before the game starts (so the game does not load OptiScaler).
- [ ] 5.4 **Third-party preserve test:** place a `dxgi.dll` from ReShade (or any third-party proxy DLL with a size different from GOverlay's) in a `GameDir` that does NOT contain `goverlay.vars`, run the GOverlay uninstaller on that game, and confirm the third-party `dxgi.dll` is preserved.
- [ ] 5.5 **Restore-from-backup test:** with a game that has a `dxgi.dll.b` backup from a previous stable install, run the uninstaller and confirm the original `dxgi.dll` is restored (the `.b` path is unchanged and runs before the marker check).
- [ ] 5.6 **Stale-leftover recovery test:** on a game directory where a previous (buggy) uninstall left a bleeding-edge proxy DLL behind while `goverlay.vars` is still present, run the uninstaller again and confirm the leftover DLL is now removed.

## 6. Consolidate GUI uninstall to invoke bgmod-uninstaller binary

The GUI `GameCardUninstallClick` (games_tab.pas) currently re-implements the bgmod-uninstaller cleanup in an inline `RunFGModUninstallCommands` procedure (~200 lines duplicating SafeCleanOrRestore and the file list). This bypasses the marker-based fix from tasks 1-2 and is the actual code path exercised by the "Uninstall changes" menu action. Consolidate so the GUI invokes the same `bgmod-uninstaller` binary that the bgmod launcher writes into the game folder, ensuring a single source of truth for cleanup behavior.

- [x] 6.1 In `games_tab.pas GameCardUninstallClick`, replace the `RunFGModUninstallCommands(TargetDirs[j], GameName)` call with an invocation of the `bgmod-uninstaller` binary via `TProcess`, pointed at each `TargetDirs[j]` by setting the `STEAM_COMPAT_INSTALL_PATH` environment variable to that directory. Used ExecuteShellCommand with `STEAM_COMPAT_INSTALL_PATH='<dir>' '<binario>' --` form (binary resolves dir via that env var fallback). Binary located via GetBGModPath, fallback GetFGModOriginalPath.
- [x] 6.2 Delete the inline `RunFGModUninstallCommands` procedure body and its declaration in `TGamesTabHelper` (games_tab.pas). Also removed the delegator `Tgoverlayform.RunFGModUninstallCommands` and its declaration in overlayunit.pas.
- [x] 6.3 Keep the existing `FindAllFiles(GamePath, 'goverlay.vars;OptiScaler.dll;OptiScaler.ini;bgmod-uninstaller*;fgmod-uninstaller*', True)` tree walk — it still produces the list of TargetDirs that need cleanup; the only change is that each dir is now cleaned by the binary instead of the inline copy. Tree walk intact.
- [x] 6.4 Build the full goverlay project (`lazbuild goverlay.lpi`) and confirm no compile errors / no unresolved references to `RunFGModUninstallCommands`. Build OK (exit 0, 2 warnings).