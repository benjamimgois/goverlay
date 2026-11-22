# Proposal

## Why

When editing or auto-saving MangoHud settings for a specific game (e.g., `Fatekeeper`), Goverlay unconditionally overwrites the Steam Flatpak global configuration (`~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf`) with the game-specific `MangoHud.conf`, leaking game-specific paths such as `output_folder=/home/<user>/.local/share/goverlay/logs/<Game>/` into the global Flatpak config and making global MangoHud settings appear reset. In addition, returning from a game profile to global mode (`gamesLabelClick` / `GamesEmptySpaceClick`) leaves `autoSaveTimer` uncancelled and MangoHud UI controls stale until the MangoHud tab is reopened, which can persist the previous game's UI state into global `MangoHud.conf` if saved beforehand.

## What Changes

- Guard Steam Flatpak `MangoHud.conf` mirroring in `SaveMangoHudConfigCore` (both standard save and `fps_only` shortcut) with `Settings.ActiveGameName = ''` so per-game saves never overwrite the global Steam Flatpak config.
- Cancel any pending `autoSaveTimer` and synchronize/reload MangoHud UI state when switching profile contexts between game-specific mode and global mode (`GameCardClick`, `gamesLabelClick`, `GamesEmptySpaceClick`) so stale game controls (such as `logfolderEdit.Text`) cannot leak into global `MangoHud.conf`.
- Add regression tests covering per-game save isolation from Steam Flatpak global config and profile-switch `autoSaveTimer`/UI synchronization.

## Capabilities

### New Capabilities
- `mangohud-global-flatpak-isolation`: Isolates global MangoHud mirror targets (including Steam Flatpak `~/.var/app/com.valvesoftware.Steam/config/MangoHud/MangoHud.conf`) from per-game configuration writes.

### Modified Capabilities
- `config-persistence-and-tool-toggling`: Extend profile context synchronization (`FActiveGameName` transitions) to cover MangoHud UI state and pending `autoSaveTimer` cancellation/flush alongside other singleton tab helpers.

## Impact

- `overlay_config.pas`: `SaveMangoHudConfigCore` (standard save and `fps_only` branch).
- `overlayunit.pas`: `gamesLabelClick` and `autoSaveTimer` lifecycle on context transitions.
- `games_tab.pas`: `GameCardClick` and `GamesEmptySpaceClick` context transitions.
- `tests/logic/` and `tests/gui/`: Unit and GUI regression tests for Flatpak global isolation and profile-switch state synchronization.
