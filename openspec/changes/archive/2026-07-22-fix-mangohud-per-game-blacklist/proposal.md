## Why

Currently, GOverlay saves blacklisted applications (`blacklist=...`) only into the global MangoHud configuration file (`~/.config/MangoHud/MangoHud.conf`). When running a game with a per-game GOverlay profile, GOverlay sets `MANGOHUD_CONFIGFILE` pointing directly to the game's specific `MangoHud.conf`.

Because MangoHud replaces (rather than merges) configuration when `MANGOHUD_CONFIGFILE` is used, the game-specific `MangoHud.conf` does not contain the `blacklist=` directive. As a result, MangoHud fails to filter blacklisted applications when games are executed under per-game profiles. Furthermore, updating the blacklist in GOverlay fails to update existing `blacklist=` lines if the key is already present.

## What Changes

- **Include Blacklist in Per-Game Configs**: Modify GOverlay's configuration saving logic (`SaveMangoHudConfigCore` in `overlay_config.pas`) to include the `blacklist=` line generated from `~/.config/goverlay/blacklist.conf` in all MangoHud configuration files (both global and game-specific).
- **Correct Blacklist Updating**: Ensure existing `blacklist=` entries in configuration files are overwritten/updated when saving settings, rather than skipped if the key exists.

## Capabilities

### New Capabilities
- `mangohud-per-game-blacklist`: Ensures `blacklist=` configuration is saved and applied across both global and per-game MangoHud configurations.

### Modified Capabilities
*(None)*

## Impact

- **Affected Code**: `overlay_config.pas` (in `SaveMangoHudConfigCore`), `overlayunit.pas` (in `saveBitBtnClick` / `SaveMangoHudConfig` workflow).
- **User Impact**: Blacklisted applications (like `zenity`, `protonplus`, `lsfg-vk-ui`, `gnome-calculator`, etc.) will now be properly hidden by MangoHud even when playing games configured with individual GOverlay profiles.
