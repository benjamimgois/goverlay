# Proposal

## Why

Gamers on Linux frequently rely on launch arguments (such as `-novid`, `-vulkan`, `-dx11`, `-dx12`, and `-nojoy`) to resolve rendering issues, bypass unskippable intro videos, or prevent controller polling stutter in Steam games. Currently, users must manually configure these arguments inside Steam's Launch Options text field, where they cannot be toggled on and off without deleting and retyping them. Integrating a dedicated Launch Arguments card into GOverlay's EnvVars tab centralizes all game startup tuning in one place, allowing users to toggle both predefined and custom arguments per game with a single click.

## What Changes

- Add a dedicated **Launch Arguments** card in the EnvVars/Tweaks tab beneath the Custom Variables card.
- Provide built-in, curated toggles for the most essential Linux/Proton launch arguments:
  - `-novid`: Skip intro videos and splash screens.
  - `-vulkan`: Force native Vulkan renderer backend.
  - `-dx11`: Force DirectX 11 backend.
  - `-dx12`: Force DirectX 12 backend.
  - `-nojoy`: Disable joystick/gamepad subsystem polling to eliminate stutter.
- Allow users to add arbitrary custom launch arguments (e.g. `+fps_max 0`, `-skipintro`, `--fullscreen`).
- Enhance the floating `+ Add` button with automatic classification:
  - Text starting with `-`, `--`, or `+` is automatically routed to the **Launch Arguments** card.
  - Text containing `=` or formatted as environment variable names is routed to the **Custom Variables** card.
- Persist active launch arguments in a dedicated `[Args]` section in `bgmod.conf`.
- Persist global custom arguments in `[CustomArguments]` in the global `bgmod.conf`, automatically inheriting them into game profiles with toggle switch OFF by default.
- Update the `bgmod` wrapper binary to parse active arguments from `[Args]` and inject them dynamically into the game's `argv` prior to `execvpe`.
- Apply `[Global]` and `[Game]` badge chips and deletion guards in game profiles, keeping parity with the custom environment variables workflow.

## Capabilities

### New Capabilities
*(None)*

### Modified Capabilities
- `envvars-tab-card-redesign`: Add requirements for the Launch Arguments card, predefined argument toggles, automatic input routing in `+ Add`, global argument catalog inheritance, and runner argument injection.

## Impact

- `tweaks_md3.pas`: Data structures for predefined and custom arguments, UI card rendering, and configuration serialization (`[Args]` and `[CustomArguments]`).
- `overlayunit.pas`: Input classification in `CustomEnvAddClick` and grid routing.
- `bgmod.lpr`: Reading `[Args]` from `bgmod.conf` and appending enabled flags into `ArgsStrings` before subprocess fork and `execvpe`.
- Automated tests: GUI tests in `tests/gui/gui_test_cases.pas` and logic/runner tests in `tests/logic/`.
