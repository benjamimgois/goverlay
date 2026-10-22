# Proposal: Clone Global Configs to Games

## Why

Users configure detailed global settings (MangoHud metrics/colors, vkBasalt post-processing, vkSumi, OptiScaler parameters, and Tweaks) in Goverlay's global mode. When configuring individual games, users currently start with empty or unconfigured profiles, requiring tedious manual re-configuration across tabs for every game.

Issue #418 requested the ability to reuse global configurations for games. Adding a 1-click "Clone global configs" action in both the game card context menu (Games tab) and the floating action dock menu (game configuration mode) enables users to instantly seed or overwrite a game's profile with all current global configurations.

## What Changes

- Add **"Clone global configs"** option in the game card 3-dots popup menu (`FGameCardMenu`), positioned directly below "Open prefix folder".
  - If the target game has existing configurations/mods, prompt for confirmation before overwriting.
  - If the target game has no existing configurations/mods, clone immediately without confirmation.
  - Copies all global configuration files (`MangoHud.conf`, `vkBasalt.conf`, `vkSumi.conf`, `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`, `lsfg.toml`, `conf.toml`, `bgmod.conf`).
  - Rewrites `[Env] MANGOHUD_CONFIGFILE` inside the game's `bgmod.conf` to target the game's configuration directory rather than the global path.
  - Deploys OptiScaler binaries to the game directory if `GOVERLAY_OPTISCALER=1` in the cloned configuration.
  - Updates the game card's ribbon badges in-place and displays a notification without leaving the Games tab.
- Add **"Clone global configs"** option in the Floating Action Dock menu (`popsaveMenu`), visible only when a game is currently active (`FActiveGameName <> ''`).
  - Prompts for confirmation before overwriting the active game's configuration.
  - Clones all global configurations to the active game.
  - Dynamically reloads the active tab controls and sidebar toggle states (e.g. `LoadMangoHudConfig`, `LoadGameToggleStates`) so the interface updates immediately.

## Capabilities

### New Capabilities
- `clone-global-configs`: Ability to replicate all global tool configurations (MangoHud, vkBasalt, vkSumi, OptiScaler, Lossless Scaling, and Tweaks) to a specific game profile in 1 click from the game card menu or the floating dock menu.

### Modified Capabilities
*(None - no existing spec requirements are changed; this is an additive capability)*

## Impact

- `games_tab.pas`: `FGameCardMenu` construction, new `FCloneGlobalMenuItem` and click handler.
- `overlayunit.pas`: `popsaveMenu` popup handling, dock menu item visibility, UI reloading after clone.
- Shared logic: Cloning helper method to duplicate global config files, rewrite `MANGOHUD_CONFIGFILE`, deploy OptiScaler binaries if enabled, and handle confirmations.
- Automated GUI and logic test cases in `tests/gui/` and `tests/logic/`.
