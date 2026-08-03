# Proposal: Centralized UI Design System in themeunit

## Problem Statement
Currently, UI styling, typography scales, colors, padding/margins, and component creation helpers are duplicated across individual tab implementation files (`mangohud_ui.pas`, `optiscaler_tab.pas`, `vkbasalt_tab.pas`, `tweaks_md3.pas`, etc.). Hardcoded font families (e.g. `'Noto Sans'` in `vkbasalt_tab.pas`), varying font sizes (`8pt`, `9pt`, `10pt`), mismatched control heights (`26px` vs `28px`), and inconsistent label colors lead to visual misalignment and make global UI updates error-prone.

## Proposed Changes
1. **Centralized Design Tokens (`themeunit.pas`)**:
   - Define a single source of truth for color palette tokens (BGR format for dark/light themes), typography scale tokens (`FONT_SZ_CARD_HDR = 10`, `FONT_SZ_SEC_HDR = 8`, `FONT_SZ_CONTROL = 9`, `FONT_SZ_HINT = 8`), and layout metric tokens (`LAYOUT_MARGIN = 4`, `LAYOUT_GAP = 6`, `LAYOUT_PAD = 12`, `LAYOUT_HDR_HEIGHT = 34`, `LAYOUT_ROW_HEIGHT = 26`, `LAYOUT_BTN_HEIGHT = 28`).

2. **Global Component Styling Helpers (`themeunit.pas`)**:
   - Provide centralized, reusable styling procedures: `StyleMainCard`, `StyleSubCard`, `StyleLabel`, `StyleInputControl`, `StyleToggleControl`, and `StyleActionButton`.
   - Remove hardcoded font names (e.g. `'Noto Sans'`) to rely on system default font configuration across Linux distributions.

3. **Incremental Migration**:
   - Refactor `optiscaler_tab.pas`, `vkbasalt_tab.pas`, and `mangohud_ui.pas` to use the unified helper procedures and design tokens from `themeunit.pas`, eliminating duplicate local styling methods (`DarkCombo`, `DarkCheck`, `DarkRadio`, `DarkLbl`).

## Impact
- Delivers complete visual uniformity in font sizes, typography colors, baseline alignment, and card header styling across all tabs.
- Significantly simplifies maintenance by allowing global design or theme updates from a single unit.
