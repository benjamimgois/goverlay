# Tasks

## 1. Runtime Cache and Installation Verification

- [x] 1.1 Update `optiscaler_update.pas` to resolve `amd_fidelityfx_dx12.dll` and `helixsr.ini` from both `HelixSR-fsrfg/` and the root cache, mirror them to root upon extraction, and update `IsHelixSRCompiled` to inspect both paths
- [x] 1.2 Update `HasMissingMandatoryLibraries` in `optiscaler_update.pas` and status checks in `home_tab.pas` to check `HelixSR-fsrfg/amd_fidelityfx_dx12.dll` alongside the root DLL
- [x] 1.3 Update GUI test cases in `tests/gui/gui_test_cases.pas` to verify detection and sync with the `HelixSR-fsrfg` subfolder structure and run `make test-gui`

## 2. Game Deployment and Frame Generation

- [x] 2.1 Update `bgmod.lpr` to locate `amd_fidelityfx_dx12.dll` and `helixsr.ini` in `HelixSR-fsrfg/` or root, and deploy `helixsr-fg` to game directories for DLSS Frame Generation
- [x] 2.2 Rebuild `bgmod` and run `make test-logic` to verify game deployment logic passes

## 3. Configuration Keys and UI Options

- [x] 3.1 Add HelixSR v2 constants (`HELIX_KEY_INT8`, `HELIX_KEY_NETWORK_RESOLUTION`, `HELIX_KEY_FG_PRESET`) to `configkeys.pas` and integrate reading/writing in `overlay_config.pas`
- [x] 3.2 Add UI controls for `Int8`, `NetworkResolution`, and `Preset` in `optiscaler_tab.pas` adhering to MD3 styling
- [x] 3.3 Build Goverlay with `make` and run complete test suite (`make test`) to verify all GUI and logic tests pass

## Workflow follow-up

- Archive the change after the project's review requirements are satisfied.
- Verify the archived result.
