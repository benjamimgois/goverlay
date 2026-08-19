## Why

Users often need to inspect, fine-tune, or verify raw configuration files directly in their preferred desktop text editor without navigating complex filesystem directories (such as `~/.local/share/goverlay/gameconfig/<game>/` or `~/.config/`). 

Currently, several configuration tabs (OptiScaler, Lossless Scaling, and EnvVars/Tweaks) hide the floating dock hamburger menu `[ ☰ ]`, and existing menus lack an action to launch the underlying configuration file in the system's default text editor. Adding an "Open config file" action at the top of the hamburger menu across all configuration tabs provides a unified, accessible bridge between the GUI and raw configuration files.

## What Changes

- **Add "Open config file" Action**: Add an `openConfigFileMenuItem` ("Open config file") at the top of the floating dock options menu (`popsaveMenu`), with a dedicated icon.
- **Enable Hamburger Menu on All Configuration Tabs**: Update floating dock tab configurations (`UpdateForTab`) so that the hamburger menu button `[ ☰ ]` is enabled and visible across all configuration tabs:
  - MangoHud tabs: `[ 👁 Preview ] [ ☰ ] [ ✓ Finish ]`
  - vkBasalt & vkSumi tabs: `[ 👁 Preview ] [ ☰ ] [ ✓ Finish ]`
  - OptiScaler tab: `[ ☰ ] [ ✓ Finish ]`
  - Lossless Scaling tab: `[ 👁 Preview ] [ ☰ ] [ ✓ Finish ]`
  - EnvVars (Tweaks) tab: `[ ☰ ] [ + Add ] [ ✓ Finish ]`
- **Dynamic Config File Resolution**: Determine the exact configuration file path based on the active tab and active context (Global mode vs Per-Game profile):
  - MangoHud: `MANGOHUDCFGFILE` (`MangoHud.conf`)
  - vkBasalt: `VKBASALTCFGFILE` (`vkBasalt.conf`)
  - vkSumi: `VKSUMICFGFILE` (`vkSumi.conf`)
  - OptiScaler: `GetGameConfigDir(FActiveGameName) + 'OptiScaler.ini'`
  - Lossless Scaling: `GetGameConfigDir(FActiveGameName) + 'lsfg.toml'`
  - EnvVars / Tweaks: `GetGameConfigDir(FActiveGameName) + 'bgmod.conf'`
- **Automatic File and Directory Preparation**: If the target configuration file does not yet exist on disk, ensure parent directories are created and trigger an initial save of the active tab's settings before launching `xdg-open`.
- **System Text Editor Execution**: Invoke `xdg-open "<config_file_path>"` asynchronously to open the configuration in the user's default desktop editor (e.g. Kate, Gedit, KWrite, VSCode).

## Capabilities

### Modified Capabilities
- `floating-action-dock`: Add "Open config file" action in the floating dock hamburger menu and ensure `[ ☰ ]` is present across all configuration tabs.

## Impact

- `overlayunit.pas`: Menu item declaration, click handler (`openConfigFileMenuItemClick`), tab show / switch handlers updating `FFADock.UpdateForTab`.
- `overlayunit.lfm`: `openConfigFileMenuItem` placed at the top of `popsaveMenu`.
- `tests/gui/gui_test_cases.pas`: Automated GUI test verifying hamburger menu presence and config file resolution across tabs.
