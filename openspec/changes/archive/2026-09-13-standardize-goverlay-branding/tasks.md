## 1. Splash Screen and Core UI Strings

- [x] 1.1 Update `bgmod_splash_src/splash_form.pas` title label caption from `'GOverlay'` to `'Goverlay'` and verify compilation of `bgmod-splash`
- [x] 1.2 Update `overlayunit.pas` desktop notification call from `'GOverlay'` to `'Goverlay'` and verify clean compilation
- [x] 1.3 Update user-facing resource strings in `goverlay_strings.pas` (`rsClearConfigPrompt`, `rsGameModeFlatpakPrompt`, `rsSteamShortcutFlatpakInfo`, etc.) from `'GOverlay'` to `'Goverlay'`
- [x] 1.4 Update tooltips and dialog texts in `hintsunit.pas`, `optiscaler_tab.pas`, `lsfg_migration_dialog.pas`, `changelogunit.pas`, and `pascube_src/src/UnitPasCubeScreen.pas`

## 2. Games Tab and GUI Test Assertions

- [x] 2.1 Update tooltips and hint check in `games_tab.pas` from `Enabled GOverlay Tools:` to `Enabled Goverlay Tools:`
- [x] 2.2 Update GUI test assertion in `tests/gui/gui_test_cases.pas` line 5172 to check for `Enabled Goverlay Tools:`

## 3. Steam Shortcut Integration

- [x] 3.1 Update `assets/goverlay-steam-shortcut.py` to set `AppName: 'Goverlay'` and match both `'Goverlay'` and `'GOverlay'` in the cleanup filter
- [x] 3.2 Verify `assets/goverlay-steam-shortcut.py` syntax and test shortcut matching logic

## 4. Documentation and Packaging Metadata

- [x] 4.1 Update user-facing references to "Goverlay" in `README.md` and `CONTRIBUTING.md`
- [x] 4.2 Update manpage `data/goverlay.1` and AppStream metainfo `data/io.github.benjamimgois.goverlay.metainfo.xml`
- [x] 4.3 Update packaging metadata in `packaging/deb/control` and `packaging/rpm/goverlay.spec`
- [x] 4.4 Update GitHub issue templates and workflow titles in `.github/`

## 5. Build and Test Verification

- [x] 5.1 Build full application binary (`goverlay`) and `bgmod-splash` and verify zero compilation errors
- [x] 5.2 Execute test suites (`tests/run_tests.sh` and `tests/gui/run_gui_tests.sh`) and verify all tests pass
