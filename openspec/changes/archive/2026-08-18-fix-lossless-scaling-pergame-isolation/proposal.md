## Why

When navigating between Global mode and a specific game profile, Lossless Scaling configurations were leaking across contexts and overwriting each other. This occurred because `losslessScalingTabSheetShow` invoked `SetSaveBtnEnabled(True)` before calling `LoadLosslessConfig` while `FLoadingConfig` was `False`, causing `TriggerAutoSave` to immediately write the stale in-memory UI values from the previous context into the newly selected game or global directory before loading its actual saved configuration.

## What Changes

- **Prevent Premature Auto-Save on Tab Show**: Ensure `FLoadingConfig := True` guards the entire activation and configuration loading sequence in `losslessScalingTabSheetShow` (and `optiscalerTabSheetShow`), calling `LoadLosslessConfig` prior to enabling save buttons or UI reflow.
- **Isolate Lossless Scaling in Save Button Dispatch**: In `overlayunit.pas` (`saveBitBtnClick`), add an explicit early-exit block for `losslessScalingTabSheet` alongside `optiscalerTabSheet` and `tweaksTabSheet`, preventing unnecessary execution of `SaveMangoHudConfig`.
- **Align Global Config Resolution in `WriteLsfgTomlConfig`**: In `lossless_scaling_tab.pas` (`WriteLsfgTomlConfig`), default fallback output directory to `GetGameConfigDir('')` (`~/.local/share/goverlay/gameconfig/global/`) when `FActiveGameName = ''` instead of `TConfigManager.GetGoverlayFolder`, ensuring consistent path resolution across all loaders and writers.

## Capabilities

### Modified Capabilities
- `lossless-scaling-tab`: Explicitly specify context isolation requirements so that Global mode and Game-specific mode maintain strictly separated `lsfg.toml` / `bgmod.conf` configurations without cross-context leakage during navigation.

## Impact

- `overlayunit.pas`: `losslessScalingTabSheetShow`, `optiscalerTabSheetShow`, `saveBitBtnClick`.
- `lossless_scaling_tab.pas`: `WriteLsfgTomlConfig`, `LoadLosslessConfig`.
- `tests/gui/gui_test_cases.pas`: Adds GUI tests verifying that switching from Global mode (with custom Lossless Scaling values) to a game profile (and vice versa) does not overwrite either configuration.
