## 1. Path Helper Modification

- [x] 1.1 Update `GetGameConfigDir` in `overlayunit.pas` and `overlay_config.pas` to map empty/blank game name to `gameconfig/global/` instead of returning a path ending with an empty folder name.

## 2. Configuration Migration & Initialization

- [x] 2.1 Implement startup migration logic to copy existing active global configuration files (`bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`) from `~/.local/share/goverlay/bgmod/` to `~/.local/share/goverlay/gameconfig/global/` if they do not exist in the new directory.

## 3. Codebase Integration

- [x] 3.1 Update all occurrences of global config writes/reads in `overlay_config.pas`, `optiscaler_update.pas`, `tweaks_md3.pas`, `sidebar_nav.pas`, and `overlayunit.pas` to use `GetGameConfigDir` instead of falling back to `GetBGModPath()`.
- [x] 3.2 Ensure GOverlay's template copying (e.g., copying template scripts, binaries, and version configs to the game directories) still uses the pristine `GetBGModPath()` as the source.

## 4. Verification

- [x] 4.1 Rebuild goverlay and verify that when GOverlay is run with the global profile active, configuration edits are saved in `gameconfig/global/`.
- [x] 4.2 Verify that `bgmod/` directory remains pristine with no user settings/modifications.
