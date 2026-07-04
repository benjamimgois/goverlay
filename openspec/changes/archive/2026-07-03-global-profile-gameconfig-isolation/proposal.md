## Why

Adjustments made to the global profile are currently stored directly in the `~/.local/share/goverlay/bgmod/` directory. This creates logic leakage and replication issues between game-specific and global configurations, making maintenance difficult. Treating the global profile like a game and isolating its configuration to a dedicated `~/.local/share/goverlay/gameconfig/global/` folder simplifies path resolution and keeps settings completely isolated.

## What Changes

- Treat the global profile configuration as if it were a game with the identifier `global`.
- Store all global profile configuration files (`bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`, etc.) in `~/.local/share/goverlay/gameconfig/global/` instead of directly in `~/.local/share/goverlay/bgmod/`.
- Restrict `~/.local/share/goverlay/bgmod/` to serve solely as the pristine/default repository template for binaries, default scripts, and fallback files.
- Simplify configuration file path generation across the codebase by unifying global and game-specific directory lookups under `GetGameConfigDir`.

## Capabilities

### New Capabilities

*None.*

### Modified Capabilities

- `bgmod-update-optiscaler`: Modify the configuration paths to use `gameconfig/global/` for global profile settings instead of writing directly to `bgmod/`.

## Impact

- **Affected files**: `bgmod_resources.pas`, `games_tab.pas`, `optiscaler_update.pas`, `tweaks_md3.pas`, `overlay_config.pas`, `sidebar_nav.pas`, `overlayunit.pas`.
- **APIs & Paths**: Unifies config folder path resolution for both the global profile and individual games.
