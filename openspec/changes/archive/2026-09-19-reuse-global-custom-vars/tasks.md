# Tasks

## 1. Storage & Persistence

- [x] 1.1 Update `SaveTweaksToFGMod` in Global mode to persist all custom variables (both active and inactive) into `[CustomVariables]` in `bgmod.conf` while keeping active variables in `[Env]`, and verify disabled variables remain in the file.
- [x] 1.2 Update `SaveTweaksToFGMod` in Game Profile mode to save only active custom variables to the game's `[Env]` section without altering the global catalog, and verify game `bgmod.conf` contents.

## 2. Loading & Inheritance

- [x] 2.1 Update `LoadTweaksFromFGMod` in Global mode to read from `[CustomVariables]` (with backwards-compatible fallback to `[Env]`), set toggle state based on `[Env]`, and tag rows as `'Global'` in `FTweaksGrid.Cells[3, Row]`.
- [x] 2.2 Update `LoadTweaksFromFGMod` in Game Profile mode to load global custom catalog entries as `'Global'`, match against the game's `[Env]` (defaulting to toggle OFF if absent), and append any game-specific entries as `'Local'`.

## 3. UI Rendering & Interaction

- [x] 3.1 Update `TTweaksMD3Helper.Paint` to render a `[Global]` badge chip for global custom rows in game profiles and suppress the delete (`×`) icon for global entries.
- [x] 3.2 Update `TTweaksMD3Helper.MouseDown` to prevent deletion of `'Global'` rows when in a game profile, ensuring clicking in the delete area does not delete global catalog entries.

## 4. Tests & Validation

- [x] 4.1 Add automated test cases in `gui_test_cases.pas` covering global variable persistence across OFF toggles, game profile inheritance with default toggle OFF, game-specific toggle activation, and deletion guarding.
- [x] 4.2 Run the full test suite and verify clean compilation and passing tests.
