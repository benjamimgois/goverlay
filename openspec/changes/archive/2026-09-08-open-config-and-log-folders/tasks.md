## 1. Menu Items & Ordering

- [x] 1.1 Reorder `popsaveMenu` in `overlayunit.lfm` so Save options and Load config appear before Open config folder and Open log folder.
- [x] 1.2 Update menu captions to "Open config folder" and "Open log folder" with folder icon (`ImageIndex = 24`).
- [x] 1.3 Update `overlayunit.pas` (`FormCreate` and `popupBitBtnClick`) to explicitly set the captions.

## 2. Directory Opening Logic

- [x] 2.1 Update `openConfigFileMenuItemClick` to open the configuration directory with `xdg-open`.
- [x] 2.2 Update `openLogFileMenuItemClick` to open the game log directory with `xdg-open`.

## 3. Localization & Testing

- [x] 3.1 Update `.lrj` and `.po`/`.pot` catalogs.
- [x] 3.2 Update `tests/gui/gui_test_cases.pas` assertions and verify test suite passes cleanly.
