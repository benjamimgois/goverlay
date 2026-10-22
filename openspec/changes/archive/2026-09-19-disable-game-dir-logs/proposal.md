# Proposal

## Why

Currently, `bgmod` and `bgmod-uninstaller` write diagnostic log files (`bgmod.log`, `mangohud.log`, `optiscaler.log`, `vkbasalt.log`, etc.) directly into the game's executable directory (`GameDir`). Games with anti-cheat protection (such as *Phasmophobia*, Easy Anti-Cheat, BattlEye, or other integrity checkers) detect these newly created foreign files in their directory and either fail to launch, flag anti-cheat violations, or disconnect players from multiplayer sessions.

Since GOverlay already maintains a dedicated centralized logging directory (`~/.local/share/goverlay/logs/<GameName>/`) and the GOverlay GUI log viewer reads exclusively from this central directory, writing logs to `GameDir` is redundant and harmful to anti-cheat protected titles.

## What Changes

- Stop writing `bgmod.log` and `bgmod-uninstaller.log` directly into the game directory (`GameDir`).
- Stop initializing and generating tool log files (`mangohud.log`, `mako.log`, `lsfg.log`, `optiscaler.log`, `dlss-enabler.log`, `vksumi.log`, `vkbasalt.log`, `reshade.log`) in `GameDir`.
- Update `RunSubprocessLogger` in `bgmod` to write captured stderr tool logs exclusively to descriptors in `CentralLogDir`.
- Keep logging to `/tmp/bgmod.log`, `/tmp/bgmod-uninstaller.log`, and the central GOverlay logs folder (`~/.local/share/goverlay/logs/<GameName>/`).
- Keep OptiScaler's console/stderr logging enabled so all OptiScaler diagnostics continue to flow into `CentralLogDir/optiscaler.log`, but prevent OptiScaler from dropping an unmanaged `OptiScaler.log` file directly into `GameDir` when possible.
- Update `README.md` and documentation to clarify that logs are stored in the central GOverlay directory and `/tmp/`.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `centralized-tools-logging`: Update requirements to eliminate log file creation in the game directory (`GameDir`), directing all tool diagnostic outputs exclusively to the centralized log directory (`~/.local/share/goverlay/logs/<GameDirName>/`) and `/tmp/`.

## Impact

- **Affected Code**: `bgmod.lpr`, `bgmod-uninstaller.lpr`, `README.md`, and any associated tests.
- **Game Directories**: Game directories will remain pristine and free of unexpected `.log` files, eliminating anti-cheat false positives.
- **Compatibility**: The GOverlay GUI log viewer remains 100% functional without changes because it already resolves logs from `GetGameLogDir(FActiveGameName)`.
