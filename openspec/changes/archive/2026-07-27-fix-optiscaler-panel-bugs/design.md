## Context

The OptiScaler tab in GOverlay exhibits four issues related to state management, file initialization, profile synchronization, and network resilience:
1. Navigating to the OptiScaler tab via left panel menu re-enables `spoofCheckBox` and `forcereflexCheckBox` even when `nvidiaRadioButton` is selected.
2. Enabling OptiScaler and saving does not copy OptiScaler binaries/DLLs into `gameconfig/global/` until GOverlay is restarted.
3. Enabling OptiScaler under MESA and picking "Force enable" for Reflex reverts to "Follow game setting" on next launch because `fakenvapi.ini` is not seeded on save when missing.
4. Installing/updating OptiScaler wipes the cache directory before fetching `fakenvapi` from GitHub; if the download fails, `fakenvapi.dll` and `fakenvapi.ini` disappear completely from the cache.

## Goals / Non-Goals

**Goals:**
- Enforce GPU driver restrictions (disabling Reflex and Spoof controls for NVIDIA) during `LoadOptiScalerConfig` and UI tab activations.
- Instantly sync OptiScaler binaries to `gameconfig/global/` upon saving when OptiScaler is enabled.
- Seed `fakenvapi.ini` from the cache directory if missing when saving OptiScaler config, before loading/modifying keys with `TConfigFile`.
- Make `fakenvapi` installation resilient during update/install flows so existing `fakenvapi` assets are preserved if downloading from GitHub fails.
- Add GUI/logic tests to verify these bug fixes.

**Non-Goals:**
- Changing the underlying OptiScaler or FakeNVAPI binary versions.
- Refactoring unrelated MangoHud or vkBasalt configuration logic.

## Decisions

### 1. Re-evaluate Driver Preferences in `LoadOptiScalerConfig`
- **Decision**: In `LoadOptiScalerConfig` (or right after calling it in `optiscalerLabelClick`), call driver state enforcement logic so that if `nvidiaRadioButton.Checked` is true, `spoofCheckBox.Enabled` and `forcereflexCheckBox.Enabled` are set to `False`.
- **Alternatives Considered**: Triggering `nvidiaRadioButtonChange(nil)` manually, but checking `nvidiaRadioButton.Checked` directly avoids unnecessary config saves during loading.

### 2. Immediate Global Profile Sync on Save
- **Decision**: In `SaveOptiScalerConfig` / `SaveOptiScalerConfigCore` (or immediately after saving in UI), execute `InitializeGlobalConfigDirectory` when `Settings.ActiveGameName` is empty (global profile) or when OptiScaler is toggled ON.
- **Alternatives Considered**: Only copying DLLs on launcher run (current broken behavior).

### 3. Seed `fakenvapi.ini` Template if Absent
- **Decision**: In `SaveOptiScalerConfigCore` in `overlay_config.pas`, before `FakeCfg.Load(FakeNvapiIniPath)`, check if `FakeNvapiIniPath` exists. If not, copy `fakenvapi.ini` from the active OptiScaler cache directory (`optiscaler-stable` or `optiscaler-edge`), mirroring the existing pattern for `OptiScaler.ini`.
- **Alternatives Considered**: Creating an empty `fakenvapi.ini` file, but copying the pristine template ensures all default sections and comments are preserved.

### 4. Resilient `fakenvapi` Update Fallback
- **Decision**: In `optiscaler_update.pas`, back up existing `fakenvapi.dll` and `fakenvapi.ini` prior to wiping cache or restore them if `FetchFakeNvapiLatest` / `DownloadFile` fails during update.

## Risks / Trade-offs

- [Risk] Running `InitializeGlobalConfigDirectory` during save might introduce a slight I/O pause. → Mitigation: `InitializeGlobalConfigDirectory` uses fast `rsync`/`cp` operations and only runs when saving global profile settings.
