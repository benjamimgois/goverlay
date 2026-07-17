## Context

GOverlay manages multiple configurations for different overlays, supporting both a global configuration and game-specific configurations. When switching contexts, the file path variables (like `MANGOHUDCFGFILE`) are updated to point to the active configuration file. However, for MangoHud, the user interface controls are only loaded when entering the MangoHud tab if `FActiveGameName` is not empty (i.e. in game mode). When in global mode, entering the MangoHud tab does not trigger `LoadMangoHudConfig`, keeping the game-specific configuration values in the UI and leading to accidental overwriting of global configuration values.

## Goals / Non-Goals

**Goals:**
- Ensure MangoHud configuration is unconditionally loaded when entering the MangoHud tab, matching the behavior of vkBasalt, OptiScaler, and Tweaks.
- Prevent game-specific MangoHud settings from leaking into and overwriting global settings.

**Non-Goals:**
- Modifying how global vs game-specific configurations are stored or parsed.
- Changing the loading behavior of other tabs (vkBasalt, OptiScaler, Tweaks) which are already correct.

## Decisions

### Decision 1: Remove conditional guard in `mangohudLabelClick`

We will invoke `LoadMangoHudConfig` unconditionally when entering the MangoHud tab sheet, removing the `if FActiveGameName <> '' then` guard.

- **Option A (Chosen)**: Remove the condition and invoke `LoadMangoHudConfig` directly. This ensures that the UI controls are always synchronized with the active configuration file (`MANGOHUDCFGFILE`) whenever the tab is selected.
- **Option B**: Reload the configuration inside `gamesLabelClick` and `GamesEmptySpaceClick` when returning to global mode. However, this would perform a redundant UI load even if the user does not visit the MangoHud tab, and could load stale values if other actions occur.

## Risks / Trade-offs

- **[Risk] Unsaved changes discarded on tab click** → If a user is on the MangoHud tab, makes changes, and then clicks the MangoHud sidebar button again, their unsaved changes will be discarded as the config reloads.
  - **Mitigation**: This risk is acceptable as it matches the behavior of all other tabs (vkBasalt, OptiScaler, Tweaks) in GOverlay, providing consistency.
