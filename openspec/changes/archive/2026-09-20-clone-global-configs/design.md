# Design: Clone Global Configs

## Context

Goverlay maintains global configurations under `~/.local/share/goverlay/gameconfig/global/` and tool-specific host folders (such as `~/.config/vkBasalt/` and `~/.config/vkSumi/`). Individual game configurations are stored under `~/.local/share/goverlay/gameconfig/<SanitizeFileName(GameName)>/`.

Currently, selecting a game initializes only launcher wrappers (`bgmod`, `bgmod-uninstaller`, and `fgmod` link) leaving tool configuration files empty until manually created and saved by the user.

## Goals / Non-Goals

**Goals:**
- Provide a unified helper method to clone all global config files to any target game's configuration folder.
- Add "Clone global configs" in the game card context menu (`FGameCardMenu`) on the Games tab below "Open prefix folder".
- Add "Clone global configs" in the floating action dock menu (`popsaveMenu`) visible during active game configuration.
- Accurately rewrite game-specific paths (e.g. `[Env] MANGOHUD_CONFIGFILE`) inside the game's `bgmod.conf`.
- Deploy OptiScaler binaries to the game directory when OptiScaler is enabled globally.
- Preserve safety by prompting confirmation when target game has existing configurations.

**Non-Goals:**
- Creating dynamic symlinks or persistent inheritance ("use global" mode) where changes to global automatically cascade to games.
- Changing game launch wrappers or how game executables invoke `bgmod`.

## Decisions

### 1. Centralized Cloning Routine in Helper
- **Decision**: Implement `CloneGlobalConfigToGame(const AGameName: string; const AGamePath: string): Boolean` accessible to both `games_tab.pas` and `overlayunit.pas`.
- **Rationale**: Keeps the file copying, directory creation, `bgmod.conf` path rewriting, and OptiScaler file deployment logic strictly unified and DRY.
- **Alternatives Considered**: Duplicating copy logic in each menu click handler (rejected for maintenance risks).

### 2. File Copying Matrix
The routine copies:
- `MangoHud.conf`: Source `GetGameConfigDir('') + 'MangoHud.conf'` (or fallback `GetMangoHudConfigDir() + 'MangoHud.conf'`).
- `vkBasalt.conf`: Source `IncludeTrailingPathDelimiter(GetVkBasaltConfigDir()) + 'vkBasalt.conf'`.
- `vkSumi.conf`: Source `IncludeTrailingPathDelimiter(GetVkSumiConfigDir()) + 'vkSumi.conf'`.
- `OptiScaler.ini`, `fakenvapi.ini`, `goverlay.vars`: Source `GetGameConfigDir('') + <file>`.
- `lsfg.toml`, `conf.toml`: Source `GetGameConfigDir('') + <file>`.
- `bgmod.conf`: Source `GetGameConfigDir('') + 'bgmod.conf'`.
  - Rewrite `[Env] MANGOHUD_CONFIGFILE := GameCfgDir + 'MangoHud.conf'`.
  - If `GOVERLAY_OPTISCALER=1` in the resulting config, execute `CopyOptiScalerGameFiles(GameCfgDir)`.
- Base wrappers: Ensure `bgmod`, `bgmod-uninstaller`, and symlink `fgmod` are present.

### 3. Conditional Confirmation
- **Decision**:
  - From card context menu: Check if game directory contains any of `bgmod.conf`, `MangoHud.conf`, `vkBasalt.conf`, `OptiScaler.ini`, etc. If yes, show confirmation dialog (`MessageDlg`). If no, clone immediately.
  - From floating dock menu: Always show confirmation dialog because the user is currently editing that profile and uncommitted edits could be discarded.

### 4. Post-Clone UX
- **Card menu (Games tab)**:
  - Stay on Games tab.
  - Call `UpdateGameCardBadge(GameName)` to immediately update the corner ribbon badges.
  - Display non-intrusive notification (`SendNotification`).
- **Dock menu (Game mode)**:
  - Call `LoadGameToggleStates` to update sidebar toggle icons.
  - Reload active tab (e.g. `LoadMangoHudConfig` if on MangoHud tab, `LoadVkBasaltConfig` if on vkBasalt tab, etc.).
  - Refresh launch command string (`FLaunchCommand := GetLaunchCommand`).

## Risks / Trade-offs

- [Risk] Global `bgmod.conf` contains an absolute path to global `MangoHud.conf` in `[Env]` → [Mitigation] Explicitly read and re-write `MANGOHUD_CONFIGFILE` in the target `bgmod.conf` using `TIniFile`.
- [Risk] Cloned OptiScaler configuration requires DLLs that are missing in the game directory → [Mitigation] Check `GOVERLAY_OPTISCALER` in the cloned `bgmod.conf` and invoke `CopyOptiScalerGameFiles` if enabled.
- [Risk] Accidental overwrite of a heavily tuned game profile → [Mitigation] Detect existing configs and prompt confirmation before proceeding.
