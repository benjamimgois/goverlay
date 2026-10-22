## 1. FSR4 Directory Infrastructure and Download

- [x] 1.1 Add `GetFSR4BasePath` in `bgmod_resources.pas` resolving `~/.local/share/goverlay/FSR4/` with subdirectories `Latest`, `4.1.1b`, and `4.0.2c`.
- [x] 1.2 Update OptiScaler auto-install and update routines in `optiscaler_update.pas` to copy the native DLL to `FSR4/Latest/` and download alternative builds (4.1.1b and 4.0.2c) from GitHub releases.
- [x] 1.3 Remove creation and syncing of legacy `FSR4_LATEST` and `FSR4_INT8` directories from `optiscaler_update.pas`, `bgmod_resources.pas`, `sidebar_nav.pas`, and `bgmod.lpr`.

## 2. UI Integration in OptiScaler Tab

- [x] 2.1 Reparent and style `fsrversionLabel` and `fsrversionComboBox` into `FOsSpatialSec` in `optiscaler_tab.pas`, setting items to `Latest`, `4.1.1b`, and `4.0.2c`.
- [x] 2.2 Update layout reflow in `optiscaler_tab.pas` to place `fsrversionComboBox` directly below `preferredUpscalerComboBox` and adjust vertical positions for `FSpoofToggle` and `FForceFsr4Toggle`.
- [x] 2.3 Remove auto-hide logic in `overlayunit.pas` (`fsrversionComboBoxChange`) to keep `fsrversionComboBox` permanently visible.

## 3. Configuration Persistence and DLL Deployment

- [x] 3.1 Update `overlay_config.pas` (`LoadOptiScalerConfig` and `SaveOptiScalerConfig`) to serialize `fsrversion` (`Latest`, `4.1.1b`, `4.0.2c`), copy the matching DLL from `FSR4/` to the profile directory, and preserve backwards compatibility.
- [x] 3.2 Update profile initialization in `sidebar_nav.pas` and runtime restoration in `bgmod.lpr` to deploy the matching FSR DLL from the centralized `FSR4/` directory without referencing legacy subfolders.

## 4. Verification and Automated Testing

- [x] 4.1 Add automated GUI tests in `tests/gui/gui_test_cases.pas` validating `fsrversionComboBox` visibility, item values, default selection, and persistence across saves.
- [x] 4.2 Run the full GUI test suite (`make test-gui`) and logic test suite (`make test-logic`) ensuring 0 failures.
