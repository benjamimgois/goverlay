# bgmod — Agent Context & Architecture

`bgmod` is a native compiled Free Pascal wrapper (`bgmod.lpr`) designed to replace the legacy `fgmod` bash script inside GOverlay. It intercepts game execution arguments, configures environment variables, handles Wine DLL overrides, manages upscale plugins, and executes the target game.

## Architecture & Workflow

1. **Resolution**: On startup, it resolves the target game directory from execution arguments, Lutris game IDs, or `STEAM_COMPAT_INSTALL_PATH`.
2. **Configuration**: It parses configuration values and environment variables from `bgmod.conf`.
3. **Upscaler Setup**: If OptiScaler is toggled, it backs up original system/game DLLs, copies dynamic link libraries (`OptiScaler.dll`, XeSS, FidelityFX, fake-nvapi), and sets up the plugins directory.
4. **Execution**: Exports active environment variables and launches the target game subprocess using `execvp`.

---

## Key Files & Structure

| File | Type | Purpose |
|---|---|---|
| `bgmod` | Binary | Main compiled wrapper executable. |
| `bgmod-uninstaller` | Binary | Native uninstaller. Restores backed up files and cleans game folders. |
| `bgmod.conf` | INI Config | Configuration file containing `[Config]`, `[Env]`, and `[Launchers]` sections. |

---

## Configuration Format (`bgmod.conf`)

`bgmod.conf` is stored next to the wrapper binary (either globally or inside game-specific config directories).

### `[Config]` Section
- `GOVERLAY_MANGOHUD` (0/1): Toggles MangoHud overlay.
- `GOVERLAY_VKBASALT` (0/1): Toggles vkBasalt overlay.
- `GOVERLAY_OPTISCALER` (0/1): Toggles OptiScaler.
- `GOVERLAY_TWEAKS` (0/1): Toggles Proton tweaks and env vars.
- `DLL` (string): Target DLL name to load (default: `dxgi.dll`).
- `PRESERVE_INI` (true/false): Toggles persistence of `OptiScaler.ini`.

### `[Env]` Section
Standard environment variables to export before running the game (e.g. `PROTON_ENABLE_HDR=1`).

### `[Launchers]` Section
Dynamic rules to match launcher EXEs and redirect them to target game EXEs.
Format: `GameSubstring = LauncherEXE|ActualGameEXE`
Example:
```ini
[Launchers]
Cyberpunk 2077 = REDprelauncher.exe|bin/x64/Cyberpunk2077.exe
Witcher 3 = REDprelauncher.exe|bin/x64_dx12/witcher3.exe
```
If the launchers section or file is missing, the binary falls back to its built-in default launchers list.

---

## Uninstallation Model

The uninstaller `bgmod-uninstaller` resolves the game directory, and:
1. Deletes copied upscaler and overlay DLLs and configuration files.
2. Removes the `plugins/` directory recursively.
3. Restores original game files from `.b` backups.
4. Deletes the wrapper symlinks, wrapper logs, and itself.
5. Supports the `-g` / `--global` flag to clean up the central GOverlay config directory.

---

## Logging
Execution logs are written to:
1. `/tmp/bgmod.log` (wrapper) and `/tmp/bgmod-uninstaller.log` (uninstaller).
2. `bgmod.log` and `bgmod-uninstaller.log` inside the game directory.
3. Central GOverlay logs directory: `~/.local/share/goverlay/logs/[Game Name]/bgmod.log`.
