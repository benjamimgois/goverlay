## Context

See `proposal.md` for motivation. Currently, `TConfigFile` in `configfile.pas` provides section-aware helper methods (`GetValue`, `SetValue`, `HasSection`). However, `IsSectionHeader` returns the full trimmed string including brackets (e.g., `[FrameGen]`), while `FindLineIndexInSection` compares that against `ASection` without normalizing brackets. When `ASection` is passed as `'FrameGen'`, section matching fails and `SetValue` appends unbracketed `FrameGen` headers to the end of the file.

## Goals / Non-Goals

**Goals:**
- Implement `CleanSectionName` in `configfile.pas` to strip whitespace and surrounding brackets `[` `]`, returning a lowercase normalized section identifier.
- Update `IsSectionHeader`, `FindLineIndexInSection`, `FindSectionIndex`, `HasSection`, and `SetValue` in `TConfigFile` to use `CleanSectionName`.
- Ensure `SetValue` formats newly created section headers as `[SectionName]` with brackets.
- Ensure `SetValue` inserts new keys at the end of an existing section (before the next section header or EOF) rather than immediately after the section header line.
- Define `OPTI_INI_SECTION_FRAMEGEN = '[FrameGen]'` in `configkeys.pas` and use it in `overlay_config.pas`.

**Non-Goals:**
- Redesign the overall `TConfigFile` architecture or replace it with `TIniFile`.

## Decisions

1. **Normalize Section Names with `CleanSectionName` Helper**:
   - *Decision*: Create `CleanSectionName(const ASection: string): string` in `configfile.pas`. If `ASection` starts with `[` and ends with `]`, strip them, then trim and convert to lowercase.
   - *Rationale*: Allows `TConfigFile` API consumers to pass either `'FrameGen'` or `'[FrameGen]'` without breaking section matching.

2. **Section Header Formatting on Creation**:
   - *Decision*: When `SetValue` determines a section header does not exist, format the line as `'[' + CleanSectionName(ASection) + ']'`.
   - *Rationale*: Ensures invalid unbracketed lines like `FrameGen` are never emitted into INI files.

3. **Insertion at Section End**:
   - *Decision*: When adding a new key to an existing section, locate the end of that section (the line index of the next section header, or `FLines.Count`) and insert the key there.
   - *Rationale*: Keeps section contents grouped neatly and logically.

## Risks / Trade-offs

- **[Risk] Existing INI files with corrupted `FrameGen` lines**:
  - *Mitigation*: Unit tests and post-extraction scripts in GOverlay will re-save OptiScaler settings, clean existing files, and verify `OptiScaler.ini` has single bracketed `[FrameGen]` headers.
