# Design: vkNemu Idle Frame Limiter Layer Integration

## Context

Goverlay currently manages several Vulkan layers and runtime utilities (`MangoHud`, `vkBasalt`, `vkSumi`, `OptiScaler`, `MAKO`, `LSFG-VK`). The `vkSumi` layer (from upstream author `reakjra`) established a proven pattern in `optiscaler_update.pas`: checking GitHub releases for `.pkg.tar.zst` packages, extracting shared objects to `~/.local/share/goverlay/layers/`, validating ELF headers with `IsValidSharedLibrary`, generating implicit layer manifests in `~/.local/share/vulkan/implicit_layer.d/`, and recording installed tags in `goverlay.vars`.

The MangoHud "Performance" tab hosts `FPerfCards[1]`, divided into `FPerfLimitSec` ("Limiters") and `FPerfFiltersSec` ("Filters"). `FPerfLimitSec` currently contains ample unused vertical padding between its FPS color thresholds and bottom method controls, making it an ideal home for dynamic idle limiting controls without adding sidebar clutter.

## Goals / Non-Goals

**Goals:**
- Implement automated provisioning of `libVkLayer_vknemu.so` during startup splash using the established `vkSumi` download/unpack pattern.
- Integrate clean, MD3-compliant UI controls for vkNemu inside `FPerfLimitSec` in `mangohud_ui.pas`.
- Ensure robust validation of binary files to protect against corrupt downloads and SteamOS bootloop regressions.
- Support configuration serialization in both global and per-game profiles.
- Inject `VKNEMU=1` and its parameters into GUI game launches, preview runs, and wrapper scripts (`fgmod`/`bgmod`).
- Register vkNemu in `goverlay-update-auditor` for automated tracking of upstream changes.

**Non-Goals:**
- Creating a separate sidebar category or top-level tab for vkNemu.
- Supporting legacy 32-bit builds by default (unless specifically requested; focusing on standard 64-bit x86_64 gaming runtime).
- Modifying MangoHud's internal configuration format (vkNemu is configured via standard environment variables).

## Decisions

### Decision 1: Embed vkNemu Controls in the MangoHud "Limiters" Card
- **Rationale**: The card `FPerfLimitSec` has a fixed base height of 389px and currently leaves significant vertical space empty. Placing vkNemu here unifies static frame capping (MangoHud) and dynamic idle capping (vkNemu) into a single logical "Limiters" panel.
- **Visual Separation**: A subtle horizontal line and a distinct subtitle `❄ Idle Limiter (vkNemu)` with its own master `TToggleSwitch` clearly indicates to users that this is an independent layer feature.
- **Alternatives Considered**:
  - *New tab in sidebar*: Excessive overhead for only 4-5 controls; clutters navigation rail.
  - *Tweaks tab*: Tweaks is structured as a scrolling list of toggles, lacking rich card-based parameter controls.

### Decision 2: Reuse the `vkSumi` Extraction & Verification Architecture
- **Rationale**: `reakjra/vkNemu` distributes Arch Linux packages (`.pkg.tar.zst`) and `.deb` archives containing `libVkLayer_vknemu.so` and `vknemu.json`. Goverlay already has native `tar` extraction routines and `IsValidSharedLibrary` verification in `optiscaler_update.pas`.
- **Manifest Location**: `~/.local/share/vulkan/implicit_layer.d/vknemu.json` pointing to `~/.local/share/goverlay/layers/vknemu/libVkLayer_vknemu.so`.
- **Activation Mechanism**: The upstream manifest specifies `"enable_environment": {"VKNEMU": "1"}`. It only activates when `VKNEMU=1` is exported in the process environment.
- **Alternatives Considered**:
  - *Direct source compilation*: Requires meson, ninja, vulkan development headers on user system; impractical for end users.

### Decision 3: Flatpak Sandbox Isolation
- **Rationale**: Following lessons learned in previous changes, `CheckAndInstallVkNemu` must check `if IsRunningInFlatpak then Exit;` immediately, preventing inadvertent modification of host Vulkan layer directories from within Flatpak.

### Decision 4: Environment Variable Schema & Defaults
- Variables injected when enabled:
  - `VKNEMU=1`: Activates layer.
  - `VKNEMU_IDLE_FPS`: Target FPS when idle (default `30`).
  - `VKNEMU_TIMEOUT`: Seconds before idle capping begins (default `2`).
  - `VKNEMU_UNFOCUSED`: `1` to cap immediately when unfocused (default `1`).
  - `VKNEMU_INPUT`: `all`, `keyboard`, `gamepad`, or `none` (default `all`).
  - `VKNEMU_DELAY`: Optional startup delay in seconds (default `0`).

## Risks / Trade-offs

- **[Wayland Compositor Support]** → Under Wayland, keyboard/mouse idle detection requires `ext_idle_notifier_v1` v2 in the compositor; otherwise vkNemu falls back to unfocused and gamepad idling.
  - *Mitigation*: Add an informative tooltip on the `Input` selector explaining the Wayland compositor requirement.
- **[Gamescope Window Unfocus]** → Window unfocus capping does not trigger under Gamescope/Steam Deck embedded session.
  - *Mitigation*: Mention in tooltip that idle input timeout is the primary limiter under Gamescope.
- **[Network / GitHub API Rate Limits]** → GitHub API requests could fail or be rate-limited.
  - *Mitigation*: Provide hardcoded fallback URLs for the known stable release (v0.2.0) and verify files before creating the manifest.
