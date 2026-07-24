## Context

In `games_tab.pas`, `ShowRemoveFoldersMenu` builds a `TPopupMenu` (`FRemoveFoldersMenu`) dynamically. In its previous implementation:
1. `RemoveParent := TMenuItem.Create(FRemoveFoldersMenu);` and `SubItem := TMenuItem.Create(FRemoveFoldersMenu);` passed `FRemoveFoldersMenu` as the Owner parameter.
2. When calling `FRemoveFoldersMenu.Items.Clear`, the LCL frees the items but leaves dangling references inside `FRemoveFoldersMenu`'s component list. Subsequent menu operations trigger a double-free SIGSEGV crash.
3. The menu structure forced a nested sub-menu (`RemoveParent.Caption := 'Remove game folders'`), adding an unnecessary hover layer.

## Goals / Non-Goals

**Goals:**
- Replace `TMenuItem.Create(FRemoveFoldersMenu)` with `TMenuItem.Create(nil)` (or `TMenuItem.Create(FForm)`) in `ShowRemoveFoldersMenu` so `Items.Clear` manages memory cleanly without dangling component owner references.
- Flatten the menu structure: list each folder directly in `FRemoveFoldersMenu.Items` with caption `Remove: <FolderPath>`.
- Parse folder path correctly in `RemoveFolderMenuItemClick` (handling prefix stripping if needed).
- Add `TestNonSteamRemoveFoldersMenu` unit test in `tests/gui/gui_test_cases.pas`.

**Non-Goals:**
- Changing Flatpak portal file picker implementation.

## Decisions

### Decision 1: Owner `nil` for Dynamic Menu Items
`TMenuItem.Create(nil)` ensures that `FRemoveFoldersMenu.Items.Clear` (which destroys child items in LCL) does not cause double-free errors on the parent `TPopupMenu` component.

### Decision 2: Direct Menu Item Formatting
Top-level menu items formatted as `Remove: /path/to/folder` make it immediately clear to users how to delete a folder without navigating submenus.
