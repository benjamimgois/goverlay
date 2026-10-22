## Why

Users frequently need to view, inspect, or manage configuration and log files directly in their desktop environment's default file manager. Previously, the hamburger menu provided "Open config file" and "Open log file" which attempted to open specific files directly in an editor, which could be cumbersome or fail when multiple files or structured directories are involved. Changing these menu actions to "Open config folder" and "Open log folder" opens the respective directory with `xdg-open` in the default file manager, and ensures consistent menu ordering and folder icons.

## What Changes

- Change hamburger menu items:
  - "Open config file" / "Config folder" -> "Open config folder" (with folder icon `ImageIndex = 24`)
  - "Open log file" / "Log folder" -> "Open log folder" (with folder icon `ImageIndex = 24`)
- Clicking "Open config folder" opens the active game (or global) configuration directory in the default file manager using `xdg-open`.
- Clicking "Open log folder" opens the active game (or global) log directory in the default file manager using `xdg-open`.
- Ensure menu item ordering in `popsaveMenu`:
  - 1st: "Save options" (when present)
  - 2nd: "Load config" (when present)
  - 3rd: "Open config folder"
  - 4th: "Open log folder"
  - In tabs where Save options and Load config are hidden (OptiScaler, Lossless Scaling, Tweaks), "Open config folder" and "Open log folder" appear at the top.
- Update GUI test suite assertions to verify updated captions, icons, and menu ordering.

## Capabilities

### Modified Capabilities
<!-- None -->

## Impact

- `overlayunit.pas`: Update `openConfigFileMenuItemClick` and `openLogFileMenuItemClick` to resolve directories and launch `xdg-open <dir> &`. Update captions in `FormCreate` and `popupBitBtnClick`.
- `overlayunit.lfm`: Update menu ordering, captions, and `ImageIndex = 24` for `openConfigFileMenuItem` and `openLogFileMenuItem`.
- `overlayunit.lrj`, `languages/goverlay.pot`, `languages/goverlay.ru.po`: Synchronize resource strings and localization catalogues.
- `tests/gui/gui_test_cases.pas`: Update assertions in `TestDockOpenConfigFileAction`.
