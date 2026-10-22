## Context

See `proposal.md` for motivation.

`bgmod` is a lightweight Free Pascal binary that parses `bgmod.conf`, sets up environment variables, ensures required runtime libraries and configuration files exist, and executes the game binary or Proton via `execvpe`.

Currently, `bgmod` operates invisibly in the background. To provide visual confirmation without introducing lag into the game's startup timeline, a dedicated lightweight graphical helper `bgmod-splash` is executed asynchronously.

## Goals / Non-Goals

**Goals:**
- Provide clear visual confirmation of all actively loaded GOverlay modules and configurations at game startup.
- Guarantee 0ms delay in game launch by decoupling the splash display process from `bgmod`'s `execvpe` execution path.
- Provide a persistent toggle in GOverlay's Settings Menu (`settingsMenu`) placed under "Create Steam shortcut", enabled by default.
- Support standalone execution of `bgmod-splash` for straightforward manual and automated verification.

**Non-Goals:**
- Replace or modify the in-game HUD overlay (MangoHud handles persistent in-game statistics).
- Display a modal that requires user interaction to proceed (the splash must auto-dismiss automatically).

## Decisions

### Decision 1: Standalone `bgmod-splash` binary vs desktop notifications vs in-process GUI
- **Chosen Option:** Dedicated lightweight LCL binary `bgmod-splash`.
- **Rationale:**
  - `bgmod` is compiled with standard `fpc` without GUI dependencies, keeping its startup footprint minimal.
  - Desktop notifications (`notify-send`) appear in corners, lack visual branding consistency, and are frequently hidden in fullscreen games or Gamescope.
  - Building `bgmod-splash` via Lazarus LCL ensures identical visual theming with GOverlay (matching fonts, dark theme palette, and vector/PNG assets) while keeping `bgmod` pure and robust.
- **Alternatives Considered:**
  - `notify-send` / D-Bus: Rejected as user requested a centered splash screen with logo and green checkboxes.
  - Embedding GUI directly into `bgmod.lpr`: Rejected to prevent adding LCL/GUI dependencies to the core launcher wrapper and to preserve fast execution.

### Decision 2: Asynchronous invocation via `fpFork` in `bgmod.lpr`
- **Chosen Option:** Right before executing `execvpe`, if `SHOW_LAUNCH_SPLASH=1` and at least one module is active, `bgmod` calls `fpFork`. The child process invokes `bgmod-splash` with command-line arguments and detaches, while the parent immediately invokes `execvpe`.
- **Rationale:** The game begins launching simultaneously with zero added latency.
- **Command-line Interface for `bgmod-splash`:**
  - `--game="<Title>"`: Optional game title to display.
  - `--item="<Module Label>"`: Repeated argument for each active module (e.g. `--item="MangoHud"`, `--item="OptiScaler (FSR 3.1)"`, `--item="Lossless Scaling (lsfg-vk)"`, `--item="Environment Variables"`).
  - `--duration=<milliseconds>`: Auto-dismiss timeout (default 2500ms).

### Decision 3: Visual Design & Window Manager Hints
- **Chosen Option:** Borderless form (`BorderStyle := bsNone`), dark background (`$00201A18` / RGB 24, 26, 32), centered on screen (`poScreenCenter`), `fsStayOnTop`.
- **Rationale:**
  - Uses `_NET_WM_WINDOW_TYPE_SPLASH` or `_NET_WM_WINDOW_TYPE_NOTIFICATION` on X11 / Wayland to prevent window managers or Gamescope from attempting to tile or maximize the splash.
  - Interactive dismiss on click or `OnKeyDown` (Esc, Space, Enter) for instant dismissal if desired.

### Decision 4: Settings Menu Placement & Configuration Persistence
- **Chosen Option:** Add `FLaunchSplashItem: TMenuItem` in `settingsMenu` directly beneath `FCreateSteamShortcutItem` (in `sidebar_nav.pas`).
- **Rationale:** Matches user's exact specification. Configured as `AutoCheck := True`, defaulted to `True`, saved to `goverlay.conf` under `[General] ShowLaunchSplash` and written to `bgmod.conf` as `SHOW_LAUNCH_SPLASH=1`.

## Risks / Trade-offs

- **[Risk]** Headless or non-graphical execution (e.g. tests or dedicated server runs).
  - **Mitigation:** `bgmod` checks if `DISPLAY` or `WAYLAND_DISPLAY` is present; if neither is set, it silently skips launching `bgmod-splash`.
- **[Risk]** Gamescope compositor capturing the window in Steam Deck Game Mode.
  - **Mitigation:** Setting window type hints to splash/notification ensures Gamescope treats the window as an overlay rather than the primary game window.
