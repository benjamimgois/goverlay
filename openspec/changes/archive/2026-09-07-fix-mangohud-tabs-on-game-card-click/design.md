## Context

See `proposal.md` for motivation. In [`games_tab.pas`](file:///mnt/NVME/Software/goverlay/games_tab.pas), [`TGamesTabHelper.GameCardClick`](file:///mnt/NVME/Software/goverlay/games_tab.pas#L2169) handles user selection of a game card. It extracts the game name, initializes per-game directories, seeds `bgmod` wrapper scripts, reloads OptiScaler status, updates config file path variables (`MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, `VKSUMICFGFILE`), and updates the game context label.

Previously, lines 2247–2262 attempted to switch the UI into MangoHud configuration mode via manually inlined statements:
```pascal
SetNavActive(1);
goverlayPageControl.ShowTabs := True;
vkbasalttabsheet.TabVisible  := False;
optiscalertabsheet.TabVisible := False;
losslessScalingTabSheet.TabVisible := False;
tweakstabsheet.TabVisible    := False;
gamesTabSheet.TabVisible     := False;
goverlayPageControl.ActivePage := presetTabsheet;
...
```
This inlined logic omitted restoring `TabVisible := True` on the 5 MangoHud tabs (`presetTabSheet`, `visualTabSheet`, `performanceTabSheet`, `metricsTabSheet`, `extrasTabSheet`) and omitted hiding `vksumiTabSheet` and `FHomeTabSheet`.

## Goals / Non-Goals

**Goals:**
- Delegate MangoHud tab activation in `GameCardClick` to `FForm.mangohudLabelClick(nil)`.
- Ensure all MangoHud tabs are always visible in the top tab bar when entering game configuration.
- Preserve the existing post-navigation update of `FLaunchCommand` and `commandPaintBox.Invalidate`.
- Add automated GUI regression testing in `tests/gui/gui_test_cases.pas`.

**Non-Goals:**
- Modifying how `mangohudLabelClick` behaves for global mode.
- Changing game library scanning, cover fetching, or script seeding.

## Decisions

### Decision 1: Delegate to `FForm.mangohudLabelClick(nil)` instead of manual inlined assignments
- **Rationale**: `mangohudLabelClick` is the single source of truth for entering MangoHud configuration. It already correctly handles:
  - Setting `MANGOHUDCFGFILE` based on `FActiveGameName`
  - `SetNavActive(1)`
  - Enabling `ShowTabs := True`
  - Setting `TabVisible := True` for all 5 MangoHud tabs
  - Hiding all non-MangoHud tabs (`vkbasalt`, `vksumi`, `optiscaler`, `losslessScaling`, `tweaks`, `games`, `home`)
  - Activating `presetTabSheet`
  - Updating the floating action dock (`FFADock.UpdateForTab(True, True, False)`)
  - Updating tool enabled states (`ApplyToolEnabledState(0, FNavToolEnabled[0])`) and save button state
- **Alternative considered**: Adding manual `presetTabSheet.TabVisible := True`, etc., to `GameCardClick`. Rejected because it duplicates ~20 lines of navigation state logic between `games_tab.pas` and `overlayunit.pas`, leading to future desynchronization.

## Risks / Trade-offs

- **[Risk] Redundant config reload**: `mangohudLabelClick` calls `LoadMangoHudConfig`.
  - **Mitigation**: `GameCardClick` already called `LoadMangoHudConfig` in its previous implementation, so delegating introduces zero additional overhead.

- **[Risk] Launch command synchronization**: `FLaunchCommand` must reflect the newly selected game immediately.
  - **Mitigation**: Keep `FLaunchCommand := GetLaunchCommand; if Assigned(commandPaintBox) then commandPaintBox.Invalidate;` immediately following the call to `mangohudLabelClick(nil)`.
