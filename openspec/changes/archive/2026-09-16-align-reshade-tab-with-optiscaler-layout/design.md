## Context

The ReShade tab helper (`reshade_tab.pas`) currently builds three cards: `FStatusCard` (Top: 12), `FShadersCard` (Top: 179), and `FConfigCard` (Top: 581). This layout places runtime metadata first, whereas the OptiScaler and Lossless Scaling tabs in GOverlay place user configuration at the top, modular components in the center, and the "Software Status" card at the base.

## Goals / Non-Goals

**Goals:**
- Invert the card hierarchy: place **"Config"** at the top, **"Shaders"** in the middle, and **"Software status"** at the base.
- Move the **"Open Shaders Directory"** button to the header of the "Shaders" card (Option A), aligned to the right.
- Align visual appearance with OptiScaler by applying `StyleMainCard` and `SubCardPaint` on card panels.
- Preserve all existing public properties on `TReshadeTabHelper` (`StatusCard`, `ShadersCard`, `ConfigCard`, etc.) to maintain complete backward compatibility with tests.

**Non-Goals:**
- Modify backend ReShade runtime acquisition, Wine path translations, or `bgmod` deployment routines.
- Change existing shader packs or configuration key names in `ReShade.ini` or `bgmod.conf`.

## Decisions

### 1. Card Order and Dynamic Sizing
- **Card 1: "Config"** (`FConfigCard`)
  - Title: `"Config"` styled via `StyleMainCard(FConfigCard, FConfigTitleLbl, 'Config')`.
  - Position: `Top := 12`, `Height := 235`.
  - Controls: `FEnableCheckBox`, `FHotkeyComboBox`, `FProxyComboBox`, `FProtonPathLbl`, `FOptiCoexistLbl`.
- **Card 2: "Shaders"** (`FShadersCard`)
  - Title: `"Shaders"` styled via `StyleMainCard(FShadersCard, FShadersTitleLbl, 'Shaders')`.
  - Position: `Top := FConfigCard.Top + FConfigCard.Height + CARD_GAP` (Top ~259), `Height := 410`.
  - Controls: `FOpenShadersBtn` in top right header; 5 shader collection rows (`FPackPanels`).
- **Card 3: "Software status"** (`FStatusCard`)
  - Title: `"Software status"` styled via `StyleMainCard(FStatusCard, FStatusTitleLbl, 'Software status')`.
  - Position: `Top := FShadersCard.Top + FShadersCard.Height + CARD_GAP` (Top ~681), `Height := 145`.
  - Controls: `FVersionLbl`, `FDll64Lbl`, `FDll32Lbl`, `FNoticeLbl`, `FUpdateBtn`.
- Container height: `FBgPanel.Height` updated to accommodate all three cards plus bottom margin (~840px).

### 2. Header Placement of "Open Shaders Directory" (Option A)
- `FOpenShadersBtn` reparented to `FShadersCard`.
- Positioned in card header: `Top := 10`, `Height := 28`, `Width := 180`.
- In `ReflowReShadeTab`, anchor/update `FOpenShadersBtn.Left := TargetCardW - CARD_P - FOpenShadersBtn.Width` to ensure responsive alignment at all window sizes.

### 3. Visual Styling Alignment with OptiScaler
- Set `Card.OnPaint := @Tgoverlayform(FForm).SubCardPaint` on `FConfigCard`, `FShadersCard`, and `FStatusCard`.
- Use `StyleMainCard` for standard bold header typography and theme-aware colors (`DARK_CARD_BG` / `LightBackgroundColor`).

## Risks / Trade-offs

- **[Risk]** Responsive reflow desynchronization when resizing the window.
  - **Mitigation:** Update `ReflowReShadeTab` to recalculate `FOpenShadersBtn.Left` and maintain pack rows and card widths together.
- **[Risk]** Test suite regression if card captions or properties change.
  - **Mitigation:** Retain existing property names on `TReshadeTabHelper`; update test assertions that verify card captions if applicable.
