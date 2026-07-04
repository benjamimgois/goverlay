## 1. Directory Cache Definitions and Startup Migration

- [x] 1.1 In `bgmod_resources.pas`, update `GetBGModOriginalPath` to return `~/.local/share/goverlay/optiscaler-stable`.
- [x] 1.2 In `bgmod_resources.pas`, declare and implement `GetBGModOriginalEdgePath` to return `~/.local/share/goverlay/optiscaler-edge`. Include legacy aliases for both.
- [x] 1.3 In `bgmod_resources.pas` `InitializeBGModDirectory`, rename legacy `.bgmod_original` to `optiscaler-stable` if the latter does not exist.
- [x] 1.4 In `bgmod_resources.pas` `InitializeBGModDirectory`, copy bundled scripts from GOverlay's install folder to `optiscaler-stable`, and also to `optiscaler-edge` if the folder exists.
- [x] 1.5 In `bgmod_resources.pas` `InitializeBGModDirectory`, remove the active `bgmod/` startup sync (leaving `bgmod/` as a template folder for wrapper scripts).

## 2. Global Profile Initialization and Syncing

- [x] 2.1 In `bgmod_resources.pas` `InitializeGlobalConfigDirectory`, check if `gameconfig/global/` exists. If not, seed it with only the wrapper scripts from `bgmod/`.
- [x] 2.2 In `bgmod_resources.pas` `InitializeGlobalConfigDirectory`, on subsequent runs, read `OPT_CHANNEL` from `gameconfig/global/bgmod.conf`.
- [x] 2.3 In `bgmod_resources.pas` `InitializeGlobalConfigDirectory`, sync DLLs and plugins from `optiscaler-stable/` or `optiscaler-edge/` directly to `gameconfig/global/` based on `OPT_CHANNEL`.

## 3. OptiScaler Tab Update and Installation Flow

- [x] 3.1 In `optiscaler_update.pas`, introduce `GetBGModOriginalPathForChannel(IsStable: Boolean)` returning `optiscaler-stable/` or `optiscaler-edge/`.
- [x] 3.2 In `optiscaler_update.pas`, update `SyncPristineAssetsTo` signature and implementation to accept `ASourceDir` as a parameter.
- [x] 3.3 In `optiscaler_update.pas` `UpdateButtonClick`, resolve the target cache folder `OrigPath` using the selected channel.
- [x] 3.4 In `optiscaler_update.pas` `UpdateButtonClick`, perform all extraction, helper DLL downloads, and `goverlay.vars` writing directly in `OrigPath`.
- [x] 3.5 In `optiscaler_update.pas` `UpdateButtonClick`, sync pristine assets from `OrigPath` to the destination directory.

## 4. Seeding and Toggle Logic in GUI

- [x] 4.1 In `games_tab.pas` `GameCardClick` first-selection seeding, copy only wrapper scripts from `bgmod/` to `gameconfig/<game>/` (no OptiScaler DLLs copied).
- [x] 4.2 In `sidebar_nav.pas` `CopyOptiScalerGameFiles`, read `OPT_CHANNEL` from `bgmod.conf` in the game's directory.
- [x] 4.3 In `sidebar_nav.pas` `CopyOptiScalerGameFiles`, copy all OptiScaler files from `optiscaler-stable/` or `optiscaler-edge/` to the game's config folder.
- [x] 4.4 In `sidebar_nav.pas` `RemoveOptiScalerGameFiles`, clean up all DLLs and plugins (and delete `fsrversion` / `xessversion` from `goverlay.vars`).

## 5. Wrapper and Uninstaller Binaries Update

- [x] 5.1 In `bgmod.lpr`, update `GetGlobalBGModPath` to read `OPT_CHANNEL` from local `bgmod.conf` and return `optiscaler-stable` or `optiscaler-edge`.
- [x] 5.2 In `bgmod-uninstaller.lpr`, update `GetBGModPath` to read `OPT_CHANNEL` from local `bgmod.conf` and return `optiscaler-stable` or `optiscaler-edge`.
- [x] 5.3 In `bgmod-uninstaller.lpr` global uninstall path, delete both `optiscaler-stable/` and `optiscaler-edge/` directories.
