## 1. Synchronize Config File Paths on Game Selection

- [x] 1.1 Update `GameCardClick` in `games_tab.pas` to assign `VKBASALTCFGFILE := GameCfgDir + 'vkBasalt.conf'` and `VKSUMICFGFILE := GameCfgDir + 'vkSumi.conf'`.

## 2. Testing and Verification

- [x] 2.1 Add a GUI test in `tests/gui/gui_test_cases.pas` verifying that `VKBASALTCFGFILE` and `VKSUMICFGFILE` point to the game config directory upon game card click.
- [x] 2.2 Run `make test` to confirm all tests pass cleanly.
