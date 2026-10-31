# Proposal: Cleanup Dead Code and Legacy Stubs

## Why
With all legacy containers (`TGroupBox`) and legacy visual components eradicated from `overlayunit.lfm` in previous changes, several Pascal procedures, obsolete stubs, unused helper methods, and dead type checks remain in the codebase. Removing them reduces maintenance surface, avoids confusion, and eliminates unnecessary CPU cycles during theme updates, search sweeps, and reflow callbacks.

## What Changes
1. **Remove `ReflowOptiScalerTab` Legacy Routine:**
   - Remove the empty procedure `ReflowOptiScalerTab` in `overlayunit.pas`.
   - Remove lingering calls to `ReflowOptiScalerTab` in `overlayunit.pas` and `sidebar_nav.pas` (modern layout is fully managed by `ReflowOptiScalerTabNew`).
2. **Purge `TGroupBox` Handlers and Stubs:**
   - Remove `StyleGroupBoxNavy(GB: TGroupBox)` in `overlayunit.pas`.
   - Remove `ReparentGB` local helper in `optiscaler_tab.pas`.
   - Clean up dead `if ... is TGroupBox` checks in `overlayunit.pas` (`ClearSearchHighlights`, `SearchEditChange`, Navy theme loops), `themeunit.pas`, `mangohud_ui.pas`, and `uihelpers.pas`.
3. **Purge Obsolete Global Enable Stubs:**
   - Remove obsolete empty `UpdateGeSpeedButtonState` procedure and lingering callers in `overlayunit.pas`.
   - Remove obsolete `geSpeedButtonClick` empty stub in `overlayunit.pas`.
   - Remove `geSpeedButton` and `geLabel` components and bindings if safe to retire.
4. **Validation:**
   - Ensure full test suite passes with 0 failures (`make test-logic` and `make test-gui`).
