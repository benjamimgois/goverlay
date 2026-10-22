# Tasks

## 1. Automated Provisioning & Upstream Tracking

- [x] 1.1 Implement `CheckAndInstallVkNemu`, `IsVkNemuInstalled`, `ReadLocalVkNemuVersion`, and `IsVkNemuUpdateAvailable` in `optiscaler_update.pas` with Flatpak guard, tar extraction, and `IsValidSharedLibrary` verification
- [x] 1.2 Integrate `CheckAndInstallVkNemu` into `TStartupDownloadThread.Execute` in `overlayunit.pas` with progress callback updates during splash
- [x] 1.3 Register `vknemu` in `.agent/skills/goverlay-update-auditor/references/repositories.json` and verify upstream release auditing

## 2. Configuration & State Management

- [x] 2.1 Add vkNemu configuration key constants (`VKNEMU_ENABLED`, `VKNEMU_IDLE_FPS`, `VKNEMU_TIMEOUT`, `VKNEMU_UNFOCUSED`, `VKNEMU_INPUT`, `VKNEMU_DELAY`) to `configkeys.pas`
- [x] 2.2 Implement vkNemu configuration load/save routines in `configmanager.pas` and `overlay_config.pas` for global and per-game profiles

## 3. UI Implementation in MangoHud Limiters Card

- [x] 3.1 Instantiate vkNemu controls (master `TToggleSwitch`, `TSpinEdit` for idle FPS & timeout, `TComboBox` for input, `TToggleSwitch` for unfocused cap, `TSpinEdit` for delay) in `BuildPerformanceTab` in `mangohud_ui.pas`
- [x] 3.2 Implement responsive layout calculation and divider placement for the Limiters card in `ReflowPerfTab` in `mangohud_ui.pas`
- [x] 3.3 Connect UI event handlers to sync control values, dim child controls when the master toggle is disabled, and trigger profile auto-save

## 4. Launch Environment & Game Wrappers

- [x] 4.1 Implement `GetVkNemuLaunchEnv` in `overlayunit.pas` and integrate it into preview (`pas_cube` / `vkcube`) and game execution pipelines
- [x] 4.2 Add `GOVERLAY_VKNEMU` support to `data/fgmod/fgmod` and `data/bgmod/` launch wrapper scripts

## 5. Verification & Testing

- [x] 5.1 Compile Goverlay with `lazbuild` and execute automated GUI test cases verifying `FPerfCards[1]` layout integrity and widget placement
- [x] 5.2 Validate launch environment string generation and verify fallback URL download in a clean test directory
