## 1. Core Paths and Cache Infrastructure

- [x] 1.1 Add `GetBGModOriginalCustomPath` to `bgmod_resources.pas` and verify path resolves to `~/.local/share/goverlay/optiscaler-custom` (or Flatpak equivalent)
- [x] 1.2 Implement custom build import function in `optiscaler_update.pas` with `OptiScaler.dll` validation, file copying to `optiscaler-custom/`, fallback companion library inheritance from `optiscaler-stable/`, and wrapper scripts synchronization

## 2. Channel Selector and Status Card UI Integration

- [x] 2.1 Add "Custom Build" item (index 2) to `optversionComboBox` and update channel load/save serialization in `overlayunit.pas`, `optiscaler_tab.pas`, and `optiscaler_update.pas`
- [x] 2.2 Wire "Select Folder..." action button in the Software Status card in `optiscaler_tab.pas` that invokes directory selection and triggers custom build import
- [x] 2.3 Suppress remote GitHub update checks and hide "Update Available" labels when the active channel is "Custom Build"
- [x] 2.4 Add non-intrusive toast and subtle status card text informing users that missing companion libraries are inherited from stable cache

## 3. Unmanaged INI Mode and Game Launch Integration

- [x] 3.1 Implement conditional "In-game menu configuration only" toggle in `optiscaler_tab.pas`, visible only when "Custom Build" is selected
- [x] 3.2 Persist `OPT_UNMANAGED_INI` in `bgmod.conf` and skip rewriting `OptiScaler.ini` in `overlay_config.pas` when unmanaged mode is enabled
- [x] 3.3 Update `SyncOptiScalerIni` in `bgmod.lpr` to respect `OPT_UNMANAGED_INI=1` and preserve existing `GameDir/OptiScaler.ini` without timestamp overwrite
- [x] 3.4 Update asset deployment in `sidebar_nav.pas` and `bgmod.lpr` to copy files from `optiscaler-custom/` when `OPT_CHANNEL=2`

## 4. Verification and Regression Testing

- [x] 4.1 Add regression test cases in `tests/gui/gui_test_cases.pas` verifying `OPT_CHANNEL=2` persistence, `OPT_UNMANAGED_INI` serialization, and unmanaged INI preservation
- [x] 4.2 Compile `goverlay.lpi` and `bgmod.lpr` with `lazbuild` and run test suite to verify 0 errors
