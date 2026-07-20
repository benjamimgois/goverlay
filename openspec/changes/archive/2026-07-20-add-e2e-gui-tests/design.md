## Context

Testing LCL (Lazarus Component Library) GUI applications on Linux has historically been done manually. The logic within GOverlay is tightly coupled with UI form units, making Pascal-level unit tests complex and requiring significant refactoring. We need a black-box end-to-end (E2E) testing framework that simulates real mouse/keyboard inputs, validates UI behavior, and checks that files are written correctly.

## Goals / Non-Goals

**Goals:**
- Provide a CLI-based test runner that boots GOverlay inside a virtual display framebuffer (`Xvfb`).
- Automate key test flows: opening the app, navigating to the OptiScaler tab, toggling driver preferences, and saving.
- Verify that correct INI configurations are saved in the output config directory after saving settings.
- Run on headless environments like GitHub Actions CI.

**Non-Goals:**
- High-level accessibility-tree tests (AT-SPI / Dogtail) which are fragile across different Desktop Environments and widgetsets (Gtk2 vs Qt5).
- Refactoring the Pascal codebase to implement FPCUnit tests.

## Decisions

### 1. Python-based E2E Test Suite with Xvfb and pyautogui/xdotool

**Decision:** Implement the test suite in Python, using:
- `Xvfb` (via `pyvirtualdisplay` or subprocess shell) to run GOverlay in a headless desktop environment.
- `pyautogui` or `xdotool` to simulate GUI inputs.
- `PIL/Pillow` (and optional OpenCV) template matching to click on buttons based on template images (e.g. `optiscaler_tab.png`, `save_button.png`).
- Standard python `unittest`/`pytest` to orchestrate tests and perform assertions on the written INI files.

**Rationale:** Template matching (using screenshots of UI elements) is highly portable, does not depend on absolute screen coordinates (which shift with window position), and is robust against subtle layout changes. Using Xvfb guarantees consistency across developer machines and headless CI servers.

### 2. Isolate Configuration Outputs for Testing

**Decision:** The test runner will configure a mock home directory structure (`$HOME` environment variable override) before launching GOverlay.

**Rationale:** This keeps the host system's GOverlay settings safe from being overwritten during tests, and allows clean verification by deleting/asserting the configuration files created in the mock `$HOME/.config/goverlay/` directory.

## Risks / Trade-offs

- **[Risk] Visual timing and race conditions** — simulating mouse clicks requires waiting for GOverlay to launch and paint its windows.
  → **Mitigation:** Implement retry-based wait helpers that periodically capture screen/search for template buttons instead of hardcoded `sleep` calls.
- **[Risk] Font and Theme changes breaking template matches** — if GOverlay looks slightly different on different systems, template matching might fail.
  → **Mitigation:** Keep template matching threshold (`confidence`) slightly flexible (e.g. 0.85-0.90) and lock Xvfb to a standard screen resolution and depth.
