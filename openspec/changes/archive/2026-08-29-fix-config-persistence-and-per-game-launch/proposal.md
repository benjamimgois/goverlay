## Why

Users have reported (Issue #405) that disabling tools (MangoHud, vkBasalt, OptiScaler, Tweaks/EnvVars) globally or per game in GOverlay leads to unintended configuration loss and resets to default settings across launches. Currently, toggling a tool off deletes its configuration files (MangoHud.conf, vkBasalt.conf, OptiScaler.ini) and wipes [Env] keys in bgmod.conf, destroying user configurations instead of just deactivating them via bgmod.conf flags (GOVERLAY_MANGOHUD=0, etc.).
Additionally, selecting a game card on the Games tab does not immediately update the cached FLaunchCommand, causing the [✓ Finish] modal to show global instead of the selected game name unless an option is modified first.

## What Changes

- **Preserve User Configurations on Tool Toggle-Off**:
  - In sidebar_nav.pas (NavToolToggleClick), toggle-off for MangoHud, vkBasalt, vkSumi, and Tweaks must strictly update GOVERLAY_*=0 in bgmod.conf without deleting configuration files (MangoHud.conf, vkBasalt.conf, vkSumi.conf) or clearing [Env] variables.
  - For OptiScaler/DLSS Enabler, toggle-off preserves OptiScaler.ini in GOverlay's profile directory (gameconfig/) so user preferences are remembered, while ensuring that the game's actual installation directory is cleaned up and original DLL backups are restored.
- **Immediate Per-Game Launch Command Synchronization**:
  - In games_tab.pas (GameCardClick), immediately invoke FLaunchCommand := GetLaunchCommand; upon selecting a game, ensuring that [✓ Finish] and other dialogs display the proper per-game command immediately.
- **Initialization Protection for Global Configs**:
  - In bgmod_resources.pas (InitializeGlobalConfigDirectory), ensure the startup sync does not overwrite existing .conf or .ini files in gameconfig/global/.
- **Form Close and Auto-Save Guarding**:
  - Guard GenericControlClick and GenericControlChange against firing during application shutdown (FClosing).

## Capabilities

### New Capabilities
- `config-persistence-and-tool-toggling`: Covers non-destructive toggling of overlay tools, ensuring user configs (MangoHud.conf, vkBasalt.conf, OptiScaler.ini, bgmod.conf [Env]) persist across tool disable/enable cycles and application restarts while honoring the GOVERLAY_* flags.
- `per-game-launch-options`: Covers immediate synchronization and generation of per-game launch commands upon game card selection in the UI.

### Modified Capabilities
<!-- None -->

## Impact

- sidebar_nav.pas: NavToolToggleClick, RemoveTweaksFromGameFGMod, GetGameToolEnabled.
- games_tab.pas: GameCardClick.
- bgmod_resources.pas: InitializeGlobalConfigDirectory.
- overlayunit.pas: Auto-save event guards during shutdown.
- tests/gui/gui_test_cases.pas: Comprehensive regression tests for toggle-off persistence, per-game launch command immediate generation, and multi-launch retention.
