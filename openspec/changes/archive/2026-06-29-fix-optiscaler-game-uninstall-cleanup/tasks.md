## 1. Implementation

- [x] 1.1 In `games_tab.pas`, update `GameCardUninstallClick` to scan subdirectories for OptiScaler markers (`goverlay.vars`, `OptiScaler.dll`, `OptiScaler.ini`) and run `RunFGModUninstallCommands` on all found directories.
- [x] 1.2 In `bgmod.lpr`, update the disabled OptiScaler branch (`else`) to clean up proxy DLLs and restore backups when OptiScaler files exist in `GameDir`.

## 2. Verification

- [x] 2.1 Verify project compiles with `lazbuild goverlay.lpi` and `make bgmod`.
