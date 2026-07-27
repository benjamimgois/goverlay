## 1. Sidebar Tab Navigation Path Reset

- [x] 1.1 Update `mangohudLabelClick` in `overlayunit.pas` to explicitly set `MANGOHUDCFGFILE := GetGameConfigDir('') + 'MangoHud.conf'` when `FActiveGameName = ''`.
- [x] 1.2 Update `vkbasaltLabelClick` in `overlayunit.pas` to explicitly set `VKBASALTCFGFILE := IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf'` and `VKSUMICFGFILE := IncludeTrailingPathDelimiter(GetVkSumiConfigDir()) + 'vkSumi.conf'` when `FActiveGameName = ''`.

## 2. Tweaks Control Reset on Missing Config

- [x] 2.1 Update `LoadTweaksFromFGMod` in `tweaks_md3.pas` to move the UI control reset logic before checking `if not FileExists(ConfigPath) then Exit;`.

## 3. Testing and Verification

- [x] 3.1 Add GUI tests in `tests/gui/gui_test_cases.pas` to verify path resetting when clicking sidebar tabs in global mode and verifying Tweaks controls reset on missing config.
- [x] 3.2 Run `make test` to confirm all tests pass cleanly.
