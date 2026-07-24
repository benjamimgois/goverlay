## 1. Fix Popup Menu Crash & Menu Layout

- [x] 1.1 In `games_tab.pas` `ShowRemoveFoldersMenu`, update `TMenuItem.Create` to use `nil` as owner (`TMenuItem.Create(nil)`) to prevent double-free LCL crashes on `Items.Clear`.
- [x] 1.2 In `games_tab.pas` `ShowRemoveFoldersMenu`, remove the nested `RemoveParent` sub-menu and add items directly to `FRemoveFoldersMenu.Items` with caption `Remove: <FolderPath>`.
- [x] 1.3 In `games_tab.pas` `RemoveFolderMenuItemClick`, update caption parsing to strip the `Remove: ` prefix and resolve the target folder path cleanly.

## 2. Test Automation

- [x] 2.1 In `tests/gui/gui_test_cases.pas`, add `TestNonSteamRemoveFoldersMenu` to verify `ShowRemoveFoldersMenu` runs without crashing and `RemoveFolderMenuItemClick` removes the path from `nonsteam_folders.txt`.

## 3. Verification

- [x] 3.1 Run `make test` to verify all unit and GUI tests pass cleanly.
