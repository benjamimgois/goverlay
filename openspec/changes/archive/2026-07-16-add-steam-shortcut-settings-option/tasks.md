## 1. Helper Script Creation

- [x] 1.1 Create `assets/goverlay-steam-shortcut.py` implementing VDF binary parsing, AppID calculation, and serialization.
- [x] 1.2 Add logic to detect Flatpak environment (`/.flatpak-info` / `FLATPAK_ID`) and format shortcut arguments accordingly.
- [x] 1.3 Add logic to check for active `steam` process and report warnings.

## 2. Interface and Event Logic

- [x] 2.1 Register and initialize the "Create Steam shortcut" menu item `FCreateSteamShortcutItem` with Steam icon inside `sidebar_nav.pas`'s `BuildSettingsButton`.
- [x] 2.2 Define `CreateSteamShortcutMenuItemClick` handler in `overlayunit.pas` to invoke the helper script using `TProcess`.
- [x] 2.3 Handle showing the Steam active warning and success/error status messages inside `CreateSteamShortcutMenuItemClick`.

## 3. Build Integration and Verification

- [x] 3.1 Verify that the Makefile packages the python script under target assets path.
- [x] 3.2 Test shortcut creation natively and inside flatpak builds to ensure `shortcuts.vdf` is updated successfully.
