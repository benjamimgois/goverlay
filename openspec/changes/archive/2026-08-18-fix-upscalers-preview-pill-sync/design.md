## Context

See `proposal.md` for motivation. Currently, in `overlayunit.pas`:
- `optiscalerTabSheet` is defined in `overlayunit.lfm` without an `OnShow` event.
- `losslessScalingTabSheet` is dynamically created in `FormCreate` and has `OnShow := @losslessScalingTabSheetShow`.
- `losslessScalingTabSheetShow` calls `FFADock.UpdateForTab(True, False, False)`, showing the Preview pill.
- When switching from Lossless Scaling to OptiScaler, no `OnShow` event fires on `optiscalerTabSheet`, so `FFADock` never resets and the Preview button remains visible.
- In `optiscalerLabelClick`, navigation forces OptiScaler logic unconditionally even when `losslessScalingTabSheet` was the active page.

## Goals / Non-Goals

**Goals:**
- Provide a dedicated `optiscalerTabSheetShow` event handler on `optiscalerTabSheet.OnShow` that configures `FFADock.UpdateForTab(False, False, False)`, refreshes enabled states, and loads OptiScaler configs.
- Update `losslessScalingTabSheetShow` and `optiscalerLabelClick` so that dock state and layout reflow remain in perfect symmetry.

**Non-Goals:**
- Changing other sidebar categories or floating dock functionality on other tabs.
- Modifying `lsfg-vk` or `optiscaler` execution logic.

## Decisions

### Decision 1: Create `optiscalerTabSheetShow` and assign `optiscalerTabSheet.OnShow`
- **Choice**: Add `procedure optiscalerTabSheetShow(Sender: TObject)` in `Tgoverlayform` and assign `optiscalerTabSheet.OnShow := @optiscalerTabSheetShow` in `FormCreate`.
- **Rationale**: Matches the architecture used by all other tab sheets in GOverlay (`vkbasaltTabSheetShow`, `vkSumiTabSheetShow`, `tweaksTabSheetShow`, `performanceTabSheetShow`, `losslessScalingTabSheetShow`).
- **Alternative considered**: Using `goverlayPageControl.OnChange`. However, LCL `TPageControl.OnChange` fires alongside `OnShow` and could duplicate executions or conflict with existing `OnShow` event handlers.

### Decision 2: Symmetrize `optiscalerLabelClick`
- **Choice**: When clicking the "Upscalers" sidebar icon, make both sub-tabs visible (`optiscalertabsheet.TabVisible := True`, `losslessScalingTabSheet.TabVisible := True`), ensure `goverlayPageControl.ActivePage` is valid, and delegate to the active sub-tab's show handler.
- **Rationale**: Prevents executing OptiScaler reload and reflow routines while the user is looking at the Lossless Scaling sub-tab.

## Risks / Trade-offs

- **[Risk] Multiple calls to `CheckForUpdatesOnClick`**: If `optiscalerTabSheetShow` runs repeatedly on tab switches, it could trigger duplicate network checks.
  → **Mitigation**: `FOptiscalerUpdate.CheckForUpdatesOnClick` already handles async cooldown/deduplication.
