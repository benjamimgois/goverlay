# Design

## Context

GOverlay previously relied on a Status / Home tab that was default or located on the sidebar. Recent updates moved startup to MangoHud Presets and consolidated dependencies under the settings menu (`⚙` -> Status). As a result, users frequently do not inspect system dependencies before configuring tools. When required system libraries like MangoHud or vkBasalt are absent, users save configurations that have no effect in games, creating frustration and false bug reports.

## Goals / Non-Goals

**Goals:**
- Provide clear, immediate visual feedback on tool pages when required system dependencies are missing.
- Keep the sidebar navigation clickable so users are never blocked from understanding why a tool is not available.
- Deactivate configuration controls and the Save button when a tool's required runtime is absent to prevent useless config generation.
- Supply environment-aware installation instructions (exact Flatpak commands vs native distro package advice).
- Support method-level reactivity in multi-method tabs (e.g. vkBasalt vs ReShade in Post Processing).
- Provide immediate actions to view full diagnostic status or re-check without restarting GOverlay.

**Non-Goals:**
- Automatically executing `sudo` or package manager commands in the background without user knowledge.
- Altering the existing built-in downloader flows for tools that have in-app installers (OptiScaler, ReShade shaders).

## Decisions

### 1. Banner Placement and Visibility
- **MangoHud Tab**: Placed at the top of the MangoHud tab sheet area (visible when inspecting presets/options). When `mangohud` or its Flatpak runtime is missing, the banner is displayed, MangoHud sub-tab control trees are disabled via `SetControlTreeEnabled`, and the Save button is disabled.
- **Post Processing Tab**: Placed dynamically when `rmVkBasalt` is selected. If vkBasalt is missing, the banner appears above the vkBasalt configuration cards, the vkBasalt cards are disabled, and the Save button is disabled. Switching to `rmReshade` hides the vkBasalt warning banner and restores ReShade functionality.
- *Alternative Considered*: Disabling the sidebar tab completely. Rejected because users could not click the tab and would never see the explanation or installation instructions.

### 2. Banner Styling and Layout
- The banner will be built using standard LCL components (`TPanel`, `TLabel`, `TBitBtn`/`TButton`) styled to respect the active dark/light theme.
- **Visuals**:
  - Dark Theme: Deep warm dark background (`$001B2433` / dark amber-slate), amber left border accent bar, light text, warning icon (`⚠️`).
  - Light Theme: Warm amber tint (`$00EBF8FF` / `$00D9F3FF` or `#FFF3CD`), amber left accent bar, dark text.
- **Contents**:
  - Header: Bold title (e.g., `MangoHud is not installed`).
  - Body: Descriptive text indicating whether the system is running under Flatpak (displaying `flatpak install org.freedesktop.Platform.VulkanLayer.MangoHud` or `.vkBasalt`) or native Linux (`Please install the 'mangohud' package using your distribution's package manager.`).
  - Actions:
    - Button `View Status`: Invokes `ShowHomeTab` to display the full dependency diagnostic screen.
    - Button `Re-check`: Triggers `CheckDependencies` and refreshes the banner and control states dynamically.

### 3. State Management and Re-check
- A reusable dependency helper or method in `overlayunit.pas` (e.g., `UpdateToolMissingDependencyBanners`) checks `Missing` list against `DEP_MANGOHUD` / `DEP_MANGOHUD_RUNTIME` and `DEP_VKBASALT` / `DEP_VKBASALT_RUNTIME`.
- Calling "Re-check" immediately re-runs `CheckDependencies` without requiring the user to close and reopen the application.

## Risks / Trade-offs

- **[Risk] Controls remain disabled after user installs the package outside GOverlay**  
  → *Mitigation*: The banner includes a "Re-check" button, and entering/switching tabs automatically refreshes the dependency status.
- **[Risk] Post processing tab has multiple methods where only one might be missing**  
  → *Mitigation*: In `reshade_tab.pas`, banner visibility is strictly tied to `FSelectedMethod = rmVkBasalt`. If user chooses `rmReshade`, the vkBasalt banner is hidden and ReShade controls function normally.
