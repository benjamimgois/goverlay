## Context

Currently, global settings for GOverlay (when no specific game is active) are read and written directly to the directory returned by `GetBGModPath()` (`~/.local/share/goverlay/bgmod/`). This folder is also used to store default templates, pristine binaries, and update caches. Mixing user configuration with installer assets results in path leakage, replication bugs, and a lack of clean isolation between the global profile configuration and game-specific profiles.

## Goals / Non-Goals

**Goals:**
- Separate active user configuration for the global profile from pristine installation assets.
- Store the global profile configuration in `~/.local/share/goverlay/gameconfig/global/`.
- Maintain `~/.local/share/goverlay/bgmod/` purely as a template and pristine storage directory.
- Unify path resolution logic in GOverlay for reading/writing configuration files.

**Non-Goals:**
- Modifying how per-game configurations are structured or saved.
- Changing the layout of binaries/scripts stored in `~/.local/share/goverlay/bgmod/`.

## Decisions

1. **Unify Configuration Path Resolution under `GetGameConfigDir`**
   - Update `GetGameConfigDir` to support empty string (`''`) or `'global'` parameter values by returning the dedicated path `~/.local/share/goverlay/gameconfig/global/`.
   - Update all configuration read and write locations to use `GetGameConfigDir(GameName)` instead of conditionally branching to `GetBGModPath()` when the game name is empty.

2. **Pristine Assets template remains in `GetBGModPath()`**
   - Files copied to games (or global) when installing/updating will be copied from `GetBGModPath()` (the template/pristine source) to the target directory.

## Risks / Trade-offs

- **[Risk]** Existing users might lose their current global configuration.
  - *Mitigation:* On startup, if `~/.local/share/goverlay/gameconfig/global/bgmod.conf` does not exist but `~/.local/share/goverlay/bgmod/bgmod.conf` does, migrate the files (`bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`) to the new location.
