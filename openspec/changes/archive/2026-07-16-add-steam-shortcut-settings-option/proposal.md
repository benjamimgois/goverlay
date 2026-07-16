## Why

Adding a "Create Steam shortcut" option makes GOverlay accessible from Steam's Gaming Mode or Big Picture Mode. This is highly useful for handhelds (like Steam Deck) and TV setups where switching to the desktop mode is inconvenient.

## What Changes

- Add a "Create Steam shortcut" menu item to the sidebar settings menu.
- Create a python script `goverlay-steam-shortcut.py` that finds and updates Steam's binary `shortcuts.vdf` file for all local Steam users.
- Add support for detecting if Steam is running and warn the user.
- Handle Flatpak environment differences by using correct flatpak run command/icon configuration when running inside flatpak.

## Capabilities

### New Capabilities
- `steam-shortcut-settings`: An option inside the settings menu to add or remove a GOverlay shortcut within Steam's local userdata configurations.

### Modified Capabilities

## Impact

- `sidebar_nav.pas`: Injects the new menu item and trigger logic in the settings popup menu.
- `overlayunit.pas`: Handles execution of the helper python script.
- `Makefile`: Copies the new python helper script to the assets directory so it gets installed correctly.
