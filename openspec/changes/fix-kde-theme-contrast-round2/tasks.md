# Tasks

## 1. Diagnose residual cause

- [x] 1.1 Add opt-in debug logging (`GOVERLAY_DEBUG_THEME=1`) in `themeunit.pas` printing, per `TBitBtn` styled by `StyleBitBtnTheme`, the `ButtonText`/`WindowText`/`Text` colours for Active/Inactive/Disabled groups and `Enabled`; verify by running the app on a Kubuntu session and capturing the output for the Efficiency, Percent, `lsfg-vk Assistant` and `Install MAKO` buttons.
- [ ] 1.2 Record the identified cause in `design.md` (Decisions 2-4) and adjust the approach if it differs from the hypothesis; verify `design.md` states the confirmed cause.

## 2. Icon buttons (Metrics)

- [x] 2.1 Harden `StyleBitBtnTheme` per the confirmed cause (palette for all groups and/or disabled colours) and verify the "Frames / Joule" and "Percent" labels are readable on Kubuntu theme.
- [x] 2.2 Re-style the button after `Caption`/`ImageIndex` changes in `gpuframesjouleBitBtnClick`, `coreloadtypeBitBtnClick`, the Intel power-fix handler and config load; verify by toggling each button and checking text stays readable.
- [x] 2.3 Extend `tests/gui/gui_test_cases.pas` (or add a unit test) asserting the palette `ButtonText` of these buttons matches the theme text colour after a toggle; verify the test passes.

## 3. Lossless Scaling status buttons

- [x] 3.1 Replace the per-button QSS block in `ApplyThemeStyles` (`lossless_scaling_tab.pas`) with `StyleBitBtnTheme` for browse, check-updates, install MAKO, lsfg-vk assistant, lsfg-vk install and AFMF install buttons; verify the app builds and the buttons are readable in dark and light themes.
- [x] 3.2 Ensure enabled buttons never use the disabled colour pair; verify "Install MAKO" and "lsfg-vk Assistant" look enabled on Kubuntu theme and a truly disabled button remains distinguishable.

## 4. About dialog tabs

- [x] 4.1 Add `GetTabBarStyleSheet(AIsDark)` to `themeunit.pas` and use it for `aboutPageControl` in `aboutunit.FormCreate` (and optionally the main form); verify the "About" and "License" tabs are readable in dark and light themes on Kubuntu.
- [x] 4.2 Remove reliance on `aboutTabSheet.Font.Color = clWhite` from `aboutunit.lfm` if it causes light-theme contrast issues; verify About text is readable in light theme.

## 5. Integration

- [x] 5.1 Build with `lazbuild` and run the GUI test suite; verify no regressions.
- [ ] 5.2 Ask the issue #423 reporter to verify on the next nightly; verify the issue comment links the build.

## Workflow follow-up

- Archive the change once the reporter confirms.
