# Tasks: Cleanup Orphaned Fields and Dead Stubs

## 1. Purge Orphaned Form Fields & Stubs
- [x] 1.1 Remove `casTrackBar2` and `ToggleSpeedButton` declarations from `overlayunit.pas` <!-- id: 1.1 -->
- [x] 1.2 Remove `themeToggleSpeedButton` hint from `hintsunit.pas` <!-- id: 1.2 -->
- [x] 1.3 Remove `ToggleSpeedButtonClick` declaration and implementation from `overlayunit.pas` <!-- id: 1.3 -->
- [x] 1.4 Remove `aboutBitBtnClick` declaration and implementation from `overlayunit.pas` <!-- id: 1.4 -->
- [x] 1.5 Remove `TweaksMD3BuildItems` and `TweaksMD3ToggleItem` declarations and implementations from `overlayunit.pas` <!-- id: 1.5 -->
- [x] 1.6 Remove `FTweaksVarListBox`, `UpdateTweaksVarListBox`, and `TweaksVarRemoveClick` from `overlayunit.pas` <!-- id: 1.6 -->

## 2. Purge Commented Dead Code Noise
- [x] 2.1 Remove `// Exposed:` commented lines from `overlayunit.pas` <!-- id: 2.1 -->
- [x] 2.2 Remove commented out radiobutton lines in `FormCreate` in `overlayunit.pas` <!-- id: 2.2 -->

## 3. Purge Unused Imported Units
- [x] 3.1 Remove unused units from `apputils.pas` (`configmanager`) <!-- id: 3.1 -->
- [x] 3.2 Remove unused units from `overlay_utils.pas` (`constants`, `configmanager`) <!-- id: 3.2 -->
- [x] 3.3 Remove unused units from `overlay_config.pas` (`Types`, `optiscaler_update`) <!-- id: 3.3 -->
- [x] 3.4 Remove unused units from `tweaks_md3.pas` (`bgmod_resources`, `configkeys`, `qtwidgets`) <!-- id: 3.4 -->

## 4. Verification & Testing
- [x] 4.1 Run full logic suite (`make test-logic`) <!-- id: 4.1 -->
- [x] 4.2 Run full GUI suite (`make test-gui`) <!-- id: 4.2 -->
- [x] 4.3 Delegate commit, archive, and push to Flash subagent <!-- id: 4.3 -->
