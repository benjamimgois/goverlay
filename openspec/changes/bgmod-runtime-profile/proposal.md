# Proposal

## Why

Upstream issue #466. bgmod picks its profile from the path of the binary it was started from: `gameconfig/global/bgmod` loads the global profile, `gameconfig/<Game>/bgmod` loads that game's profile. Every game with its own profile therefore needs its own launch option, and switching a game between global and game-specific settings means editing the launch options in Steam, Heroic or Lutris every time. Renames or a different name sanitisation break the link between profile and launch option.

## What Changes

- bgmod started from the global location (`gameconfig/global/bgmod` or the legacy `bgmod/bgmod`) resolves the game directory first and then looks for a game profile whose recorded game path contains that directory. If one exists, bgmod loads that profile; otherwise it loads the global profile. The same rule applies to Steam, Heroic and Lutris (and every other launcher), because it only depends on the game directory bgmod already resolves for installing its files.
- New checkable "Use game-specific settings" item in the game card context menu. It writes a small identity file (`goverlay-profile.conf`) into the profile folder with the game's install path and `ENABLED=1/0`. Turning it on for a game without settings clones the global configuration first; "Clone global configs" turns it on as well.
- Existing profiles without an identity file are matched via the `GAME_DIR` bgmod has already cached in their `bgmod.conf` (only written when the game was launched with its per-game bgmod), so they work without opening GOverlay first. Switching the toggle off overrides that.
- A bgmod started from a per-game copy keeps using that profile (explicit path wins). Existing setups keep working.
- New setting "Automatic game profile selection" in the settings menu (default on), stored as `RUNTIME_PROFILE` in the global `bgmod.conf`. When off, bgmod behaves as before.
- When the setting is on, GOverlay shows the generic global launch command for every game.
- bgmod logs which profile it picked and why.

## Capabilities

### New Capabilities
- `bgmod-runtime-profile`: runtime selection of the bgmod profile by game directory.

### Modified Capabilities
<!-- None -->

## Impact

- `bgmod.lpr`: profile resolution before reading `bgmod.conf`, profile directory variable for config files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `plugins/`).
- `overlay_config.pas`, `configkeys.pas`: identity file helpers and keys.
- `games_tab.pas`: context menu toggle, identity on clone, keep the recorded path current on card selection.
- `overlayunit.pas`, `sidebar_nav.pas`: setting toggle, launch command.
- `tests/logic`, `tests/gui`: end-to-end bgmod tests for the resolution, GUI tests for the settings, toggle and launch command.
- Behaviour change: a game with a per-game launch option keeps working unchanged; a game launched with the global command now uses its own profile when "Use game-specific settings" is on, or when it has an older profile that bgmod cached a `GAME_DIR` for. Documented, and can be turned off globally.
