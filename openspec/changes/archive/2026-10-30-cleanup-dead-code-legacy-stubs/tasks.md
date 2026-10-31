# Tasks: Cleanup Dead Code and Legacy Stubs

## 1. ReflowOptiScalerTab Cleanup
- [x] 1.1 Remove `ReflowOptiScalerTab` calls in `overlayunit.pas` and `sidebar_nav.pas` <!-- id: 1.1 -->
- [x] 1.2 Remove `ReflowOptiScalerTab` declaration and definition in `overlayunit.pas` <!-- id: 1.2 -->
- [x] 1.3 Verify compilation <!-- id: 1.3 -->

## 2. TGroupBox Dead Code Purge
- [x] 2.1 Remove `StyleGroupBoxNavy` from `overlayunit.pas` <!-- id: 2.1 -->
- [x] 2.2 Remove `ReparentGB` from `optiscaler_tab.pas` <!-- id: 2.2 -->
- [x] 2.3 Remove `TGroupBox` checks from `ClearSearchHighlights` and `SearchEditChange` in `overlayunit.pas` <!-- id: 2.3 -->
- [x] 2.4 Remove `TGroupBox` branches from `themeunit.pas`, `mangohud_ui.pas`, and `uihelpers.pas` <!-- id: 2.4 -->
- [x] 2.5 Verify compilation <!-- id: 2.5 -->

## 3. Obsolete GeSpeedButton Stubs Cleanup
- [x] 3.1 Remove all calls to `UpdateGeSpeedButtonState` in `overlayunit.pas` <!-- id: 3.1 -->
- [x] 3.2 Remove `UpdateGeSpeedButtonState` declaration and implementation <!-- id: 3.2 -->
- [x] 3.3 Remove `geSpeedButtonClick` declaration and implementation <!-- id: 3.3 -->
- [x] 3.4 Safely disconnect `geSpeedButton` / `geLabel` or reanchor dependent labels in `goverlaybarPanel` <!-- id: 3.4 -->
- [x] 3.5 Verify compilation <!-- id: 3.5 -->

## 4. Verification & Testing
- [x] 4.1 Run full logic suite (`make test-logic`) <!-- id: 4.1 -->
- [x] 4.2 Run full GUI suite (`make test-gui`) <!-- id: 4.2 -->
- [x] 4.3 Delegate commit, archive, and push to Flash subagent <!-- id: 4.3 -->
