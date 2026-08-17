# Design: OptiScaler Menu Scale Auto Option and Default

## Context

`optiscaler_tab.pas` creates and manages the `menuscaleComboBox` control on the Upscalers tab. `overlay_config.pas` handles loading and saving settings from/to `OptiScaler.ini` (`[Menu]` section, `Scale=` key). See `proposal.md` for motivation.

## Goals / Non-Goals

**Goals:**
- Add `'auto'` as the first entry (`Index 0`) of `menuscaleComboBox`.
- Make `'auto'` the default selection on clean launch / new profiles.
- Persist `Scale=auto` to `[Menu]` in `OptiScaler.ini` when `auto` is selected.
- Parse `Scale=auto`, empty strings, or missing `Scale=` keys as `auto` (`Index 0`) on load.
- Map fixed float scales `1.0` through `2.0` (Indices 1 through 11) seamlessly.

**Non-Goals:**
- Altering any other OptiScaler settings or sections.

## Decisions

### Decision 1: `MenuScalePosition` numeric sentinel for `auto`
- **Choice**: In `TOptiScalerSettings`, use `MenuScalePosition := 0` to denote `auto`. Numeric scales `1.0` to `2.0` are stored as `10` to `20` (`Round(FloatValue * 10)`).
- **Rationale**:
  - Backward compatibility: `0` or negative cleanly distinguishes `auto` from numeric multipliers (`10` = 1.0, `15` = 1.5, `20` = 2.0).
  - Clean mapping with ComboBox indices:
    - Index 0 -> `MenuScalePosition = 0` (`Scale=auto`)
    - Index 1..11 -> `MenuScalePosition = 9 + Index` (e.g. Index 1 -> 10 = `Scale=1.0`, Index 6 -> 15 = `Scale=1.5`).

## Risks / Trade-offs

- **Risk**: Existing INI files with `Scale=1.0` or other fixed values.
  - **Mitigation**: `TryStrToFloat` parses existing float values and maps them directly to the corresponding combobox item (e.g. `1.0` -> Index 1). If the file contains `Scale=auto` or is empty, it selects `auto` (Index 0).
