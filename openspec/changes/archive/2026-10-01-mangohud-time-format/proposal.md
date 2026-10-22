# Proposal

## Why

MangoHud supports customizing the displayed time format via the `time_format` parameter using `std::put_time` / `strftime` syntax (such as `%T` for 24-hour with seconds, `%R` for 24-hour without seconds, or `%I:%M %p` for 12-hour AM/PM). Currently, GOverlay only exposes a binary `time` toggle in the "Extras" tab, always appending `time` and `time_no_label` without any ability to view or customize `time_format`. Users who want 12-hour clocks, concise formats without seconds, or date stamps are forced to manually edit their config files, which GOverlay subsequently overrides.

Adding a discreet configuration button beside the "Time" toggle allows full customization and presets without adding visual clutter to the busy 6-column grid of the "Extras" tab.

## What Changes

- Add a compact settings button (`⚙` / config button) adjacent to `FtimeToggle` in the "Extras" tab (Card 1: System info), enabled only when the `time` toggle is active.
- Clicking the configuration button opens a lightweight modal/dialog (`Time Format Configuration`) styled to match the dark/light theme, featuring:
  - Preset selector dropdown with common options:
    - 24-hour with seconds (`%T`) [Default]
    - 24-hour without seconds (`%R`)
    - 12-hour AM/PM with seconds (`%r`)
    - 12-hour AM/PM without seconds (`%I:%M %p`)
    - Date and 24-hour time (`%d/%m/%Y %H:%M`)
    - Custom format
  - Editable format string input box allowing any valid `std::put_time` specifier.
  - Live formatted preview label showing the current local system time rendered with the selected format string.
  - Informational help note and action buttons (Cancel / Apply).
- Add `TimeFormat: string` property to `TMangoHudSettings` in `overlay_config.pas`.
- Update MangoHud configuration parser in `mangohud_ui.pas` to parse `time_format=<value>` when loading configuration files.
- Update MangoHud configuration generator in `overlay_config.pas` to write `time_format=<value>` when `Time` is enabled (omitting or defaulting cleanly to `%T` when empty).
- Ensure reset to defaults resets `TimeFormat` to `%T`.

## Capabilities

### New Capabilities
- `mangohud-time-format`: Covers UI configuration, validation, preview, serialization, and round-trip persistence of MangoHud's `time_format` setting.

### Modified Capabilities
<!-- No existing spec requirements modified -->

## Impact

- `mangohud_ui.pas`: Add time format configuration dialog/popup logic, wire gear button adjacent to `FtimeToggle`, update `LoadMangoHudKeyValue`, `SaveMangoHudConfig`, and `ResetMangoHudControls`.
- `overlay_config.pas`: Add `TimeFormat` field to `TMangoHudSettings`, load/save `time_format` in `SaveMangoHudConfig` and `TConfigManager`.
- UI: Adds a 20x20 config button next to `timeCheckBox` toggle in `FExtSysCard`.
