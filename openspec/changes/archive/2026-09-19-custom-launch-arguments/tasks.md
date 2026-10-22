# Tasks

## 1. Data Model & Category Definition

- [x] 1.1 Define `TWEAK_CAT_ARGS = 5` in `tweaks_md3.pas` and set up predefined launch arguments array (`-novid`, `-vulkan`, `-dx11`, `-dx12`, `-nojoy`).
- [x] 1.2 Implement automatic input classification in `CustomEnvAddClick` (`overlayunit.pas`) and `FABClick` (`tweaks_md3.pas`), routing `-`, `--`, and `+` prefixed strings to `TWEAK_CAT_ARGS`.

## 2. UI Rendering & Interaction

- [x] 2.1 Update `TTweaksMD3Helper.Paint` in `tweaks_md3.pas` to render the "Launch Arguments" card below the "Custom Variables" card with item toggles, badges, and active count.
- [x] 2.2 Update `TTweaksMD3Helper.MouseDown` and hover handling to process toggle clicks and deletion guards on launch argument items.

## 3. Storage & Configuration Persistence

- [x] 3.1 Update `SaveTweaksConfig` in `tweaks_md3.pas` to serialize active arguments into `[Args]` and preserve global custom arguments in `[CustomArguments]`.
- [x] 3.2 Update `LoadTweaksFromFGMod` in `tweaks_md3.pas` to populate predefined arguments and load/inherit custom arguments in both Global and Game Profile modes.

## 4. Runner Subprocess Integration

- [x] 4.1 Update `bgmod.lpr` to read active arguments from `[Args]` in `bgmod.conf` and inject them into `ArgsStrings` before subprocess fork and `execvpe`.
- [x] 4.2 Build updated `bgmod` binary and verify subprocess argument execution.

## 5. Tests & Validation

- [x] 5.1 Add runner logic test in `tests/logic/` verifying `bgmod` argument injection from `[Args]`.
- [x] 5.2 Add GUI automated test cases in `tests/gui/gui_test_cases.pas` verifying predefined arguments, custom argument routing, persistence, and game profile inheritance.
- [x] 5.3 Execute `make test-logic` and `make test-gui` and verify clean build with zero failures.
