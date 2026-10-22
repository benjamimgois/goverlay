# Design

## Context

In `reshade_tab.pas`, the Post Processing interface currently splits the top row 50/50 between `FMethodCard` (left) and an options card (`FConfigCard` for ReShade, or `FVkToggleCard` for vkBasalt) on the right.

In `optiscaler_tab.pas`, Goverlay previously established a spacious full-width pattern for `FOsUpscalerCard` ("Method"), dividing its inner width into three equal slots (`SlotW := InnerW div 3`) and centering each radio button and logo within its slot.

This design brings the same full-width layout to the Post Processing tab, creates a compact single-row options bar for ReShade, and removes the redundant options card from vkBasalt.

## Goals / Non-Goals

**Goals:**
- Make `FMethodCard` span full available content width (`CW`), using 3 equal symmetrical slots for **None**, **ReShade**, and **vkBasalt**.
- Redesign `FConfigCard` ("Options") for ReShade as a compact full-width card (~56px height) placed directly beneath `FMethodCard`, with `Toggle: [ ⌨ Home ]` and `Proxy DLL: [ ... ▾ ]` aligned horizontally on a single line.
- Completely eliminate `FVkToggleCard` from the vkBasalt view (`rmVkBasalt`), allowing `FVkReshadeCard` to position immediately below `FMethodCard` and gain the freed vertical height.
- Update `ReflowReShadeTab` and layout reflow to maintain precise dynamic heights and prevent vertical scrollbar churn.
- Update any existing GUI test cases in `tests/gui/gui_test_cases.pas` to match the new layout structure.

**Non-Goals:**
- Modifying backend configuration serialization for vkBasalt (vkBasalt continues to use its default key mapping).
- Changing shader package download mechanisms, Wine path translation, or bgmod deployment.
- Modifying the standalone vkSumi tab.

## Decisions

### 1. Symmetrical 3-Slot Grid for Method Card
- **Choice**: Divide `InnerW := CW - 2 * CARD_P` by 3 (`SlotW := InnerW div 3`). Calculate centered horizontal positions for each (Radio + Logo) pair:
  - Column 1: `X1 := CARD_P + (SlotW - GroupW_None) div 2`
  - Column 2: `X2 := CARD_P + SlotW + (SlotW - GroupW_Reshade) div 2`
  - Column 3: `X3 := CARD_P + 2 * SlotW + (SlotW - GroupW_VkBasalt) div 2`
- **Rationale**: Replicates the clean, balanced presentation of the OptiScaler Method card and adapts dynamically to any window resizing.

### 2. Compact Single-Row Layout for ReShade Options
- **Choice**: Set `OPTIONS_H = 56` for `FConfigCard`. Place `FToggleTitleLbl` and `FToggleBtn` on the left half, and `FProxyTitleLbl` and `FProxyComboBox` on the right half within the same vertical band (`Y ~ 14..18`).
- **Rationale**: Avoids pushing the Shaders card too far down while keeping runtime proxy DLL selection and toggle key capture prominent and easy to access.

### 3. Elimination of Options Card in vkBasalt
- **Choice**: When `rmVkBasalt` is active, explicitly set `MainForm.FVkToggleCard.Visible := False`. Position `MainForm.FVkReshadeCard` starting at `CurY := TopRowY + TOP_ROW_H + CARD_GAP`.
- **Rationale**: Per user decision (Option A), removing the Toggle key capture and Restore Defaults buttons gives all available vertical space directly to the effects list, eliminating unnecessary visual clutter.

## Risks / Trade-offs

- **[Risk] Existing GUI tests asserting `FVkToggleCard` or `FVkRestoreBtn` presence in unified post-processing tab may fail.**
  - **Mitigation**: Inspect and update tests in `tests/gui/gui_test_cases.pas` to assert that `FVkToggleCard` is hidden when `rmVkBasalt` is selected in the ReShade tab.
- **[Risk] Controls overlapping in ReShade Options on narrow window sizes.**
  - **Mitigation**: Calculate dynamic width for `FProxyComboBox` with minimum bounds (`Max(120, ...)`), or stack smoothly if width is extremely constrained.
