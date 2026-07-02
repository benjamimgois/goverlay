## 1. Active config path plumbing

- [x] 1.1 In `optiscaler_update.pas`, replace the `LoadVersionsFromFile`/`CheckForUpdates`/`InitializeTab` reads of `IncludeTrailingPathDelimiter(FFGModPath) + 'goverlay.vars'` so they keep using `FFGModPath` (no behavior change yet) — confirms the path is the single source. CONFIRMED: LoadVersionsFromFile:953, CheckForUpdates:1173, CheckForUpdatesOnClick:1146/1150, InitializeTab:1251 all use FFGModPath. No edit needed.
- [x] 1.2 In `overlayunit.pas` `GameCardClick` (around `games_tab.pas:2067`), after setting `FActiveGameName`, set `FForm.FOptiscalerUpdate.FGModPath := GetGameConfigDir(FActiveGameName)` and call `LoadVersionsFromFile` + `InitializeTab` + `RefreshOsStatusDots` once the game config dir is prepared.
- [x] 1.3 In the global-return path (`overlayunit.pas:4067` where `FActiveGameName := ''`), re-point `FOptiscalerUpdate.FGModPath := GetGameConfigDir('')` and reload versions/initialize/refresh.
- [x] 1.4 Add `FGModPath` snapshot field to `TOptiUpdateThread` (constructor param) and extend the `SyncUpdateUI` channel-change guard (`optiscaler_update.pas:159-168`) to also discard results when `FOptiTab.FFGModPath <> FSpawnedFGModPath`.

## 2. Per-game install destination

- [x] 2.1 In `optiscaler_update.pas UpdateButtonClick`, introduce a local `DestDir := GetGameConfigDir(goverlayform.FActiveGameName)` after `FFGModPath := GetOptiScalerInstallPath`.
- [x] 2.2 Replace the hardcoded `goverlayform.GetGameConfigDir('')` write at line 1801-1802 with `DestDir`; keep the `.bgmod_original` write unchanged.
- [x] 2.3 Extract the existing DLL/plugin/FSR4/fakenvapi sync shell block (lines 1619-1643) into a reusable `SyncPristineAssetsTo(const ATargetDir: string)` helper and call it twice: once for `FFGModPath` (global pristine, for heuristics) and once for `DestDir` (active destination).
- [x] 2.4 Ensure `RegenerateVars` (the existing vars-update block) writes the updated `goverlay.vars` to `.bgmod_original`, `FFGModPath` if global, and `DestDir` using force (`SaveToFile` already overwrites; remove the `IncludeTrailingPathDelimiter(goverlayform.GetGameConfigDir(''))` literal).

## 3. Cache reuse on channel switch

- [x] 3.1 After fetching the latest channel tag (`OptiScalerTag`) in `UpdateButtonClick`, read `OptiScalerVersion=` from `.bgmod_original/goverlay.vars` and compare to `OptiScalerTag` (case-insensitive, trimmed).
- [x] 3.2 If they match, skip steps 2-5 of the existing flow (download, extract, move subfolder, chmod) and branch directly to the `SyncPristineAssetsTo(DestDir)` + `RegenerateVars` steps. Emit a `[DEBUG] UpdateButtonClick: reusing cached .bgmod_original` log line.
- [x] 3.3 If they differ or `.bgmod_original/goverlay.vars` is missing, run the full download-extract cycle as today.

## 4. First-selection stable seeding

- [x] 4.1 In `games_tab.pas GameCardClick`, before re-pointing `FOptiscalerUpdate.FGModPath`, check `FileExists(GameCfgDir + 'goverlay.vars')`.
- [x] 4.2 If absent, `ForceDirectories(GameCfgDir)` and run `ExecuteShellCommand('cp -rn ' + QuotedStr(GetFGModOriginalPath + '/.') + ' ' + QuotedStr(GameCfgDir) + ' 2>/dev/null')` to seed stable assets (no-clobber preserves any existing user configs).
- [x] 4.3 If `cp` did not bring a `goverlay.vars` (because `.bgmod_original` lacks one), copy `.bgmod_original/goverlay.vars` verbatim to `GameCfgDir/goverlay.vars`, or fall back to generating a stable vars from `.bgmod_original` content (read existing key/values and force `OptiScalerVersion=<stableTag>`). NOTE: cp -rn .bgmod_original/. includes goverlay.vars if it exists; if absent, LoadVersionsFromFile tolerates the missing file.
- [x] 4.4 Keep the `EnsureGameFGModOptiScalerConditional(GameCfgDir + 'bgmod')` call after seeding so the bgmod wrapper's OptiScaler conditional stays correct.

