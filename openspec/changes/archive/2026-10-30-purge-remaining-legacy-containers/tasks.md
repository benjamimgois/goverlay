# Tasks: Purge Remaining Legacy Containers

## 1. vkBasalt Tab Cleanup
- [x] 1.1 Reparent active controls from `reshadeGroupBox` and `builtineffectsGroupBox` to `vkbasaltTabSheet` and remove groupboxes in `overlayunit.lfm` <!-- id: 1.1 -->
- [x] 1.2 Remove field declarations and legacy hiding calls in `overlayunit.pas` and `vkbasalt_tab.pas` <!-- id: 1.2 -->
- [x] 1.3 Verify compilation and vkBasalt test cases <!-- id: 1.3 -->

## 2. OptiScaler Tab Cleanup
- [x] 2.1 Reparent active controls from `gpudriverGroupBox`, `optionsGroupBox`, `optiscalerGroupBox`, `fakenvapiGroupBox`, `imgmenuGroupBox`, `statusGroupBox` to `optiscalerTabSheet` and remove groupboxes in `overlayunit.lfm` <!-- id: 2.1 -->
- [x] 2.2 Clean field declarations, unanchor calls, manual layout logic, and visibility lines in `overlayunit.pas` and `optiscaler_tab.pas` <!-- id: 2.2 -->
- [x] 2.3 Verify compilation and OptiScaler test cases <!-- id: 2.3 -->

## 3. Tweaks Tab Cleanup
- [x] 3.1 Reparent active controls from `basicGroupBox`, `generalGroupBox`, `graphicsGroupBox`, `advancedGroupBox`, `performanceGroupBox` to `tweaksTabSheet` and remove groupboxes in `overlayunit.lfm` <!-- id: 3.1 -->
- [x] 3.2 Clean field declarations, unanchor calls, and visibility lines in `overlayunit.pas` and `tweaks_md3.pas` <!-- id: 3.2 -->
- [x] 3.3 Verify compilation and Tweaks test cases <!-- id: 3.3 -->

## 4. Final Validation & Delegation
- [x] 4.1 Run full logic suite (`make test-logic`) <!-- id: 4.1 -->
- [x] 4.2 Run full GUI suite (`make test-gui`) <!-- id: 4.2 -->
- [x] 4.3 Delegate commit, openspec archive, and push to Flash subagent <!-- id: 4.3 -->
