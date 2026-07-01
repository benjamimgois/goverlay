## Why

On a fresh GOverlay install, the isolated global profile directory `~/.local/share/goverlay/gameconfig/global/` is created before OptiScaler binaries are downloaded. As a result the first-run copy of `bgmod/` into `gameconfig/global/` only contains template scripts and `README/LICENSE` files, while `OptiScaler.dll`, upscaler DLLs, plugins and other runtime assets are missing. This breaks per-game installs and the Software Status card on the first launch until the user restarts GOverlay.

## What Changes

- Split global profile initialization out of `InitializeBGModDirectory` so it can run **after** OptiScaler has been auto-installed.
- Introduce a dedicated helper that fully populates `gameconfig/global/` from `bgmod/` on first run and syncs binaries on subsequent runs.
- Update the startup sequence in `overlayunit.pas` to call the new helper after `CheckAndInstallOptiScaler`.
- Ensure the helper reuses the existing config-file exclusion list (`bgmod.conf`, `goverlay.vars`, `OptiScaler.ini`, `fakenvapi.ini`) for subsequent-run syncs.

## Capabilities

### New Capabilities
- `first-run-global-config-population`: Ensures `gameconfig/global/` is fully populated with the complete contents of `bgmod/` after OptiScaler is installed on the first run.

### Modified Capabilities
- `bgmod-update-optiscaler`: Extends the global-profile isolation requirement to guarantee that the first initialization of `gameconfig/global/` happens after `bgmod/` contains the downloaded OptiScaler runtime files.

## Impact

- `bgmod_resources.pas`: refactor `InitializeBGModDirectory` global-init block into a reusable helper.
- `overlayunit.pas`: adjust startup order so global init runs after auto-install.
- Affects first-run behavior only; existing per-game and global profile paths remain unchanged.
