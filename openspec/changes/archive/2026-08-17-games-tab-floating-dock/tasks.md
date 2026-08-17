## 1. Floating Action Dock Enhancements

- [x] 1.1 Update `TFloatingActionDock` in `floating_dock.pas` to support optional Finish button (`AShowFinish`) and customizable Add button label (`FAddCaption`).
- [x] 1.2 Update `LayoutButtons` and `AddPaint` in `floating_dock.pas` to dynamically adapt pill width and render custom button caption.

## 2. Games Tab Clean-Up & Dock Integration

- [x] 2.1 In `games_tab.pas`, remove the dummy "Add game folder" card panel and 3-dot action panel generation from the game grid.
- [x] 2.2 In `overlayunit.pas`, configure `FFADock.UpdateForTab` on `gamesTabSheet` to display `[ ☰ ] [ + Add Folder ]` without the Finish button.
- [x] 2.3 In `overlayunit.pas`, wire `DockAddClick` on the Games tab to trigger non-Steam folder selection.

## 3. Hamburger Menu Management

- [x] 3.1 In `overlayunit.pas` and `games_tab.pas`, implement the contextual Games tab popup menu with "Add game folder...", "Remove game folder ▸" sub-menu, and "Refresh game library".
- [x] 3.2 Wire `DockMenuClick` to display the Games tab menu when on `gamesTabSheet`.

## 4. Verification & Testing

- [x] 4.1 Build the application using `lazbuild` to verify clean compilation.
- [x] 4.2 Update GUI test suite in `tests/gui/gui_test_cases.pas` to verify Games tab floating dock, button captions, and menu actions.
- [x] 4.3 Run full test suites (`./tests/logic/logic_tests` and `./tests/gui/gui_tests`) to confirm 100% pass rate.
