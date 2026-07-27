## Why

When navigating between Game Profiles and Global Profile (or between different Game Profiles), selecting a preset layout (e.g., "Full") or color theme (e.g., "Simple White") in one profile leaves the visual selection highlight (blue border and selection bar) active on the Preset cards when switching to another profile. This happens because `FActiveLayoutCard` and `FActiveColorCard` in `Tgoverlayform` are not reset in `ResetMangoHudControls` nor re-evaluated in `LoadMangoHudConfig`.

## What Changes

- Reset `FActiveLayoutCard := -1` and `FActiveColorCard := -1` inside `ResetMangoHudControls` in `mangohud_ui.pas` so stale card selection state is cleared prior to loading a new config.
- Update `LoadMangoHudConfig` in `mangohud_ui.pas` to invoke `UpdatePresetCardVisuals` after loading config settings, ensuring preset card highlights match the newly active configuration.
- Add GUI tests in `tests/gui/gui_test_cases.pas` to verify preset card highlights reset upon profile context switches.

## Capabilities

### Modified Capabilities
- `mangohud-ui-reset-on-load`: Add requirement that preset card active indices (`FActiveLayoutCard`, `FActiveColorCard`) are reset during control resets and preset visual highlights are refreshed upon loading MangoHud configs.

## Impact

- `mangohud_ui.pas`: Update `ResetMangoHudControls` and `LoadMangoHudConfig` to clear and refresh preset card selection states.
- `tests/gui/gui_test_cases.pas`: Add test verifying preset card selection reset when switching profiles.
