## Why

During the game uninstallation process ("Uninstall changes"), log files and overlay configuration files such as `bgmod.log`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` are sometimes left behind in the target game directory. Explicitly ensuring these files are removed across all uninstallation routines prevents leftover configurations and log clutter.

## What Changes

- Explicitly add deletion logic for `bgmod.log`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` in `RunFGModUninstallCommands` (`games_tab.pas`).
- Synchronize uninstallation cleanup in `bgmod-uninstaller.lpr` and `bgmod.lpr` to guarantee these files are explicitly removed when uninstallation or disabled wrapper cleanup occurs.

## Capabilities

### New Capabilities
- `fix-uninstall-overlay-files-cleanup`: Explicitly removes `bgmod.log`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf` from target game directories during uninstallation.

### Modified Capabilities
<!-- None -->

## Impact

- `games_tab.pas`: Updated `RunFGModUninstallCommands`.
- `bgmod-uninstaller.lpr`: Updated uninstaller cleanup tasks.
- `bgmod.lpr`: Updated disabled wrapper cleanup block.
