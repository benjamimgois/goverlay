# Tasks

## 1. Theme Palette, Header & Footer Modernization

- [x] 1.1 In `first_run_dialog.pas`, add a theme-aware `GetDialogPalette` helper supporting both `tmDark` and `tmLight` from `themeunit.pas` (`CurrentTheme`), adjust dialog dimensions (`660x700` or `640x700` so `HelixSR` sits cleanly above the scroll fold with bottom spacing), and add `1px` header/footer divider lines. Verify compilation cleanly.
- [x] 1.2 In `first_run_dialog.pas`, display GOverlay's modern app icon in the header alongside `TitleLabel` and wrapped `SubtitleLabel`, and modernize the footer with `Select All / Deselect All` dynamic toggling, a live `"X of 10 active"` counter label, and accent-styled primary CTA QSS on `ConfirmBtn` (`Save and Continue` / `Save and Apply`). Verify caption and layout bounds in `TestFirstRunSetupDialogUI`.

## 2. Modern Module Cards & TToggleSwitch Integration

- [x] 2.1 In `first_run_dialog.pas`, replace visible `TCheckBox` controls inside `CreateLibraryCard` with hidden linked `TCheckBox` controls + left-aligned textless `TToggleSwitch` (`tssNormal`, `Caption := ''` set after `LinkToCheckBox`) controls synced bidirectionally on click, toggle change, and `SelectAllBtnClick`. Verify all `MangoCheck`..`AfmfCheck` properties work in `TestFirstRunSetupDialogUI`.
- [x] 2.2 In `first_run_dialog.pas`, implement custom `CardPaint` with parent-background corner clearing, hover and checked border/fill elevation, a `3px` left accent strip for active/core cards, a green `"Core"` pill badge beside MangoHud, and category active-count pills (`"X / Y active"`). Verify hover/toggle tracking and `6px` thin scrollbar styling.

## 3. Automated Tests & Integration Verification

- [x] 3.1 Update `TestFirstRunSetupDialogUI` in `tests/gui/gui_test_cases.pas` to assert `TToggleSwitch` presence/sync, category and footer active counters, `Select All` / `Deselect All` toggle behavior, header/subtitle bounds, and theme/layout geometry without regressions.
- [x] 3.2 Run `lazbuild goverlay.lpi --ws=qt6`, `make test-logic`, `make test-gui`, and `openspec validate modernize-component-setup-ui --strict` and verify all builds and tests pass with zero errors.
