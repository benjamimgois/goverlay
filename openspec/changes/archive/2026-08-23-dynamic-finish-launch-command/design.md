## Context

See `proposal.md` for background. The legacy GOverlay UI displayed the Steam launch command in a fixed bottom bar (`goverlaybarPanel`) that repainted on every manual save. During the transition to the modern Floating Action Dock (`FFADock`) and the modal Finish Configuration dialog (`TFinishDialogForm`), the dock's Finish button (`DockFinishClick`) was wired directly to pass `FLaunchCommand`.

Because `FLaunchCommand` is only updated in select manual save routines and is bypassed by modern auto-save handlers and game card navigation, clicking "Finish" while viewing a game configuration routinely displays the stale global command (`gameconfig/global/bgmod`).

## Goals / Non-Goals

**Goals:**
- Guarantee that the Finish Configuration dialog always displays the exact launch command corresponding to the active profile (global or per-game) and launcher type (Steam or Non-Steam/Heroic).
- Centralize launch command string construction in a single helper method (`GetLaunchCommand`) to eliminate duplicate code across tabs and save handlers.
- Retain support for optional launch options such as `gamemoderun` and RE Engine RT workaround suffix.

**Non-Goals:**
- Changing the binary wrapper syntax or argument structure of `bgmod`.
- Altering the UI design or layout of `TFinishDialogForm`.

## Decisions

### 1. Centralized Dynamic Launch Command Helper
Implement `Tgoverlayform.GetLaunchCommand: string` in `overlayunit.pas`:

```pascal
function Tgoverlayform.GetLaunchCommand: string;
var
  Cmd: string;
begin
  if FActiveGameName <> '' then
  begin
    if FActiveGameIsNonSteam then
      Cmd := GetGameConfigDir(FActiveGameName) + 'bgmod '
    else
      Cmd := '"' + GetGameConfigDir(FActiveGameName) + 'bgmod" ';
  end
  else
    Cmd := '"' + GetGameConfigDir('') + 'bgmod" ';

  // Gamemode prefix
  if GetPerformanceCheckBox(0).Checked then
    Cmd := Cmd + ENV_GAMEMODERUN + ' ';

  // Steam launch command suffix (%command%)
  if not ((FActiveGameName <> '') and FActiveGameIsNonSteam) then
    Cmd := Cmd + LAUNCH_COMMAND_SUFFIX;

  // RE Engine RT workaround suffix
  if Assigned(FReEngineRTCheckBox) and FReEngineRTCheckBox.Checked then
    Cmd := Cmd + LAUNCH_SUFFIX_WINE_DETECTION;

  Result := Cmd;
end;
```

### 2. On-Demand Resolution in `DockFinishClick`
Update `Tgoverlayform.DockFinishClick` to invoke `GetLaunchCommand` directly:

```pascal
procedure Tgoverlayform.DockFinishClick(Sender: TObject);
begin
  ShowFinishDialog(Self, GetLaunchCommand, FActiveGameName, FActiveGameIsNonSteam);
end;
```

### 3. Unify Redundant Save Handler Builders
Refactor existing command building in `SaveVkSumiConfig`, `SaveVkBasaltConfig`, `SaveTweaksConfig`, and `saveBitBtnClick` to call `GetLaunchCommand` when updating `FLaunchCommand` and repainting the legacy/fallback command box.

## Risks / Trade-offs

- **[Risk]** Potential desync between `FLaunchCommand` (if referenced elsewhere) and `GetLaunchCommand`.
  → **Mitigation**: Update all remaining references to `FLaunchCommand` to use `GetLaunchCommand`, or assign `FLaunchCommand := GetLaunchCommand` in `GetLaunchCommand`.
