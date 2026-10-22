# Proposal: Fix MangoHud Global Toggle Revert on Tab Access

## Why

When MangoHud is disabled in global mode (`GOVERLAY_MANGOHUD=0` in `bgmod.conf`), restarting GOverlay and navigating to the MangoHud tab causes `bgmod.conf` to be modified and `GOVERLAY_MANGOHUD=1` to be written back, even though the toggle in the UI remains in the OFF state.

This occurs because `ResetMangoHudControls` prematurely resets `FLoadingConfig` to `False` in its `finally` block before `LoadMangoHudConfig` finishes populating control values from `MangoHud.conf`. The resulting UI control change events fire `TriggerAutoSave`, invoking `SaveMangoHudConfigCore`, which unconditionally writes `GOVERLAY_MANGOHUD=1` to `bgmod.conf`.

## What Changes

- Preserve `FLoadingConfig := True` throughout the entire `LoadMangoHudConfig` routine by ensuring `ResetMangoHudControls` does not prematurely set `FLoadingConfig := False` when called within an active load operation.
- Guard `SaveMangoHudConfigCore` (and related overlay config savers) so that saving overlay configuration files does not clobber an existing disabled tool flag (`GOVERLAY_MANGOHUD=0`) in `bgmod.conf`.
- Add automated GUI test verifying that navigating to the MangoHud tab when MangoHud is toggled off does not trigger AutoSave or revert `GOVERLAY_MANGOHUD=0` to `1` in `bgmod.conf`.

## Capabilities

### Modified Capabilities
- `config-persistence-and-tool-toggling`: Ensure accessing a tool tab (specifically MangoHud) when disabled preserves the `GOVERLAY_MANGOHUD=0` state in `bgmod.conf` without triggering AutoSave.

## Impact

- Affected files: `mangohud_ui.pas`, `overlay_config.pas`, `tests/gui/gui_test_cases.pas`.
- No breaking changes or external API changes.
