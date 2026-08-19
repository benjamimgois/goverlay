## Context

See `proposal.md` for motivation. In GOverlay, tab activation handlers (`OnShow`) synchronize tool-enabled states and floating action dock visibility. Previously, `losslessScalingTabSheetShow` invoked `SetSaveBtnEnabled(FNavToolEnabled[2])` before loading configuration from disk. Because `SetSaveBtnEnabled` calls `TriggerAutoSave` whenever `FLoadingConfig` is `False`, the active in-memory controls were saved into the target game directory, overwriting the game's configuration with stale data from the previous tab/mode.

## Goals / Non-Goals

**Goals:**
- Guarantee strict configuration isolation between Global mode (`gameconfig/global/`) and per-game profiles (`gameconfig/<game>/`).
- Eliminate premature auto-saving during tab transitions by wrapping tab show routines in `FLoadingConfig := True` and loading the target configuration before enabling save buttons or UI reflow.
- Prevent `SaveMangoHudConfig` from executing when saving from the Lossless Scaling tab.

**Non-Goals:**
- Changing the schema of `lsfg.toml` or `bgmod.conf`.
- Modifying other tabs' configuration persistence mechanisms.

## Decisions

### 1. Guard `losslessScalingTabSheetShow` with `FLoadingConfig`
- **Choice**: In `losslessScalingTabSheetShow`, immediately load configuration via `LoadLosslessConfig` while `FLoadingConfig` is `True`, and only invoke `SetSaveBtnEnabled` / dock updates after data has been populated.
- **Rationale**: Prevents `SetSaveBtnEnabled` from triggering an auto-save while UI controls still hold previous context data.

### 2. Early-Exit for Lossless Scaling in `saveBitBtnClick`
- **Choice**: In `overlayunit.pas` (`saveBitBtnClick`), position the Lossless Scaling save check alongside `tweaksTabSheet` and `optiscalerTabSheet`:
  ```pascal
  if (goverlayPageControl.ActivePage = losslessScalingTabSheet) and Assigned(FLosslessScalingHelper) then
  begin
    TLosslessScalingTabHelper(FLosslessScalingHelper).SaveLosslessConfig;
    Exit;
  end;
  ```
- **Rationale**: Prevents `saveBitBtnClick` from falling through into the MangoHud save block (`SaveMangoHudConfig`).

### 3. Ensure Consistent Global Path in `WriteLsfgTomlConfig`
- **Choice**: In `TLosslessScalingTabHelper.WriteLsfgTomlConfig`, when `ATargetDir = ''` and `FActiveGameName = ''`, set `OutDir := Tgoverlayform(FForm).GetGameConfigDir('')` instead of `TConfigManager.GetGoverlayFolder`.
- **Rationale**: Aligns default directory resolution with `GetConfigFile` (`~/.local/share/goverlay/gameconfig/global/`).

## Risks / Trade-offs

- **[Risk]** Existing stale `lsfg.toml` files created in game folders during previous test sessions might still exist on disk.
  → **Mitigation**: Once isolated, users can configure different settings on Global and Games, and each profile will correctly maintain and save its own independent values.
