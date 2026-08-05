## Why

When saving OptiScaler FrameGen settings (`FGInput`, `FGOutput`, `Enabled`), `TConfigFile.SetValue` fails to match existing section headers like `[FrameGen]` because `IsSectionHeader` returns bracketed section names (`[FrameGen]`) while `FindLineIndexInSection` compares against unbracketed section names (`FrameGen`). Additionally, when a section is not found, `SetValue` appends an unbracketed section header (`FrameGen`) and key lines to the end of the file, causing duplicate `FrameGen` blocks to accumulate repeatedly on every save.

## What Changes

- Update `TConfigFile` in `configfile.pas` to normalize section names (stripping surrounding whitespace and brackets `[` `]`) so that both `FrameGen` and `[FrameGen]` match section `[FrameGen]` in a case-insensitive manner.
- Fix `TConfigFile.SetValue` so that creating a new section header always writes `[SectionName]` with brackets instead of an unbracketed string.
- Fix `TConfigFile.SetValue` to insert missing keys at the end of an existing section instead of appending unbracketed section headers at the bottom of the file.
- Update `TConfigFile.HasSection` and `TConfigFile.FindSectionIndex` to match section names with or without brackets.
- Define `OPTI_INI_SECTION_FRAMEGEN = '[FrameGen]'` in `configkeys.pas` for consistency with `OPTI_INI_SECTION_MENU`.

## Capabilities

### Modified Capabilities
- `optiscaler-persistence`: INI section and key operations in `TConfigFile` must match section headers with or without brackets, and write new section headers with proper brackets `[Section]` without duplicating section blocks.

## Impact

- `configfile.pas`: Section matching, section header creation, and key placement logic in `TConfigFile`.
- `configkeys.pas`: Addition of `OPTI_INI_SECTION_FRAMEGEN`.
- `overlay_config.pas`: Usage of normalized section parameters in `SaveOptiScalerConfigCore` and `LoadOptiScalerConfig`.
- Prevents corrupting `OptiScaler.ini` with duplicate unbracketed `FrameGen` sections and key lines.
