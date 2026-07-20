## 1. Fix off-by-one in optiscaler_update.pas

- [x] 1.1 Change `Copy(VarsList[VarsIdx], 1, 18)` → `Copy(VarsList[VarsIdx], 1, 17)` on line 1859 (manual update `UpdateButtonClick` — FakeNvapi update block)
- [x] 1.2 Change `Copy(VarsList[VarsIdx], 1, 18)` → `Copy(VarsList[VarsIdx], 1, 17)` on line 2471 (auto-install `AutoInstallOptiScaler` — FakeNvapi update block)

## 2. Fix off-by-one in sidebar_nav.pas

- [x] 2.1 Change `Copy(VarsList[i], 1, 18)` → `Copy(VarsList[i], 1, 17)` on line 868 (uninstall/cleanup filter for `'fakenvapiversion='`)

## 3. Fix typo in bgmod.lpr

- [x] 3.1 Change `'fakenvapiversioN'` → `'fakenvapiversion'` on line 299 (VersionKeys array constant)

## 4. Verification

- [x] 4.1 Confirm the four corrected `Copy` lengths match `Length('fakenvapiversion=')` = 17
- [x] 4.2 Build the project with `make` and confirm zero compilation errors
