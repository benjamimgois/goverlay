## 1. Include Blacklist in MangoHud Configuration Generation

- [x] 1.1 Update `SaveMangoHudConfigCore` in `overlay_config.pas` to read `~/.config/goverlay/blacklist.conf` and append `blacklist=app1,app2,...` to `ConfigLines`.
- [x] 1.2 Ensure default stock blacklist items are written if `blacklist.conf` does not exist yet.

## 2. Refactor Post-Save Blacklist Handling in Main Unit

- [x] 2.1 Refactor the blacklist saving logic in `overlayunit.pas` (`saveBitBtnClick`) to ensure existing `blacklist=` entries in configuration files are overwritten/updated rather than skipped.
- [x] 2.2 Verify both global (`~/.config/MangoHud/MangoHud.conf`) and per-game (`~/.config/goverlay/<game>/MangoHud.conf`) configuration files contain the updated blacklist after saving settings.

## 3. Verification

- [x] 3.1 Build GOverlay and test saving global settings to verify `blacklist=` is present in `~/.config/MangoHud/MangoHud.conf`.
- [x] 3.2 Test saving a per-game profile to verify `blacklist=` is present in `~/.config/goverlay/<game>/MangoHud.conf`.
