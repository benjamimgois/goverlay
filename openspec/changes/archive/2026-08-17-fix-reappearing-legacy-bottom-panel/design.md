## Context

See `proposal.md` for background. GOverlay transitioned to a floating action pill dock (`FFADock`) and modal Finish dialog (`FFinishDialog`), with `goverlaybarPanel.Visible := False` set during initialization. However, legacy visibility calls in `games_tab.pas` (`GameCardClick`) and scattered configuration save routines were still toggling `goverlaybarPanel.Visible := True` and `commandPanel.Visible := True`, causing the legacy bottom bar to reappear when selecting game cards or saving configs.

## Goals / Non-Goals

**Goals:**
- Update `GameCardClick` in `games_tab.pas` to configure `FFADock` via `FFADock.UpdateForTab(True, True, False)` and maintain `goverlaybarPanel.Visible = False`.
- Eliminate all remaining `commandPanel.Visible := True` calls across `overlayunit.pas`, `optiscaler_tab.pas`, and `tweaks_md3.pas`.
- Add an automated GUI test verifying that selecting a game card keeps `goverlaybarPanel` hidden while keeping `FFADock` visible.

**Non-Goals:**
- Deleting the `goverlaybarPanel` control from `overlayunit.lfm` in this change (controls remain instantiated and permanently hidden to avoid streaming or anchoring regressions).
- Modifying the visual appearance or behavior of `FFADock` or `FFinishDialog`.

## Decisions

### Decision 1: Use `FFADock.UpdateForTab` in `GameCardClick`
- **Context**: When a user clicks a game card, GOverlay transitions from `gamesTabSheet` to `presetTabsheet` (MangoHud tab).
- **Choice**: Replace legacy lines (setting `goverlaybarPanel`, `popupBitBtn`, and `FPreviewBtn` visible) with `if Assigned(FFADock) then FFADock.UpdateForTab(True, True, False);`.
- **Alternatives Considered**: Triggering `mangohudLabelClick(nil)` directly. Not chosen because `GameCardClick` performs specific game-directory seeding and OptiScaler status binding that would conflict with global defaults.

### Decision 2: Remove `commandPanel.Visible := True` from Save Routines
- **Context**: In `SaveMangoHudConfig`, `SaveVkBasaltConfig`, `SaveOptiScalerConfig`, `SaveTweaksConfig`, and `saveBitBtnClick`, `commandPanel.Visible := True` was historically used to display the Steam launch command.
- **Choice**: Remove `commandPanel.Visible := True` from these methods. Configuration saving is already confirmed by `ShowSavedStatus` (floating auto-save toast), and the launch command is viewed via the modal `Finish Config` dialog.
- **Alternatives Considered**: Leaving `commandPanel.Visible := True` while keeping parent `goverlaybarPanel.Visible := False`. Deprecated because if any parent panel ever becomes visible or is repainted, the child might flash or trigger layout recalculations.

## Risks / Trade-offs

- **[Risk]** Potential breakage of existing tests expecting `commandPanel` to be visible.
  - **Mitigation**: Existing GUI tests specifically verify `goverlaybarPanel.Visible = False` across all tabs. Tests will be verified before and after the change.
