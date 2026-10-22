## Context

See `proposal.md` for motivation.
The project historically used "GOverlay" (capital "G" and "O"). Although modern branding uses "Goverlay", several visible UI strings, tooltips, dialogs, desktop notifications, splash screen components, shortcut scripts, packaging specs, and documentation still display the legacy casing.

## Goals / Non-Goals

**Goals:**
- Update all user-facing interface text, resource strings, desktop notifications, tooltips, and changelog headers to display "Goverlay".
- Update the `bgmod-splash` splash screen header title label to display "Goverlay".
- Update `assets/goverlay-steam-shortcut.py` to create "Goverlay" shortcuts while matching both "GOverlay" and "Goverlay" during cleanup and re-generation.
- Update documentation (`README.md`, `CONTRIBUTING.md`), man pages (`goverlay.1`), AppStream metadata (`io.github.benjamimgois.goverlay.metainfo.xml`), and package specs (`deb/control`, `rpm/goverlay.spec`).
- Update test assertions in `tests/gui/gui_test_cases.pas` that verify hint texts.

**Non-Goals:**
- Renaming internal Pascal identifiers, functions, or record types (e.g. `GOverlayMangoHud`, `GetGOverlayDataDir`).
- Changing POSIX environment variables (e.g. `GOVERLAY_MANGOHUD`, `GOVERLAY_OPTISCALER`).
- Changing file paths, binary names, or desktop file names (`goverlay`, `io.github.benjamimgois.goverlay`).
- Modifying archived OpenSpec change logs.

## Decisions

### Decision 1: Scope boundary restricted to visible texts and docs
- **Rationale**: User explicitly selected Option 2 ("Apenas Textos Visíveis (UI & Docs)"). Internal symbol renaming would cause wide code churn across dozens of Pascal units without changing user perception.
- **Alternatives considered**: Full codebase refactoring (renaming all identifiers and variables). Rejected due to high churn and zero user-facing benefit.

### Decision 2: Dual-matching in Steam shortcut script
- **Rationale**: In `assets/goverlay-steam-shortcut.py`, setting `'AppName': 'Goverlay'` will create new shortcuts as "Goverlay". However, users who already created a shortcut using the previous version will have an entry named "GOverlay". The cleanup check must match both:
  ```python
  if s.get('AppName') in ('Goverlay', 'GOverlay'):
  ```
- **Alternatives considered**: Only matching "Goverlay". Rejected because it would leave orphaned "GOverlay" shortcuts in the user's Steam library when re-running shortcut creation.

### Decision 3: Coordinated update of tooltip inspection in `games_tab.pas` and `gui_test_cases.pas`
- **Rationale**: `games_tab.pas` generates tooltips starting with `Enabled Goverlay Tools:` and also inspects `Pos('Enabled Goverlay Tools:', TargetPanel.Hint)` when updating dynamic hints. `gui_test_cases.pas` asserts this exact string. Updating both simultaneously prevents test failures or hint generation discrepancies.

## Risks / Trade-offs

- **[Risk]** Test failure from desynchronized hint assertions → **Mitigation**: Update `tests/gui/gui_test_cases.pas` line 5172 to check `Pos('Enabled Goverlay Tools:', ...)` and run both GUI test suite and logic test suite before completion.
- **[Risk]** Steam shortcut duplication → **Mitigation**: Check both `'Goverlay'` and `'GOverlay'` in the Python shortcut helper's cleanup routine.
