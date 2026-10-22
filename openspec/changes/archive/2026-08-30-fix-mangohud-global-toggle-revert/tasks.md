## 1. MangoHud Config Loading and Saving Fixes

- [x] 1.1 Preserve `FLoadingConfig` state in `ResetMangoHudControls` in `mangohud_ui.pas` so that `LoadMangoHudConfig` keeps `FLoadingConfig = True` until all controls finish loading. Verify that AutoSave is not triggered while populating controls.
- [x] 1.2 Guard `GOVERLAY_MANGOHUD` in `SaveMangoHudConfigCore` in `overlay_config.pas` so that saving configuration files does not overwrite an existing `GOVERLAY_MANGOHUD=0` flag in `bgmod.conf`. Verify that saving configuration when disabled preserves the disabled flag.

## 2. Automated Tests and Verification

- [x] 2.1 Add a GUI test in `tests/gui/gui_test_cases.pas` that disables MangoHud in global mode, simulates a subsequent launch, navigates to the MangoHud tab, and verifies that `GOVERLAY_MANGOHUD` remains `0` in `bgmod.conf`. Verify by running the GUI test suite.
- [x] 2.2 Run full project test suite (`./build_tests.sh all`) to verify that all unit and GUI tests pass.
