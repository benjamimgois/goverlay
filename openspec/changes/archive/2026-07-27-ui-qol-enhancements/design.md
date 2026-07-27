## Context

This change introduces three user interface quality-of-life improvements:
- Badges tooltips on game cards (`games_tab.pas`).
- Status toast notifications on sidebar tool toggles (`sidebar_nav.pas`).
- Restore Defaults button on vkBasalt tab (`vkbasalt_tab.pas` / `overlayunit.pas`).

All user-facing strings MUST be in English.

## Goals / Non-Goals

**Goals:**
- Add hint tooltips to badge images in game cards (`"MangoHud: Enabled"`, `"vkBasalt: Enabled"`, `"OptiScaler: Enabled"`, `"Tweaks: Enabled"`).
- Invoke `ShowStatusMessage` on sidebar tool toggle state changes with clear English status messages.
- Add a "Restore Defaults" button (`FVkRestoreBtn`) to the vkBasalt tab layout.

**Non-Goals:**
- Modifying underlying configuration file parsers.

## Decisions

### 1. Game Card Badge Tooltips
In `games_tab.pas`, when creating or updating badge icons on game cards:
Set `Hint` and `ShowHint := True` on each badge control:
- `M` -> `"MangoHud: Enabled"`
- `V` -> `"vkBasalt: Enabled"`
- `O` -> `"OptiScaler: Enabled"`
- `T` -> `"Tweaks: Enabled"`

### 2. Sidebar Tool Toggle Status Messages
In `NavToolToggleClick` in `sidebar_nav.pas`:
Construct message string:
- If `FActiveGameName <> ''`: `ToolName + ' ' + Enabled/Disabled + ' for ' + FActiveGameName`
- Else: `ToolName + ' ' + Enabled/Disabled + ' globally'`
Then call `FForm.ShowStatusMessage(Msg)`.

### 3. vkBasalt Restore Defaults Button
In `vkbasalt_tab.pas`:
Add `FVkRestoreBtn: TBitBtn;` to the vkBasalt tab header/layout.
Set caption to `'🔄 Restore Defaults'`, hint to `'Reset all vkBasalt sliders and active effects'`, and onClick handler `VkRestoreBtnClick`.
Inside `VkRestoreBtnClick`:
Clear `acteffectsListBox`, reset trackbars (`casTrackBar`, `fxaaTrackBar`, `smaaTrackBar`, `dlsTrackBar`) to `0`, update labels to `'0'`, and show status message `'🔄 vkBasalt settings restored to defaults'`.
