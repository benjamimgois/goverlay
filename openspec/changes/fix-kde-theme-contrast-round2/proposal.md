# Proposal

## Why

Issue #423 is still reproducible on the official Kubuntu 26.04 theme (Breeze), confirmed with fresh screenshots of a `1.9.5 (git testing build)` after the previous round (`fix-tbitbtn-contrast-kde-palette`). Three areas remain unreadable:

1. **Metrics tab icon buttons** (`gpuframesjouleBitBtn`, `cpuframesjouleBitBtn` "Frames / Joule" and `coreloadtypeBitBtn` "Percent"): text is nearly invisible (dark/dim on dark card) even though `UpdateGenericCardTheme` already calls `StyleBitBtnTheme` on them.
2. **Upscalers → Frame Interpolation "Software Status" buttons** (`Install MAKO` / `Install update`, `lsfg-vk Assistant`, plus Browse/Check/Install siblings): text is dim gray, as if disabled.
3. **About dialog tabs**: the active "About" tab is white with invisible text; "License" is light gray with white text. The `QTabBar` of `aboutPageControl` is never styled (the main form's tab bar is, at `overlayunit.pas` `TabSS`).

## What Changes

- **Icon-button text (Metrics)**: find why the palette/QSS synchronisation of `StyleBitBtnTheme` does not stick for `TBitBtn`s that carry an icon (custom `TQtBitBtn` paint path), and fix it so the label always uses the theme text colour. Re-apply the style after any `Caption` / `ImageIndex` change made by the click handlers (`gpuframesjouleBitBtnClick`, `coreloadtypeBitBtnClick`, `intelpowerfix`) and on config load.
- **Lossless Scaling tab buttons**: route `FLsBrowseDllBtn`, `FLsCheckUpdatesBtn`, `FLsInstallBtn`, `FLsLsfgAssistantBtn`, `FLsLsfgInstallBtn` (and AFMF equivalents) through `StyleBitBtnTheme` so palette and QSS no longer disagree; drop the duplicated QSS block in `ApplyThemeStyles` and use a single enabled/disabled colour pair with sufficient contrast.
- **About dialog**: apply a theme-aware `QTabBar` / `QTabWidget::pane` stylesheet in `aboutunit.pas` (dark and light), and remove reliance on the hard-coded `Font.Color = clWhite` of `aboutTabSheet`.
- Add a diagnostic step first (log `QPalette` ButtonText/WindowText and enabled state of the affected buttons) because the exact residual cause for item 1 and 2 is not yet confirmed.

## Capabilities

### New Capabilities
<!-- None -->

### Modified Capabilities
- `ui-theme-contrast`: extend button contrast requirements to icon buttons whose caption/icon changes at runtime and to the Lossless Scaling status buttons; add a requirement that dialog tab bars (About) are styled independently of the desktop palette.

## Impact

- `themeunit.pas`: possible hardening of `StyleBitBtnTheme` (icon path, disabled colours).
- `mangohud_ui.pas` / `overlayunit.pas`: re-style after caption/icon changes.
- `lossless_scaling_tab.pas`: `ApplyThemeStyles` and button creation.
- `aboutunit.pas`: tab bar stylesheet.
- No config format or API changes.
