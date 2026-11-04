# Tasks

## 1. Profile State Synchronization & Default Initialization

- [x] 1.1 In `overlay_config.pas:LoadOptiScalerConfig`, explicitly default `Settings.UpscalerTypeItemIndex := 2` (None) when `bgmod.conf` is missing or unconfigured, and verify with tests.
- [x] 1.2 In `games_tab.pas:GameCardClick`, `overlayunit.pas:gamesLabelClick`, and `overlayunit.pas:optiscalerLabelClick`, invoke `FLosslessScalingHelper.LoadLosslessConfig` and synchronize `FOptiScalerHelper` so memory state reflects the newly active profile.
- [x] 1.3 Add a test in `tests/gui/gui_test_cases.pas` verifying that activating AFMF in Global mode and then selecting OptiScaler in a clean game profile does not display the AFMF conflict dialog.

## 2. Upscaler Sidebar Toggle Coherence

- [x] 2.1 Update `TSidebarNavHelper.SetGameToolEnabled` in `sidebar_nav.pas` to check the profile's `UPSCALER_TYPE` and `INTERPOLATION_METHOD` before writing `GOVERLAY_OPTISCALER=1` or `GOVERLAY_LOSSLESS=1` into `bgmod.conf`.
- [x] 2.2 Add a test in `tests/logic/logic_test_cases.pas` verifying that enabling the Upscalers toggle on a profile with `UPSCALER_TYPE=2` (None) keeps `GOVERLAY_OPTISCALER=0`.

## 3. HelixSR Leftover Detection and Cleanup

- [x] 3.1 In `bgmod.lpr:HasOptiScalerLeftovers`, add checks for `HelixSR/`, `helixsr-fg/`, and `helixsr.ini` so games with leftover HelixSR files are flagged for cleanup.
- [x] 3.2 In `bgmod.lpr` (cleanup routine) and `bgmod-uninstaller.lpr`, ensure `HelixSR/`, `helixsr-fg/`, `helixsr.ini`, and HelixSR proxy DLLs are removed when upscalers are disabled or uninstalled.
- [x] 3.3 Add a test in `tests/logic/logic_test_cases.pas` verifying that HelixSR files are recognized as leftovers and purged when launching with upscaler disabled.
- [x] 3.4 Compile project binaries (`make all`) and run test suite (`./goverlay-tests`) to verify end-to-end functionality.
