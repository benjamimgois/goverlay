## Why

GOverlay currently uses a fixed window size (`bsSingle`), preventing users on high-resolution displays (1440p, 4K), ultrawide monitors, or tiling window managers (KDE, GNOME, Sway/Hyprland) from scaling or maximizing the application. Allowing window resizing and maximizing improves usability and accessibility while leveraging GOverlay's existing responsive card reflow system.

## What Changes

- Allow window resizing and maximizing by changing `Tgoverlayform.BorderStyle` from `bsSingle` to `bsSizeable`.
- Enforce minimum constraints (`Constraints.MinWidth = 1045`, `Constraints.MinHeight = 683`) to ensure all native UI elements fit cleanly without clipping.
- Implement fluid horizontal and vertical spacing for cards and inner controls across MangoHud tabs (`Metrics`, `Extras`, `Performance`, `Visual`) so cards expand and controls dynamically spread when window dimensions exceed 1045x683 px.
- Persist and restore window dimensions (`Width`, `Height`) and state (`Maximized`) in `~/.config/goverlay/goverlay.ini` across application restarts.

## Capabilities

### New Capabilities
- `window-geometry-and-resizing`: Provides resizable and maximizable main window support with initial size, minimum constraints (1045x683 px), fluid horizontal/vertical inner layout reflowing across MangoHud tabs, and state persistence in `goverlay.ini`.

### Modified Capabilities

## Impact

- `overlayunit.lfm`: `BorderStyle` and `Constraints` properties.
- `overlayunit.pas`: `FormCreate`, `FormShow`, `FormClose`, and INI load/save helpers for window geometry.
- `mangohud_ui.pas`: `ReflowMetricsTab`, `ReflowExtrasTab`, `ReflowPerformanceTab`, and `ReflowVisualTab` dynamic control column and vertical row calculations.
- UI & Logic Tests: Existing tests pass clean; test coverage updated for 1045x683 px window constraints.
