## 1. Tab Activation and Reflow Updates

- [x] 1.1 Add `ReflowVkBasaltTab` call with width calculation in `Tgoverlayform.vkbasaltTabSheetShow` in `overlayunit.pas`
- [x] 1.2 Update `Tgoverlayform.vkbasaltLabelClick` to set tab visibility and active page prior to calling `SetNavActive(2)` in `overlayunit.pas`
- [x] 1.3 Improve height fallback in `TVkBasaltTabHelper.ReflowVkBasaltTab` in `vkbasalt_tab.pas`

## 2. Testing and Verification

- [x] 2.1 Add GUI test case in `tests/gui/gui_test_cases.pas` verifying that `FVkToggleCard.Top + FVkToggleCard.Height <= vkbasaltTabSheet.ClientHeight` when navigating to the tab
- [x] 2.2 Run test suites (`make test-gui` and `make test-logic`) to verify fix and ensure no regressions
