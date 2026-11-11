# Proposal

## Why

The Component Setup dialog (`first_run_dialog.pas`) currently uses bare Qt checkboxes, static unstyled cards, a clipped layout fold, and hardcoded dark colors, making it look basic and visually inconsistent with GOverlay's modern card/toggle design system (`home_tab.pas`, `toggle_switch.pas`, `themeunit.pas`). Upgrading its visual hierarchy, interactive controls, and theme support aligns the onboarding and module management experience with the rest of GOverlay.

## What Changes

- Replace visible `TCheckBox` controls inside module cards with modern left-aligned textless `TToggleSwitch` (`tssNormal`, `Caption := ''`) controls while keeping underlying `TCheckBox` instances linked and hidden for full API/test backwards compatibility.
- Upgrade module cards with GOverlay's rounded-card styling (`RoundRect`), interactive hover and checked highlights, subtle `3px` left accent strips, and a styled green `Core` pill badge on MangoHud.
- Add category active-count pills (e.g., `1 / 3 active`) and GOverlay's modern app icon in the header alongside `1px` header/footer separator lines.
- Modernize the footer bar with `Select All / Deselect All` toggling, a live total active counter (`X of 10 active`), and an accent-styled primary CTA button (`Save and Continue` on first run, `Save and Apply` in Manage mode), removing the legacy "Keep MangoHud Only" button.
- Support both `tmDark` and `tmLight` GOverlay themes (`themeunit.pas`), adjust dialog height/spacing (`700px`) with bottom padding so no card is clipped at the scroll fold, and preserve the `6px` thin modern scrollbar.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `first-launch-modular-setup`: Update onboarding and module manager dialog requirements to use modern interactive card/toggle controls, category and footer active counters, primary CTA confirmation (`Save and Continue` / `Save and Apply` with `Select All` / `Deselect All`), and Dark/Light theme compliance.

## Impact

- `first_run_dialog.pas`: Visual redesign, `TToggleSwitch` linking, hover/active painting, theme-aware palette, header/footer separators and primary CTA styling, dynamic counters.
- `tests/gui/gui_test_cases.pas`: Extend `TestFirstRunSetupDialogUI` to verify `TToggleSwitch` synchronization, category/footer counters, `Select All / Deselect All` toggling, and theme/layout geometry while preserving existing assertions.
