## 1. Assets and Configuration Persistence

- [x] 1.1 Copy and optimize the provided Steam Betas screenshot to `assets/images/steam_lsfg_beta.png` and verify file is present and readable.
- [x] 1.2 Ensure `assets/images` is correctly handled in `Makefile` and packaging scripts, verifying installation path integrity.
- [x] 1.3 Add `HideSteamBetaNotice` preference handling in `lossless_scaling_tab.pas` to read and save setting to `goverlay.ini`, verifying round-trip config persistence.

## 2. Dialog Implementation

- [x] 2.1 Create `lsfg_steam_beta_dialog.pas` implementing `TLSFGVkSteamBetaNoticeDialog` with the screenshot image, instructions, action buttons ("Open Steam Folder", "Migration Assistant", "Close"), and "Do not show this notice again" checkbox.
- [x] 2.2 Add `lsfg_steam_beta_dialog` to `goverlay.lpi`, `goverlay.lpr`, and `lossless_scaling_tab.pas` unit uses lists.
- [x] 2.3 Enhance Step 1 of `lsfg_migration_dialog.pas` to embed a visual preview thumbnail or reference to `steam_lsfg_beta.png`.

## 3. Method Selection Triggering

- [x] 3.1 Hook `MethodLsfgClick` in `lossless_scaling_tab.pas` to inspect `CheckSteamBetaDllHealth` and invoke `ShowLsfgSteamBetaNoticeDialog` when `lsfg-vk.dll` is missing and `HideSteamBetaNotice` is False.
- [x] 3.2 Ensure notice dialog is suppressed when `FLoadingConfig` is True or when switching between `None` and `MAKO`.

## 4. Testing and Verification

- [x] 4.1 Add automated test cases in `tests/gui/gui_test_cases.pas` validating dialog instantiation, suppression preference, and trigger conditions.
- [x] 4.2 Compile project with `lazbuild -B goverlay.lpi` and run test suite to verify zero compilation errors and clean execution.
