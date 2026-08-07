# Change Proposal: Fix INI File Sync on Launch in bgmod

## Context
On branch `de-alternate`, when a user modifies `OptiScaler.ini` or `fakenvapi.ini` in GOverlay UI or directly inside the active configuration directory (`~/.local/share/goverlay/gameconfig/<game>/`), those settings are saved in `ConfigDir`. However, during game launch (`bgmod` execution), `bgmod` fails to apply these settings because:

1. In section 5a of `bgmod.lpr` (DLSS Enabler setup), `bgmod` was copying default `optiscaler-stable/OptiScaler.ini` into `GameDir`, overwriting `GameDir/OptiScaler.ini` and setting its timestamp to the current time.
2. `SyncOptiScalerIni` compared `AgeConfig > AgeGame`. Because `AgeGame` was newer (from step 1 or previous in-game writes), it aborted copying `ConfigDir/OptiScaler.ini` to `GameDir`.
3. `fakenvapi.ini` lacked a unified synchronization helper from `ConfigDir` to `GameDir`.

## Proposed Changes

### 1. Update `SyncOptiScalerIni` and Add `SyncFakeNvapiIni` (`bgmod.lpr`)
- Update `SyncOptiScalerIni` to always copy `ConfigDir/OptiScaler.ini` to `GameDir/OptiScaler.ini` whenever `ConfigDir/OptiScaler.ini` exists.
- Add `SyncFakeNvapiIni` to always copy `ConfigDir/fakenvapi.ini` to `GameDir/fakenvapi.ini` whenever `ConfigDir/fakenvapi.ini` exists.
- Remove default `OptiScaler.ini` template copy during DLSS Enabler base file setup in section 5a of `bgmod.lpr`.

## Non-Goals
- Modifying GOverlay UI form controls or `overlay_config.pas` save logic.
