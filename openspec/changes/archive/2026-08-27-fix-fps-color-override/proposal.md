## Why

In MangoHud configuration, `fps_value=min,max` configures the two thresholds separating low, medium, and high FPS colors. Currently in GOverlay, whenever the user clicks Save, `SaveMangoHudConfig` automatically parses the FPS limit field (`FFpsLimitEdit`), derives `MaxFPS` and `Round(MaxFPS / 2)`, and unconditionally overwrites `fpscolor3SpinEdit` and `fpscolor2SpinEdit`. This makes it impossible for users to customize the FPS color threshold breakpoints, causing Issue #180.

This change decouples the FPS limiter and FPS color threshold controls so that custom breakpoint values configured in `fpscolor2SpinEdit` and `fpscolor3SpinEdit` are preserved, correctly written to `MangoHud.conf`, and never overwritten when saving or updating the FPS limit.

## What Changes

- **Remove forced overwrite on Save**: Remove the logic in `TMangoHudUiHelper.SaveMangoHudConfig` that forcibly overwrites `fpscolor2SpinEdit.Value` and `fpscolor3SpinEdit.Value` based on `FFpsLimitEdit.Text`.
- **Preserve User Color Thresholds**: Ensure `fpscolor2SpinEdit.Value` and `fpscolor3SpinEdit.Value` are saved directly to `Settings.FpsColorValues` and written as `fps_value=<min>,<max>` in `MangoHud.conf` when color FPS is enabled.
- **Clean Startup/Default Initialization**: Ensure `FormCreate` and `ResetMangoHudControls` initialize sensible stock defaults (30 and 60) without overwriting them based on FPS limits on startup.
- **Update Automated GUI Tests**: Update `tests/gui/gui_test_cases.pas` to verify that custom FPS color values are preserved on save and reload rather than being overwritten by the FPS limiter value.

## Capabilities

### New Capabilities
- `mangohud-fps-colors`: Manages MangoHud FPS color threshold configuration, ensuring user-defined breakpoints are preserved and persisted without interference from the FPS limiter.

### Modified Capabilities

## Impact

- **Affected files**:
  - `mangohud_ui.pas` (`TMangoHudUiHelper.SaveMangoHudConfig`)
  - `overlayunit.pas` (`FormCreate`)
  - `tests/gui/gui_test_cases.pas`
- **User Impact**: Users can now freely set custom break points for MangoHud FPS colors (`fps_value`) and have them reliably saved and reloaded.
