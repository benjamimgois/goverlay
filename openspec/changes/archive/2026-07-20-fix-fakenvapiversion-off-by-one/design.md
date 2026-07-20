## Context

`goverlay.vars` is a key=value flat file that stores the versions of all components
installed by GOverlay (OptiScaler, FakeNvapi, FSR, XeSS, etc.). Several places in the
codebase read and rewrite individual keys using a `Copy(line, 1, N) = 'key='` prefix
check, where `N` must equal `Length('key=')`.

The key `'fakenvapiversion='` has **17 characters**. Three comparison sites pass `18`
as the copy length, so the extracted prefix always contains the key name plus the first
character of the value. The comparison against the literal `'fakenvapiversion='`
(17 chars) always fails because the lengths differ — Pascal's `SameText` compares full
string content, not just N chars. The consequence is:

- `UpdateButtonClick` (manual update): always falls through to the `Add` branch →
  duplicate `FakeNvapiVersion` lines accumulate on each update.
- `AutoInstallOptiScaler` (auto-install): same duplicate accumulation.
- `CleanGameOptiFiles` in `sidebar_nav.pas` (uninstall): the filter loop never matches
  the `FakeNvapiVersion` line → it is left behind in the game dir after uninstall.

A cosmetic typo `'fakenvapiversioN'` (capital N) exists in the `bgmod.lpr` version-key
constant array. While harmless at runtime (the array value is only used inside
`GetValFromList` which calls `SameText`), it is inconsistent and confusing.

## Goals / Non-Goals

**Goals:**
- Correct all three `Copy(..., 1, 18)` comparisons against `'fakenvapiversion='` to use `17`.
- Fix the typo `'fakenvapiversioN'` → `'fakenvapiversion'` in `bgmod.lpr`.
- Ensure existing `FakeNvapiVersion` entries in `goverlay.vars` are updated in-place
  rather than duplicated.
- Ensure uninstall cleanup correctly removes `FakeNvapiVersion` lines.

**Non-Goals:**
- Refactoring the key-matching pattern to a helper function (valuable but out of scope
  for this minimal fix).
- Migrating existing `goverlay.vars` files with duplicate lines (those will naturally
  resolve on next update because the in-place update will now work correctly).

## Decisions

### Use the corrected literal length directly (not `Length('fakenvapiversion=')`)

**Decision:** Change the magic number `18` to `17` at each affected callsite.

**Rationale:** The existing pattern throughout the codebase consistently uses
`Copy(line, 1, N)` with a hard-coded N equal to the key length. Switching to
`Length('fakenvapiversion=')` would be cleaner but touches more code and mixes styles
within the same function. Keeping the change minimal reduces review surface and risk.

**Alternative considered:** Introduce a `MatchesKey(line, key)` helper. Deferred — a
broader refactor of all key-matching sites is a separate improvement.

## Risks / Trade-offs

- **[Risk] Existing files with duplicate lines** — `goverlay.vars` files that already
  contain two `FakeNvapiVersion=` lines will have only the *first* matched line updated.
  The second (stale) duplicate will persist until something rewrites the whole file.
  → **Mitigation:** Acceptable; the file is self-healing after one full
  update+reinstall cycle. Adding dedup logic is out of scope here.

- **[Risk] Wrong copy count** — introducing a new typo in the corrected value.
  → **Mitigation:** Verified by `echo -n 'fakenvapiversion=' | wc -c` = 17 before
  writing this fix.
