# Design: Add Preview Pill and LSFG-VK Environment to 3D Preview on Lossless Scaling Tab

## Context

GOverlay uses a unified floating action dock (`FFADock: TFloatingActionDock`) to provide quick actions across tabs. On the MangoHud and vkBasalt tabs, the dock displays `[ 👁 Preview ]` to launch `pascube` or `vkcube`.
On the Lossless Scaling tab (`losslessScalingTabSheet`), `FFADock.UpdateForTab(False, False, False)` previously hid the Preview button.
Additionally, the preview command builder in `overlayunit.pas` (`PreviewBtnClick`, `runpascubetItemClick`, `runvkcubeItemClick`) only injected `GetMangoHudLaunchEnv`, `GetVkBasaltLaunchEnv`, and `GetVkSumiLaunchEnv`.

## Goals / Non-Goals

**Goals:**
- Enable the Preview button in `FFADock` when the Lossless Scaling tab is active.
- Create `GetLosslessScalingLaunchEnv: string;` in `overlayunit.pas` to dynamically retrieve `TLosslessScalingTabHelper(FLosslessScalingHelper).BuildEnvLine`.
- Inject `GetLosslessScalingLaunchEnv` into `PreviewBtnClick`, `runpascubetItemClick`, and `runvkcubeItemClick`.

**Non-Goals:**
- Modifying `pascube` source code or PasVulkan engine internals.

## Decisions

### 1. Update Floating Action Dock on Tab Selection
In `overlayunit.pas` (`losslessScalingTabSheetShow`):
```pascal
if Assigned(FFADock) then
  FFADock.UpdateForTab(True, False, False);
```
In `overlayunit.pas` (`optiscalerLabelClick`):
```pascal
if goverlayPageControl.ActivePage = losslessScalingTabSheet then
begin
  if Assigned(FFADock) then FFADock.UpdateForTab(True, False, False);
end
else
begin
  if Assigned(FFADock) then FFADock.UpdateForTab(False, False, False);
end;
```

### 2. Implement GetLosslessScalingLaunchEnv
In `overlayunit.pas`:
```pascal
function Tgoverlayform.GetLosslessScalingLaunchEnv: string;
var
  EnvStr: string;
begin
  Result := '';
  if (FActiveGameName <> '') and not FNavToolEnabled[2] then
    Exit;
  if (FActiveGameName = '') and not FNavToolEnabled[2] then
    Exit;
  if Assigned(FLosslessScalingHelper) then
  begin
    EnvStr := TLosslessScalingTabHelper(FLosslessScalingHelper).BuildEnvLine;
    if EnvStr <> '' then
      Result := EnvStr + ' ';
  end;
end;
```

### 3. Inject into Preview Launchers
In `PreviewBtnClick`:
```pascal
ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + GetLosslessScalingLaunchEnv + GetGOverlayPackageEnv + GetPasCubeCommand + ' --version "' + GVERSION + '"' + GetPasCubeNicknameParam + ' &');
```
and for `vkcube`:
```pascal
ExecuteGUICommand(GetMangoHudLaunchEnv + GetVkBasaltLaunchEnv + GetVkSumiLaunchEnv + GetLosslessScalingLaunchEnv + 'vkcube &');
```
Same for `runpascubetItemClick` and `runvkcubeItemClick`.