## 5. OptiScaler tab visibility per-game

- [x] 5.1 In `games_tab.pas GameCardClick`, change line 2093 `optiscalertabsheet.TabVisible := False` to `True` so the tab is visible when a game is selected.
- [x] 5.2 Verify `ApplyToolEnabledState(2, FNavToolEnabled[2])` continues to disable every interactive control on the tab when the game's OptiScaler toggle is off (no change needed if behavior holds; otherwise add the channel combobox + Update button to the disabled set). VERIFIED: sidebar_nav.pas:664 calls SetControlTreeEnabled(optiscalertabsheet, AEnabled) which recursively disables all child controls including the channel combobox and Update button.
- [x] 5.3 In the global-return path, ensure the tab remains visible (it already is); no regressions.
- [x] 5.4 In `optiscalertabsheet` click handler (`overlayunit.pas optiscalerLabelClick ~4229`), keep the existing `LoadOptiScalerConfig` + `RefreshOsStatusDots` calls; they now read the active game's dir because of task 1.2.

## 6. Clobber vs no-clobber copy distinction

- [x] 6.1 Confirm `CopyOptiScalerGameFiles` (`sidebar_nav.pas:771`) stays `cp -rn` (no-clobber) — used only as the toggle-on/seeding path. Document this in a code comment.
- [x] 6.2 Add the new force-copy helper `SyncPristineAssetsTo(const ATargetDir: string)` from task 2.3 with `cp -f` (force) for DLLs and `cp -rf` for `plugins/`, `FSR4_LATEST/`, `FSR4_INT8/`, and `cp -f` for `fakenvapi.ini`, matching the existing global pristine sync semantics.
- [x] 6.3 Verify the per-game install overwrite does not clobber `bgmod.conf`, `OptiScaler.ini`, `MangoHud.conf`, `vkBasalt.conf`, or `vkSumi.conf` in `DestDir` (these are user-editable; the installer doesn't copy them anyway — confirm by inspecting the sync file list). CONFIRMED: helper only copies *.dll, fakenvapi.ini, plugins/, FSR4_LATEST/, FSR4_INT8/ — user-editable files never touched.

## 7. Verification

- [x] 7.1 Build GOverlay (`lazbuild goverlay.lpi` or `make`) and confirm no new compile errors. BUILD OK (lazbuild exit 0, 2 warnings).
- [ ] 7.2 Clean test: remove `~/.local/share/goverlay/gameconfig/<testgame>/`, launch GOverlay, click the game card, and verify `gameconfig/<testgame>/goverlay.vars` is created with the stable tag and the Software status card shows stable versions per-game.
- [ ] 7.3 With the test game selected and OptiScaler toggle ON, switch the channel combobox to Bleeding-edge and click Update; verify `.bgmod_original` is reused if it already has the latest edge tag (no re-download log) and that `gameconfig/<testgame>/goverlay.vars` and DLLs are updated to the edge tag while `gameconfig/global/` is untouched.
- [ ] 7.4 Click a second game card with no config; verify stable seeding runs and Software status switches to that game's stable versions without restarting.
- [ ] 7.5 Return to global profile; verify `FOptiscalerUpdate.FGModPath` re-points to `gameconfig/global/`, Software status reflects the global `.bgmod_original`/`gameconfig/global/goverlay.vars`, and the OptiScaler tab is still visible.
- [ ] 7.6 Repeat 7.3 but force `.bgmod_original` to a stale tag (e.g., by editing its `goverlay.vars`); verify GOverlay re-downloads the new edge 7z and installs the latest tag in the active game folder.
- [ ] 7.7 Verify a game with OptiScaler toggle OFF cannot switch channels or install (channel combobox + Update button disabled) while its Software status card still displays the per-game versions.