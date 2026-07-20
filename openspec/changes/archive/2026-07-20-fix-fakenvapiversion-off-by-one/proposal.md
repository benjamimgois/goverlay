## Why

A string length off-by-one error in three files causes `FakeNvapiVersion` entries in
`goverlay.vars` to never be detected during update/install operations. As a result,
each OptiScaler install or update appends a *new* duplicate `FakeNvapiVersion` line
instead of updating the existing one, and uninstall cleanup also silently skips the
line. The typo `'fakenvapiversioN'` in `bgmod.lpr` is also cleaned up while touching
the same area.

## What Changes

- **Fix** `Copy(VarsList[VarsIdx], 1, 18)` → `Copy(VarsList[VarsIdx], 1, 17)` on all
  three `'fakenvapiversion='` comparisons in `optiscaler_update.pas` (lines 1859, 2471)
  and `sidebar_nav.pas` (line 868).
- **Fix** typo `'fakenvapiversioN'` → `'fakenvapiversion'` in `bgmod.lpr` (line 299).

## Capabilities

### New Capabilities
- *(none — this is a pure bug fix)*

### Modified Capabilities
- `bgmod-update-optiscaler`: FakeNvapiVersion key matching must use the correct prefix
  length (17) so that existing lines are detected and updated in-place rather than
  duplicated.

## Impact

- `optiscaler_update.pas` — `UpdateButtonClick` (manual update flow) and
  `AutoInstallOptiScaler` (auto-install flow): both duplicate-line creation paths are
  fixed.
- `sidebar_nav.pas` — `CleanGameOptiFiles` / uninstall cleanup: will now correctly
  filter out and delete `FakeNvapiVersion` lines from `goverlay.vars` on uninstall or
  game switch.
- `bgmod.lpr` — version-key comparison array: cosmetic fix; no runtime behaviour
  change because `SameText` is case-insensitive, but eliminates misleading inconsistency.
