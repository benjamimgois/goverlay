# Change Proposal: Synchronize Game Profile Config Paths on Game Selection (`sync-game-profile-config-paths`)

## Problem
When a game card is selected in the Games tab (`GameCardClick` in `games_tab.pas`), GOverlay sets `FActiveGameName` and updates `MANGOHUDCFGFILE` and `FOptiscalerUpdate.FGModPath`. However, it does not update `VKBASALTCFGFILE` or `VKSUMICFGFILE` until the user manually clicks the vkBasalt sidebar tab (`vkbasaltLabelClick`).

If background operations, preview actions (`FPreviewBtn`), or status queries execute after selecting a game card but before clicking the vkBasalt tab, they target the global vkBasalt/vkSumi paths instead of the selected game's config directory.

## Solution
1. Update `GameCardClick` in `games_tab.pas` to assign `VKBASALTCFGFILE := GameCfgDir + 'vkBasalt.conf'` and `VKSUMICFGFILE := GameCfgDir + 'vkSumi.conf'` upon game card selection.
2. Add a GUI test verifying that `VKBASALTCFGFILE` and `VKSUMICFGFILE` point to the game config directory immediately after game card selection.
