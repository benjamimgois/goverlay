# Design

## Context

See `proposal.md` for motivation. `first_run_dialog.pas` currently renders plain `TCheckBox` controls inside static dark-only `TPanel` cards with a `660px` dialog height that clips the `HelixSR` card at the scroll fold, no separators or counters, and an unstyled confirmation button.

Existing GOverlay units provide the building blocks to modernize the dialog cleanly:
- `toggle_switch.pas` (`TToggleSwitch` with `tssNormal` 38x20 track and `LinkToCheckBox`)
- `themeunit.pas` (`CurrentTheme`, `DARK_TAB_BG`, `LightBackgroundColor`, `LightTextColor`, `ApplyModernScrollBarStylesheet`)
- `home_tab.pas` / `tweaks_md3.pas` rounded card painting (`RoundRect` with parent-background corner clearing) and Qt6 antialiasing patterns.

## Goals / Non-Goals

**Goals:**
- Align `TFirstRunSetupDialog` visually with GOverlay's modern tabs (`Home`, `OptiScaler`, `Tweaks`) across both `tmDark` and `tmLight`.
- Keep all existing public `TCheckBox` properties (`MangoCheck`..`AfmfCheck` plus legacy aliases) and `TBitBtn` properties (`SelectAllBtn`, `ConfirmBtn`) intact and synchronized for test and caller compatibility.
- Avoid external Nerd Font dependencies on first run by using crisp vector icons drawn on `TPaintBox`/`TCanvas` (or bundled PNGs when available).

**Non-Goals:**
- Changing module persistence semantics in `configmanager.pas` (`[Modules]` keys remain identical).
- Removing the locked MangoHud core module or changing module download/uninstall behavior in `ConfirmBtnClick`.

## Decisions

1. **Hidden `TCheckBox` + Left-Aligned Textless `TToggleSwitch` (`tssNormal`, `Caption := ''`)**:
   - Rationale: Follows `TOptiScalerTabHelper.PlaceOsToggle` in `optiscaler_tab.pas`. Setting `Caption := ''` *after* `LinkToCheckBox(ACheck)` clears the copied checkbox caption so only the switch track renders (`40x22`), placed on the left side of each card while keeping every `TCheckBox` property functional.
   - Sync note: `TToggleSwitch.LinkToCheckBox` sets initial state without subscribing to `ACheckBox.OnChange`. Whenever a card is clicked, `SelectAllBtnClick` runs, or `CardPaint` executes, `TToggleSwitch.SyncFromLinked` will ensure visual switches and card highlights stay synchronized even when tests mutate `ACheckBox.Checked` directly.

2. **Custom Canvas-Painted Module Cards + Modern Header GOverlay Icon**:
   - Rationale: `CardPaint` matches `HomeCardPaint` (`home_tab.pas`), clearing outer corners cleanly, drawing an antialiased rounded rect (`16px` diameter / `8px` corner radius), a `3px` left accent strip when active/core, and the green `Core` pill badge next to `MangoHud`, without extra per-module left icon boxes so `TitleLbl` and `DescLbl` get maximum horizontal space next to the left-aligned toggle switch.
   - Header icon: Loads GOverlay's modern icon PNG (`data/icons/128x128/goverlay.png` / `assets/icons/goverlay.png` / `GetIconFile()`) into a `TImage` (`AntialiasingMode := amOn`, `Proportional := True`) beside `FTitleLabel`, with a painted vector fallback if the PNG is absent.

3. **Dialog Dimensions & Viewport Anti-Clip Layout (`660x700`)**:
   - Header (`90px` tall) with GOverlay app icon (`42x42`), `FTitleLabel`, wrapped `FSubtitleLabel`, and `1px` bottom divider.
   - Scroll area (`FContentBox` with `ApplyModernScrollBarStylesheet`) containing `OVERLAY`, `POST-PROCESSING AND SHADERS`, `UPSCALING ECOSYSTEM`, and `FRAME GENERATION AND MOTION` with right-aligned active counter pills (`X / Y active`), `62px`-tall cards (`6px` gap, full dynamic width `ClientWidth - 32` to balance with the `6px` scrollbar), and `12px` bottom spacer. Adjusting dialog height to `700px` ensures `HelixSR` sits cleanly above the scroll fold with zero half-card clipping.
   - Footer (`64px` tall) with `1px` top divider, left `Select All / Deselect All` toggle button, live `"X of 10 active"` label, and right-aligned primary accent CTA `TBitBtn` styled via Qt stylesheet (`rgb(32,120,180)` background, `rgb(48,190,240)` border, `8px` radius, bold white text).

4. **Dynamic Theme Palette Helper (`GetPalette`)**:
   - Branches on `CurrentTheme = tmLight` to select authentic GOverlay dark (`#161A28`, `#1B202E`) and light (`#FFFFFF`, `#F5F6F8`) colors cleanly.

## Risks / Trade-offs

- [Qt6 QSS button styling overrides native hover/focus] → Scope QSS specifically to `FConfirmBtn` and `FSelectAllBtn` with explicit `:hover` and `:pressed` rules so visual states remain crisp in both themes.
- [Tests modifying `TCheckBox.Checked` directly bypass `TToggleSwitch.OnChange`] → Read `ACheck.Checked` inside `ConfirmBtnClick` (existing behavior) and sync switches in `RefreshCardsState` / `CardPaint` so UI tests and runtime clicks stay coherent.
