## Why

Currently, the Finish Configuration dialog provides dedicated tabs and animated guidance for Steam (launch options with `%command%`) and Heroic Games Launcher (wrapper command without `%command%`). Linux gamers frequently use Lutris to manage their games, requiring them to manually figure out how to configure GOverlay's `bgmod` wrapper in Lutris. Adding a dedicated Lutris tab with visual instructions and the correct command format simplifies the setup experience for Lutris users.

## What Changes

- Add a Lutris platform option (`fpLutris`) and switcher button (`FLutrisBtn`) to `TFinishDialogForm`.
- Provide the generated launch command in Lutris's required format (unquoted path without `%command%`, identical to Heroic's wrapper command).
- Add procedural canvas animation (`PaintAnimLutris`) matching Lutris's GTK4/Libadwaita interface (System options tab › Game execution group › Command prefix field with pulsating highlight, cursor, and guide arrow).
- Display step-by-step instructions guiding users to right-click their game in Lutris › Configure › System options tab (enabling Advanced if needed) › paste into Command prefix and save.
- Preserve Heroic as the default selection for non-Steam games and Steam for standard games, with Lutris accessible via the platform switcher.
- Add automated GUI test coverage for Lutris tab switching, command output, step instructions, and canvas painting.

## Capabilities

### New Capabilities
- `finish-dialog-lutris-tab`: Dedicated Lutris tab, command generation, and animated visual guidance in the Finish Configuration dialog.

### Modified Capabilities

## Impact

- `finish_dialog.pas`: UI layout, platform switcher, command formatting, platform update logic, and custom canvas drawing.
- `tests/gui/gui_test_cases.pas`: GUI test cases verifying the Lutris tab interactions and painting.
