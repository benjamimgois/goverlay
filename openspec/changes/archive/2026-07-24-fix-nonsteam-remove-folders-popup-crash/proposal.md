## Why

Clicking the 3-dots action button on the "Add non-Steam folder" card (Card Tag 9998) triggers a SIGSEGV / double-free crash when `ShowRemoveFoldersMenu` populates and clears dynamic `TMenuItem` instances owned by `FRemoveFoldersMenu`. Furthermore, the menu nests items inside a secondary sub-menu ("Remove game folders ▶"), confusing users and making it hard to find and remove folders that fail `DirectoryExists` checks (e.g. external NVMe mounts in Flatpak sandbox environments).

## What Changes

- Fix memory management in `ShowRemoveFoldersMenu` (`games_tab.pas`) by instantiating dynamic `TMenuItem` objects with `nil` owner (`TMenuItem.Create(nil)`), preventing LCL/Qt double-free crashes upon calling `FRemoveFoldersMenu.Items.Clear`.
- Simplify popup menu UX by listing non-Steam folders directly as top-level menu items with a clear "Remove: /path/to/folder" format instead of a nested sub-menu.
- Allow users to remove non-Steam folders from `nonsteam_folders.txt` even if the directory does not exist or is blocked by sandbox permissions.
- Add GUI automated unit test `TestNonSteamRemoveFoldersMenu` in `tests/gui/gui_test_cases.pas` to ensure crash-free execution and proper folder removal.

## Capabilities

### New Capabilities
- `fix-nonsteam-remove-folders-popup-crash`: Resolves SIGSEGV crash when opening the non-Steam folders removal menu and simplifies popup menu layout.

### Modified Capabilities

## Impact

- `games_tab.pas`: `ShowRemoveFoldersMenu` popup menu instantiation and item layout updated.
- `tests/gui/gui_test_cases.pas`: New test procedure `TestNonSteamRemoveFoldersMenu` added.
