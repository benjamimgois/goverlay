## 1. Implementation

- [x] 1.1 In `games_tab.pas`, update `RunFGModUninstallCommands` to explicitly delete `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf`.
- [x] 1.2 In `bgmod-uninstaller.lpr` and `bgmod.lpr`, add explicit `SafeDeleteFile` calls for `bgmod.log`, `MangoHud.conf`, `vkBasalt.conf`, and `vkSumi.conf`.

## 2. Verification

- [x] 2.1 Verify project compiles with `lazbuild goverlay.lpi`, `make bgmod`, and `make bgmod-uninstaller`.
