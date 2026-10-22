## Why

Historically, the application was named "GOverlay" with both "G" and "O" capitalized. Over time, the project's official branding transitioned to "Goverlay" (capital "G" only). However, several visible user-facing interface elements—such as the new `bgmod-splash` title, dialog confirmation prompts, desktop notifications, tooltips, Steam shortcut creation scripts, and documentation—still display the legacy "GOverlay" casing.

Standardizing user-facing texts to "Goverlay" ensures visual consistency and reinforces current brand identity across all UI surfaces, dialogs, desktop notifications, packaging metadata, and documentation.

## What Changes

- **User Interface & Resource Strings**: Update all user-facing strings in `goverlay_strings.pas` (`rsClearConfigPrompt`, `rsGameModeFlatpakPrompt`, `rsSteamShortcutFlatpakInfo`, etc.) from "GOverlay" to "Goverlay".
- **Launch Splash Screen**: Update `bgmod_splash_src/splash_form.pas` title label from "GOverlay" to "Goverlay".
- **Notifications & Dialogs**: Update `SendNotification` call in `overlayunit.pas` from `'GOverlay'` to `'Goverlay'`.
- **Tooltips & Hints**: Update tooltips in `hintsunit.pas`, `optiscaler_tab.pas`, `lsfg_migration_dialog.pas`, `changelogunit.pas`, and `games_tab.pas` (including corresponding test assertion in `gui_test_cases.pas`).
- **PasCube Screen**: Update visible text strings in `UnitPasCubeScreen.pas` (`'Disable Lossless Scaling in Goverlay...'` and `'Goverlay Version:'`).
- **Steam Shortcut Script**: Update `assets/goverlay-steam-shortcut.py` to create shortcuts with `AppName: 'Goverlay'`, while retaining backward-compatible cleanup matching both `'GOverlay'` and `'Goverlay'`.
- **Packaging & Documentation**: Standardize mentions in `README.md`, `CONTRIBUTING.md`, `data/goverlay.1`, `data/io.github.benjamimgois.goverlay.metainfo.xml`, `packaging/deb/control`, `packaging/rpm/goverlay.spec`, and `.github/` templates.

Internal Pascal variable names, function identifiers, and POSIX uppercase environment variables (`GOVERLAY_*`) remain unchanged to avoid unnecessary code churn and preserve configuration compatibility.

## Capabilities

### New Capabilities
- `standardize-goverlay-branding`: Defines consistent "Goverlay" presentation requirements across all user-facing dialogs, tooltips, notifications, launch splash screen, Steam shortcuts, packaging, and documentation.

### Modified Capabilities
None.

## Impact

- **UI & Strings**: Minor text updates in Pascal UI units and resource strings.
- **Tests**: `tests/gui/gui_test_cases.pas` updated to match the new `Enabled Goverlay Tools:` hint string.
- **Steam Shortcuts**: Newly created shortcuts in Steam will appear as "Goverlay"; existing "GOverlay" shortcuts will be cleanly recognized and replaced if regenerated.
- **Compatibility**: No breaking changes to CLI options, INI configuration files, environment variables, or binary names.
