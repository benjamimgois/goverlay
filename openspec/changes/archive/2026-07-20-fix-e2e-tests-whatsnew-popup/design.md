## Context

When GOverlay runs for the first time, it spawns a modal changelog popup. This happens during E2E tests because `$HOME` is mock-isolated. The popup blocks all inputs to the main window.
Additionally, LCL's UI uses a mixed layout: the left sidebar (containing the main tabs) has a fixed width of 211px, while the right-side configuration panels scale dynamically based on the parent window dimensions. Proportional-only scaling makes left-tab clicks miss their target when the window is resized.

## Goals / Non-Goals

**Goals:**
- Bypass the changelog popup on startup in E2E tests.
- Fix click coordinates calculations to handle the fixed-width sidebar (Left menu) and proportional right-side panels.

**Non-Goals:**
- Disable the changelog popup feature in production builds.

## Decisions

### 1. Mock `config.ini` Startup State

**Decision:** The test runner will write a basic `config.ini` in `$MOCK_HOME/.config/goverlay/config.ini` before running the GOverlay binary:
```ini
[General]
ChangelogSeenVersion=1.8.9
```

**Rationale:** The Pascal source check reads `ChangelogSeenVersion` to decide whether to spawn `TChangelogFetchThread`. Writing this value beforehand tricks the app into skipping the popup without changing any Pascal logic.

### 2. Differentiate Sidebar vs Panel Geometry Clicking

**Decision:**
- **Sidebar Tab clicks (MangoHud, vkBasalt, OptiScaler, Tweaks):** Keep absolute coordinates X = 142. Y remains at fixed values (165, 255, 345, 435) because the left panel does not scale.
- **Nvidia Radio Button (Left-anchored panel item):** Keep absolute X = 293 (calculated as `211 + 82`).
- **Mesa Radio Button (Right-anchored panel item):** Calculate dynamic X = `W - 322`, where `W` is the parsed window width.

**Rationale:** This matches Lazarus LCL's anchoring layout design, allowing clicks to land exactly on targets regardless of window size changes or system-level window scaling.
