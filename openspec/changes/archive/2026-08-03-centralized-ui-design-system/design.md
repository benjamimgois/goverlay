# Design: Centralized UI Design System in themeunit

## Architecture Overview

Currently, each tab helper unit manages its own local styling routines:

```
[ mangohud_ui.pas ]  ──▶ Local DarkCombo/DarkCheck/MakeCard (Hardcoded fonts/sizes)
[ optiscaler_tab.pas ] ──▶ Local DarkCombo/DarkCheck/MakeCard (Hardcoded fonts/sizes)
[ vkbasalt_tab.pas ]   ──▶ Local TitleLbl.Font.Name := 'Noto Sans' (Hardcoded fonts/sizes)
```

We will refactor `themeunit.pas` to expose a unified Design System API, making `themeunit.pas` the single source of truth:

```
                      ┌───────────────────────────┐
                      │      themeunit.pas        │
                      │  (Design Tokens & Helpers)│
                      └─────────────┬─────────────┘
                                    │
           ┌────────────────────────┼────────────────────────┐
           ▼                        ▼                        ▼
[ mangohud_ui.pas ]     [ optiscaler_tab.pas ]    [ vkbasalt_tab.pas ]
```

## Token Specifications

### 1. Color Palette Tokens (BGR Format)
- `DARK_TAB_BG        = $00281A16` (rgb(22, 26, 40) - Tab canvas)
- `DARK_CARD_BG       = $002E1E1A` (rgb(26, 30, 46) - Card fill)
- `DARK_CARD_BORDER   = $00342620` (rgb(32, 38, 52) - Card border)
- `DARK_INPUT_BG      = $00482E26` (rgb(38, 46, 72) - ComboBox/Edit fill)
- `DARK_INPUT_BORDER  = $006C4637` (rgb(55, 70, 108) - ComboBox/Edit border)

### 2. Typography Color Tokens
- `CLR_TEXT_PRIMARY   = clWhite`   (10pt Bold Card Titles & Primary text)
- `CLR_TEXT_SECONDARY = $00CCAAAA` (8pt Bold Sub-Card Headers)
- `CLR_TEXT_MUTED     = $00AAAAAA` (9pt Regular Control Labels & hints)
- `CLR_TEXT_HIGHLIGHT = $00FF99BB` (8pt Regular Version & Key tags)
- `CLR_TEXT_ACCENT    = $00F0BE30` (Cyan accents & links)
- `CLR_TEXT_SUCCESS   = $0066CC44` (Green status)

### 3. Typography Scale Tokens
- `FONT_SZ_CARD_HDR   = 10` (Level 1 Card Header - Bold)
- `FONT_SZ_SEC_HDR    = 8`  (Level 2 Sub-Card Header - Bold)
- `FONT_SZ_CONTROL    = 9`  (Form controls, CheckBoxes, RadioButtons, ComboBoxes - Regular)
- `FONT_SZ_HINT       = 8`  (Auxiliary hints and secondary badges - Regular)

### 4. Layout Metric Tokens
- `LAYOUT_MARGIN      = 4`  (Outer scrollbox padding)
- `LAYOUT_GAP         = 6`  (Gap between cards & sub-cards)
- `LAYOUT_PAD         = 12` (Inner card padding)
- `LAYOUT_HDR_HEIGHT  = 34` (Top card header height)
- `LAYOUT_ROW_HEIGHT  = 26` (Standard control row height)
- `LAYOUT_BTN_HEIGHT  = 28` (Standard button height)

## Global Styling Helpers API (`themeunit.pas`)

```pascal
type
  TUiLabelRole = (lrCardTitle, lrSectionTitle, lrControlLabel, lrMutedHint, lrHighlight, lrStatusOk);

procedure StyleMainCard(ACard: TPanel; ATitleLbl: TLabel; const ATitle: string);
procedure StyleSubCard(ASubCard: TPanel; AHeaderLbl: TLabel; const ATitle: string);
procedure StyleLabel(ALabel: TLabel; ARole: TUiLabelRole);
procedure StyleInputControl(AControl: TWinControl);
procedure StyleToggleControl(AControl: TControl);
procedure StyleActionButton(AButton: TControl);
```
