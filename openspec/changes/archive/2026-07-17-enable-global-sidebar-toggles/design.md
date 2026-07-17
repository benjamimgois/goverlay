## Context

Currently, the ON/OFF tool toggles (speed buttons) in the GOverlay navigation sidebar are only visible in per-game configuration mode. In global mode, all configuration tabs are enabled, and the toggles are hidden. The user wants the toggles to be displayed in global mode, enabling the same activation/deactivation workflow as in per-game mode, while keeping the toggles hidden on the main "Games" landing tab.

## Goals / Non-Goals

**Goals:**
- Make sidebar tool toggles visible in global configuration tabs.
- Hide sidebar tool toggles when on the "Games" tab.
- When toggling a tool OFF globally, delete its configuration file and grey out its configuration tab controls.
- When toggling a tool ON globally, enable the configuration tab controls for editing and saving.

**Non-Goals:**
- Implementing global toggles for OptiScaler or Tweaks (which are only available per-game and whose tabs are hidden in global configuration mode).

## Decisions

### Decision 1: Toggle Visibility Condition

We will update the toggle visibility check in `TSidebarNavHelper.UpdateNavToolToggleVisibility` to check `FNavActive` (the index of the active sidebar navigation item) instead of `FActiveGameName <> ''`.

- **Chosen implementation**:
  `ShouldShow := FForm.FNavActive <> 0;` (since index 0 is the Games tab).

### Decision 2: Global Toggle State Resolution

In `TSidebarNavHelper.LoadGameToggleStates`, if `FActiveGameName` is empty (global mode):
- The MangoHud toggle state will be resolved based on `FileExists(MANGOHUDCFGFILE)`.
- The vkBasalt toggle state will be resolved based on `FileExists(VKBASALTCFGFILE)`.
- OptiScaler and Tweaks toggles will default to `False` (disabled).
- We will call `ApplyToolEnabledState` to set the UI inputs enabled/disabled state based on the resolved toggle states.

### Decision 3: Global Toggle Click Handler

In `TSidebarNavHelper.NavToolToggleClick`:
- If `FActiveGameName` is empty (global mode) and the tool is toggled OFF, we will delete the corresponding global configuration file (`MANGOHUDCFGFILE` or `VKBASALTCFGFILE`) and call `ApplyToolEnabledState(Idx, False)` to grey out the controls.

## Risks / Trade-offs

- **[Risk] Unintentional global configuration loss** → Toggling a tool OFF globally deletes the configuration file.
  * *Mitigation*: The user explicitly chose to match the game mode behavior where configuration files are deleted when disabled.
