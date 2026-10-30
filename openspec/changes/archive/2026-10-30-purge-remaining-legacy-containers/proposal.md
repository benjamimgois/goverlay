# Proposal: Purge Remaining Legacy Containers (vkBasalt, OptiScaler, Tweaks)

## Why
Following the successful removal of legacy containers in MangoHud, the remaining tabs (`vkBasalt`, `OptiScaler`, and `Tweaks`) still declare obsolete `TGroupBox` hierarchies in `overlayunit.lfm` and `overlayunit.pas`. These containers are purely legacy scaffolding that is hidden at runtime (`GroupBox.Visible := False`) while modern panels reparent the actual functional controls. Removing them simplifies `overlayunit.lfm`, eliminates dead container definitions, and finishes the complete purge of legacy GUI groupboxes across GOverlay.

## What Changes
1. **vkBasalt Tab (`vkbasaltTabSheet`)**:
   - Eliminate `reshadeGroupBox` and `builtineffectsGroupBox` from `overlayunit.lfm` and `overlayunit.pas`.
   - Reparent all active effect checkboxes and controls directly to `vkbasaltTabSheet` with `Anchors = []` while preserving their natural visibility (no `Visible = False`).
   - Remove legacy hiding calls in `vkbasalt_tab.pas`.

2. **OptiScaler Tab (`optiscalerTabSheet`)**:
   - Eliminate `gpudriverGroupBox`, `optionsGroupBox`, `optiscalerGroupBox`, `fakenvapiGroupBox`, `imgmenuGroupBox`, and `statusGroupBox` from `overlayunit.lfm` and `overlayunit.pas`.
   - Reparent all active functional controls (driver radios, upscaler combos, options controls, status labels) directly to `optiscalerTabSheet` with `Anchors = []` preserving natural visibility.
   - Remove manual groupbox reflow code and visibility assignments in `optiscaler_tab.pas` and `overlayunit.pas`.

3. **Tweaks Tab (`tweaksTabSheet`)**:
   - Eliminate `basicGroupBox`, `generalGroupBox`, `graphicsGroupBox`, `advancedGroupBox`, and `performanceGroupBox` from `overlayunit.lfm` and `overlayunit.pas`.
   - Reparent all active functional checkboxes directly to `tweaksTabSheet` with `Anchors = []` preserving natural visibility.
   - Remove legacy hiding calls and `UnanchorControl` in `tweaks_md3.pas` and `overlayunit.pas`.

4. **Safety & Verification**:
   - Preserve natural visibility of all functional controls so modern cards display properly.
   - Pass 100% of `make test-logic` (98 tests) and `make test-gui` (158 tests).
