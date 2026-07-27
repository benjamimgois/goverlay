## Context

When clicking a game card on the Games tab, `GameCardClick` sets up paths for MangoHud (`MANGOHUDCFGFILE`) and OptiScaler (`FGModPath`), but omits `VKBASALTCFGFILE` and `VKSUMICFGFILE`. These were previously only assigned when `vkbasaltLabelClick` was triggered by clicking the sidebar tab.

## Goals / Non-Goals

**Goals:**
- Atomically assign `VKBASALTCFGFILE` and `VKSUMICFGFILE` inside `GameCardClick` in `games_tab.pas`.
- Ensure all four tool configuration paths (`MANGOHUDCFGFILE`, `VKBASALTCFGFILE`, `VKSUMICFGFILE`, `FGModPath`) are in sync upon game card selection.
- Add GUI tests asserting that all config path variables match the selected game directory.

**Non-Goals:**
- Changing file reading or format parsing.

## Decisions

- **Decision**: Update `GameCardClick` in `games_tab.pas` to execute:
  ```pascal
  VKBASALTCFGFILE := GameCfgDir + 'vkBasalt.conf';
  VKSUMICFGFILE := GameCfgDir + 'vkSumi.conf';
  ```
  right after `MANGOHUDCFGFILE := GameCfgDir + 'MangoHud.conf';`.
