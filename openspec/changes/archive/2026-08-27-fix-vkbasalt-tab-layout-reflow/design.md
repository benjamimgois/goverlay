## Context

The vkBasalt tab contains 3 stacked cards:
1. `FVkReshadeCard`: Dynamic height (`RSHD_H`), scrollable list of ReShade shader toggles.
2. `FVkBuiltinCard`: Fixed height (170px), sliders for CAS, FXAA, SMAA, DLS.
3. `FVkToggleCard`: Fixed height (85px), title label + action buttons for Toggle key, Restore Defaults, and Sync Shaders.

Currently, `vkbasaltTabSheetShow` does not invoke `ReflowVkBasaltTab`, leaving card geometry reliant on the initial form create reflow where `vkbasaltTabSheet` was hidden (resulting in an overestimated fallback height).

## Goals / Non-Goals

**Goals:**
- Trigger `ReflowVkBasaltTab` whenever `vkbasaltTabSheet` is shown.
- Align `vkbasaltLabelClick` sequencing with standard tab switching patterns across the application.
- Improve fallback height calculation when the tab sheet client height is not yet available.

**Non-Goals:**
- Redesigning the card layout or changing visual styles.

## Decisions

### Decision 1: Call `ReflowVkBasaltTab` in `vkbasaltTabSheetShow`
In `overlayunit.pas`, compute `ContentW := vkbasaltTabSheet.ClientWidth` (with minimum width clamp) and call `ReflowVkBasaltTab(ContentW)` inside `vkbasaltTabSheetShow`.

### Decision 2: Reorder tab activation in `vkbasaltLabelClick`
In `vkbasaltLabelClick`, show the tabs (`ShowTabs := True`, `vkbasalttabsheet.TabVisible := True`, `ActivePage := vkbasaltTabsheet`) before invoking `SetNavActive(2)`, ensuring that `ApplyNavWidth` and `ReflowVkBasaltTab` observe the active and visible tab state.

### Decision 3: Refine height fallback in `ReflowVkBasaltTab`
In `vkbasalt_tab.pas`, if `vkbasaltTabSheet.ClientHeight < 150`, use `goverlayPageControl.ClientHeight - 32` (or form height minus header/margins) to calculate a more accurate tab height.
