## Why

In the MangoHud **Performance** tab, the previous fixed 2-row horizontal split created severe spatial imbalances:
1. The **VSYNC** sub-card was constrained to a tall row while only containing two simple dropdowns, leaving over 70% of its area empty.
2. The **Filters** sub-card left a massive (~200px) empty void in its bottom half after converting to horizontal sliders.
3. The **Information** and **Limiters** sub-cards were constrained by rigid row heights rather than their content density.

Transitioning to two independent vertical columns (Option B) — **FPS & Metrics** on the left column, and **Graphics & Sync** on the right column — organizes related settings by functional domain and eliminates idle space by giving each card an optimal, dedicated height.

## What Changes

- **Restructure Performance Tab Cards**: Reorganize the Performance tab into 4 distinct cards arranged across 2 independent vertical columns:
  - **Left Column (FPS & Timing)**:
    - `Information` card: Dedicated height (~200px) providing ample breathing room for the 7 FPS/frametime display toggles and sub-action buttons.
    - `Limiters` card: Occupies the remainder of the left column height (~370px+) with harmonious, cohesive vertical spacing between the FPS Limit input, FPS color thresholds, and Method/Toggle key controls.
  - **Right Column (Graphics, Sync & Texture Filtering)**:
    - `VSYNC` card: Compact height (~130px) cleanly housing the Vulkan and OpenGL synchronization dropdowns with zero wasted space.
    - `Filters` card: Occupies the remainder of the right column height (~440px+), providing clean vertical rhythm for the filter radio group and both horizontal sliders (Anisotropic Filtering and Mip-map LoD bias) while maintaining safe clearance from the floating action pill dock.
- **Dynamic Reflow & Resizing**: Update `ReflowPerformanceTab` in `mangohud_ui.pas` to dynamically compute column widths and proportional heights across varying window dimensions (960x650 through maximized 1920x1080).
- **GUI Tests**: Update automated test suite in `tests/gui/gui_test_cases.pas` to validate the new 2-column card hierarchy and geometry constraints.

## Capabilities

### Modified Capabilities
- `expanded-vertical-tab-cards`: Update scenario for MangoHud Performance tab to define the 2-column independent card hierarchy (compact VSYNC, expanded Filters, dedicated Information and Limiters).
- `ui-design-system`: Standardize card and sub-section layout metrics for the 2-column Performance tab structure.

## Impact

- `mangohud_ui.pas`: Update `BuildPerformanceTab` and `ReflowPerformanceTab` card creation and positioning.
- `tests/gui/gui_test_cases.pas`: Update GUI test assertions for the Performance tab layout.
