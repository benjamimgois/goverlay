# Change Proposal: UI Quality of Life Enhancements (`ui-qol-enhancements`)

## Problem
1. **Unclear Card Badges**: Game cards in the Games tab display tool badges (`M`, `V`, `O`, `T`), but hovering over them does not show explicit tooltips explaining what each badge means.
2. **Missing Toggle Feedback**: Toggling sidebar tool switches (MangoHud, vkBasalt, OptiScaler, Tweaks) changes button color but provides no status toast feedback informing the user of the state change for the active game or global profile.
3. **No Quick Reset on vkBasalt Tab**: Unlike the vkSumi tab which includes a "Restore Defaults" button (`FVsRestoreBtn`), the vkBasalt tab lacks a quick way to reset all effect sliders (CAS, FXAA, SMAA, DLS) back to default zero positions.

## Solution
All user-facing text, tooltips, and status messages SHALL be in **English**:
1. Add descriptive hints/tooltips to game card badge icons: `"MangoHud: Enabled"`, `"vkBasalt: Enabled"`, `"OptiScaler: Enabled"`, and `"Tweaks: Enabled"`.
2. Display status toast messages when toggling sidebar tool switches (e.g. `"MangoHud enabled for <GameName>"`, `"vkBasalt disabled globally"`).
3. Add a "Restore Defaults" button to the vkBasalt tab that resets all trackbars (`casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, `dlsTrackBar`) and value labels back to `0`.
