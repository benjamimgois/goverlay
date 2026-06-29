## Context

In the OptiScaler tab, `fsrversionComboBox` provides FSR version selection, and `emufp8CheckBox` allows toggling an FP8 emulation workaround flag. The user requested simplifying the combobox text from "Latest (FP8)" to "Latest" and hiding `emufp8CheckBox`.

## Goals / Non-Goals

**Goals:**
- Update `fsrversionComboBox` item 0 text to "Latest".
- Hide `emufp8CheckBox` (`Visible := False`).
- Update config serialization (`overlay_config.pas` and `optiscaler_update.pas`) to support "Latest".

**Non-Goals:**
- Removing the underlying config key handling or breaking existing saved game profiles.

## Decisions

### Decision 1: LFM and Code Updates for Combobox Text
Update `overlayunit.lfm` items list for `fsrversionComboBox` from `Latest (FP8)` to `Latest`, and update `Text` default property to `Latest`.
Update comment references and string checks in `overlayunit.pas`, `overlay_config.pas`, and `optiscaler_update.pas`.

### Decision 2: Hide emufp8CheckBox
Set `emufp8CheckBox.Visible := False` in `overlayunit.lfm` and `overlayunit.pas` form initialization.

## Risks / Trade-offs

- [Risk] Existing config files with `Latest (FP8)` might fail matching → Mitigation: Include `(FsrVer = 'Latest (FP8)') or (FsrVer = 'Latest')` in all config parsing conditions.
