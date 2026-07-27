## 1. Game Card Badge Tooltips

- [x] 1.1 Add tooltips/hints in English (`MangoHud: Enabled`, `vkBasalt: Enabled`, `OptiScaler: Enabled`, `Tweaks: Enabled`) to badge controls in `games_tab.pas`.

## 2. Sidebar Tool Toggle Status Messages

- [x] 2.1 Update `NavToolToggleClick` in `sidebar_nav.pas` to invoke `ShowStatusMessage` with English status notifications when toggling tool switches ON or OFF.

## 3. vkBasalt Restore Defaults Button

- [x] 3.1 Create `FVkRestoreBtn: TBitBtn` in `vkbasalt_tab.pas` with `VkRestoreBtnClick` handler that resets active effects, trackbars, and MD3 labels, and displays a status message.

## 4. Testing and Verification

- [x] 4.1 Add GUI tests in `tests/gui/gui_test_cases.pas` covering badge tooltips, sidebar toggle status toasts, and vkBasalt default restoration.
- [x] 4.2 Run `make test` to confirm all tests pass cleanly.
