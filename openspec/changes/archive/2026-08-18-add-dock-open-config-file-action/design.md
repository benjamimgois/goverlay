## Context

See `proposal.md` for motivation. The floating action dock (`TFloatingActionDock`) provides quick contextual actions via pill buttons (`Preview`, `Menu`, `Add`, `Finish`). Currently, the hamburger menu (`[ ☰ ]`) is hidden on OptiScaler, Lossless Scaling, and EnvVars/Tweaks tabs.

## Goals / Non-Goals

**Goals:**
- Provide a universal "Open config file" option at the top of the floating dock hamburger menu (`popsaveMenu`) across all overlay and tweak configuration tabs.
- Ensure the hamburger menu button `[ ☰ ]` is enabled in `FFADock` for all configuration tabs (MangoHud, vkBasalt, vkSumi, OptiScaler, Lossless Scaling, EnvVars).
- Guarantee that the target configuration file exists before opening by triggering a save/scaffold if missing.
- Open the resolved configuration file asynchronously in the user's default desktop editor via `xdg-open`.

**Non-Goals:**
- Modifying the Games tab popup menu (`ShowGamesPopupMenu`), which manages non-Steam game libraries and scanning rather than a configuration file.
- Embedding an in-app text editor inside GOverlay (external editor via `xdg-open` is the intended approach).

## Decisions

### 1. Menu Item Hierarchy and Visibility Control
- **Choice**: Insert `openConfigFileMenuItem: TMenuItem` as the first item in `popsaveMenu` in `overlayunit.lfm` with `Caption := 'Open config file'` and an edit/file icon from `iconsImageList`.
- **Visibility in `popupBitBtnClick`**:
  - `openConfigFileMenuItem.Visible := True` unconditionally for all tabs calling `popupBitBtnClick`.
  - On OptiScaler and Tweaks tabs, show `openConfigFileMenuItem` and `globalenableMenuItem` while keeping MangoHud-only presets and blacklist items hidden.

### 2. Floating Action Dock Tab Configurations
- **Choice**: Standardize `UpdateForTab` calls across all tab switch routines in `overlayunit.pas`:
  - `mangohudLabelClick` / subtabs: `FFADock.UpdateForTab(True, True, False)`
  - `vkbasaltLabelClick` / `vksumiTabSheetShow`: `FFADock.UpdateForTab(True, True, False)`
  - `optiscalerTabSheetShow`: `FFADock.UpdateForTab(False, True, False)`
  - `losslessScalingTabSheetShow`: `FFADock.UpdateForTab(True, True, False)`
  - `tweaksLabelClick`: `FFADock.UpdateForTab(False, True, True)`

### 3. File Resolution and Auto-Save on Open
- **Choice**: In `openConfigFileMenuItemClick`:
  1. Map `goverlayPageControl.ActivePage` to its target file:
     - MangoHud: `MANGOHUDCFGFILE`
     - vkBasalt: `VKBASALTCFGFILE`
     - vkSumi: `VKSUMICFGFILE`
     - OptiScaler: `IncludeTrailingPathDelimiter(GetGameConfigDir(FActiveGameName)) + 'OptiScaler.ini'`
     - Lossless Scaling: `IncludeTrailingPathDelimiter(GetGameConfigDir(FActiveGameName)) + 'lsfg.toml'`
     - Tweaks / EnvVars: `IncludeTrailingPathDelimiter(GetGameConfigDir(FActiveGameName)) + 'bgmod.conf'`
  2. If the file does not exist, ensure parent directory exists (`ForceDirectories`) and trigger the active tab's save routine so the file is populated before opening.
  3. Execute `ExecuteShellCommand('xdg-open ' + QuotedStr(TargetFile) + ' &')`.

## Risks / Trade-offs

- **[Risk]** `xdg-open` blocking UI execution if executed synchronously.
  → **Mitigation**: Launch via background shell execution (`'xdg-open ' + QuotedStr(TargetFile) + ' &'`).
- **[Risk]** Empty or non-existent file opened if user hasn't saved yet on a new profile.
  → **Mitigation**: Pre-check `FileExists`; if missing, automatically create directories and invoke active tab save logic before calling `xdg-open`.
