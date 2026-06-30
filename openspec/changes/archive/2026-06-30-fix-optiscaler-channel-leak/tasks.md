## 1. UI Selection Sychronization

- [x] 1.1 Implement fallback to index 0 (Stable Channel) in TOptiScalerTabHelper.LoadOptiScalerConfig if OptVersionItemIndex is invalid (in optiscaler_tab.pas)

## 2. Verification

- [x] 2.1 Verify compilation of the project using make
- [x] 2.2 Verify that switching between different configurations correctly resets and syncs optversionComboBox state without leaking previous selection
