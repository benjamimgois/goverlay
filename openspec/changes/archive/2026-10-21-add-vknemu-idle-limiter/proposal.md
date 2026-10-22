# Proposal: Integrate vkNemu Idle Frame Limiter Layer

## Why

Linux gamers currently lack an out-of-the-box dynamic frame rate limiter equivalent to AMD Radeon Chill, which automatically caps frame rates when a game is idle (no input) or when the game window is unfocused to save power and reduce heat/noise without impacting responsiveness during gameplay. The upstream `vkNemu` Vulkan layer provides this exact functionality, and integrating it into Goverlay with automated provisioning during boot splash and intuitive controls in the MangoHud Performance "Limiters" card provides a seamless power-saving solution for native Linux and Steam Deck environments.

## What Changes

- **Automated vkNemu Runtime Provisioning**: Implement `CheckAndInstallVkNemu` in `optiscaler_update.pas` and call it from `TStartupDownloadThread` during the startup splash sequence. Automatically download `vknemu-*-x86_64.pkg.tar.zst` from GitHub releases (`reakjra/vkNemu`), unpack `libVkLayer_vknemu.so` into `~/.local/share/goverlay/layers/vknemu/`, validate binary integrity with `IsValidSharedLibrary`, register the user-space implicit Vulkan layer manifest `~/.local/share/vulkan/implicit_layer.d/vknemu.json`, and record the installed version in `goverlay.vars`.
- **Flatpak Guarding**: Guard vkNemu automated installation to immediately exit when running in Flatpak sandbox (`if IsRunningInFlatpak then Exit;`), preventing unauthorized host layer modifications.
- **Upstream Repository Monitoring**: Register `vknemu` in `.agent/skills/goverlay-update-auditor/references/repositories.json` for tracking future releases, tags, and new options.
- **Performance Tab UI Integration**: Reorganize the "Limiters" card (`FPerfLimitSec`) in `mangohud_ui.pas` to add an "Idle Limiter (vkNemu)" sub-section with a divider, Master `TToggleSwitch`, `Idle FPS` spin control, `Timeout (s)` spin control, `Input` device selector (All, Keyboard/Mouse, Gamepad), `Cap on Unfocus` toggle, and optional `Delay (s)` spin control.
- **Configuration & Launch Environment**: Persist vkNemu settings in `goverlay.ini` (global and per-game configs), implement `GetVkNemuLaunchEnv` in `overlayunit.pas` to export `VKNEMU=1` and associated environment variables (`VKNEMU_IDLE_FPS`, `VKNEMU_TIMEOUT`, `VKNEMU_UNFOCUSED`, `VKNEMU_INPUT`, `VKNEMU_DELAY`), and append them to test cube executions and `fgmod`/`bgmod` game wrappers.

## Capabilities

### New Capabilities
- `vknemu-idle-limiter`: Provisioning, update monitoring, UI controls in the MangoHud Limiters card, configuration persistence, and launch environment injection for the vkNemu idle frame limiter Vulkan layer.

### Modified Capabilities
*(None - existing capabilities maintain current contracts)*

## Impact

- **Affected Code**:
  - `optiscaler_update.pas`: Automated download, extraction, validation, and update detection routines.
  - `mangohud_ui.pas`: UI layout and control creation in `FPerfLimitSec` (`BuildPerformanceTab`, `ReflowPerfTab`).
  - `overlayunit.pas` / `overlayunit.lfm`: Splash thread execution (`TStartupDownloadThread.Execute`), launch environment builder (`GetVkNemuLaunchEnv`), and UI synchronization.
  - `configkeys.pas` & `configmanager.pas`: Configuration key constants and serialization/deserialization.
  - `data/bgmod/` & `data/fgmod/`: Wrapper scripts support for `GOVERLAY_VKNEMU`.
  - `.agent/skills/goverlay-update-auditor/references/repositories.json`: Auditor tool registration.
- **Dependencies**: Requires `curl` and `tar` (standard system utilities already required by Goverlay) for archive extraction.
